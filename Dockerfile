FROM nginx:alpine
LABEL org.opencontainers.image.title="workstation-mission-web"
LABEL org.opencontainers.image.description="Codyssey workstation mission static web server"
COPY site/ /usr/share/nginx/html/
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD wget -q -O /dev/null http://127.0.0.1/ || exit 1
