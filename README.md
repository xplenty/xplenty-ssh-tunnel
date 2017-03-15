# Xplenty SSH Tunnel
A tiny application to initiate a SSH tunnel in order to allow Xplenty to connect to your database.

This application is setting up a persistant SSH tunnel from a Heroku server to Xplenty for tunnel based connections. This is mostly usefull for private spaced data stores hosted such as Heroku PostgreSQL which are not accessible from outside the private space.

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/xplenty/xplenty-ssh-tunnel)

## Usage

The persistant SSH tunnel is initiated using _autossh_ - a program to start a copy of ssh and monitor it, restarting it as necessary should it die or stop passing traffic. More information about autossh can be found here: [http://www.harding.motd.ca/autossh/](http://www.harding.motd.ca/autossh).

This application is using both the [autossh](https://github.com/xplenty/heroku-buildpack-autossh) and [ruby](https://github.com/heroku/heroku-buildpack-ruby) buildpacks.

During application startup, the container starts a bash shell that runs any code in `$HOME/.profile` before executing the dyno's command. We leverage this by sourcing `script/setup-ssh-tunnel.sh` file which handles autossh set up.

Note: The SSH tunnel might be unavailable during [Dyno automatic restart](https://devcenter.heroku.com/articles/dynos#automatic-dyno-restarts) which can cause your Xplenty jobs to fail.

### Managing Your SSH Keys

When configuring SSH tunnels for connecting to databases, authentication is performed using the SSH server. To authenticate using key based authentication, a key pair needs to be generated and then added to your user settings in Xplenty.

We assume a RSA SSH key pair is already present under `$HOME/.ssh/id_rsa` and the public key [was already added to your Xplenty user settings](http://community.xplenty.com/knowledgebase/articles/468251). If you don't have an existing public and private key pair, or don't wish to use any that are available to connect to Xplenty, then [generate a new SSH key](http://community.xplenty.com/knowledgebase/articles/468251).

### Environment Variables

The following application settings are required in order for the tunnel to be set up:

```
$ APP_NAME=<your app name>

$ heroku config:set XPLENTY_SSH_TUNNEL_CONNECTION_PORT="<xplenty's tunnel connection port here>" -a ${APP_NAME}
$ heroku config:set XPLENTY_SSH_TUNNEL_HOST="<xplenty's server host name here>" -a ${APP_NAME}
$ heroku config:set XPLENTY_SSH_TUNNEL_PORT="50683" -a ${APP_NAME}
$ heroku config:set XPLENTY_SSH_TUNNEL_USER_NAME="sshtunnel" -a ${APP_NAME}
$ heroku config:set XPLENTY_SSH_TUNNEL_PRIVATE_KEY="`cat $HOME/.ssh/id_rsa`" -a ${APP_NAME}
$ heroku config:set XPLENTY_SSH_TUNNEL_PUBLIC_KEY="`cat $HOME/.ssh/id_rsa.pub`" -a ${APP_NAME}
$ heroku config:set XPLENTY_SSH_TUNNEL_DATABASE_HOST="<your database host here>" -a ${APP_NAME}
$ heroku config:set XPLENTY_SSH_TUNNEL_DATABASE_PORT="<your database port here>" -a ${APP_NAME}
```

## Monitoring SSH Tunnel Health

The application exposes a small status page for your tunnel:

```
$ heroku open -a ${APP_NAME}
```