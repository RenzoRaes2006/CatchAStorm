# Catch a Storm!

Een Roblox-game waarin je op weer jaagt, het vangt in potten en in je eigen weerlab munten laat verdienen.

## Snel spelen in Roblox Studio (zonder extra programma's)

1. Download `CatchAStorm.rbxlx` uit deze repository (klik op het bestand en dan op het download-icoon).
2. Dubbelklik het bestand, of open Roblox Studio en kies **File > Open from File**.
3. Druk op **Play** (F5). De wereld en je lab worden automatisch gebouwd.
4. Publiceer de game met **File > Publish to Roblox**.
5. Zet daarna in **Game Settings**:
   - **Security > Enable Studio Access to API Services** aan, anders wordt je voortgang in Studio niet opgeslagen.
   - **Places > Max Players** op **10** (er zijn 10 labs per server).

`CatchAStorm.rbxlx` wordt gemaakt uit de map `src/` met `python tools/build_place.py`. Pas dus de code in `src/` aan, niet de scripts in het bestand.

## Werken met Rojo (later, als we vaker updaten)

Met [Rojo](https://rojo.space) komt de code uit `src/` direct in Studio. Installeer de Rojo-plugin in Studio en de Rojo-tool op je computer, open deze map en start `rojo serve`. Klik daarna in Studio op **Connect** in de Rojo-plugin.

## Hoe de code in elkaar zit

| Bestand | Wat het doet |
| --- | --- |
| `src/shared/Config.luau` | Alle getallen: weertypes, kansen, prijzen, het rad en de speeltijd-beloningen |
| `src/server/Main.server.luau` | Startpunt van de server |
| `src/server/World.luau` | Bouwt de Groene Weide en de rij labs |
| `src/server/PlayerData.luau` | Laden en opslaan van voortgang, inkomen terwijl je weg was |
| `src/server/Lab.luau` | Je lab: planken, potten en inkomen per seconde |
| `src/server/Weather.luau` | Weer laten verschijnen, vangen en de serverstorm |
| `src/server/Shop.luau` | Netten en planken kopen met munten |
| `src/server/Rewards.luau` | Dagelijks rad en speeltijd-beloningen |
| `src/client/Main.client.luau` | Alle schermen: munten, winkel, rad, beloningen, meldingen |
