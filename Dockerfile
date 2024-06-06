FROM alpine:3.20

ARG GIT_VERSION=2.45.2-r0

ARG GIT_REPO_ROOT=/srv/git

RUN apk add --no-cache \
      coreutils \
      dropbear \
      git=$GIT_VERSION

RUN adduser git -g git -D && \
    mkdir -p $GIT_REPO_ROOT && \
    chown git:git $GIT_REPO_ROOT && \
    ln -s /etc/dropbear /etc/git && \
    echo "export GIT_REPO_ROOT=$GIT_REPO_ROOT" > /env.sh

COPY --chown=git:git .gitconfig /home/git/

COPY --chown=git:git git-shell-commands/ /home/git/git-shell-commands/

COPY docker-entrypoint.sh /

COPY git-shell-rel-path /

EXPOSE 22

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "/usr/sbin/dropbear", "-R", "-g", "-F", "-E", "-j", "-k", "-m", "-c /git-shell-rel-path" ]
