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

# FIX: Setuptools ko <70.0.0 pe pin karo taaki pkg_resources break na ho
RUN pip install --no-cache-dir "setuptools<70.0.0" wheel cython

# FIX: --no-build-isolation pass karo taaki pinned setuptools hi use ho
RUN pip install --no-cache-dir --no-build-isolation -r requirements.txt
RUN pip install --no-cache-dir runpod

# Environment path clean set karo
ENV PYTHONPATH="/workspace/CosyVoice:/workspace/CosyVoice/third_party/Matcha-TTS"

# Model weights pre-download karo (Cold-start speed boost)
RUN python3 -c "from cosyvoice.cli.cosyvoice import CosyVoice; CosyVoice('iic/CosyVoice-300M')"

WORKDIR /workspace
COPY handler.py /workspace/handler.py

CMD ["python", "-u", "/workspace/handler.py"]