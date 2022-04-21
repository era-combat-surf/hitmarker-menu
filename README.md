# Hitmarker menu for CSGO

This plugin requires [SourceMod](https://www.sourcemod.net/plugins.php)

To install the plugin, follow the [installation guide](#installation)

[Forum link](https://forums.alliedmods.net/showthread.php?t=330813)

[Source code](https://github.com/awyxx/hitmarker-menu/blob/main/addons/sourcemod/scripting/hitmarker_menu_roby.sp)

### How it works
([Full video here](https://www.youtube.com/watch?v=2ck2jKZY17A&feature=emb_title))

https://user-images.githubusercontent.com/47612455/164533395-70b29d60-0da8-4589-a81a-adbf484ded29.mp4

### Stuff:
* addons/sourcemod/scripting/.sp - Source code <br>
* addons/sourcemod/plugins/.smx - Compiled plugin<br>
* materials/erasurf/ - Default hitmarkers I've included <br>

### Installation:
Put the .smx file into your server plugins/ folder <br>
Move erasurf/ to your server materials/ folder. **(Make sure your server's fastdl is working)** <br>

### Adding more hitmarkers:
If you want to add new hitmarkers, you will have to edit and recompile the plugin <br>
But its pretty simple, follow the example below:
```c
char hitmarker_path[][] = {
    "",
    "erasurf/wingsmarkerv2_era",
    "erasurf/crosshair_evil_v2_eye_era",
    "erasurf/crosshair_evil_v3_era",
    "erasurf/iexhit_era",
    "erasurf/iexvermelho",
    "erasurf/hitmarker_era",
    "erasurf/hitmarker_2_era",
    "erasurf/crosshair_alliance_v1_era",
    "erasurf/hit3blue",
    "erasurf/hit4red",
    "erasurf/kimimaru_pequenov1",
    // EXAMPLE: "mycommunity/cool_hitmarker01"	// .vmt and .vtf should be here: csgo/materials/mycommunity/
};

char hitmarker_name[][] = {
    "None",
    "Era",
    "Evileye",
    "Evil",
    "iexblue",
    "iexred",
    "Karma1",
    "Karma2",
    "Alliance",
    "hit3blue",
    "hit4red",
    "kimimaru_red",
    // EXAMPLE: "Cool Hitmarker"
};
```

### TODO:
* Add hitmarkers via config file
