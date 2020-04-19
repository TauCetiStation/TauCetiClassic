/obj/item/clothing/glasses/hud
	name = "HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags = null //doesn't protect eyes because it's a monocle, duh
	origin_tech = "magnets=3;biotech=2"
	var/fixtime = 0
	var/list/icon/current = list() //the current hud icons

/obj/item/clothing/glasses/hud/proc/process_hud(mob/M)
	return

/obj/item/clothing/glasses/hud/set_prototype_qualities(rel_val=100, mark=0)
	..()
	fixtime = -1

/obj/item/clothing/glasses/sunglasses/hud/secmed
	name = "mixed HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and health status."
	icon_state = "secmedhud"
	body_parts_covered = 0
	var/fixtime = 0


/obj/item/clothing/glasses/sunglasses/hud/secmed/proc/process_hud(mob/M)
	if(fixtime != -1 && crit_fail && fixtime < world.time)
		crit_fail = 0
	process_med_hud(M, 1, crit_fail = crit_fail)
	process_sec_hud(M, 1, crit_fail = crit_fail)

/obj/item/clothing/glasses/hud/emp_act(severity)
	if(!crit_fail)
		crit_fail = 1
		fixtime = world.time + 900 / severity

/obj/item/clothing/glasses/hud/health
	name = "health scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	icon_state = "healthhud"
	body_parts_covered = 0


/obj/item/clothing/glasses/hud/health/process_hud(mob/M)
	check_integrity()
	process_med_hud(M, 1, crit_fail = crit_fail)

/obj/item/clothing/glasses/hud/security
	name = "security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	body_parts_covered = 0
	var/static/list/jobs[0]

/obj/item/clothing/glasses/hud/security/jensenshades
	name = "augmented shades"
	desc = "Polarized bioneural eyewear, designed to augment your vision."
	icon_state = "hos_shades"
	item_state = "hos_shades"
	vision_flags = SEE_MOBS
	invisa_view = 3

/obj/item/clothing/glasses/hud/security/process_hud(mob/M)
	check_integrity()
	process_sec_hud(M, 1, crit_fail = crit_fail)

/obj/item/clothing/glasses/hud/broken/process_hud(mob/M)
	process_broken_hud(M, 1)

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
