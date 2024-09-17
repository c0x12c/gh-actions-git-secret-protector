FROM python:3.12-alpine as build

RUN apk --no-cache add \
        curl \
        bash \
        ca-certificates \
        libc6-compat \
        gnupg \
    && curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli.tar.gz \
    && tar -xf google-cloud-cli.tar.gz -C /usr/local \
    && /usr/local/google-cloud-sdk/install.sh --quiet \
    && pip install --no-cache-dir pipx \
    && pipx install git-secret-protector \
    && apk del gnupg curl \
    && rm -rf google-cloud-cli.tar.gz

FROM python:3.12-alpine

COPY --from=build /usr/local/google-cloud-sdk /usr/local/google-cloud-sdk
COPY --from=build /root/.local /root/.local

ENV PATH="/usr/local/google-cloud-sdk/bin:/root/.local/bin:$PATH"

COPY main.sh /main.sh
COPY post.sh /post.sh

ENTRYPOINT ["/main.sh"]
