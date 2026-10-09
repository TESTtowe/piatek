# Krwawy Piątek — Zanim zadzwoni dzwonek

Projekt gry narracyjnej do Roblox Studio. Sześć rozdziałów, 19 zadań, pięć postaci, dialogi z wyborami, trzy epilogi, cztery zadania wykorzystujące trzy rodzaje minigier. Mapa powstaje automatycznie po uruchomieniu: dziedziniec, korytarz, sala, biblioteka, sekretariat i gabinet pedagoga.

Fabuła jest autorska. Kontekst opracowano na podstawie przeczytanych komunikatów Policji i MEN oraz relacji Polsat News i RMF24 z października 2026. Postacie i szkoła są fikcyjne. Wbudowane archiwum zawiera 20 wpisów z przypisanymi źródłami. „Krwawy Piątek” to tytuł gry, a nie potwierdzona nazwa jednej skoordynowanej akcji. [Ustalenia i źródła](docs/RESEARCH.md) wyjaśniają zakres przeglądu i brakujące informacje.

## Pobieranie z GitHuba

Na gałęzi `codex/roblox-friday` wybierz **Code → Download ZIP**, rozpakuj archiwum i otwórz plik **KrwawyPiatek.rbxl** z głównego katalogu w Roblox Studio. Plik jest również dostępny bezpośrednio w katalogu repozytorium.

## Otwieranie w Roblox Studio

1. Otwórz `KrwawyPiatek.rbxl` (lub wygenerowany `build/KrwawyPiatek.rbxl`) przez **File → Open from File**. Wersja tekstowa `build/KrwawyPiatek.rbxlx` też jest dostępna.
2. Wybierz **Play / F5**, nie samo **Run** — gra potrzebuje klienta gracza.
3. Zaczekaj na ekran tytułowy i wybierz pierwszy rozdział. Podejdź do Leny na dziedzińcu i użyj **E** albo podpowiedzi na ekranie.

Mapa, światło, postacie i interfejs tworzą się podczas **Play**, dlatego przed uruchomieniem edytor nie pokazuje gotowej mapy. Projekt nie potrzebuje Toolboxa, identyfikatorów cudzych assetów, tokenów ani włączonego HTTP. Otwarcie pliku w Studio nie wymaga Rojo.

## Praca nad kodem

Na przygotowanym środowisku Linux x86_64:

```bash
cd /workspace/piatek
python3 scripts/bootstrap.py
python3 scripts/check.py
```

Bootstrap pobiera Rojo **7.7.1** i Luau **0.741** z oficjalnych wydań przez HTTPS oraz sprawdza przypięte sumy SHA-256. Nie wyłącza weryfikacji TLS. Narzędzia zapisuje w ignorowanym `.tools/bin`, a pliki gry w `build/`. Nie zmienia źródeł.

Opcjonalna synchronizacja przy użyciu wtyczki Rojo w Studio:

```bash
.tools/bin/rojo serve default.project.json --address 127.0.0.1 --port 34872
```

Usługa została sprawdzona przez odczyt protokołu i drzewa instancji. Studio uruchomione na innym komputerze nie ma automatycznego połączenia z tą chmurą; pobierz projekt i uruchom lokalną wersję Rojo na swoim komputerze. Wtyczka oraz plik `.rbxl` to dwie alternatywne ścieżki pracy.

## Co jest zaimplementowane

- Autorska mapa o ograniczonym obszarze, meble, biblioteczne regały, stylizowane postacie, oznaczenia pomieszczeń, jesienny dziedziniec, oświetlenie i korekcja kolorów.
- Interfejs w kolorach atramentu, bursztynu i papieru: ekran tytułowy z kamerą, karta zadania, mapa, dystans, przejścia rozdziałów, przewijane dialogi i zeszyt.
- Kolejność zdarzeń, klasyfikacja źródeł i zapamiętywanie listy. Brak limitu błędów; widok listy pamięci zamyka sam gracz.
- Indywidualny postęp, dziennik rozmów, zmienne relacji wpływające na epilog, powtórka z potwierdzeniem i opcja ograniczenia ruchu UI/kamery.
- Kontrola serwerowa zadań: właściwy etap, odległość, token, ważność sesji minigry, poprawność odpowiedzi i ograniczenie częstotliwości żądań.
- Opcjonalny DataStore, domyślnie wyłączony. Stan sesji działa bez publikowania miejsca. Błąd odczytu nie nadpisuje poprzedniego zapisu.

## Walidacja i granice gotowości

`scripts/check.py` kompiluje wszystkie skrypty, analizuje moduły niezależne od silnika, uruchamia testy kampanii i walidatorów oraz buduje oba formaty miejsca. Sprawdza również mapowanie Script / LocalScript / ModuleScript.

Środowisko chmurowe nie zawiera Roblox Studio. Nie wykonano renderowania ani rozgrywki w silniku Roblox; nie potwierdzono zachowania na telefonie, kontrolerze ani rzeczywistego DataStore. Te kontrole są opisane w [liście testów Studio](docs/STUDIO_TESTS.md). To rozwijalna wersja robocza, nie deklaracja gotowości do publicznej premiery.

Nie ma nagrań aktorskich, muzyki, animacji twarzy ani zakupionych modeli. Styl graficzny opiera się na geometrii Roblox i własnym UI. Kod nie próbuje odtwarzać przebiegu ataku ani roli sprawcy.

## Struktura

| Plik / katalog | Przeznaczenie |
| --- | --- |
| `src/shared/Campaign.luau` | Rozdziały, dialogi, wybory i definicje minigier |
| `src/shared/FactBook.luau` | Zwięzłe ustalenia i adresy źródeł |
| `src/shared/Engine.luau` | Postęp, dziennik i epilogi |
| `src/shared/Rules.luau`, `Gate.luau` | Walidacja odpowiedzi, zapisów i aktywnych zadań |
| `src/shared/WorldData.luau` | Współrzędne i nazwy punktów interakcji |
| `src/server/World.luau` | Budowa mapy, postaci i podpowiedzi |
| `src/server/Server.server.luau` | Sesje graczy, remotes, postęp i opcjonalny zapis |
| `src/client/Client.client.luau`, `UI.luau` | Prezentacja, kamera, dialogi, minigry i UI |
| `tests/campaign.spec.luau` | Wykonywane testy domeny i walidacji |
| `scripts/research.py` | Pobieranie publicznych stron do dalszej weryfikacji |

Każde zadanie chmurowe ma izolowane środowisko. Używaj istniejącego checkoutu; nie twórz Git worktree bez wyraźnej prośby.
