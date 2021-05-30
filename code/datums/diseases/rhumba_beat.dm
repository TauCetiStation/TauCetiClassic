/datum/disease/rhumba_beat
	name = "The Rhumba Beat"
	max_stages = 5
	spread = "On contact"
	spread_type = CONTACT_GENERAL
	cure = "Chick Chicky Boom!"
	cure_id = list("phoron")
	agent = "Unknown"
	affected_species = list(HUMAN)
	permeability_mod = 1

/datum/disease/rhumba_beat/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(45))
				affected_mob.adjustToxLoss(5)
				affected_mob.updatehealth()
			if(prob(1))
				to_chat(affected_mob, "<span class='warning'>You feel strange...</span>")
		if(3)
			if(prob(5))
				to_chat(affected_mob, "<span class='warning'>You feel the urge to dance...</span>")
			else if(prob(5))
				affected_mob.emote("gasp")
			else if(prob(10))
				to_chat(affected_mob, "<span class='warning'>You feel the need to chick chicky boom...</span>")
		if(4)
			if(prob(10))
				affected_mob.emote("gasp")
				to_chat(affected_mob, "<span class='warning'>You feel a burning beat inside...</span>")
			if(prob(20))
				affected_mob.adjustToxLoss(5)
				affected_mob.updatehealth()
		if(5)
			if(QDELETED(affected_mob))
				return
			if(affected_mob.notransform)
				return
			to_chat(affected_mob, "<span class='warning'>Your body is unable to contain the Rhumba Beat...</span>")
			if(prob(50))
				affected_mob.gib()
		else
			return
