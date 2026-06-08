#!/bin/bash
set -e

MODEL_DIR="${MODEL_DIR:-/workspace/models}"
PORT="${PORT:-10095}"
MODE="${MODE:-2pass}"
DECODER_THREADS="${DECODER_THREADS:-4}"
IO_THREADS="${IO_THREADS:-2}"
MODEL_THREADS="${MODEL_THREADS:-1}"

VAD_MODEL_MS="${VAD_MODEL_MS:-damo/speech_fsmn_vad_zh-cn-16k-common-onnx}"
VAD_MODEL_HF="${VAD_MODEL_HF:-funasr/fsmn-vad-onnx}"
ASR_MODEL_MS="${ASR_MODEL_MS:-damo/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-onnx}"
ASR_MODEL_HF="${ASR_MODEL_HF:-funasr/Paraformer-large}"
PUNC_MODEL_MS="${PUNC_MODEL_MS:-damo/punc_ct-transformer_zh-cn-common-vad_realtime-vocab272727-onnx}"
PUNC_MODEL_HF="${PUNC_MODEL_HF:-funasr/ct-punc-onnx}"
ONLINE_MODEL_MS="${ONLINE_MODEL_MS:-damo/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-online-onnx}"
ONLINE_MODEL_HF="${ONLINE_MODEL_HF:-funasr/paraformer-zh-streaming}"
ITN_MODEL="${ITN_MODEL:-thuduj12/fst_itn_zh}"
LM_MODEL="${LM_MODEL:-damo/speech_ngram_lm_zh-cn-ai-wesp-fst}"

# Use HuggingFace ID for directory if it's different from default
if [ "${ASR_MODEL_HF}" != "funasr/Paraformer-large" ]; then
    ASR_MODEL_DIR="${MODEL_DIR}/${ASR_MODEL_HF}"
else
    ASR_MODEL_DIR="${MODEL_DIR}/${ASR_MODEL_MS}"
fi

VAD_MODEL_DIR="${MODEL_DIR}/${VAD_MODEL_MS}"
PUNC_MODEL_DIR="${MODEL_DIR}/${PUNC_MODEL_MS}"
ONLINE_MODEL_DIR="${MODEL_DIR}/${ONLINE_MODEL_MS}"
ITN_MODEL_DIR="${MODEL_DIR}/${ITN_MODEL}"
LM_MODEL_DIR="${MODEL_DIR}/${LM_MODEL}"

mkdir -p "${MODEL_DIR}"

download_model() {
    local model_id_ms="$1"
    local model_id_hf="$2"
    local model_dir="$3"
    local required_file="${4:-model_quant.onnx}"
    
    if [ -f "${model_dir}/${required_file}" ] || [ -f "${model_dir}/sense-voice-encoder.onnx" ] || [ -f "${model_dir}/sense-voice-encoder-int8.onnx" ]; then
        echo "  Already exists: ${model_id_ms}"
        return 0
    fi
    
    echo "  Downloading: ${model_id_ms}"
    python3 -c "
from huggingface_hub import snapshot_download
try:
    path = snapshot_download('${model_id_hf}', local_dir='${model_dir}')
    print(f'  Downloaded from HuggingFace: {path}')
except Exception as e:
    print(f'  HuggingFace failed: {e}')
    try:
        from modelscope.hub.snapshot_download import snapshot_download as ms_download
        ms_download('${model_id_ms}', local_dir='${model_dir}')
        print('  Downloaded from ModelScope')
    except Exception as e2:
        print(f'  ModelScope failed: {e2}')
        exit(1)
"
    if [ ! -f "${model_dir}/${required_file}" ] && [ ! -f "${model_dir}/sense-voice-encoder.onnx" ] && [ ! -f "${model_dir}/sense-voice-encoder-int8.onnx" ]; then
        echo "  WARNING: No model file found in ${model_dir}"
        ls -la "${model_dir}" 2>/dev/null || true
    fi
}

echo "=== FunASR Runtime ==="
echo "Mode: ${MODE}"
echo "Port: ${PORT}"
echo "Model dir: ${MODEL_DIR}"
echo ""

echo "Checking models..."
download_model "${VAD_MODEL_MS}" "${VAD_MODEL_HF}" "${VAD_MODEL_DIR}" "model_quant.onnx"
download_model "${ASR_MODEL_MS}" "${ASR_MODEL_HF}" "${ASR_MODEL_DIR}" "model_quant.onnx"
download_model "${PUNC_MODEL_MS}" "${PUNC_MODEL_HF}" "${PUNC_MODEL_DIR}" "model_quant.onnx"
download_model "${ITN_MODEL}" "" "${ITN_MODEL_DIR}" "configuration.json"
download_model "${LM_MODEL}" "" "${LM_MODEL_DIR}" "TLG.fst"

if [ "$MODE" = "2pass" ] || [ "$MODE" = "online" ]; then
    download_model "${ONLINE_MODEL_MS}" "${ONLINE_MODEL_HF}" "${ONLINE_MODEL_DIR}" "model_quant.onnx"
fi

echo ""
echo "Starting ${MODE} server..."
if [ "$MODE" = "2pass" ] || [ "$MODE" = "online" ]; then
    exec /opt/funasr/bin/funasr-wss-server-2pass \
        --download-model-dir "${MODEL_DIR}" \
        --model-dir "${ASR_MODEL_DIR}" \
        --online-model-dir "${ONLINE_MODEL_DIR}" \
        --vad-dir "${VAD_MODEL_DIR}" \
        --punc-dir "${PUNC_MODEL_DIR}" \
        --itn-dir "${ITN_MODEL_DIR}" \
        --port "${PORT}" \
        --decoder-thread-num "${DECODER_THREADS}" \
        --io-thread-num "${IO_THREADS}" \
        --model-thread-num "${MODEL_THREADS}" \
        --certfile 0
elif [ "$MODE" = "offline" ]; then
    exec /opt/funasr/bin/funasr-wss-server \
        --download-model-dir "${MODEL_DIR}" \
        --model-dir "${ASR_MODEL_DIR}" \
        --vad-dir "${VAD_MODEL_DIR}" \
        --punc-dir "${PUNC_MODEL_DIR}" \
        --itn-dir "${ITN_MODEL_DIR}" \
        --port "${PORT}" \
        --decoder-thread-num "${DECODER_THREADS}" \
        --io-thread-num "${IO_THREADS}" \
        --model-thread-num "${MODEL_THREADS}" \
        --certfile 0
else
    echo "Unknown mode: ${MODE}. Use '2pass', 'online', or 'offline'."
    exit 1
fi
