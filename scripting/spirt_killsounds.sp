#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

ConVar g_kill1, g_kill2, g_kill3, g_kill4, g_ace;
char kill1[PLATFORM_MAX_PATH], kill2[PLATFORM_MAX_PATH], kill3[PLATFORM_MAX_PATH], kill4[PLATFORM_MAX_PATH], ace[PLATFORM_MAX_PATH];

#define PLUGIN_VERSION "1.0"

Handle killTimer[MAXPLAYERS + 1];
char lastKillSound[MAXPLAYERS + 1];
int kills[MAXPLAYERS + 1];
bool isPlayingSound[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "[SpirT] Kill Sounds",
	author = "SpirT", 
	description = "", 
	version = PLUGIN_VERSION, 
	url = ""
};

public void OnPluginStart()
{
	g_kill1 = CreateConVar("spirt_sounds_kill1", "SpirT/Valorant/kill1.mp3", "Sound to play when killing once in a round");
	g_kill2 = CreateConVar("spirt_sounds_kill2", "SpirT/Valorant/kill2.mp3", "Sound to play when double killing in a round");
	g_kill3 = CreateConVar("spirt_sounds_kill3", "SpirT/Valorant/kill3.mp3", "Sound to play when triple killing in a round");
	g_kill4 = CreateConVar("spirt_sounds_kill4", "SpirT/Valorant/kill4.mp3", "Sound to play when quadra killing in a round");
	g_ace = CreateConVar("spirt_sounds_ace", "SpirT/Valorant/ace.mp3", "Sound to play when killing five or more in a round");
	HookEvent("round_start", OnRoundStart);
	HookEvent("player_death", OnPlayerDeath);
	AutoExecConfig(true, "kill.sounds", "SpirT");
}

public void OnConfigsExecuted() {
	GetConVarString(g_kill1, kill1, sizeof(kill1));
	GetConVarString(g_kill2, kill2, sizeof(kill2));
	GetConVarString(g_kill3, kill3, sizeof(kill3));
	GetConVarString(g_kill4, kill4, sizeof(kill4));
	GetConVarString(g_ace, ace, sizeof(ace));
	char download[PLATFORM_MAX_PATH];
	Format(download, sizeof(download), "sound/%s", kill1);
	AddFileToDownloadsTable(download);
	Format(download, sizeof(download), "sound/%s", kill2);
	AddFileToDownloadsTable(download);
	Format(download, sizeof(download), "sound/%s", kill3);
	AddFileToDownloadsTable(download);
	Format(download, sizeof(download), "sound/%s", kill4);
	AddFileToDownloadsTable(download);
	Format(download, sizeof(download), "sound/%s", ace);
	AddFileToDownloadsTable(download);
}

public void OnClientPostAdminCheck(int client) {
	strcopy(lastKillSound[client], sizeof(lastKillSound[]), "");
	killTimer[client] = INVALID_HANDLE;
	kills[client] = 0;
	isPlayingSound[client] = false;
}

public Action OnRoundStart(Event event, const char[] name, bool dontBroadCast) {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && !IsFakeClient(client)) {
			strcopy(lastKillSound[client], sizeof(lastKillSound[]), "");
			killTimer[client] = INVALID_HANDLE;
			kills[client] = 0;
			isPlayingSound[client] = false;
		}
	}
} 

public Action OnPlayerDeath(Event event, const char[] name, bool dontBroadCast) {
	int client = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(!IsFakeClient(client)) {
		if(isPlayingSound[client]) {
			StopSound(client, SNDCHAN_AUTO, lastKillSound);
			isPlayingSound[client] = false;
		}
		
		kills[client]++;
		if(kills[client] == 1) {
			strcopy(lastKillSound[client], sizeof(lastKillSound[]), kill1);
			PrecacheSound(kill1);
			EmitSoundToClient(client, kill1, -2, SNDCHAN_AUTO, 0, 0, 0.60, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			killTimer[client] = CreateTimer(1.0, AllowNextSound, client);
		} else if (kills[client] == 2) {
			strcopy(lastKillSound[client], sizeof(lastKillSound[]), kill2);
			PrecacheSound(kill2);
			EmitSoundToClient(client, kill2, -2, SNDCHAN_AUTO, 0, 0, 0.60, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			killTimer[client] = CreateTimer(1.0, AllowNextSound, client);
		} else if (kills[client] == 3) {
			strcopy(lastKillSound[client], sizeof(lastKillSound[]), kill3);
			PrecacheSound(kill3);
			EmitSoundToClient(client, kill3, -2, SNDCHAN_AUTO, 0, 0, 0.60, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			killTimer[client] = CreateTimer(1.0, AllowNextSound, client);
		} else if (kills[client] == 4) {
			strcopy(lastKillSound[client], sizeof(lastKillSound[]), kill4);
			PrecacheSound(kill4);
			EmitSoundToClient(client, kill4, -2, SNDCHAN_AUTO, 0, 0, 0.60, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			killTimer[client] = CreateTimer(1.0, AllowNextSound, client);
		} else if (kills[client] >= 5) {
			strcopy(lastKillSound[client], sizeof(lastKillSound[]), ace);
			PrecacheSound(ace);
			EmitSoundToClient(client, ace, -2, SNDCHAN_AUTO, 0, 0, 0.60, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			killTimer[client] = CreateTimer(4.0, AllowNextSound, client);
		}
	}
}

Action AllowNextSound(Handle timer, int client) {
	isPlayingSound[client] = false;
}