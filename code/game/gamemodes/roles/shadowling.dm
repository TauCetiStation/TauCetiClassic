/datum/role/shadowling
	name = SHADOW
	id = SHADOW

	required_pref = ROLE_SHADOWLING
	restricted_jobs = list("AI", "Cyborg", "Security Cadet", "Security Officer", "Warden", "Head of Security", "Captain", "Blueshield Officer")
	restricted_species_flags = list(IS_SYNTHETIC)

	antag_hud_type = ANTAG_HUD_SHADOW
	antag_hud_name = "hudshadowling"

	logo_state = "shadowling-logo"

	skillset_type = /datum/skillset/shadowling
	change_to_maximum_skills = TRUE

/datum/role/shadowling/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, "<b>Currently, you are disguised as an employee aboard [station_name()].</b>")
	to_chat(antag.current, "<b>In your limited state, you have three abilities: Enthrall, Hatch, and Hivemind Commune.</b>")
	to_chat(antag.current, "<b>Any other shadowlings are you allies. You must assist them as they shall assist you.</b>")
	to_chat(antag.current, "<b>If you are new to shadowling, or want to read about abilities, check the wiki page at https://wiki.taucetistation.org/Shadowling</b><br>")

/datum/role/shadowling/OnPostSetup(laterole)
	. = ..()
	var/mob/living/carbon/human/S = antag.current

	if(antag.assigned_role == "Clown")
		to_chat(S, "<span class='notice'>Your alien nature has allowed you to overcome your clownishness.</span>")
		REMOVE_TRAIT(S, TRAIT_CLUMSY, GENETIC_MUTATION_TRAIT)

	S.verbs += /mob/living/carbon/human/proc/shadowling_hatch
	S.AddSpell(new /obj/effect/proc_holder/spell/targeted/enthrall)
	S.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind)

/datum/role/thrall
	name = SHADOW_THRALL
	id = SHADOW_THRALL

	antag_hud_type = ANTAG_HUD_SHADOW
	antag_hud_name = "hudthrall"

	logo_state = "thrall-logo"

	skillset_type = /datum/skillset/thrall
	change_to_maximum_skills = TRUE

/datum/role/thrall/OnPreSetup(greeting, custom)
	. = ..()
	antag.current.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind)
	SEND_SIGNAL(antag.current, COMSIG_ADD_MOOD_EVENT, "thralled", /datum/mood_event/thrall)

/datum/role/thrall/RemoveFromRole(datum/mind/M, msg_admins)
	SEND_SIGNAL(antag.current, COMSIG_CLEAR_MOOD_EVENT, "thralled")
	for(var/obj/effect/proc_holder/spell/targeted/shadowling_hivemind/S in antag.current.spell_list)
		antag.current.RemoveSpell(S)
	..()
