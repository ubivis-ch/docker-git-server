#!/bin/sh

mkdir -p /home/git/.ssh
chown git:git /home/git/.ssh
chmod 700 /home/git/.ssh

touch /home/git/.ssh/authorized_keys
chown git:git /home/git/.ssh/authorized_keys
chmod 600 /home/git/.ssh/authorized_keys

echo "${GIT_AUTHORIZED_KEYS:-}" > /home/git/.ssh/authorized_keys

if [ ! -z "${GIT_USER_PASSWORD}" ]; then
    echo "git:${GIT_USER_PASSWORD}" | chpasswd
fi

echo "export GIT_HOST_HINT=\"${GIT_HOST_HINT:-<host>[:<port>]}\"" >> /env.sh

if [ "$#" -gt 0 ]; then
    exec "$@"
else
    dropbear -R -g -F -E -j -k -m -c /git-shell-rel-path
fi

