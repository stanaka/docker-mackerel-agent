#!/bin/bash
set -e

if [[ $apikey ]]; then
    sed -i -e "s|# apikey = \"\"|apikey = \"${apikey}\"|" /etc/mackerel-agent/mackerel-agent.conf
fi

if [[ $include ]]; then
    sed -i -e "s|# Configuration for Custm Metrics Plugins|include = \"${include}\"|" /etc/mackerel-agent/mackerel-agent.conf
fi

if [[ $auto_retirement ]]; then
    trap '/usr/local/bin/mackerel-agent retire -force' TERM KILL
fi

if [[ $enable_docker_plugin ]]; then
    echo [plugin.metrics.docker] >> /etc/mackerel-agent/mackerel-agent.conf
    echo command = \"/usr/local/bin/mackerel-plugin-docker -name-format name\" >> /etc/mackerel-agent/mackerel-agent.conf
fi

echo /usr/local/bin/mackerel-agent -apikey=${apikey} $opts
/usr/local/bin/mackerel-agent $opts &
wait ${!}
