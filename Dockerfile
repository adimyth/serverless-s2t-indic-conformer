# Base Image
FROM nvcr.io/nvidia/pytorch:24.01-py3

# Set working directory
RUN mkdir -p /usr/ai-inference/
WORKDIR /usr/ai-inference/

# Set timezone and disable interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV LOG_LEVEL INFO

# Install system dependencies
RUN apt-get update \
    && apt-get -y install git g++ gcc postgresql libpq-dev python3-dev wget unzip vim curl \
    && apt-get -y install poppler-utils ffmpeg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download ASR Models
RUN mkdir -p /usr/ai-inference/models/asr
# Hindi
RUN wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_hi.nemo -O /usr/ai-inference/models/asr/hi.nemo
# Kannada
RUN wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_kn.nemo -O /usr/ai-inference/models/asr/kn.nemo
# Tamil
RUN wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_ta.nemo -O /usr/ai-inference/models/asr/ta.nemo
# Telugu
RUN wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_te.nemo -O /usr/ai-inference/models/asr/te.nemo
# Marathi
RUN wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_mr.nemo -O /usr/ai-inference/models/asr/mr.nemo
# Malayalam
RUN wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_ml.nemo -O /usr/ai-inference/models/asr/ml.nemo
# Bengali
RUN wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_bn.nemo -O /usr/ai-inference/models/asr/bn.nemo
# Gujarati
RUN wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_gu.nemo -O /usr/ai-inference/models/asr/gu.nemo
# Punjabi
RUN wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_pa.nemo -O /usr/ai-inference/models/asr/pa.nemo

# Install ASR dependencies
RUN git clone https://github.com/AI4Bharat/NeMo.git -b nemo-v2
RUN pip install packaging huggingface_hub==0.23.2
RUN cd NeMo && bash reinstall.sh

# Install ai-inference server dependencies
RUN pip install --upgrade pip
COPY builder/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Add src files
COPY src /usr/ai-inference/src

CMD python3.10 -u src/handler.py