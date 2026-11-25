# Vexmon Pack (`vexmon-pack`)

Manifest del modpack client Vexmon: mod, config e file che il launcher scarica.

## Cosa fa

La repo contiene tre manifest JSON del modpack client. Il launcher `vexmon-launcher` li legge e scarica mod e file di config. Ogni mod ha URL Modrinth e hash SHA512. I file di config sono serviti da `raw.githubusercontent.com` dal branch `main`.

## Stato

| | |
|---|---|
| Versione | `1.0.14` (`modpackVersion`) |
| Usato da | [`vexmon-launcher`](https://github.com/vexmon/vexmon-launcher) |
| Cobblemon nel pack | `1.7.3+1.21.1` |

Topic: `resource-pack`.

## Origine

Interna.

## Stack

- Manifest JSON letti dal launcher.
- Script Bash con Python 3 per aggiungere mod e fare le release.
- Minecraft 1.21.1, Fabric, Fabric API `0.116.9+1.21.1`.

## Contenuto

| File | Cosa contiene |
|---|---|
| `modpack.json` | Profilo normale |
| `modpack-light.json` | Profilo leggero, aggiunge `config/sodium-options.json` |
| `modpack-pro.json` | Profilo pro, aggiunge Iris Shaders, `config/iris.properties` e lo shader Complementary Reimagined |
| `files/config/` | Config comuni delle mod client |
| `files/normal/`, `files/light/`, `files/pro/` | `options.txt` e config di ogni profilo |
| `files/mods/` | Jar non presenti su Modrinth: `ranked_hub`, `vexmon-aprijuice-fix` |
| `files/servers.dat` | Lista server del client |
| `add-mod.sh` | Genera la voce JSON di una mod da un URL Modrinth |
| `release.sh` | Aggiorna hash e versione, fa commit, tag e push |

Ogni manifest ha quattro chiavi:

- `modpackVersion`: versione del pack.
- `mods`: mod obbligatorie (`name`, `filename`, `url`, `sha512`).
- `optionalMods`: mod opzionali, con `enabledByDefault`, `description` e `category`.
- `extraFiles`: file copiati nella cartella del gioco (`path`, `url`, `sha512`, `updatable`).

Mod obbligatorie: Cobblemon, More Cobblemon Tweaks, Mega Showdown, Accessories, Fabric API, Fabric Language Kotlin, oωo lib, Architectury, Cloth Config, YACL, TCDCommons, Chat Signing Hider, Continuity, Cobblemon Pokenav, Cobblemon Battle Extras, Catch Indicator, Cobblemon Catch Rate Display, Vexmon Aprijuice Fix, Mod Menu, Text Placeholder API, Cobblemon Journey Mounts, Ranked Hub.

Mod opzionali: Sodium, Lithium, ImmediatelyFast, FerriteCore, Entity Culling, Zoomify, Visuality, Skin Layers 3D, Xaero's Minimap, Xaero's World Map, Better Stats, Shulker Box Tooltip, Appleskin, Tooltip Scroll, Just Enough Items (JEI), Simple Voice Chat.

## Aggiungere una mod

```
./add-mod.sh https://modrinth.com/mod/<slug>/version/<versione>
```

Lo script stampa la voce per `mods` e quella per `optionalMods`. Incolla la voce giusta in tutti e tre i manifest.

## Release

```
./release.sh <versione>
```

Lo script ricalcola gli hash dei file in `files/` e aggiorna `modpackVersion` nei tre manifest. Poi fa commit `Release v<versione>`, crea il tag `v<versione>` e fa il push. Serve Python 3.

## Branch

| Branch | Uso |
|---|---|
| `main` | Manifest e file serviti al launcher |

## Maintainer

ytnoos
