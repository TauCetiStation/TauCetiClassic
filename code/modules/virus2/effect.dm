/datum/disease2/effectholder
	var/name = "Holder"
	var/datum/disease2/effect/effect
	var/chance = 0 //Chance in percentage each tick
	var/cure = "" //Type of cure it requires
	var/happensonce = 0
	var/multiplier = 1 //The chance the effects are WORSE
	var/stage = 0

/datum/disease2/effectholder/proc/runeffect(mob/living/carbon/human/mob,stage)
	if(happensonce > -1 && effect.stage <= stage && prob(chance))
		effect.activate(mob)
		if(happensonce == 1)
			happensonce = -1

/datum/disease2/effectholder/proc/getrandomeffect(badness = 1)
	var/list/datum/disease2/effect/list = list()
	for(var/e in (typesof(/datum/disease2/effect) - /datum/disease2/effect))
		var/datum/disease2/effect/f = new e
		if (f.badness > badness)	//we don't want such strong effects
			continue
		if(f.stage == src.stage)
			list += f
	effect = pick(list)
	chance = rand(0,effect.chance_maxm)
	multiplier = rand(1,effect.maxm)

/datum/disease2/effectholder/proc/minormutate()
	switch(pick(1,2,3,4,5))
		if(1)
			chance = rand(0,effect.chance_maxm)
		if(2)
			multiplier = rand(1,effect.maxm)

/datum/disease2/effectholder/proc/majormutate()
	getrandomeffect(2)

////////////////////////////////////////////////////////////////
////////////////////////EFFECTS/////////////////////////////////
////////////////////////////////////////////////////////////////

/datum/disease2/effect
	var/chance_maxm = 50
	var/name = "Blanking effect"
	var/stage = 4
	var/maxm = 1
	var/badness = 1
	proc/activate(mob/living/carbon/mob,multiplier)
	proc/deactivate(mob/living/carbon/mob)

/datum/disease2/effect/invisible
	name = "Waiting Syndrome"
	stage = 1
	activate(mob/living/carbon/mob,multiplier)
		return

////////////////////////STAGE 4/////////////////////////////////

/datum/disease2/effect/gibbingtons
	name = "Gibbingtons Syndrome"
	stage = 4
	badness = 2
	activate(mob/living/carbon/mob,multiplier)
		mob.gib()

/datum/disease2/effect/radian
	name = "Radian's Syndrome"
	stage = 4
	maxm = 3
	activate(mob/living/carbon/mob,multiplier)
		mob.radiation += (2*multiplier)

/datum/disease2/effect/deaf
	name = "Dead Ear Syndrome"
	stage = 4
	activate(mob/living/carbon/mob,multiplier)
		mob.ear_deaf += 20

/datum/disease2/effect/monkey
	name = "Monkism Syndrome"
	stage = 4
	badness = 2
	activate(mob/living/carbon/mob,multiplier)
		if(istype(mob,/mob/living/carbon/human))
			var/mob/living/carbon/human/h = mob
			h.monkeyize()

/datum/disease2/effect/suicide
	name = "Suicidal Syndrome"
	stage = 4
	badness = 2
	activate(mob/living/carbon/mob,multiplier)
		mob.suiciding = 1
		//instead of killing them instantly, just put them at -175 health and let 'em gasp for a while
		to_chat(viewers(mob), "\red <b>[mob.name] is holding \his breath. It looks like \he's trying to commit suicide.</b>")
		mob.adjustOxyLoss(175 - mob.getToxLoss() - mob.getFireLoss() - mob.getBruteLoss() - mob.getOxyLoss())
		mob.updatehealth()
		spawn(200) //in case they get revived by cryo chamber or something stupid like that, let them suicide again in 20 seconds
			mob.suiciding = 0

/datum/disease2/effect/killertoxins
	name = "Toxification Syndrome"
	stage = 4
	activate(mob/living/carbon/mob,multiplier)
		mob.adjustToxLoss(15*multiplier)

/datum/disease2/effect/dna
	name = "Reverse Pattern Syndrome"
	stage = 4
	activate(mob/living/carbon/mob,multiplier)
		mob.bodytemperature = max(mob.bodytemperature, 350)
		scramble(0,mob,10)
		mob.apply_damage(10, CLONE)

/datum/disease2/effect/organs
	name = "Shutdown Syndrome"
	stage = 4
	activate(mob/living/carbon/mob,multiplier)
		if(istype(mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = mob
			var/organ = pick(list("r_arm","l_arm","r_leg","r_leg"))
			var/datum/organ/external/E = H.organs_by_name[organ]
			if (!(E.status & ORGAN_DEAD))
				E.status |= ORGAN_DEAD
				to_chat(H, "<span class='notice'>You can't feel your [E.display_name] anymore...</span>")
				for (var/datum/organ/external/C in E.children)
					C.status |= ORGAN_DEAD
			H.update_body()
		mob.adjustToxLoss(15*multiplier)

	deactivate(mob/living/carbon/mob,multiplier)
		if(istype(mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = mob
			for (var/datum/organ/external/E in H.organs)
				E.status &= ~ORGAN_DEAD
				for (var/datum/organ/external/C in E.children)
					C.status &= ~ORGAN_DEAD
			H.update_body()

/datum/disease2/effect/immortal
	name = "Longevity Syndrome"
	stage = 4
	activate(mob/living/carbon/mob,multiplier)
		if(istype(mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = mob
			for (var/datum/organ/external/E in H.organs)
				if (E.status & ORGAN_BROKEN && prob(30))
					E.status ^= ORGAN_BROKEN
		var/heal_amt = -5*multiplier
		mob.apply_damages(heal_amt,heal_amt,heal_amt,heal_amt)

	deactivate(mob/living/carbon/mob,multiplier)
		if(istype(mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = mob
			to_chat(H, "<span class='notice'>You suddenly feel hurt and old...</span>")
			H.age += 8
		var/backlash_amt = 5*multiplier
		mob.apply_damages(backlash_amt,backlash_amt,backlash_amt,backlash_amt)

////////////////////////STAGE 3/////////////////////////////////

/datum/disease2/effect/bones
	name = "Fragile Bones Syndrome"
	stage = 4
	activate(mob/living/carbon/mob,multiplier)
		if(istype(mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = mob
			for (var/datum/organ/external/E in H.organs)
				E.min_broken_damage = max(5, E.min_broken_damage - 30)

	deactivate(mob/living/carbon/mob,multiplier)
		if(istype(mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = mob
			for (var/datum/organ/external/E in H.organs)
				E.min_broken_damage = initial(E.min_broken_damage)

/datum/disease2/effect/toxins
	name = "Hyperacidity"
	stage = 3
	maxm = 3
	activate(mob/living/carbon/mob,multiplier)
		mob.adjustToxLoss((2*multiplier))

/datum/disease2/effect/shakey
	name = "World Shaking Syndrome"
	stage = 3
	maxm = 3
	activate(mob/living/carbon/mob,multiplier)
		shake_camera(mob,5*multiplier)

/datum/disease2/effect/telepathic
	name = "Telepathy Syndrome"
	stage = 3
	activate(mob/living/carbon/mob,multiplier)
		mob.dna.check_integrity()
		mob.dna.SetSEState(REMOTETALKBLOCK,1)
		domutcheck(mob, null)

/datum/disease2/effect/mind
	name = "Lazy Mind Syndrome"
	stage = 3
	activate(mob/living/carbon/mob,multiplier)
		if(istype(mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = mob
			var/datum/organ/internal/brain/B = H.internal_organs_by_name["brain"]
			if (B.damage < B.min_broken_damage)
				B.take_damage(5)
		else
			mob.setBrainLoss(50)

/datum/disease2/effect/hallucinations
	name = "Hallucinational Syndrome"
	stage = 3
	activate(mob/living/carbon/mob,multiplier)
		mob.hallucination += 25

/datum/disease2/effect/deaf
	name = "Hard of Hearing Syndrome"
	stage = 3
	activate(mob/living/carbon/mob,multiplier)
		mob.ear_deaf = 5

/datum/disease2/effect/giggle
	name = "Uncontrolled Laughter Effect"
	stage = 3
	activate(mob/living/carbon/mob,multiplier)
		mob.say("*giggle")

/datum/disease2/effect/confusion
	name = "Topographical Cretinism"
	stage = 3
	activate(mob/living/carbon/mob,multiplier)
		to_chat(mob, "<span class='notice'>You have trouble telling right and left apart all of a sudden.</span>")
		mob.confused += 10

/datum/disease2/effect/mutation
	name = "DNA Degradation"
	stage = 3
	activate(mob/living/carbon/mob,multiplier)
		mob.apply_damage(2, CLONE)


/datum/disease2/effect/groan
	name = "Groaning Syndrome"
	stage = 3
	activate(mob/living/carbon/mob,multiplier)
		mob.say("*groan")
////////////////////////STAGE 2/////////////////////////////////

/datum/disease2/effect/scream
	name = "Loudness Syndrome"
	stage = 2
	activate(mob/living/carbon/mob,multiplier)
		mob.emote("scream",,, 1)

/datum/disease2/effect/drowsness
	name = "Automated Sleeping Syndrome"
	stage = 2
	activate(mob/living/carbon/mob,multiplier)
		mob.drowsyness += 10

/datum/disease2/effect/sleepy
	name = "Resting Syndrome"
	stage = 2
	activate(mob/living/carbon/mob,multiplier)
		mob.say("*collapse")

/datum/disease2/effect/blind
	name = "Blackout Syndrome"
	stage = 2
	activate(mob/living/carbon/mob,multiplier)
		mob.eye_blind = max(mob.eye_blind, 4)

/datum/disease2/effect/cough
	name = "Anima Syndrome"
	stage = 2
	activate(mob/living/carbon/mob,multiplier)
		mob.say("*cough")
		for(var/mob/living/carbon/M in oview(2,mob))
			mob.spread_disease_to(M)

/datum/disease2/effect/hungry
	name = "Appetiser Effect"
	stage = 2
	activate(mob/living/carbon/mob,multiplier)
		mob.nutrition = max(0, mob.nutrition - 200)

/datum/disease2/effect/fridge
	name = "Refridgerator Syndrome"
	stage = 2
	activate(mob/living/carbon/mob,multiplier)
		mob.say("*shiver")

/datum/disease2/effect/hair
	name = "Hair Loss"
	stage = 2
	activate(mob/living/carbon/mob,multiplier)
		if(istype(mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = mob
			if(H.species.name == "Human" && !(H.h_style == "Bald") && !(H.h_style == "Balding Hair"))
				to_chat(H, "<span class='danger'>Your hair starts to fall out in clumps...</span>")
				spawn(50)
					H.h_style = "Balding Hair"
					H.update_hair()

/datum/disease2/effect/stimulant
	name = "Adrenaline Extra"
	stage = 2
	activate(mob/living/carbon/mob,multiplier)
		to_chat(mob, "<span class='notice'>You feel a rush of energy inside you!</span>")
		if (mob.reagents.get_reagent_amount("hyperzine") < 10)
			mob.reagents.add_reagent("hyperzine", 4)
		if (prob(30))
			mob.jitteriness += 10

////////////////////////STAGE 1/////////////////////////////////

/datum/disease2/effect/sneeze
	name = "Coldingtons Effect"
	stage = 1
	activate(mob/living/carbon/mob,multiplier)
		if (prob(3))
			mob.say("*sneeze")
			for(var/mob/living/carbon/M in get_step(mob,mob.dir))
				mob.spread_disease_to(M)
			var/turf/T = get_turf(mob)
			var/obj/effect/decal/cleanable/mucus/M = locate() in T.contents
			if(!M)
				M = new(T)
			M.virus2 = virus_copylist(mob.virus2)

/datum/disease2/effect/gunck
	name = "Flemmingtons"
	stage = 1
	activate(mob/living/carbon/mob,multiplier)
		to_chat(mob, "\red Mucous runs down the back of your throat.")

/datum/disease2/effect/drool
	name = "Saliva Effect"
	stage = 1
	activate(mob/living/carbon/mob,multiplier)
		mob.say("*drool")

/datum/disease2/effect/twitch
	name = "Twitcher"
	stage = 1
	activate(mob/living/carbon/mob,multiplier)
		mob.say("*twitch")

/datum/disease2/effect/headache
	name = "Headache"
	stage = 1
	activate(mob/living/carbon/mob,multiplier)
		to_chat(mob, "<span class = 'notice'> Your head hurts a bit</span>")
