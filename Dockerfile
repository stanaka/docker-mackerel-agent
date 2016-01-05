FROM ubuntu:14.04

# setup mackerel-agent
RUN apt-get update \
  && apt-get -y install curl sudo ruby docker.io \
  && curl -fsSL https://mackerel.io/assets/files/scripts/setup-apt.sh | sh \
  && apt-get update \
  && apt-get -y install mackerel-agent mackerel-agent-plugins mackerel-check-plugins \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# setup docker plugin
RUN echo [plugin.metrics.docker] >> /etc/mackerel-agent/mackerel-agent.conf
RUN echo command = \"/usr/local/bin/mackerel-plugin-docker\" >> /etc/mackerel-agent/mackerel-agent.conf

ADD startup.sh /startup.sh
RUN chmod 755 /startup.sh

# boot mackerel-agent
CMD ["/startup.sh"]
