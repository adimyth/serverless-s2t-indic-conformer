# Base Image
FROM runpod/base:0.6.2-cuda12.1.0

# Download ASR Models
RUN mkdir -p /usr/models/asr
# Hindi
RUN wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_hi.nemo -O /usr/models/asr/hi.nemo
# Kannada
RUN wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_kn.nemo -O /usr/models/asr/kn.nemo
# Tamil
RUN wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_ta.nemo -O /usr/models/asr/ta.nemo
# Telugu
RUN wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_te.nemo -O /usr/models/asr/te.nemo
# Marathi
RUN wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_mr.nemo -O /usr/models/asr/mr.nemo
# Malayalam
RUN wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_ml.nemo -O /usr/models/asr/ml.nemo
# Bengali
RUN wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_bn.nemo -O /usr/models/asr/bn.nemo
# Gujarati
RUN wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_gu.nemo -O /usr/models/asr/gu.nemo
# Punjabi
RUN wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_pa.nemo -O /usr/models/asr/pa.nemo

# Install ASR dependencies
RUN git clone https://github.com/AI4Bharat/NeMo.git -b nemo-v2
RUN pip install packaging huggingface_hub==0.23.2
RUN cd NeMo && bash reinstall.sh

# Install necessary packages
COPY builder/requirements.txt /requirements.txt
RUN python3.10 -m pip install --upgrade pip && \
    python3.10 -m pip install --upgrade -r /requirements.txt --no-cache-dir && \
    rm /requirements.txt

# Add src files
ADD src .

CMD python3.10 -u /handler.py