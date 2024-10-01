import uuid

import aiohttp
import nemo.collections.asr as nemo_asr
import numpy as np
import runpod
from dotenv import load_dotenv
from fastapi import HTTPException
from loguru import logger

load_dotenv()


# Given a language, the function returns the corresponding model
def get_model(language):
    device = "cuda"
    model = nemo_asr.models.EncDecCTCModel.restore_from(
        restore_path=f"/usr/models/asr/{language}.nemo"
    )
    model.freeze()
    model = model.to(device)
    model.cur_decoder = "ctc"
    return model


# Load model outside the handler to avoid loading it every time
models = {}
for lang in ["hi", "kn", "ta", "te", "mr", "ml", "bn", "gu"]:
    models[lang] = get_model(lang)
    logger.info(f"Model for {lang} loaded successfully")
logger.info("Speech to Text models loaded successfully")


async def download_audio(url: str):
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            if response.status != 200:
                raise HTTPException(
                    status_code=response.status, detail="Error downloading audio file"
                )
            # Create a temp file
            audio_file_path = f"/tmp/{uuid.uuid4()}.wav"
            # Write to a file
            with open(audio_file_path, "wb") as f:
                f.write(await response.read())
            return audio_file_path


async def handler(event):
    input_data = event.get("input", {})

    # Extract sentence and language
    audioURL = input_data.get("audioURL", "")
    language = input_data.get("language", "")

    # Error handling in case of invalid input
    if not audioURL:
        return {"error": "audioURL is required"}
    if not language:
        return {"error": "language is required"}
    if language not in ["hi", "kn", "ta", "te", "mr", "ml", "bn", "gu"]:
        return {"error": "language not supported"}

    # Download the audio file & get the sample rate
    audio_file_path = await download_audio(audioURL)

    # Inference
    transcription = models[language].transcribe(
        [audio_file_path], batch_size=1, logprobs=False, language_id=language
    )[0][0]

    return {"text": transcription}


runpod.serverless.start({"handler": handler})
