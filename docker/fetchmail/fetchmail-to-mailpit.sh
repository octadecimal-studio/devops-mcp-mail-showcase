#!/bin/bash

# Skrypt przekazujący emaili z fetchmail do Mailpit przez SMTP
# Używany jako MDA (Mail Delivery Agent) przez fetchmail

MAILPIT_HOST="${MAILPIT_HOST:-mailpit}"
MAILPIT_PORT="${MAILPIT_PORT:-1025}"

# Odczytaj email ze stdin
email_content=$(cat)

# Wyciągnij adres nadawcy i odbiorcy z nagłówków
from=$(echo "$email_content" | grep -i "^From:" | head -1 | sed 's/^From: //' | sed 's/.*<\(.*\)>/\1/' | sed 's/.*\([a-zA-Z0-9._%+-]\+@[a-zA-Z0-9.-]\+\.[a-zA-Z]\+\).*/\1/')
to=$(echo "$email_content" | grep -i "^To:" | head -1 | sed 's/^To: //' | sed 's/.*<\(.*\)>/\1/' | sed 's/.*\([a-zA-Z0-9._%+-]\+@[a-zA-Z0-9.-]\+\.[a-zA-Z]\+\).*/\1/')

# Jeśli nie znaleziono, użyj domyślnych wartości
if [ -z "$from" ]; then
    from="unknown@example.com"
fi

if [ -z "$to" ]; then
    to="mailpit@example.com"
fi

# Sprawdź czy to nie jest chroniony adres
if echo "$from" | grep -qi "octadecimal@example.com"; then
    echo "Pomijam email z chronionego adresu: $from" >&2
    exit 0
fi

# Wyślij email do Mailpit przez SMTP używając swaks lub msmtp
# Jeśli swaks jest dostępny, użyj go (lepsze wsparcie dla raw email)
if command -v swaks >/dev/null 2>&1; then
    echo "$email_content" | swaks \
        --to "$to" \
        --from "$from" \
        --server "$MAILPIT_HOST" \
        --port "$MAILPIT_PORT" \
        --data - \
        --h-From: "$from" \
        --h-To: "$to" \
        >/dev/null 2>&1
else
    # Alternatywnie użyj msmtp (wymaga konfiguracji)
    echo "$email_content" | msmtp \
        --host="$MAILPIT_HOST" \
        --port="$MAILPIT_PORT" \
        --from="$from" \
        "$to" \
        >/dev/null 2>&1
fi

# Loguj (opcjonalnie)
echo "$(date '+%Y-%m-%d %H:%M:%S') - Przekazano email od $from do $to" >> /var/log/fetchmail/mailpit.log

exit 0
