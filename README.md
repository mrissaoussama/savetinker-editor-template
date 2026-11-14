# SaveTinker editor template

Start a repository of [SaveTinker](https://github.com/mrissaoussama/SaveTinker) save editors from this template.

| Folder | What it is |
|---|---|
| `editors/my-game` | Small starting point: one file, a checksum, two pages |
| `editors/feature-tour` | Uses every part of the API on a made-up save; copy what you need |
| `samples/feature-tour` | `make_sample.py` writes a save the feature tour opens |

## Make an editor

1. Rename `editors/my-game` and set `id`, `name` and the game's `title_id` in its `manifest.json`.
   Platforms are `switch`, `3ds`, `nds` and `gba`; `versions` limits the game versions the editor was tested on.
2. Describe the save in `main.lua`: `detect` recognises the save, `build` lays out the pages and `before_save`
   fixes checksums. The full API is in the SaveTinker README.
3. Try it on a real save:

   ```sh
   savetinker-cli validate editors/my-game
   savetinker-cli run editors/my-game path/to/save --set "Player/Money=500" --out edited/
   savetinker-cli diff path/to/save edited/
   ```

4. Publish: `savetinker-cli pack editors repo --name "My editors" --maintainer yourname`, commit `repo/`, make the
   repository public and add `https://raw.githubusercontent.com/<you>/<repo>/main/repo/repo.json` in SaveTinker's
   Repositories tab.

Editors can also be created on the console: mark fields in SaveTinker's hex editor and install the result from the
editor creator, then copy the generated folder here to keep working on it.

## Feature tour

```sh
python samples/feature-tour/make_sample.py
savetinker-cli run editors/feature-tour samples/feature-tour/save --game-version 1.0.5
```

| Page | Shows |
|---|---|
| Player | `text`, `int` with actions, `float`, `dropdown` with `on_change`, `segmented`, `toggle` on a bit and with custom `on`/`off` values, hex numbers, `help` |
| Heroes | collapsed `section`s with actions, `st.transaction`, `st.bind` with `string.pack`, widgets shown only when they apply |
| Inventory | `ui:state` filters, translated labels from `st.labels` (`data/fr/items.json`) |
| World | `tristate`, `multiselect`, `st.game.has_dlc`, `separator`, `popup`, `warning`, buttons |
| Notes and raw data | resizing a file with `splice`, `find`, `st.hex`, `st.hash` |
| Game files | `st.game_data` (needs `"game_data": true`), `st.format.msbt` |
| About | `st.editor`, `st.game`, `st.game.version_is`, `st.api_version`, `print`/`st.warn` (open the log with -), nested `page`, `st.json` |

`detect` returns `false, "reason"` for saves it does not know and warns about a bad checksum; `before_save` fixes it.
`require("layout")` loads `layout.lua` from the editor folder.

## Manifest options

| Key | Meaning |
|---|---|
| `icon` | PNG or JPEG in the editor folder, 128x128 or smaller (64 KB at most) |
| `api_version` | Editor API the scripts were written for; older SaveTinker builds refuse newer versions |
| `game_data` | Read only access to the game's own files |
| `games[].versions` | Game versions the editor was tested with, like `">=1.1.0"` or `"1.0.0 - 1.2.0"` |
| `games[].title_id = "*"` | Generic editor: offered for every game on that platform (`"platform": "*"` for every console) |

Generic editors suit engine or format based saves (Unity JSON, Unreal GVAS, SQLite...). They are listed apart from
game editors and `detect` decides whether a save is one they understand, so make it strict and give a reason when it
says no. See `generic-json` in [savetinker-editors](https://github.com/mrissaoussama/savetinker-editors) for one.
