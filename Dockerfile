FROM runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04

# System tools & C++ compilation packages install karo
RUN apt-get update && apt-get install -y \
    sox libsox-dev ffmpeg git git-lfs wget \
    build-essential cmake swig g++ python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# CosyVoice repository clone karo
RUN git clone --recursive https://github.com/FunAudioLLM/CosyVoice.git /workspace/CosyVoice

WORKDIR /workspace/CosyVoice

# Pip update karo aur saare build tools & backends system me install karo
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir "setuptools<70.0.0" wheel cython flit_core hatchling poetry-core

# FIX 1: Problematic openai-whisper ko pehle hi separately install kar lo
RUN pip install --no-cache-dir --no-build-isolation openai-whisper

# FIX 2: Ab baaki requirements.txt ko normal mode me install karo (TensorRT aur PyTorch backend solve ho jayega)
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir runpod

# Environment path clean set karo
ENV PYTHONPATH="/workspace/CosyVoice:/workspace/CosyVoice/third_party/Matcha-TTS"

# Model weights pre-download karo (Cold-start speed boost)
RUN python3 -c "from cosyvoice.cli.cosyvoice import CosyVoice; CosyVoice('iic/CosyVoice-300M')"

WORKDIR /workspace
COPY handler.py /workspace/handler.py

CMD ["python", "-u", "/workspace/handler.py"]