FROM python:latest

ARG DIRNAME
ARG PYVENV_LOCATION

WORKDIR "${DIRNAME}"
EXPOSE 443
EXPOSE 80

# Copy requirements first for better layer caching
COPY requirements.txt .
RUN /usr/bin/env python3 -m venv "${PYVENV_LOCATION}"
RUN "${PYVENV_LOCATION}/bin/python" -m pip install -r requirements.txt

# Copy remaining files (invalidates less frequently cached layers)
COPY . .
RUN chmod +x shell/run.sh

ENTRYPOINT ["./shell/run.sh"]
