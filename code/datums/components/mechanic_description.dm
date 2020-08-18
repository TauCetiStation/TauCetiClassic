/datum/mechanic_tip
	// The name of the tip to display.
	var/tip_name
	// The description embedded in the tiip.
	var/description

	// Whether the tip should be re-generated on each examine.
	var/dyn_generation = FALSE

	// This var is generated if dyn_generation = FALSE
	var/tip_cache

/datum/mechanic_tip/proc/get_tip(mob/inspector, atom/inspected)
	if(dyn_generation)
		return generate_tip(inspector, inspected)

	if(tip_cache)
		return tip_cache

	tip_cache = generate_tip(inspector, inspected)
	return tip_cache

/datum/mechanic_tip/proc/generate_tip(mob/inspector, atom/inspected)
	return EMBED_TIP("[tip_name]", get_description(inspector, inspected))

/datum/mechanic_tip/proc/get_description(mob/inspector, atom/inspected)
	return description



/datum/component/mechanic_desc
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/datum/tip_handler
	var/list/datum/mechanic_tip/tips

/datum/component/mechanic_desc/Initialize(list/datum/mechanic_tip/tips_to_add)
	if(!istype(parent, /atom))
		return COMPONENT_INCOMPATIBLE

	for(var/datum/mechanic_tip/tip in tips_to_add)
		add_tip(tip)

	RegisterSignal(parent, list(COMSIG_PARENT_POST_EXAMINE), .proc/show_tips)
	RegisterSignal(parent, list(COMSIG_TIPS_REMOVE), .proc/remove_tips)

/datum/component/mechanic_desc/InheritComponent(datum/component/mechanic_desc/C, i_am_original, list/datum/mechanic_tip/tips_to_add)
	for(var/datum/mechanic_tip/tip in tips_to_add)
		add_tip(tip)

/datum/component/mechanic_desc/Destroy()
	QDEL_LIST_ASSOC_VAL(tips)
	return ..()

/datum/component/mechanic_desc/proc/add_tip(datum/mechanic_tip/tip)
	LAZYSET(tips, tip.tip_name, tip)

/datum/component/mechanic_desc/proc/remove_tip(tip_name)
	qdel(tips[tip_name])
	tips -= tip_name
	UNSETEMPTY(tips)
	if(!tips)
		qdel(src)

/datum/component/mechanic_desc/proc/remove_tips(datum/source, list/tip_ids_to_remove)
	for(var/tip_name in tip_ids_to_remove)
		if(QDELING(src))
			return
		remove_tip(tip_name)

/datum/component/mechanic_desc/proc/show_tips(datum/source, mob/user)
	for(var/tip_name in tips)
		var/datum/mechanic_tip/tip = tips[tip_name]
		to_chat(user, tip.get_tip(user, source))
