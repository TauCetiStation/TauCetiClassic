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
	var/obj/item/clothing/glasses/hud/health/mech/hud

/obj/mecha/medical/odysseus/atom_init()
	. = ..()
	hud = new /obj/item/clothing/glasses/hud/health/mech(src)

/obj/mecha/medical/odysseus/moved_inside(mob/living/carbon/human/H)
	if(..())
		if(H.glasses)
			occupant_message("<font color='red'>[H.glasses] prevent you from using [src] [hud]</font>")
		else
			H.glasses = hud
		return 1
	else
		return 0

/obj/mecha/medical/odysseus/go_out()
	if(ishuman(occupant))
		var/mob/living/carbon/human/H = occupant
		if(H.glasses == hud)
			H.glasses = null
	..()

//TODO - Check documentation for client.eye and client.perspective...
/obj/item/clothing/glasses/hud/health/mech
	name = "Integrated Medical Hud"


/obj/item/clothing/glasses/hud/health/mech/process_hud(mob/M)

	if(!M || M.stat || !(M in view(M)))
		return
	if(!M.client)
		return
	var/client/C = M.client
	var/image/holder
	for(var/mob/living/carbon/human/patient in view(M.loc))
		if(M.see_invisible < patient.invisibility)
			continue
		var/foundVirus = 0
		for(var/datum/disease/D in patient.viruses)
			if(!D.hidden[SCANNER])
				foundVirus++

		for (var/ID in patient.virus2)
			if (ID in virusDB)
				foundVirus = 1
				break

		holder = patient.hud_list[HEALTH_HUD]
		if(patient.stat == DEAD)
			holder.icon_state = "hudhealth-100"
			C.images += holder
		else
			holder.icon_state = "hud[RoundHealth(patient.health)]"
			C.images += holder

		holder = patient.hud_list[STATUS_HUD]
		if(patient.stat == DEAD)
			holder.icon_state = "huddead"
		else if(patient.status_flags & XENO_HOST)
			holder.icon_state = "hudxeno"
		else if(foundVirus || iszombie(patient))
			holder.icon_state = "hudill"
		else if(patient.has_brain_worms())
			var/mob/living/simple_animal/borer/B = patient.has_brain_worms()
			if(B.controlling)
				holder.icon_state = "hudbrainworm"
			else
				holder.icon_state = "hudhealthy"
		else
			holder.icon_state = "hudhealthy"

		C.images += holder
