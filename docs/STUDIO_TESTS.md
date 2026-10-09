# Testy w silniku Roblox

Poniższe testy nie zostały wykonane w chmurze. Wymagają Roblox Studio.

## Pierwsze uruchomienie

1. Otwórz wygenerowany `.rbxl`; uruchom **Play**.
2. Sprawdź Output po stronie serwera i klienta. Oczekiwany wynik: brak błędów w skryptach Friday.
3. Sprawdź kamerę menu, czytelność tytułu, przewijanie małego ekranu i przycisk rozpoczęcia.
4. Otwórz archiwum przed startem. Sprawdź komplet wpisów oraz oznaczenia źródeł i fikcyjnej fabuły.
5. Rozpocznij opowieść. Oczekiwane: sterowanie zostaje odblokowane, pojawia się znacznik Leny i podpowiedź E.

## Kampania

Przejdź wszystkie 19 zadań. Oczekiwane: dokładnie jeden wpis dziennika na zadanie, poprawne przejścia między sześcioma rozdziałami i epilog po ostatniej rozmowie.

W dialogu przeczytaj kolejne strony, wybierz odpowiedź, zamknij replikę i wróć do świata. Sprawdź, że podpowiedź następnego zadania włącza się bez potrzeby otwierania menu. Zamknięcie rozmowy przed wyborem pozwala rozpocząć ją ponownie i nie dodaje postępu.

Sprawdź wszystkie minigry: błędne odpowiedzi nie zmieniają postępu, poprawne przechodzą dalej. W zadaniu pamięci lista powinna pozostać widoczna po siedmiu sekundach, aż gracz sam kliknie „następna strona”. Zamknięcie minigry kasuje token; ponowna próba rozpoczyna nowe zadanie.

Otwórz i zamknij menu w trakcie gry. Sprawdź powrót kamery, prędkości ruchu i podpowiedzi. Zresetuj postać podczas rozmowy/minigry; oczekiwane: panel zamyka się, zadanie pozostaje, sterowanie wraca po odrodzeniu.

## Dwa klienty

W **Test → Server & Clients** uruchom serwer z dwoma klientami. Przejdź różne zadania i dokonaj różnych wyborów. Oczekiwane: dzienniki i znaczniki pozostają niezależne. Zmiana rozdziału jednego klienta nie zmienia czasu dnia drugiego. Restart historii jednego gracza nie resetuje drugiego.

## Ekrany i wejście

W Device Emulator sprawdź telefon w pionie 360×640, telefon poziomo i komputer 1920×1080. Dialogi, minigry oraz archiwum muszą dać się przewijać. Sterowanie ekranowe nie powinno zasłaniać aktywnej interakcji. Sprawdź fokus przycisków z kontrolera oraz systemową interakcję ButtonX i zamykanie panelu ButtonB.

Włącz ograniczenie ruchu. Oczekiwane: kamera menu przestaje kołysać się, zmiany UI i czasu dnia są natychmiastowe. Ukrycie znaczników nie powinno usuwać opisu bieżącego zadania.

## Opcjonalny zapis

Na własnym opublikowanym miejscu można włączyć `Config.PersistenceEnabled`. Do testu Studio należy skonfigurować **Enable Studio Access to API Services** dla tego miejsca. Użyj testowego magazynu danych, ponieważ Studio może korzystać z danych opublikowanej gry.

Przejdź kilka zadań, opuść grę, wróć i sprawdź punkt kontynuacji. Osobno sprawdź błąd odczytu: UI ma pokazać ostrzeżenie, sesja ma działać, a istniejący zapis nie może zostać nadpisany. Sprawdź również ukończoną kampanię i reset z potwierdzeniem.

Implementacja nie zawiera pełnej blokady sesji między różnymi serwerami. Przed publicznym wydaniem z trwałym zapisem należy przetestować szybkie ponowne dołączanie i rozwiązać konflikt zapisu z poprzedniego serwera.
