#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>

#include "tf2bh/utils.sp"
#include "tf2bh/dhooks.sp"
#include "tf2bh/natives.sp"

/////////////////////////////
// PLUGIN INFO             //
/////////////////////////////

public Plugin myinfo = {
	name        = "[TF2] BaseObject Hook",
	author      = "Sandy and Monera",
	description = "Natives and Forwards for CBaseObject.",
	version     = "1.0.0",
	url         = "https://github.com/M60TM/TF2-BaseObject-Hook"
};

public APLRes AskPluginLoad2(Handle self, bool late, char[] error, int maxlen) {
	RegPluginLibrary("tf2bh");

	Native_Setup();

	return APLRes_Success;
}

public void OnPluginStart() {
	SDKCall_Setup();
	DHook_Setup();
}

public void OnEntityCreated(int entity, const char[] classname) {
	if (IsValidEntity(entity) && Util_IsBaseObject(entity)) {
		DHook_OnObjectCreated(entity);
	}
}