## Deploying AI4Bharat Indic Conformer S2T Models on RunPod

### Model Information

The models used in this project come from AI4Bharat's [Indic Conformer](https://github.com/AI4Bharat/IndicConformerASR) project.

### Building the Docker Image

Before running the project, you need to build a Docker image that includes the necessary dependencies and the pre-downloaded model.

1. Ensure you have Docker installed on your system.

2. Build the Docker image:
```bash
docker image build -f Dockerfile -t adimyth/serverless-s2t-indic-conformer:v1.0.0 .
```
This command builds the Docker image with the tag `adimyth/serverless-s2t-indic-conformer:v1.0.0`
  

### Running the project locally

1. Clone the repository
2. Install the requirements
```bash
python3 -m venv .venv
source .venv/bin/activate

pip install -r builder/requirements.txt
```
3. Install nemo
```bash
git clone https://github.com/AI4Bharat/NeMo.git -b nemo-v2
pip install packaging huggingface_hub==0.23.2
cd NeMo && bash reinstall.sh
cd ..
```
4. Make directory for storing the model
```bash
sudo mkdir -p /temp/models/asr

sudo chmod -R 777 /temp/models/asr

wget https://objectstore.e2enetworks.net/indic-asr-public/indicConformer/ai4b_indicConformer_hi.nemo -O /temp/models/asr/hi.nemo
```
> Modify the `src/handler.py` file to remove the other languages from the list & update the model prefix path to `/temp/models/asr/` instead
5. Run the project. This will start the FastAPI server on the specified host at port 8000.
```bash
python3 src/handler.py --rp_serve_api --rp_api_host 0.0.0.0 --rp_log_level DEBUG
```
6. Test the project
```bash
curl --location 'http://0.0.0.0:8000/runsync' \
--header 'accept: application/json' \
--header 'Content-Type: application/json' \
--data '{"audioURL": "https://www.tuttlepublishing.com/content/docs/9780804844383/06-18%20Part2%20Car%20Trouble.mp3", "language": "hi"}'
```

### Running with Docker
After building the image, you can run the container:
```bash
docker container run -e RUNPOD_SECRET_HF_API_KEY="YOUR_HF_API_KEY" -p 8000:8000 adimyth/serverless-stt-deployment:v1.1.0
```
This command runs the container and maps port 8000 from the container to port 8000 on your host machine.

