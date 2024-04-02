FROM alpine
ADD kind.sh /bin/
RUN chmod +x /bin/kind.sh
RUN apk -Uuv add curl bash ca-certificates git
ENTRYPOINT /bin/kind.sh