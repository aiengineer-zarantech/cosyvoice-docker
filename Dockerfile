WORKDIR /app

# Step 1: Pehle SIRF requirements.txt copy karein
COPY requirements.txt /app/requirements.txt

# Step 2: Dependencies install karein (Yeh heavy 50-minute wali layer ab hamesha CACHED rahegi)
RUN pip install --no-cache-dir -r requirements.txt

# Step 3: Bilkul LAST me apna code (handler.py) copy karein
COPY handler.py /app/handler.py
COPY . /app