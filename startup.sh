#!/bin/sh
set -e

prog=/usr/bin/mackerel-agent
conf=/etc/mackerel-agent/mackerel-agent.conf

if [ "$apikey" != "" ]; then
    $prog init -apikey="$apikey"
fi

if [ "$include" != "" ]; then
    sed -i -e "s|# Configuration for Custom Metrics Plugins|include = \"${include}\"|" $conf
fi

if [ "$enable_docker_plugin" != "" ] && [ "$enable_docker_plugin" != "0" ] && ! grep '^[plugin.metrics.docker]' $conf; then
    cat >> $conf << "EOF"
[plugin.metrics.docker]
command = "/usr/bin/mackerel-plugin-docker -method API -name-format name"
EOF
fi

sig_trap() {
    func="$1"; shift
    for sig in "$@"; do
        trap "$func $sig" "$sig"
    done
}

cleanup() {
    sig="$1"
    if [ "$auto_retirement" != "" ] && [ "$auto_retirement" != "0" ]; then
        $prog retire -force $opts
    fi
    kill -"$sig" "$PID"
}

# Propagate signals to mackerel-agent.
sig_trap cleanup INT TERM QUIT HUP

echo /usr/bin/mackerel-agent -apikey="$apikey" $opts
/usr/bin/mackerel-agent $opts &
PID=$!
wait $PID
