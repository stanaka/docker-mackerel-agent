#!/bin/bash
set -e

if [[ $apikey ]]; then
    sed -i -e "s|# apikey = \"\"|apikey = \"${apikey}\"|" /etc/mackerel-agent/mackerel-agent.conf
fi

if [[ $include ]]; then
    sed -i -e "s|# Configuration for connection|include = \"${include}\"|" /etc/mackerel-agent/mackerel-agent.conf
fi

if [[ $auto_retirement ]]; then
    sed -i -e "s|# AUTO_RETIREMENT=1|AUTO_RETIREMENT = ${auto_retirement}|" /etc/default/mackerel-agent
fi

echo /usr/local/bin/mackerel-agent -apikey=${apikey} -v
exec /usr/local/bin/mackerel-agent -v
