# Dockerfile

FROM python:3.12-alpine

RUN pip install --no-cache-dir pipx \
    && pipx install git-secret-protector

# Manually set the PATH in the Dockerfile
ENV PATH="/root/.local/bin:$PATH"

COPY main.sh /main.sh
COPY post.sh /post.sh

ENTRYPOINT ["/main.sh"]
