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

/obj/item/clothing/glasses/sunglasses/hud/advanced/atom_init()
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(handle_drop))

/obj/item/clothing/glasses/sunglasses/hud/advanced/equipped(mob/user, slot)
	. = ..()
	if(slot != SLOT_GLASSES)
		return
	apply_effects(current_mode, TRUE)

/obj/item/clothing/glasses/sunglasses/hud/advanced/proc/handle_drop(source, mob/living/carbon/human/user)
	if(!istype(user) || user.glasses)
		return
	apply_effects(current_mode, FALSE)

/obj/item/clothing/glasses/sunglasses/hud/advanced/proc/apply_effects(mode_type, enable)
	if(!ishuman(glasses_user))
		return
	if(mode_type == null)
		return
	var/datum/glasses_mode_type_state/state = glasses_states[mode_type]
	state.change_state(src, enable)
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

/obj/item/clothing/glasses/sunglasses/hud/advanced/proc/upgrade_hud(obj/item/hud_upgrade/hud_upgrader, mob/living/user)
	hud_upgrader.upgrade_hud(src, user)
	upgrade_tier = hud_upgrader.tier
	update_world_icon()
	add_item_actions(user)

/obj/item/clothing/glasses/sunglasses/hud/advanced/attackby(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/hud_upgrade))
		var/obj/item/hud_upgrade/hud_upgrade = W
		if(upgrade_tier >= hud_upgrade.tier)
			to_chat(user, "<span class='notice'>You've already installed that upgrade</span>")
			return
		if(upgrade_tier < hud_upgrade.tier - 1)
			to_chat(user, "<span class='alert'>You have to install previous upgrades</span>")
			return
		if(!user.is_in_hands(src))
			to_chat(user, "<span class='alert'>You have to hold huds in hands to upgrade it</span>")
			return
		upgrade_hud(hud_upgrade, user)
		add_item_actions(user)
		qdel(hud_upgrade)
	else if(istype(W, /obj/item/device/hud_calibrator))
		var/obj/item/device/hud_calibrator = W
		to_chat(user, "<span class='alert'>You try to recalibrate huds, but nothing happens</span>")
		qdel(hud_calibrator)
		return
	return ..()

/obj/item/hud_upgrade
	icon = 'icons/obj/item_upgrades.dmi'
	var/tier = 0
	var/glasses_item_state
	var/glasses_item_state_inventory
	var/glasses_item_state_world

/obj/item/hud_upgrade/proc/upgrade_hud(obj/item/clothing/glasses/sunglasses/hud/advanced/glasses, mob/living/user)
	if(glasses_item_state)
		glasses.item_state = glasses_item_state
	if(glasses_item_state_inventory)
		glasses.item_state_inventory = glasses_item_state_inventory
	if(glasses_item_state_world)
		glasses.item_state_world = glasses_item_state_world

/obj/item/hud_upgrade/medscan
	name = "Damage Scan Upgrade"
	desc = "Allows HUD to show damage on person."
	item_state_inventory = "medscan"
	item_state_world = "medscan_w"
	glasses_item_state = "mixhud"
	glasses_item_state_inventory = "mixhud"
	glasses_item_state_world = "mixhud_w"
	tier = HUD_UPGRADE_MEDSCAN

/obj/item/hud_upgrade/medscan/upgrade_hud(obj/item/clothing/glasses/sunglasses/hud/advanced/glasses, mob/living/user)
	..()
	glasses.hud_types.Add(DATA_HUD_MEDICAL_ADV)
	glasses.def_hud_types.Add(DATA_HUD_MEDICAL_ADV)

/obj/item/hud_upgrade/night
	name = "Basic Nightvision HUD upgrade"
	desc = "Allows HUD to turn a basic nightvision mode. Can be installed only after damage scan upgrade"
	item_state_inventory = "nightvision"
	item_state_world = "nightvision_w"
	glasses_item_state = "nvghud"
	glasses_item_state_inventory = "nvghud"
	glasses_item_state_world = "nvghud_w"
	tier = HUD_UPGRADE_NIGHTVISION

/obj/item/hud_upgrade/night/upgrade_hud(obj/item/clothing/glasses/sunglasses/hud/advanced/glasses, mob/living/user)
	..()
	glasses.item_actions.Add(new /datum/action/item_action/hands_free/switch_hud_modes/night(glasses))

/obj/item/hud_upgrade/thermal
	name = "Thermal HUD upgrade"
	desc = "Allows HUD to turn a basic thermal mode, makes nightvision mode more comfortable for use. Can be installed only after basic nightvision upgrade"
	item_state_inventory = "thermal"
	item_state_world = "thermal_w"
	glasses_item_state = "thermalhud"
	glasses_item_state_inventory = "thermalhud"
	glasses_item_state_world = "thermalhud_w"
	tier = HUD_UPGRADE_THERMAL

/obj/item/hud_upgrade/thermal/upgrade_hud(obj/item/clothing/glasses/sunglasses/hud/advanced/glasses, mob/living/user)
	..()
	glasses.item_actions.Add(new /datum/action/item_action/hands_free/switch_hud_modes/thermal(glasses))

/obj/item/hud_upgrade/thermal_advanced
	name = "Advanced Thermal HUD upgrade"
	desc = "Makes thermal mode comfortable and combines it with nightvision mode. Can be installed only after thermal upgrade"
	item_state_inventory = "thermaladv"
	item_state_world = "thermaladv_w"
	glasses_item_state = "thermalhudadv"
	glasses_item_state_inventory = "thermalhudadv"
	glasses_item_state_world = "thermalhudadv_w"
	tier = HUD_UPGRADE_THERMAL_ADVANCED

/obj/item/hud_upgrade/thermal_advanced/upgrade_hud(obj/item/clothing/glasses/sunglasses/hud/advanced/glasses, mob/living/user)
	..()
	for(var/datum/action/item_action/hands_free/switch_hud_modes/night/night_action in glasses.item_actions)
		night_action.Remove(user)
		glasses.item_actions.Remove(night_action)
	for(var/datum/action/item_action/hands_free/switch_hud_modes/thermal/thermal_action in glasses.item_actions)
		thermal_action.Remove(user)
		glasses.item_actions.Remove(thermal_action)
	glasses.item_actions.Add(new /datum/action/item_action/hands_free/switch_hud_modes/thermal_advanced(glasses))


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
