/datum/disease2/effectholder
	var/name = "Holder"
	var/datum/disease2/effect/effect
	var/chance = 0 //Chance in percentage each tick
	var/multiplier = 1 //The chance the effects are WORSE
	var/stage = 1
	var/ticks = 0
	var/cooldownticks = 0

/datum/disease2/effectholder/proc/runeffect(atom/host, datum/disease2/disease/disease)
	if(cooldownticks > 0)
		cooldownticks -= 1 * disease.cooldown_mul
	if(prob(chance))
		if(ticks > stage * 10 && prob(50) && stage < effect.max_stage)
			stage++
		if(cooldownticks <= 0)
			cooldownticks = effect.cooldown
			if(ismob(host))
				effect.activate_mob(host, src, disease)
			if(istype(host, /obj/machinery/hydroponics))
				effect.activate_plant(host, src, disease)
		ticks += 1

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

/datum/disease2/effect/proc/activate_mob(mob/living/carbon/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
/datum/disease2/effect/proc/activate_plant(obj/machinery/hydroponics/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
/datum/disease2/effect/proc/deactivate(atom/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
/datum/disease2/effect/proc/copy(datum/disease2/effectholder/holder_old, datum/disease2/effectholder/holder_new, datum/disease2/effect/effect_old)

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
	desc = "Вирус быстро расщепляет инородные химические вещества, попавшие в кровь."
	level = 4

/datum/disease2/effect/heal/chem/heal(mob/living/carbon/human/M, datum/disease2/disease/disease, actual_power)
	for(var/datum/reagent/R in M.reagents.reagent_list) //Not just toxins!
		M.reagents.remove_reagent(R.id, actual_power)
		if(prob(2))
			to_chat(M, "<span class='notice'>Вы чувствуете небольшой жар, ваша кровь очищается.</span>") //kirolt
	return 1

/datum/disease2/effect/heal/coma
	name = "Regenerative Coma"
	desc = "После получения серьёзных повреждений, вирус заставляет носителя впасть в кому, а затем быстро восстанавливает его."
	level = 4
	passive_message = "<span class='notice'>От боли в ранах вас клонит в сон...</span>"
	var/active_coma = FALSE

/datum/disease2/effect/heal/coma/can_heal(mob/living/carbon/human/M, datum/disease2/disease/disease)
	if(M.status_flags & FAKEDEATH)
		return 1
	else if(M.stat == UNCONSCIOUS)
		return 0.5
	else if(M.getBruteLoss() + M.getFireLoss() >= 120 && !active_coma)
		to_chat(M, "<span class='warning'>Вы чувствуете, как впадаете в регенеративную кому...</span>")
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
	desc = "Вирус ускоряет метаболизм, повышая аппетит, позваляет носителю усваивать вещества в два раза быстрее."
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
	to_chat(M, "<span class='notice'>Вы чувствуете странное бульканье в желудке, как будто он работает гораздо быстрее, чем обычно.</span>")
	COOLDOWN_START(src, metabolicboost_message, 1 MINUTES)

/datum/disease2/effect/metabolism/activate_plant(obj/machinery/hydroponics/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	A.adjustSpeedmultiplier(holder.stage)

/datum/disease2/effect/flesh_death
	name = "Autophagocytosis Necrosis"
	desc = "Вирус быстро пожирает заражённые клетки, приводя к тяжелым и обширным повреждениям."
	level = 4
	max_stage = 3
	cooldown = 5
	chance_maxm = 20
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/flesh_death/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || (holder.stage >= 1 && holder.stage <= 2))
		to_chat(mob, "<span class='warning'>[pick("Вы чувствуете, как разваливаетесь на части.", "Ваша кожа осыпается, как пыль.")]</span>")
	else if(holder.stage == 3)
		to_chat(mob, "<span class='userdanger'>[pick("Вы чувствуете, как слабеют ваши мышцы.", "Ваша кожа отслаивается сама по себе.", "Вы как будто растворяетесь.")]</span>")
		mob.adjustBruteLoss(rand(6,10))

/datum/disease2/effect/stage_boost
	name = "Quick growth"
	desc = "Вирус мутирует и быстро развивается, достигая своего полного потенциала в мгновение ока."
	level = 4
	max_stage = 1
	cooldown = 1
	chance_minm = 100
	chance_maxm = 100
	pools = list(POOL_NEUTRAL_VIRUS)

/datum/disease2/effect/stage_boost/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(disease.stage < disease.effects.len)
		disease.stage = disease.effects.len
		to_chat(mob, "<span class='notice'>Вы чувствуете небольшой жар в области головы.</span>")

/datum/disease2/effect/gibbingtons
	name = "Gibbingtons Syndrome"
	desc = "Вирус производит сероводород в крови носителя, повреждая вены и артерии. В особых случаях, передозировка может привести к взрыву, который разнесёт носителя на кусочки."
	level = 4
	max_stage = 14
	cooldown = 30
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/gibbingtons/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	switch(holder.stage)
		if(1,2,3,4,5)
			to_chat(mob, "<span class='notice'>[pick("Вы почему-то злитесь.", "Ваша кожа шелушится.", "Ваша кожа горит.", "То тут, то там на вашей коже появляются маленькие ранки.")]</span>")
		if(6,7,8,9)
			if(prob(70))
				mob.reagents.add_reagent("potassium", 10)
				mob.reagents.add_reagent("water", 10)
			else
				to_chat(mob, "<span class='warning'>[pick("Вы чувствуете как протекают химические реакции в вашем теле.", "На вашей коже появляются пузырьки, которые немедленно взрываются.", "Кровь проявляется на вашем теле. Что-то разрывает вас изнутри!", "Раны на теле становятся все серьезнее.", "Вы чувствуете, как внутри вас что-то слабо взрывается.")]</span>")
		if(10,11,12,13)
			if(prob(10) && ishuman(mob))
				var/mob/living/carbon/human/H = mob
				var/bodypart = pick(list(BP_R_ARM , BP_L_ARM , BP_R_LEG , BP_L_LEG))
				var/obj/item/organ/external/BP = H.bodyparts_by_name[bodypart]
				if (BP && !(BP.is_stump))
					mob.emote("scream")
					BP.droplimb(no_explode = FALSE, clean = FALSE, disintegrate = DROPLIMB_BLUNT)
			else
				to_chat(mob, "<span class='userdanger'>[pick("Вас разрывает на части!", "БОЛЬНО!")]</span>")
				mob.adjustBruteLoss(rand(2,10))
		if(14)
			mob.emote("scream")
			mob.apply_effect(5, WEAKEN)
			mob.make_jittery(50)
			addtimer(CALLBACK(mob, TYPE_PROC_REF(/mob/, gib)), 50)

/datum/disease2/effect/vomit
	name = "Haematemesis's Syndrome"
	desc = "Вирус производит в пищеварительной системе носителя наниты, которые размножаются и питаются тканями организма, вызывая кровотечение с рвотой."
	level = 4
	max_stage = 3
	cooldown = 60
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/vomit/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	switch(holder.stage)
		if(1)
			to_chat(mob, "<span class='warning'>У вас болит грудь!</span>")
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
	desc = "Вирус меняет ДНК носителя, превращая его в обезьяну."
	level = 4
	max_stage = 8
	cooldown = 30
	pools = list(POOL_NEUTRAL_VIRUS, POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/monkey/activate_mob(mob/living/carbon/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(ishuman(A))
		var/mob/living/carbon/human/h = A
		switch(holder.stage)
			if(1,2,3)
				to_chat(A, "<span class='notice'>[pick("Вы хотите бананов.", "Вы ощущаете, что тупеете.", "Это банан?")]</span>")
			if(4,5,6,7)
				if(holder.stage == 7 && prob(20))
					h.say(pick("О, банан?", "У тебя есть бананы?", "У-У-У-и-и","Уо Уо Уои ээи ээи иии ииии", "Ииик! Ииик!"))
				else
					to_chat(A, "<span class='danger'>[pick("Вы очень хотите бананов.", "Вы замечаете как начинаете постепенно деградировать.", "Вы становитесь ниже.", "Шерсть проступает на вашей коже.")]</span>")
			if(8)
				h.monkeyize()

/datum/disease2/effect/suicide
	name = "Suicidal Syndrome"
	desc = "Вирус вызывает у носителя фальшивые суицидальные мысли, из-за чего последний с большой вероятностью может совершить самоубийство."
	level = 4
	max_stage = 8
	cooldown = 50
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/suicide/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if((holder.stage >= 1 && holder.stage <= 7) || prob(70))
		to_chat(mob, "<span class='notice'>[pick("А ведь во Вселенной есть те, кто топят маленьких таяран. Как такое возможно?", "Я бесполезен.", "Зачем я вообще существую?", "Может, всем будет лучше без меня?", "Если суицид не выход, то что?", "Может они были правы...", "Было бы лучше, если бы я не рождался.", "Хочется умереть.", "Мне так одиноко...", "Может я должен с всем этим покончить?", "Всё, что я делаю, я делаю не так.", "Я лишь несмешная шутка.", "И почему я лишь разочаровываю всех вокруг?")]</span>")
	else if(holder.stage == 8 && mob.stat == CONSCIOUS)
		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			if(prob(90))
				H.emote("gasp")
				H.visible_message("<span class='danger'>[H] пытается задержать своё дыхание, но не справляется.</span>")
				H.adjustOxyLoss(60)
			else
				H.visible_message("<span class='danger'>[H] задерживает своё дыхание. Похоже, что это попытка самоубийства.</span>")
				H.adjustOxyLoss(175 - H.getToxLoss() - H.getFireLoss() - H.getBruteLoss() - H.getOxyLoss())
			H.updatehealth()

/datum/disease2/effect/dna
	name = "Reverse Pattern Syndrome"
	desc = "Вирус приcоединяется к ДНК носителя, вызывая вредные мутации до его удаленния." //kirolt
	level = 4
	max_stage = 3
	cooldown = 10
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/dna/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>[pick("Вы чувствуете себя совсем по-другому.", "Вы чувствуете зуд по всему телу.", "Вы чувствуете лёгкое головокружение.")]</span>")
	else if(prob(20) || holder.stage == 2)
		to_chat(mob, "<span class='warning'>[pick("Вы чувствуете, что в вас что-то поменялось.", "У вас болит голова.")]</span>")
	else if(holder.stage == 3)
		scramble(0,mob,10)

/datum/disease2/effect/dna/deactivate(atom/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(!iscarbon(A))
		return
	var/mob/living/carbon/mob = A
	mob.remove_any_mutations()

/datum/disease2/effect/organs
	name = "Shutdown Syndrome"
	desc = "Вирус повреждает кости и мышечную ткань, медленно разрушая конечности носителя. Очень смертоносный."
	level = 4
	max_stage = 7
	cooldown = 20
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/organs/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	switch(holder.stage)
		if(1,2,3)
			to_chat(mob, "<span class='notice'>[pick("Вы чувствуете зуд по всему телу.", "Вы чувствуетет слабость.")]</span>")
		if(4,5,6)
			mob.adjustToxLoss(3)
			to_chat(mob, "<span class='warning'>[pick("У вас болит рука.", "Ваша нога болит.")]</span>")
		if(7)
			if(ishuman(mob) && prob(40))
				var/mob/living/carbon/human/H = mob
				var/bodypart = pick(list(BP_R_ARM , BP_L_ARM , BP_R_LEG , BP_L_LEG))
				var/obj/item/organ/external/BP = H.bodyparts_by_name[bodypart]
				if (!(BP.status & ORGAN_DEAD))
					BP.status |= ORGAN_DEAD
					to_chat(H, "<span class='warning'>Вы больше не чувствуете какую-то конечность...</span>") //add cases
					for (var/obj/item/organ/external/CHILD in BP.children)
						CHILD.status |= ORGAN_DEAD
				H.update_body()
			else
				to_chat(mob, "<span class='userdanger'>[pick("Ваши руки дрожат и сильно болят.", "Ваше тело как будто разваливается.")]</span>")
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
	desc = "Вирус вызывает проблемы с выработкой соединительной ткани в организме, что делает кости очень хрупкими."
	level = 4
	max_stage = 8
	cooldown = 60
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/bones/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	switch(holder.stage)
		if(1,2,3,4)
			to_chat(mob, "<span class='notice'>[pick("Вы замечаете, что стали менее ловким.", "Вы неуклюже двигаетесь.")]</span>")
		if(5,6,7)
			to_chat(mob, "<span class='notice'>[pick("Вы понимаете, что с вашими костями что-то не так.", "Ваши кости хрустят при движении.")]</span>")
		if(8)
			if(ishuman(mob))
				var/mob/living/carbon/human/H = mob
				var/obj/item/organ/external/BP = pick(H.bodyparts)
				BP.min_broken_damage = max(10, initial(BP.min_broken_damage) - 30)
				to_chat(mob, "<span class='notice'>Вы понимаете, что ваши конечности не такие крепкие, как прежде..</span>")

/datum/disease2/effect/bones/deactivate(atom/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		for (var/obj/item/organ/external/BP in H.bodyparts)
			BP.min_broken_damage = initial(BP.min_broken_damage)

////////////////////////STAGE 3/////////////////////////////////

/datum/disease2/effect/heal/starlight
	name = "Starlight Condensation"
	desc = "Вирус реагирует на звездный свет, вырабатывая регенерирующие химические вещества. Лучше всего работает против интоксикации."
	level = 3
	passive_message = "<span class='notice'>Вы скучаете по ощущению звездного света на своей коже.</span>"

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
		passive_message = "<span class='notice'>Ваша кожа покалывает. А свет звёзд исцеляет вас.</span>"
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
	desc = "Вирус способен восстанавливать плоть хозяина в условиях тусклого освещения, излечивая небольшие повреждения. Наиболее эффективен против механических повреждений."
	level = 3
	passive_message = "<span class='notice'>Вы чувствуете покалывание на коже, когда на неё падает свет.</span>"

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
		to_chat(M, "<span class='notice'>Темнота обволакивает ваши раны, залечивая их.</span>")

	M.heal_bodypart_damage(heal_amt, heal_amt * 0.5) //more effective on brute
	return 1

/datum/disease2/effect/heal/darkness/passive_message_condition(mob/living/carbon/human/M, datum/disease2/disease/disease)
	if(M.getBruteLoss() || M.getFireLoss())
		return TRUE
	return FALSE

/datum/disease2/effect/fire
	name = "Spontaneous Combustion"
	desc = "Вирус превращает жиры носителя в чрезвычайно огнеопасное соединение и повышает температуру тела, заставляя его самопроизвольно вспыхивать."
	level = 3
	max_stage = 3
	cooldown = 30
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/fire/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(50) || holder.stage == 1)
		to_chat(mob, "<span class='warning'>[pick("Вам жарко.", "Вы слышите потрескивание.", "Вы чувствуете запах дыма.")]</span>")
	else if(prob(50) || holder.stage == 2)
		mob.adjust_fire_stacks(1)
		mob.IgniteMob()
		to_chat(mob, "<span class='userdanger'>Ваша кожа вспыхивает пламенем!</span>")
		mob.emote("scream")
	else if(holder.stage == 3)
		mob.adjust_fire_stacks(3)
		mob.IgniteMob()
		to_chat(mob, "<span class='userdanger'>Ваша кожа всполыхает адским пламенем! </span>")
		mob.emote("scream")

/datum/disease2/effect/flesh_eating
	name = "Necrotizing Fasciitis"
	desc = "Вирус агрессивно атакует клетки организма, подвергая некрозу ткани и органы."
	level = 3
	max_stage = 4
	cooldown = 30
	chance_maxm = 30
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/flesh_eating/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(50) || (holder.stage >= 1 && holder.stage <= 3))
		to_chat(mob, "<span class='warning'>[pick("Всё ваше тело пронизывает боль.", "Капли крови внезапно появляются на коже.")]</span>")
	else if(holder.stage == 4)
		to_chat(mob, "<span class='userdanger'>[pick("Вы скорчиваетесь, когда невыносимая боль охватывает ваше тело.", "Такое ощущение, что ваше тело съедает само себя изнутри.", "БОЛЬНО.")]</span>")
		mob.adjustBruteLoss(rand(15, 25))

/datum/disease2/effect/mind_restoration
	name = "Mind Restoration"
	desc = "Вирус укрепляет связи между нейронами, сокращая продолжительность любых воздействий на разум."
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
	desc = "Вирус стимулирует регенерацию тканей глаз и ушей, позваляет носителю восстанавливать их при повреждении."
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
	desc = "Вирус мутирует и становится более активным, сокращая время между эффектами."
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
		to_chat(mob, "<span class='notice'>Вы чувствуете, что ваш мозг работает эффективнее.</span>")

/datum/disease2/effect/chance_boost
	name = "Structure improvement"
	desc = "Вирус мутирует и изменяет свою структуру, в результате чего эффекты проявляются с большей вероятностью."
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
		to_chat(mob, "<span class='notice'>Вы чувствуете себя умнее.</span>")

/datum/disease2/effect/chance_boost/copy(datum/disease2/effectholder/holder_old, datum/disease2/effectholder/holder_new, datum/disease2/effect/effect_old)
	var/datum/disease2/effect/chance_boost/Z = effect_old
	activated = Z.activated

/datum/disease2/effect/radian
	name = "Radian's Syndrome"
	desc = "Вирус подвергает мутации клетки кожи носителя, увеличивая воздействие радиации."
	level = 3
	max_stage = 3
	cooldown = 10
	pools = list(POOL_NEUTRAL_VIRUS, POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/radian/activate_mob(mob/living/carbon/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	switch(holder.stage)
		if(1)
			to_chat(A, "<span class='notice'>[pick("Вы чувствуете тепло.", "Вы чувствуете слабость.")]</span>")
		if(2)
			to_chat(A, "<span class='warning'>[pick("Ваша кожа шелушится.", "У вас жар.")]</span>")
			irradiate_one_mob(A, 5)
		if(3)
			irradiate_one_mob(A, 20)

/datum/disease2/effect/radian/activate_plant(obj/machinery/hydroponics/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	A.adjustMutationmod(holder.stage)

/datum/disease2/effect/killertoxins
	name = "Toxification Syndrome"
	desc = "Вирус вызывает тошноту и раздражает желудок, вызывая интоксикацию и периодическую рвоту."
	level = 3
	max_stage = 3
	cooldown = 10
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/killertoxins/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='warning'>[pick("Вас тошнит.", "Вам кажется, что вас сейчас вырвет!")]</span>")
	else if(prob(20) || holder.stage == 2)
		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			H.invoke_vomit_async()
	else if(holder.stage == 3)
		to_chat(mob, "<span class='userdanger'>[pick("У вас болит живот.", "Вы ощущаете резкую боль в животе.")]</span>")
		mob.reagents.add_reagent(pick("plasticide", "toxin", "amatoxin", "phoron", "lexorin", "carpotoxin", "mindbreaker", "plantbgone", "fluorine"), round(rand(1, 3), 1)) // some random toxin

/datum/disease2/effect/toxins
	name = "Hyperacidity"
	desc = "Вирус повреждает желудок хозяина, заставляя его вырабатывать большое количество кислот, что вызывает интоксикацию."
	level = 3
	max_stage = 3
	cooldown = 20
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/toxins/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	switch(holder.stage)
		if(1)
			to_chat(mob, "<span class='notice'>[pick("У вас болит живот.", "Вы испытываете тошноту.")]</span>")
		if(2)
			to_chat(mob, "<span class='warning'>[pick("У вас болит живот.", "Вы чувствуете противную боль в горле.")]</span>")
			mob.adjustToxLoss(5)
		if(3)
			to_chat(mob, "<span class='warning'>[pick("У вас очень сильно болит живот.", "Ваша кожа кажется более бледной.", "Вы чувствуете себя растерянным.", "Ваше дыхание горячее и нерегулярное.")]</span>")
			mob.adjustToxLoss(10)

/datum/disease2/effect/nerve_support
	name = "Nerve Support"
	desc = "Вирус вводит в организм хозяина наниты, которые действуют как вторичная нервная система, защищая от паралича."
	level = 3
	max_stage = 3
	cooldown = 7
	pools = list(POOL_POSITIVE_VIRUS)
	var/trait_added = FALSE
	COOLDOWN_DECLARE(senses_message)

/datum/disease2/effect/nerve_support/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	switch(holder.stage)
		if(1)
			if(COOLDOWN_FINISHED(src, senses_message))
				to_chat(mob, "<span class='notice'>Вы чувствуете, как обостряются ваши тактильные ощущения.</span>")
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
	desc = "Вирус странным образом подвергает мутации мозг, наделяя носителя способностью общаться с другими людьми посредством своего разума."
	level = 3
	max_stage = 3
	cooldown = 60
	pools = list(POOL_POSITIVE_VIRUS)

/datum/disease2/effect/telepathic/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	switch(holder.stage)
		if(1)
			to_chat(mob, "<span class='notice'>[pick("Вам что-то послышалось.", "В голове появляются посторонние мысли.", "Мир кажется странным.")]</span>")
		if(2)
			to_chat(mob, "<span class='warning'>[pick("Вы паникуете, слыша столько случайных слов.", "Вы не можете понять, что происходит с вашей головой.")]</span>")
		if(3)
			mob.dna.check_integrity()
			mob.dna.SetSEState(REMOTETALKBLOCK,1)
			domutcheck(mob, null)

/datum/disease2/effect/mind
	name = "Lazy Mind Syndrome"
	desc = "Вирус медленно повреждает мозг, делая носителя очень тупым."
	level = 3
	max_stage = 3
	cooldown = 30
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/mind/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>[pick("Мир кажется странным.", "Вы на секунду забыли, как вас зовут.", "Вы вдруг забыли, куда шли.")]</span>")
	else if(prob(20) || holder.stage == 2)
		to_chat(mob, "<span class='warning'>[pick("Вы чувствуете себя тупым.", "Вы на что-то уставились и смотрите.", "У вас текут слюни.")]</span>")
		mob.adjustBrainLoss(5)
	else if(holder.stage == 3)
		to_chat(mob, "<span class='userdanger'>[pick("Вы на мгновение забыли, как дышать.", "Кто я?", "Вы очень глупы.")]</span>") //Ayanami Rei
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
	desc = "Вирус производит наниты, которые устраняют повреждения в механических конечностях хозяина."
	level = 3
	max_stage = 7
	cooldown = 10
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
	desc = "Вирус значительно ускоряет выработку тестостерона, вызывая быстрый рост бороды."
	level = 2
	max_stage = 3
	cooldown = 30
	pools = list(POOL_NEUTRAL_VIRUS)

/datum/disease2/effect/beard/activate_mob(mob/living/carbon/A, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		switch(holder.stage)
			if(1)
				to_chat(H, "<span class='warning'>У вас чешется подбородок.</span>")
				if(H.f_style == "Shaved" && prob(30))
					H.f_style = "Jensen Beard"
					H.update_hair()
			if(2)
				if(!(H.f_style == "Dwarf Beard") && !(H.f_style == "Very Long Beard") && !(H.f_style == "Full Beard"))
					to_chat(H, "<span class='warning'>Вы чувствуете себя крутым.</span>")
					H.f_style = "Full Beard"
					H.update_hair()
			if(3)
				if(!(H.f_style == "Dwarf Beard") && !(H.f_style == "Very Long Beard"))
					to_chat(H, "<span class='warning'>Вы чувствуете себя настоящим Мужиком!</span>")
					H.f_style = pick("Dwarf Beard", "Very Long Beard")
					H.update_hair()

/datum/disease2/effect/hallucinations
	name = "Hallucinational Syndrome"
	desc = "Вирус стимулирует мозг, вызывая периодические галлюцинации."
	level = 2
	max_stage = 3
	cooldown = 30
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/hallucinations/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>[pick("Что-то появляется в вашем периферийном зрении, а затем исчезает.", "Вы слышите слабый шепот, не имеющий источника.", "У вас болит голова.")]</span>")
	else if(prob(20) || holder.stage == 2)
		to_chat(mob, "<span class='danger'>[pick("Что-то преследует вас.", "За вами следят.", "Вы слышите шепот в своем ухе.", "Вы слышите гулкие шаги, раздающиеся из ниоткуда.")]</span>")
		mob.hallucination = max(mob.hallucination, 50)
	else if(holder.stage == 3)
		to_chat(mob, "<span class='userdanger'>[pick("Ох, моя голова...", "У вас раскалывается голова.", "Они повсюду! Бегите!", "Что-то скрывается в тенях...")]</span>")
		mob.hallucination = max(mob.hallucination, 100)

/datum/disease2/effect/deaf
	name = "Hard of Hearing Syndrome"
	desc = "Вирус вызывает воспаление барабанных перепонок, что приводит к периодической глухоте."
	level = 2
	max_stage = 3
	cooldown = 60
	pools = list(POOL_NEGATIVE_VIRUS)
	var/pain_chance = 5

/datum/disease2/effect/deaf/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>[pick("Вы слышите звон в ушах.", "Ваши уши закладывает.")]</span>")
	else if(prob(20) || holder.stage == 2)
		to_chat(mob, "<span class='warning'><i>Все стало таким тихим...</i></span>")
		mob.ear_deaf = max(mob.ear_deaf, 2)
	else if(holder.stage == 3)
		if(prob(pain_chance))
			to_chat(mob, "<span class='userdanger'>Ваши уши заложило, они болят и кровоточат!</span>")
			mob.ear_deaf = max(mob.ear_deaf, 10)
			mob.emote("scream")
		else
			to_chat(mob, "<span class='userdanger'>Ваши уши заложило и появляется громкий звон!</span>")
			mob.ear_deaf = max(mob.ear_deaf, 5)

/datum/disease2/effect/giggle
	name = "Uncontrolled Laughter Effect"
	desc = "Вирус вызывает неврологическое расстройство, заставляя носителя неудержимо смеяться."
	level = 2
	max_stage = 4
	cooldown = 10
	pools = list(POOL_NEGATIVE_VIRUS)
	var/laughing_fit_chance = 5

/datum/disease2/effect/giggle/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>[pick("Вы улыбаетесь без причины.", "Вы чувствуете себя очень счастливым.")]</span>")
	else if(prob(20) || holder.stage == 2)
		if(prob(50))
			to_chat(mob, "<span class='notice'>В мире все так хорошо, что вы не можете перестать улыбаться.</span>")
		else
			mob.emote(pick("smile","grin"))

	else if(prob(20) || holder.stage == 3)
		if(prob(30))
			to_chat(mob, "<span class='warning'>[pick("Вы неудержимо смеетесь.", "Вы чуть не плачете от смеха.", "У вас болят легкие от смеха.")]</span>")
		else
			mob.emote(pick("laugh","giggle"))
	else if(holder.stage == 4)
		if(prob(30))
			to_chat(mob, "<span class='userdanger'>[pick("АХАХАХАХА!","Я ДОЛЖЕН СМЕЯТЬСЯ", "ПОМОГИТЕ МНЕ, Я НЕ МОГУ ОСТАНОВИТЬСЯ!")]</span>")
		else if(prob(laughing_fit_chance))
			to_chat(mob, "<span notice='userdanger'>[pick("У вас приступ смеха!", "Вы не можете перестать смеяться!")]</span>")
			mob.apply_effect(2, WEAKEN)
			mob.make_jittery(50)
			addtimer(CALLBACK(mob, TYPE_PROC_REF(/mob/, emote), pick("laugh","giggle")), 6)
			addtimer(CALLBACK(mob, TYPE_PROC_REF(/mob/, emote), pick("laugh","giggle")), 12)
			addtimer(CALLBACK(mob, TYPE_PROC_REF(/mob/, emote), pick("laugh","giggle")), 18)
		else
			mob.say(pick("хаха","ха ха ха","ха","ХА","хех","аха","хехе","хехехе","хех","хе хе хе","мухахаха","мваахаха","хихи","тцхихи","хахаха","ахахахах","бваахах","гхахах"))

/datum/disease2/effect/confusion
	name = "Topographical Cretinism"
	desc = "Вирус повреждает мозг, вызывая сильную дезориентацию."
	level = 2
	max_stage = 3
	cooldown = 60
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/confusion/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>[pick("Вы вдруг забыли, где находится право.", "Вы вдруг забыли, где находится лево.")]</span>")
	else if(prob(20) || holder.stage == 2)
		to_chat(mob, "<span class='notice'>Вам вдруг стало трудно различать право и лево.</span>")
		mob.MakeConfused(2)
	else if(holder.stage == 3)
		to_chat(mob, "<span class='warning'><i>Где я?</i></span>")
		mob.MakeConfused(10)

/datum/disease2/effect/purging_advanced
	name = "Selective Purification"
	desc = "Вирус очищает кровь хозяина от токсинов и опасных химических веществ, игнорируя при этом полезные химические вещества."
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
	desc = "Вирус изменяет метаболизм хозяина, делая его гораздо более эффективным, позволяет синтезировать питательные вещества из несъедобных источников."
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
	desc = "Вирус производит стимуляторы в крови, давая носителю много энергии и сил."
	level = 2
	max_stage = 3
	cooldown = 10
	pools = list(POOL_POSITIVE_VIRUS, POOL_NEUTRAL_VIRUS)
	var/muscles_ache_chance = 5

/datum/disease2/effect/stimulant/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class = 'notice'>[pick("Вы хотите попрыгать вокруг.", "Вы хотите бегать.")]</span>")
	else if(prob(20) || holder.stage == 2)
		if (mob.reagents.get_reagent_amount("stimulants") < 1)
			to_chat(mob, "<span class='notice'>Вы чувствуете небольшой прилив сил.</span>")
			mob.reagents.add_reagent("stimulants", 1)
	else if(holder.stage == 3)
		if (mob.reagents.get_reagent_amount("stimulants") < 10)
			to_chat(mob, "<span class='notice'>Вы ощущаете прилив энергии внутри себя!</span>")
			mob.reagents.add_reagent("stimulants", 4)
		else if(prob(muscles_ache_chance))
			to_chat(mob, "<span class='userdanger'>Ваши мышцы болят.</span>")
			mob.apply_effect(35,AGONY,0)
		if (prob(30))
			mob.make_jittery(150)

/datum/disease2/effect/mute
	name = "Absorption"
	desc = "Вирус производит на коже хозяина наниты, которые поглощают звуковые волны."
	level = 2
	max_stage = 2
	cooldown = 10
	pools = list(POOL_NEUTRAL_VIRUS, POOL_NEGATIVE_VIRUS)
	var/trait_added = FALSE
	COOLDOWN_DECLARE(mute_message)

/datum/disease2/effect/mute/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	switch(holder.stage)
		if(1)
			if(!COOLDOWN_FINISHED(src, mute_message))
				return
			to_chat(mob, "<span class='warning'>Вы начинаете хуже слышать собственную речь.</span>")
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
	desc = "Вирус повреждает мозг носителя, вызывая неконтролируемую громкую речь."
	level = 1
	max_stage = 4
	cooldown = 10
	pools = list(POOL_NEUTRAL_VIRUS)

/datum/disease2/effect/scream/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>[pick("Вы хотите много говорить.", "Вы очень хотите громко разговаривать.")]</span>")
	else if(prob(20) || holder.stage == 2)
		if(prob(50))
			to_chat(mob, "<span class='warning'>Из вашего рта вырываются беспорядочные звуки.</span>")
		else
			mob.say(pick("Ай","Аууу","Ах","Ииии"))

	else if(prob(20) || holder.stage == 3)
		if(prob(50))
			to_chat(mob, "<span class='warning'>[pick("Ваш голос становиться слишком громким.", "Вы не можете контролировать свой рот.")]</span>")
		else
			mob.say(pick("ААААА","АААРРРГ!","ААААВУУ","ААААх","Айяяяя","Ляяяяяяяяяяяяяяяя!"))
	else if(holder.stage == 4)
		if(prob(30))
			to_chat(mob, "<span class='userdanger'>[pick("ААААА!","ДОЛЖЕН ОРАТЬ", "КАК ЭТО ОСТАНОВИТЬ?!.")]</span>")
		else
			mob.emote("scream")

/datum/disease2/effect/drowsness
	name = "Narcolepsy"
	desc = "Вирус влияет на гормональный баланс, вызывая у носителя нарколепсию."
	level = 1
	max_stage = 4
	cooldown = 60
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/drowsness/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>Вы чувствуете себя уставшим.</span>")
	else if(prob(20) || holder.stage == 2)
		to_chat(mob, "<span class='warning'>Вы сильно устали.</span>")
		mob.drowsyness = max(mob.drowsyness, 2)
	else if(prob(20) || holder.stage == 3)
		mob.drowsyness = max(mob.drowsyness, 5)
		to_chat(mob, "<span class='warning'>[pick("Вы пытаетесь не заснуть.", "Вы на мгновение задремали.")]</span>")
	else if(holder.stage == 4)
		mob.drowsyness = max(mob.drowsyness, 10)
		to_chat(mob, "<span class='userdanger'>[pick("Вы слишком уст...","Вам ОЧЕНЬ хочется спать.","Вам трудно держать глаза открытыми.","Вы валитесь с ног.")]</span>")

		if(prob(10))
			if(prob(50))
				mob.emote("collapse")
			else
				mob.SetSleeping(max(mob.AmountSleeping(), 5 SECONDS))

/datum/disease2/effect/blind
	name = "Hyphema"
	desc = "Вирус вызывает воспаление сетчатки, что приводит к повреждению глаза и в конечном итоге к слепоте."
	level = 1
	max_stage = 4
	cooldown = 10
	pools = list(POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/blind/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class='notice'>Ваши глаза чешутся.</span>")
	else if(prob(20) || holder.stage == 2)
		to_chat(mob, "<span class='warning'><i>Ваши глаза как будто горят!</i></span>")
		mob.blurEyes(5)
	else if(holder.stage == 3)
		mob.blurEyes(10)
		mob.eye_blind = max(mob.eye_blind, 2)
		to_chat(mob, "<span class='warning'>В ваших глазах как будто песок!</span>")
	else if(holder.stage == 4)
		mob.blurEyes(20)
		mob.eye_blind = max(mob.eye_blind, 2)
		to_chat(mob, "<span class='userdanger'>[pick("Ваши глаза покраснели и горят!", "У вас болят глаза!")]</span>")

		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			var/obj/item/organ/internal/eyes/E = H.organs_by_name[O_EYES]
			if(E)
				E.damage += 1

/datum/disease2/effect/hungry
	name = "Appetiser Effect"
	desc = "Вирус изменяет метаболизм носителя, делая его практически неспособным к усваиванию пищи."
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
		to_chat(mob, "<span class='warning'><i>[pick("Хочется кушать...", "Вы готовы убить кого-то ради кусочка еды...", "Вас охватывают голодные спазмы...")]</i></span>")

		if(mob.nutrition < 10 && prob(5))
			to_chat(mob, "<span class='userdanger'>Вы ослабеваете от голода.</span>")
			mob.apply_effect(35,AGONY,0)

/datum/disease2/effect/fridge
	name = "Refridgerator Syndrome"
	desc = "Вирус подавляет терморегуляцию организма, охлаждая его."
	level = 1
	max_stage = 3
	cooldown = 20
	pools = list(POOL_NEUTRAL_VIRUS, POOL_NEGATIVE_VIRUS)

/datum/disease2/effect/fridge/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class = 'notice'>[pick("Вы чувствуете холодок.", "Вы дрожите.")]</span>")
	else if(prob(20) || holder.stage == 2)
		if(prob(50))
			to_chat(mob, "<span class = 'notice'>[pick("Вам холодно.", "Ваша челюсть дрожит.", "Вы передвигаетесь рывками.")]</span>")
		else
			mob.emote("shiver")
		mob.bodytemperature = min(mob.bodytemperature, 260)
	else if(holder.stage == 3)
		if(prob(50))
			to_chat(mob, "<span class = 'warning'>[pick("Вы ощущаете, что кровь в ваших жилах - холодная.", "Кровь как будто застыла в ваших жилах.", "Вы не можете согреться.", "Вы сильно дрожите.")]</span>")
		else
			mob.emote("shiver")
		mob.bodytemperature = min(mob.bodytemperature, 100)

/datum/disease2/effect/hair
	name = "Hair Loss"
	desc = "Вирус вызывает быстрое выпадение волос на голове и теле."
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
				to_chat(H, "<span class='warning'>[pick("Ваш скальп чешется.", "Ваша кожа шелушится.")]</span>")
			if(4,5,6)
				to_chat(H, "<span class='warning'>[pick("Начинают выпадать случайные волоски.", "Вы чувствуете, как лысеете с каждой секундой.")]</span>")
			if(7)
				if(!is_face_bald(H))
					to_chat(H, "<span class='danger'>Ваши волосы начинают выпадать клочьями...</span>")
					spawn(50)
						shed(H, TRUE)
			if(8)
				if(!is_face_bald(H) || !is_bald(H))
					to_chat(H, "<span class='danger'>Ваши волосы начинают выпадать клочьями...</span>")
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
	desc = "Вирус производит наниты, которые отслеживают состояние органов и местоположение носителя, отправляя информацию в сенсорную сеть станции."
	level = 1
	max_stage = 1
	cooldown = 600
	pools = list(POOL_POSITIVE_VIRUS, POOL_NEUTRAL_VIRUS)

/datum/disease2/effect/monitoring/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	SSmobs.virus_monitored_mobs |= mob

/datum/disease2/effect/monitoring/deactivate(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	SSmobs.virus_monitored_mobs -= mob

/datum/disease2/effect/cough
	name = "Cough"
	desc = "Вирус раздражает горло носителя, вызывая периодический кашель."
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
		to_chat(mob, "<span class = 'notice'>[pick("Вы проглатываете избыток мокроты.", "Вы слегка покашливаете.")]</span>")
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
				to_chat(mob, "<span notice='userdanger'>[pick("У вас приступ кашля!", "Вы не можете перестать кашлять!")]</span>")
				H.Stun(2)
				addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/, emote), "cough"), 6)
				addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/, emote), "cough"), 12)
				addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/, emote), "cough"), 18)

/datum/disease2/effect/sneeze
	name = "Sneezing"
	desc = "Вирус вызывает раздражение носовой полости, заставляя носителя периодически чихать."
	level = 1
	max_stage = 3
	cooldown = 20
	pools = list(POOL_NEUTRAL_VIRUS)

/datum/disease2/effect/sneeze/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class = 'notice'>[pick("Вы шмыгаете носом.", "Вам хочется чихнуть.")]</span>")
	else if(prob(20) || holder.stage == 2)
		if(prob(50))
			to_chat(mob, "<span class = 'notice'>[pick("Желание чихнуть невыносимо.")]</span>")
		else if(prob(50))
			mob.emote("sniff")
		else
			mob.emote("sneeze")
			disease.spread(mob, 1)
	else if(holder.stage == 3)
		if(prob(30))
			to_chat(mob, "<span class = 'warning'>[pick("Вы не можете остановить желание чихнуть.")]</span>")
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
	desc = "Вирус вызывает воспаление внутри мозга, что приводит к птиализму."
	level = 1
	max_stage = 3
	cooldown = 10
	pools = list(POOL_NEUTRAL_VIRUS)

/datum/disease2/effect/drool/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class = 'notice'>[pick("Вы сглатываете избыток слюны.", "Кажется, вы забыли, как глотать слюну.")]</span>")
	else if(prob(20) || holder.stage == 2)
		if(prob(50))
			to_chat(mob, "<span class = 'notice'>[pick("Вам трудно удерживать слюну во рту.", "Вы выплевываете избыток слюны.")]</span>")
		else
			mob.emote("drool")
			disease.spread(mob, 1)
	else if(holder.stage == 3)
		if(prob(30))
			to_chat(mob, "<span class = 'warning'>[pick("Вы пускаете слюни, забыв закрыть рот.", "Вы не можете остановить слюни.")]</span>")
		else
			mob.emote("drool")
			disease.spread(mob, 1)

/datum/disease2/effect/twitch
	name = "Twitcher"
	desc = "Вирус провоцирует беспорядочные мышечные спазмы."
	level = 1
	max_stage = 3
	cooldown = 5
	pools = list(POOL_NEUTRAL_VIRUS)

/datum/disease2/effect/twitch/activate_mob(mob/living/carbon/mob, datum/disease2/effectholder/holder, datum/disease2/disease/disease)
	if(prob(20) || holder.stage	== 1)
		to_chat(mob, "<span class = 'notice'>[pick("Ваш большой палец подергивается.", "Ваши уши подергиваются.", "Вы подёргиваетесь.")]</span>")
	else if(prob(20) || holder.stage == 2)
		if(prob(50))
			to_chat(mob, "<span class = 'notice'>[pick("Все ваше тело дергается.", "Ваши руки судорожно сжимаются.", "У вас сводит ноги судорогой.")]</span>")
		else
			mob.emote("twitch")
	else if(holder.stage == 3)
		if(prob(30))
			to_chat(mob, "<span class = 'warning'>[pick("Дерганье невыносимо.", "Вы не можете перестать дергаться.", "Вы дёргаетесь, как будто вас ударило током.")]</span>")
		else
			mob.emote("twitch")

/datum/disease2/effect/headache
	name = "Headache"
	desc = "Вирус вызывает воспаление в головном мозге, что приводит к постоянным головным болям."
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
				to_chat(H, "<span class = 'notice'>[pick("У вас побаливает голова.", "У вас болит голова.", "Голова немного болит.", "У вас началась головная боль.")]</span>")
			else if(prob(20) || (holder.stage >= 2 && holder.stage <= 5))
				to_chat(H, "<span class = 'warning'>[pick("У вас раскалывается голова.", "Ваша голова непрерывно болит.", "У вас пульсирующая головная боль.")]</span>")
				H.apply_effect(5,AGONY,0)
			else if(holder.stage == 6)
				to_chat(H, "<span class = 'userdanger'>[pick("Голова как будто налита свинцом!", "Вы чувствуете, будто раскаленный нож вошёл в ваш мозг!", "Волна боли заполняет вашу голову!")]</span>")
				if(prob(stun_chance))
					H.apply_effect(30,AGONY,0)
					H.Stun(2)
					H.emote("scream")
				else
					H.apply_effect(10,AGONY,0)

/datum/disease2/effect/hemocoagulation
	name = "Rapid Coagulation"
	desc = "Вирус производит наниты, ускоряющие свертывание крови носителя, значительно снижая тяжесть кровотечений."
	level = 1
	max_stage = 2
	cooldown = 40
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
				to_chat(A, "<span class='notice'>Вы чувствуете, что ваши кровеносные сосуды периодически пульсируют.</span>")
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
