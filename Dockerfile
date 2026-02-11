FROM python:latest

ARG DIRNAME
ARG PYVENV_LOCATION

# Install uv (pinned version — update periodically)
COPY --from=ghcr.io/astral-sh/uv:0.6.2 /uv /usr/local/bin/uv

WORKDIR "${DIRNAME}"
EXPOSE 443
EXPOSE 80

# Copy requirements first for better layer caching
COPY requirements.txt .
RUN uv venv "${PYVENV_LOCATION}"
RUN uv pip install --python "${PYVENV_LOCATION}/bin/python" -r requirements.txt

# Copy remaining files (invalidates less frequently cached layers)
COPY . .
RUN chmod +x shell/run.sh

ENTRYPOINT ["./shell/run.sh"]
