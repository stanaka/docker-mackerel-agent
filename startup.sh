#!/bin/bash
set -e

prog=/usr/bin/mackerel-agent

if [[ $apikey ]]; then
    $prog init -apikey=${apikey}
fi

if [[ $include ]]; then
    sed -i -e "s|# Configuration for Custom Metrics Plugins|include = \"${include}\"|" /etc/mackerel-agent/mackerel-agent.conf
fi

if [[ $enable_docker_plugin ]] && ! grep "^\[plugin\.metrics\.docker\]" /etc/mackerel-agent/mackerel-agent.conf; then
    echo [plugin.metrics.docker] >> /etc/mackerel-agent/mackerel-agent.conf
    echo command = \"/usr/bin/mackerel-plugin-docker -method API -name-format name\" >> /etc/mackerel-agent/mackerel-agent.conf
fi

sig_trap() {
    func="$1"
    shift $@
    for sig in $@; do
        trap "$func $sig" "$sig"
    done
}

cleanup() {
    sig="$1"
    if [[ $auto_retirement ]]; then
        $prog retire -force $opts
    fi
    kill -$sig $PID
}

# Propagate signals to mackerel-agent.
sig_trap cleanup INT TERM QUIT HUP

echo /usr/bin/mackerel-agent -apikey=${apikey} $opts
/usr/bin/mackerel-agent $opts &
PID=$!
wait $PID
