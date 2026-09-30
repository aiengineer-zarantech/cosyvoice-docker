# 1. Sabse pehle Base Image honi zaroori hai (Aapki original FROM line)
FROM pytorch/pytorch:2.1.2-cuda12.1-cudnn8-runtime

WORKDIR /app

# 2. Pehle SIRF requirements.txt copy karein (Heavy Cache Layer)
COPY requirements.txt /app/requirements.txt

# 3. Dependencies install karein (Yeh layer hamesha CACHED rahegi)
RUN pip install --no-cache-dir -r requirements.txt

# 4. Last me apna code copy karein (Badalne par bhi pip install dubara nahi chalega)
COPY . /app