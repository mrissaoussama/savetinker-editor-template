# SaveTinker editor template

Template for a repository of [SaveTinker](https://github.com/mrissaoussama/SaveTinker) editors. The API is
documented in the SaveTinker README; [savetinker-editors](https://github.com/mrissaoussama/savetinker-editors) has
real ones, including generic editors for Unreal (`st.gvas`) and JSON saves.

| Folder | |
|---|---|
| `editors/my-game` | Minimal editor to start from |
| `editors/my-pc-game` | PC game (an Unreal save, read with `st.gvas`) |
| `editors/feature-tour` | Uses every widget and API call |
| `samples/feature-tour` | `make_sample.py` writes a save for the feature tour |
| `samples/my-pc-game` | `make_sample.py` writes `Slot1.sav` for the PC example |

```sh
python samples/feature-tour/make_sample.py
savetinker-cli run editors/feature-tour samples/feature-tour/save --game-version 1.0.5

savetinker-cli validate editors/my-game
savetinker-cli run editors/my-game path/to/save --set "Player/Money=500" --out edited/
savetinker-cli diff path/to/save edited/

savetinker-cli pack editors repo --name "My editors" --maintainer yourname
```

Files other than Lua (JSON tables, pictures, binary data) can sit in an editor folder and are read with
`st.data`. A PC game takes a 16-digit `title_id` you choose; the Steam app id in hex keeps it unique. Users add
the save in Settings and link it to the game.

Commit `repo/`, make the repository public and add
`https://raw.githubusercontent.com/<you>/<repo>/main/repo/repo.json` in SaveTinker's Repositories tab.
