# build go-jsonnet
FROM       golang:alpine as go_builder

RUN apk add git
RUN go get github.com/fatih/color
RUN wget https://github.com/google/go-jsonnet/archive/v0.15.0.zip && \
    unzip v0.15.0.zip && mkdir -p /go/src/github.com/google/go-jsonnet && \
    mv go-jsonnet-0.15.0/* /go/src/github.com/google/go-jsonnet/ && \
    cd /go/src/github.com/google/go-jsonnet/cmd/jsonnet && CGO_ENABLED=0 go build


# build base c jsonnet
FROM alpine:latest as c_builder

RUN apk -U add build-base

WORKDIR /opt

RUN wget https://github.com/google/jsonnet/archive/v0.15.0.zip
RUN unzip v0.15.0.zip

RUN cd jsonnet-0.15.0 && \
    make -j && \
    mv jsonnet /usr/local/bin && \
    mv jsonnetfmt /usr/local/bin && \
    rm -rf /opt/jsonnet-0.15.0 && ls /usr/local/bin/jsonnet


# create our container with both
FROM alpine:latest

RUN apk add --no-cache libstdc++ jq
COPY --from=c_builder /usr/local/bin/jsonnet /bin/c-jsonnet
COPY --from=c_builder /usr/local/bin/jsonnetfmt /bin/jsonnetfmt
COPY --from=go_builder  /go/src/github.com/google/go-jsonnet/cmd/jsonnet/jsonnet /bin/jsonnet
