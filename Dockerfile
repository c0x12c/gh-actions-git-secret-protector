FROM python:3.12-alpine as build

RUN apk add --update \
    curl \
    which \
    bash

RUN curl -sSL https://sdk.cloud.google.com | bash

COPY --from=ghcr.io/astral-sh/uv:0.12.23@sha256:61d393e44e249f2e4b526b6c7ddcecce245946826e608e11c93ad4f5bba55b21 /uv /uvx /bin/

# Pin to the base image's own interpreter instead of letting uv download a managed one:
# avoids an extra musl-targeted interpreter fetch/build and keeps the installed tool bound
# to the exact python3.12-alpine already present in this layer.
ENV UV_PYTHON_PREFERENCE=only-system

RUN uv tool install 'git-secret-protector==1.13.0'

FROM python:3.12-alpine

COPY --from=build /root/google-cloud-sdk /root/google-cloud-sdk
COPY --from=build /root/.local /root/.local

ENV PATH="/root/google-cloud-sdk/bin:/root/.local/bin:$PATH"

COPY main.sh /main.sh
COPY post.sh /post.sh

ENTRYPOINT ["/main.sh"]
