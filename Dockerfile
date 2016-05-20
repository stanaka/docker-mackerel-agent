FROM centos:7

# setup docker.repo
RUN echo -e "[dockerrepo]\nname=Docker Repository\nbaseurl=https://yum.dockerproject.org/repo/main/centos/\$releasever/\nenabled=1\ngpgcheck=1\ngpgkey=https://yum.dockerproject.org/gpg" >> /etc/yum.repos.d/docker.repo
# setup mackerel-agent docker-engine
RUN curl -fsSL https://mackerel.io/file/script/amznlinux/setup-yum.sh | sed -r 's/sudo( -k)?//' | sh \
  && sed -i.bak 's/$releasever/latest/' /etc/yum.repos.d/mackerel.repo \
  && yum -y install mackerel-agent mackerel-agent-plugins mackerel-check-plugins \
  && yum -y install docker-engine \
  && yum clean all

ADD startup.sh /startup.sh
RUN chmod 755 /startup.sh

# boot mackerel-agent
CMD ["/startup.sh"]
