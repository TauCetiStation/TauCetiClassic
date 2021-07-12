//Returns 1 if mob can be infected, 0 otherwise. Checks his clothing.
/proc/get_infection_chance(mob/living/carbon/M, vector = "Airborne")
	var/score = 0
	if (!istype(M))
		return 0

	if(istype(M, /mob/living/carbon/human))

		if (vector == "Airborne")
			if(M.internal)	//not breathing infected air helps greatly
				score = 30
			if(M.wear_mask)
				score += 5
				if(istype(M:wear_mask, /obj/item/clothing/mask/surgical) && !M.internal)
					score += 10
			if(istype(M:wear_suit, /obj/item/clothing/suit/space) && istype(M:head, /obj/item/clothing/head/helmet/space))
				score += 20
			if(istype(M:wear_suit, /obj/item/clothing/suit/bio_suit) && istype(M:head, /obj/item/clothing/head/bio_hood))
				score += 30


		if (vector == "Contact")
			if(M:gloves) score += 15
			if(istype(M:wear_suit, /obj/item/clothing/suit/space) && istype(M:head, /obj/item/clothing/head/helmet/space))
				score += 15
			if(istype(M:wear_suit, /obj/item/clothing/suit/bio_suit) && istype(M:head, /obj/item/clothing/head/bio_hood))
				score += 15


//	log_debug("[M]'s resistance to [vector] viruses: [score]")

	if(score >= 30)
		return 0
	else if(score == 25 && prob(99))
		return 0
	else if(score == 20 && prob(95))
		return 0
	else if(score == 15 && prob(75))
		return 0
	else if(score == 10 && prob(55))
		return 0
	else if(score == 5 && prob(35))
		return 0
//	log_debug("Infection got through")
	return 1

/proc/get_bite_infection_chance(mob/living/carbon/M, target_zone)
	if (!istype(M) || !target_zone)
		return 0

	if(target_zone && ishuman(M))
		var/mob/living/carbon/human/H = M

		var/armor = H.getarmor(target_zone, "melee")
		var/bioarmor = H.getarmor(target_zone, "bio")

		return max((100 - max(armor, bioarmor/2)), 0) / 2
	return 100

//Checks if table-passing table can reach target (5 tile radius)
/proc/airborne_can_reach(turf/source, turf/target)
	var/obj/dummy = new(source)
	dummy.pass_flags = PASSTABLE

	for(var/i=0, i<5, i++) if(!step_towards(dummy, target)) break

	var/rval = dummy.Adjacent(target)
	dummy.loc = null
	dummy = null
	return rval

//Attemptes to infect mob M with virus. Set forced to 1 to ignore protective clothnig
/proc/infect_virus2(mob/living/carbon/M,datum/disease2/disease/disease, forced = FALSE, ignore_antibiotics = FALSE)
	if(!istype(disease))
//		log_debug("Bad virus")
		return
	if(!istype(M))
//		log_debug("Bad mob")
		return
	if ("[disease.uniqueID]" in M.virus2)
		return
	// if one of the antibodies in the mob's body matches one of the disease's antigens, don't infect
	if((M.antibodies & disease.antigen) != 0)
		return
	if(M.reagents.has_reagent("spaceacillin") && !ignore_antibiotics)
		return

	if(istype(M,/mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/chimp = M
		if (!(chimp.greaterform in disease.affected_species))
			return

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/chump = M
		if (!(chump.species.name in disease.affected_species))
			return

//	log_debug("Infecting [M]")

	if(prob(disease.infectionchance) || forced)
		// certain clothes can prevent an infection
		if(!forced && !get_infection_chance(M, disease.spreadtype))
			return

		var/datum/disease2/disease/D = disease.getcopy()
//		log_debug("Adding virus")
		M.virus2["[D.uniqueID]"] = D
		M.med_hud_set_status()

//Infects mob M with random lesser disease, if he doesn't have one
/proc/infect_mob_random_lesser(mob/living/carbon/M)
	var/datum/disease2/disease/D = new /datum/disease2/disease
	D.makerandom()
	D.infectionchance = 1
	infect_virus2(M,D,1)
	M.med_hud_set_status()

//Infects mob M with random greated disease, if he doesn't have one
/proc/infect_mob_random_greater(mob/living/carbon/M)
	var/datum/disease2/disease/D = new /datum/disease2/disease
	D.makerandom(1)
	infect_virus2(M,D,1)
	M.med_hud_set_status()

//Fancy prob() function.
/proc/dprob(p)
	return(prob(sqrt(p)) && prob(sqrt(p)))

/mob/living/carbon/proc/spread_disease_to(mob/living/carbon/victim, vector = "Airborne")
	if (src == victim)
		return "retardation"

//	log_debug("Spreading [vector] diseases from [src] to [victim]")
	if (virus2.len > 0)
		for (var/ID in virus2)
//			log_debug("Attempting virus [ID]")
			var/datum/disease2/disease/V = virus2[ID]
			if(V.spreadtype != vector) continue

			if (vector == "Airborne")
				if(airborne_can_reach(get_turf(src), get_turf(victim)))
//					log_debug("In range, infecting")
					infect_virus2(victim,V)
				else
//					log_debug("Could not reach target")

			if (vector == "Contact")
				if (Adjacent(victim))
//					log_debug("In range, infecting")
					infect_virus2(victim,V)

	//contact goes both ways
	if (victim.virus2.len > 0 && vector == "Contact")
//		log_debug("Spreading [vector] diseases from [victim] to [src]")
		var/nudity = 1

		if (ishuman(victim) && zone_sel)
			var/mob/living/carbon/human/H = victim
			var/obj/item/organ/external/BP = H.get_bodypart(get_targetzone())
			var/list/clothes = list(H.head, H.wear_mask, H.wear_suit, H.w_uniform, H.gloves, H.shoes)
			for(var/obj/item/clothing/C in clothes)
				if(C && istype(C))
					if(C.body_parts_covered & BP.body_part)
						nudity = 0
		if (nudity)
			for (var/ID in victim.virus2)
				var/datum/disease2/disease/V = victim.virus2[ID]
				if(V && V.spreadtype != vector) continue
				infect_virus2(src,V)
