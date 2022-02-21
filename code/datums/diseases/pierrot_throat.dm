/datum/disease/pierrot_throat
	name = "Pierrot's Throat"
	max_stages = 4
	spread = "Airborne"
	cure = "A whole banana."
	cure_id = "banana"
	cure_chance = 75
	agent = "H0NI<42 Virus"
	affected_species = list(HUMAN)
	permeability_mod = 0.75
	desc = "If left untreated the subject will probably drive others to insanity."
	severity = "Medium"
	longevity = 400

/datum/disease/pierrot_throat/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(10))
				to_chat(affected_mob, "<span class='warning'>Вы чувствуете себя глуповато.</span>")
		if(2)
			if(prob(10))
				to_chat(affected_mob, "<span class='warning'>Вы начинаете видеть радугу.</span>")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='warning'>Ваши мысли обрывает громкий <b>ХОНК!</b></span>")
		if(4)
			if(prob(5))
				affected_mob.say(pick(list("ХОНК!", "Хонк!", "Хонк.", "Хонк?", "Хонк!!", "ХОНК?!", "Хонк...")))
