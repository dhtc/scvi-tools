FROM nvidia/cuda:12.4.0-runtime-ubuntu22.04 AS base

# 1. 添加 PPA 并安装 Python 3.12
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
    python3.12 \
    python3.12-dev \
    python3.12-distutils \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 2. 为 Python 3.12 安装对应的 pip
RUN curl -sS https://pypa.io | python3.12

# 3. 建立软链接（确保命令指向 3.12 版本）
RUN ln -sf /usr/bin/python3.12 /usr/bin/python3 && \
    ln -sf /usr/bin/python3.12 /usr/bin/python && \
    ln -sf /usr/local/bin/pip3.12 /usr/local/bin/pip

# 4. 安装 uv (uv 会自动识别当前的 Python 3.12)
RUN pip install --no-cache-dir uv

# 5. 安装 Torch 依赖
RUN uv pip install --system --no-cache torch torchvision torchaudio

FROM base AS build
ENV SCVI_PATH="/usr/local/lib/scvi-tools"
COPY . ${SCVI_PATH}
ARG DEPENDENCIES=""

# 此时 Python 3.12 环境已就绪，scvi-tools 可以顺利通过版本检查
RUN uv pip install --system "scvi-tools[${DEPENDENCIES}] @ ${SCVI_PATH}"

CMD ["/bin/bash"]
