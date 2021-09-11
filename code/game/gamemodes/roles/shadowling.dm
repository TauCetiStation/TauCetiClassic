/datum/role/shadowling
	name = SHADOW
	id = SHADOW

	required_pref = ROLE_SHADOWLING
	restricted_jobs = list("AI", "Cyborg", "Security Cadet", "Security Officer", "Warden", "Detective", "Blueshield Officer", "Head of Security", "Captain")
	restricted_species_flags = list(IS_SYNTHETIC)

	antag_hud_type = ANTAG_HUD_SHADOW
	antag_hud_name = "hudshadowling"

	logo_state = "shadowling-logo"

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
		S.mutations.Remove(CLUMSY)

	S.verbs += /mob/living/carbon/human/proc/shadowling_hatch
	S.AddSpell(new /obj/effect/proc_holder/spell/targeted/enthrall)
	S.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind)

/datum/role/thrall
	name = SHADOW_THRALL
	id = SHADOW_THRALL

	antag_hud_type = ANTAG_HUD_SHADOW
	antag_hud_name = "hudthrall"

	logo_state = "thrall-logo"

/datum/role/thrall/OnPreSetup(greeting, custom)
	. = ..()
	antag.current.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind)
	SEND_SIGNAL(antag.current, COMSIG_ADD_MOOD_EVENT, "thralled", /datum/mood_event/thrall)

/datum/role/thrall/RemoveFromRole(datum/mind/M, msg_admins)
	..()
	SEND_SIGNAL(antag.current, COMSIG_CLEAR_MOOD_EVENT, "thralled")
