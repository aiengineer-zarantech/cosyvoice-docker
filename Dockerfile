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

# Build tools install karo
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir "setuptools<70.0.0" wheel cython flit_core hatchling poetry-core

# STEP 1: openai-whisper ko pehle hi without build isolation install kar lo
RUN pip install --no-cache-dir --no-build-isolation openai-whisper==20231117

# STEP 2: requirements.txt me se openai-whisper line hata do taaki pip use dubara build na kare
RUN sed -i '/openai-whisper/d' requirements.txt

# STEP 3: Ab baaki requirements clean install ho jayenge
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir runpod

# Environment path clean set karo
ENV PYTHONPATH="/workspace/CosyVoice:/workspace/CosyVoice/third_party/Matcha-TTS"

# Model weights pre-download karo (Cold-start speed boost)
RUN python3 -c "from cosyvoice.cli.cosyvoice import CosyVoice; CosyVoice('iic/CosyVoice-300M')"

WORKDIR /workspace
COPY handler.py /workspace/handler.py

CMD ["python", "-u", "/workspace/handler.py"]