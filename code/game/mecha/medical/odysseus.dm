/obj/mecha/medical/odysseus
	desc = "These exosuits are developed and produced by Vey-Med. (&copy; All rights reserved)."
	name = "Odysseus"
	icon_state = "odysseus"
	initial_icon = "odysseus"
	step_in = 2
	max_temperature = 15000
	health = 120
	wreckage = /obj/effect/decal/mecha_wreckage/odysseus
	internal_damage_threshold = 35
	deflect_chance = 15
	step_energy_drain = 6

/obj/mecha/medical/odysseus/moved_inside(mob/living/carbon/human/H)
	. = ..()
	if(.)
		var/datum/atom_hud/hud = global.huds[DATA_HUD_MEDICAL]
		hud.add_hud_to(H)

/obj/mecha/medical/odysseus/go_out()
	if(isliving(occupant))
		var/mob/living/L = occupant
		var/datum/atom_hud/hud = global.huds[DATA_HUD_MEDICAL]
		hud.remove_hud_from(L)
	..()

/obj/mecha/medical/odysseus/mmi_moved_inside(obj/item/device/mmi/M, mob/user)
	. = ..()
	if(.)
		var/datum/atom_hud/hud = global.huds[DATA_HUD_MEDICAL]
		hud.add_hud_to(M.brainmob)
