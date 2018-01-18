FROM alpine:3.4

# golang envrironment
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH

# SETUP build deps package
RUN apk add --no-cache --update --virtual .mackerel-agent-build-deps \
      go \
      git \
      perl \
      build-base && \
# SETUP mackerel-agent
    go get -d github.com/mackerelio/mackerel-agent && \
    cd /go/src/github.com/mackerelio/mackerel-agent/ && \
      make build && \
# SETUP copy mackerel-agent.conf
    mkdir /etc/mackerel-agent && \
      cp /go/src/github.com/mackerelio/mackerel-agent/mackerel-agent.sample.conf /etc/mackerel-agent/mackerel-agent.conf && \
# SETUP gox
    go get github.com/mitchellh/gox && \
# SETUP mackerel-agent-plugins
    cd /go/src/github.com/mackerelio/ && \
      git clone https://github.com/mackerelio/mackerel-agent-plugins.git && \
    cd /go/src/github.com/mackerelio/mackerel-agent-plugins/ && \
      make build && \
# SETUP go-check-plugins
    cd /go/src/github.com/mackerelio/ && \
      git clone https://github.com/mackerelio/go-check-plugins.git && \
    cd /go/src/github.com/mackerelio/go-check-plugins/ && \
      make build && \
# SETUP copy build binary to /usr/bin
    mv /go/src/github.com/mackerelio/mackerel-agent/build/mackerel-agent /usr/bin/ && \
    mv /go/src/github.com/mackerelio/mackerel-agent-plugins/build/mackerel-plugin-* /usr/bin/ && \
    mv /go/src/github.com/mackerelio/go-check-plugins/build/check-* /usr/bin/ && \
# SETUP clean deps go packages
    go clean -i -x -r github.com/mitchellh/gox && \
    go clean -i -x -r github.com/laher/goxc && \
    go clean -i -x -r github.com/pierrre/gotestcover && \
    go clean -i -x -r github.com/mattn/goveralls && \
# SETUP remove build-deps
    apk del .mackerel-agent-build-deps && \
# SETUP remove go/src
    rm -Rf /go/src/*

# SETUP add run-deps
RUN apk add --no-cache --virtual .mackerel-agent-run-deps \
    bash \
    ca-certificates \
    iproute2 \
    docker \
    coreutils

# SETUP startup.sh
ADD startup.sh /startup.sh
RUN chmod 755 /startup.sh

# bootup
CMD ["/startup.sh"]
