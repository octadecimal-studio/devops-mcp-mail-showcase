FROM alpine:latest

# Instalacja fetchmail i narzędzi
RUN apk add --no-cache \
    fetchmail \
    ca-certificates \
    bash \
    curl \
    jq \
    msmtp \
    su-exec \
    && rm -rf /var/cache/apk/*

# Utworzenie użytkownika
RUN addgroup -g 1000 fetchmail || true && \
    adduser -D -u 1000 -s /bin/sh fetchmail && \
    adduser fetchmail fetchmail || true

# Katalogi robocze
RUN mkdir -p /var/mail/fetchmail /etc/fetchmail /var/log/fetchmail && \
    chown -R fetchmail:fetchmail /var/mail/fetchmail /etc/fetchmail /var/log/fetchmail

# Skrypt do przekazywania emaili do Mailpit
COPY fetchmail-to-mailpit.sh /usr/local/bin/fetchmail-to-mailpit.sh
RUN chmod +x /usr/local/bin/fetchmail-to-mailpit.sh

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Konfiguracja fetchmail (będzie montowana jako volume, więc tylko katalog)
RUN mkdir -p /etc/fetchmail

# Zmiana użytkownika (zostawiamy jako root, żeby móc zmienić właściciela pliku)
# USER fetchmail

WORKDIR /var/mail/fetchmail

ENTRYPOINT ["/entrypoint.sh"]
