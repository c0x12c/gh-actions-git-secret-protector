# Dockerfile

FROM python:3.12-alpine

RUN apk add --no-cache bash \
    && pip install --no-cache-dir pipx \
    && pipx ensurepath \
    && pipx install git-secret-protector

COPY main.sh /main.sh
COPY post.sh /post.sh

ENTRYPOINT ["/main.sh"]
