#pragma semicolon 1
#pragma newdecls required

/////////////////////////////
// Setup                   //
/////////////////////////////

void Native_Setup() {
	CreateNative("TF2BH_CTFPlayer_DetonateObjectOfType", Native_CTFPlayer_DetonateObjectOfType);
	CreateNative("TF2BH_CTFPlayer_GetObjectOfType", Native_CTFPlayer_GetObjectOfType);
	CreateNative("TF2BH_CBaseObject_DestroyScreens", Native_CBaseObject_DestroyScreens);
	CreateNative("TF2BH_CTFPlayer_RemoveAllObjects", Native_CTFPlayer_RemoveAllObjects);
	CreateNative("TF2BH_CTFGameRules_RemoveAllObjects", Native_CTFGameRulesRemoveObjects);
	CreateNative("TF2BH_CBaseObject_GetSapper", Native_CBaseObject_GetSapper);
}

/////////////////////////////
// Native                  //
/////////////////////////////

public any Native_CTFPlayer_DetonateObjectOfType(Handle plugin, int nParams) {
	int	client = GetNativeInGameClient(1);
	int	type = GetNativeCell(2);
	int	mode = GetNativeCell(3);
	bool silent = GetNativeCell(4);

	return SDKCall_CTFPlayerDetonateObjectOfType(client, type, mode, silent);
}

public any Native_CTFPlayer_GetObjectOfType(Handle plugin, int nParams) {
	int owner = GetNativeInGameClient(1);
	int objectType = GetNativeCell(2);
	int objectMode = GetNativeCell(3);

	return SDKCall_CTFPlayerGetObjectOfType(owner, objectType, objectMode);
}

public any Native_CBaseObject_DestroyScreens(Handle plugin, int nParams) {
	int building = GetNativeCell(1);

	return SDKCall_CBaseObjectDestroyScreens(building);
}

public any Native_CTFPlayer_RemoveAllObjects(Handle plugin, int nParams) {
	int	client = GetNativeInGameClient(1);
	bool explode = GetNativeCell(2);

	return SDKCall_CTFPlayerRemoveAllObjects(client, explode);
}

public any Native_CTFGameRulesRemoveObjects(Handle plugin, int nParams) {
	bool explode = GetNativeCell(1);

	return SDKCall_CTFGameRulesRemoveAllObjects(explode);
}

public any Native_CBaseObject_GetSapper(Handle plugin, int nParams) {
	int building = GetNativeCell(1);
	
	return SDKCall_CBaseObjectGetSapper(building);
}