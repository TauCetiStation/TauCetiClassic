/datum/disease2/effectholder
	var/name = "Holder"
	var/datum/disease2/effect/effect
	var/chance = 0 //Chance in percentage each tick
	var/multiplier = 1 //The chance the effects are WORSE
	var/stage = 1
	var/ticks = 0
	var/cooldownticks = 0

/datum/disease2/effectholder/proc/runeffect(mob/living/carbon/human/mob,datum/disease2/disease/disease)
	if(cooldownticks > 0)
		cooldownticks -= 1*disease.cooldown_mul
	if(prob(chance))
		if(ticks > stage*10 && prob(50) && stage < effect.max_stage)
			stage++
		if(cooldownticks <= 0)
			cooldownticks = effect.cooldown
			effect.activate(mob, src, disease)
		ticks+=1

////////////////////////////////////////////////////////////////
////////////////////////EFFECTS/////////////////////////////////
////////////////////////////////////////////////////////////////

/datum/disease2/effect
	var/chance_minm = 10
	var/chance_maxm = 50
	var/name = "Blanking effect"
	var/desc = "No description"
	var/level = 1
	var/max_stage = 1
	var/cooldown = 0

/datum/disease2/effect/proc/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
/datum/disease2/effect/proc/deactivate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
/datum/disease2/effect/proc/copy(datum/disease2/effectholder/holder_old, datum/disease2/effectholder/holder_new, datum/disease2/effect/effect_old)

/datum/disease2/effect/invisible
	name = "Waiting Syndrome"
	level = 0 // can't get this one

/datum/disease2/effect/invisible/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	return

/datum/disease2/effect/zombie
	name = "Green Flu"
	desc = "Unknown."
	level = 5
	max_stage = 10
	cooldown = 10
	chance_minm = 20
	chance_maxm = 20
	var/activated = FALSE
	var/obj/item/organ/external/infected_organ = null //if infected part is removed, destroys itself

/datum/disease2/effect/zombie/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		if(iszombie(H))
			disease.dead = TRUE
			return

		if(!(H.species.name in list(HUMAN, UNATHI, TAJARAN, SKRELL)))
			return

		if(infected_organ == null && holder.ticks == 0)
			var/list/organs = list(BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG) // Organs that you can actually cut off are checked first to give a chance
			organs = shuffle(organs) + shuffle(list(BP_CHEST, BP_GROIN, BP_HEAD))

			for(var/o in organs)
				var/obj/item/organ/external/BP = H.get_bodypart(o)
				if(BP && BP.is_flesh() && BP.is_usable())
					infected_organ = BP
					break

		if(QDELETED(infected_organ) || !infected_organ || !infected_organ.is_flesh() || infected_organ.is_stump || !infected_organ.is_attached())
			disease.dead = TRUE
			to_chat(H, "<span class='notice'>You suddenly feel better.</span>")
			return

		switch(holder.stage)
			if(1,2,3) //increased hunger
				H.nutrition = max(H.nutrition - 20, 0)
				if(prob(1)) //might never happen and its fine
					to_chat(H, "<span class='notice'>[pick("You feel an odd gurgle in your stomach.", "You are hungry for something.", "You suddenly feel better.", "You suddenly feel worse.")]</span>")
			if(4,5,6) //some random stuff
				H.adjustToxLoss(1)
				if(prob(70))
					mob.emote(pick("twitch","drool","sneeze","sniff","cough","shiver","giggle","laugh","gasp"))
				else
					to_chat(H, "<span class='warning'>[pick("Your [infected_organ.name] seems to become more green...", "Your [infected_organ.name] hurts...")]</span>")
			if(7,8) //pain
				to_chat(H, "<span class='danger'>[pick("Your brain hurts.", "Your [infected_organ.name] hurts a lot.", "Your muscles ache.", "Your muscles are sore.")]</span>")
				H.apply_effect(20,AGONY,0)
				H.adjustBrainLoss(5)
				H.adjustToxLoss(3)
			if(9) //IT HURTS
				if(prob(33))
					to_chat(H, "<span class='danger'>[pick("IT HURTS", "You feel a sharp pain across your whole body!")]</span>")
					H.adjustBruteLoss(rand(2,5))
					H.apply_effect(50,AGONY,0)
				else if(prob(33) && H.stat == CONSCIOUS)
					to_chat(H, "<span class='danger'>[pick("Your heart stop for a second.", "It's hard for you to breathe.")]</span>")
					H.adjustOxyLoss(rand(10,40))
				else
					to_chat(H, "<span class='danger'>[pick("Your body is paralyzed.")]</span>")
					H.Stun(4)
			if(10) //rip
				if(!activated)
					activated = TRUE
					H.visible_message("<span class='danger'>[H] suddenly closes \his eyes. \His body falls lifeless and stops moving. \He seems to stop breathing.</span>")
					H.SetSleeping(600 SECONDS)
					handle_infected_death(H)
					H.update_canmove()
					disease.dead = TRUE

/datum/disease2/effect/zombie/copy(datum/disease2/effectholder/holder_old, datum/disease2/effectholder/holder_new, datum/disease2/effect/effect_old)
	var/datum/disease2/effect/zombie/Z = effect_old
	infected_organ = Z.infected_organ

/datum/disease2/effect/beard
	name = "Facial Hypertrichosis"
	desc = "The virus increases hair production significantly, causing rapid beard growth."
	level = 2
	max_stage = 3
	cooldown = 30

/datum/disease2/effect/beard/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		switch(holder.stage)
			if(1)
				to_chat(H, "<span class='warning'>Your chin itches.</span>")
				if(H.f_style == "Shaved" && prob(30))
					H.f_style = "Jensen Beard"
					H.update_hair()
			if(2)
				if(!(H.f_style == "Dwarf Beard") && !(H.f_style == "Very Long Beard") && !(H.f_style == "Full Beard"))
					to_chat(H, "<span class='warning'>You feel tough.</span>")
					H.f_style = "Full Beard"
					H.update_hair()
			if(3)
				if(!(H.f_style == "Dwarf Beard") && !(H.f_style == "Very Long Beard"))
					to_chat(H, "<span class='warning'>You feel manly!</span>")
					H.f_style = pick("Dwarf Beard", "Very Long Beard")
					H.update_hair()

/datum/disease2/effect/fire
	name = "Spontaneous Combustion"
	desc = "The virus turns fat into an extremely flammable compound, and raises the body's temperature, making the host burst into flames spontaneously."
	level = 3
	max_stage = 3
	cooldown = 30

/datum/disease2/effect/fire/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(50) || holder.stage == 1)
		to_chat(mob, "<span class='warning'>[pick("You feel hot.", "You hear a crackling noise.", "You smell smoke.")]</span>")
	else if(prob(50) || holder.stage == 2)
		mob.adjust_fire_stacks(1)
		mob.IgniteMob()
		to_chat(mob, "<span class='userdanger'>Your skin bursts into flames!</span>")
		mob.emote("scream")
	else if(holder.stage == 3)
		mob.adjust_fire_stacks(3)
		mob.IgniteMob()
		to_chat(mob, "<span class='userdanger'>Your skin erupts into an inferno!</span>")
		mob.emote("scream")

/datum/disease2/effect/flesh_eating
	name = "Necrotizing Fasciitis"
	desc = "The virus aggressively attacks body cells, necrotizing tissues and organs."
	level = 3
	max_stage = 4
	cooldown = 30
	chance_maxm = 30

/datum/disease2/effect/flesh_eating/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(50) || (holder.stage >= 1 && holder.stage <= 3))
		to_chat(mob, "<span class='warning'>[pick("You feel a sudden pain across your body.", "Drops of blood appear suddenly on your skin.")]</span>")
	else if(holder.stage == 4)
		to_chat(mob, "<span class='userdanger'>[pick("You cringe as a violent pain takes over your body.", "It feels like your body is eating itself inside out.", "IT HURTS.")]</span>")
		mob.adjustBruteLoss(rand(15,25))

/datum/disease2/effect/flesh_death
	name = "Autophagocytosis Necrosis"
	desc = "The virus rapidly consumes infected cells, leading to heavy and widespread damage."
	level = 4
	max_stage = 3
	cooldown = 5
	chance_maxm = 20

/datum/disease2/effect/flesh_death/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(20) || (holder.stage >= 1 && holder.stage <= 2))
		to_chat(mob, "<span class='warning'>[pick("You feel your body break apart.", "Your skin rubs off like dust.")]</span>")
	else if(holder.stage == 3)
		to_chat(mob, "<span class='userdanger'>[pick("You feel your muscles weakening.", "Some of your skin detaches itself.", "You feel sandy.")]</span>")
		mob.adjustBruteLoss(rand(6,10))

/datum/disease2/effect/heal
	name = "Basic Healing (does nothing)"
	desc = "You should not be seeing this."
	level = 0
	max_stage = 2
	cooldown = 0
	chance_minm = 100
	chance_maxm = 100
	var/passive_message = "" //random message to infected but not actively healing people

/datum/disease2/effect/heal/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(holder.stage == 2 && ishuman(mob))
		var/mob/living/carbon/human/H = mob
		var/effectiveness = can_heal(H, disease)
		if(!effectiveness)
			if(passive_message && prob(2) && passive_message_condition(H, disease))
				to_chat(mob, passive_message)
			return
		else
			heal(H, disease, effectiveness)

/datum/disease2/effect/heal/proc/can_heal(mob/living/carbon/human/M,datum/disease2/disease/disease)
	return 1

/datum/disease2/effect/heal/proc/heal(mob/living/carbon/human/M,datum/disease2/disease/disease, actual_power)
	return TRUE

/datum/disease2/effect/heal/proc/passive_message_condition(mob/living/carbon/human/M,datum/disease2/disease/disease)
	return TRUE

/datum/disease2/effect/heal/starlight
	name = "Starlight Condensation"
	desc = "The virus reacts to direct starlight, producing regenerative chemicals. Works best against toxin-based damage."
	level = 3
	passive_message = "<span class='notice'>You miss the feeling of starlight on your skin.</span>"

/datum/disease2/effect/heal/starlight/can_heal(mob/living/carbon/human/M,datum/disease2/disease/disease)
	if(istype(get_turf(M), /turf/space))
		return 1
	else
		for(var/turf/T in view(M, 2))
			if(istype(T, /turf/space))
				return 0.5

/datum/disease2/effect/heal/starlight/heal(mob/living/carbon/human/M,datum/disease2/disease/disease, actual_power)
	var/heal_amt = actual_power
	if(M.getToxLoss() && prob(5))
		to_chat(M, "<span class='notice'>Your skin tingles as the starlight seems to heal you.</span>")

	M.adjustToxLoss(-(4 * heal_amt)) //most effective on toxins

	var/list/parts = M.get_damaged_bodyparts(1,1)

	if(!parts.len)
		return

	M.heal_bodypart_damage(heal_amt, heal_amt)
	return 1

/datum/disease2/effect/heal/starlight/passive_message_condition(mob/living/carbon/human/M,datum/disease2/disease/disease)
	if(M.getBruteLoss() || M.getFireLoss() || M.getToxLoss())
		return TRUE
	return FALSE

/datum/disease2/effect/heal/chem
	name = "Toxolysis"
	desc = "The virus rapidly breaks down any foreign chemicals in the bloodstream."
	level = 4

/datum/disease2/effect/heal/chem/heal(mob/living/carbon/human/M,datum/disease2/disease/disease, actual_power)
	for(var/datum/reagent/R in M.reagents.reagent_list) //Not just toxins!
		M.reagents.remove_reagent(R.id, actual_power)
		if(prob(2))
			to_chat(M, "<span class='notice'>You feel a mild warmth as your blood purifies itself.</span>")
	return 1

/datum/disease2/effect/heal/metabolism
	name = "Metabolic Boost"
	desc = "The virus causes the host's metabolism to accelerate rapidly, making them process chemicals twice as fast, but also causing increased hunger."
	level = 4

/datum/disease2/effect/heal/metabolism/heal(mob/living/carbon/human/M,datum/disease2/disease/disease, actual_power)
	if(M.reagents)
		M.reagents.metabolize(M) //this works even without a liver; it's intentional since the virus is metabolizing by itself
	M.overeatduration = max(M.overeatduration - 2, 0)
	var/lost_nutrition = 2
	M.nutrition = max(M.nutrition - (lost_nutrition * M.get_metabolism_factor()), 0) //Hunger depletes at 2x the normal speed
	if(prob(2))
		to_chat(M, "<span class='notice'>You feel an odd gurgle in your stomach, as if it was working much faster than normal.</span>")
	return 1

/datum/disease2/effect/heal/darkness
	name = "Nocturnal Regeneration"
	desc = "The virus is able to mend the host's flesh when in conditions of low light, repairing physical damage. More effective against brute damage."
	level = 3
	passive_message = "<span class='notice'>You feel tingling on your skin as light passes over it.</span>"

/datum/disease2/effect/heal/darkness/can_heal(mob/living/carbon/human/M,datum/disease2/disease/disease)
	var/light_amount = 0
	if(M.loc && istype(M.loc.type, /turf/space))
		return 0
	if(isturf(M.loc))
		var/turf/T = M.loc
		light_amount = min(1,T.get_lumcount())
		if(light_amount < 0.7)
			return 1
		else
			return 0
	return 0.5  // If they are inside something, let them heal, but more slowly

/datum/disease2/effect/heal/darkness/heal(mob/living/carbon/human/M,datum/disease2/disease/disease, actual_power)
	var/heal_amt = 2 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,1)

	if(!parts.len)
		return

	if(prob(5))
		to_chat(M, "<span class='notice'>The darkness soothes and mends your wounds.</span>")

	M.heal_bodypart_damage(heal_amt, heal_amt * 0.5) //more effective on brute
	return 1

/datum/disease2/effect/heal/darkness/passive_message_condition(mob/living/carbon/human/M,datum/disease2/disease/disease)
	if(M.getBruteLoss() || M.getFireLoss())
		return TRUE
	return FALSE

/datum/disease2/effect/heal/coma
	name = "Regenerative Coma"
	desc = "The virus causes the host to fall into a death-like coma when severely damaged, then rapidly fixes the damage."
	level = 4
	passive_message = "<span class='notice'>The pain from your wounds makes you feel oddly sleepy...</span>"
	var/active_coma = FALSE

/datum/disease2/effect/heal/coma/can_heal(mob/living/carbon/human/M,datum/disease2/disease/disease)
	if(M.status_flags & FAKEDEATH)
		return 1
	else if(M.stat == UNCONSCIOUS)
		return 0.5
	else if(M.getBruteLoss() + M.getFireLoss() >= 70 && !active_coma)
		to_chat(M, "<span class='warning'>You feel yourself slip into a regenerative coma...</span>")
		active_coma = TRUE
		addtimer(CALLBACK(src, .proc/coma, M), 60)

/datum/disease2/effect/heal/coma/proc/coma(mob/living/carbon/human/M)
	//M.emote("deathgasp")
	M.status_flags |= FAKEDEATH
	M.SetSleeping(999 SECONDS) //Well, I hope its good enough
	addtimer(CALLBACK(src, .proc/uncoma, M), 300)

/datum/disease2/effect/heal/coma/proc/uncoma(mob/living/carbon/human/M)
	if(!active_coma)
		return
	active_coma = FALSE
	M.status_flags &= ~FAKEDEATH
	M.SetSleeping(0)

/datum/disease2/effect/heal/coma/heal(mob/living/carbon/human/M,datum/disease2/disease/disease, actual_power)
	var/heal_amt = 4 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,1)

	if(!parts.len)
		return

	M.heal_bodypart_damage(heal_amt, heal_amt)

	if(active_coma && M.getBruteLoss() + M.getFireLoss() == 0)
		uncoma(M)
	return 1

/datum/disease2/effect/heal/coma/passive_message_condition(mob/living/carbon/human/M,datum/disease2/disease/disease)
	if((M.getBruteLoss() + M.getFireLoss()) > 30)
		return TRUE
	return FALSE

/datum/disease2/effect/mind_restoration
	name = "Mind Restoration"
	desc = "The virus strengthens the bonds between neurons, reducing the duration of any ailments of the mind."
	level = 3
	max_stage = 5
	cooldown = 5
	chance_minm = 100
	chance_maxm = 100

/datum/disease2/effect/mind_restoration/activate(mob/living/carbon/M,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(holder.stage	>= 3)
		M.dizziness = max(0, M.dizziness - 2)
		M.drowsyness = max(0, M.drowsyness - 2)
		M.slurring = max(0, M.slurring - 2)
		M.confused = max(0, M.confused - 2)
		M.druggy = max(M.druggy - 5, 0)
	if(holder.stage	>= 4)
		M.drowsyness = max(0, M.drowsyness - 2)
		if(M.reagents.has_reagent("mindbreaker"))
			M.reagents.remove_reagent("mindbreaker", 5)
		M.hallucination = max(0, M.hallucination - 10)
	if(holder.stage	>= 5)
		M.adjustBrainLoss(-3)

/datum/disease2/effect/sensory_restoration
	name = "Sensory Restoration"
	desc = "The virus stimulates the production and replacement of sensory tissues, causing the host to regenerate eyes and ears when damaged."
	level = 3
	max_stage = 4
	cooldown = 1
	chance_minm = 100
	chance_maxm = 100

/datum/disease2/effect/sensory_restoration/activate(mob/living/carbon/M,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(holder.stage	== 4)
		M.eye_blurry = max(M.eye_blurry - 5, 0)
		M.eye_blind = max(M.eye_blind - 5, 0)
		M.ear_damage = max(M.ear_damage - 1, 0)
		M.ear_deaf = max(M.ear_deaf - 1, 0)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/internal/eyes/IO = H.organs_by_name[O_EYES]
			if(istype(IO))
				if(IO.damage > 0)
					IO.damage = max(IO.damage - 1, 0)

/datum/disease2/effect/stage_boost
	name = "Quick growth"
	desc = "The virus mutates and quickly grows, reaching its full potential in moments."
	level = 4
	max_stage = 1
	cooldown = 1
	chance_minm = 100
	chance_maxm = 100

/datum/disease2/effect/stage_boost/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(disease.stage < disease.effects.len)
		disease.stage = disease.effects.len
		to_chat(mob, "<span class='notice'>You feel warmth inside your head.</span>")

/datum/disease2/effect/cooldown_boost
	name = "Virus booster"
	desc = "The virus mutates and becomes more active, reducing the time between effects."
	level = 3
	max_stage = 1
	cooldown = 1
	chance_minm = 100
	chance_maxm = 100
	var/activated = FALSE

/datum/disease2/effect/cooldown_boost/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(!activated)
		activated = TRUE
		disease.cooldown_mul += 1
		disease.advance_stage()
		to_chat(mob, "<span class='notice'>You feel that your brain is more active.</span>")

/datum/disease2/effect/chance_boost
	name = "Structure improvement"
	desc = "The virus mutates and changes its structure, making effects show up more likely."
	level = 3
	max_stage = 1
	cooldown = 1
	chance_minm = 100
	chance_maxm = 100
	var/activated = FALSE

/datum/disease2/effect/chance_boost/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(!activated)
		activated = TRUE
		for(var/datum/disease2/effectholder/e in disease.effects)
			e.chance = max(min(e.chance * 2, 100), 40)
		disease.advance_stage()
		to_chat(mob, "<span class='notice'>You feel smarter.</span>")

/datum/disease2/effect/chance_boost/copy(datum/disease2/effectholder/holder_old, datum/disease2/effectholder/holder_new, datum/disease2/effect/effect_old)
	var/datum/disease2/effect/chance_boost/Z = effect_old
	activated = Z.activated

////////////////////////STAGE 4/////////////////////////////////

/datum/disease2/effect/gibbingtons
	name = "Gibbingtons Syndrome"
	desc = "The virus synthesizes hydrogen sulphide in the bloodstream, damaging host's veins and arteries. In extreme cases, overdose of hydrogen sulphide may also cause host to explode in a shower of gore."
	level = 4
	max_stage = 14
	cooldown = 30

/datum/disease2/effect/gibbingtons/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	switch(holder.stage)
		if(1,2,3,4,5)
			to_chat(mob, "<span class='notice'>[pick("You feel angry for some reason.", "Your skin feels flakey.", "Your skin burns.", "Random small wounds are appearing on your skin.")]</span>")
		if(6,7,8,9)
			if(prob(70))
				mob.reagents.add_reagent("potassium", 10)
				mob.reagents.add_reagent("water", 10)
			else
				to_chat(mob, "<span class='warning'>[pick("You feel chemical reactions inside your body.", "Your skin turns into bubbles that explode after a few seconds.", "Blood appears on your skin. Something is ripping you appart!", "Wounds on your body become worse.", "You feel small explosions inside of you.")]</span>")
		if(10,11,12,13)
			if(prob(10) && ishuman(mob))
				var/mob/living/carbon/human/H = mob
				var/bodypart = pick(list(BP_R_ARM , BP_L_ARM , BP_R_LEG , BP_L_LEG))
				var/obj/item/organ/external/BP = H.bodyparts_by_name[bodypart]
				if (BP && !(BP.is_stump))
					mob.emote("scream")
					BP.droplimb(no_explode = FALSE, clean = FALSE, disintegrate = DROPLIMB_BLUNT)
			else
				to_chat(mob, "<span class='userdanger'>[pick("Something is ripping you appart!", "IT HURTS!")]</span>")
				mob.adjustBruteLoss(rand(2,10))
		if(14)
			mob.emote("scream")
			mob.apply_effect(5, WEAKEN)
			mob.make_jittery(50)
			addtimer(CALLBACK(mob, /mob/.proc/gib), 50)

/datum/disease2/effect/radian
	name = "Radian's Syndrome"
	desc = "The virus mutates host's skin cells, increasing exposure to radiation."
	level = 3
	max_stage = 3
	cooldown = 10

/datum/disease2/effect/radian/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	switch(holder.stage)
		if(1)
			to_chat(mob, "<span class='notice'>[pick("You feel warmth.", "You feel weak.")]</span>")
		if(2)
			to_chat(mob, "<span class='warning'>[pick("Your skin is flaking.", "You have a headache.")]</span>")
			mob.apply_effect(5, IRRADIATE, 0)
		if(3)
			mob.apply_effect(20, IRRADIATE, 0)

/*/datum/disease2/effect/deaf
	name = "Dead Ear Syndrome"
	stage = 4
	level = 7

/datum/disease2/effect/deaf/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	mob.ear_deaf += 20*/

/datum/disease2/effect/monkey
	name = "Monkism Syndrome"
	desc = "The virus degrades host's dna, making him into a monkey."
	level = 4
	max_stage = 8
	cooldown = 30

/datum/disease2/effect/monkey/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(istype(mob,/mob/living/carbon/human))
		var/mob/living/carbon/human/h = mob
		switch(holder.stage)
			if(1,2,3)
				to_chat(mob, "<span class='notice'>[pick("You want bananas.", "You feel very primitive.", "Is that a banana?")]</span>")
			if(4,5,6,7)
				if(holder.stage == 7 && prob(20))
					h.say(pick("Bananas?", "Do you have some bananas?", "Ooh-ooh-ooh-eee-eee","Ooh ooh ooh eee eee eee aah aah aah", "Eeek! Eeek!"))
				else
					to_chat(mob, "<span class='danger'>[pick("You really want some bananas.", "You feel yourself slowly degrading.", "You become smaller.", "Fur appears on your skin.")]</span>")
			if(8)
				h.monkeyize()

/datum/disease2/effect/suicide
	name = "Suicidal Syndrome"
	desc = "The virus creates fake thoughts inside host's brain, making him very likely to commit suicide."
	level = 4
	max_stage = 8
	cooldown = 50

/datum/disease2/effect/suicide/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if((holder.stage >= 1 && holder.stage <= 7) || prob(70))
		to_chat(mob, "<span class='notice'>[pick("You feel very bad, thinking that there are people in the world who drown little tajaras.", "You are useless.", "Why do you exist?", "The world would be better without you.", "If suicide isn't an exit, then what is?", "Maybe they were right after all...", "I wish I hadn't been born.", "I wish I was dead.", "I feel so alone...", "Maybe I should end all of this.", "Everything I do is wrong.", "I am just an unfunny joke.", "Why should I disappoint everyone again?")]</span>")
	else if(holder.stage == 8 && mob.stat == CONSCIOUS)
		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			if(prob(90))
				H.emote("gasp")
				H.visible_message("<span class='danger'>[H] tried to hold \his breath but couldn't.</span>")
				H.adjustOxyLoss(60)
			else
				H.visible_message("<span class='danger'>[H] is holding \his breath. It looks like \he is trying to commit suicide.</span>")
				H.adjustOxyLoss(175 - H.getToxLoss() - H.getFireLoss() - H.getBruteLoss() - H.getOxyLoss())
			H.updatehealth()

/datum/disease2/effect/killertoxins
	name = "Toxification Syndrome"
	desc = "The virus causes nausea and irritates the stomach, causing intoxication and occasional vomit."
	level = 3
	max_stage = 3
	cooldown = 10

/datum/disease2/effect/killertoxins/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='warning'>[pick("You feel nauseated.", "You feel like you're going to throw up!")]</span>")
	else if(prob(20) || holder.stage == 2)
		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			H.invoke_vomit_async()
	else if(holder.stage == 3)
		to_chat(mob, "<span class='userdanger'>[pick("Your stomach hurts.", "You feel a sharp abdominal pain.")]</span>")
		mob.reagents.add_reagent(pick("plasticide", "toxin", "amatoxin", "phoron", "lexorin", "carpotoxin", "mindbreaker", "plantbgone", "fluorine"), round(rand(1,3), 1)) // some random toxin


/datum/disease2/effect/dna
	name = "Reverse Pattern Syndrome"
	desc = "The virus bonds with the DNA of the host, causing damaging mutations until removed."
	level = 4
	max_stage = 3
	cooldown = 10

/datum/disease2/effect/dna/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>[pick("For some reason you feel different.", "Your skin feels itchy.", "You feel light headed.")]</span>")
	else if(prob(20) || holder.stage == 2)
		to_chat(mob, "<span class='warning'>[pick("Something is changing inside you.", "Your head hurts.")]</span>")
	else if(holder.stage == 3)
		scramble(0,mob,10)

/datum/disease2/effect/dna/deactivate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	mob.remove_any_mutations()

/datum/disease2/effect/organs
	name = "Shutdown Syndrome"
	desc = "The virus damages bones and muscle tissue, slowly destroying host's external organs. Very lethal."
	level = 4
	max_stage = 7
	cooldown = 20

/datum/disease2/effect/organs/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	switch(holder.stage)
		if(1,2,3)
			to_chat(mob, "<span class='notice'>[pick("Your skin feels itchy.", "You feel weaker.")]</span>")
		if(4,5,6)
			mob.adjustToxLoss(3)
			to_chat(mob, "<span class='warning'>[pick("Your arm hurts.", "Your leg hurts.")]</span>")
		if(7)
			if(ishuman(mob) && prob(40))
				var/mob/living/carbon/human/H = mob
				var/bodypart = pick(list(BP_R_ARM , BP_L_ARM , BP_R_LEG , BP_L_LEG))
				var/obj/item/organ/external/BP = H.bodyparts_by_name[bodypart]
				if (!(BP.status & ORGAN_DEAD))
					BP.status |= ORGAN_DEAD
					to_chat(H, "<span class='warning'>You can't feel your [BP.name] anymore...</span>")
					for (var/obj/item/organ/external/CHILD in BP.children)
						CHILD.status |= ORGAN_DEAD
				H.update_body()
			else
				to_chat(mob, "<span class='userdanger'>[pick("Your hands are trembling and badly hurt.", "You feel your body break apart.")]</span>")
				mob.apply_effect(20,AGONY,0)
				mob.adjustBruteLoss(rand(5,15))

/datum/disease2/effect/organs/deactivate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		for (var/obj/item/organ/external/BP in H.bodyparts)
			BP.status &= ~ORGAN_DEAD
			for (var/obj/item/organ/external/CHILD in BP.children)
				CHILD.status &= ~ORGAN_DEAD
		H.update_body()

/*/datum/disease2/effect/immortal
	name = "Longevity Syndrome"
	stage = 4
	level = 7

/datum/disease2/effect/immortal/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		for (var/obj/item/organ/external/BP in H.bodyparts)
			if (BP.status & ORGAN_BROKEN && prob(30))
				BP.status ^= ORGAN_BROKEN
	var/heal_amt = -5*holder.multiplier
	mob.apply_damages(heal_amt,heal_amt,heal_amt,heal_amt)

/datum/disease2/effect/immortal/deactivate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		to_chat(H, "<span class='notice'>You suddenly feel hurt and old...</span>")
		H.age += 8
	var/backlash_amt = 5*holder.multiplier
	mob.apply_damages(backlash_amt,backlash_amt,backlash_amt,backlash_amt)*/

////////////////////////STAGE 3/////////////////////////////////

/datum/disease2/effect/bones
	name = "Fragile Bones Syndrome"
	desc = "The virus creates a problem with host's production of connective tissue, making bones very fragile."
	level = 4
	max_stage = 8
	cooldown = 60

/datum/disease2/effect/bones/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	switch(holder.stage)
		if(1,2,3,4)
			to_chat(mob, "<span class='notice'>[pick("You seem less agile.", "You move more jaggy than usual.")]</span>")
		if(5,6,7)
			to_chat(mob, "<span class='notice'>[pick("You feel like something is wrong with your bones.", "Your bones creak when you move.")]</span>")
		if(8)
			if(ishuman(mob))
				var/mob/living/carbon/human/H = mob
				var/obj/item/organ/external/BP = pick(H.bodyparts)
				BP.min_broken_damage = max(10, initial(BP.min_broken_damage) - 30)
				to_chat(mob, "<span class='notice'>You feel like your [BP.name] is not as strong as it was before..</span>")

/datum/disease2/effect/bones/deactivate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		for (var/obj/item/organ/external/BP in H.bodyparts)
			BP.min_broken_damage = initial(BP.min_broken_damage)

/datum/disease2/effect/toxins
	name = "Hyperacidity"
	desc = "The virus damages host's stomach, forcing it to produce a lot of acids, causing intoxication."
	level = 3
	max_stage = 3
	cooldown = 20

/datum/disease2/effect/toxins/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	switch(holder.stage)
		if(1)
			to_chat(mob, "<span class='notice'>[pick("You feel an odd gurgle in your stomach.", "You feel nauseated.")]</span>")
		if(2)
			to_chat(mob, "<span class='warning'>[pick("Your stomach hurts.", "You feel a nasty pain inside your throat.")]</span>")
			mob.adjustToxLoss(5)
		if(3)
			to_chat(mob, "<span class='warning'>[pick("Your stomach hurts a lot.", "Your skin seems to become more pale.", "You feel confused.", "Your breathing is hot and irregular.")]</span>")
			mob.adjustToxLoss(10)


/*/datum/disease2/effect/shakey
	name = "World Shaking Syndrome"
	stage = 3
	level = 6
	maxm = 3

/datum/disease2/effect/shakey/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	shake_camera(mob,5*holder.multiplier)*/

/datum/disease2/effect/telepathic
	name = "Telepathy Syndrome"
	desc = "The virus mutates the brain in a strange way, giving host ability to communicate with others through his mind."
	level = 3
	max_stage = 3
	cooldown = 60

/datum/disease2/effect/telepathic/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	switch(holder.stage)
		if(1)
			to_chat(mob, "<span class='notice'>[pick("You heard something.", "Random thoughts are appearing inside your mind.", "Something is not right.")]</span>")
		if(2)
			to_chat(mob, "<span class='warning'>[pick("You panic hearing so much random words.", "You can't understand what is going on with your head.")]</span>")
		if(3)
			mob.dna.check_integrity()
			mob.dna.SetSEState(REMOTETALKBLOCK,1)
			domutcheck(mob, null)

/datum/disease2/effect/mind
	name = "Lazy Mind Syndrome"
	desc = "The virus slowly damages the brain, making host very dumb."
	level = 3
	max_stage = 3
	cooldown = 30

/datum/disease2/effect/mind/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>[pick("Something is not right.", "You forget your name for a moment.", "You suddenly forgot where you were going.")]</span>")
	else if(prob(20) || holder.stage == 2)
		to_chat(mob, "<span class='warning'>[pick("You feel dumb.", "You keep staring at something.", "You are drooling.")]</span>")
		mob.adjustBrainLoss(5)
	else if(holder.stage == 3)
		to_chat(mob, "<span class='userdanger'>[pick("You forgot how to breathe for a moment.", "Who am I?", "You feel very dumb.")]</span>")
		if(ishuman(mob) && prob(10))
			var/mob/living/carbon/human/H = mob
			var/obj/item/organ/internal/brain/IO = H.organs_by_name[O_BRAIN]
			if (IO.damage < IO.min_broken_damage)
				IO.take_damage(1)
			mob.adjustBrainLoss(5)
		else
			mob.adjustBrainLoss(10)

/datum/disease2/effect/hallucinations
	name = "Hallucinational Syndrome"
	desc = "The virus stimulates the brain, causing occasional hallucinations."
	level = 2
	max_stage = 3
	cooldown = 30

/datum/disease2/effect/hallucinations/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>[pick("Something appears in your peripheral vision, then winks out.", "You hear a faint whisper with no source.", "Your head aches.")]</span>")
	else if(prob(20) || holder.stage == 2)
		to_chat(mob, "<span class='danger'>[pick("Something is following you.", "You are being watched.", "You hear a whisper in your ear.", "Thumping footsteps slam toward you from nowhere.")]</span>")
		mob.hallucination = max(mob.hallucination, 50)
	else if(holder.stage == 3)
		to_chat(mob, "<span class='userdanger'>[pick("Oh, your head...", "Your head pounds.", "They're everywhere! Run!", "Something in the shadows...")]</span>")
		mob.hallucination = max(mob.hallucination, 100)

/datum/disease2/effect/deaf
	name = "Hard of Hearing Syndrome"
	desc = "The virus causes inflammation of the eardrums, causing intermittent deafness."
	level = 2
	max_stage = 3
	cooldown = 60
	var/pain_chance = 5

/datum/disease2/effect/deaf/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>[pick("You hear a ringing in your ear.", "Your ears pop.")]</span>")
	else if(prob(20) || holder.stage == 2)
		to_chat(mob, "<span class='warning'><i>Everything is so quiet suddenly...</i></span>")
		mob.ear_deaf = max(mob.ear_deaf, 2)
	else if(holder.stage == 3)
		if(prob(pain_chance))
			to_chat(mob, "<span class='userdanger'>Your ears pop painfully and start bleeding!</span>")
			mob.ear_deaf = max(mob.ear_deaf, 10)
			mob.emote("scream")
		else
			to_chat(mob, "<span class='userdanger'>Your ears pop and begin ringing loudly!</span>")
			mob.ear_deaf = max(mob.ear_deaf, 5)

/datum/disease2/effect/giggle
	name = "Uncontrolled Laughter Effect"
	desc = "The virus creates a neurologic disorder, causing host to laugh unstoppable."
	level = 2
	max_stage = 4
	cooldown = 10
	var/laughing_fit_chance = 5

/datum/disease2/effect/giggle/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>[pick("You smile for no reason.", "You feel very happy.")]</span>")
	else if(prob(20) || holder.stage == 2)
		if(prob(50))
			to_chat(mob, "<span class='notice'>Everything is so good in the world you can't stop smiling.</span>")
		else
			mob.emote(pick("smile","grin"))

	else if(prob(20) || holder.stage == 3)
		if(prob(30))
			to_chat(mob, "<span class='warning'>[pick("You laugh unstoppable.", "You are almost crying from laughter.", "Your lungs hurt from laughing so much.")]</span>")
		else
			mob.emote(pick("laugh","giggle"))
	else if(holder.stage == 4)
		if(prob(30))
			to_chat(mob, "<span class='userdanger'>[pick("AHAHAHA!","MUST LAUGH", "HELP ME, I CAN'T STOP")]</span>")
		else if(prob(laughing_fit_chance))
			to_chat(mob, "<span notice='userdanger'>[pick("You have a laughing fit!", "You can't stop laughing!")]</span>")
			mob.apply_effect(2, WEAKEN)
			mob.make_jittery(50)
			addtimer(CALLBACK(mob, /mob/.proc/emote, pick("laugh","giggle")), 6)
			addtimer(CALLBACK(mob, /mob/.proc/emote, pick("laugh","giggle")), 12)
			addtimer(CALLBACK(mob, /mob/.proc/emote, pick("laugh","giggle")), 18)
		else
			mob.say(pick("haha","ha ha ha","ha","HA","hah","haaaaaa","hehe","hehehe","heh","heh heh","muahaha","mwahaha","heehee","teehee","hahaha","ahahaha","bahaha","gahaha"))

/datum/disease2/effect/confusion
	name = "Topographical Cretinism"
	desc = "The virus damages brain, making host be unable to orient in his surroundings."
	level = 2
	max_stage = 3
	cooldown = 60

/datum/disease2/effect/confusion/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>[pick("You suddenly forget where your right is.", "You suddenly forget where your left is.")]</span>")
	else if(prob(20) || holder.stage == 2)
		to_chat(mob, "<span class='notice'>You have trouble telling right and left apart all of a sudden.</span>")
		mob.confused = max(mob.confused, 2)
	else if(holder.stage == 3)
		to_chat(mob, "<span class='warning'><i>Where am I?</i></span>")
		mob.confused = max(mob.confused, 10)

/*/datum/disease2/effect/mutation
	name = "DNA Degradation"
	stage = 3
	level = 3

/datum/disease2/effect/mutation/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
		mob.apply_damage(2, CLONE)*/


/*/datum/disease2/effect/groan
	name = "Groaning Syndrome"
	stage = 3
	level = 2

/datum/disease2/effect/groan/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	mob.say("*groan")*/
////////////////////////STAGE 2/////////////////////////////////

/datum/disease2/effect/scream
	name = "Loudness Syndrome"
	desc = "The virus damages host's brain, causing uncontrollable loud speech."
	level = 1
	max_stage = 4
	cooldown = 10

/datum/disease2/effect/scream/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>[pick("You want to talk a lot.", "You feel a desire to talk loud.")]</span>")
	else if(prob(20) || holder.stage == 2)
		if(prob(50))
			to_chat(mob, "<span class='warning'>Random squeals come out of your mouth.</span>")
		else
			mob.say(pick("Aaie","Aww","Ah","Eeek"))

	else if(prob(20) || holder.stage == 3)
		if(prob(50))
			to_chat(mob, "<span class='warning'>[pick("Your voice becomes very loud.", "You can't control your mouth.")]</span>")
		else
			mob.say(pick("AAAAH","AARRGH!","AAAWW","AAAAH","AAaiiee","Eeeyyaaauuugghhhhh!"))
	else if(holder.stage == 4)
		if(prob(30))
			to_chat(mob, "<span class='userdanger'>[pick("AAAAH!","MUST SCREAM", "You just can't shut up anymore")]</span>")
		else
			mob.emote("scream")

/datum/disease2/effect/drowsness
	name = "Narcolepsy"
	desc = "The virus causes a hormone imbalance, making the host sleepy and narcoleptic."
	level = 1
	max_stage = 4
	cooldown = 60

/datum/disease2/effect/drowsness/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>You feel tired.</span>")
	else if(prob(20) || holder.stage == 2)
		to_chat(mob, "<span class='warning'>You feel very tired.</span>")
		mob.drowsyness = max(mob.drowsyness, 2)
	else if(prob(20) || holder.stage == 3)
		mob.drowsyness = max(mob.drowsyness, 5)
		to_chat(mob, "<span class='warning'>[pick("You try to focus on staying awake.", "You nod off for a moment.")]</span>")
	else if(holder.stage == 4)
		mob.drowsyness = max(mob.drowsyness, 10)
		to_chat(mob, "<span class='userdanger'>[pick("So tired...","You feel very sleepy.","You have a hard time keeping your eyes open.","You try to stay awake.")]</span>")

		if(prob(10))
			if(prob(50))
				mob.emote("collapse")
			else
				mob.SetSleeping(max(mob.AmountSleeping(), 5 SECONDS))

/datum/disease2/effect/blind
	name = "Hyphema"
	desc = "The virus causes inflammation of the retina, leading to eye damage and eventually blindness."
	level = 1
	max_stage = 4
	cooldown = 10

/datum/disease2/effect/blind/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>Your eyes itch.</span>")
	else if(prob(20) || holder.stage == 2)
		to_chat(mob, "<span class='warning'><i>Your eyes burn!</i></span>")
		mob.eye_blurry = max(mob.eye_blurry, 2)
	else if(holder.stage == 3)
		mob.eye_blurry = max(mob.eye_blurry, 4)
		mob.eye_blind = max(mob.eye_blind, 2)
		to_chat(mob, "<span class='warning'>Your eyes burn very much!</span>")
	else if(holder.stage == 4)
		mob.eye_blurry = max(mob.eye_blurry, 6)
		mob.eye_blind = max(mob.eye_blind, 2)
		to_chat(mob, "<span class='userdanger'>[pick("Your eyes burn!", "Your eyes hurt!")]</span>")

		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			var/obj/item/organ/internal/eyes/E = H.organs_by_name[O_EYES]
			if(E)
				E.damage += 1

/datum/disease2/effect/weight_even
	name = "Weight Even"
	desc = "The virus alters the host's metabolism, making it far more efficient then normal, and synthesizing nutrients from normally unedible sources."
	level = 2
	max_stage = 3
	cooldown = 10
	var/target_nutrition = 400

/datum/disease2/effect/weight_even/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	var/speed = 0
	switch(holder.stage)
		if(1)
			speed = 5
		if(2)
			speed = 10
		if(3)
			speed = 30
			mob.overeatduration = 0

	var/delta = target_nutrition - mob.nutrition
	delta = min(delta, speed)
	delta = max(delta, -speed)
	mob.nutrition = mob.nutrition + delta

/datum/disease2/effect/hungry
	name = "Appetiser Effect"
	desc = "The virus mutates the host's metabolism, making it almost unable to gain nutrition from food."
	level = 1
	max_stage = 3
	cooldown = 30

/datum/disease2/effect/hungry/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		mob.nutrition = max(0, mob.nutrition - 5)
		mob.overeatduration = max(mob.overeatduration - 5, 0)
	else if(prob(20) || holder.stage == 2)
		mob.nutrition = max(0, mob.nutrition - 10)
		mob.overeatduration = max(mob.overeatduration - 10, 0)
	else if(holder.stage == 3)
		mob.nutrition = max(0, mob.nutrition - 20)
		mob.overeatduration = max(mob.overeatduration - 20, 0)
		to_chat(mob, "<span class='warning'><i>[pick("So hungry...", "You'd kill someone for a bite of food...", "Hunger cramps seize you...")]</i></span>")

		if(mob.nutrition < 10 && prob(5))
			to_chat(mob, "<span class='userdanger'>Your hunger makes you very weak.</span>")
			mob.apply_effect(35,AGONY,0)

/datum/disease2/effect/fridge
	name = "Refridgerator Syndrome"
	desc = "The virus inhibits the body's thermoregulation, cooling the body down."
	level = 1
	max_stage = 3
	cooldown = 20

/datum/disease2/effect/fridge/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class = 'notice'>[pick("You feel cold.", "You shiver.")]</span>")
	else if(prob(20) || holder.stage == 2)
		if(prob(50))
			to_chat(mob, "<span class = 'notice'>[pick("You feel very cold.", "Your jaw shakes.", "Your movements are choppy.")]</span>")
		else
			mob.emote("shiver")
		mob.bodytemperature = min(mob.bodytemperature, 260)
	else if(holder.stage == 3)
		if(prob(50))
			to_chat(mob, "<span class = 'warning'>[pick("You feel your blood run cold.", "You feel ice in your veins.", "You feel like you can't heat up.", "You shiver violently.")]</span>")
		else
			mob.emote("shiver")
		mob.bodytemperature = min(mob.bodytemperature, 100)

/datum/disease2/effect/hair
	name = "Hair Loss"
	desc = "The virus causes rapid shedding of head and body hair."
	level = 1
	max_stage = 8
	cooldown = 60

/datum/disease2/effect/hair/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob

		if((is_face_bald(H) && is_bald(H)) || !is_race_valid(H.species.name))
			return
		switch(holder.stage)
			if(1,2,3)
				to_chat(mob, "<span class='warning'>[pick("Your scalp itches.", "Your skin feels flakey.")]</span>")
			if(4,5,6)
				to_chat(mob, "<span class='warning'>[pick("Random hairs start to fall out.", "You feel more bald with every second.")]</span>")
			if(7)
				if(!is_face_bald(H))
					to_chat(H, "<span class='danger'>Your hair starts to fall out in clumps...</span>")
					spawn(50)
						shed(H, TRUE)
			if(8)
				if(!is_face_bald(H) || !is_bald(H))
					to_chat(H, "<span class='danger'>Your hair starts to fall out in clumps...</span>")
					spawn(50)
						shed(H, FALSE)

/datum/disease2/effect/hair/proc/is_race_valid(race)
	if(race == HUMAN || race == TAJARAN)
		return TRUE
	return FALSE

/datum/disease2/effect/hair/proc/is_bald(mob/living/carbon/human/H)
	if(!(H.h_style == "Bald") && !(H.h_style == "Balding Hair") && !(H.h_style == "Skinhead") && !(H.h_style == "Tajaran Ears"))
		return FALSE
	return TRUE

/datum/disease2/effect/hair/proc/is_face_bald(mob/living/carbon/human/H)
	if(!(H.f_style == "Shaved"))
		return FALSE
	return TRUE

/datum/disease2/effect/hair/proc/shed(mob/living/carbon/human/H, onlyface)
	H.f_style = "Shaved"
	if(!onlyface)
		if(H.species.name == HUMAN)
			H.h_style = "Balding Hair"
		else if(H.species.name == TAJARAN)
			H.h_style = "Tajaran Ears"
	H.update_hair()


/datum/disease2/effect/stimulant
	name = "Adrenaline Extra"
	desc = "The virus synthesizes hyperzine in the bloodstream, giving host a lot of energy."
	level = 2
	max_stage = 3
	cooldown = 10
	var/muscles_ache_chance = 5

/datum/disease2/effect/stimulant/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class = 'notice'>[pick("You want to jump around.", "You want to run.")]</span>")
	else if(prob(20) || holder.stage == 2)
		if (mob.reagents.get_reagent_amount("hyperzine") < 1)
			to_chat(mob, "<span class='notice'>You feel a small boost of energy.</span>")
			mob.reagents.add_reagent("hyperzine", 1)
	else if(holder.stage == 3)
		if (mob.reagents.get_reagent_amount("hyperzine") < 10)
			to_chat(mob, "<span class='notice'>You feel a rush of energy inside you!</span>")
			mob.reagents.add_reagent("hyperzine", 4)
		else if(prob(muscles_ache_chance))
			to_chat(mob, "<span class='userdanger'>Your muscles ache.</span>")
			mob.apply_effect(35,AGONY,0)
		if (prob(30))
			mob.make_jittery(150)

////////////////////////STAGE 1/////////////////////////////////

/datum/disease2/effect/cough
	name = "Cough"
	desc = "The virus irritates the throat of the host, causing occasional coughing."
	level = 1
	max_stage = 3
	cooldown = 10
	var/drop_item_chance = 30
	var/couthing_fit_chance = 5

/datum/disease2/effect/cough/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(mob.reagents.has_reagent("dextromethorphan"))
		return
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class = 'notice'>[pick("You swallow excess mucus.", "You lightly cough.")]</span>")
	else if(prob(20) || holder.stage == 2)
		mob.emote("cough")
		disease.spread(mob, 2)
	else if(holder.stage == 3)
		mob.emote("cough")
		disease.spread(mob, 2)
		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			if(prob(drop_item_chance))
				var/obj/item/I = H.get_active_hand()
				if(I && I.w_class <= ITEM_SIZE_SMALL)
					H.drop_item()
			if(prob(couthing_fit_chance))
				to_chat(mob, "<span notice='userdanger'>[pick("You have a coughing fit!", "You can't stop coughing!")]</span>")
				H.Stun(2)
				addtimer(CALLBACK(H, /mob/.proc/emote, "cough"), 6)
				addtimer(CALLBACK(H, /mob/.proc/emote, "cough"), 12)
				addtimer(CALLBACK(H, /mob/.proc/emote, "cough"), 18)

/datum/disease2/effect/sneeze
	name = "Sneezing"
	desc = "The virus causes irritation of the nasal cavity, making the host sneeze occasionally."
	level = 1
	max_stage = 3
	cooldown = 20

/datum/disease2/effect/sneeze/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class = 'notice'>[pick("You sniff a little.", "You want to sneeze.")]</span>")
	else if(prob(20) || holder.stage == 2)
		if(prob(50))
			to_chat(mob, "<span class = 'notice'>[pick("The urge to sneeze is unbearable.")]</span>")
		else if(prob(50))
			mob.emote("sniff")
		else
			mob.emote("sneeze")
			disease.spread(mob, 1)
	else if(holder.stage == 3)
		if(prob(30))
			to_chat(mob, "<span class = 'warning'>[pick("You can't stop the urge to sneeze.")]</span>")
		else
			mob.emote("sneeze")
			disease.spread(mob, 2)
			if(prob(30))
				var/turf/T = get_turf(mob)
				var/obj/effect/decal/cleanable/mucus/M = locate() in T.contents
				if(!M)
					M = new(T)
				M.virus2 = virus_copylist(mob.virus2)

/*/datum/disease2/effect/gunck
	name = "Flemmingtons"
	stage = 1
	level = 1

/datum/disease2/effect/gunck/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	to_chat(mob, "<span class='warning'>Mucous runs down the back of your throat.</span>")*/

/datum/disease2/effect/drool
	name = "Drooling"
	desc = "The virus causes inflammation inside the brain, causing constant drooling."
	level = 1
	max_stage = 3
	cooldown = 10

/datum/disease2/effect/drool/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class = 'notice'>[pick("You swallow excess saliva.", "You seem to forget how to swallow saliva.")]</span>")
	else if(prob(20) || holder.stage == 2)
		if(prob(50))
			to_chat(mob, "<span class = 'notice'>[pick("You find it hard to keep saliva inside your mouth.", "You spit out excess saliva.")]</span>")
		else
			mob.emote("drool")
			disease.spread(mob, 1)
	else if(holder.stage == 3)
		if(prob(30))
			to_chat(mob, "<span class = 'warning'>[pick("You drool for a moment, forgetting to close your mouth.", "You can't stop drooling.")]</span>")
		else
			mob.emote("drool")
			disease.spread(mob, 1)

/datum/disease2/effect/twitch
	name = "Twitcher"
	desc = "The virus causes random muscle spasms, causing constant twitching."
	level = 1
	max_stage = 3
	cooldown = 5

/datum/disease2/effect/twitch/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class = 'notice'>[pick("Your thumb twitches.", "Your ear twitches.", "You twitch a bit.")]</span>")
	else if(prob(20) || holder.stage == 2)
		if(prob(50))
			to_chat(mob, "<span class = 'notice'>[pick("Your whole body wants to twitch.", "Your hand twiches.", "Your leg twiches.")]</span>")
		else
			mob.emote("twitch")
	else if(holder.stage == 3)
		if(prob(30))
			to_chat(mob, "<span class = 'warning'>[pick("The twitching is unbearable.", "You can't stop twitching.", "Your whole body twitches a bit.")]</span>")
		else
			mob.emote("twitch")

/datum/disease2/effect/headache
	name = "Headache"
	desc = "The virus causes inflammation inside the brain, causing constant headaches."
	level = 1
	max_stage = 6
	cooldown = 10
	var/stun_chance = 5

/datum/disease2/effect/headache/activate(mob/living/carbon/mob,datum/disease2/effectholder/holder,datum/disease2/disease/disease)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		if(H.species && !H.species.flags[NO_PAIN])
			if(prob(20) || holder.stage	== 1)
				to_chat(mob, "<span class = 'notice'>[pick("Your head hurts.", "Your head pounds.", "Your head hurts a bit.", "You have a headache.")]</span>")
			else if(prob(20) || (holder.stage >= 2 && holder.stage <= 5))
				to_chat(mob, "<span class = 'warning'>[pick("Your head hurts a lot.", "Your head pounds incessantly.", "You have a throbbing headache.")]</span>")
				H.apply_effect(5,AGONY,0)
			else if(holder.stage == 6)
				to_chat(mob, "<span class = 'userdanger'>[pick("Your head hurts!", "You feel a burning knife inside your brain!", "A wave of pain fills your head!")]</span>")
				if(prob(stun_chance))
					H.apply_effect(30,AGONY,0)
					H.Stun(2)
					mob.emote("scream")
				else
					H.apply_effect(10,AGONY,0)
