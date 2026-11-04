#!/bin/zsh
set +e
cd "$(dirname "$0")/.."
run() {
  printf '\n$'
  printf ' %q' "$@"
  printf '\n'
  "$@"
  local rc=$?
  printf '[exit %s]\n' "$rc"
}
run docker --version
run docker info --format '{{.ServerVersion}}'
run docker run --rm hello-world
run docker images
run docker run --rm ubuntu:24.04 sh -c 'pwd; whoami; ls -la; echo Ubuntu container ready'
run docker run -d --name workstation-ubuntu ubuntu:24.04 sh -c 'echo ubuntu-log-line; sleep 3600'
run docker exec workstation-ubuntu sh -c 'pwd; whoami; ls -la; echo command-from-exec'
run docker logs workstation-ubuntu
run docker stats --no-stream workstation-ubuntu
run docker ps
run docker stop workstation-ubuntu
run docker ps -a
run docker start workstation-ubuntu
run docker exec workstation-ubuntu sh -c 'echo container-started-again'
run docker stop workstation-ubuntu
run docker rm workstation-ubuntu
run docker build -t workstation-mission-web:1.0 .
run docker images workstation-mission-web
run docker run -d --name workstation-web-8080 -p 8080:80 workstation-mission-web:1.0
run curl -i http://localhost:8080
run docker run -d --name workstation-web-8081 -p 8081:80 workstation-mission-web:1.0
run curl -i http://localhost:8081
run docker logs workstation-web-8080
run docker stats --no-stream workstation-web-8080
run docker ps -a
mkdir -p runtime/bind
printf 'bind mount version one\n' > runtime/bind/index.html
run docker run -d --name workstation-bind -p 18082:80 -v "$PWD/runtime/bind:/usr/share/nginx/html:ro" nginx:alpine
run curl -s http://localhost:18082
printf 'bind mount version two\n' > runtime/bind/index.html
run curl -s http://localhost:18082
run docker rm -f workstation-bind
run docker volume create workstation-mission-data
run docker run -d --name workstation-volume-one -v workstation-mission-data:/data ubuntu:24.04 sleep infinity
run docker exec workstation-volume-one sh -c 'echo persistent-data > /data/check.txt && cat /data/check.txt'
run docker rm -f workstation-volume-one
run docker run --rm -v workstation-mission-data:/data ubuntu:24.04 cat /data/check.txt
run docker volume ls
# Deliberate, isolated name-conflict reproduction for troubleshooting evidence.
run docker run -d --name workstation-name-conflict alpine:3.20 sleep 60
run docker run -d --name workstation-name-conflict alpine:3.20 sleep 60
run docker rm -f workstation-name-conflict
run docker run -d --name workstation-name-conflict alpine:3.20 sleep 60
run docker ps -a
run docker rm -f workstation-name-conflict
