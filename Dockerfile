FROM nvidia/cuda:12.4.0-runtime-ubuntu22.04 AS base

# 1. 安装 Python 和必要工具
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 2. 建立 python 软链接（解决 "python: not found" 报错）
RUN ln -s /usr/bin/python3 /usr/bin/python

# 3. 接下来再执行你的原逻辑
RUN python -m ensurepip --upgrade
RUN pip install --no-cache-dir uv

RUN uv pip install --system --no-cache torch torchvision torchaudio

CMD ["/bin/bash"]

# ... 后续 build 阶段保持不变
