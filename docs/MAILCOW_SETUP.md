# 📧 Mailcow - Instalacja i Konfiguracja

**Data utworzenia:** 2026-01-21  
**Projekt:** api.example.test  
**VPS:** debian@203.0.113.10

---

## 🎯 Wprowadzenie

Mailcow to kompleksowy, open-source'owy serwer pocztowy oparty na Dockerze. System umożliwia:

- **Samodzielny serwer pocztowy** (self-hosted)
- **Obsługę wielu domen email**
- **Skrzynki pocztowe** tworzone lokalnie na serwerze
- **Dostęp przez IMAP/SMTP** z TLS
- **Automatyczną konfigurację DNS** przez OVH API
- **Pełną automatyzację** przez REST API

---

## 📋 Wymagania

- VPS z Ubuntu 22.04 LTS (lub Debian)
- Docker >= 24.0.0
- Docker Compose >= 2.0
- Domeny zarejestrowane w OVH
- DNS zarządzany przez OVH API
- SSH dostęp do VPS

---

## 🚀 Instalacja

### Krok 1: Instalacja Mailcow na VPS

```bash
# Z katalogu głównego projektu
./scripts/mailcow/install-mailcow.sh
```

Skrypt automatycznie:
- Zainstaluje wymagane pakiety
- Zainstaluje Docker (jeśli nie jest zainstalowany)
- Sklonuje repozytorium Mailcow
- Wygeneruje konfigurację
- Uruchomi kontenery Docker

### Krok 2: Konfiguracja początkowa

1. **Dostęp do panelu:**
   ```
   https://mail.octadecimal.studio
   ```

2. **Domyślne dane logowania:**
   - Login: `admin`
   - Hasło: `moohoo`
   
   ⚠️ **ZMIEŃ HASŁO NATYCHMIAST!**

3. **Wygeneruj API Key:**
   - Przejdź do: `Configuration → API`
   - Kliknij "Generate API Key"
   - Skopiuj wygenerowany klucz

4. **Dodaj API Key do `.admin`:**
   ```bash
   # Edytuj .admin i dodaj:
   MAILCOW_API_KEY=twoj_wygenerowany_klucz
   ```

Alternatywnie, możesz wygenerować klucz przez SSH:
```bash
ssh debian@203.0.113.10 'cd /opt/mailcow-dockerized && docker compose exec mailcow-api-mailcow /bin/bash -c "cd / && source /source/functions.sh && api"'
```

---

## 🔧 Zarządzanie domenami

### Automatyczna konfiguracja domeny

Skrypt `setup-domain.sh` automatycznie:
1. Dodaje domenę do Mailcow
2. Pobiera klucz DKIM
3. Konfiguruje DNS w OVH (MX, SPF, DKIM, DMARC)

```bash
# Dodaj domenę z automatyczną konfiguracją DNS
./scripts/mailcow/setup-domain.sh example.com mail.example.com
```

### Ręczna konfiguracja

#### 1. Dodaj domenę do Mailcow

```bash
./scripts/mailcow/mailcow-api.sh add-domain example.com "Opis domeny"
```

#### 2. Pobierz klucz DKIM

```bash
./scripts/mailcow/mailcow-api.sh get-dkim example.com
```

#### 3. Konfiguracja DNS w OVH

```bash
# Rekord A dla mail hostname
./scripts/automation/ovh-dns.sh add mail 203.0.113.10

# Rekord MX
./scripts/automation/ovh-dns.sh add-mx 10 mail.example.com

# Rekord SPF
./scripts/automation/ovh-dns.sh add-txt "" "v=spf1 mx a ip4:203.0.113.10 -all"

# Rekord DKIM (pobierz z Mailcow)
./scripts/automation/ovh-dns.sh add-txt "dkim._domainkey" "v=DKIM1; k=rsa; p=..."

# Rekord DMARC
./scripts/automation/ovh-dns.sh add-txt "_dmarc" "v=DMARC1; p=reject; rua=mailto:dmarc@example.com"
```

---

## 📧 Zarządzanie skrzynkami

### Utworzenie skrzynki

```bash
# Utwórz skrzynkę (hasło zostanie wygenerowane automatycznie)
./scripts/mailcow/mailcow-api.sh create-mailbox user@example.com

# Utwórz skrzynkę z własnym hasłem
./scripts/mailcow/mailcow-api.sh create-mailbox user@example.com "moje_haslo" "Imię Nazwisko" 2048

# Parametry:
# - email: adres email
# - password: hasło (opcjonalne, jeśli puste - wygenerowane)
# - name: imię i nazwisko (opcjonalne)
# - quota: limit skrzynki w MB (domyślnie 1024)
```

### Lista skrzynek

```bash
# Wszystkie skrzynki
./scripts/mailcow/mailcow-api.sh list-mailboxes

# Skrzynki dla konkretnej domeny
./scripts/mailcow/mailcow-api.sh list-mailboxes example.com
```

### Lista domen

```bash
./scripts/mailcow/mailcow-api.sh list-domains
```

---

## 🔐 Konfiguracja klienta pocztowego

### Ustawienia IMAP/SMTP

```
IMAP Server: mail.octadecimal.studio
IMAP Port: 993 (SSL/TLS)
IMAP Security: SSL/TLS

SMTP Server: mail.octadecimal.studio
SMTP Port: 587 (STARTTLS) lub 465 (SSL/TLS)
SMTP Security: STARTTLS lub SSL/TLS

Username: pełny adres email (np. user@example.com)
Password: hasło skrzynki
```

### Autodiscover / Autoconfig

Mailcow automatycznie obsługuje:
- `autodiscover.example.com`
- `autoconfig.example.com`

Te subdomeny powinny wskazywać na `mail.octadecimal.studio` (CNAME).

---

## 🛠️ Skrypty i narzędzia

### `scripts/mailcow/mailcow-api.sh`

Główny skrypt do zarządzania Mailcow przez API.

**Akcje:**
- `add-domain <domain> [description]` - Dodaj domenę
- `create-mailbox <email> [pass] [name] [quota]` - Utwórz skrzynkę
- `get-dkim <domain>` - Pobierz klucz DKIM
- `list-domains` - Lista domen
- `list-mailboxes [domain]` - Lista skrzynek

### `scripts/mailcow/setup-domain.sh`

Automatyczna konfiguracja domeny (Mailcow + OVH DNS).

**Użycie:**
```bash
./scripts/mailcow/setup-domain.sh <domain> [mail_hostname]
```

### `scripts/mailcow/install-mailcow.sh`

Instalacja Mailcow na VPS.

**Użycie:**
```bash
./scripts/mailcow/install-mailcow.sh [vps_host]
```

---

## 📚 Przykłady użycia

### Przykład 1: Pełna konfiguracja nowej domeny

```bash
# 1. Dodaj domenę z automatyczną konfiguracją DNS
./scripts/mailcow/setup-domain.sh example.com mail.example.com

# 2. Utwórz skrzynkę
./scripts/mailcow/mailcow-api.sh create-mailbox info@example.com "haslo123" "Info Example" 2048

# 3. Sprawdź propagację DNS
./scripts/automation/ovh-dns.sh check mail
```

### Przykład 2: Dodanie wielu skrzynek

```bash
# Utwórz kilka skrzynek dla domeny
for user in admin info sales support; do
    ./scripts/mailcow/mailcow-api.sh create-mailbox ${user}@example.com
done
```

### Przykład 3: Sprawdzenie statusu

```bash
# Lista wszystkich domen
./scripts/mailcow/mailcow-api.sh list-domains

# Lista skrzynek dla domeny
./scripts/mailcow/mailcow-api.sh list-mailboxes example.com
```

---

## 🔍 Troubleshooting

### Problem: Mailcow nie uruchamia się

```bash
# Sprawdź logi
ssh debian@203.0.113.10 'cd /opt/mailcow-dockerized && docker compose logs'

# Sprawdź status kontenerów
ssh debian@203.0.113.10 'cd /opt/mailcow-dockerized && docker compose ps'
```

### Problem: Błąd autentykacji API

- Sprawdź czy `MAILCOW_API_KEY` jest ustawiony w `.admin`
- Sprawdź czy klucz jest poprawny w panelu Mailcow
- Wygeneruj nowy klucz jeśli potrzeba

### Problem: DNS nie propaguje się

```bash
# Sprawdź propagację
./scripts/automation/ovh-dns.sh check mail

# Sprawdź przez różne serwery DNS
dig @8.8.8.8 mail.example.com
dig @1.1.1.1 mail.example.com
```

### Problem: Maile nie przychodzą

1. Sprawdź rekordy DNS (MX, SPF, DKIM, DMARC)
2. Sprawdź logi Postfix:
   ```bash
   ssh debian@203.0.113.10 'cd /opt/mailcow-dockerized && docker compose logs postfix-mailcow'
   ```
3. Sprawdź czy porty są otwarte (25, 587, 993)

---

## 🔒 Bezpieczeństwo

### Wymagane ustawienia produkcyjne

1. **Zmień domyślne hasło administratora**
2. **Włącz fail2ban** (już wbudowany w Mailcow)
3. **Skonfiguruj firewall** (porty 25, 587, 993, 995)
4. **Regularne backupy** skrzynek
5. **Monitoruj logi** pod kątem ataków

### Backup

```bash
# Backup skrzynek (na VPS)
ssh debian@203.0.113.10 'cd /opt/mailcow-dockerized && ./helper-scripts/backup_and_restore.sh backup all'
```

---

## 📖 Dokumentacja

- **Oficjalna dokumentacja Mailcow:** https://docs.mailcow.email/
- **API Documentation:** https://docs.mailcow.email/api_docs/
- **GitHub:** https://github.com/mailcow/mailcow-dockerized

---

## ✅ Checklist produkcyjna

- [ ] Mailcow zainstalowany i uruchomiony
- [ ] Hasło administratora zmienione
- [ ] API Key wygenerowany i dodany do `.admin`
- [ ] Co najmniej jedna domena skonfigurowana
- [ ] DNS skonfigurowany (MX, SPF, DKIM, DMARC)
- [ ] Propagacja DNS zweryfikowana
- [ ] Test wysłania/odbierania maili
- [ ] Backup skonfigurowany
- [ ] Firewall skonfigurowany
- [ ] Monitoring skonfigurowany

---

**Ostatnia aktualizacja:** 2026-01-21  
**Autor:** automation assistant  
**Wersja:** 1.0.0
