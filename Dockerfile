FROM alpine

LABEL "repository"="http://github.com/wei/git-sync"
LABEL "homepage"="http://github.com/wei/git-sync"
LABEL "maintainer"="Wei He <github@weispot.com>"

RUN apk add --no-cache git openssh-client && \
  echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

ADD *.sh /

ENTRYPOINT ["/entrypoint.sh"]
