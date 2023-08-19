/datum/religion_rites/standing/legacy
	// A multiplier applied to spells divine power.
	var/divine_power_mult = 1.0

	// Invocation probability of on_invocation_spell
	var/invocation_prob = 100
	// This type of spell will be inited for invoke_effect_spell
	var/invoke_spelltype
	// This type of spell will be inited for on_invocation_spell
	var/invocation_spelltype

	// This spell will be cast in invoke_effect, if succesful.
	var/obj/effect/proc_holder/spell/invoke_effect_spell
	// This spell will be cast in on_invocation with probability "invocation_prob"
	var/obj/effect/proc_holder/spell/on_invocation_spell

/datum/religion_rites/standing/legacy/New()
	if(invoke_spelltype)
		invoke_effect_spell = new invoke_spelltype
	if(invocation_spelltype)
		on_invocation_spell = new invocation_spelltype

/datum/religion_rites/standing/legacy/on_chosen(mob/living/user, obj/AOG)
	if(istype(AOG, /obj/structure/altar_of_gods))
		var/obj/structure/altar_of_gods/A = AOG

		if(invoke_effect_spell)
			A.religion.affect_divine_power_spell(invoke_effect_spell)
			invoke_effect_spell.divine_power *= divine_power_mult
		if(on_invocation_spell)
			A.religion.affect_divine_power_spell(on_invocation_spell)
			on_invocation_spell *= divine_power_mult

	return ..()

/datum/religion_rites/standing/legacy/proc/cast_spell(mob/living/user, obj/AOG, obj/effect/proc_holder/spell/S)
	S.choose_targets(user = user)

/datum/religion_rites/standing/legacy/invoke_effect(mob/living/user, obj/AOG)
	. = ..()
	if(!.)
		return FALSE

	if(invoke_effect_spell)
		cast_spell(user, AOG, invoke_effect_spell)
	return TRUE

/datum/religion_rites/standing/legacy/rite_step(mob/living/user, obj/AOG, current_stage)
	..()
	if(on_invocation_spell && prob(invocation_prob))
		cast_spell(user, AOG, on_invocation_spell)


/*
 * Charge
 * AoE charge
 */
/datum/religion_rites/standing/legacy/charge
	name = "Беспроводная Зарядка"
	desc = "Заряжает оборудование, батарейки и другие штуки вокруг тебя."
	ritual_length = (10 SECONDS)
	ritual_invocations = list("Силой бога нашего...",
						"...Мы взываем к вам, создающим поток энергии...",
						"...даровать нам часть того, что будет...")
	invoke_msg = "...Лейся! Пусть Энергия льется через все в этом мире!"
	favor_cost = 400

	needed_aspects = list(
		ASPECT_TECH = 1,
		ASPECT_RESCUE = 1,
	)

	invoke_spelltype = /obj/effect/proc_holder/spell/no_target/charge/religion
