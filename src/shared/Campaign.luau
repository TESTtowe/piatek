-- Ten plik zawiera fikcję autorską. Nie jest rekonstrukcją prawdziwego ataku.
local function choice(id, label, reply, score)
    return { id = id, label = label, reply = reply, score = score or {} }
end

local function talk(id, target, title, speaker, lines, choices, entry)
    return { id = id, target = target, title = title, kind = "dialogue", speaker = speaker,
        lines = lines, choices = choices, journal = entry }
end

local function taskStep(id, target, title, kind, puzzle, entry)
    return { id = id, target = target, title = title, kind = kind, puzzle = puzzle, journal = entry }
end

return {
    chapters = {
        {
            id = "morning", title = "Zwyczajny piątek", time = "08:05", clock = 8.1,
            subtitle = "Nie wiesz jeszcze, które rozmowy zapamiętasz.",
            objectives = {
                talk("meet_lena", "Lena", "Spotkaj Lenę na dziedzińcu", "Lena", {
                    "Myślałam, że dziś nie przyjdziesz. Cała klasa szykuje wystawę, a nasza tablica nadal wygląda jak po przeprowadzce.",
                    "Mam zdjęcia. Olek ma opisy. Ty masz podobno talent do ogarniania chaosu. Pomożesz nam przed pierwszą lekcją?",
                }, {
                    choice("together", "Zrobimy to razem. Od czego zaczynamy?", "Od planu na tablicy. Potem znajdź panią Martę. I dzięki, że pytasz.", { empathy = 1 }),
                    choice("organize", "Ułóżmy plan, żeby niczego nie zgubić.", "Właśnie dlatego na ciebie czekałam. Lista zajęć jest przy wejściu.", { clarity = 1 }),
                }, "Lena przygotowuje klasową wystawę. Umawiamy się, że każdy dołoży swoją część."),
                taskStep("schedule", "Tablica", "Ułóż poranny plan na tablicy", "puzzle", "schedule", "Poranny plan uporządkowany. Z pozoru drobiazg, ale wszyscy wiedzą, co robić."),
                talk("teacher_morning", "Marta", "Porozmawiaj z wychowawczynią", "Pani Marta", {
                    "Wystawa ma opowiadać o naszej dzielnicy. O zwykłych ludziach, nie tylko o wielkich wydarzeniach.",
                    "Przygotowałam zeszyt do zapisywania rozmów. Leży w bibliotece. Nie musisz zapisywać wszystkiego; wybierz to, co naprawdę usłyszysz.",
                }, {
                    choice("listen", "Chcę najpierw wysłuchać innych.", "Dobre historie zaczynają się od słuchania. Olek czeka przy regale.", { empathy = 1 }),
                    choice("sources", "Dopiszę, skąd pochodzi każda informacja.", "To dobry nawyk. Oddzielaj własne wrażenia od tego, co da się sprawdzić.", { clarity = 1 }),
                }, "Pani Marta prosi o zebranie małych historii. Każda ma mieć swojego autora."),
                taskStep("notebook", "Zeszyt", "Odbierz zeszyt z biblioteki", "collect", nil, "W zeszycie zostaje miejsce na fakty, pytania i cudze słowa."),
            },
        },
        {
            id = "noise", title = "Wiadomość bez autora", time = "09:20", clock = 9.3,
            subtitle = "Ekran pokazuje pewność. Rozmowa pokazuje wątpliwości.",
            objectives = {
                talk("olek_rumor", "Olek", "Sprawdź, co martwi Olka", "Olek", {
                    "Ktoś przesłał zrzut ekranu. Nie ma daty ani nazwy szkoły. Podpis brzmi: «wszyscy już wiedzą». Ja nie wiem nawet, kto to napisał.",
                    "Nie chcę przestraszyć Leny. Ale jeśli przemilczę coś ważnego? Co mam jej powiedzieć?",
                }, {
                    choice("verify", "Najpierw sprawdźmy, co wiadomo naprawdę.", "Dobrze. Na stanowisku redakcyjnym mamy oryginały i kopie. Porównajmy je.", { clarity = 2 }),
                    choice("support", "Powiedz jej, że sprawdzamy to razem.", "To brzmi uczciwie. Nie obiecuję, że wszystko wiem, ale nie zostawiam jej samej.", { empathy = 2 }),
                }, "Olek otrzymał wiadomość bez daty i autora. Jej treść nie jest potwierdzonym faktem."),
                taskStep("verify_message", "Redakcja", "Oddziel fakty od niepotwierdzonych twierdzeń", "puzzle", "sources", "Rozdzielono oryginalne dokumenty od opinii i niepotwierdzonych wiadomości."),
                talk("marta_rumor", "Marta", "Przekaż wychowawczyni swoje ustalenia", "Pani Marta", {
                    "Dziękuję, że przyszliście. Zgłoszenie przekazuję dyrekcji. Nie musicie sami rozstrzygać, co oznacza.",
                    "Teraz zróbmy miejsce na spokojną rozmowę. Co, waszym zdaniem, powinni usłyszeć pozostali?",
                }, {
                    choice("honest", "Co wiemy, czego nie wiemy i kto to sprawdza.", "Tak właśnie sformułuję wiadomość. Nie dopisujemy domysłów.", { clarity = 1 }),
                    choice("kind", "Że mogą przyjść do pani z pytaniami.", "Powiem to wprost. Nie każdy potrzebuje mówić przy całej klasie.", { empathy = 1 }),
                }, "Wychowawczyni przyjęła zgłoszenie. Weryfikacja należy do dorosłych; nie prowadzimy własnego śledztwa."),
            },
        },
        {
            id = "pause", title = "Przerwany dzień", time = "11:45", clock = 11.75,
            subtitle = "Plan przestaje pasować. Ludzie nadal są obok.",
            objectives = {
                talk("director", "Dyrektor", "Wysłuchaj komunikatu dyrektora", "Dyrektor Nowak", {
                    "Zajęcia zostają dziś przerwane. Dorośli zajmują się organizacją dalszej części dnia. Nie będziemy powtarzać nagrań ani niesprawdzonych wiadomości.",
                    "Pani Marta zostaje z waszą grupą. Informacje dla opiekunów przekaże sekretariat. Rozumiem, że trudno teraz spokojnie czekać.",
                    "Jeżeli czegoś nie wiecie, pytajcie. Możemy nie mieć od razu odpowiedzi, ale nie zostawimy was z pytaniami samych.",
                }, {
                    choice("stay", "Zostanę z grupą i pomogę pani Marcie.", "Dziękuję. Zapytaj Lenę, czy chce teraz porozmawiać.", { community = 1 }),
                    choice("ask", "Gdzie znajdziemy kolejne potwierdzone informacje?", "Pani Marta przekaże komunikat, gdy będzie gotowy. Nie musicie szukać go w plotkach.", { clarity = 1 }),
                }, "Zajęcia przerwano. Szczegóły zdarzenia pozostają poza sceną; nie przypisujemy tego fikcyjnego komunikatu rzeczywistej szkole."),
                talk("lena_pause", "Lena", "Usiądź na chwilę z Leną", "Lena", {
                    "Rano martwiłam się tylko o zdjęcia. Teraz nawet nie umiem dokończyć zdania.",
                    "Wszyscy pytają, czy wszystko dobrze. Nie chcę mówić, że dobrze, jeśli tak nie jest. Możesz po prostu zostać obok?",
                }, {
                    choice("quiet", "Mogę. Nie musisz teraz nic mówić.", "Dzięki. Posiedźmy chwilę. Potem zapytam panią Martę o moją mamę.", { empathy = 2 }),
                    choice("adult", "Zostanę. Możemy też poprosić panią Martę.", "Chciałabym, żeby przyszła. Nie chcę odpowiadać na pytania sama.", { empathy = 1, community = 1 }),
                }, "Lena nie potrzebuje gotowej odpowiedzi. Potrzebuje obecności i możliwości rozmowy z dorosłym."),
                taskStep("attendance", "Lista", "Sprawdź listę grupy z panią Martą", "puzzle", "attendance", "Zestawiono listę fikcyjnej grupy. To zadanie narracyjne, a nie instrukcja postępowania w zagrożeniu."),
                taskStep("envelope", "Koperta", "Odbierz przygotowane wiadomości dla opiekunów", "collect", nil, "Sekretariat przygotował wiadomości dla opiekunów. Nie zawierają danych prawdziwych osób."),
            },
        },
        {
            id = "afternoon", title = "Słowa, które zostają", time = "14:10", clock = 14.1,
            subtitle = "Powrót do rozmowy nie oznacza powrotu do zwyczajności.",
            objectives = {
                talk("counselor", "Pedagog", "Porozmawiaj z pedagogiem", "Pani Ewa", {
                    "Nie musisz od razu umieć opowiedzieć o swoim dniu. Możesz zacząć od czegoś małego: kto był obok, co usłyszałeś, czego potrzebujesz.",
                    "Różnie reagujemy na trudne wiadomości. Nie porównuj swojej reakcji z cudzą. Jeśli chcesz, jutro też będzie miejsce na tę rozmowę.",
                }, {
                    choice("friends", "Chcę wiedzieć, jak odezwać się do przyjaciół.", "Zapytaj, czy mają ochotę rozmawiać. Nie naciskaj. Możesz też zaproponować wspólne spokojne zajęcie.", { empathy = 1 }),
                    choice("myself", "Potrzebuję chwili dla siebie.", "Możesz ją mieć. Ustalmy z panią Martą, gdzie będziesz. Nie musisz być pomocnikiem przez cały czas.", { community = 1 }),
                }, "Rozmowa z pedagogiem nie wymaga gotowej relacji. Można poprosić o czas i wsparcie."),
                talk("olek_apology", "Olek", "Wróć do Olka przy regale", "Olek", {
                    "Przesłałem tamten zrzut jednej osobie. Potem zobaczyłem, że ktoś dopisał do niego inne miasto. Chciałem pomóc, a tylko dołożyłem szumu.",
                    "Nie cofnę wiadomości z czyjejś pamięci. Mogę jednak napisać, że nie była sprawdzona. Pomożesz mi dobrać słowa?",
                }, {
                    choice("correction", "Napisz wprost, co przesłałeś i czego nie potwierdziłeś.", "Bez tłumaczenia się i bez nowych domysłów. Tak zrobię.", { clarity = 2 }),
                    choice("care", "Dodaj, że rozumiesz, jeśli ktoś się przestraszył.", "Masz rację. Powinienem też pomyśleć o osobie, która to dostała.", { empathy = 2 }),
                }, "Olek postanawia sprostować niepotwierdzoną wiadomość i uznać jej wpływ na innych."),
                taskStep("note", "Kartka", "Zostaw w zeszycie krótką wiadomość dla klasy", "collect", nil, "Wspólna kartka: «Nie musimy mieć wszystkich odpowiedzi, żeby się słuchać»."),
            },
        },
        {
            id = "archive", title = "Między faktem a pamięcią", time = "16:30", clock = 16.5,
            subtitle = "Nie każda luka w historii powinna zostać wypełniona domysłem.",
            objectives = {
                talk("archive_teacher", "Marta", "Ustal zasady szkolnego archiwum", "Pani Marta", {
                    "Zeszyt nie jest dowodem w sprawie. To zapis tego, co sami usłyszeliśmy. Nie wpisujemy cudzych nazwisk ani szczegółów, których nie znamy.",
                    "Do prawdziwej historii potrzebne są źródła, daty i jasne oznaczenie tego, co zostało zrekonstruowane. Bez nich uczciwiej zostawić puste miejsce.",
                }, {
                    choice("boundary", "Oddzielmy wydarzenia od naszych wspomnień.", "Powstaną dwie kolumny: zapis i interpretacja. Obie mają sens, ale nie są tym samym.", { clarity = 1 }),
                    choice("consent", "Zapytajmy każdego, czy chce zostawić swoją wypowiedź.", "Własna historia należy do osoby, która ją opowiada. Nie zbieramy jej za wszelką cenę.", { empathy = 1 }),
                }, "Archiwum odróżnia zapis od interpretacji. Wypowiedzi zbieramy za zgodą postaci."),
                taskStep("timeline", "Archiwum", "Uporządkuj zapis fikcyjnego dnia", "puzzle", "timeline", "Oś czasu uporządkowana. Puste miejsca pozostają oznaczone jako niewiadome."),
                talk("lena_archive", "Lena", "Zapytaj Lenę o jej zdjęcie", "Lena", {
                    "To zdjęcie zrobiłam rano, zanim cokolwiek się zmieniło. Jest na nim pusta ławka i światło między drzewami.",
                    "Nie chcę, żeby ktoś dopisał do niego cudzą historię. Może zostać po prostu zdjęciem naszego poranka?",
                }, {
                    choice("respect", "Tak. Podpis zostawimy taki, jaki wybierzesz.", "Napisz: «Poranek. Dziedziniec». Tyle mi wystarczy.", { empathy = 1 }),
                    choice("ask_photo", "Może wolisz na razie zachować je dla siebie?", "Na wystawie może zostać. Dzięki, że zapytałeś, zanim je zabrałeś.", { community = 1 }),
                }, "Lena wybrała podpis do własnego zdjęcia: «Poranek. Dziedziniec»."),
            },
        },
        {
            id = "tomorrow", title = "Miejsce na jutro", time = "17:40", clock = 17.7,
            subtitle = "Historia kończy się pytaniem o to, co zabierzesz dalej.",
            objectives = {
                talk("final_olek", "Olek", "Dokończ rozmowę z Olkiem", "Olek", {
                    "Plan na tablicy miał tylko trzy punkty. Żaden nie mówił o tym, jak wygląda dzisiejszy wieczór.",
                    "Zostawiamy wystawę niedokończoną. Chyba po raz pierwszy nie wydaje mi się to porażką. Co chcesz dopisać na ostatniej stronie?",
                }, {
                    choice("people", "Najpierw ludzie, potem opowieść.", "Zapiszę to przy pustej stronie. Może właśnie ona będzie najważniejsza.", { empathy = 2 }),
                    choice("truth", "Nie wiem — też może być uczciwą odpowiedzią.", "Tak. Następnym razem zacznę od tego, zanim nacisnę «prześlij».", { clarity = 2 }),
                    choice("tomorrow", "Jutro zrobimy miejsce dla kolejnych głosów.", "I nie będziemy nikogo pospieszać. Umowa.", { community = 2 }),
                }, "Ostatnia strona pozostaje otwarta. Zapisujemy zasadę, z którą chcemy wrócić jutro."),
                talk("final_lena", "Lena", "Pożegnaj się na dziedzińcu", "Lena", {
                    "Rano pytałam, czy pomożesz ogarnąć chaos. Nie wiedziałam, że to pytanie będzie dziś tyle razy wracać.",
                    "Dziękuję za rozmowy. Za te, które skończyliśmy, i za te, których nie trzeba było kończyć. Do zobaczenia.",
                }, {
                    choice("goodbye", "Do zobaczenia, Lena.", "W zeszycie nadal zostało dużo miejsca.", { community = 1 }),
                }, "Piątek się kończy. Relacje i pytania pozostają."),
            },
        },
    },
    puzzles = {
        schedule = { kind = "order", title = "Plan poranka", description = "Ustaw zajęcia od najwcześniejszego do najpóźniejszego. Klikaj karty w wybranej kolejności.",
            cards = { { id = "lesson", text = "09:00 · Pierwsza lekcja" }, { id = "exhibition", text = "08:35 · Przygotowanie wystawy" }, { id = "meeting", text = "08:15 · Spotkanie klasy" } },
            solution = { "meeting", "exhibition", "lesson" } },
        sources = { kind = "classify", title = "Co da się sprawdzić?", description = "Każdą kartę przypisz do kategorii. Te dokumenty i wiadomości należą wyłącznie do fikcyjnego scenariusza.",
            cards = {
                { id = "notice", text = "Komunikat szkoły · data i autor widoczni · oryginał", answer = "verified" },
                { id = "screenshot", text = "Zrzut ekranu · brak daty · nieznany autor", answer = "unknown" },
                { id = "feeling", text = "«Mam wrażenie, że nikt nic nie mówi» · osobista wypowiedź", answer = "opinion" },
                { id = "schedule", text = "Plan zajęć · dokument szkoły · data widoczna", answer = "verified" },
            }, categories = { { id = "verified", label = "Weryfikowalny zapis" }, { id = "unknown", label = "Brak potwierdzenia" }, { id = "opinion", label = "Opinia / odczucie" } } },
        attendance = { kind = "memory", title = "Lista naszej grupy", description = "Zapamiętaj trzy imiona wyróżnione na liście, a potem zaznacz je na kolejnej stronie.",
            cards = { { id = "lena", text = "Lena" }, { id = "olek", text = "Olek" }, { id = "maja", text = "Maja" }, { id = "adam", text = "Adam" }, { id = "iga", text = "Iga" }, { id = "tomek", text = "Tomek" } },
            count = 3 },
        timeline = { kind = "order", title = "Zapis dnia", description = "Zbuduj chronologię z wpisów w zeszycie. Nie dopisuj zdarzeń, których nie ma w zapisach.",
            cards = { { id = "support", text = "14:10 · Rozmowa z pedagogiem" }, { id = "pause", text = "11:45 · Komunikat dyrektora" }, { id = "morning", text = "08:05 · Spotkanie na dziedzińcu" }, { id = "rumor", text = "09:20 · Wiadomość bez autora" }, { id = "archive", text = "16:30 · Porządkowanie archiwum" } },
            solution = { "morning", "rumor", "pause", "support", "archive" } },
    },
}
