//Xenomicrobes

/datum/disease/xeno_transformation
	name = "Xenomorph Transformation"
	max_stages = 5
	spread = "Syringe"
	spread_type = SPECIAL
	cure = "Spaceacillin & Glycerol"
	cure_id = list("spaceacillin", "glycerol")
	cure_chance = 5
	agent = "Rip-LEY Alien Microbes"
	affected_species = list(HUMAN)
	var/gibbed = 0

/datum/disease/xeno_transformation/stage_act()
	..()
	switch(stage)
		if(2)
			if (prob(8))
				to_chat(affected_mob, "Что-то царапает Ваше горло.")
				affected_mob.take_bodypart_damage(1)
			if (prob(9))
				to_chat(affected_mob, "<span class='warning'>Убивать...</span>")
			if (prob(9))
				to_chat(affected_mob, "<span class='warning'>Убивать...</span>")
		if(3)
			if (prob(8))
				to_chat(affected_mob, "<span class='warning'>Что-то сильно чешется в вашем горле.</span>")
				affected_mob.take_bodypart_damage(1)
			/*
			if (prob(8))
				affected_mob.say(pick("Бип, буп", "Бип, бип!", "Буп...боп"))
			*/
			if (prob(10))
				to_chat(affected_mob, "Ваша кожа натягивается.")
				affected_mob.take_bodypart_damage(5)
			if (prob(4))
				to_chat(affected_mob, "<span class='warning'>Вы чувствуете пульсирующую боль в голове.</span>")
				affected_mob.Paralyse(2)
			if (prob(4))
				to_chat(affected_mob, "<span class='warning'>Вы чувствуете как внутри вас...что-то двигается.</span>")
		if(4)
			if (prob(10))
				to_chat(affected_mob, pick("<span class='warning'>Ваша кожа очень плотная.</span>", "<span class='warning'>Ваша кровь закипает!</span>"))
				affected_mob.take_bodypart_damage(8)
			if (prob(20))
				affected_mob.say(pick("Выглядишь аппетитно.", "Хочу... поглотить тебя...", "Хссссс!"))
			if (prob(8))
				to_chat(affected_mob, "<span class='warning'>Вы чувствуете как что-то... двигается...внутри вас.</span>")
		if(5)
			if(QDELETED(affected_mob))
				return
			if(affected_mob.notransform)
				return
			to_chat(affected_mob, "<span class='warning'>Ваша кожа огрубела до невозможности...</span>")
			affected_mob.adjustToxLoss(10)
			affected_mob.updatehealth()
			if(prob(40))
				if(gibbed != 0)
					return
				var/turf/T = find_loc(affected_mob)
				gibs(T)
				cure(0)
				gibbed = 1
				affected_mob:Alienize()

