FROM ghcr.io/denzyldick/phanalist:latest

WORKDIR /github/workspace
ENTRYPOINT [ "phanalist --src=/github/workspace" ]

