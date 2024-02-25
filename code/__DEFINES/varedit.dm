// to prevent:
//  admin permissions escalation;
//  savefiles corruption;
//  feedback/db corruption;
//  inputs edit;
//  callprocs throught VV;
//  and edit of other things that admins better not touch;

/* protected types */

#define VE_PROTECTED_TYPES config.sandbox ? VE_PROTECTED_TYPES_STAT + /client : VE_PROTECTED_TYPES_STAT

#define VE_PROTECTED_TYPES_STAT list(\
		/datum/admins,\
		/datum/configuration,\
		/datum/preferences,\
		/datum/custom_item,\
		/datum/guard,\
		/datum/paiCandidate,\
		/obj/machinery/blackbox_recorder,\
		/datum/feedback_variable,\
		/datum/timedevent,\
		/datum/craft_or_build,\
		/datum/stack_recipe,\
		/datum/events,\
		/atom/movable/screen/buildmode,\
		/datum/controller/subsystem/junkyard,\
		/datum/tgui_list_input,\
		/datum/tgui_modal,\
		/datum/map_module,\
	)

/* protected variables */

#define VE_ICONS \
	list("resize") // R_DEBUG|R_EVENT required
#define VE_DEBUG \
	list("vars", "summon_type", "AI_Interact", "key", "ckey", "client")
#define VE_FULLY_LOCKED \
	list("holder", "glide_size", "player_next_age_tick", "player_ingame_age", "resize_rev", "step_x", "step_y", "bound_x", "bound_y", "step_size", "bound_height", "bound_width", "bounds", "smooth_icon_initial", "current_power_usage", "current_power_area", "script", "command_text", "proc_res")


/* massmodify protected */

#define VE_MASS_ICONS \
	list("icon", "icon_state", "resize") // R_DEBUG|R_EVENT required
#define VE_MASS_DEBUG \
	list("vars", "summon_type", "AI_Interact")
#define VE_MASS_FULLY_LOCKED \
	list("holder", "glide_size", "player_next_age_tick", "player_ingame_age", "resize_rev", "step_x", "step_y", "bound_x", "bound_y", "step_size", "bound_height", "bound_width", "bounds", "key", "ckey", "client", "smooth_icon_initial", "current_power_usage", "current_power_area", "script", "command_text", "proc_res")

/* hidden variables */
#define VE_HIDDEN_LOG \
	list("address", "computer_id", "guard", "related_accounts_ip", "related_accounts_cid", "lastKnownIP", "telemetry_connections")

var/global/list/duplicate_forbidden_vars = list(
	"tag", "area", "type", "loc", "locs", "vars", "verbs", "contents",
	"x", "y", "z", "key", "ckey", "client", "stat",
	"parent_type", "parent", "group", "power_supply",
	"bodyparts", "organs", "overlays_standing", "hud_list",
	"actions", "appearance", "managed_overlays", "managed_vis_overlays", "implants",
	"tgui_shared_states", "datum_components", "comp_lookup", "reagents",
	"current_power_usage", "current_power_area"
	)
