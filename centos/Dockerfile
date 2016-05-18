FROM centos:6

WORKDIR /tmp

# SETUP docker.repo
COPY docker.repo /etc/yum.repos.d/docker.repo

RUN yum update -y \
    && yum install -y \
         docker-engine \
         sudo \
# SETUP sudo tty
    && sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers \
# SETUP mackerel-agent mackerel-agent-plugins, mackerel-check-plugins
    && curl -fsSL https://mackerel.io/assets/files/scripts/setup-yum.sh | sh \
    &&  yum install -y \
          mackerel-agent \
          mackerel-agent-plugins \
          mackerel-check-plugins \
# SETUP clean all
    && yum clean all

# setup startup.sh
ADD startup.sh /startup.sh
RUN chmod 755 /startup.sh

# boot mackerel-agent
CMD ["/startup.sh"]
