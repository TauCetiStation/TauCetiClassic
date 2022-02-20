/*
//////////////////////////////////////

Dizziness

	Hidden.
	Lowers resistance considerably.
	Decreases stage speed.
	Reduced transmittability
	Intense Level.

Bonus
	Shakes the affected mob's screen for short periods.

//////////////////////////////////////
*/

/datum/symptom/dizzy // Not the egg

	name = "Dizziness"
	stealth = 2
	resistance = -2
	stage_speed = -3
	transmittable = -1
	level = 4

/datum/symptom/dizzy/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				to_chat(M, "<span class='notice'>[pick("Вы испытываете головокружение.", "Ваша голова ходит кругом.")]</span>")
			else
				to_chat(M, "<span class='notice'>Вы не можете смотреть прямо!</span>")
				M.make_dizzy(5)
	return
