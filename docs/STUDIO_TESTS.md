# Testy w silniku Roblox

Poniższe testy nie zostały wykonane w chmurze. Wymagają Roblox Studio.

## Pierwsze uruchomienie

1. Otwórz wygenerowany `.rbxl`; uruchom **Play**.
2. Sprawdź Output po stronie serwera i klienta. Oczekiwany wynik: brak błędów w skryptach Friday.
3. Przed potwierdzeniem ostrzeżenia spróbuj przejść dalej. Oczekiwane: menu i ruch pozostają zablokowane. Odznaczenie pola ponownie blokuje przycisk wejścia; ładowanie świata również go blokuje.
4. Potwierdź ostrzeżenie i otwórz menu. Sprawdź tło korytarza, czytelność tytułu Bodoni, przewijanie małego ekranu, autorów i spis sześciu rozdziałów.
5. Otwórz archiwum przed startem. Sprawdź komplet wpisów oraz oznaczenia źródeł i fikcyjnej fabuły.
6. Rozpocznij opowieść. Oczekiwane: sterowanie zostaje odblokowane, pojawia się znacznik Leny i podpowiedź E.

## Grafika menu i 2K

1. W Device Emulator ustaw 2560×1440, potem 1920×1080, 1280×720, telefon pionowo i poziomo. Sprawdź tytuł, ostrzeżenie, przycisk startu i wszystkie elementy nawigacji.
2. Sprawdź, czy obraz `Photograph` powstaje z czterech fragmentów i nie ma przerw na ich łączeniach. `Friday background: using 3D scene` w Output oznacza uruchomienie wariantu 3D; zapisz dokładny komunikat API.
3. Otwórz i zamknij menu kilka razy. Liczba tworzonych `EditableImage` nie powinna rosnąć; po rozpoczęciu gry tło powinno zniknąć. Przy ponownym otwarciu wraca ten sam obraz.
4. Sprawdź przejście z ostrzeżenia do menu. Wielokrotne kliknięcie potwierdzenia nie może uruchomić kilku przejść. Ograniczenie ruchu pomija animację wygaszenia.
5. Na małym ekranie przewiń treść ostrzeżenia. Checkbox i przycisk pozostają w stałym miejscu; nie powinny zostać zasłonięte przez treść.
6. Sprawdź opublikowane doświadczenie z właściwym ustawieniem **Enable Mesh / Image APIs** oraz z niedostępnym API. W drugim wariancie musi działać kadr 3D i wejście do gry. Osobno sprawdź własny opublikowany obraz przez `Config.MenuImage`.

## Kampania

Przejdź wszystkie 19 zadań. Oczekiwane: dokładnie jeden wpis dziennika na zadanie, poprawne przejścia między sześcioma rozdziałami i epilog po ostatniej rozmowie.

W dialogu sprawdź portret, kadr właściwej postaci oraz panel w dolnej części ekranu. Przeczytaj kolejne strony, wybierz odpowiedź, zamknij replikę i wróć do świata. Sprawdź, że podpowiedź następnego zadania włącza się bez potrzeby otwierania menu. Zamknięcie rozmowy przed wyborem pozwala rozpocząć ją ponownie i nie dodaje postępu.

Sprawdź wszystkie minigry: błędne odpowiedzi nie zmieniają postępu, poprawne przechodzą dalej. Karty chronologii pokazują wybraną kolejność i pozwalają wycofać wybór. W dokumentach cofnięcie zachowuje klasyfikację. Po sukcesie kontrolki zadania są zablokowane, a przycisk powrotu pozostaje widoczny. W zadaniu pamięci lista powinna pozostać widoczna po siedmiu sekundach, aż gracz sam kliknie „następna strona”. Zamknięcie minigry kasuje token; ponowna próba rozpoczyna nowe zadanie.

Otwórz i zamknij menu w trakcie gry. Sprawdź powrót kamery, prędkości ruchu i podpowiedzi. Zresetuj postać podczas rozmowy/minigry; oczekiwane: panel zamyka się, zadanie pozostaje, sterowanie wraca po odrodzeniu.

## Otoczenie i wydajność

Sprawdź korytarz, świetlik, szafki, okna i wszystkie pomieszczenia na ustawieniach grafiki niskich i wysokich. Wejścia muszą pozostać przechodnie; elementy ozdobne nie powinny blokować dotarcia do żadnego zadania. Portrety postaci powinny pokazywać twarz i akcesoria. Kamera rozmowy nie powinna wejść w ścianę.

Sprawdź drobny ruch postaci oraz ich obrót w stronę gracza. Ograniczenie ruchu zatrzymuje go. Na słabszym urządzeniu sprawdź liczbę klatek i czas ładowania; podgląd HTML nie mierzy wydajności Roblox.

## Dwa klienty

W **Test → Server & Clients** uruchom serwer z dwoma klientami. Przejdź różne zadania i dokonaj różnych wyborów. Oczekiwane: dzienniki i znaczniki pozostają niezależne. Zmiana rozdziału jednego klienta nie zmienia czasu dnia drugiego. Restart historii jednego gracza nie resetuje drugiego.

## Ekrany i wejście

W Device Emulator sprawdź telefon w pionie 360×640, telefon poziomo, komputer 1920×1080 oraz 2560×1440. Dialogi, minigry oraz archiwum muszą dać się przewijać. Sterowanie ekranowe nie powinno zasłaniać aktywnej interakcji. Sprawdź własną podpowiedź na dotyk: przytrzymanie musi zostać zwolnione, gdy podpowiedź znika lub otwiera się rozmowa. Systemowe przyciski Roblox i obszar wycięcia ekranu nie powinny zasłaniać treści. Sprawdź fokus przycisków z kontrolera oraz systemową interakcję ButtonX i zamykanie panelu ButtonB.

Włącz ograniczenie ruchu. Oczekiwane: kamera menu przestaje kołysać się, zmiany UI i czasu dnia są natychmiastowe. Ukrycie znaczników nie powinno usuwać opisu bieżącego zadania.

## Opcjonalny zapis

Na własnym opublikowanym miejscu można włączyć `Config.PersistenceEnabled`. Do testu Studio należy skonfigurować **Enable Studio Access to API Services** dla tego miejsca. Użyj testowego magazynu danych, ponieważ Studio może korzystać z danych opublikowanej gry.

Przejdź kilka zadań, opuść grę, wróć i sprawdź punkt kontynuacji. Osobno sprawdź błąd odczytu: UI ma pokazać ostrzeżenie, sesja ma działać, a istniejący zapis nie może zostać nadpisany. Sprawdź również ukończoną kampanię i reset z potwierdzeniem.

Implementacja nie zawiera pełnej blokady sesji między różnymi serwerami. Przed publicznym wydaniem z trwałym zapisem należy przetestować szybkie ponowne dołączanie i rozwiązać konflikt zapisu z poprzedniego serwera.
