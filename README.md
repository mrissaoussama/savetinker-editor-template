# SaveTinker editor template

Start a repository of [SaveTinker](https://github.com/mrissaoussama/SaveTinker) save editors from this template.

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
