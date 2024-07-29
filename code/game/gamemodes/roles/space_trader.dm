/datum/role/space_trader
	disallow_job = TRUE
	logo_state = "space_traders"

/datum/role/space_trader/dealer
	skillset_type = /datum/skillset/quartermaster

/datum/role/space_trader/dealer/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>Вы - барыга.

------------------</b></span>"})

/datum/role/space_trader/guard
	skillset_type = /datum/skillset/officer

/datum/role/space_trader/guard/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>Вы - ЧОПовец.

------------------</b></span>"})

/datum/role/space_trader/porter
	skillset_type = /datum/skillset/cargotech

/datum/role/space_trader/porter/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>Вы - грузчик.

------------------</b></span>"})
