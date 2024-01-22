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
	to_chat(antag.current, "<b>Вы - Шедоулинг. На данный момент, вы скрываетесь под личиной одного из сотрудников станции [station_name()].</b>")
	to_chat(antag.current, "<b>В этой слабой оболочке, вы способны лишь: Enthrall - поработить не просвещённого, Hatch - облачиться в свою истинную форму (находится во вкладке Shadowling Evolution в верхней-правой части экрана), и Hivemind Commune - общаться с себе подобными братьями и рабами.</b>")
	to_chat(antag.current, "<b>Другие Шедоулинги являются вашими братьями и союзниками. Вы должны помогать им, как и они вам, для достижения общей цели.</b>")
	to_chat(antag.current, "<b>Если вы впервые играете за Шедоулинга, или хотите ознакомится с вашими способностями, перейдите на эту страницу нашей вики - https://wiki.taucetistation.org/Shadowling</b><br>")

/datum/role/shadowling/OnPostSetup(laterole)
	. = ..()
	var/mob/living/carbon/human/S = antag.current

	if(antag.assigned_role == "Clown")
		to_chat(S, "<span class='notice'>Ваша нечеловеческая природа позволила преодолеть вашего внутреннего клоуна.</span>")
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

/datum/role/thrall/Greet(greeting, custom)
    . = ..()
    to_chat(antag.current, "<b>Вы были порабощены Шедоулингом и обязаны выполнять любой приказ, и помогать ему в достижении его целей.</b>")

/datum/role/thrall/OnPreSetup(greeting, custom)
	. = ..()
	antag.current.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind)
	SEND_SIGNAL(antag.current, COMSIG_ADD_MOOD_EVENT, "thralled", /datum/mood_event/thrall)

/datum/role/thrall/RemoveFromRole(datum/mind/M, msg_admins)
	SEND_SIGNAL(antag.current, COMSIG_CLEAR_MOOD_EVENT, "thralled")
	for(var/obj/effect/proc_holder/spell/targeted/shadowling_hivemind/S in antag.current.spell_list)
		antag.current.RemoveSpell(S)
	..()
