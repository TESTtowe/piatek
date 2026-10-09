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

Paleta UI: ciemny atrament, zgaszony turkus, papier i bursztyn. Świat: jesienne kolory, prosta geometria i ciepłe oświetlenie wnętrz. Wszystkie widoczne elementy działają bez cudzych assetów. Docelowe modele, animacje i dźwięki można dodać po ustaleniu stylu i licencji.

Wersja nie rekonstruuje prawdziwego ataku od początku do końca: dostępne źródła nie ustalają całej historii ani związku wszystkich zdarzeń. Rozszerzenie o konkretny rzeczywisty przypadek wymaga osobnej osi czasu ze źródłem każdej sceny oraz oznaczenia dialogów i zdarzeń rekonstruowanych. Nie należy zmieniać niepotwierdzonego internetowego opisu w fakt tylko po to, żeby wypełnić lukę w fabule.
