git-server
==========

Relatively simple Git server (Git over SSH) based on Alpine Linux and with some administration capabilities to create,
delete and list repositories.

It can be accessed using either a password or SSH keys.

Run
---

Simplest example:

    $ docker run -d -p 22:22 -e GIT_USER_PASSWORD="[secret]" ubivisgmbh/git-server

Typical example:

    $ docker run -d -p 2222:22 -v git-config:/etc/git -w git-data:/srv/git -e GIT_AUTHORIZED_KEYS="[secret]" -e GIT_HOST_HINT="example.org:2222" ubivisgmbh/git-server

Or using Docker Compose (`compose.yaml`):

```
services:

  git-server:
    image: ubivisgmbh/git-server:latest
    restart: always
    ports:
      - 2222:22
    environment:
      - GIT_USER_PASSWORD=[secret]
      - "GIT_AUTHORIZED_KEYS=[ssh-rsa xxxxx xxx@xxx]\n[ssh-rsa xxxxx xxx@xxx]"
      - GIT_HOST_HINT=example.org:2222
    volumes:
      - config:/etc/git
      - data:/srv/git

volumes:
  config:
  data:
```
    
Configuration (environment variables)
-------------------------------------

At least one of the two environment variables below need to be set in order for it to work:

* `GIT_USER_PASSWORD` - Sets a password for the `git` user.
* `GIT_AUTHORIZED_KEYS` - Sets a number of SSH public keys (separated by the newline character `\n`).

Optionally one can set the following environment variable (useful espcially if the server runs behind a reverse proxy.

* `GIT_HOST_HINT` - Sets the host that shows how to access the repositories in the adminstration interface.

Data persistence
----------------

Two volumes can (and should) be used to persist the data:

### `/etc/git`

The SSH server keys are generated on each start of the server if the don't already exist. Therefore it is good practice
to save them between restarts, otherwise one would always get a warning of a conflicting known host key.

### `/srv/git`

This is where the repositories are stored. It wouldn't really make sense not to persist them.

Usage
-----

Git repositories can be accessed using Git over SSH like so (e.g. cloning):

    $ git clone ssh://git@example.org:2222/<namespace>/<repository>.git

There is also a administration interface that can be accessed over SSH (as a restricted shell):

    $ ssh -p 2222 git@example.org
    Available commands:
      create <repo path>  - Create a new repository
      delete <repo path>  - Delete a repository
      exit                - Exit
      help                - Show available commands
      list                - List all repostories
    git> 

Notes
-----

There are a few design decisions that are discussed now:

### No data besides the repositories

I didn't want to add features to this server that require additional (meta)data like the bigger Git servers tend to 
have. This means that there are a lot of features missing compared to Github, GitLab, Bitbucket, Gitea, Gogs, etc. Be 
aware of that.

I tried to make everything as simple as possible for both movability and backup/restore of repositories.

### Access defined on a per-start basis

Access types (password or SSH keys) are reset on every start of the container. This means if you forget a password or
lose an SSH private key, it is only a matter of restarting the Docker container and setting the authentication
methods as environment variables.

### Abstracting away the base path to the repositories

Usually when accessing Git over SSH, one has to set the absolute filesystem path to the repository. This is abstracted
away in this Docker Image, so one can leave out the base portion of the path. So with this Container one can write

    $ git clone ssh://git@example.org:2222/<namespace>/<repository>.git

instead of

    $ git clone ssh://git@example.org:2222/srv/git/<namespace>/<repository>.git

which from an aesthetical point of view was important to me :-).

Development / Bugs
------------------

Development takes place on Github:

https://github.com/ubivis-ch/docker-git-server

Please report any issues to:

https://github.com/ubivis-ch/docker-git-server/issues

Future
------

* It might be nice to have different users that can have private, shared or public repositories. I currently do not need
  this for my purposes, but if great interest for such a feature is seen, I will consider adding this.
  
* As a second step, different authentication mechanisms might be looked at. Connecting with an LDAP/AD server would
  definitely be helpful with administering larger user bases in SME settings.
