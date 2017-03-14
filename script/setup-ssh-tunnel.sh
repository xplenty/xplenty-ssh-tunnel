#!/bin/sh -eu

mkdir -p ${HOME}/.ssh
chmod 700 ${HOME}/.ssh

# Copy public key env variable into a file
echo "${XPLENTY_SSH_TUNNEL_PUBLIC_KEY}" > ${HOME}/.ssh/id_rsa.pub
chmod 644 ${HOME}/.ssh/id_rsa.pub

# Copy private key env variable into a file
echo "${XPLENTY_SSH_TUNNEL_PRIVATE_KEY}" > ${HOME}/.ssh/id_rsa
chmod 600 ${HOME}/.ssh/id_rsa

# Auto add the host to known_hosts
# This is to avoid the authenticity of host question that otherwise will halt autossh from setting up the tunnel.
ssh-keyscan -p ${XPLENTY_SSH_TUNNEL_PORT} ${XPLENTY_SSH_TUNNEL_HOST} >> ${HOME}/.ssh/known_hosts

# Setup SSH Tunnel - If the connection dies autossh will automatically set up a new one.
export AUTOSSH_LOGFILE=${HOME}/.heroku/tunnel.log 
export AUTOSSH_PIDFILE=${HOME}/.heroku/autossh.pid

# Store the command that will be used so we can display it in rack app
cat <<EOF > ${HOME}/.heroku/tunnel.cmd
autossh -M 0 -f -N -R ${XPLENTY_SSH_TUNNEL_CONNECTION_PORT}:${XPLENTY_SSH_TUNNEL_DATABASE_HOST}:${XPLENTY_SSH_TUNNEL_DATABASE_PORT} ${XPLENTY_SSH_TUNNEL_USER_NAME:-sshtunnel}@${XPLENTY_SSH_TUNNEL_HOST} -g -i ${HOME}/.ssh/id_rsa -p ${XPLENTY_SSH_TUNNEL_PORT} -o "ExitOnForwardFailure yes" -o "ServerAliveInterval 10" -o "ServerAliveCountMax 1" -o "UserKnownHostsFile ${HOME}/.ssh/known_hosts"
EOF
autossh -M 0 -f -N -R ${XPLENTY_SSH_TUNNEL_CONNECTION_PORT}:${XPLENTY_SSH_TUNNEL_DATABASE_HOST}:${XPLENTY_SSH_TUNNEL_DATABASE_PORT} ${XPLENTY_SSH_TUNNEL_USER_NAME:-sshtunnel}@${XPLENTY_SSH_TUNNEL_HOST} -g -i ${HOME}/.ssh/id_rsa -p ${XPLENTY_SSH_TUNNEL_PORT} -o "ExitOnForwardFailure yes" -o "ServerAliveInterval 10" -o "ServerAliveCountMax 1" -o "UserKnownHostsFile ${HOME}/.ssh/known_hosts"