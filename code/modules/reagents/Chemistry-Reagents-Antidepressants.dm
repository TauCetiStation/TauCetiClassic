#define ANTIDEPRESSANT_MESSAGE_DELAY 5*60*10

/datum/reagent/antidepressant/methylphenidate
	name = "Метилфенидат"
	id = "methylphenidate"
	description = "Улучшает концентрацию."
	reagent_state = LIQUID
	color = "#bf80bf"
	custom_metabolism = 0.01
	data = 0
	restrict_species = list(IPC, DIONA)

/datum/reagent/antidepressant/methylphenidate/on_general_digest(mob/living/M)
	..()
	if(volume <= 0.1 && data != -1)
		data = -1
		to_chat(M, "<span class='warning'>Вы теряете концентрацию..</span>")
	else
		if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
			data = world.time
			to_chat(M, "<span class='notice'>Вы чувствуете себя сосредоточенным.</span>")

/datum/chemical_reaction/methylphenidate
	name = "Methylphenidate"
	id = "methylphenidate"
	result = "methylphenidate"
	required_reagents = list("mindbreaker" = 1, "hydrogen" = 1)
	result_amount = 3

/datum/reagent/antidepressant/citalopram
	name = "Циталопрам"
	id = "citalopram"
	description = "Немного стабилизирует разум."
	reagent_state = LIQUID
	color = "#ff80ff"
	custom_metabolism = 0.01
	data = 0
	restrict_species = list(IPC, DIONA)

/datum/reagent/antidepressant/citalopram/on_general_digest(mob/living/M)
	..()
	if(volume <= 0.1 && data != -1)
		data = -1
		to_chat(M, "<span class='warning'>Ваш разум становится менее стабильным.</span>")
	else
		if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
			data = world.time
			to_chat(M, "<span class='notice'>Ваш разум чувствуется стабильным... немного.</span>")

/datum/chemical_reaction/citalopram
	name = "Citalopram"
	id = "citalopram"
	result = "citalopram"
	required_reagents = list("mindbreaker" = 1, "carbon" = 1)
	result_amount = 3

/datum/reagent/antidepressant/paroxetine
	name = "Пароксетин"
	id = "paroxetine"
	description = "Отлично стабилизирует разум, но есть шанс получить побочный эффект."
	reagent_state = LIQUID
	color = "#ff80bf"
	custom_metabolism = 0.01
	data = 0
	restrict_species = list(IPC, DIONA)

/datum/reagent/antidepressant/paroxetine/on_general_digest(mob/living/M)
	..()
	if(volume <= 0.1 && data != -1)
		data = -1
		to_chat(M, "<span class='warning'>Ваш разум становится намного менее стабильным.</span>")
	else
		if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
			data = world.time
			if(prob(90))
				to_chat(M, "<span class='notice'>Ваш разум становится намного стабильнее.</span>")
			else
				to_chat(M, "<span class='warning'>Ваш разум распадается.</span>")
				M.hallucination += 200

/datum/chemical_reaction/paroxetine
	name = "Paroxetine"
	id = "paroxetine"
	result = "paroxetine"
	required_reagents = list("mindbreaker" = 1, "oxygen" = 1, "inaprovaline" = 1)
	result_amount = 3
