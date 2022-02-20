// MEDICAL SIDE EFFECT BASE
// ========================
/datum/medical_effect
	var/name = "None"
	var/strength = 0
	var/start = 0
	var/list/triggers
	var/list/cures
	var/cure_message

/datum/medical_effect/proc/manifest(mob/living/carbon/human/H)
	for(var/R in cures)
		if(H.reagents.has_reagent(R))
			return 0
	for(var/R in triggers)
		if(H.reagents.get_reagent_amount(R) >= triggers[R])
			return 1
	return 0

/datum/medical_effect/proc/on_life(mob/living/carbon/human/H, strength)
	return

/datum/medical_effect/proc/cure(mob/living/carbon/human/H)
	for(var/R in cures)
		if(H.reagents.has_reagent(R))
			if (cure_message)
				to_chat(H, "<span class='notice'>[cure_message]</span>")
			return 1
	return 0


// MOB HELPERS
// ===========
/mob/living/carbon/human/var/list/datum/medical_effect/side_effects = list()
/mob/proc/add_side_effect(name, strength = 0)
/mob/living/carbon/human/add_side_effect(name, strength = 0)
	for(var/datum/medical_effect/M in side_effects)
		if(M.name == name)
			M.strength = max(M.strength, 10)
			M.start = life_tick
			return


	var/T = global.side_effects[name]
	if (!T)
		return

	var/datum/medical_effect/M = new T
	if(M.name == name)
		M.strength = strength
		M.start = life_tick
		side_effects += M

/mob/living/carbon/human/proc/handle_medical_side_effects()
	//Going to handle those things only every few ticks.
	if(life_tick % 15 != 0)
		return 0

	var/list/L = subtypesof(/datum/medical_effect)
	for(var/T in L)
		var/datum/medical_effect/M = new T
		if (M.manifest(src))
			add_side_effect(M.name)

	// One full cycle(in terms of strength) every 10 minutes
	for (var/datum/medical_effect/M in side_effects)
		if (!M) continue
		var/strength_percent = sin((life_tick - M.start) / 2)

		// Only do anything if the effect is currently strong enough
		if(strength_percent >= 0.4)
			if (M.cure(src) || M.strength > 50)
				side_effects -= M
				M = null
			else
				if(life_tick % 45 == 0)
					M.on_life(src, strength_percent*M.strength)
				// Effect slowly growing stronger
				M.strength+=0.08

// HEADACHE
// ========
/datum/medical_effect/headache
	name = "Headache"
	triggers = list("cryoxadone" = 10, "bicaridine" = 15, "tricordrazine" = 15)
	cures = list("alkysine", "tramadol", "paracetamol", "oxycodone")
	cure_message = "Ваша головная боль постепенно проходит..."

/datum/medical_effect/headache/on_life(mob/living/carbon/human/H, strength)
	switch(strength)
		if(1 to 10)
			H.custom_pain("Вы чувствуете слабую боль в голове.",0)
		if(11 to 30)
			H.custom_pain("Вы чувствуете сильную боль в голове!",1)
		if(31 to INFINITY)
			H.custom_pain("Вы чувствуете сильнейшую боль в голове!",1)

// BAD STOMACH
// ===========
/datum/medical_effect/bad_stomach
	name = "Bad Stomach"
	triggers = list("kelotane" = 30, "dermaline" = 15)
	cures = list("anti_toxin")
	cure_message = "Ваш живот постепенно выздоравливает..."

/datum/medical_effect/bad_stomach/on_life(mob/living/carbon/human/H, strength)
	switch(strength)
		if(1 to 10)
			H.custom_pain("Вы чувствуете странную пустоту в области живота.",0)
		if(11 to 30)
			H.custom_pain("Вы чувтсвуете боль в животе.",0)
		if(31 to INFINITY)
			H.custom_pain("Вас сильно тошнит.",1)

// CRAMPS
// ======
/datum/medical_effect/cramps
	name = "Cramps"
	triggers = list("anti_toxin" = 30, "tramadol" = 15)
	cures = list("inaprovaline")
	cure_message = "Судорога постепенно проходит..."

/datum/medical_effect/cramps/on_life(mob/living/carbon/human/H, strength)
	switch(strength)
		if(1 to 10)
			H.custom_pain("Вы чувствуете мышечную боль по всему вашему телу.",0)
		if(11 to 30)
			H.custom_pain("Мышцы по всему вашему телу болезненно охватываются судорогой.",0)
		if(31 to INFINITY)
			H.emote("me",1,"вздрагивает от внезапной судороги по всему телу.")
			H.custom_pain("Всё ваше тело болит.",1)

// ITCH
// ====
/datum/medical_effect/itch
	name = "Itch"
	triggers = list("space_drugs" = 10)
	cures = list("inaprovaline")
	cure_message = "Чесотка прекращается..."

/datum/medical_effect/itch/on_life(mob/living/carbon/human/H, strength)
	switch(strength)
		if(1 to 10)
			H.custom_pain("Вы чувствуете лёгкий зуд.",0)
		if(11 to 30)
			H.custom_pain("Вы очень сильно хотите расчесать зудящее место.",0)
		if(31 to INFINITY)
			H.emote("me",1,"немного трясётся.")
			H.custom_pain("Из-за этой чесотки тяжело сконцентрироваться.",1)
