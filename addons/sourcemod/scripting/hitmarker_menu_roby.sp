#include <sourcemod>
#include <sdktools>
#include <clientprefs>

/* im ready for csurf people remove credits and put their community here ;) */
public Plugin myinfo = {
    name = "Hitmarker Menu",
    author = "roby", /* s/o zauni and era surf community */
    description = "Choose your custom kill/hit hitmarker!",
    version = "2.0",
    url = "https://steamcommunity.com/id/sleepiest/ OR roby#0577"
};


/*
IMPORTANT READ PLEASE:
	want to add a new custom hitmarkers? simple
	you just have to add .vmt/.vtf path to 'hitmarker_path' and hitmarker name on 'hitmarker_name'
	follow the EXAMPLES below:
*/

// code is very old sorry if it looks like ****

/***********/
/* globals */

#define TAG 						"\x01 \x0B[Hitmarker]\x01"
#define HITMARKER_SHOW_TIME			0.45
#define TOTAL_HITMARKERS 			sizeof(hitmarker_path)
#define SPECMODE_NONE 				0
#define SPECMODE_FIRSTPERSON 		4
#define SPECMODE_3RDPERSON 			5
#define SPECMODE_FREELOOK	 		6

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

Handle g_menu_hitmarker 	= INVALID_HANDLE;
Handle g_menu_hit 			= INVALID_HANDLE;
Handle g_cookie_hitmarker 	= INVALID_HANDLE;
Handle g_cookie_hit 		= INVALID_HANDLE;

int g_client_hitmarker[MAXPLAYERS + 1] 	= {1, ...}; // default hitmarker: wingsmarkerv2_era (1)
int g_client_hit[MAXPLAYERS + 1] 		= {0, ...};	// default hit: none (0)

public OnPluginStart() {
	RegConsoleCmd("sm_hitmarker", cmd_hitmarker);
	RegConsoleCmd("sm_hitmarkers", cmd_hitmarker);
	RegConsoleCmd("sm_hitmark", cmd_hitmarker);
	RegConsoleCmd("sm_hm", cmd_hitmarker);
	RegConsoleCmd("sm_hit", cmd_hit);
	
	HookEvent("player_hurt", event_player_hurt, EventHookMode_Post);
	HookEvent("player_death", event_player_death);
	
	g_cookie_hitmarker 	= RegClientCookie("roby_hitmarker_kill", "Kill hitmarker", CookieAccess_Protected);
	g_cookie_hit		= RegClientCookie("roby_hitmarker_hit", "Hit hitmarker", CookieAccess_Protected);
	
	make_files_ready();
	
	for (int i = MaxClients; i > 0; --i)
        if(AreClientCookiesCached(i))
			OnClientCookiesCached(i);
}

public void OnMapStart() {
	make_files_ready();
}

/************/
/* commands */

public Action cmd_hitmarker(int client, int args) {
	if (is_valid_client(client)) {
		init_hitmarker_menu(client);
		DisplayMenu(g_menu_hitmarker, client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

public Action cmd_hit(int client, int args) {
	if (is_valid_client(client)) {
		init_hit_menu(client);
		DisplayMenu(g_menu_hit, client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}


/***********************/
/* menus and callbacks */

void init_hitmarker_menu(int client) {
	char info[8], item[64];
	g_menu_hitmarker = CreateMenu(hitmarker_menu_cb, MenuAction_Start|MenuAction_Select|MenuAction_End|MenuAction_Cancel);
	SetMenuTitle(g_menu_hitmarker, "Choose your hitmarker (on kill):");
	for (int i = 0; i < TOTAL_HITMARKERS; i++) {
		Format(item, sizeof(item), "%s %s", hitmarker_name[i], i == g_client_hitmarker[client] ? "[X]" : " ");
		IntToString(i, info, sizeof(info));
		AddMenuItem(g_menu_hitmarker, info, item);
	}
}

void init_hit_menu(int client) {
	char info[8], item[64];
	g_menu_hit = CreateMenu(hit_menu_cb, MenuAction_Start|MenuAction_Select|MenuAction_End|MenuAction_Cancel);
	SetMenuTitle(g_menu_hit, "Choose your hitmarker (on hit):");
	for (int i = 0; i < TOTAL_HITMARKERS; i++) {
		Format(item, sizeof(item), "%s %s", hitmarker_name[i], i == g_client_hit[client] ? "[X]" : " ");
		IntToString(i, info, sizeof(info));
		AddMenuItem(g_menu_hit, info, item);
	}
}

public int hitmarker_menu_cb(Menu menu, MenuAction action, int param1, int param2) {
	switch (action) {
		case MenuAction_End: { 
			delete menu; 
		}

		case MenuAction_Select: {
			char item[32];
			menu.GetItem(param2, item, sizeof(item));
			
			int option = StringToInt(item);
			SetClientCookie(param1, g_cookie_hitmarker, item); // pls work
			g_client_hitmarker[param1] = option;

			if (!option)	PrintToChat(param1, "%s \x0FYou disabled \x07hitmarkers on kill", TAG);
			else			PrintToChat(param1, "%s \x0FYou chose \x07\"%s\" \x0Fhitmarker (on kill)", TAG, hitmarker_name[option]);

			cl_show_overlay(param1, hitmarker_path[option]);
			CreateTimer(HITMARKER_SHOW_TIME, cl_hide_overlay, param1);
        }
    }
    
	return 0;
}

public int hit_menu_cb(Menu menu, MenuAction action, int param1, int param2) {
	switch (action) {
		case MenuAction_End: { 
			delete menu; 
		}

		case MenuAction_Select: {
			char item[32];
			menu.GetItem(param2, item, sizeof(item));
			
			int option = StringToInt(item);
			SetClientCookie(param1, g_cookie_hit, item); // pls work
			g_client_hit[param1] = option;

			if (!option)	PrintToChat(param1, "%s \x0FYou disabled \x07hitmarkers on hit.", TAG);
			else			PrintToChat(param1, "%s \x0FYou chose \x07\"%s\" \x0Fhitmarker (on hit)", TAG, hitmarker_name[option]);
			
			cl_show_overlay(param1, hitmarker_path[option]);
			CreateTimer(HITMARKER_SHOW_TIME, cl_hide_overlay, param1);
		}
	}

	return 0;
}


/**********/
/* events */

public Action event_player_hurt(Event event, const char[] name, bool dontBroadcast) {
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	
	if (is_valid_client(attacker) && g_client_hit[attacker]) {
		cl_show_overlay(attacker, hitmarker_path[g_client_hit[attacker]]);
		CreateTimer(HITMARKER_SHOW_TIME, cl_hide_overlay, attacker);
	}
	
	show_to_spec(attacker, false);
	return Plugin_Handled;
}

public Action event_player_death(Event event, const char[] name, bool dontBroadcast) {
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    
	if (is_valid_client(attacker) && g_client_hitmarker[attacker]) {
		cl_show_overlay(attacker, hitmarker_path[g_client_hitmarker[attacker]]);
		CreateTimer(HITMARKER_SHOW_TIME, cl_hide_overlay, attacker);
	}

	show_to_spec(attacker, true);
	return Plugin_Handled;
}


/*************/
/* functions */

void cl_show_overlay(int client, const char[] overlaypath) {
	if(is_valid_client(client)) ClientCommand(client, "r_screenoverlay \"%s\"", overlaypath);
}

public Action cl_hide_overlay(Handle timer, any client) {
	if(is_valid_client(client)) cl_show_overlay(client, "");
} 

stock bool is_valid_client(int client) {
    return (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client));
}

void show_to_spec(int attacker, bool kill) {
	// s/o kamay
	for (int spec = 1; spec <= MaxClients; spec++) {
		if (!is_valid_client(spec) || !IsClientObserver(spec))
			continue;
	
		int iSpecMode = GetEntProp(spec, Prop_Send, "m_iObserverMode");

		if (iSpecMode == SPECMODE_FIRSTPERSON || iSpecMode == SPECMODE_3RDPERSON) {
			int iTarget = GetEntPropEnt(spec, Prop_Send, "m_hObserverTarget");
			
			if (kill) {
				if (iTarget == attacker && g_client_hitmarker[spec])
					cl_show_overlay(spec, hitmarker_path[g_client_hitmarker[spec]]);
			}
			else {
				if (iTarget == attacker && g_client_hit[spec])
					cl_show_overlay(spec, hitmarker_path[g_client_hit[spec]]);
			}
			
			CreateTimer(HITMARKER_SHOW_TIME, cl_hide_overlay, spec);
		}
	}
}


/***********/
/* cookies */ 
// i have no idea if this works properly xd 

public OnClientCookiesCached(int client) {
	char hm[4], hit[4];
	GetClientCookie(client, g_cookie_hitmarker, hm, sizeof(hm));
	GetClientCookie(client, g_cookie_hit, hit, sizeof(hit));
	
	if (hm[0] == '\0') {
		SetClientCookie(client, g_cookie_hitmarker, "1");
		g_client_hitmarker[client] = 1;
	}
	else {
		g_client_hitmarker[client] = StringToInt(hm);
	}
	
	if (hit[0] == '\0') {
		SetClientCookie(client, g_cookie_hit, "0");
		g_client_hit[client] = 0;
	}
	else {
		g_client_hit[client] = StringToInt(hit);
	}

}

public void OnClientDisconnect(int client) {
	char hm_option[4], hit_option[4];
	IntToString(g_client_hitmarker[client], hm_option, sizeof(hm_option));
	IntToString(g_client_hit[client], hit_option, sizeof(hit_option));
	SetClientCookie(client, g_cookie_hitmarker, hm_option);
	SetClientCookie(client, g_cookie_hit, hit_option);
}


/******************/
/* download stuff */

void make_files_ready() {
	// i hope this works XD 
	char vmt[64], vtf[64];
	char vmt2[64], vtf2[64];
	for (int i = 1; i < TOTAL_HITMARKERS; i++) {
		Format(vmt, sizeof(vmt), "materials/%s.vmt", hitmarker_path[i]);
		Format(vtf, sizeof(vtf), "materials/%s.vtf", hitmarker_path[i]);
		Format(vmt2, sizeof(vmt2), "%s.vmt", hitmarker_path[i]);
		Format(vtf2, sizeof(vtf2), "%s.vtf", hitmarker_path[i]);
		
		AddFileToDownloadsTable(vmt);
		AddFileToDownloadsTable(vtf);
		PrecacheDecal(vmt2, true);
		PrecacheDecal(vtf2, true);
	}
}