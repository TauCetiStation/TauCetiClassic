/* protected types */

#define VE_PROTECTED_TYPES list(\
		/datum/admins,\
		/datum/configuration,\
		/obj/machinery/blackbox_recorder,\
		/datum/feedback_variable,\
		/datum/timedevent,\
		/datum/craft_or_build,\
		/datum/stack_recipe,\
		/datum/events,\
		/obj/effect/bmode/,\
	)


/* protected variables */

#define VE_ICONS \
	list("resize") // R_DEBUG|R_EVENT required
#define VE_DEBUG \
	list("vars", "virus", "viruses", "mutantrace", "summon_type", "AI_Interact", "key", "ckey", "client")
#define VE_FULLY_LOCKED \
	list("holder", "player_next_age_tick", "player_ingame_age", "resize_rev", "step_x", "step_y")


/* massmodify protected */

#define VE_MASS_ICONS \
	list("icon", "icon_state", "resize") // R_DEBUG|R_EVENT required
#define VE_MASS_DEBUG \
	list("vars", "virus", "viruses", "mutantrace", "summon_type", "AI_Interact")
#define VE_MASS_FULLY_LOCKED \
	list("holder", "player_next_age_tick", "player_ingame_age", "resize_rev", "step_x", "step_y", "key", "ckey", "client")
