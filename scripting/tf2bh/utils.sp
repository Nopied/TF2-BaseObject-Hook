#pragma semicolon 1
#pragma newdecls required

/////////////////////////////
// SDKCall                 //
/////////////////////////////

static Handle g_SDKCallCTFPlayerDetonateObjectOfType;
static Handle g_SDKCallCBaseObjectDestroyScreens;
static Handle g_SDKCallCTFPlayerGetObjectOfType;
static Handle g_SDKCallCTFPlayerRemoveAllObjects;
static Handle g_SDKCallCTFGameRulesRemoveAllObjects;
static Handle g_SDKCallCBaseObjectGetSapper;

void SDKCall_Setup() {
	GameData data = new GameData("tf2.baseobject");
	if (!data) {
		SetFailState("Failed to load gamedata (tf2.baseobject).");
	}
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(data, SDKConf_Signature, "CTFPlayer::DetonateObjectOfType()");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	// int - type
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	// int - mode
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	// bool - force
	g_SDKCallCTFPlayerDetonateObjectOfType = EndPrepSDKCall();

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(data, SDKConf_Signature, "CTFPlayer::GetObjectOfType()");
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	g_SDKCallCTFPlayerGetObjectOfType = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(data, SDKConf_Signature, "CBaseObject::DestroyScreens()");
	g_SDKCallCBaseObjectDestroyScreens = EndPrepSDKCall();

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(data, SDKConf_Signature, "CTFPlayer::RemoveAllObjects()");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	// bool - explodeBulidings
	g_SDKCallCTFPlayerRemoveAllObjects = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_GameRules);
	PrepSDKCall_SetFromConf(data, SDKConf_Signature, "CTFGameRules::RemoveAllObjects()");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	// bool - explodeBulidings
	g_SDKCallCTFGameRulesRemoveAllObjects = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(data, SDKConf_Signature, "CBaseObject::GetSapper()");
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	g_SDKCallCBaseObjectGetSapper = EndPrepSDKCall();
	
	delete data;
}

any SDKCall_CTFPlayerDetonateObjectOfType(int client, int type, int mode = 0, bool force = false) {
	return SDKCall(g_SDKCallCTFPlayerDetonateObjectOfType, client, type, mode, force);
}

any SDKCall_CTFPlayerGetObjectOfType(int owner, int objectType, int objectMode) {
	return SDKCall(g_SDKCallCTFPlayerGetObjectOfType, owner, objectType, objectMode);
}

any SDKCall_CBaseObjectDestroyScreens(int building) {
	return SDKCall(g_SDKCallCBaseObjectDestroyScreens, building);
}

any SDKCall_CTFPlayerRemoveAllObjects(int client, bool explode) {
	return SDKCall(g_SDKCallCTFPlayerRemoveAllObjects, client, explode);
}

any SDKCall_CTFGameRulesRemoveAllObjects(bool explode) {
	return SDKCall(g_SDKCallCTFGameRulesRemoveAllObjects, explode);
}

any SDKCall_CBaseObjectGetSapper(int building) {
	return SDKCall(g_SDKCallCBaseObjectGetSapper, building);
}

/////////////////////////////
// Utility                 //
/////////////////////////////

stock bool Util_IsValidClient(int client, bool replaycheck = true) {
	if (client <= 0 || client > MaxClients) {
		return false;
	}
	
	if (!IsClientInGame(client)) {
		return false;
	}
	
	if (GetEntProp(client, Prop_Send, "m_bIsCoaching")) {
		return false;
	}
	
	if (replaycheck && (IsClientSourceTV(client) || IsClientReplay(client))) {
		return false;
	}
	
	return true;
}

stock bool Util_IsBaseObject(int entity) {
	return HasEntProp(entity, Prop_Data, "CBaseObjectUpgradeThink");
}