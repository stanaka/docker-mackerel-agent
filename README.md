# docker-mackerel-agent
Docker image for mackerel-agent


# Usage

## Basic usage

To launch mackerel-agent image, run this command. Replace `<APIKEY>` to your own apikey.

```
docker run -h `hostname` \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/lib/mackerel-agent/:/var/lib/mackerel-agent/ \
  -v /proc/mounts:/host/proc/mounts:ro \
  -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro
  -e 'apikey=<APIKEY>‘ \
  mackerel/mackerel-agent
```

## Monitor processes in other containers

If you want to monitor processes on other containers, `link` option can be used.

Here is an example for memcached.

1. Launch memcached container, which named `memcached`

```
docker run -d -P \ 
  --name memcached -p 11211:11211 \
  sylvainlasnier/memcached
```

2. Prepare a configuration file for a memcached plugin, which specifies the host address.
This file should be put on the host.

```
% cat /etc/mackerel-agent/conf.d/memcached.conf
[plugin.metrics.memcached]
command = "/usr/local/bin/mackerel-plugin-memcached -host=$MEMCACHED_PORT_11211_TCP_ADDR"
```

3. Launch mackerel-agent container linking to the memcached container.
`-v` and `include` is to include other configuration files.

```
docker run -h `hostname` \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/lib/mackerel-agent/:/var/lib/mackerel-agent/ \
  -v /proc/mounts:/host/proc/mounts:ro \
  -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro 
  -e 'apikey=<APIKEY>‘ \
  --link memcached:memcached \
  -v /etc/mackerel-agent/conf.d:/etc/mackerel-agent/conf.d:ro
  -e ‘include=/etc/mackerel-agent/conf.d/*' \
  mackerel/mackerel-agent
```

