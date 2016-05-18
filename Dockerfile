FROM centos:7

# setup mackerel-agent
RUN curl -fsSL https://mackerel.io/file/script/amznlinux/setup-yum.sh | sed -r 's/sudo( -k)?//' | sh \
  && sed -i.bak 's/$releasever/latest/' /etc/yum.repos.d/mackerel.repo \
  && yum -y install mackerel-agent mackerel-agent-plugins mackerel-check-plugins

ADD startup.sh /startup.sh
RUN chmod 755 /startup.sh

# boot mackerel-agent
CMD ["/startup.sh"]
