#!/bin/bash
set -e

if [[ $apikey ]]; then
    sed -i -e "s|# apikey = \"\"|apikey = \"${apikey}\"|" /etc/mackerel-agent/mackerel-agent.conf
fi

if [[ $include ]]; then
    sed -i -e "s|# Configuration for Custom Metrics Plugins|include = \"${include}\"|" /etc/mackerel-agent/mackerel-agent.conf
fi

if [[ $enable_docker_plugin ]] && ! grep "^\[plugin\.metrics\.docker\]" /etc/mackerel-agent/mackerel-agent.conf; then
    echo [plugin.metrics.docker] >> /etc/mackerel-agent/mackerel-agent.conf
    echo command = \"/usr/bin/mackerel-plugin-docker -method API -name-format name\" >> /etc/mackerel-agent/mackerel-agent.conf
fi

# Propagate signals to mackerel-agent.
if [[ $auto_retirement ]]; then
    trap '/usr/bin/mackerel-agent retire -force' TERM KILL
fi
trap 'kill -SIGTERM $PID' SIGTERM
trap 'kill -SIGQUIT $PID' SIGQUIT
trap 'kill -SIGHUP  $PID' SIGHUP

echo /usr/bin/mackerel-agent -apikey=${apikey} $opts
/usr/bin/mackerel-agent $opts &
PID=$!
wait $PID
