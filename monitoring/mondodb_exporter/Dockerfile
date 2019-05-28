FROM golang:1.11.4 as builder

ENV PERCONA_DIR $GOPATH/src/github.com/percona
RUN mkdir -p $PERCONA_DIR && cd $PERCONA_DIR/ && git clone "https://github.com/percona/mongodb_exporter"

WORKDIR $PERCONA_DIR/mongodb_exporter

COPY . .

RUN make build

FROM quay.io/prometheus/busybox:latest

LABEL maintainer="Alexey Palazhchenko <alexey.palazhchenko@percona.com>"

COPY --from=0 /go/src/github.com/percona/mongodb_exporter/bin/mongodb_exporter /bin/mongodb_exporter

EXPOSE 9216

ENTRYPOINT [ "/bin/mongodb_exporter" ]
