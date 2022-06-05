FROM alpine

LABEL "maintainer"="leandro-mana"
LABEL "repository"="https://github.com/leandro-mana/jakr"
LABEL "com.github.actions.name"="jakr"
LABEL "com.github.actions.description"="Create a Release based on commit message keyword"
LABEL "com.github.actions.icon"="gift"
LABEL "com.github.actions.color"="green"

ARG KEYWORD_ARG
ENV KEYWORD=${KEYWORD_ARG}
RUN apk add --no-cache \
        bash \
        curl \
        git \
        jq && \
        which bash && \
        which curl && \
        which jq && \
        which git

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY sample_push_event.json /sample_push_event.json

ENTRYPOINT ["entrypoint.sh"]
