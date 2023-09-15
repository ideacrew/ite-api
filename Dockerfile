############################################
### Base image ###
############################################

FROM ruby:3.1.3-slim-buster as base
LABEL author="IdeaCrew"

RUN apt-get update \
    && apt-get -yq dist-upgrade \
    && apt-get install -y \
      libcurl4-openssl-dev \
      libffi6 \
      libxext6 \
      libxrender1 \
      openssl \
      sshpass \
      unzip \
      zip \
      zlibc \ 
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && truncate -s 0 /var/log/*log


ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_PATH=$GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH
ENV BUNDLE_BIN=/usr/local/bin
ENV BUNDLE_JOBS=4
ENV BUNDLE_RETRY=3
ENV LANG=C.UTF-8

ENV HOME=/dbh
ENV PATH=$HOME/bin:$BUNDLE_BIN:$GEM_HOME/gems/bin:$PATH

RUN gem update --system
RUN gem install bundler -v 2.2.14

RUN groupadd --gid 1001 nonroot \
  && useradd --uid 1001 --gid nonroot --shell /bin/bash --create-home nonroot


RUN mkdir $HOME \
  && chown -R nonroot:nonroot $HOME

ENV SECRET_KEY_BASE=c8d2b9b204fbac78081a88a2c29b28cfeb82e6ccd3664b3948b813463b5917b315dbbd3040e8dffcb5b68df427099db0ce03e59e2432dfe5d272923b00755b82

WORKDIR $HOME
ENV RAILS_ENV=production

################################################################################
### Builder. Adds node and Yarn. Not necessary in production. ###
###############################################################################
FROM base as builder

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq \
  && apt-get install -yq --no-install-recommends \
    build-essential \
    libpq-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

### Install dependencies

FROM builder as prod_gems_and_assets

COPY --chown=nonroot:nonroot ./Gemfile $HOME/Gemfile
COPY --chown=nonroot:nonroot ./Gemfile.lock $HOME/Gemfile.lock

RUN bundle config set --local without 'development test' \
  && bundle install

################################################################
# Deployable image
################################################################

FROM base as deploy

COPY --chown=nonroot:nonroot --from=prod_gems_and_assets $BUNDLE_PATH $BUNDLE_PATH
COPY --chown=nonroot:nonroot . $HOME

USER nonroot

ENV PORT=${PORT:-3000}
EXPOSE 3000

CMD env && echo "10.57.76.134 dbh-prod.privatelink.database.windows.net" >> /etc/hosts && bin/rails db:prepare && bundle exec rails s -b 0.0.0.0 -p $PORT
