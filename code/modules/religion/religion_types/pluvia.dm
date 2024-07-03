/datum/religion/pluvia
	name = "Путь Плувиийца"
	deity_names_by_name = list(
		"Путь Плувиийца" = list("Лунарис")
	)

	style_text = "piety"
	symbol_icon_state = "nimbus"

/datum/religion/pluvia/add_member(mob/M)
	. = ..()
	M.AddSpell(new /obj/effect/proc_holder/spell/create_bless_vote)

/datum/religion/pluvia/remove_member(mob/M)
	. = ..()
	M.RemoveSpell(/obj/effect/proc_holder/spell/create_bless_vote)

/datum/religion/pluvia/setup_religions()
	global.pluvia_religion = src
	all_religions += src
