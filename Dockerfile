FROM python:latest

ARG DIRNAME
ARG PYENV_LOCATION

COPY . "${DIRNAME}"
WORKDIR "${DIRNAME}"
EXPOSE 443
EXPOSE 80


RUN /usr/bin/env python3 -m venv "${PYENV_LOCATION}"
RUN "${PYENV_LOCATION}/bin/python" -m pip install -r requirements.txt
RUN chmod +x shell/main.sh