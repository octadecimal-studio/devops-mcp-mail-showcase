#!/bin/bash

# Entrypoint dla kontenera fetchmail

set -e

echo "=== Fetchmail Container ==="
echo "Mailpit host: ${MAILPIT_HOST:-mailpit}"
echo "Mailpit port: ${MAILPIT_PORT:-1025}"
echo ""

# Sprawdź czy plik konfiguracyjny istnieje
if [ ! -f /etc/fetchmail/fetchmailrc ]; then
    echo "⚠️  Brak pliku /etc/fetchmail/fetchmailrc"
    echo "Utwórz plik na podstawie fetchmailrc.example"
    echo ""
    echo "Przykład:"
    echo "  cp docker/fetchmail/fetchmailrc.example docker/fetchmail/fetchmailrc"
    echo "  # Edytuj docker/fetchmail/fetchmailrc i uzupełnij dane"
    exit 1
fi

# Sprawdź uprawnienia do pliku konfiguracyjnego
# Fetchmail wymaga uprawnień 600 lub 700 i właściciela fetchmail
chown fetchmail:fetchmail /etc/fetchmail/fetchmailrc
chmod 600 /etc/fetchmail/fetchmailrc

# Utworzenie katalogu logów jeśli nie istnieje
mkdir -p /var/log/fetchmail
chown fetchmail:fetchmail /var/log/fetchmail

# Sprawdź czy Mailpit jest dostępny
echo "Sprawdzanie dostępności Mailpit..."
timeout 5 bash -c "until nc -z ${MAILPIT_HOST:-mailpit} ${MAILPIT_PORT:-1025}; do sleep 1; done" 2>/dev/null || {
    echo "⚠️  Mailpit nie jest dostępny na ${MAILPIT_HOST:-mailpit}:${MAILPIT_PORT:-1025}"
    echo "Upewnij się, że kontener mailpit jest uruchomiony"
}

echo ""
echo "Uruchamianie fetchmail w trybie daemon..."
echo "Fetchmail będzie sprawdzał nowe maile co ${FETCHMAIL_INTERVAL:-300} sekund"
echo ""

# Uruchom fetchmail w trybie daemon jako użytkownik fetchmail
exec su-exec fetchmail fetchmail \
    --daemon ${FETCHMAIL_INTERVAL:-300} \
    --pidfile /var/run/fetchmail.pid \
    --logfile /var/log/fetchmail/fetchmail.log \
    --fetchmailrc /etc/fetchmail/fetchmailrc \
    --verbose
