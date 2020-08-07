/obj/item/clothing/glasses/hud
	name = "HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags = null //doesn't protect eyes because it's a monocle, duh
	origin_tech = "magnets=3;biotech=2"
	var/fixtime = 0
	var/list/icon/current = list() //the current hud icons
	var/hud_type = null

/obj/item/clothing/glasses/hud/equipped(mob/living/carbon/human/user, slot)
	if(slot != SLOT_GLASSES)
		return
	if(hud_type)
		var/datum/atom_hud/H = global.huds[hud_type]
		H.add_hud_to(user)
		for(var/parasit in user.parasites)
			H.add_hud_to(parasit)

/obj/item/clothing/glasses/hud/dropped(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(hud_type)
		var/datum/atom_hud/H = global.huds[hud_type]
		H.remove_hud_from(user)
		for(var/parasit in user.parasites)
			H.remove_hud_from(parasit)

/obj/item/clothing/glasses/hud/set_prototype_qualities(rel_val=100, mark=0)
	..()
	fixtime = -1

/obj/item/clothing/glasses/hud/broken
	fixtime = -1

/obj/item/clothing/glasses/hud/emp_act(severity)
	if(!crit_fail)
		crit_fail = 1
		fixtime = world.time + 900 / severity

/obj/item/clothing/glasses/hud/health
	name = "health scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	icon_state = "healthhud"
	body_parts_covered = 0
	hud_type = DATA_HUD_MEDICAL

/obj/item/clothing/glasses/hud/security
	name = "security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	body_parts_covered = 0
	hud_type = DATA_HUD_SECURITY

/obj/item/clothing/glasses/hud/security/jensenshades
	name = "augmented shades"
	desc = "Polarized bioneural eyewear, designed to augment your vision."
	icon_state = "hos_shades"
	item_state = "hos_shades"
	vision_flags = SEE_MOBS
	invisa_view = 3

// TODO: FUCK THIS AND REWORK HERE
/obj/item/clothing/glasses/hud/proc/check_integrity()
	if(!crit_fail)
		return
	if(fixtime == -1)
		return
	if(fixtime < world.time)
		crit_fail = 0

/obj/item/clothing/glasses/hud/emp_act(severity)
	if(!crit_fail)
		crit_fail = 1
		fixtime = world.time + 900 / severity

// Why need this class?
/obj/item/clothing/glasses/sunglasses/hud
	name = "sunglasses-HUD"
	var/hud_type = null

/obj/item/clothing/glasses/sunglasses/hud/equipped(mob/living/carbon/human/user, slot)
	if(slot != SLOT_GLASSES)
		return
	if(hud_type)
		var/datum/atom_hud/H = global.huds[hud_type]
		H.add_hud_to(user)
		for(var/parasit in user.parasites)
			H.add_hud_to(parasit)

/obj/item/clothing/glasses/sunglasses/hud/dropped(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(hud_type)
		var/datum/atom_hud/H = global.huds[hud_type]
		H.remove_hud_from(user)
		for(var/parasit in user.parasites)
			H.remove_hud_from(parasit)

//TODO: FUCK THIS AND SECMED
/obj/item/clothing/glasses/sunglasses/hud/secmed
	name = "mixed HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and health status."
	icon_state = "secmedhud"
	body_parts_covered = 0
	var/fixtime = 0