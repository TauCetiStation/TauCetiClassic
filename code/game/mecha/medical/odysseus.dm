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
	// TODO: FUCK THIS AND REWORK HERE
	var/obj/item/clothing/glasses/hud/health/mech/hud

/obj/mecha/medical/odysseus/atom_init()
	. = ..()
	// TODO: FUCK THIS AND REWORK HERE
	hud = new /obj/item/clothing/glasses/hud/health/mech(src)

/obj/mecha/medical/odysseus/moved_inside(mob/living/carbon/human/H)
	if(..())
		// TODO: FUCK THIS AND REWORK HERE
		if(H.glasses)
			occupant_message("<font color='red'>[H.glasses] prevent you from using [src] [hud]</font>")
		else
			H.glasses = hud
		return 1
	else
		return 0
