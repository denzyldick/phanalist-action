FROM ghcr.io/denzyldick/phanalist:latest

WORKDIR /github/workspace
CMD [ "phanalist --src=." ]

