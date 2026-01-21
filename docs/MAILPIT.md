# Mailpit - Przechwytywanie i testowanie emaili

## 📧 Czym jest Mailpit?

**Mailpit** to narzędzie do przechwytywania i testowania emaili w środowisku deweloperskim. Działa jako lokalny serwer SMTP, który przechwytuje wszystkie maile wysyłane przez aplikację i wyświetla je w przyjaznym interfejsie webowym.

### Główne zastosowania:

1. **Testowanie emaili w środowisku deweloperskim**
   - Wszystkie maile wysyłane przez Laravel są przechwytywane
   - Nie są wysyłane na prawdziwe adresy email
   - Możesz zobaczyć treść, HTML, załączniki bez wysyłania

2. **Debugowanie szablonów emaili**
   - Podgląd jak wyglądają maile w różnych przeglądarkach
   - Sprawdzanie czy HTML renderuje się poprawnie
   - Testowanie responsywności szablonów

3. **Testowanie funkcjonalności emailowych**
   - Rejestracja użytkowników (weryfikacja email)
   - Resetowanie hasła
   - Powiadomienia
   - Newsletter

4. **Bezpieczne testowanie**
   - Nie wysyłasz testowych emaili do prawdziwych użytkowników
   - Nie zużywasz limitów SMTP (np. OVH, SendGrid)
   - Nie płacisz za wysyłanie testowych emaili

## 🚀 Konfiguracja w projekcie

### 1. Mailpit w Docker Compose

Mailpit jest już skonfigurowany w `docker/docker-compose.dev.yml`:

```yaml
mailpit:
  image: axllent/mailpit:latest
  container_name: octadecimal_mailpit
  restart: unless-stopped
  ports:
    - "8025:8025"  # UI - interfejs webowy
    - "1025:1025"  # SMTP - port do wysyłania emaili
  networks:
    - octadecimal
```

### 2. Konfiguracja Laravel (.env)

Aby Laravel wysyłał maile przez Mailpit, zaktualizuj `src/.env`:

```env
# Mailpit Configuration (Development)
MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="noreply@octadecimal.studio"
MAIL_FROM_NAME="${APP_NAME}"
```

**Uwaga:** W kontenerze Docker, host to `mailpit` (nazwa serwisu), nie `localhost`!

### 3. Dostęp do interfejsu

Po uruchomieniu kontenerów, Mailpit UI jest dostępny pod:
- **http://localhost:8025**

## 🔄 Przekierowanie emaili z OVH

### ❌ NIE - Mailpit nie jest serwerem SMTP do produkcji

Mailpit **NIE** jest przeznaczony do:
- Odbierania emaili z zewnętrznych serwerów (OVH, Gmail, etc.)
- Przekierowywania emaili z kont OVH
- Działania jako serwer SMTP w produkcji

### ✅ TAK - Możesz użyć Mailpit do testowania emaili wysyłanych PRZEZ aplikację

Jeśli chcesz testować maile wysyłane przez Twoją aplikację Laravel:

1. **W środowisku deweloperskim:**
   - Skonfiguruj Laravel aby używał Mailpit (jak wyżej)
   - Wszystkie maile z aplikacji będą przechwytywane w Mailpit

2. **W środowisku produkcyjnym:**
   - Użyj prawdziwego serwera SMTP (OVH, SendGrid, Mailgun, etc.)
   - Skonfiguruj w `.env`:
   ```env
   MAIL_MAILER=smtp
   MAIL_HOST=smtp.ovh.net  # lub inny serwer SMTP OVH
   MAIL_PORT=587
   MAIL_USERNAME=sender@example.com
   MAIL_PASSWORD=twoje-haslo
   MAIL_ENCRYPTION=tls
   ```

### 🔀 Alternatywa: Przekierowanie emaili OVH do innego adresu

Jeśli chcesz przekierować maile przychodzące na konto OVH do innego adresu:

1. **W panelu OVH:**
   - Zaloguj się do panelu OVH
   - Przejdź do: Email → Przekierowania
   - Dodaj przekierowanie: `sender@example.com` → `recipient@example.com`

2. **To NIE wymaga Mailpit** - to funkcja OVH

## 📝 Przykłady użycia

### Testowanie emaila rejestracji

```php
// W kontrolerze lub tinker
use Illuminate\Support\Facades\Mail;
use App\Mail\WelcomeEmail;

Mail::to('test@example.com')->send(new WelcomeEmail());
```

Następnie sprawdź w Mailpit (http://localhost:8025) - email będzie tam widoczny!

### Testowanie w Tinker

```bash
docker compose -f docker/docker-compose.yml -f docker/docker-compose.dev.yml exec app php artisan tinker

# W tinker:
Mail::raw('Test email', function ($message) {
    $message->to('test@example.com')
            ->subject('Test');
});
```

## 🔍 Funkcje Mailpit

- **Przeglądarka emaili** - wszystkie przechwycone maile
- **Podgląd HTML** - jak wygląda email w przeglądarce
- **Podgląd tekstowy** - wersja tekstowa
- **Załączniki** - pobieranie załączników
- **Wyszukiwanie** - filtrowanie emaili
- **API** - dostęp przez API do automatyzacji testów

## ⚠️ Ważne uwagi

1. **Tylko dla developmentu** - Mailpit nie powinien być używany w produkcji
2. **Lokalne przechwytywanie** - działa tylko dla emaili wysyłanych przez aplikację w kontenerze
3. **Nie zastępuje prawdziwego SMTP** - w produkcji użyj OVH, SendGrid, Mailgun, etc.
4. **Automatyczne czyszczenie** - stare maile są automatycznie usuwane (domyślnie po 7 dniach)

## 🛠️ Rozwiązywanie problemów

### Maile nie pojawiają się w Mailpit

1. Sprawdź czy kontener działa:
   ```bash
   docker compose -f docker/docker-compose.yml -f docker/docker-compose.dev.yml ps mailpit
   ```

2. Sprawdź konfigurację `.env`:
   ```bash
   docker compose -f docker/docker-compose.yml -f docker/docker-compose.dev.yml exec app cat .env | grep MAIL_
   ```

3. Wyczyść cache konfiguracji:
   ```bash
   docker compose -f docker/docker-compose.yml -f docker/docker-compose.dev.yml exec app php artisan config:clear
   ```

4. Sprawdź logi:
   ```bash
   docker compose -f docker/docker-compose.yml -f docker/docker-compose.dev.yml logs mailpit
   ```

### Błąd połączenia z SMTP

- Upewnij się, że `MAIL_HOST=mailpit` (nazwa serwisu Docker, nie `localhost`)
- Sprawdź czy kontener `mailpit` jest w tej samej sieci Docker (`octadecimal`)

---

**Status:** Dokumentacja aktualna  
**Ostatnia aktualizacja:** 2026-01-21
