FROM ubuntu:latest
WORKDIR /usr/src/
RUN curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/denzyldick/phanalist/main/bin/init.sh | sh

COPY . .
RUN chmod 0755 -R /usr/src/
CMD /usr/src/phanalist
