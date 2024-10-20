FROM python:3.12-alpine as build

RUN apk add --update \
    curl \
    which \
    bash

RUN curl -sSL https://sdk.cloud.google.com | bash

RUN pip install --no-cache-dir pipx \
    && pipx install git-secret-protector==0.8.0

FROM python:3.12-alpine

COPY --from=build /root/google-cloud-sdk /root/google-cloud-sdk
COPY --from=build /root/.local /root/.local

ENV PATH="/root/google-cloud-sdk/bin:/root/.local/bin:$PATH"

COPY main.sh /main.sh
COPY post.sh /post.sh

ENTRYPOINT ["/main.sh"]
