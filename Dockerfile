FROM hugomods/hugo:latest AS builder

WORKDIR /src

COPY . .

RUN hugo

FROM caddy:2-alpine

COPY --from=builder /src/public /usr/share/caddy
