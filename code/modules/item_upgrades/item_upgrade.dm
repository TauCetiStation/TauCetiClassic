#define HUD_UPGRADE_MEDSCAN 1
#define HUD_UPGRADE_NIGHTVISION 2
#define HUD_UPGRADE_THERMAL 3
#define HUD_UPGRADE_THERMAL_ADVANCED 4

/obj/item/clothing/glasses/sunglasses/hud/advanced
	name = "mixed HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and health status."
	icon_state = "secmedhud"
	body_parts_covered = 0
	hud_types = list(DATA_HUD_SECURITY)
	item_action_types = list()
	var/upgrade_tier = 0

/obj/item/clothing/glasses/sunglasses/hud/advanced/proc/toggle_hud_mode(var/mode_type)
	switch(mode_type)
		if("night")
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				if(src.darkness_view)
					src.lighting_alpha = null
					src.sightglassesmod = null
					src.darkness_view = 0
				else
					src.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
					src.sightglassesmod = "nightsight"
					src.darkness_view = 7
				playsound(src, activation_sound, VOL_EFFECTS_MASTER, 10, FALSE)
				H.update_sight()
				update_item_actions()

/obj/item/clothing/glasses/sunglasses/hud/advanced/attackby(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/hud_upgrade))
		var/obj/item/hud_upgrade/hud_upgrade = W
		if(upgrade_tier >= hud_upgrade.tier)
			to_chat(usr, "<span class='notice'>You've already installed that upgrade")
			return
		if(upgrade_tier < hud_upgrade.tier - 1)
			to_chat(usr, "<span class='alert'>You have to install previous upgrades")
			return
		switch(hud_upgrade.tier)
			if(HUD_UPGRADE_MEDSCAN)
				hud_types.Add(DATA_HUD_MEDICAL)
			if(HUD_UPGRADE_NIGHTVISION)
				item_actions.Add(new /datum/action/item_action/hands_free/switch_hud_modes/night(src))
		upgrade_tier = hud_upgrade.tier
		update_item_actions()
		qdel(hud_upgrade)
	. = ..()

/obj/item/hud_upgrade
	icon = 'icons/obj/item_upgrades.dmi'
	var/tier = 0
/obj/item/hud_upgrade/hud1
	name = "Damage Scan Upgrade"
	desc = "Allows HUD to show damage on person."
	icon_state = "medscan"
	tier = 1
/obj/item/hud_upgrade/hud2
	name = "Basic Nightvision HUD upgrade"
	desc = "Allows HUD to turn a basic nightvision mode. Can be installed only after damage scan upgrade"
	icon_state = "nightvision"
	tier = 2
/obj/item/hud_upgrade/hud3
	name = "Thermal HUD upgrade"
	desc = "Allows HUD to turn a basic thermal mode, makes nightvision mode more comfortable for use. Can be installed only after basic nightvision upgrade"
	icon_state = "thermal1"
	tier = 3
/obj/item/hud_upgrade/hud4
	name = "Advanced Thermal HUD upgrade"
	desc = "Makes thermal mode comfortable and combines it with nightvision mode. Can be installed only after thermal upgrade"
	icon_state = "thermal2"
	tier = 4

/datum/action/item_action/hands_free/switch_hud_modes/
	name = "Switch Mode"
	button_icon = 'icons/obj/clothing/glasses.dmi'

/datum/action/item_action/hands_free/switch_hud_modes/night
	name = "Toggle Nightvision"
	button_icon_state = "night"

/datum/action/item_action/hands_free/switch_hud_modes/night/Activate()
	var/obj/item/clothing/glasses/sunglasses/hud/advanced/hud = target
	hud.toggle_hud_mode("night")

/datum/action/item_action/hands_free/switch_hud_modes/thermal1 //only thermal
	name = "Toggle thermal"
	button_icon_state = "thermal"

/datum/action/item_action/hands_free/switch_hud_modes/thermal1/Activate()
	// if(ishuman(usr))
	// 	var/mob/living/carbon/human/H = usr
	// 	var/obj/item/clothing/glasses/glasses = target
	// 	glasses.darkness_view = 0
	// 	if(glasses.vision_flags)
	// 		glasses.lighting_alpha = null
	// 		glasses.sightglassesmod = null
	// 		glasses.vision_flags = 0
	// 		glasses.invisa_view = 0
	// 	else
	// 		glasses.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	// 		glasses.sightglassesmod = "thermal"
	// 		glasses.vision_flags = SEE_MOBS
	// 		glasses.invisa_view = 2
	// 	playsound(src, activation_sound, VOL_EFFECTS_MASTER, 10, FALSE)
	// 	H.update_sight()
	// 	update_item_actions()

/datum/action/item_action/hands_free/switch_hud_modes/thermal2 //mixed thermal and nightvision
	name = "Toggle Advanced Thermal"
	button_icon_state = "material"

/datum/action/item_action/hands_free/switch_hud_modes/thermal2/Activate()
	// if(ishuman(usr))
	// 	var/obj/item/clothing/glasses/glasses = target
	// 	glasses.sightglassesmod = null
	// 	var/mob/living/carbon/human/H = usr
	// 	if(glasses.lighting_alpha == LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
	// 		glasses.lighting_alpha = null
	// 		glasses.vision_flags = 0
	// 		glasses.invisa_view = 0
	// 		glasses.darkness_view = 0
	// 	else
	// 		glasses.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	// 		glasses.vision_flags = SEE_MOBS
	// 		glasses.invisa_view = 2
	// 		glasses.darkness_view = 7
	// 	playsound(src, activation_sound, VOL_EFFECTS_MASTER, 10, FALSE)
	// 	H.update_sight()
	// 	update_item_actions()
