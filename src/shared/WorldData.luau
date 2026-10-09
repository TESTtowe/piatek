-- Wspólne współrzędne mapy i znaczników; moduł działa również poza silnikiem Roblox.
return {
    bounds = { x = 180, z = 190 },
    spawn = { 0, 4, 68 },
    targets = {
        Lena = { position = { -22, 3, 49 }, label = "Lena", role = "Koleżanka z klasy", npc = true, color = { 192, 132, 92 } },
        Marta = { position = { -7, 3, -18 }, label = "Pani Marta", role = "Wychowawczyni", npc = true, color = { 85, 123, 132 } },
        Olek = { position = { -53, 3, -16 }, label = "Olek", role = "Redakcja wystawy", npc = true, color = { 101, 125, 92 } },
        Dyrektor = { position = { 48, 3, -12 }, label = "Dyrektor Nowak", role = "Dyrekcja", npc = true, color = { 91, 99, 121 } },
        Pedagog = { position = { 47, 3, -48 }, label = "Pani Ewa", role = "Pedagog szkolny", npc = true, color = { 132, 107, 134 } },
        Tablica = { position = { -13, 4, 7 }, label = "Plan zajęć", object = "board" },
        Zeszyt = { position = { -62, 2.7, -39 }, label = "Zeszyt rozmów", object = "notebook" },
        Redakcja = { position = { -46, 2.7, -40 }, label = "Stanowisko redakcji", object = "desk" },
        Lista = { position = { 9, 2.7, -48 }, label = "Lista grupy", object = "notebook" },
        Koperta = { position = { 58, 2.7, -22 }, label = "Wiadomości dla opiekunów", object = "notebook" },
        Kartka = { position = { 43, 2.7, -55 }, label = "Wspólna kartka", object = "notebook" },
        Archiwum = { position = { -32, 2.7, -40 }, label = "Archiwum wystawy", object = "desk" },
    },
}
