# Dockerfile

FROM python:3.12-alpine

RUN pip install --no-cache-dir pipx \
    && pipx install git-secret-protector

COPY main.sh /main.sh
COPY post.sh /post.sh

ENTRYPOINT ["/main.sh"]
