/datum/disease2/effectholder
	var/name = "Holder"
	var/datum/disease2/effect/effect
	var/chance = 0 //Chance in percentage each tick
	var/multiplier = 1 //The chance the effects are WORSE
	var/stage = 1
	var/ticks = 0
	var/cooldownticks = 0

/datum/disease2/effectholder/proc/on_process(datum/disease2/disease/virus, atom/host)
	return effect.on_process(virus, host, src)

/datum/disease2/effectholder/proc/runeffect(atom/host, datum/disease2/disease/disease)
	if(cooldownticks > 0)
		cooldownticks -= 1 * disease.cooldown_mul
	if(prob(chance))
		ticks += 1
		if(ticks > stage * 10 && prob(50) && stage < effect.max_stage)
			stage++
		if(cooldownticks <= 0)
			cooldownticks = effect.cooldown
			on_process(disease, host)
			if(!effect.effect_active)
				return
			if(!check_conditions(host, disease, src))
				return
			if(ismob(host))
				effect.activate_mob(host, src, disease)
			if(istype(host, /obj/machinery/hydroponics))
				effect.activate_plant(host, src, disease)

//If false, disables effects
/datum/disease2/effectholder/proc/check_conditions(atom/host, datum/disease2/disease/disease)
	//bloodloss = cell loss. Programs suspended
	if(ishuman(host) && effect.effect_type & MICROBIOLOGY_NANITE)
		var/mob/living/carbon/human/H = host
		var/probability_denied = clamp(BLOOD_VOLUME_OKAY - H.blood_amount(), 0, 100)
		if(prob(probability_denied))
			return FALSE
	return effect.check_conditions(host, disease, src)

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
	var/pools = list()
	var/effect_active = TRUE
	var/effect_type = 0
	//The following vars are customizable
	var/use_rate = 0 			//Amount of cells used while active
	var/program_flags = NONE
	var/list/rogue_mutate_type = list(/*datum/disease2/effect/confusion*/) //What this can turn into if it glitches.

/datum/disease2/effect/proc/activate_mob(mob/living/carbon/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
/datum/disease2/effect/proc/activate_plant(obj/machinery/hydroponics/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
/datum/disease2/effect/proc/deactivate(atom/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
/datum/disease2/effect/proc/copy(datum/disease2/effectholder/holder_old, datum/disease2/effectholder/holder_new, datum/disease2/effect/effect_old)

/datum/disease2/effect/proc/check_conditions(atom/host, datum/disease2/disease/disease, datum/disease2/effectholder/holder)
	return TRUE

/datum/disease2/effect/proc/on_process(datum/disease2/disease/virus, atom/host, datum/disease2/effectholder/holder)
	var/consume_success = consume_cells(use_rate, FALSE, virus, host)
	if(!consume_success && effect_active)
		deactivate(host, holder, virus)
	effect_active = check_conditions(host, virus) && consume_success

/datum/disease2/effect/proc/consume_cells(amount, force = FALSE, datum/disease2/disease/virus, atom/host)
	return virus.consume_cells(amount, force, host)

/datum/disease2/effect/proc/on_death(datum/disease2/disease/virus, atom/host, gibbed)
	return

/datum/disease2/effect/proc/software_error(type, atom/host, datum/disease2/disease/virus)
	if(!type)
		type = rand(1,5)
	switch(type)
		if(1)
			virus.dead = TRUE
		if(2)
			virus.cooldown_mul /= 2
		if(3)
			virus.stage = min(1, virus.stage - 1)
		if(4)
			virus.regen_rate = 0
		if(5) //Effect breakes and does something different
			var/rogue_type = pick(rogue_mutate_type)
			var/datum/disease2/effect/rogue = new rogue_type
			for(var/datum/disease2/effectholder/ef_holder as anything in virus.effects)
				if(ef_holder.effect == src)
					virus.remove_effect(ef_holder.effect)
			virus.addeffect(virus.get_new_effectholder(rogue))

/datum/disease2/effect/proc/on_emp(datum/disease2/disease/virus, atom/host, severity)
	if((effect_type & MICROBIOLOGY_NANITE) && (program_flags & NANITE_EMP_IMMUNE) && prob(80 / severity))
		software_error(null, host, virus)

/datum/disease2/effect/proc/on_shock(datum/disease2/disease/virus, atom/host, shock_damage, obj/current_source, siemens_coeff, def_zone, tesla_shock)
	if((effect_type & MICROBIOLOGY_NANITE) && !(program_flags & NANITE_SHOCK_IMMUNE) && prob(10))
		software_error(1, host, virus)

/datum/disease2/effect/invisible
	name = "Waiting Syndrome"
	level = 0 // can't get this one

/datum/disease2/effect/invisible/activate_mob(mob/living/carbon/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	return

/datum/disease2/effect/heal
	name = "Basic Healing (does nothing)"
	desc = "You should not be seeing this."
	level = 0
	max_stage = 2
	cooldown = 0
	chance_minm = 100
	chance_maxm = 100
	pools = list(POOL_POSITIVE_VIRUS)
	var/passive_message = "" //random message to infected but not actively healing people
	COOLDOWN_DECLARE(heal_message)

/datum/disease2/effect/heal/activate_mob(mob/living/carbon/H, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(holder.stage != 2)
		return
	var/effectiveness = can_heal(H, disease)
	if(effectiveness)
		heal(H, disease, effectiveness)
		return
	if(!passive_message)
		return
	if(!COOLDOWN_FINISHED(src, heal_message))
		return
	if(passive_message_condition(H, disease))
		to_chat(H, passive_message)
		COOLDOWN_START(src, heal_message, rand(1 MINUTE, 3 MINUTES))

/datum/disease2/effect/heal/proc/can_heal(mob/living/carbon/A, datum/disease2/disease/disease)
	return 1

/datum/disease2/effect/heal/proc/can_heal_plant(obj/machinery/hydroponics/A, datum/disease2/disease/disease)
	return 1

/datum/disease2/effect/heal/proc/heal(mob/living/carbon/A, datum/disease2/disease/disease, actual_power)
	return TRUE

/datum/disease2/effect/heal/proc/heal_plant(obj/machinery/hydroponics/A, datum/disease2/disease/disease, actual_power)
	return TRUE

/datum/disease2/effect/heal/proc/passive_message_condition(mob/living/carbon/human/A, datum/disease2/disease/disease)
	return TRUE

/datum/disease2/effect/zombie
	name = "Green Flu"
	desc = "Unknown."
	level = 5
	max_stage = 10
	cooldown = 10
	chance_minm = 20
	chance_maxm = 20
	pools = list(POOL_NEGATIVE_VIRUS)
	var/activated = FALSE
	var/obj/item/organ/external/infected_organ = null //if infected part is removed, destroys itself

/datum/disease2/effect/zombie/activate_mob(mob/living/carbon/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(!ishuman(A))
		return
	var/mob/living/carbon/human/H = A
	if(iszombie(H) || activated)
		disease.dead = TRUE
		UnregisterSignal(H, COMSIG_MOB_DIED)
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
		UnregisterSignal(A, COMSIG_MOB_DIED)
		to_chat(H, "<span class='notice'>You suddenly feel better.</span>")
		return

	var/tox_damage = 0
	var/messages_pool = list()

	H.nutrition = max(H.nutrition - 20, 0)
	messages_pool += "<span class='notice'>[pick("You feel an odd gurgle in your stomach.", "You are hungry for something.", "You suddenly feel better.", "You suddenly feel worse.")]</span>"
	if(holder.stage > 3) //some random stuff
		tox_damage += 1
		if(prob(10))
			H.emote(pick("twitch","drool","sneeze","sniff","cough","shiver","giggle","laugh","gasp"))
		messages_pool += "<span class='warning'>[pick("Your [infected_organ.name] seems to become more green...", "Your [infected_organ.name] hurts...")]</span>"
	if(holder.stage > 6) //pain
		messages_pool += "<span class='danger'>[pick("Your brain hurts.", "Your [infected_organ.name] hurts a lot.", "Your muscles ache.", "Your muscles are sore.")]</span>"
		H.adjustBrainLoss(5)
		tox_damage += 2
	if(holder.stage > 8) //IT HURTS
		if(prob(33))
			messages_pool += "<span class='danger'>[pick("IT HURTS", "You feel a sharp pain across your whole body!")]</span>"
			H.adjustBruteLoss(20)
			H.apply_effect(20, AGONY, 0)
		else if(prob(33) && H.stat == CONSCIOUS)
			messages_pool += "<span class='danger'>[pick("Your heart stop for a second.", "It's hard for you to breathe.")]</span>"
			H.adjustOxyLoss(10)
			H.losebreath = 5
		else
			messages_pool += "<span class='danger'>Your body is paralyzed.</span>"
			H.Stun(4)

	H.adjustToxLoss(tox_damage)
	if(prob(50))
		to_chat(H, pick(messages_pool))

	if(holder.stage > 9) //rip
		activated = TRUE
		H.suiciding = TRUE
		UnregisterSignal(H, COMSIG_MOB_DIED)
		H.adjustOxyLoss(max(H.maxHealth * 2 - H.getToxLoss() - H.getFireLoss() - H.getBruteLoss() - H.getOxyLoss(), 0))
		H.updatehealth()
		disease.dead = TRUE

/datum/disease2/effect/zombie/copy(datum/disease2/effectholder/holder_old, datum/disease2/effectholder/holder_new, datum/disease2/effect/effect_old)
	var/datum/disease2/effect/zombie/Z = effect_old
	infected_organ = Z.infected_organ

/datum/disease2/effect/zombie/deactivate(atom/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	. = ..()
	if(ishuman(A))
		UnregisterSignal(A, COMSIG_MOB_DIED)

/datum/disease2/effect/zombie/proc/handle_infected_death(mob/user)
	SIGNAL_HANDLER
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/human, prerevive_zombie)), 600)
		to_chat(H, "<span class='cult'>Твоё сердце останавливается, но вместе с этим просыпается ненасытный ГОЛОД... \
				Вот только жизнь не покинула твоё бездыханное тело. \
				Этот голод не отпускает тебя, ты ещё восстанешь, что бы распространять болезнь и сеять смерть!</span>")
		activated = TRUE
		UnregisterSignal(H, COMSIG_MOB_DIED)

////////////////////////STAGE 4/////////////////////////////////

/datum/disease2/effect/heal/chem
	name = "Toxolysis"
	desc = "The virus rapidly breaks down any foreign chemicals in the bloodstream."
	level = 4

/datum/disease2/effect/heal/chem/heal(mob/living/carbon/human/M, datum/disease2/disease/disease, actual_power)
	for(var/datum/reagent/R in M.reagents.reagent_list) //Not just toxins!
		M.reagents.remove_reagent(R.id, actual_power)
		if(prob(2))
			to_chat(M, "<span class='notice'>You feel a mild warmth as your blood purifies itself.</span>")
	return 1

/datum/disease2/effect/heal/coma
	name = "Regenerative Coma"
	desc = "The virus causes the host to fall into a death-like coma when severely damaged, then rapidly fixes the damage."
	level = 4
	passive_message = "<span class='notice'>The pain from your wounds makes you feel oddly sleepy...</span>"
	var/active_coma = FALSE

/datum/disease2/effect/heal/coma/can_heal(mob/living/carbon/human/M, datum/disease2/disease/disease)
	if(M.status_flags & FAKEDEATH)
		return 1
	else if(M.stat == UNCONSCIOUS)
		return 0.5
	else if(M.getBruteLoss() + M.getFireLoss() >= 120 && !active_coma)
		to_chat(M, "<span class='warning'>You feel yourself slip into a regenerative coma...</span>")
		active_coma = TRUE
		addtimer(CALLBACK(src, PROC_REF(coma), M), 60)

/datum/disease2/effect/heal/coma/proc/coma(mob/living/carbon/human/M)
	//M.emote("deathgasp")
	M.add_status_flags(FAKEDEATH)
	addtimer(CALLBACK(src, PROC_REF(uncoma), M), 300)

/datum/disease2/effect/heal/coma/proc/uncoma(mob/living/carbon/human/M)
	if(!active_coma)
		return
	active_coma = FALSE
	M.remove_status_flags(FAKEDEATH)

/datum/disease2/effect/heal/coma/heal(mob/living/carbon/human/M, datum/disease2/disease/disease, actual_power)
	var/heal_amt = 4 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,1)

	if(!parts.len)
		return

	M.heal_bodypart_damage(heal_amt, heal_amt)

	if(active_coma && M.getBruteLoss() + M.getFireLoss() == 0)
		uncoma(M)
	return 1

/datum/disease2/effect/heal/coma/passive_message_condition(mob/living/carbon/human/M, datum/disease2/disease/disease)
	if((M.getBruteLoss() + M.getFireLoss()) > 30)
		return TRUE
	return FALSE

/datum/disease2/effect/metabolism
	name = "Metabolic Boost"
	desc = "The virus causes the host's metabolism to accelerate rapidly, making them process chemicals twice as fast, but also causing increased hunger."
	level = 4
	cooldown = 60
	max_stage = 5
	pools = list(POOL_NEUTRAL_VIRUS, POOL_NEGATIVE_VIRUS)
	COOLDOWN_DECLARE(metabolicboost_message)

/datum/disease2/effect/metabolism/activate_mob(mob/living/carbon/human/M, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(M.reagents)
		M.reagents.metabolize(M) //this works even without a liver; it's intentional since the virus is metabolizing by itself
	M.overeatduration = max(M.overeatduration - 2, 0)
	var/lost_nutrition = 2
	M.nutrition = max(M.nutrition - (lost_nutrition * M.get_metabolism_factor()), 0) //Hunger depletes at 2x the normal speed
	if(!COOLDOWN_FINISHED(src, metabolicboost_message))
		return
	to_chat(M, "<span class='notice'>You feel an odd gurgle in your stomach, as if it was working much faster than normal.</span>")
	COOLDOWN_START(src, metabolicboost_message, 1 MINUTES)

/datum/disease2/effect/metabolism/activate_plant(obj/machinery/hydroponics/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	A.adjustSpeedmultiplier(holder.stage)

/datum/disease2/effect/flesh_death
	name = "Autophagocytosis Necrosis"
	desc = "The virus rapidly consumes infected cells, leading to heavy and widespread damage."
	level = 4
	max_stage = 3
	cooldown = 5
	chance_maxm = 20
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/flesh_death/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || (holder.stage >= 1 && holder.stage <= 2))
		to_chat(mob, "<span class='warning'>[pick("You feel your body break apart.", "Your skin rubs off like dust.")]</span>")
	else if(holder.stage == 3)
		to_chat(mob, "<span class='userdanger'>[pick("You feel your muscles weakening.", "Some of your skin detaches itself.", "You feel sandy.")]</span>")
		mob.adjustBruteLoss(rand(6,10))

/datum/disease2/effect/stage_boost
	name = "Quick growth"
	desc = "The virus mutates and quickly grows, reaching its full potential in moments."
	level = 4
	max_stage = 1
	cooldown = 1
	chance_minm = 100
	chance_maxm = 100
	pools = list(POOL_NEUTRAL_VIRUS)

/datum/disease2/effect/stage_boost/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(disease.stage < disease.effects.len)
		disease.stage = disease.effects.len
		to_chat(mob, "<span class='notice'>You feel warmth inside your head.</span>")

/datum/disease2/effect/gibbingtons
	name = "Gibbingtons Syndrome"
	desc = "The virus synthesizes hydrogen sulphide in the bloodstream, damaging host's veins and arteries. In extreme cases, overdose of hydrogen sulphide may also cause host to explode in a shower of gore."
	level = 4
	max_stage = 14
	cooldown = 30
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/gibbingtons/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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
			addtimer(CALLBACK(mob, TYPE_PROC_REF(/mob/, gib)), 50)

/datum/disease2/effect/vomit
	name = "Haematemesis's Syndrome"
	desc = "The virus introduces nanites into the host's digestive system, which multiply and begin to eat the body's tissues, causing bleeding with vomiting."
	level = 4
	max_stage = 3
	cooldown = 60
	use_rate = 1.5
	rogue_mutate_type = list(/datum/disease2/effect/organs)
	effect_type = MICROBIOLOGY_NANITE
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/vomit/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	switch(holder.stage)
		if(1)
			to_chat(mob, "<span class='warning'>Your chest hurts!</span>")
		if(2)
			mob.vomit(vomit_type = VOMIT_BLOOD, stun = FALSE)
			if(ishuman(mob))
				var/mob/living/carbon/human/H = mob
				H.blood_remove(2)
		if(3)
			mob.vomit(vomit_type = VOMIT_NANITE)
			if(ishuman(mob))
				var/mob/living/carbon/human/H = mob
				H.blood_remove(5)

/datum/disease2/effect/monkey
	name = "Monkism Syndrome"
	desc = "The virus degrades host's dna, making him into a monkey."
	level = 4
	max_stage = 8
	cooldown = 30
	pools = list(POOL_NEUTRAL_VIRUS, POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/monkey/activate_mob(mob/living/carbon/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(ishuman(A))
		var/mob/living/carbon/human/h = A
		switch(holder.stage)
			if(1,2,3)
				to_chat(A, "<span class='notice'>[pick("You want bananas.", "You feel very primitive.", "Is that a banana?")]</span>")
			if(4,5,6,7)
				if(holder.stage == 7 && prob(20))
					h.say(pick("Bananas?", "Do you have some bananas?", "Ooh-ooh-ooh-eee-eee","Ooh ooh ooh eee eee eee aah aah aah", "Eeek! Eeek!"))
				else
					to_chat(A, "<span class='danger'>[pick("You really want some bananas.", "You feel yourself slowly degrading.", "You become smaller.", "Fur appears on your skin.")]</span>")
			if(8)
				h.monkeyize()

/datum/disease2/effect/suicide
	name = "Suicidal Syndrome"
	desc = "The virus creates fake thoughts inside host's brain, making him very likely to commit suicide."
	level = 4
	max_stage = 8
	cooldown = 50
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/suicide/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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

/datum/disease2/effect/dna
	name = "Reverse Pattern Syndrome"
	desc = "The virus bonds with the DNA of the host, causing damaging mutations until removed."
	level = 4
	max_stage = 3
	cooldown = 10
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/dna/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>[pick("For some reason you feel different.", "Your skin feels itchy.", "You feel light headed.")]</span>")
	else if(prob(20) || holder.stage == 2)
		to_chat(mob, "<span class='warning'>[pick("Something is changing inside you.", "Your head hurts.")]</span>")
	else if(holder.stage == 3)
		scramble(0,mob,10)

/datum/disease2/effect/dna/deactivate(atom/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(!iscarbon(A))
		return
	var/mob/living/carbon/mob = A
	mob.remove_any_mutations()

/datum/disease2/effect/organs
	name = "Shutdown Syndrome"
	desc = "The virus damages bones and muscle tissue, slowly destroying host's external organs. Very lethal."
	level = 4
	max_stage = 7
	cooldown = 20
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/organs/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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

/datum/disease2/effect/organs/deactivate(atom/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		for(var/obj/item/organ/external/BP in H.bodyparts)
			BP.status &= ~ORGAN_DEAD
			for(var/obj/item/organ/external/CHILD in BP.children)
				CHILD.status &= ~ORGAN_DEAD
		H.update_body()

/datum/disease2/effect/bones
	name = "Fragile Bones Syndrome"
	desc = "The virus creates a problem with host's production of connective tissue, making bones very fragile."
	level = 4
	max_stage = 8
	cooldown = 60
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/bones/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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

/datum/disease2/effect/bones/deactivate(atom/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		for (var/obj/item/organ/external/BP in H.bodyparts)
			BP.min_broken_damage = initial(BP.min_broken_damage)

////////////////////////STAGE 3/////////////////////////////////

/datum/disease2/effect/heal/starlight
	name = "Starlight Condensation"
	desc = "The virus reacts to direct starlight, producing regenerative chemicals. Works best against toxin-based damage."
	level = 3
	passive_message = "<span class='notice'>You miss the feeling of starlight on your skin.</span>"

/datum/disease2/effect/heal/starlight/proc/calculate_spacepower(atom/A)
	if(isspaceturf(get_turf(A)))
		return 1
	else
		for(var/turf/T in view(2, A))
			if(isspaceturf(T))
				return 0.5

/datum/disease2/effect/heal/starlight/can_heal(mob/living/carbon/A, datum/disease2/disease/disease)
	return calculate_spacepower(A)

/datum/disease2/effect/heal/starlight/can_heal_plant(obj/machinery/hydroponics/A, datum/disease2/disease/disease)
	return calculate_spacepower(A)

/datum/disease2/effect/heal/starlight/heal(mob/living/carbon/human/M, datum/disease2/disease/disease, actual_power)
	if(M.getToxLoss())
		passive_message = "<span class='notice'>Your skin tingles as the starlight seems to heal you.</span>"
	else
		passive_message = initial(passive_message)
	M.adjustToxLoss(-(4 * actual_power)) //most effective on toxins
	var/list/parts = M.get_damaged_bodyparts(1, 1)
	if(!parts.len)
		return
	M.heal_bodypart_damage(actual_power, actual_power)
	return TRUE

/datum/disease2/effect/heal/starlight/activate_plant(obj/machinery/hydroponics/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(holder.stage != 2)
		return
	var/effectiveness = can_heal_plant(A, disease)
	if(effectiveness)
		heal_plant(A, disease, effectiveness)

/datum/disease2/effect/heal/starlight/heal_plant(obj/machinery/hydroponics/A, datum/disease2/disease/disease, actual_power)
	A.adjustHealth(actual_power)
	A.adjustToxic(-(4 * actual_power))
	return 1

/datum/disease2/effect/heal/starlight/passive_message_condition(mob/living/carbon/human/M, datum/disease2/disease/disease)
	if(M.getBruteLoss() || M.getFireLoss() || M.getToxLoss())
		return TRUE
	return FALSE

/datum/disease2/effect/heal/darkness
	name = "Nocturnal Regeneration"
	desc = "The virus is able to mend the host's flesh when in conditions of low light, repairing physical damage. More effective against brute damage."
	level = 3
	passive_message = "<span class='notice'>You feel tingling on your skin as light passes over it.</span>"

/datum/disease2/effect/heal/darkness/can_heal(mob/living/carbon/human/M, datum/disease2/disease/disease)
	var/light_amount = 0
	if(M.loc && isspaceturf(M.loc))
		return 0
	if(isturf(M.loc))
		var/turf/T = M.loc
		light_amount = min(1,T.get_lumcount())
		if(light_amount < 0.7)
			return 1
		else
			return 0
	return 0.5  // If they are inside something, let them heal, but more slowly

/datum/disease2/effect/heal/darkness/heal(mob/living/carbon/human/M, datum/disease2/disease/disease, actual_power)
	var/heal_amt = 2 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,1)

	if(!parts.len)
		return

	if(prob(5))
		to_chat(M, "<span class='notice'>The darkness soothes and mends your wounds.</span>")

	M.heal_bodypart_damage(heal_amt, heal_amt * 0.5) //more effective on brute
	return 1

/datum/disease2/effect/heal/darkness/passive_message_condition(mob/living/carbon/human/M, datum/disease2/disease/disease)
	if(M.getBruteLoss() || M.getFireLoss())
		return TRUE
	return FALSE

/datum/disease2/effect/fire
	name = "Spontaneous Combustion"
	desc = "The virus turns fat into an extremely flammable compound, and raises the body's temperature, making the host burst into flames spontaneously."
	level = 3
	max_stage = 3
	cooldown = 30
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/fire/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/flesh_eating/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(50) || (holder.stage >= 1 && holder.stage <= 3))
		to_chat(mob, "<span class='warning'>[pick("You feel a sudden pain across your body.", "Drops of blood appear suddenly on your skin.")]</span>")
	else if(holder.stage == 4)
		to_chat(mob, "<span class='userdanger'>[pick("You cringe as a violent pain takes over your body.", "It feels like your body is eating itself inside out.", "IT HURTS.")]</span>")
		mob.adjustBruteLoss(rand(15, 25))

/datum/disease2/effect/mind_restoration
	name = "Mind Restoration"
	desc = "The virus strengthens the bonds between neurons, reducing the duration of any ailments of the mind."
	level = 3
	max_stage = 5
	cooldown = 5
	chance_minm = 100
	chance_maxm = 100
	pools = list(POOL_POSITIVE_VIRUS)

/datum/disease2/effect/mind_restoration/activate_mob(mob/living/carbon/M, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(holder.stage	>= 3)
		M.dizziness = max(0, M.dizziness - 2)
		M.drowsyness = max(0, M.drowsyness - 2)
		M.slurring = max(0, M.slurring - 2)
		M.AdjustConfused(-2)
		M.adjustDrugginess(-2)
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
	pools = list(POOL_POSITIVE_VIRUS)

/datum/disease2/effect/sensory_restoration/activate_mob(mob/living/carbon/M, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(holder.stage	== 4)
		M.adjustBlurriness(-5)
		M.eye_blind = max(M.eye_blind - 5, 0)
		M.ear_damage = max(M.ear_damage - 1, 0)
		M.ear_deaf = max(M.ear_deaf - 1, 0)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/internal/eyes/IO = H.organs_by_name[O_EYES]
			if(istype(IO))
				if(IO.damage > 0)
					IO.damage = max(IO.damage - 1, 0)

/datum/disease2/effect/cooldown_boost
	name = "Virus booster"
	desc = "The virus mutates and becomes more active, reducing the time between effects."
	level = 3
	max_stage = 1
	cooldown = 1
	chance_minm = 100
	chance_maxm = 100
	pools = list(POOL_NEUTRAL_VIRUS)
	var/activated = FALSE

/datum/disease2/effect/cooldown_boost/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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
	pools = list(POOL_NEUTRAL_VIRUS)
	var/activated = FALSE

/datum/disease2/effect/chance_boost/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(!activated)
		activated = TRUE
		for(var/datum/disease2/effectholder/e in disease.effects)
			e.chance = max(min(e.chance * 2, 100), 40)
		disease.advance_stage()
		to_chat(mob, "<span class='notice'>You feel smarter.</span>")

/datum/disease2/effect/chance_boost/copy(datum/disease2/effectholder/holder_old, datum/disease2/effectholder/holder_new, datum/disease2/effect/effect_old)
	var/datum/disease2/effect/chance_boost/Z = effect_old
	activated = Z.activated

/datum/disease2/effect/radian
	name = "Radian's Syndrome"
	desc = "The virus mutates host's skin cells, increasing exposure to radiation."
	level = 3
	max_stage = 3
	cooldown = 10
	pools = list(POOL_NEUTRAL_VIRUS, POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/radian/activate_mob(mob/living/carbon/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	switch(holder.stage)
		if(1)
			to_chat(A, "<span class='notice'>[pick("You feel warmth.", "You feel weak.")]</span>")
		if(2)
			to_chat(A, "<span class='warning'>[pick("Your skin is flaking.", "You have a headache.")]</span>")
			irradiate_one_mob(A, 5)
		if(3)
			irradiate_one_mob(A, 20)

/datum/disease2/effect/radian/activate_plant(obj/machinery/hydroponics/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	A.adjustMutationmod(holder.stage)

/datum/disease2/effect/killertoxins
	name = "Toxification Syndrome"
	desc = "The virus causes nausea and irritates the stomach, causing intoxication and occasional vomit."
	level = 3
	max_stage = 3
	cooldown = 10
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/killertoxins/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='warning'>[pick("You feel nauseated.", "You feel like you're going to throw up!")]</span>")
	else if(prob(20) || holder.stage == 2)
		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			H.invoke_vomit_async()
	else if(holder.stage == 3)
		to_chat(mob, "<span class='userdanger'>[pick("Your stomach hurts.", "You feel a sharp abdominal pain.")]</span>")
		mob.reagents.add_reagent(pick("plasticide", "toxin", "amatoxin", "phoron", "lexorin", "carpotoxin", "mindbreaker", "plantbgone", "fluorine"), round(rand(1, 3), 1)) // some random toxin

/datum/disease2/effect/toxins
	name = "Hyperacidity"
	desc = "The virus damages host's stomach, forcing it to produce a lot of acids, causing intoxication."
	level = 3
	max_stage = 3
	cooldown = 20
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/toxins/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	switch(holder.stage)
		if(1)
			to_chat(mob, "<span class='notice'>[pick("You feel an odd gurgle in your stomach.", "You feel nauseated.")]</span>")
		if(2)
			to_chat(mob, "<span class='warning'>[pick("Your stomach hurts.", "You feel a nasty pain inside your throat.")]</span>")
			mob.adjustToxLoss(5)
		if(3)
			to_chat(mob, "<span class='warning'>[pick("Your stomach hurts a lot.", "Your skin seems to become more pale.", "You feel confused.", "Your breathing is hot and irregular.")]</span>")
			mob.adjustToxLoss(10)

/datum/disease2/effect/nerve_decay
	name = "Nerve Decay"
	desc = "The virus produces nanites that attacks the host's nerves, causing lack of coordination and short bursts of paralysis."
	level = 3
	max_stage = 10
	cooldown = 5
	use_rate = 1
	rogue_mutate_type = list(/datum/disease2/effect/flesh_eating)
	effect_type = MICROBIOLOGY_NANITE
	COOLDOWN_DECLARE(nerv_decay_message)

/datum/disease2/effect/nerve_decay/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	switch(holder.stage)
		if(1 to 5)
			if(COOLDOWN_FINISHED(src, nerv_decay_message))
				to_chat(mob, "<span class='warning'>You feel unbalanced!</span>")
				COOLDOWN_START(src, nerv_decay_message, 1 MINUTE)
			mob.AdjustConfused(holder.stage)
		if(6 to 9)
			if(COOLDOWN_FINISHED(src, nerv_decay_message))
				to_chat(mob, "<span class='warning'>You can't feel your hands!</span>")
				COOLDOWN_START(src, nerv_decay_message, 1 MINUTE)
			mob.drop_item()
		else
			if(COOLDOWN_FINISHED(src, nerv_decay_message))
				to_chat(mob, "<span class='warning'>You can't feel your legs!</span>")
				COOLDOWN_START(src, nerv_decay_message, 1 MINUTE)
			mob.AdjustWeakened(7)

/datum/disease2/effect/nerve_support
	name = "Nerve Support"
	desc = "The virus injects nanites into the host's body, which act as a secondary nervous system, protecting against nerve palsies."
	level = 3
	max_stage = 3
	cooldown = 7
	use_rate = 1.5
	rogue_mutate_type = list(/datum/disease2/effect/nerve_decay, /datum/disease2/effect/giggle, /datum/disease2/effect/cough)
	effect_type = MICROBIOLOGY_NANITE
	pools = list(POOL_POSITIVE_VIRUS)
	var/trait_added = FALSE
	COOLDOWN_DECLARE(senses_message)

/datum/disease2/effect/nerve_support/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	switch(holder.stage)
		if(1)
			if(COOLDOWN_FINISHED(src, senses_message))
				to_chat(mob, "<span class='notice'>You feel your tactile senses intensify.</span>")
				COOLDOWN_START(src, senses_message, 1 MINUTE)
		if(2)
			mob.make_dizzy(min(mob.dizziness + 10, 15))
			mob.adjustHalLoss(-3)
		if(3)
			if(trait_added)
				return
			ADD_TRAIT(mob, TRAIT_STEEL_NERVES, VIRUS_TRAIT)
			trait_added = TRUE

/datum/disease2/effect/nerve_support/deactivate(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	REMOVE_TRAIT(mob, TRAIT_STEEL_NERVES, VIRUS_TRAIT)
	trait_added = FALSE

/datum/disease2/effect/telepathic
	name = "Telepathy Syndrome"
	desc = "The virus mutates the brain in a strange way, giving host ability to communicate with others through his mind."
	level = 3
	max_stage = 3
	cooldown = 60
	pools = list(POOL_POSITIVE_VIRUS)

/datum/disease2/effect/telepathic/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/mind/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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

/datum/disease2/effect/repairing
	name = "Mechanical Repair"
	desc = "The virus produces nanites that fix damage in the host's mechanical limbs."
	level = 3
	max_stage = 7
	cooldown = 10
	use_rate = 0.5
	rogue_mutate_type = list(/datum/disease2/effect/flesh_eating)
	effect_type = MICROBIOLOGY_NANITE
	pools = list(POOL_POSITIVE_VIRUS)

/datum/disease2/effect/repairing/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(!ishuman(mob))
		return
	var/mob/living/carbon/human/H = mob
	var/list/parts = list()
	for(var/obj/item/organ/external/BP in H.bodyparts)
		if(BP.is_robotic())
			if(BP.get_damage())
				parts += BP
	if(!parts.len)
		return
	var/countBPhealed = 1
	for(var/obj/item/organ/external/BP in shuffle(parts))
		if(countBPhealed > holder.stage)
			return
		countBPhealed++
		BP.heal_damage(1 / parts.len, 1 / parts.len, robo_repair = TRUE)

////////////////////////STAGE 2/////////////////////////////////

/datum/disease2/effect/beard
	name = "Facial Hypertrichosis"
	desc = "The virus increases hair production significantly, causing rapid beard growth."
	level = 2
	max_stage = 3
	cooldown = 30
	pools = list(POOL_NEUTRAL_VIRUS)

/datum/disease2/effect/beard/activate_mob(mob/living/carbon/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
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

/datum/disease2/effect/hallucinations
	name = "Hallucinational Syndrome"
	desc = "The virus stimulates the brain, causing occasional hallucinations."
	level = 2
	max_stage = 3
	cooldown = 30
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/hallucinations/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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
	pools = list(POOL_NEGATIVE_VIRUS)
	var/pain_chance = 5

/datum/disease2/effect/deaf/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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
	pools = list(POOL_NEGATIVE_VIRUS)
	var/laughing_fit_chance = 5

/datum/disease2/effect/giggle/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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
			addtimer(CALLBACK(mob, TYPE_PROC_REF(/mob/, emote), pick("laugh","giggle")), 6)
			addtimer(CALLBACK(mob, TYPE_PROC_REF(/mob/, emote), pick("laugh","giggle")), 12)
			addtimer(CALLBACK(mob, TYPE_PROC_REF(/mob/, emote), pick("laugh","giggle")), 18)
		else
			mob.say(pick("haha","ha ha ha","ha","HA","hah","haaaaaa","hehe","hehehe","heh","heh heh","muahaha","mwahaha","heehee","teehee","hahaha","ahahaha","bahaha","gahaha"))

/datum/disease2/effect/confusion
	name = "Topographical Cretinism"
	desc = "The virus damages brain, making host be unable to orient in his surroundings."
	level = 2
	max_stage = 3
	cooldown = 60
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/confusion/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>[pick("You suddenly forget where your right is.", "You suddenly forget where your left is.")]</span>")
	else if(prob(20) || holder.stage == 2)
		to_chat(mob, "<span class='notice'>You have trouble telling right and left apart all of a sudden.</span>")
		mob.MakeConfused(2)
	else if(holder.stage == 3)
		to_chat(mob, "<span class='warning'><i>Where am I?</i></span>")
		mob.MakeConfused(10)

/datum/disease2/effect/purging_advanced
	name = "Selective Purification"
	desc = "The virus purge toxins and dangerous chemicals from the host's bloodstream, while ignoring beneficial chemicals."
	level = 2
	max_stage = 1
	cooldown = 30
	pools = list(POOL_POSITIVE_VIRUS)

/datum/disease2/effect/purging_advanced/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(!mob.getToxLoss())
		return
	if(!mob.reagents)
		return
	for(var/datum/reagent/toxin/R in mob.reagents.reagent_list)
		mob.reagents.remove_reagent(R.id, 1)

/datum/disease2/effect/weight_even
	name = "Weight Even"
	desc = "The virus alters the host's metabolism, making it far more efficient then normal, and synthesizing nutrients from normally unedible sources."
	level = 2
	max_stage = 3
	cooldown = 10
	pools = list(POOL_POSITIVE_VIRUS)
	var/target_nutrition = NUTRITION_LEVEL_NORMAL

/datum/disease2/effect/weight_even/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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

/datum/disease2/effect/stimulant
	name = "Adrenaline Extra"
	desc = "The virus synthesizes stimulants in the bloodstream, giving host a lot of energy."
	level = 2
	max_stage = 3
	cooldown = 10
	pools = list(POOL_POSITIVE_VIRUS, POOL_NEUTRAL_VIRUS)
	var/muscles_ache_chance = 5

/datum/disease2/effect/stimulant/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class = 'notice'>[pick("You want to jump around.", "You want to run.")]</span>")
	else if(prob(20) || holder.stage == 2)
		if (mob.reagents.get_reagent_amount("stimulants") < 1)
			to_chat(mob, "<span class='notice'>You feel a small boost of energy.</span>")
			mob.reagents.add_reagent("stimulants", 1)
	else if(holder.stage == 3)
		if (mob.reagents.get_reagent_amount("stimulants") < 10)
			to_chat(mob, "<span class='notice'>You feel a rush of energy inside you!</span>")
			mob.reagents.add_reagent("stimulants", 4)
		else if(prob(muscles_ache_chance))
			to_chat(mob, "<span class='userdanger'>Your muscles ache.</span>")
			mob.apply_effect(35,AGONY,0)
		if (prob(30))
			mob.make_jittery(150)

/datum/disease2/effect/mute
	name = "Absorption"
	desc = "The virus produces nanites on the host's skin that absorb sound waves."
	level = 2
	max_stage = 2
	cooldown = 10
	use_rate = 0.75
	rogue_mutate_type = list(/datum/disease2/effect/mind, /datum/disease2/effect/drowsness, /datum/disease2/effect/confusion, /datum/disease2/effect/hallucinations)
	effect_type = MICROBIOLOGY_NANITE
	pools = list(POOL_NEUTRAL_VIRUS, POOL_NEGATIVE_VIRUS)
	var/trait_added = FALSE
	COOLDOWN_DECLARE(mute_message)

/datum/disease2/effect/mute/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	switch(holder.stage)
		if(1)
			if(!COOLDOWN_FINISHED(src, mute_message))
				return
			to_chat(mob, "<span class='warning'>You begin to hear your own speech worse.</span>")
			COOLDOWN_START(src, mute_message, 1 MINUTES)
		if(2)
			if(trait_added)
				return
			ADD_TRAIT(mob, TRAIT_MUTE, VIRUS_TRAIT)

/datum/disease2/effect/mute/deactivate(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	REMOVE_TRAIT(mob, TRAIT_MUTE, VIRUS_TRAIT)
	trait_added = FALSE

////////////////////////STAGE 1/////////////////////////////////

/datum/disease2/effect/scream
	name = "Loudness Syndrome"
	desc = "The virus damages host's brain, causing uncontrollable loud speech."
	level = 1
	max_stage = 4
	cooldown = 10
	pools = list(POOL_NEUTRAL_VIRUS)

/datum/disease2/effect/scream/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/drowsness/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/blind/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>Your eyes itch.</span>")
	else if(prob(20) || holder.stage == 2)
		to_chat(mob, "<span class='warning'><i>Your eyes burn!</i></span>")
		mob.blurEyes(5)
	else if(holder.stage == 3)
		mob.blurEyes(10)
		mob.eye_blind = max(mob.eye_blind, 2)
		to_chat(mob, "<span class='warning'>Your eyes burn very much!</span>")
	else if(holder.stage == 4)
		mob.blurEyes(20)
		mob.eye_blind = max(mob.eye_blind, 2)
		to_chat(mob, "<span class='userdanger'>[pick("Your eyes burn!", "Your eyes hurt!")]</span>")

		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			var/obj/item/organ/internal/eyes/E = H.organs_by_name[O_EYES]
			if(E)
				E.damage += 1

/datum/disease2/effect/hungry
	name = "Appetiser Effect"
	desc = "The virus mutates the host's metabolism, making it almost unable to gain nutrition from food."
	level = 1
	max_stage = 3
	cooldown = 30
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/hungry/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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
	pools = list(POOL_NEUTRAL_VIRUS, POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/fridge/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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
	pools = list(POOL_NEUTRAL_VIRUS)

/datum/disease2/effect/hair/activate_mob(mob/living/carbon/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A

		if((is_face_bald(H) && is_bald(H)) || !is_race_valid(H.species.name))
			return
		switch(holder.stage)
			if(1,2,3)
				to_chat(H, "<span class='warning'>[pick("Your scalp itches.", "Your skin feels flakey.")]</span>")
			if(4,5,6)
				to_chat(H, "<span class='warning'>[pick("Random hairs start to fall out.", "You feel more bald with every second.")]</span>")
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

/datum/disease2/effect/monitoring
	name = "Monitoring"
	desc = "The virus produces nanites that track the host's vital organs and location, sending them to the station's sensor network."
	level = 1
	max_stage = 1
	cooldown = 600
	rogue_mutate_type = list(/datum/disease2/effect/toxins)
	effect_type = MICROBIOLOGY_NANITE
	pools = list(POOL_POSITIVE_VIRUS, POOL_NEUTRAL_VIRUS)

/datum/disease2/effect/monitoring/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	SSmobs.virus_monitored_mobs |= mob

/datum/disease2/effect/monitoring/deactivate(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	SSmobs.virus_monitored_mobs -= mob

/datum/disease2/effect/cough
	name = "Cough"
	desc = "The virus irritates the throat of the host, causing occasional coughing."
	level = 1
	max_stage = 3
	cooldown = 10
	pools = list(POOL_NEGATIVE_VIRUS)
	var/drop_item_chance = 30
	var/couthing_fit_chance = 5

/datum/disease2/effect/cough/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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
				if(I && I.w_class <= SIZE_TINY)
					H.drop_item()
			if(prob(couthing_fit_chance))
				to_chat(mob, "<span notice='userdanger'>[pick("You have a coughing fit!", "You can't stop coughing!")]</span>")
				H.Stun(2)
				addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/, emote), "cough"), 6)
				addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/, emote), "cough"), 12)
				addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/, emote), "cough"), 18)

/datum/disease2/effect/sneeze
	name = "Sneezing"
	desc = "The virus causes irritation of the nasal cavity, making the host sneeze occasionally."
	level = 1
	max_stage = 3
	cooldown = 20
	pools = list(POOL_NEUTRAL_VIRUS)

/datum/disease2/effect/sneeze/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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

/datum/disease2/effect/drool
	name = "Drooling"
	desc = "The virus causes inflammation inside the brain, causing constant drooling."
	level = 1
	max_stage = 3
	cooldown = 10
	pools = list(POOL_NEUTRAL_VIRUS)

/datum/disease2/effect/drool/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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
	pools = list(POOL_NEUTRAL_VIRUS)

/datum/disease2/effect/twitch/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
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
	pools = list(POOL_NEGATIVE_VIRUS)
	var/stun_chance = 5

/datum/disease2/effect/headache/activate_mob(mob/living/carbon/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.species && !H.species.flags[NO_PAIN])
			if(prob(20) || holder.stage	== 1)
				to_chat(H, "<span class = 'notice'>[pick("Your head hurts.", "Your head pounds.", "Your head hurts a bit.", "You have a headache.")]</span>")
			else if(prob(20) || (holder.stage >= 2 && holder.stage <= 5))
				to_chat(H, "<span class = 'warning'>[pick("Your head hurts a lot.", "Your head pounds incessantly.", "You have a throbbing headache.")]</span>")
				H.apply_effect(5,AGONY,0)
			else if(holder.stage == 6)
				to_chat(H, "<span class = 'userdanger'>[pick("Your head hurts!", "You feel a burning knife inside your brain!", "A wave of pain fills your head!")]</span>")
				if(prob(stun_chance))
					H.apply_effect(30,AGONY,0)
					H.Stun(2)
					H.emote("scream")
				else
					H.apply_effect(10,AGONY,0)

/datum/disease2/effect/suffocating
	name = "Hypoxemia"
	desc = "The virus producing nanites that prevent the host's blood from absorbing oxygen efficiently."
	level = 1
	max_stage = 3
	use_rate = 0.75
	effect_type = MICROBIOLOGY_NANITE

/datum/disease2/effect/suffocating/activate_mob(mob/living/carbon/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	A.losebreath += holder.stage

/datum/disease2/effect/hemocoagulation
	name = "Rapid Coagulation"
	desc = "The virus producing nanites that rapid coagulation when the host is wounded, dramatically reducing bleeding rate."
	level = 1
	max_stage = 2
	cooldown = 40
	use_rate = 0.10
	rogue_mutate_type = list(/datum/disease2/effect/suffocating)
	effect_type = MICROBIOLOGY_NANITE
	pools = list(POOL_POSITIVE_VIRUS)
	var/trait_added = FALSE
	COOLDOWN_DECLARE(blood_add_message)

/datum/disease2/effect/hemocoagulation/proc/heal_artery(mob/living/carbon/human/H)
	for(var/obj/item/organ/external/BP in H.bodyparts)
		if(BP.is_artery_cut())
			BP.status &= ~ORGAN_ARTERY_CUT

/datum/disease2/effect/hemocoagulation/activate_mob(mob/living/carbon/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	switch(holder.stage)
		if(1)
			if(COOLDOWN_FINISHED(src, blood_add_message))
				to_chat(A, "<span class='notice'>You feel like your blood vessels pulsate periodically.</span>")
				COOLDOWN_START(src, blood_add_message, 1 MINUTE)
			if(!ishuman(A))
				return
			var/mob/living/carbon/human/H = A
			H.blood_add(1)
		if(2)
			if(!trait_added)
				trait_added = TRUE
				if(ishuman(A))
					var/mob/living/carbon/human/H = A
					heal_artery(H)
				ADD_TRAIT(A, TRAIT_HEMOCOAGULATION, VIRUS_TRAIT)

/datum/disease2/effect/hemocoagulation/deactivate(atom/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	REMOVE_TRAIT(A, TRAIT_HEMOCOAGULATION, VIRUS_TRAIT)
	trait_added = FALSE
