# SaveTinker editor template

Template for a repository of [SaveTinker](https://github.com/mrissaoussama/SaveTinker) editors. The API is
documented in the SaveTinker README; [savetinker-editors](https://github.com/mrissaoussama/savetinker-editors) has
real ones, including generic editors for Unreal (`st.gvas`) and JSON saves.

| Folder | |
|---|---|
| `editors/my-game` | Minimal editor to start from |
| `editors/feature-tour` | Uses every widget and API call |
| `samples/feature-tour` | `make_sample.py` writes a save for the feature tour |

```sh
python samples/feature-tour/make_sample.py
savetinker-cli run editors/feature-tour samples/feature-tour/save --game-version 1.0.5

savetinker-cli validate editors/my-game
savetinker-cli run editors/my-game path/to/save --set "Player/Money=500" --out edited/
savetinker-cli diff path/to/save edited/

savetinker-cli pack editors repo --name "My editors" --maintainer yourname
```

Commit `repo/`, make the repository public and add
`https://raw.githubusercontent.com/<you>/<repo>/main/repo/repo.json` in SaveTinker's Repositories tab.
