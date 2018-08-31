#define ANTIDEPRESSANT_MESSAGE_DELAY 5*60*10

/datum/reagent/antidepressant/methylphenidate
	name = "Methylphenidate"
	id = "methylphenidate"
	description = "Improves the ability to concentrate."
	reagent_state = LIQUID
	color = "#bf80bf"
	custom_metabolism = 0.01
	data = 0
	restrict_species = list(IPC, DIONA)

/datum/reagent/antidepressant/methylphenidate/on_general_digest(mob/living/M)
	..()
	if(volume <= 0.1 && data != -1)
		data = -1
		to_chat(M, "<span class='warning'>You lose focus..</span>")
	else
		if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
			data = world.time
			to_chat(M, "<span class='notice'>Your mind feels focused and undivided.</span>")

/datum/chemical_reaction/methylphenidate
	name = "Methylphenidate"
	id = "methylphenidate"
	result = "methylphenidate"
	required_reagents = list("mindbreaker" = 1, "hydrogen" = 1)
	result_amount = 3

/datum/reagent/antidepressant/citalopram
	name = "Citalopram"
	id = "citalopram"
	description = "Stabilizes the mind a little."
	reagent_state = LIQUID
	color = "#ff80ff"
	custom_metabolism = 0.01
	data = 0
	restrict_species = list(IPC, DIONA)

/datum/reagent/antidepressant/citalopram/on_general_digest(mob/living/M)
	..()
	if(volume <= 0.1 && data != -1)
		data = -1
		to_chat(M, "<span class='warning'>Your mind feels a little less stable.</span>")
	else
		if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
			data = world.time
			to_chat(M, "<span class='notice'>Your mind feels stable.. a little stable.</span>")

/datum/chemical_reaction/citalopram
	name = "Citalopram"
	id = "citalopram"
	result = "citalopram"
	required_reagents = list("mindbreaker" = 1, "carbon" = 1)
	result_amount = 3

/datum/reagent/antidepressant/paroxetine
	name = "Paroxetine"
	id = "paroxetine"
	description = "Stabilizes the mind greatly, but has a chance of adverse effects."
	reagent_state = LIQUID
	color = "#ff80bf"
	custom_metabolism = 0.01
	data = 0
	restrict_species = list(IPC, DIONA)

/datum/reagent/antidepressant/paroxetine/on_general_digest(mob/living/M)
	..()
	if(volume <= 0.1 && data != -1)
		data = -1
		to_chat(M, "<span class='warning'>Your mind feels much less stable.</span>")
	else
		if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
			data = world.time
			if(prob(90))
				to_chat(M, "<span class='notice'>Your mind feels much more stable.</span>")
			else
				to_chat(M, "<span class='warning'>Your mind breaks apart.</span>")
				M.hallucination += 200

/datum/chemical_reaction/paroxetine
	name = "Paroxetine"
	id = "paroxetine"
	result = "paroxetine"
	required_reagents = list("mindbreaker" = 1, "oxygen" = 1, "inaprovaline" = 1)
	result_amount = 3
