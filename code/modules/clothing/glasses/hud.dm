/obj/item/clothing/glasses/hud
	name = "HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags = null //doesn't protect eyes because it's a monocle, duh
	origin_tech = "magnets=3;biotech=2"

/obj/item/clothing/glasses/proc/enable_hud(mob/living/carbon/human/user)
	if(!hud_types)
		return

	user.set_broken_hud_icon()
	for(var/hud in hud_types)
		var/datum/atom_hud/H = global.huds[hud]
		H.add_hud_to(user)
		for(var/parasit in user.parasites)
			H.add_hud_to(parasit)

/obj/item/clothing/glasses/proc/disable_hud(mob/living/carbon/human/user)
	if(!hud_types)
		return

	for(var/hud in hud_types)
		var/datum/atom_hud/H = global.huds[hud]
		H.remove_hud_from(user)
		for(var/parasit in user.parasites)
			H.remove_hud_from(parasit)

/obj/item/clothing/glasses/hud/equipped(mob/living/carbon/human/user, slot)
	..()
	if(slot != SLOT_GLASSES)
		return
	enable_hud(user)
	glasses_user = user

/obj/item/clothing/glasses/hud/dropped(mob/living/carbon/human/user)
	..()
	if(!istype(user) || user.glasses)
		return
	disable_hud(user)
	glasses_user = null

/obj/item/clothing/glasses/proc/broke_hud(mob/living/carbon/human/user)
	if(!hud_types)
		return
	hud_types = list(DATA_HUD_BROKEN)

/obj/item/clothing/glasses/proc/fix_hud()
	if(glasses_user)
		disable_hud(glasses_user)
	hud_types = def_hud_types
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
		addtimer(CALLBACK(src, PROC_REF(fix_hud)), (90 SECONDS) / severity)

/obj/item/clothing/glasses/hud/health
	name = "health scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	icon_state = "healthhud"
	body_parts_covered = 0
	hud_types = list(DATA_HUD_MEDICAL)


/obj/item/clothing/glasses/hud/health/vox
	name = "health scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	icon_state = "material"
	body_parts_covered = 0


/obj/item/clothing/glasses/hud/security
	name = "security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	body_parts_covered = 0
	hud_types = list(DATA_HUD_SECURITY)

/obj/item/clothing/glasses/hud/diagnostic
	name = "diagnostic goggles"
	desc = "You can see information about mechs and metal friends!"
	icon_state = "diagnostichud"
	item_state = "diagnostichud"
	origin_tech = "engineering=2;programming=2"
	toggleable = 1
	sightglassesmod = "sepia"
	hud_types = list(DATA_HUD_DIAGNOSTIC)
	item_action_types = list(/datum/action/item_action/hands_free/toggle_goggles)

/obj/item/clothing/glasses/hud/diagnostic/equipped(mob/living/user, slot)
	. = ..()
	if(slot == SLOT_GLASSES)
		to_chat(user, "<span class='info'>Вы можете получать очки исследований, проводя диагностику изобретений, связанных с роботами. Осматривайте объекты в этих очках.</span>")

/datum/action/item_action/hands_free/toggle_goggles
	name = "Toggle Goggles"

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
		addtimer(CALLBACK(src, PROC_REF(fix_hud)), (90 SECONDS) / severity)

/obj/item/clothing/glasses/sunglasses/hud/equipped(mob/living/carbon/human/user, slot)
	..()
	if(slot != SLOT_GLASSES)
		return
	glasses_user = user
	enable_hud(user)

/obj/item/clothing/glasses/sunglasses/hud/dropped(mob/living/carbon/human/user)
	..()
	if(!istype(user) || user.glasses)
		return
	glasses_user = null
	disable_hud(user)

/obj/item/clothing/glasses/sunglasses/hud/secmed
	name = "mixed HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and health status."
	icon_state = "secmedhud"
	body_parts_covered = 0
	hud_types = list(DATA_HUD_MEDICAL, DATA_HUD_SECURITY)

/obj/item/clothing/glasses/sunglasses/hud/med
	name = "MEDHUD sunglasses"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	icon_state = "sunmedhud"
	body_parts_covered = 0
	hud_types = list(DATA_HUD_MEDICAL)

/obj/item/device/hud_calibrator
	name = "Рекалибратор дисплея"
	desc = "Рекалибрует дисплей с помощью интерференции волн, улучшая опыт пользования визуальным интерфейсом."
	icon = 'icons/obj/device.dmi'
	icon_state = "motion2"

/obj/item/clothing/glasses/attackby(obj/item/device/hud_calibrator/W, mob/living/user)
	if(!istype(W))
		return ..()
	if(sightglassesmod == null)
		to_chat(user, "<span class='notice'>Внедрение калибратора не принесло никакого эффекта</span>")
		return
	sightglassesmod = null
	qdel(W)
