# Dockerfile

FROM python:3.12-alpine

RUN pip install --no-cache-dir pipx \
    && pipx ensurepath \
    && pipx install git-secret-protector

COPY main.sh /main.sh
COPY post.sh /post.sh

ENTRYPOINT ["sh", "-c", "/main.sh"]
