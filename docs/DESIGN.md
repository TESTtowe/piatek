# Założenia i rozwój

Gracz poznaje fikcyjną klasę w czasie zwykłego poranka. Zmiana dnia pojawia się przez rozmowy, nie przez rekonstrukcję przemocy. Pierwsze zadania budują relacje, kolejne dotyczą wiarygodności informacji, obecności przy innych i zbierania wspomnień za zgodą postaci. Zakończenie wynika z akcentów w wyborach: obecności, uczciwych słów albo wspólnego jutra.

| Rozdział | Zadania | Funkcja |
| --- | --- | --- |
| Zwyczajny piątek | Lena, plan, wychowawczyni, zeszyt | Poznanie miejsca i postaci |
| Wiadomość bez autora | Olek, klasyfikacja, rozmowa z Martą | Informacja a domysł |
| Przerwany dzień | Dyrektor, Lena, lista, wiadomości | Zmiana rytmu i wsparcie |
| Słowa, które zostają | Pedagog, Olek, kartka | Uznanie potrzeb i sprostowanie |
| Między faktem a pamięcią | Marta, chronologia, Lena | Granice własnej relacji |
| Miejsce na jutro | Olek, Lena, epilog | Domknięcie relacji |

Świat ma wspólną geometrię, ale fabuła i prezentacja światła są indywidualne. Serwer kontroluje postęp, a klient wyświetla panel. Każda rozmowa lub minigra otrzymuje token powiązany z konkretnym zadaniem. Odpowiedź bez tokena, z innego zadania, z dużej odległości lub po wygaśnięciu nie może dopisać postępu. Klient nie wysyła samodzielnego polecenia „ukończ zadanie”.

Minigry nie są mechanizmem zabezpieczającym przed graczem czytającym moduły w ReplicatedStorage. Ich definicje są jawne. Walidacja zapobiega nieprawidłowym przejściom i żądaniom, ale nie jest ogólnym systemem antycheat. Projekt nie ma konkurencyjnego rankingu ani nagrody ekonomicznej za rozwiązania.

Wersja 0.3.0 wykorzystuje realistyczną grafikę fikcyjnego korytarza, granatowe powierzchnie, ciepły złoty akcent i tytuł Bodoni. Ikony są rysowane z elementów GUI. Ekrany wejścia mają kompozycję dla 2560×1440; `UIScale` zwiększa także HUD oraz panele rozgrywki na większym ekranie. Na telefonie nawigacja zajmuje dwie kolumny, a treść przewija się zamiast zmniejszać tekst.

Pierwsze wejście rozpoczyna osobne ostrzeżenie. Treść przewija się wewnątrz karty, natomiast checkbox i przycisk pozostają na dole. Potwierdzenie obowiązuje do końca sesji, również po odrodzeniu. Wejście wymaga stanu serwera, kompletnego świata i gotowości grafiki lub wariantu 3D. Sekcja autorów korzysta z `Config.Credits`, bez dopisywania nieistniejącego zespołu.

Obraz powstaje z czterech osadzonych fragmentów RGBA. Powtórne otwieranie menu korzysta z tego samego zestawu, zamiast tworzyć kolejne obrazy. Błąd po częściowej alokacji zwalnia wszystkie utworzone obrazy. Oddzielny korytarz 3D służy do kadru menu, jeśli obraz jest niedostępny. [Dokumentacja grafiki](ART.md) opisuje rozdzielczość źródłową i wymagania publikowania Roblox.

Dialogi wykorzystują panel w dolnej części ekranu, portret z modelu postaci i osobny kadr rozmówcy. Kamera wraca do sterowania gracza po zamknięciu rozmowy. Opcja ograniczenia ruchu wyłącza kołysanie i proceduralny ruch postaci. Mapa ma oświetlenie Future, przeszklony dach, lampy, korekcję kolorów i subtelne efekty postprocessingu.

Każda minigra ma własny sposób pracy: chronologia przenosi wybrane karty na początek i pokazuje pozycje; weryfikacja prezentuje jeden dokument i zachowuje odpowiedzi podczas cofania; lista pokazuje imiona przed wyborem na siatce. Udane rozwiązanie blokuje stare kontrolki i pozostawia powrót do opowieści. Podpowiedź interakcji zwalnia wirtualnie przytrzymany przycisk także wtedy, gdy obiekt znika.

Modele i otoczenie powstają z geometrii Roblox. Realistyczna grafika menu nie oznacza fotorealistycznych modeli w rozgrywce. Kod nie zawiera nagrań, muzyki ani profesjonalnych animacji szkieletowych; dodanie ich wymaga własnych lub licencjonowanych materiałów. Podglądy w dokumentacji są projekcją rzeczywistego GUI, nie renderem silnika.

Wersja nie rekonstruuje prawdziwego ataku od początku do końca: dostępne źródła nie ustalają całej historii ani związku wszystkich zdarzeń. Rozszerzenie o konkretny rzeczywisty przypadek wymaga osobnej osi czasu ze źródłem każdej sceny oraz oznaczenia dialogów i zdarzeń rekonstruowanych. Nie należy zmieniać niepotwierdzonego internetowego opisu w fakt tylko po to, żeby wypełnić lukę w fabule.
