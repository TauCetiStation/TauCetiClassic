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
	icon_state = "secmedhud"
	body_parts_covered = 0
	hud_types = list(DATA_HUD_SECURITY)
	item_action_types = list()
	var/upgrade_tier = 0
	var/current_mode = null

/obj/item/clothing/glasses/sunglasses/hud/advanced/proc/apply_effects(var/mode_type, var/enable)
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/human = usr
	switch(mode_type)
		if(HUD_TOGGLEABLE_MODE_NIGHTVISION)
			if(enable)
				lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
				sightglassesmod = "nightsight"
				darkness_view = 7
			else
				lighting_alpha = null
				sightglassesmod = null
				darkness_view = 0
		if(HUD_TOGGLEABLE_MODE_THERMAL)
			if(enable)
				lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
				sightglassesmod = "sepia"
				vision_flags = SEE_MOBS

			else
				lighting_alpha = null
				sightglassesmod = null
				vision_flags = 0

		if(HUD_TOGGLEABLE_MODE_THERMAL_ADVANCED)
			if(enable)
				lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
				darkness_view = 7
				vision_flags = SEE_MOBS
			else
				lighting_alpha = null
				darkness_view = 0
				vision_flags = 0

	playsound(src, activation_sound, VOL_EFFECTS_MASTER, 10, FALSE)
	human.update_sight()
	update_item_actions()


/obj/item/clothing/glasses/sunglasses/hud/advanced/proc/switch_mode(var/mode_type)
	if(current_mode)
		apply_effects(current_mode, FALSE)
	if(current_mode == mode_type)
		current_mode = null
		return

	apply_effects(mode_type, TRUE)
	current_mode = mode_type

/obj/item/clothing/glasses/sunglasses/hud/advanced/proc/upgrade_hud(var/obj/item/hud_upgrade/hud_upgrade)
	switch(hud_upgrade.tier)
		if(HUD_UPGRADE_MEDSCAN)
			hud_types.Add(DATA_HUD_MEDICAL)
			def_hud_types.Add(DATA_HUD_MEDICAL)
		if(HUD_UPGRADE_NIGHTVISION)
			item_actions.Add(new /datum/action/item_action/hands_free/switch_hud_modes/night(src))
		if(HUD_UPGRADE_THERMAL)
			item_actions.Add(new /datum/action/item_action/hands_free/switch_hud_modes/thermal(src))
		if(HUD_UPGRADE_THERMAL_ADVANCED)
			item_actions.Add(new /datum/action/item_action/hands_free/switch_hud_modes/thermal_advanced(src))
	upgrade_tier = hud_upgrade.tier

/obj/item/clothing/glasses/sunglasses/hud/advanced/attackby(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/hud_upgrade))
		var/obj/item/hud_upgrade/hud_upgrade = W
		if(upgrade_tier >= hud_upgrade.tier)
			to_chat(usr, "<span class='notice'>You've already installed that upgrade")
			return
		if(upgrade_tier < hud_upgrade.tier - 1)
			to_chat(usr, "<span class='alert'>You have to install previous upgrades")
			return
		if(user.is_in_hands(src))
			upgrade_hud(hud_upgrade)
			add_item_actions(user)
		else
			to_chat(usr, "<span class='alert'>You have to hold huds in hands to upgrade it")
			return
		qdel(hud_upgrade)
	. = ..()

/obj/item/hud_upgrade
	icon = 'icons/obj/item_upgrades.dmi'
	var/tier = 0
/obj/item/hud_upgrade/medscan
	name = "Damage Scan Upgrade"
	desc = "Allows HUD to show damage on person."
	icon_state = "medscan"
	tier = 1
/obj/item/hud_upgrade/night
	name = "Basic Nightvision HUD upgrade"
	desc = "Allows HUD to turn a basic nightvision mode. Can be installed only after damage scan upgrade"
	icon_state = "nightvision"
	tier = 2
/obj/item/hud_upgrade/thermal
	name = "Thermal HUD upgrade"
	desc = "Allows HUD to turn a basic thermal mode, makes nightvision mode more comfortable for use. Can be installed only after basic nightvision upgrade"
	icon_state = "thermal1"
	tier = 3
/obj/item/hud_upgrade/thermal_advanced
	name = "Advanced Thermal HUD upgrade"
	desc = "Makes thermal mode comfortable and combines it with nightvision mode. Can be installed only after thermal upgrade"
	icon_state = "thermal2"
	tier = 4

/datum/action/item_action/hands_free/switch_hud_modes/
	name = "Switch Mode"
	button_overlay_icon = 'icons/obj/clothing/glasses.dmi'
	var/hud_mode

/datum/action/item_action/hands_free/switch_hud_modes/Activate()
	var/obj/item/clothing/glasses/sunglasses/hud/advanced/hud = target
	if(!hud_mode || !istype(hud))
		return

	hud.switch_mode(hud_mode)

/datum/action/item_action/hands_free/switch_hud_modes/night
	name = "Toggle Nightvision"
	button_overlay_state = "night"
	hud_mode = HUD_TOGGLEABLE_MODE_NIGHTVISION

/datum/action/item_action/hands_free/switch_hud_modes/thermal //only thermal
	name = "Toggle thermal"
	button_overlay_state = "thermal"
	hud_mode = HUD_TOGGLEABLE_MODE_THERMAL

/datum/action/item_action/hands_free/switch_hud_modes/thermal_advanced //mixed thermal and nightvision
	name = "Toggle Advanced Thermal"
	button_overlay_state = "material"
	hud_mode = HUD_TOGGLEABLE_MODE_THERMAL_ADVANCED

#undef HUD_UPGRADE_MEDSCAN
#undef HUD_UPGRADE_NIGHTVISION
#undef HUD_UPGRADE_THERMAL
#undef HUD_UPGRADE_THERMAL_ADVANCED
#undef HUD_TOGGLEABLE_MODE_NIGHTVISION
#undef HUD_TOGGLEABLE_MODE_THERMAL
#undef HUD_TOGGLEABLE_MODE_THERMAL_ADVANCED
