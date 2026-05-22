FROM nvidia/cuda:12.4.0-runtime-ubuntu22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# 1. 添加 PPA 并安装 Python 3.12 (移除 python3.12-distutils，添加 python3.12-venv)
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 2. 安装 pip (通过 get-pip.py 方式最稳妥)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    ln -s /root/.local/bin/uv /usr/bin/uv

# 3. 建立软链接
RUN ln -sf /usr/bin/python3.12 /usr/bin/python3 && \
    ln -sf /usr/bin/python3.12 /usr/bin/python

# 4. 安装 Torch 依赖
RUN uv pip install --system --no-cache torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

FROM base AS build
ENV SCVI_PATH="/usr/local/lib/scvi-tools"
COPY . ${SCVI_PATH}
ARG DEPENDENCIES=""

# 此时 Python 3.12 环境已就绪，scvi-tools 可以顺利通过版本检查
RUN uv pip install --system "scvi-tools[${DEPENDENCIES}] @ ${SCVI_PATH}"

RUN uv pip install --system --no-cache jupyterlab
RUN uv pip install --system --no-cache igraph

CMD ["/bin/bash"]
