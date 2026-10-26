FROM golang:1.27-alpine@sha256:b8c9b82affbbb82a020bbcf998dad2ba9516944ac7e883524642a481a9505e9c AS builder

RUN mkdir /binary 

COPY ./test-webhook /binary/

WORKDIR /binary

RUN apk update && apk add --no-cache ca-certificates git tzdata && update-ca-certificates

RUN adduser -u 1000 -D -g '' appuser

RUN go get -d -v ./...

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o main .

# --------------------------------------------

FROM scratch 

WORKDIR /app

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /binary/ /app/

USER appuser

EXPOSE 8000

ENTRYPOINT ["./main"]
