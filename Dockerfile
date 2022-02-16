FROM golang:alpine as builder
COPY . /go/src/github.com/swce/metadata-resource
ENV CGO_ENABLED 0
RUN go env -w GO111MODULE=off
ENV GOPATH /go/src/github.com/swce/metadata-resource/Godeps/_workspace:${GOPATH}
ENV PATH /go/src/github.com/swce/metadata-resource/Godeps/_workspace/bin:${PATH}
RUN go build -o /assets/out github.com/swce/metadata-resource/out
RUN go build -o /assets/in github.com/swce/metadata-resource/in
RUN go build -o /assets/check github.com/swce/metadata-resource/check
RUN set -e; for pkg in $(go list ./...); do \
		go test -o "/tests/$(basename $pkg).test" -c $pkg; \
	done

FROM alpine:edge AS resource
RUN apk add --update bash tzdata
COPY --from=builder /assets /opt/resource

FROM resource AS tests
COPY --from=builder /tests /tests
RUN set -e; for test in /tests/*.test; do \
		$test; \
	done

FROM resource
