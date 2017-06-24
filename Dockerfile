FROM python:3.6.1-alpine

ENV HOME /root
ENV TERM xterm
ENV LANG en_US.UTF-8
ENV BASE_IMAGE_BUILD_DEPS \
# lets be honest and assume that many people use bashisms without
# even knowing
  bash \
# we need git to fetch gems
  git \
# we want a pager for pry that is able to spit ANSI so that we don't
# lose syntax highlighting
  less \
# we need openssh to fetch gems from git+ssh repositories
  openssh \
# busybox's wget needs openssl to fetch from HTTPS sources
  openssl \
# use tini as PID 1 so that zombie processes are reaped
  tini

RUN set -ex \
  \
  && apk add --no-cache --virtual .python_image-rundeps $BASE_IMAGE_BUILD_DEPS

ENTRYPOINT ["/sbin/tini", "--"]

##############################################################################
# All environment variables below must be set.
#

ENV APP_ROOT /var/code/
ENV APP_NAME news_extractor
ENV APP_HOME $APP_ROOT/$APP_NAME
ENV PORT 3000

ENV APP_BUILD_DEPS \
  build-base

ENV APP_RUN_DEPS \
  libstdc++ \
  tzdata \
  zlib-dev \
  libxml2-dev \
  libxslt-dev \
  jpeg-dev \
  libpng-dev

##############################################################################
# STAY AWAY ZONE BELOW!
# (well, be really sure of what you're doing...)
#

COPY requirements.txt $APP_HOME/

WORKDIR $APP_HOME

RUN set -ex \
  \
  && apk add --no-cache --virtual .python_app-rundeps $APP_RUN_DEPS \
  && apk add --no-cache --virtual .python_app-builddeps $APP_BUILD_DEPS \
  \
  && pip install -r requirements.txt \
  \
  && apk del .python_app-builddeps

COPY . $APP_HOME

EXPOSE $PORT

##############################################################################
# Here, be dragons!
#

CMD ["/bin/bash"]

