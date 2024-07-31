FROM alpine:latest

ARG GIT_REPO_ROOT=/srv/git

RUN apk add --no-cache \
      coreutils \
      dropbear \
      git

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
