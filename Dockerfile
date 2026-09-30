FROM runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04

# System tools install karo
RUN apt-get update && apt-get install -y \
    sox libsox-dev ffmpeg git git-lfs wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# CosyVoice repository clone karo
RUN git clone --recursive https://github.com/FunAudioLLM/CosyVoice.git /workspace/CosyVoice

# Python libraries install karo
WORKDIR /workspace/CosyVoice
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir runpod

# Environment path set karo
ENV PYTHONPATH="/workspace/CosyVoice:/workspace/CosyVoice/third_party/Matcha-TTS:${PYTHONPATH}"

# HACK FOR COST CUTTING: Image build karte waqt hi Model download kar lo
RUN python3 -c "from cosyvoice.cli.cosyvoice import CosyVoice; CosyVoice('iic/CosyVoice-300M')"

WORKDIR /workspace
COPY handler.py /workspace/handler.py

CMD ["python", "-u", "/workspace/handler.py"]