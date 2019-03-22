/*
//////////////////////////////////////

Vomiting

	Very Very Noticable.
	Decreases resistance.
	Doesn't increase stage speed.
	Little transmittable.
	Medium Level.

Bonus
	Forces the affected mob to vomit!
	Meaning your disease can spread via
	people walking on vomit.
	Makes the affected mob lose nutrition and
	heal toxin damage.

//////////////////////////////////////
*/

/datum/symptom/vomit

	name = "Vomiting"
	stealth = -2
	resistance = -1
	stage_speed = 0
	transmittable = 1
	level = 3

/datum/symptom/vomit/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB / 2))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				to_chat(M, "<span class='notice'>[pick("You feel nauseous.", "You feel like you're going to throw up!")]</span>")
			else
				Vomit(M)

	return

/datum/symptom/vomit/proc/Vomit(mob/living/M)

	M.visible_message("<B>[M]</B> vomits on the floor!")

	M.nutrition -= 20
	M.adjustToxLoss(-3)

	var/turf/pos = get_turf(M)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(istype(H.head, /obj/item/clothing/head/helmet/space))
				H.visible_message("<B>[H.name]</B> <span class='danger'>throws up in their helmet!</span>","<span class='warning'>You threw up in your helmet, damn it, what could be worse!</span>")
				H.losebreath += 15
				H.eye_blurry = max(2, H.eye_blurry)
				if(H.gender == FEMALE)
					playsound(H.loc, 'sound/misc/frigvomit.ogg', 90, 0)
				else
					playsound(H.loc, 'sound/misc/mrigvomit.ogg', 90, 0)
			else
				var/vomitsound = ""
				H.visible_message("<B>[H.name]</B> <span class='danger'>throws up!</span>","<span class='warning'>You throw up!</span>")
				if(H.gender == FEMALE)
					vomitsound = "femalevomit"
				else
					vomitsound = "malevomit"
				playsound(H.loc, vomitsound, 90, 0)
		else
			playsound(C.loc, 'sound/effects/splat.ogg', 100, 1)
			C.visible_message("<B>[C.name]</B> <span class='danger'>throws up!</span>","<span class='warning'>You throw up!</span>")
		pos.add_vomit_floor(M)
/*
//////////////////////////////////////

Vomiting Blood

	Very Very Noticable.
	Decreases resistance.
	Decreases stage speed.
	Little transmittable.
	Intense level.

Bonus
	Forces the affected mob to vomit blood!
	Meaning your disease can spread via
	people walking on the blood.
	Makes the affected mob lose health.

//////////////////////////////////////
*/

/datum/symptom/vomit/blood

	name = "Blood Vomiting"
	stealth = -2
	resistance = -1
	stage_speed = -1
	transmittable = 1
	level = 4

/datum/symptom/vomit/blood/Vomit(mob/living/M)

	M.Stun(1)
	M.visible_message("<B>[M]</B> vomits on the floor!")

	// They lose blood and health.
	var/brute_dam = M.getBruteLoss()
	if(brute_dam < 50)
		M.adjustBruteLoss(3)

	var/turf/simulated/pos = get_turf(M)
	pos.add_blood_floor(M)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(istype(H.head, /obj/item/clothing/head/helmet/space))
				H.visible_message("<B>[H.name]</B> <span class='danger'>throws up BLOOD in their helmet!</span>","<span class='warning'>You threw up BLOOD in your helmet, damn it, what could be worse!</span>")
				H.losebreath += 15
				H.eye_blurry = max(2, H.eye_blurry)
				if(H.gender == FEMALE)
					playsound(H.loc, 'sound/misc/frigvomit.ogg', 90, 0)
				else
					playsound(H.loc, 'sound/misc/mrigvomit.ogg', 90, 0)
			else
				var/vomitsound = ""
				H.visible_message("<B>[H.name]</B> <span class='danger'>throws up BLOOD!</span>","<span class='warning'>You throw up BLOOD!</span>")
				if(H.gender == FEMALE)
					vomitsound = "femalevomit"
				else
					vomitsound = "malevomit"
				playsound(H.loc, vomitsound, 90, 0)
		else
			playsound(C.loc, 'sound/effects/splat.ogg', 90, 1)
			C.visible_message("<B>[C.name]</B> <span class='danger'>throws up BLOOD!</span>","<span class='warning'>You throw up BLOOD!</span>")
		pos.add_vomit_floor(M)
