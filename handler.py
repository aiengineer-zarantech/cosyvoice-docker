import sys
import os

# Set paths for CosyVoice
sys.path.append('/workspace/CosyVoice')
sys.path.append('/workspace/CosyVoice/third_party/Matcha-TTS')

import runpod
import torch
import soundfile as sf
import numpy as np
import base64
import requests
import tempfile
from cosyvoice.cli.cosyvoice import CosyVoice

print("🧠 Loading pre-cached CosyVoice model...")
cosyvoice = CosyVoice('iic/CosyVoice-300M')
print("✅ Model loaded successfully!")

def handler(event):
    try:
        input_data = event.get('input', {})
        ref_audio_url = input_data.get('reference_audio_url')
        text = input_data.get('text', 'Hello, this is a test.')
        prompt_text = input_data.get('prompt_text', 'Reference audio')

        if not ref_audio_url:
            return {"status": "error", "message": "reference_audio_url is required"}

        response = requests.get(ref_audio_url)
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
            tmp.write(response.content)
            ref_path = tmp.name

        output = cosyvoice.inference_zero_shot(
            tts_text=text,
            prompt_text=prompt_text,
            prompt_speech_16k=ref_path,
            stream=False
        )

        audio_chunks = [chunk['tts_speech'].numpy() for chunk in output]
        final_audio = np.concatenate(audio_chunks, axis=1)

        out_path = "/tmp/output.wav"
        sf.write(out_path, final_audio[0], 22050)

        with open(out_path, "rb") as f:
            audio_b64 = base64.b64encode(f.read()).decode('utf-8')

        os.remove(ref_path)
        os.remove(out_path)

        return {
            "status": "success",
            "audio_base64": audio_b64
        }

    except Exception as e:
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    runpod.serverless.start({"handler": handler})