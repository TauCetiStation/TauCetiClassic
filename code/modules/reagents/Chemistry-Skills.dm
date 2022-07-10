/datum/reagent/brain_juice
	name = "Brain juice"
	id = "brainjuice"
	description = "You don't want to know how it's made..."
	reagent_state = LIQUID
	color = "#a17193"
	custom_metabolism = 0.01
	taste_message = "despair"
	restrict_species = list(IPC, DIONA, VOX, SKRELL)

/datum/reagent/brain_juice/on_general_digest(mob/living/M)
	..()
	var/transfer_threshold = BRAIN_JUICE_AMOUNT - 0.5
	var/mob/living/carbon/brain/brainmob = data["brainmob"]
	if(brainmob)
		M.adjustToxLoss(40)
		M.adjustBrainLoss(40)
	else
		M.adjustToxLoss(15)
		M.adjustBrainLoss(15)

	if(volume < transfer_threshold)
		return
	to_chat(M, "<span class='danger'>You can feel that your brain has changed!</span>")

	for(var/datum/skillset/skillset in M.mind.skills.available_skillsets)
		M.mind.skills.remove_available_skillset(skillset.type)

	M.mind.skills.transfer_skills(brainmob.mind)
	M.mind.skills.maximize_active_skills()
	M.reagents.remove_all_type(/datum/reagent/brain_juice, BRAIN_JUICE_AMOUNT, 0, 1)
	M.adjustBrainLoss(50)

/datum/reagent/brain_juice/on_merge(other_data, other_amount)  //to avoid diluting or duplication of the juice
	if(other_data["brainmob"] != data["brainmob"])
		holder.remove_reagent("brainjuice", other_amount * 2)
		holder.add_reagent("grayjuice", other_amount)

/datum/chemical_reaction/gray_juice
	name = "Gray juice"
	id = "grayjuice"
	result = "grayjuice"
	required_reagents = list("grayjuice" = 0.1, "brainjuice" = 0.1)
	result_amount = 0.2

/datum/reagent/gray_juice
	name = "Gray juice"
	id = "grayjuice"
	description = "It smells really bad."
	reagent_state = LIQUID
	color = "#696969"
	taste_message = null
	restrict_species = list(IPC)

/datum/reagent/gray_juice/on_general_digest(mob/living/M)
	M.adjustBrainLoss(2)
	M.adjustToxLoss(2)

/datum/reagent/mentat
	name = "Mentat"
	id = "mentat"
	description = "Improves cognitive and motor skills, allowing you to do some tasks faster and better."
	reagent_state = LIQUID
	color = "#d8c238"
	taste_message = "intelligence"
	custom_metabolism = 1000
	var/buff_duration = 5 MINUTES
	restrict_species = list(IPC, DIONA, VOX, SKRELL)

/datum/chemical_reaction/mentat
	name = "Mentat"
	id = "mentat"
	result = "mentat"
	required_reagents = list("brainjuice" = BRAIN_JUICE_AMOUNT, "methylphenidate" = 15, "alkysine" = 15)
	required_catalysts = list("phoron" = 5)
	result_amount = 5

/datum/reagent/mentat/on_general_digest(mob/living/M)
	if(volume < 0.4)
		return
	var/mob/living/carbon/brain/brainmob = data["brainmob"]
	if(brainmob)
		M.add_skills_buff(brainmob.mind.skills.available, buff_duration)

/datum/reagent/mentat/preset
	id = "mentat_preset"
	taste_message = "hard work"
	var/skillset_type = /datum/skillset/test_subject

/datum/reagent/mentat/preset/on_general_digest(mob/living/M)
	if(volume < 0.4)
		return
	M.add_skills_buff(all_skillsets[skillset_type])

/datum/reagent/mentat/preset/engineering
	id = "mentat_engi"
	taste_message = "phoron"
	skillset_type = /datum/skillset/engineer

/datum/reagent/mentat/preset/science
	id = "mentat_sci"
	taste_message = "books"
	color = "#9612e3"
	skillset_type = /datum/skillset/scientist