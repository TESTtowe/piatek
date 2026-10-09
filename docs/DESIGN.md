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

Wersja 0.2.0 ma wspólny kierunek wizualny: grafitowe tło, papierowy kolor tekstu, typografię Oswald i czerwony akcent używany do tytułu, oznaczeń i wyborów. Menu pozostawia miejsce na kadr korytarza. Na telefonie nawigacja zajmuje dwie kolumny, a treść przewija się zamiast zmniejszać tekst do nieczytelnego rozmiaru.

Pierwsze wejście rozpoczyna osobne ostrzeżenie. Gracz potwierdza jego przeczytanie; wejście wymaga także stanu serwera i kompletnego świata. Potwierdzenie obowiązuje do końca sesji, również po odrodzeniu. Sekcja autorów korzysta z `Config.Credits`, bez dopisywania nieistniejącego zespołu.

Dialogi wykorzystują panel w dolnej części ekranu, portret z rzeczywistego modelu postaci i osobny kadr rozmówcy. Kamera wraca do sterowania gracza po zamknięciu rozmowy. Opcja ograniczenia ruchu wyłącza kołysanie i proceduralny ruch postaci. Oświetlenie korzysta z przeszklonego dachu, lamp, korekcji kolorów i subtelnych efektów postprocessingu.

Każda minigra ma własny sposób pracy: chronologia przenosi wybrane karty na początek i pokazuje pozycje; weryfikacja prezentuje jeden dokument i zachowuje odpowiedzi podczas cofania; lista pokazuje imiona przed wyborem na siatce. Udane rozwiązanie blokuje stare kontrolki i pozostawia powrót do opowieści. Podpowiedź interakcji zwalnia wirtualnie przytrzymany przycisk także wtedy, gdy obiekt znika.

Modele i otoczenie powstają z geometrii Roblox. Portrety nie są rysunkami zastępczymi. Kod nie zawiera nagrań, muzyki ani profesjonalnych animacji szkieletowych; dodanie ich wymaga własnych lub licencjonowanych materiałów. Podglądy w dokumentacji są projekcją układu GUI, nie renderem silnika.

Wersja nie rekonstruuje prawdziwego ataku od początku do końca: dostępne źródła nie ustalają całej historii ani związku wszystkich zdarzeń. Rozszerzenie o konkretny rzeczywisty przypadek wymaga osobnej osi czasu ze źródłem każdej sceny oraz oznaczenia dialogów i zdarzeń rekonstruowanych. Nie należy zmieniać niepotwierdzonego internetowego opisu w fakt tylko po to, żeby wypełnić lukę w fabule.
