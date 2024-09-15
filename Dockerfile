# Dockerfile

FROM python:3.12-alpine

RUN apk add --no-cache bash \
    && pip install --no-cache-dir pipx \
    && pipx ensurepath \
    && pipx install git-secret-protector

# Ensure the installed binaries are in the system's PATH
ENV PATH="$PATH:/root/.local/bin"

COPY main.sh /main.sh
COPY post.sh /post.sh

ENTRYPOINT ["bash", "-c", "/main.sh"]
