/obj/item/clothing/glasses/hud
	name = "HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags = null //doesn't protect eyes because it's a monocle, duh
	origin_tech = "magnets=3;biotech=2"

/obj/item/clothing/glasses/proc/enable_hud(mob/living/carbon/human/user)
	if(!hud_type)
		return

	user.set_broken_hud_icon()
	if(hud_type)
		var/datum/atom_hud/H = global.huds[hud_type]
		H.add_hud_to(user)
		for(var/parasit in user.parasites)
			H.add_hud_to(parasit)

	if(hud_type_1)
		var/datum/atom_hud/H = global.huds[hud_type_1]
		H.add_hud_to(user)
		for(var/parasit in user.parasites)
			H.add_hud_to(parasit)

/obj/item/clothing/glasses/proc/disable_hud(mob/living/carbon/human/user)
	if(!hud_type)
		return

	if(hud_type)
		var/datum/atom_hud/H = global.huds[hud_type]
		H.remove_hud_from(user)
		for(var/parasit in user.parasites)
			H.remove_hud_from(parasit)

	if(hud_type_1)
		var/datum/atom_hud/H = global.huds[hud_type_1]
		H.remove_hud_from(user)
		for(var/parasit in user.parasites)
			H.remove_hud_from(parasit)

/obj/item/clothing/glasses/hud/equipped(mob/living/carbon/human/user, slot)
	if(slot != SLOT_GLASSES)
		return
	enable_hud(user)
	glasses_user = user

/obj/item/clothing/glasses/hud/dropped(mob/living/carbon/human/user)
	if(!istype(user))
		return
	disable_hud(user)
	glasses_user = null

/obj/item/clothing/glasses/proc/broke_hud(mob/living/carbon/human/user)
	if(!hud_type)
		return
	hud_type = DATA_HUD_BROKEN
	hud_type_1 = DATA_HUD_BROKEN

/obj/item/clothing/glasses/proc/fix_hud()
	if(glasses_user)
		disable_hud(glasses_user)
	hud_type = initial(hud_type)
	hud_type_1 = initial(hud_type_1)
	if(glasses_user)
		enable_hud(glasses_user)
	crit_fail = 0

/obj/item/clothing/glasses/hud/emp_act(severity)
	if(!crit_fail)
		crit_fail = 1
		if(glasses_user)
			disable_hud(glasses_user)
		broke_hud()
		if(glasses_user)
			enable_hud(glasses_user)
		addtimer(CALLBACK(src, .proc/fix_hud), (90 SECONDS) / severity)

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

/obj/item/clothing/glasses/hud/diagnostic
	name = "diagnostic goggles"
	desc = "You can see information about mechs and metal friends!"
	icon_state = "diagnostichud"
	item_state = "diagnostichud"
	origin_tech = "engineering=2;programming=2"
	action_button_name = "Toggle Goggles"
	toggleable = 1
	sightglassesmod = "sepia"
	hud_type = DATA_HUD_DIAGNOSTIC

/obj/item/clothing/glasses/hud/security/jensenshades
	name = "augmented shades"
	desc = "Polarized bioneural eyewear, designed to augment your vision."
	icon_state = "hos_shades"
	item_state = "hos_shades"
	vision_flags = SEE_MOBS
	invisa_view = 3

// Why need this class?
/obj/item/clothing/glasses/sunglasses/hud
	name = "sunglasses-HUD"

/obj/item/clothing/glasses/sunglasses/hud/emp_act(severity)
	if(!crit_fail)
		crit_fail = 1
		if(glasses_user)
			disable_hud(glasses_user)
		broke_hud()
		if(glasses_user)
			enable_hud(glasses_user)
		addtimer(CALLBACK(src, .proc/fix_hud), (90 SECONDS) / severity)

/obj/item/clothing/glasses/sunglasses/hud/equipped(mob/living/carbon/human/user, slot)
	if(slot != SLOT_GLASSES)
		return
	glasses_user = user
	enable_hud(user)

/obj/item/clothing/glasses/sunglasses/hud/dropped(mob/living/carbon/human/user)
	if(!istype(user))
		return
	glasses_user = null
	disable_hud(user)

/obj/item/clothing/glasses/sunglasses/hud/secmed
	name = "mixed HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and health status."
	icon_state = "secmedhud"
	body_parts_covered = 0
	hud_type_1 = DATA_HUD_SECURITY
	hud_type = DATA_HUD_MEDICAL
