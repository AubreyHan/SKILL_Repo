---
name: get-movie-subtitles
description: |
  Use this skill to extract the entire audio from a movie file and transcribe/translate it into an accurate SRT subtitle file using the Gemini API, preserving native timestamps without chunking.
license: Apache-2.0
metadata:
  version: v1
  publisher: google
---

# Movie Subtitles Extraction Skill

You have been tasked with generating accurate subtitles for a video/movie file. This skill outlines the standard operating procedure (SOP) to extract audio, process it with the Gemini AI model, and generate an aligned, translated SRT file.

## Prerequisites

- **FFmpeg & FFprobe**: Must be installed and accessible (e.g., via `/opt/homebrew/bin/ffmpeg`).
- **Python Packages**: The `google-genai` package must be installed.
- **Environment Variable**: `GEMINI_API_KEY` must be configured.

## Skill Procedure

When asked to generate subtitles for a movie, follow these steps:

1. **Extract Full Audio**
   - Use `ffmpeg` to extract the complete audio track from the video file into a single file. Do NOT chunk or split the audio, to preserve Gemini's native timestamp synchronization and avoid manual offset errors.
   - Example: `ffmpeg -y -i /path/to/movie.mkv -vn -acodec libmp3lame -q:a 5 /path/to/full_audio.mp3`

2. **Transcribe and Translate via Gemini**
   - Write a Python script using the `google.genai` SDK.
   - Upload the single full audio file using `client.files.upload()`.
   - Call `models/gemini-3.5-flash` with a strict prompt:
     - Instruct the model to transcribe dialogue to English and translate to Chinese (or the target language).
     - Provide a list of specific character names to keep in English, if the user requested any.
     - Enforce the output format strictly as **SRT**.
     - Specifically prompt the model to process the entire audio duration and output native timestamps accurately from start to finish.

3. **Save Subtitles**
   - Receive the SRT output from the model.
   - Clean up any hallucinated markdown blocks (like ```srt) from the response.
   - Save directly to the final `.srt` file.

4. **Cleanup**
   - Delete the temporary audio file from the local disk.
   - Delete the uploaded file from the Gemini API using `client.files.delete()`.
