//Methods that need to be cleaned.
/* INFORMATION
Put (mob/proc)s here that are in dire need of a code cleanup.
*/

/mob/proc/has_disease(datum/disease/virus)
	for(var/datum/disease/D in viruses)
		if(D.IsSame(virus))
			//error("[D.name]/[D.type] is the same as [virus.name]/[virus.type]")
			return 1
	return 0

// This proc has some procs that should be extracted from it. I believe we can develop some helper procs from it - Rockdtben
/mob/proc/contract_disease(datum/disease/virus, skip_this = 0, force_species_check=1, spread_type = -5)
	//world << "Contract_disease called by [src] with virus [virus]"
	if(stat >=2)
		//world << "He's dead jim."
		return
	if(istype(virus, /datum/disease/advance))
		//world << "It's an advance virus."
		var/datum/disease/advance/A = virus
		if(A.GetDiseaseID() in resistances)
			//world << "It resisted us!"
			return
		if(count_by_type(viruses, /datum/disease/advance) >= 3)
			return

	else
		if(src.resistances.Find(virus.type))
			//world << "Normal virus and resisted"
			return


	if(has_disease(virus))
		return


	if(force_species_check)
		var/fail = 1
		for(var/name in virus.affected_species)
			var/mob_type = text2path("/mob/living/carbon/[lowertext(name)]")
			if(mob_type && istype(src, mob_type))
				fail = 0
				break
		if(fail) return

	if(skip_this == 1)
		//world << "infectin"
		//if(src.virus)				< -- this used to replace the current disease. Not anymore!
			//src.virus.cure(0)
		var/datum/disease/v = new virus.type(1, virus, 0)
		src.viruses += v
		v.affected_mob = src
		v.strain_data = v.strain_data.Copy()
		v.holder = src
		if(v.can_carry && prob(5))
			v.carrier = 1
		return
	//world << "Not skipping."
	//if(src.virus) //
		//return //


/*
	var/list/clothing_areas	= list()
	var/list/covers = list(UPPER_TORSO,LOWER_TORSO,LEGS,FEET,ARMS,HANDS)
	for(var/Covers in covers)
		clothing_areas[Covers] = list()

	for(var/obj/item/clothing/Clothing in src)
		if(Clothing)
			for(var/Covers in covers)
				if(Clothing&Covers)
					clothing_areas[Covers] += Clothing

*/
	if(prob(15/virus.permeability_mod)) return //the power of immunity compels this disease! but then you forgot resistances
	//world << "past prob()"
	var/obj/item/clothing/Cl = null
	var/passed = 1

	//chances to target this zone
	var/head_ch
	var/body_ch
	var/hands_ch
	var/feet_ch

	if(spread_type == -5)
		spread_type = virus.spread_type

	switch(spread_type)
		if(CONTACT_HANDS)
			head_ch = 0
			body_ch = 0
			hands_ch = 100
			feet_ch = 0
		if(CONTACT_FEET)
			head_ch = 0
			body_ch = 0
			hands_ch = 0
			feet_ch = 100
		else
			head_ch = 100
			body_ch = 100
			hands_ch = 25
			feet_ch = 25


	var/target_zone = pick(head_ch;1,body_ch;2,hands_ch;3,feet_ch;4)//1 - head, 2 - body, 3 - hands, 4- feet

	if(iscarbon(src))
		var/mob/living/carbon/C = src

		switch(target_zone) // TODO properly deal with that.
			if(1)
				var/obj/item/head = C.get_equipped_item(slot_head)
				var/obj/item/wear_mask = C.get_equipped_item(slot_wear_mask)
				if(isobj(head) && !istype(head, /obj/item/weapon/paper))
					Cl = head
					passed = prob((Cl.permeability_coefficient*100) - 1)
				if(passed && isobj(wear_mask))
					Cl = wear_mask
					passed = prob((Cl.permeability_coefficient*100) - 1)
			if(2)//arms and legs included
				var/obj/item/wear_suit = C.get_equipped_item(slot_wear_suit)
				var/obj/item/w_uniform = C.get_equipped_item(slot_w_uniform)
				if(isobj(wear_suit))
					Cl = wear_suit
					passed = prob((Cl.permeability_coefficient*100) - 1)
				if(passed && isobj(w_uniform))
					Cl = w_uniform
					passed = prob((Cl.permeability_coefficient*100) - 1)
			if(3)
				var/obj/item/wear_suit = C.get_equipped_item(slot_wear_suit)
				var/obj/item/gloves = C.get_equipped_item(slot_gloves)
				if(isobj(wear_suit) && (wear_suit.body_parts_covered & HANDS))
					Cl = wear_suit
					passed = prob((Cl.permeability_coefficient*100) - 1)
				if(passed && isobj(gloves))
					Cl = gloves
					passed = prob((Cl.permeability_coefficient*100) - 1)
			if(4)
				var/obj/item/wear_suit = C.get_equipped_item(slot_wear_suit)
				var/obj/item/shoes = C.get_equipped_item(slot_shoes)
				if(isobj(wear_suit) && (wear_suit.body_parts_covered & FEET))
					Cl = wear_suit
					passed = prob((Cl.permeability_coefficient*100) - 1)
				if(passed && isobj(shoes))
					Cl = shoes
					passed = prob((Cl.permeability_coefficient*100) - 1)
			else
				to_chat(src, "Something strange's going on, something's wrong.")

			/*if("feet")
				if(H.shoes && istype(H.shoes, /obj/item/clothing/))
					Cl = H.shoes
					passed = prob(Cl.permeability_coefficient*100)
					//
					to_chat(world, "Shoes pass [passed]")
			*/		//

	if(!passed && spread_type == AIRBORNE && !internals)
		passed = (prob((50*virus.permeability_mod) - 1))

	if(passed)
		//world << "Infection in the mob [src]. YAY"

		var/datum/disease/v = new virus.type(1, virus, 0)
		src.viruses += v
		v.affected_mob = src
		v.strain_data = v.strain_data.Copy()
		v.holder = src
		if(v.can_carry && prob(5))
			v.carrier = 1
		return
	return
