FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    wget \
    ca-certificates \
    libssl-dev \
    libsndfile1-dev \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    autoconf \
    automake \
    libtool \
    portaudio19-dev \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

WORKDIR /build

RUN git clone --depth 1 --branch main https://github.com/modelscope/FunASR.git

ARG TARGETARCH
RUN cd /build/FunASR/runtime/onnxruntime/third_party && \
    if [ "$TARGETARCH" = "arm64" ]; then \
        ONNXRT_ARCH="aarch64"; \
    else \
        ONNXRT_ARCH="x64"; \
    fi && \
    wget -q https://github.com/microsoft/onnxruntime/releases/download/v1.14.0/onnxruntime-linux-${ONNXRT_ARCH}-1.14.0.tgz && \
    tar -xzf onnxruntime-linux-${ONNXRT_ARCH}-1.14.0.tgz && \
    rm onnxruntime-linux-${ONNXRT_ARCH}-1.14.0.tgz && \
    if [ "$TARGETARCH" = "arm64" ]; then \
        mv onnxruntime-linux-aarch64-1.14.0 onnxruntime-linux-x64-1.14.0; \
    fi

RUN mkdir -p /build/FunASR/runtime/websocket/build && \
    cd /build/FunASR/runtime/websocket/build && \
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_PORTAUDIO=OFF \
        -DENABLE_GLOG=ON \
        -DONNXRUNTIME_DIR=/build/FunASR/runtime/onnxruntime/third_party/onnxruntime-linux-x64-1.14.0 && \
    make -j$(nproc) && \
    mkdir -p /build/libs && \
    find . -name "*.so*" -exec cp {} /build/libs/ \; && \
    cp /build/FunASR/runtime/onnxruntime/third_party/onnxruntime-linux-x64-1.14.0/lib/libonnxruntime.so* /build/libs/

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl3 \
    libsndfile1 \
    python3 \
    python3-pip \
    python3-venv \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/bin/python3 /usr/bin/python

RUN pip3 install --no-cache-dir \
    funasr \
    modelscope \
    huggingface_hub

COPY --from=builder /build/libs/ /opt/funasr/lib/
COPY --from=builder /build/FunASR/runtime/websocket/build/bin/ /opt/funasr/bin/
COPY --from=builder /build/FunASR/runtime/run_server_2pass.sh /opt/funasr/
COPY --from=builder /build/FunASR/runtime/run_server.sh /opt/funasr/
COPY --from=builder /build/FunASR/runtime/ssl_key/ /opt/funasr/ssl_key/

ENV LD_LIBRARY_PATH="/opt/funasr/lib"

RUN ldconfig && chmod +x /opt/funasr/bin/*

COPY ./onno204/funasr/entrypoint.sh /opt/funasr/entrypoint.sh
RUN chmod +x /opt/funasr/entrypoint.sh

VOLUME /workspace/models

EXPOSE 10095

WORKDIR /opt/funasr

ENTRYPOINT ["/opt/funasr/entrypoint.sh"]
