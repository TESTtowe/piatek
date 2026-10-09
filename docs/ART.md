# Grafika ekranu wejścia — wersja 0.3.0

Interfejs jest projektowany pod **2560×1440**. Tekst, ikony, ramki i przyciski są natywnymi elementami Roblox GUI; `UIScale` dopasowuje je do rozdzielczości. W rozgrywce także HUD i panele rozmów zwiększają skalę na ekranie 1440p. Rozdzielczość UI nie jest deklaracją rozdzielczości wszystkich tekstur lub fotorealizmu modeli postaci.

Tło `assets/menu-corridor.png` jest grafiką koncepcyjną wygenerowaną dla projektu. Przedstawia fikcyjny korytarz, nie prawdziwą szkołę ani miejsce ataku. Plik źródłowy ma **1672×941**; nie podwyższono sztucznie jego rozdzielczości. Podgląd ekranu jest renderowany w 2560×1440, a tło wypełnia obszar z zachowaniem proporcji.

## Obraz zapisany w pliku gry

`MenuArt.luau` zawiera cztery fragmenty RGBA, kompresowane bezstratnie Zstandard i zapisane jako Base64. Każdy fragment mieści się w limicie 1024×1024 dla `EditableImage`. `ArtBackground.luau` odczytuje dane przez `EncodingService`, tworzy obrazy, wiąże je z `ImageLabel.ImageContent` i składa całe tło. Jeden zestaw obrazów obsługuje menu i ostrzeżenie. Nie są potrzebne HTTP, klucz API ani nieudokumentowane identyfikatory cudzych assetów.

Pełne dane pikselowe zajmują **6 293 408 bajtów**. Dekodowanie odbywa się fragmentami, a zapisy są rozłożone na klatki. Błąd tworzenia obrazu, limit pamięci lub brak dostępu do API usuwa także obrazy utworzone przed błędem. Gra przełącza się na osobny korytarz 3D `MenuSet`; nie blokuje to potwierdzenia ostrzeżenia ani startu.

Kod API sprawdzono względem dokumentacji Roblox, a cykl życia wykonano na adapterze z symulowanymi błędami. **Nie uruchomiono tego w silniku Roblox.** Pierwszy test w Studio musi sprawdzić dekodowanie, łączenia fragmentów i zachowanie pamięci.

## Publikowanie

Roblox domyślnie ogranicza `EditableImage` w opublikowanych doświadczeniach. Właściciel musi spełniać wymagania weryfikacji konta podane przez Roblox i włączyć **Enable Mesh / Image APIs** w Creator Dashboard. Tego ustawienia konta nie można zmienić w pliku `.rbxl` ani w tej chmurze.

Alternatywnie zaimportuj `assets/menu-corridor.png` jako własny obraz w Asset Manager, a w `src/shared/Config.luau` ustaw:

```lua
MenuImage = "rbxassetid://TWOJ_ID_OBRAZU",
```

Ten wariant używa zwykłego `ImageLabel`, sprawdza pobranie przez `ContentProvider` i pomija tworzenie `EditableImage`. Asset musi być dostępny dla właściciela doświadczenia. Błąd pobrania również włącza kadr 3D. Bez konfiguracji opublikowana gra może wyświetlać ten kadr zamiast grafiki koncepcyjnej.

## Weryfikacja i ponowne pakowanie

`python3 scripts/check.py` sprawdza podpis pliku PNG, jego wymiary, sumy SHA-256, rozmiary i pokrycie fragmentów oraz cykl życia grafiki na adapterze. Jeżeli dostępne są Pillow i zstandard, porównuje każdy odtworzony piksel z plikiem źródłowym. Brak tych opcjonalnych zależności jest raportowany jako niewykonane porównanie pikseli; podstawowy build nie wymaga ich instalowania.

Po zmianie pliku źródłowego: `python3 scripts/pack_art.py`. Ten krok wymaga Pillow i zstandard. Pakowanie nie zmienia wyglądu, kolorów ani rozdzielczości grafiki. Przeglądarkowy podgląd UI wymaga dodatkowo Playwright, Chromium i lokalnego fontu Bodoni; font nie jest dołączany do gry.

Dokumentacja API:

- [EditableImage: ograniczenia, pamięć i publikowanie](https://create.roblox.com/docs/reference/engine/classes/EditableImage)
- [AssetService: tworzenie obrazów](https://create.roblox.com/docs/reference/engine/classes/AssetService)
- [EncodingService: Base64 i kompresja](https://create.roblox.com/docs/reference/engine/classes/EncodingService)
- [CompressionAlgorithm: Zstd](https://create.roblox.com/docs/reference/engine/enums/CompressionAlgorithm)
