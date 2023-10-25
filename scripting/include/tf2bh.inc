/** Double-include prevention */
#if defined _tf2bh_included_
  #endinput
#endif
#define _tf2bh_included_

#include <tf2>

/////////////////////////////
// Define                  //
/////////////////////////////

#define SENTRY_BLUEPRINT_MODEL "models/buildables/sentry1_blueprint.mdl"
#define SENTRY_LV1_MODEL	   "models/buildables/sentry1.mdl"
#define SENTRY_LV1_HEAVY_MODEL "models/buildables/sentry1_heavy.mdl"
#define SENTRY_LV2_MODEL	   "models/buildables/sentry2.mdl"
#define SENTRY_LV2_HEAVY_MODEL "models/buildables/sentry2_heavy.mdl"
#define SENTRY_LV3_MODEL	   "models/buildables/sentry3.mdl"
#define SENTRY_LV3_HEAVY_MODEL "models/buildables/sentry3_heavy.mdl"

#define DISPENSER_BLUEPRINT_MODEL "models/buildables/dispenser_blueprint.mdl"
#define DISPENSER_LV1_LIGHT_MODEL "models/buildables/dispenser_light.mdl"
#define DISPENSER_LV1_MODEL		  "models/buildables/dispenser.mdl"
#define DISPENSER_LV2_LIGHT_MODEL "models/buildables/dispenser_lvl2_light.mdl"
#define DISPENSER_LV2_MODEL		  "models/buildables/dispenser_lvl2.mdl"
#define DISPENSER_LV3_LIGHT_MODEL "models/buildables/dispenser_lvl3_light.mdl"
#define DISPENSER_LV3_MODEL		  "models/buildables/dispenser_lvl3.mdl"

#define TELEPORTER_BLUEPRINT_ENTER_MODEL "models/buildables/teleporter_blueprint_enter.mdl"
#define TELEPORTER_BLUEPRINT_EXIT_MODEL	 "models/buildables/teleporter_blueprint_exit.mdl"
#define TELEPORTER_LIGHT_MODEL			 "models/buildables/teleporter_light.mdl"
#define TELEPORTER_MODEL				 "models/buildables/teleporter.mdl"

/////////////////////////////
// Native                  //
/////////////////////////////

/**
 * Detonate spectific buildings belonging to a player.
 * 
 * @param client     Player to check against.
 * @param type       Type of building to destroy.
 * @param mode       Mode of building to destroy.
 * @param force      Force to destroy buildings. If true, this skips the sapper / plasma disabled checks.
 * @noreturn
 * 
 * @error            Invalid client index.
 */
native void TF2BH_CTFPlayer_DetonateObjectOfType(int client, int type, int mode = 0, bool force = false);

/**
 * Get player's spectific object.
 * 
 * @param client         Client index to check.
 * @param objectType     Type of object to find.
 * @param objectMode     Mode of object to find.
 * @return               Client's object index if object is valid, -1 otherwise.
 * 
 * @error                Invalid client index.
 */
native int TF2BH_CTFPlayer_GetObjectOfType(int client, int objectType, int objectMode);

/**
 * Destroy object's screen.
 * 
 * @param building     Object index to destroy screen.
 * @noreturn
 * 
 * @error Entity is not valid or not CBaseObject.
 */
native void TF2BH_CBaseObject_DestroyScreens(int building);

/**
 * Remove All Objects of spectific client.
 * 
 * @param client      Client index to remove it's own objects.
 * @param explode     Explode object instead remove.
 * @noreturn
 * 
 * @error             Invalid client index.
 */
native void TF2BH_CTFPlayer_RemoveAllObjects(int client, bool explode);

/**
 * Remove All Objects in world.
 * 
 * @param explode     Explode object instead remove.
 * @noreturn
 */
native void TF2BH_CTFGameRules_RemoveAllObjects(bool explode);

/**
 * Get attached sapper from object.
 * 
 * @param building     Object index to destroy screen.
 * @return             Attached sapper index if m_bHasSapper is true, -1 otherwise.
 * 
 * @error Entity is not valid or not CBaseObject.
 */
native int TF2BH_CBaseObject_GetSapper(int building);

/////////////////////////////
// Forward                 //
/////////////////////////////

/**
 * Called when object go active.
 * 
 * @param builder				object builder.
 * @param building				object's index.
 * @param type					object's type.
 */
forward void TF2BH_CBaseObject_OnGoActive(int builder, int building, TFObjectType type);

/**
 * Called when object start upgrade.
 * 
 * @param builder				object builder.
 * @param building				object's index.
 * @param type					object's type.
 */
forward void TF2BH_CBaseObject_StartUpgrading(int builder, int building, TFObjectType type);

/**
 * Called when object finish upgrade.
 * 
 * @param builder				object builder.
 * @param building				object's index.
 * @param type					object's type.
 */
forward void TF2BH_CBaseObject_FinishUpgrading(int builder, int building, TFObjectType type);

/**
 * Called when object get max health for current level.
 * 
 * @param builder       Object builder index.
 * @param building      Object entity index.
 * @param type          Object type.
 * @param maxHealth     Object max health.
 * @return              Plugin_Changed to use your maxHealth value.
 */
forward Action TF2BH_CBaseObject_GetMaxHealth(int builder, int building, TFObjectType type, int &maxHealth);

/**
 * Called when object get construction multiplier.
 * 
 * @param builder        Object builder index.
 * @param building       Object entity index.
 * @param type           Object type.
 * @param multiplier     Construction multiplier.
 * @return               Plugin_Changed to use your multiplier value.
 */
forward Action TF2BH_CBaseObject_GetConstructionMultiplier(int builder, int building, TFObjectType type, float &multiplier);

/**
 * Called when sentrygun find model for current state.
 * 
 * @param builder       Sentrygun builder index.
 * @param sentry        Sentrygun entity index.
 * @param modelName     Model path.
 * @return              Plugin_Changed to change model path.
 */
forward Action TF2BH_CObjectSentrygun_SetModel(int builder, int sentry, char modelName[128]);

/**
 * Called when dispenser find model for current state.
 * 
 * @param builder       Dispenser builder index.
 * @param dispenser     Dispenser entity index.
 * @param modelName     Model path.
 * @return              Plugin_Changed to change model path.
 */
forward Action TF2BH_CObjectDispenser_SetModel(int builder, int dispenser, char modelName[128]);

/**
 * Called when teleporter find model for current state.
 * 
 * @param builder        Teleporter builder index.
 * @param teleporter     Teleporter entity index.
 * @param modelName      Model path.
 * @return               Plugin_Changed to change model path.
 */
forward Action TF2BH_CObjectTeleporter_SetModel(int builder, int teleporter, char modelName[128]);

/**
 * Called when sapper find model for current state.
 * 
 * @param builder        Sapper builder index.
 * @param sapper         Sapper entity index.
 * @param modelName      Model path.
 * @return               Plugin_Changed to change model path.
 */
forward Action TF2BH_CObjectSapper_SetModel(int builder, int sapper, char modelName[128]);

/**
 * Called when dispenser start healing to patient.
 * 
 * @param builder      Dispenser builder index.
 * @param building     Dispenser entity index.
 * @param patient      Patient index.
 * @noreturn           
 */
forward void TF2BH_CObjectDispenser_StartHealing(int builder, int building, int patient);

/**
 * Called when dispenser get healrate.
 * 
 * @param builder       Dispenser builder index.
 * @param dispenser     Dispenser entity index.
 * @param healrate      Healrate.
 * @return              Plugin_Changed to use your healrate value.
 */
forward Action TF2BH_CObjectDispenser_GetHealRate(int builder, int dispenser, float &healrate);

/**
 * Called when dispenser stop healing to patient.
 * 
 * @param builder      Dispenser builder index.
 * @param building     Dispenser entity index.
 * @param patient      Patient index.
 * @noreturn           
 */
forward void TF2BH_CObjectDispenser_StopHealing(int builder, int building, int patient);

/**
 * Called when dispenser consider patient is heal target.
 * Return Plugin_Continue to let the original calculation or return a higher
 * action to override the decision with the value of 'result'
 * 
 * @param builder       Builder index.
 * @param dispenser     Dispenser entity index.
 * @param patient       Patient index.
 * @param result        True to pass, false to block.
 * @return              Plugin_Continue for original calculation, higher value to use 'result'.
 */
forward Action TF2BH_CObjectDispenser_CouldHealTarget(int builder, int dispenser, int patient, bool &result);

/**
 * Called when player calculate object cost.
 * 
 * @note It doesn't affect to PDA. PDA's HUD is client side.
 * 
 * @param client      Client index.
 * @param type        Object type.
 * @param cost        Object cost.
 * @return            Plugin_Changed to use your cost value.
 */
forward Action TF2BH_CTFPlayerShared_CalculateObjectCost(int client, TFObjectType type, int &cost);

public SharedPlugin __pl_tf2bh = {
	name = "tf2bh",
	file = "tf2bh.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};
