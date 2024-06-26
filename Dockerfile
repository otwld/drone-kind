FROM docker:26.0.0-dind-alpine3.19
ADD kind.sh /bin/
ADD kind-config.yml /root
RUN chmod +x /bin/kind.sh
RUN apk -Uuv add curl bash ca-certificates
ENTRYPOINT /bin/kind.sh