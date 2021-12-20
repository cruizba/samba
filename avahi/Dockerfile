FROM alpine:3.15

RUN apk add --update avahi && \
    sed -i 's/#enable-dbus=yes/enable-dbus=no/g' /etc/avahi/avahi-daemon.conf && \
    rm -rf /var/cache/apk/*

ADD smb.service /etc/avahi/services/smb.service

ENTRYPOINT ["avahi-daemon"]
CMD []