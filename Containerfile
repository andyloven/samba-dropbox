# Tiny guest-only SMB3 dropbox.
# Build: podman build -t localhost/samba-dropbox .
ARG ALPINE_VERSION=3.23
FROM docker.io/library/alpine:${ALPINE_VERSION}

# smbd only. No nmbd, avahi, wsdd, or entrypoint script.
# "smb" (1000:1000) owns everything written to the share. Map it to your
# host user with --userns=keep-id:uid=1000,gid=1000 (see samba.container).
RUN apk add --no-cache samba-server \
 && addgroup -g 1000 smb \
 && adduser -D -H -u 1000 -G smb -s /sbin/nologin smb \
 && mkdir -p /share /run/samba /var/lib/samba/private /var/cache/samba \
 && chown smb:smb /share

COPY smb.conf /etc/samba/smb.conf

EXPOSE 445/tcp
VOLUME /share

# Keep the process in the foreground and send logs to stdout so journald/podman logs pick them up.
CMD ["smbd", "--foreground", "--no-process-group", "--debug-stdout"]
