//Nanomachines!

/datum/disease/robotic_transformation
	name = "Robotic Transformation"
	max_stages = 5
	spread = "Syringe"
	spread_type = SPECIAL
	cure = "An injection of copper."
	cure_id = list("copper")
	cure_chance = 5
	agent = "R2D2 Nanomachines"
	affected_species = list(HUMAN)
	desc = "This disease, actually acute nanomachine infection, converts the victim into a cyborg."
	severity = "Major"
	var/gibbed = 0

/datum/disease/robotic_transformation/stage_act()
	..()
	switch(stage)
		if(2)
			if (prob(8))
				to_chat(affected_mob, "Ваши суставы тяжело гнутся.")
				affected_mob.take_bodypart_damage(1)
			if (prob(9))
				to_chat(affected_mob, "<span class='warning'>Бип...буп..</span>")
			if (prob(9))
				to_chat(affected_mob, "<span class='warning'>Боп...бииип...</span>")
		if(3)
			if (prob(8))
				to_chat(affected_mob, "<span class='warning'>Ваши шарниры тяжело поворачиваются.</span>")
				affected_mob.take_bodypart_damage(1)
			if (prob(8))
				affected_mob.say(pick("Бип, буп", "Бип, бип!", "Буп...Боп"))
			if (prob(10))
				to_chat(affected_mob, "Ваша кожа становится эластичной.")
				affected_mob.take_bodypart_damage(5)
			if (prob(4))
				to_chat(affected_mob, "<span class='warning'>Вы чувтсвуете колющую боль в голове.</span>")
				affected_mob.Paralyse(2)
			if (prob(4))
				to_chat(affected_mob, "<span class='warning'>Вы чувствуете как внутри вас...что-то двигается.</span>")
		if(4)
			if (prob(10))
				to_chat(affected_mob, "<span class='warning'>Ваша оболочка становится дряблой.</span>")
				affected_mob.take_bodypart_damage(8)
			if (prob(20))
				affected_mob.say(pick("Бип, бип!", "Буп боп буп бип.", "Уббббеееейййтее мееннняяя", "Я ххооочччуууу уумммееерррееетть..."))
			if (prob(8))
				to_chat(affected_mob, "<span class='warning'>Что-то... движется...внутри вас.</span>")
		if(5)
			if(QDELETED(affected_mob))
				return
			if(affected_mob.notransform)
				return
			to_chat(affected_mob, "<span class='warning'>Ваша кожа вот-вот лопнет...</span>")
			affected_mob.adjustToxLoss(10)
			affected_mob.updatehealth()
			if(prob(40)) //So everyone can feel like robot Seth Brundle
				if(src.gibbed != 0)
					return
				var/turf/T = find_loc(affected_mob)
				gibs(T)
				cure(0)
				gibbed = 1
				var/mob/living/carbon/human/H = affected_mob
				if(istype(H) && !jobban_isbanned(affected_mob, "Cyborg"))
					H.Robotize()
				else
					affected_mob.death(1)

