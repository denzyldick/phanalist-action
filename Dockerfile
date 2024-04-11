FROM ubuntu:latest
RUN apt-get -y update; apt-get -y install curl
RUN curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/denzyldick/phanalist/main/bin/init.sh | sh
ENTRYPOINT [ "/root/phanalist " ]


