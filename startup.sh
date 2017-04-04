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

cleanup() {
    sig="$1"
    kill -"$sig" "$PID"
    if [ "$auto_retirement" != "" ] && [ "$auto_retirement" != "0" ]; then
        $prog retire -force $opts
    fi
}

# Propagate signals to mackerel-agent.
for sig in INT TERM QUIT HUP; do
    trap "cleanup $sig" $sig
done

echo /usr/bin/mackerel-agent -apikey="$apikey" $opts
$prog $opts &
PID=$!
wait $PID
