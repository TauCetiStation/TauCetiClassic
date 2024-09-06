#define HUD_UPGRADE_MEDSCAN 1
#define HUD_UPGRADE_NIGHTVISION 2
#define HUD_UPGRADE_THERMAL 3
#define HUD_UPGRADE_THERMAL_ADVANCED 4

#define HUD_TOGGLEABLE_MODE_NIGHTVISION "night"
#define HUD_TOGGLEABLE_MODE_THERMAL "thermal"
#define HUD_TOGGLEABLE_MODE_THERMAL_ADVANCED "thermal_adv"

/obj/item/clothing/glasses/sunglasses/hud/advanced
	name = "Advanced HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and health status."
	icon = 'icons/obj/clothing/goggles.dmi'
	item_state = "sechud"
	item_state_inventory = "sechud"
	item_state_world = "sechud_w"
	body_parts_covered = EYES
	hud_types = list(DATA_HUD_SECURITY)
	item_action_types = list()
	var/upgrade_tier = 0
	var/current_mode = null
	var/static/list/glasses_states = list(
		HUD_TOGGLEABLE_MODE_NIGHTVISION = new /datum/glasses_mode_type_state/night/nightsight,
		HUD_TOGGLEABLE_MODE_THERMAL = new /datum/glasses_mode_type_state/thermal/sepia,
		HUD_TOGGLEABLE_MODE_THERMAL_ADVANCED = new /datum/glasses_mode_type_state/thermal_advanced,
	)

/obj/item/clothing/glasses/sunglasses/hud/advanced/proc/apply_effects(mode_type, enable)
	if(!ishuman(usr))
		return
	var/mob/living/carbon/glasses_user = usr
	var/datum/glasses_mode_type_state/state = glasses_states[mode_type]
	if (enable)
		state.on()
	else
		state.off()
	playsound(src, activation_sound, VOL_EFFECTS_MASTER, 10, FALSE)
	glasses_user.update_sight()
	update_item_actions()


/obj/item/clothing/glasses/sunglasses/hud/advanced/proc/switch_mode(mode_type)
	if(current_mode)
		apply_effects(current_mode, FALSE)
	if(current_mode == mode_type)
		current_mode = null
		return

	apply_effects(mode_type, TRUE)
	current_mode = mode_type

/obj/item/clothing/glasses/sunglasses/hud/advanced/proc/upgrade_hud(obj/item/hud_upgrade/hud_upgrade, mob/living/user)
	switch(hud_upgrade.tier)
		if(HUD_UPGRADE_MEDSCAN)
			item_state = "mixhud"
			item_state_inventory = "mixhud"
			item_state_world = "mixhud_w"
			hud_types.Add(DATA_HUD_MEDICAL_ADV)
			def_hud_types.Add(DATA_HUD_MEDICAL_ADV)
		if(HUD_UPGRADE_NIGHTVISION)
			item_state = "nvghud"
			item_state_inventory = "nvghud"
			item_state_world = "nvghud_w"
			item_actions.Add(new /datum/action/item_action/hands_free/switch_hud_modes/night(src))
		if(HUD_UPGRADE_THERMAL)
			item_state = "thermalhud"
			item_state_inventory = "thermalhud"
			item_state_world = "thermalhud_w"
			item_actions.Add(new /datum/action/item_action/hands_free/switch_hud_modes/thermal(src))
		if(HUD_UPGRADE_THERMAL_ADVANCED)
			item_state = "thermalhudadv"
			item_state_inventory = "thermalhudadv"
			item_state_world = "thermalhudadv_w"
			for(var/datum/action/item_action/hands_free/switch_hud_modes/night/night_action in item_actions)
				night_action.Remove(user)
				item_actions.Remove(night_action)
			for(var/datum/action/item_action/hands_free/switch_hud_modes/thermal/thermal_action in item_actions)
				thermal_action.Remove(user)
				item_actions.Remove(thermal_action)
			item_actions.Add(new /datum/action/item_action/hands_free/switch_hud_modes/thermal_advanced(src))

	upgrade_tier = hud_upgrade.tier
	update_world_icon()
	add_item_actions(user)

/obj/item/clothing/glasses/sunglasses/hud/advanced/attackby(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/hud_upgrade))
		var/obj/item/hud_upgrade/hud_upgrade = W
		if(upgrade_tier >= hud_upgrade.tier)
			to_chat(usr, "<span class='notice'>You've already installed that upgrade</span>")
			return
		if(upgrade_tier < hud_upgrade.tier - 1)
			to_chat(usr, "<span class='alert'>You have to install previous upgrades</span>")
			return
		if(user.is_in_hands(src))
			upgrade_hud(hud_upgrade, user)
			add_item_actions(user)
		else
			to_chat(usr, "<span class='alert'>You have to hold huds in hands to upgrade it</span>")
			return
		qdel(hud_upgrade)
	if(istype(W, /obj/item/device/hud_calibrator))
		var/obj/item/device/hud_calibrator = W
		to_chat(usr, "<span class='alert'>You try to recalibrate huds, but nothing happens</span>")
		qdel(hud_calibrator)
	. = ..()

/obj/item/hud_upgrade
	icon = 'icons/obj/item_upgrades.dmi'
	var/tier = 0
/obj/item/hud_upgrade/medscan
	name = "Damage Scan Upgrade"
	desc = "Allows HUD to show damage on person."
	item_state_inventory = "medscan"
	item_state_world = "medscan_w"
	tier = 1
/obj/item/hud_upgrade/night
	name = "Basic Nightvision HUD upgrade"
	desc = "Allows HUD to turn a basic nightvision mode. Can be installed only after damage scan upgrade"
	item_state_inventory = "nightvision"
	item_state_world = "nightvision_w"
	tier = 2
/obj/item/hud_upgrade/thermal
	name = "Thermal HUD upgrade"
	desc = "Allows HUD to turn a basic thermal mode, makes nightvision mode more comfortable for use. Can be installed only after basic nightvision upgrade"
	item_state_inventory = "thermal"
	item_state_world = "thermal_w"
	tier = 3
/obj/item/hud_upgrade/thermal_advanced
	name = "Advanced Thermal HUD upgrade"
	desc = "Makes thermal mode comfortable and combines it with nightvision mode. Can be installed only after thermal upgrade"
	item_state_inventory = "thermaladv"
	item_state_world = "thermaladv_w"
	tier = 4

/datum/action/item_action/hands_free/switch_hud_modes
	name = "Switch Mode"
	button_overlay_icon = 'icons/obj/clothing/goggles.dmi'
	var/hud_mode

/datum/action/item_action/hands_free/switch_hud_modes/Activate()
	var/obj/item/clothing/glasses/sunglasses/hud/advanced/hud = target
	if(!hud_mode || !istype(hud))
		return

	hud.switch_mode(hud_mode)

/datum/action/item_action/hands_free/switch_hud_modes/night
	name = "Toggle Nightvision"
	button_overlay_state = "nvghud"
	hud_mode = HUD_TOGGLEABLE_MODE_NIGHTVISION

/datum/action/item_action/hands_free/switch_hud_modes/thermal //only thermal
	name = "Toggle thermal"
	button_overlay_state = "thermalhud"
	hud_mode = HUD_TOGGLEABLE_MODE_THERMAL

/datum/action/item_action/hands_free/switch_hud_modes/thermal_advanced //mixed thermal and nightvision
	name = "Toggle Advanced Thermal"
	button_overlay_state = "thermalhudadv"
	hud_mode = HUD_TOGGLEABLE_MODE_THERMAL_ADVANCED

#undef HUD_UPGRADE_MEDSCAN
#undef HUD_UPGRADE_NIGHTVISION
#undef HUD_UPGRADE_THERMAL
#undef HUD_UPGRADE_THERMAL_ADVANCED
#undef HUD_TOGGLEABLE_MODE_NIGHTVISION
#undef HUD_TOGGLEABLE_MODE_THERMAL
#undef HUD_TOGGLEABLE_MODE_THERMAL_ADVANCED
