# FunASR Runtime

Custom build of [FunASR](https://github.com/modelscope/FunASR) WebSocket server for real-time speech recognition.

## Why Custom Build?

The official Docker image is hosted on `registry.cn-hangzhou.aliyuncs.com` which is inaccessible from outside China. This image builds the same C++ runtime from source using publicly available dependencies.

## What's Included

- `funasr-wss-server`: Offline speech recognition server
- `funasr-wss-server-2pass`: Real-time streaming recognition with offline correction
- ONNX Runtime 1.14.0
- VAD, ASR, punctuation, and ITN models (downloaded on first startup)

## Usage

```bash
docker run -p 10095:10095 -v ./models:/workspace/models onno204/funasr:latest
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MODE` | `2pass` | Server mode: `2pass`, `online`, or `offline` |
| `PORT` | `10095` | WebSocket port |
| `MODEL_DIR` | `/workspace/models` | Model download directory |
| `DECODER_THREADS` | `4` | Inference thread count |

## Sources

- [FunASR Repository](https://github.com/modelscope/FunASR)
- [ONNX Runtime](https://github.com/microsoft/onnxruntime)
- [Build files](https://github.com/onno204/public-dockerhub-images/tree/main/onno204/funasr)
