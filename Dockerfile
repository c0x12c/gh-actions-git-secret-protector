# Dockerfile

FROM python:3.12-alpine

RUN pip install --no-cache-dir pipx \
    && pipx ensurepath \
    && pipx install git-secret-protector

# Ensure the installed binaries are in the system's PATH
ENV PATH="/root/.local/bin:${PATH}"

COPY main.sh /main.sh
COPY post.sh /post.sh

ENTRYPOINT ["/main.sh"]
