/datum/religion_rites/legacy
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

/datum/religion_rites/legacy/New()
	if(invoke_spelltype)
		invoke_effect_spell = new invoke_spelltype
	if(invocation_spelltype)
		on_invocation_spell = new invocation_spelltype


/datum/religion_rites/legacy/required_checks(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!AOG)
		to_chat(user, "<span class='warning'>This rite requires an altar to be performed.</span>")
		return FALSE
	if(!AOG.religion)
		to_chat(user, "<span class='warning'>This rite requires a religion to be in place.</span>")
		return FALSE
	return TRUE

/datum/religion_rites/legacy/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(invoke_effect_spell)
		AOG.religion.affect_divine_power(invoke_effect_spell)
		invoke_effect_spell.divine_power *= divine_power_mult
	if(on_invocation_spell)
		AOG.religion.affect_divine_power(on_invocation_spell)
		on_invocation_spell *= divine_power_mult

	return ..()

/datum/religion_rites/legacy/proc/cast_spell(mob/living/user, obj/structure/altar_of_gods/AOG, obj/effect/proc_holder/spell/S)
	S.choose_targets(user = user)

/datum/religion_rites/legacy/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	. = ..()
	if(!.)
		return FALSE

	if(invoke_effect_spell)
		cast_spell(user, AOG, invoke_effect_spell)
	return TRUE

/datum/religion_rites/legacy/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(on_invocation_spell && prob(invocation_prob))
		cast_spell(user, AOG, on_invocation_spell)


/*
 * Charge
 * AoE charge
 */
/datum/religion_rites/legacy/charge
	name = "Electric Charge Pulse"
	desc = "Charge equipment, cells, and other things around you."
	ritual_length = (20 SECONDS)
	ritual_invocations = list("By the power of our gods...",
						"...We call upon you, who make the energy flow...",
						"...to give us a piece of what we will be...")
	invoke_msg = "...Flow! The energy through everything shall flow!"
	favor_cost = 400

	needed_aspects = list(
		ASPECT_TECH = 1,
		ASPECT_RESCUE = 1,
	)

	invoke_spelltype = /obj/effect/proc_holder/spell/targeted/charge/religion
