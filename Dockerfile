FROM python:3.12-alpine AS build

RUN apk add --update \
    curl \
    which \
    bash

RUN curl -sSL https://sdk.cloud.google.com | bash

# Pinned exactly: a floating lower bound (`>=1.0`) froze this image on 1.2.4 for a
# year without anyone noticing. Bump this line deliberately when upgrading.
RUN pip install --no-cache-dir pipx \
    && pipx install 'git-secret-protector==1.5.1'

FROM python:3.12-alpine

COPY --from=build /root/google-cloud-sdk /root/google-cloud-sdk
COPY --from=build /root/.local /root/.local

ENV PATH="/root/google-cloud-sdk/bin:/root/.local/bin:$PATH"

COPY main.sh /main.sh
COPY post.sh /post.sh

ENTRYPOINT ["/main.sh"]
