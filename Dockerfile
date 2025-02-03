FROM python:3.9-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libportaudio2 libportaudiocpp0 portaudio19-dev \
    libasound-dev libsndfile1-dev ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /code

# Copy pyproject.toml and poetry.lock (if exists)
COPY ./pyproject.toml /code/pyproject.toml
COPY ./poetry.lock /code/poetry.lock 

# Install Poetry
RUN pip install --no-cache-dir "poetry==1.5.1"

# Configure poetry to not create virtual environments
RUN poetry config virtualenvs.create false

# Generate the lock file (if needed)
RUN poetry lock

# Install dependencies using poetry
RUN poetry install --no-interaction --no-ansi -vvv

# Copy application files
COPY main.py /code/main.py
COPY speller_agent.py /code/speller_agent.py
COPY memory_config.py /code/memory_config.py
COPY events_manager.py /code/events_manager.py
COPY config.py /code/config.py
COPY instructions.txt /code/instructions.txt
COPY ./utils /code/utils

# Create necessary directories
RUN mkdir -p /code/call_transcripts /code/db

# Run the application using Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]
