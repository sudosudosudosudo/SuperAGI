# Stage 1: Compile image
FROM python:3.10-slim-bullseye AS compile-image
FROM python:3.10-slim-bullseye

# Install git
RUN apt-get update && \
    apt-get install -y git

WORKDIR /app

# Use RUN to execute git commands
RUN git add package-lock.json && \
    git commit -m "Add package manager lockfile" && \
    apt-get update && \
    apt-get install -y git wget libpq-dev gcc g++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    apt-get install --no-install-recommends -y wget libpq-dev gcc g++ && \

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

RUN python3.10 -c "import nltk; nltk.download('punkt')" && \
  python3.10 -c "import nltk; nltk.download('averaged_perceptron_tagger')"

COPY . .

RUN chmod +x ./entrypoint.sh ./wait-for-it.sh ./install_tool_dependencies.sh ./entrypoint_celery.sh

# Stage 2: Build image
FROM python:3.10-slim-bullseye AS build-image
WORKDIR /app

RUN apt-get update && \
    apt-get install --no-install-recommends -y libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=compile-image /opt/venv /opt/venv
COPY --from=compile-image /app /app
COPY --from=compile-image /root/nltk_data /root/nltk_data

ENV PATH="/opt/venv/bin:$PATH"

EXPOSE 8001
