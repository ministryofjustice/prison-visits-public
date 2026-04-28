FROM ruby:3.4.8-alpine3.23

ARG BUILD_NUMBER
ARG GIT_BRANCH
ARG GIT_REF

RUN \
  set -ex \
  && apk add --no-cache \
    musl-locales \
    musl-locales-lang \
    tzdata \
  && cp /usr/share/zoneinfo/Europe/London /etc/localtime \
  && echo "Europe/London" > /etc/timezone

ENV \
  LANG=en_GB.UTF-8 \
  LANGUAGE=en_GB.UTF-8 \
  LC_ALL=en_GB.UTF-8 \
  MUSL_LOCPATH=/usr/share/i18n/locales/musl

ARG VERSION_NUMBER
ARG COMMIT_ID
ARG BUILD_DATE
ARG BUILD_TAG

ENV APPVERSION=${VERSION_NUMBER}
ENV APP_GIT_COMMIT=${COMMIT_ID}
ENV APP_BUILD_DATE=${BUILD_DATE}
ENV APP_BUILD_TAG=${BUILD_TAG}

WORKDIR /app

RUN \
  set -ex \
  && apk add --no-cache \
    build-base \
    git \
    postgresql-dev \
    netcat-openbsd \
    nodejs \
    npm \
    iputils \
  && gem update bundler --no-document \
  && npm install -g yarn@1.22.0 \
  && yarn add govuk-frontend

COPY Gemfile Gemfile.lock ./

RUN bundle update --bundler
RUN bundle config set without 'development test'
RUN bundle install --jobs 2 --retry 3
COPY . /app

ENV BUILD_NUMBER=${BUILD_NUMBER}
ENV GIT_BRANCH=${GIT_BRANCH}
ENV GIT_REF=${GIT_REF}

RUN mkdir -p /home/appuser && \
  addgroup -S -g 1001 appuser && \
  adduser -S -D -u 1001 -G appuser -h /home/appuser appuser && \
  chown -R appuser:appuser /app && \
  chown -R appuser:appuser /home/appuser

USER 1001

RUN bundle update --bundler
RUN SECRET_KEY_BASE=`rails secret` PUBLIC_SERVICE_URL=http://example.com RAILS_ENV=production STAFF_SERVICE_URL=http://example.com SERVICE_URL=http://example.com rails assets:precompile --trace
EXPOSE 3000
