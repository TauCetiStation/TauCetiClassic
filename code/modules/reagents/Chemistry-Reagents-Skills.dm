#define BRAIN_JUICE_AMOUNT 50

/datum/reagent/brain_juice
	name = "Brain juice"
	id = "brainjuice"
	description = "You don't want to know how it's made..."
	reagent_state = LIQUID
	color = "#a17193"
	custom_metabolism = 0.01
	restrict_species = list(IPC, DIONA, VOX, SKRELL)

/datum/reagent/brain_juice/on_general_digest(mob/living/M)
	..()
	//while amount < BRAIN_JUICE_AMOUNT
	M.adjustBrainLoss(5 * REM)
	//if amount > BRAIN_JUICE_AMOUNT



/datum/reagent/mentat
	name = "Mentat"
	id = "mentat"
	description = "Improves cognitive and motor skills, allowing you to do some tasks faster and better."
	reagent_state = LIQUID
	color = "#d8c238"
	custom_metabolism = 0.01
	restrict_species = list(IPC, DIONA, VOX)

/datum/chemical_reaction/mentat
	name = "Mentat"
	id = "mentat"
	result = "mentat"
	required_reagents = list("brainjuice" = BRAIN_JUICE_AMOUNT, "methylphenidate" = 15, "alkysine" = 15)
	required_catalysts = list("phoron" = 5)
	result_amount = 5

/datum/chemical_reaction/explosion_potassium/on_reaction(datum/reagents/holder, created_volume)

	var/datum/reagent/brain_juice/juice
	for(var/datum/reagent/R in holder.reagent_list)
		if(R.id == "brainjuice")
			juice = R
	var/mob/living/carbon/brain/brainmob = juice.data["brainmob"]
	brainmob.mind.skills.available
	holder.clear_reagents()
