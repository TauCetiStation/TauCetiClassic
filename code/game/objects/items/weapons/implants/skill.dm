/obj/item/weapon/implant/skill
	name = "CMF implant"
	var/list/compatible_species
	var/datum/skillset/added_skillset

/obj/item/weapon/implant/skill/inject()
	. = ..()

	if(!ishuman(implanted_mob))
		return

	var/mob/living/carbon/human/H = implanted_mob

	if(!(H.species.name in compatible_species))
		H.adjustBrainLoss(100)
		meltdown()
		return

	if(compatible_species.len > 1)
		if(rand(50))
			H.adjustBrainLoss(50)
		if(rand(10))
			if(body_part)
				body_part.take_damage(10, 0, used_weapon = "CMF implant")
			H.adjustBrainLoss(75)
			H.adjustToxLoss(50)
			H.Stun(5)
			H.Weaken(5)

	H.add_skills_buff(added_skillset)
	return TRUE

/obj/item/weapon/implant/skill/eject()
	implanted_mob.remove_skills_buff(added_skillset) // todo: more feedback?
	implanted_mob.adjustBrainLoss(100)

	. = ..()

/obj/item/weapon/implant/skill/emp_act(severity)
	if (malfunction)
		return

	if(severity == 1 && prob(40))
		meltdown()
		return

	set_malfunction_for(30 SECONDS) // protects from repeated emp

/obj/item/weapon/implant/skill/proc/set_skills(list/skills_list, list/species)
	var/datum/skillset/skillset = new()
	skillset.skills = skills_list
	added_skillset = skillset
	compatible_species = species
