#!/bin/bash
set -e

MODEL_DIR="${MODEL_DIR:-/workspace/models}"
PORT="${PORT:-10095}"
MODE="${MODE:-2pass}"
DECODER_THREADS="${DECODER_THREADS:-4}"
IO_THREADS="${IO_THREADS:-2}"
MODEL_THREADS="${MODEL_THREADS:-1}"

ASR_MODEL="${ASR_MODEL:-damo/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-onnx}"
ONLINE_MODEL="${ONLINE_MODEL:-damo/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-online-onnx}"
VAD_MODEL="${VAD_MODEL:-damo/speech_fsmn_vad_zh-cn-16k-common-onnx}"
PUNC_MODEL="${PUNC_MODEL:-damo/punc_ct-transformer_zh-cn-common-vad_realtime-vocab272727-onnx}"
ITN_MODEL="${ITN_MODEL:-thuduj12/fst_itn_zh}"

mkdir -p "${MODEL_DIR}"

echo "=== FunASR Runtime ==="
echo "Mode: ${MODE}"
echo "Port: ${PORT}"
echo "Model dir: ${MODEL_DIR}"
echo "ASR Model: ${ASR_MODEL}"
echo "Decoder threads: ${DECODER_THREADS}"
echo ""

if [ "$MODE" = "2pass" ] || [ "$MODE" = "online" ]; then
    echo "Starting 2pass WebSocket server..."
    exec /opt/funasr/bin/funasr-wss-server-2pass \
        --download-model-dir "${MODEL_DIR}" \
        --model-dir "${ASR_MODEL}" \
        --online-model-dir "${ONLINE_MODEL}" \
        --vad-dir "${VAD_MODEL}" \
        --punc-dir "${PUNC_MODEL}" \
        --itn-dir "${ITN_MODEL}" \
        --port "${PORT}" \
        --decoder-thread-num "${DECODER_THREADS}" \
        --io-thread-num "${IO_THREADS}" \
        --model-thread-num "${MODEL_THREADS}" \
        --certfile 0
elif [ "$MODE" = "offline" ]; then
    echo "Starting offline WebSocket server..."
    exec /opt/funasr/bin/funasr-wss-server \
        --download-model-dir "${MODEL_DIR}" \
        --model-dir "${ASR_MODEL}" \
        --vad-dir "${VAD_MODEL}" \
        --punc-dir "${PUNC_MODEL}" \
        --itn-dir "${ITN_MODEL}" \
        --port "${PORT}" \
        --decoder-thread-num "${DECODER_THREADS}" \
        --io-thread-num "${IO_THREADS}" \
        --model-thread-num "${MODEL_THREADS}" \
        --certfile 0
else
    echo "Unknown mode: ${MODE}. Use '2pass', 'online', or 'offline'."
    exit 1
fi
