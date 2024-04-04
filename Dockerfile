FROM php:8.3.3-cli-bullseye
WORKDIR /usr/src/
RUN curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/denzyldick/phanalist/main/bin/init.sh | sh

COPY . .
ENTRYPOINT["/usr/src/phanalist"]
