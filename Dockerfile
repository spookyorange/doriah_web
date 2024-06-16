FROM elixir:1.16.3-otp-26-alpine

WORKDIR /app

EXPOSE 4000

RUN apk add inotify-tools git

