# docker-mackerel-agent
Docker image for mackerel-agent


# Usage

## Basic usage

To launch mackerel-agent image, run this command. Replace `<APIKEY>` to your own apikey.

```
docker run -h `hostname` \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/lib/mackerel-agent/:/var/lib/mackerel-agent/ \
  -e 'apikey=<APIKEY>' \
  -e 'enable_docker_plugin=true' \
  -e 'opts=-v' \
  --name mackerel-agent \
  -d \
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
command = "/usr/bin/mackerel-plugin-memcached -host=$MEMCACHED_PORT_11211_TCP_ADDR"
```

3. Launch mackerel-agent container linking to the memcached container.
`-v` and `include` is to include other configuration files.

```
docker run -h `hostname` \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/lib/mackerel-agent/:/var/lib/mackerel-agent/ \
  -e 'apikey=<APIKEY>' \
  -e 'enable_docker_plugin=true' \
  -e 'opts=-v' \
  --link memcached:memcached \
  -v /etc/mackerel-agent/conf.d:/etc/mackerel-agent/conf.d:ro \
  -e 'include=/etc/mackerel-agent/conf.d/*.conf' \
  --name mackerel-agent \
  -d \
  mackerel/mackerel-agent
```

## Retire the host automatically

If you want to retire a host of a mackerel-agent container on Mackerel when the container stops,
you should set `auto_retirement=true` as an environment variable.

If the variable is set, the retirement API is called while terminate process of the containter.
See the entry about auto retirement in detail: http://blog.mackerel.io/entry/2015/08/03/142244 .

```
docker run -h `hostname` \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/lib/mackerel-agent/:/var/lib/mackerel-agent/ \
  -e 'apikey=<APIKEY>' \
  -e 'auto_retirement=true' \
  -e 'enable_docker_plugin=true' \
  -e 'opts=-v' \
  -d \
  mackerel/mackerel-agent
```

Note: replace `<APIKEY>` to your own apikey.
