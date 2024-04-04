FROM php:8.3.3-cli-bullseye
WORKDIR /usr/src/phanalist
COPY . .
RUN chmod +x ./release/x86_64-unknown-linux-musl/phanalist
RUN ./release/x86_64-unknown-linux-musl/phanalist -h
