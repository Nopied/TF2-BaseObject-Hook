#pragma semicolon 1
#pragma newdecls required

#include <dhooks_gameconf_shim>
#include <stocksoup/functions>
#include <stocksoup/tf/entity_prop_stocks>

/////////////////////////////
// Forward Define          //
/////////////////////////////

static GlobalForward g_ObjectOnGoActiveForward;
static GlobalForward g_ObjectStartUpgradingForward;
static GlobalForward g_ObjectFinishUpgradingForward;
static GlobalForward g_ObjectGetMaxHealthForCurrentLevel;
static GlobalForward g_SentrygunSetModel;
static GlobalForward g_DispenserSetModel;
static GlobalForward g_TeleporterSetModel;
static GlobalForward g_SapperSetModel;
static GlobalForward g_DispenserStartHealingForward;
static GlobalForward g_DispenserGetHealRate;
static GlobalForward g_DispenserStopHealingForward;
static GlobalForward g_PlayerCalculateObjectCost;
static GlobalForward g_ObjectGetConstructionMultiplier;
static GlobalForward g_DispenserCouldHealTargetForward;

/////////////////////////////
// DHooks Define           //
/////////////////////////////

static DynamicHook g_DHookObjectOnGoActive;
static DynamicHook g_DHookObjectStartUpgrading;
static DynamicHook g_DHookObjectFinishUpgrading;
static DynamicHook g_DHookObjectGetMaxHealth;
static DynamicHook g_DHookDispenserStartHealing;
static DynamicHook g_DHookObjectSetModel;
static DynamicHook g_DHookGetHealRate;

/////////////////////////////
// Setup Stuffs            //
/////////////////////////////

public void DHook_Setup() {
	GameData data = new GameData("tf2.baseobject");
	if (!data) {
		SetFailState("Failed to load gamedata (tf2.baseobject).");
	} else if (!ReadDHooksDefinitions("tf2.baseobject")) {
		SetFailState("Failed to read dhooks definitions of gamedata (tf2.baseobject).");
	}
	
	DHook_SetupForward();
	
	g_DHookObjectOnGoActive = GetDHooksHookDefinition(data, "CBaseObject::OnGoActive()");
	g_DHookObjectStartUpgrading = GetDHooksHookDefinition(data, "CBaseObject::StartUpgrading()");
	g_DHookObjectFinishUpgrading = GetDHooksHookDefinition(data, "CBaseObject::FinishUpgrading()");
	g_DHookObjectGetMaxHealth = GetDHooksHookDefinition(data, "CBaseObject::GetMaxHealthForCurrentLevel()");
	
	g_DHookObjectSetModel = GetDHooksHookDefinition(data, "CBaseObject::SetModel()");
	
	g_DHookDispenserStartHealing = GetDHooksHookDefinition(data, "CObjectDispenser::StartHealing()");
	g_DHookGetHealRate = GetDHooksHookDefinition(data, "CObjectDispenser::GetHealRate()");
	
	DynamicDetour dynDetourCalculateObjectCost = GetDHooksDetourDefinition(data, "CTFPlayerShared::CalculateObjectCost()");
	dynDetourCalculateObjectCost.Enable(Hook_Post, DynDetour_CalculateObjectCostPost);
	DynamicDetour dynDetourStopHealing = GetDHooksDetourDefinition(data, "CObjectDispenser::StopHealing()");
	dynDetourStopHealing.Enable(Hook_Post, DynDetour_DispenserStopHealingPost);
	DynamicDetour dynDetourGetConstructionMultiplier = GetDHooksDetourDefinition(data, "CBaseObject::GetConstructionMultiplier()");
	dynDetourGetConstructionMultiplier.Enable(Hook_Post, DynDetour_GetConstructionMultiplierPost);
	DynamicDetour dynDetourCouldHealTarget = GetDHooksDetourDefinition(data, "CObjectDispenser::CouldHealTarget");
	dynDetourCouldHealTarget.Enable(Hook_Pre, DynDetour_CouldHealTargetPre);
	
	ClearDHooksDefinitions();
	delete data;
}

void DHook_SetupForward() {
	g_ObjectOnGoActiveForward = new GlobalForward("TF2BH_CBaseObject_OnGoActive", ET_Event, Param_Cell, Param_Cell, Param_Cell);
	g_ObjectStartUpgradingForward = new GlobalForward("TF2BH_CBaseObject_StartUpgrading", ET_Event, Param_Cell, Param_Cell, Param_Cell);
	g_ObjectFinishUpgradingForward = new GlobalForward("TF2BH_CBaseObject_FinishUpgrading", ET_Event, Param_Cell, Param_Cell, Param_Cell);
	g_ObjectGetMaxHealthForCurrentLevel = new GlobalForward("TF2BH_CBaseObject_GetMaxHealth", ET_Hook, Param_Cell, Param_Cell, Param_Cell, Param_CellByRef);
	g_ObjectGetConstructionMultiplier = new GlobalForward("TF2BH_CBaseObject_GetConstructionMultiplier", ET_Hook, Param_Cell, Param_Cell, Param_Cell, Param_FloatByRef);
	
	g_SentrygunSetModel = new GlobalForward("TF2BH_CObjectSentrygun_SetModel", ET_Hook, Param_Cell, Param_Cell, Param_String);
	g_DispenserSetModel = new GlobalForward("TF2BH_CObjectDispenser_SetModel", ET_Hook, Param_Cell, Param_Cell, Param_String);
	g_TeleporterSetModel = new GlobalForward("TF2BH_CObjectTeleporter_SetModel", ET_Hook, Param_Cell, Param_Cell,Param_String);
	g_SapperSetModel = new GlobalForward("TF2BH_CObjectSapper_SetModel", ET_Hook, Param_Cell, Param_Cell, Param_String);
	
	g_DispenserStartHealingForward = new GlobalForward("TF2BH_CObjectDispenser_StartHealing", ET_Event, Param_Cell, Param_Cell, Param_Cell);
	g_DispenserGetHealRate = new GlobalForward("TF2BH_CObjectDispenser_GetHealRate", ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef);
	g_DispenserStopHealingForward = new GlobalForward("TF2BH_CObjectDispenser_StopHealing", ET_Event, Param_Cell, Param_Cell, Param_Cell);
	g_DispenserCouldHealTargetForward = new GlobalForward("TF2BH_CObjectDispenser_CouldHealTarget", ET_Hook, Param_Cell, Param_Cell, Param_Cell, Param_CellByRef);
	
	g_PlayerCalculateObjectCost = new GlobalForward("TF2BH_CTFPlayerShared_CalculateObjectCost", ET_Hook, Param_Cell, Param_Cell,  Param_CellByRef);
}

void DHook_OnObjectCreated(int entity) {
	g_DHookObjectOnGoActive.HookEntity(Hook_Post, entity, DHook_ObjectOnGoActivePost);
	g_DHookObjectStartUpgrading.HookEntity(Hook_Post, entity, DHook_ObjectStartUpgradingPost);
	g_DHookObjectFinishUpgrading.HookEntity(Hook_Post, entity, DHook_ObjectFinishUpgradingPost);
	g_DHookObjectGetMaxHealth.HookEntity(Hook_Post, entity, DHook_ObjectGetMaxHealthPost);
	
	switch (TF2_GetObjectType(entity)) {
		case TFObject_Dispenser: {
			g_DHookObjectSetModel.HookEntity(Hook_Pre, entity, DHook_DispenserSetModelPre);
			g_DHookDispenserStartHealing.HookEntity(Hook_Post, entity, DHook_DispenserStartHealingPost);
			g_DHookGetHealRate.HookEntity(Hook_Post, entity, DHook_DispenserGetHealRatePost);
		}
		case TFObject_Teleporter: {
			g_DHookObjectSetModel.HookEntity(Hook_Pre, entity, DHook_TeleporterSetModelPre);
		}
		case TFObject_Sentry: {
			g_DHookObjectSetModel.HookEntity(Hook_Pre, entity, DHook_SentrySetModelPre);
		}
		case TFObject_Sapper: {
			g_DHookObjectSetModel.HookEntity(Hook_Pre, entity, DHook_SapperSetModelPre);
		}
	}
}

MRESReturn DHook_ObjectOnGoActivePost(int building) {
	int builder = TF2_GetObjectBuilder(building);

	TFObjectType type = TF2_GetObjectType(building);

	Call_StartForward(g_ObjectOnGoActiveForward);
	Call_PushCell(builder);
	Call_PushCell(building);
	Call_PushCell(type);
	Call_Finish();

	return MRES_Ignored;
}

MRESReturn DHook_ObjectStartUpgradingPost(int building) {
	int	builder	= TF2_GetObjectBuilder(building);

	TFObjectType type = TF2_GetObjectType(building);

	Call_StartForward(g_ObjectStartUpgradingForward);
	Call_PushCell(builder);
	Call_PushCell(building);
	Call_PushCell(type);
	Call_Finish();

	return MRES_Handled;
}

MRESReturn DHook_ObjectFinishUpgradingPost(int building) {
	int	builder	= TF2_GetObjectBuilder(building);

	TFObjectType type = TF2_GetObjectType(building);

	Call_StartForward(g_ObjectFinishUpgradingForward);
	Call_PushCell(builder);
	Call_PushCell(building);
	Call_PushCell(type);
	Call_Finish();

	return MRES_Handled;
}

MRESReturn DHook_ObjectGetMaxHealthPost(int building, DHookReturn ret) {
	int builder = TF2_GetObjectBuilder(building);

	TFObjectType type = TF2_GetObjectType(building);

	int health = ret.Value;

	Call_StartForward(g_ObjectGetMaxHealthForCurrentLevel);
	Call_PushCell(builder);
	Call_PushCell(building);
	Call_PushCell(type);
	Call_PushCellRef(health);
	Action result;
	Call_Finish(result);

	if (result > Plugin_Continue) {
		ret.Value = health;
		return MRES_Override;
	}

	return MRES_Ignored;
}

MRESReturn DHook_SentrySetModelPre(int building, DHookParam params) {
	int builder = TF2_GetObjectBuilder(building);
	
	char modelName[128];
	params.GetString(1, modelName, sizeof(modelName));

	Call_StartForward(g_SentrygunSetModel);
	Call_PushCell(builder);
	Call_PushCell(building);
	Call_PushStringEx(modelName, 128, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Action result;
	Call_Finish(result);

	if (result > Plugin_Continue) {
		params.SetString(1, modelName);
		return MRES_ChangedHandled;
	}

	return MRES_Ignored;
}

MRESReturn DHook_DispenserSetModelPre(int building, DHookParam params) {
	int builder = TF2_GetObjectBuilder(building);

	char modelName[128];
	params.GetString(1, modelName, sizeof(modelName));

	Call_StartForward(g_DispenserSetModel);
	Call_PushCell(builder);
	Call_PushCell(building);
	Call_PushStringEx(modelName, 128, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Action result;
	Call_Finish(result);

	if (result > Plugin_Continue) {
		params.SetString(1, modelName);
		return MRES_ChangedHandled;
	}

	return MRES_Ignored;
}

MRESReturn DHook_TeleporterSetModelPre(int building, DHookParam params) {
	int builder = TF2_GetObjectBuilder(building);

	char modelName[128];
	params.GetString(1, modelName, sizeof(modelName));

	Call_StartForward(g_TeleporterSetModel);
	Call_PushCell(builder);
	Call_PushCell(building);
	Call_PushStringEx(modelName, 128, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Action result;
	Call_Finish(result);

	if (result > Plugin_Continue) {
		params.SetString(1, modelName);
		return MRES_ChangedHandled;
	}
	
	return MRES_Ignored;
}

MRESReturn DHook_SapperSetModelPre(int building, DHookParam params) {
	int builder = TF2_GetObjectBuilder(building);
	
	char modelName[128];
	params.GetString(1, modelName, sizeof(modelName));

	Call_StartForward(g_SapperSetModel);
	Call_PushCell(builder);
	Call_PushCell(building);
	Call_PushStringEx(modelName, 128, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Action result;
	Call_Finish(result);

	if (result > Plugin_Continue) {
		params.SetString(1, modelName);
		return MRES_ChangedHandled;
	}
	
	return MRES_Ignored;
}

MRESReturn DHook_DispenserStartHealingPost(int building, DHookParam params) {
	int builder = TF2_GetObjectBuilder(building);

	int patient = params.Get(1);
	if (!Util_IsValidClient(patient)) {
		patient = -1;
	}

	Call_StartForward(g_DispenserStartHealingForward);
	Call_PushCell(builder);
	Call_PushCell(building);
	Call_PushCell(patient);
	Call_Finish();

	return MRES_Ignored;
}

MRESReturn DHook_DispenserGetHealRatePost(int building, DHookReturn ret) {
	int builder = TF2_GetObjectBuilder(building);

	float healrate = ret.Value;
	Call_StartForward(g_DispenserGetHealRate);
	Call_PushCell(builder);
	Call_PushCell(building);
	Call_PushFloatRef(healrate);
	Action result;
	Call_Finish(result);

	if (result > Plugin_Continue) {
		ret.Value = healrate;
		return MRES_Override;
	}
	
	return MRES_Ignored;
}

MRESReturn DynDetour_CalculateObjectCostPost(Address pShared, DHookReturn ret, DHookParam params) {
	int cost = ret.Value;

	int builder = params.Get(1);

	TFObjectType type = params.Get(2);

	Call_StartForward(g_PlayerCalculateObjectCost);
	Call_PushCell(builder);
	Call_PushCell(type);
	Call_PushCellRef(cost);
	Action result;
	Call_Finish(result);

	if (result > Plugin_Continue) {
		ret.Value = cost;
		return MRES_Override;
	}

	return MRES_Ignored;
}

MRESReturn DynDetour_DispenserStopHealingPost(int building, DHookParam params) {
	int builder = TF2_GetObjectBuilder(building);

	int patient = DHookGetParam(params, 1);
	if (!Util_IsValidClient(patient)) {
		patient = -1;
	}

	Call_StartForward(g_DispenserStopHealingForward);
	Call_PushCell(builder);
	Call_PushCell(building);
	Call_PushCell(patient);
	Call_Finish();

	return MRES_Ignored;
}

MRESReturn DynDetour_GetConstructionMultiplierPost(int building, DHookReturn ret) {
	int builder = TF2_GetObjectBuilder(building);

	TFObjectType type = TF2_GetObjectType(building);

	float multiplier = ret.Value;

	Call_StartForward(g_ObjectGetConstructionMultiplier);
	Call_PushCell(builder);
	Call_PushCell(building);
	Call_PushCell(type);
	Call_PushFloatRef(multiplier);
	Action result;
	Call_Finish(result);

	if (result > Plugin_Continue) {
		ret.Value = multiplier;
		return MRES_Override;
	}

	return MRES_Ignored;
}

MRESReturn DynDetour_CouldHealTargetPre(int building, DHookReturn ret, DHookParam params) {
	int builder = TF2_GetObjectBuilder(building);
	int patient = params.Get(1);

	if (Util_IsValidClient(patient)) {
		Call_StartForward(g_DispenserCouldHealTargetForward);
		Call_PushCell(builder);
		Call_PushCell(building);
		Call_PushCell(patient);
		bool result = ret.Value;
		Call_PushCellRef(result);
		Action act;
		Call_Finish(act);

		if (act > Plugin_Continue) {
			ret.Value = result;
			return MRES_Supercede;
		}
	}

	return MRES_Ignored;
}