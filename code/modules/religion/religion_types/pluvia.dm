/datum/religion/pluvia
	name = "Путь Плувиийца"
	deity_names_by_name = list(
		"Путь Плувиийца" = list("Лунарис")
	)
	bible_info_by_name = list(
		"Путь Плувиийца" = /datum/bible_info/chaplain/bible, //потом переделать на другую
	)

	emblem_info_by_name = list(
		"Путь Плувиийца" = "christianity", //потом переделать на другую
	)

	altar_info_by_name = list(
		"Путь Плувиийца" = "chirstianaltar",
	)
	carpet_type_by_name = list(
		"Путь Плувиийца" = /turf/simulated/floor/carpet,
	)
	style_text = "piety"
	symbol_icon_state = null
	var/haram_harm = 2

/datum/religion/pluvia/proc/harm_haram(datum/source, mob/living/carbon/human/target)
	var/mob/living/carbon/human/attacker  = source
	if(istype(target.my_religion, /datum/religion/pluvia))
		if(attacker.haram_point < haram_threshold)
			attacker.haram_point += haram_harm
			attacker.playsound_local(null, 'sound/effects/haram.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			to_chat(attacker, "<span class='warning'>\ <font size=3>Хватит наносить вред Плувийцу!</span></font>")
		else
			global.pluvia_religion.remove_member(attacker, HOLY_ROLE_PRIEST)
			attacker.social_credit = 0
			to_chat(attacker, "<span class='warning'>\ <font size=5>Врата рая закрыты для вас. Ищите себе другого покровителя</span></font>")


/datum/religion/pluvia/add_member(mob/living/carbon/human/H)
	. = ..()
	H.AddSpell(new /obj/effect/proc_holder/spell/create_bless_vote)
	RegisterSignal(H, COMSIG_HUMAN_HARMED_OTHER, PROC_REF(harm_haram))

/datum/religion/pluvia/remove_member(mob/M)
	. = ..()
	for(var/obj/effect/proc_holder/spell/create_bless_vote/spell_to_remove in M.spell_list)
		M.RemoveSpell(spell_to_remove)
	UnregisterSignal(M, list(COMSIG_HUMAN_HARMED_OTHER, COMSIG_PARENT_QDELETING))

/datum/religion/pluvia/setup_religions()
	global.pluvia_religion = src
	all_religions += src
