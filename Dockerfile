FROM golang:1.24.5-alpine3.21 AS build-stage

RUN <<-EOF
	apk --no-cache update
	apk --no-cache upgrade

	apk --no-cache add ca-certificates curl gcc g++ git make
EOF

WORKDIR /usr/src/xcrawl3r

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN make go-build

FROM alpine:3.22

RUN <<-EOF
	apk --no-cache update
	apk --no-cache upgrade

	apk --no-cache add bind-tools ca-certificates

	addgroup runners

	adduser runner -D -G runners
EOF

USER runner

COPY --from=build-stage /usr/src/xcrawl3r/bin/xcrawl3r /usr/local/bin/

ENTRYPOINT ["xcrawl3r"]