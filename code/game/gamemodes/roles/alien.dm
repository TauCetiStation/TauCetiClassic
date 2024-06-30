/datum/role/alien
	name = LONE_XENOMORPH
	id = LONE_XENOMORPH
	required_pref = ROLE_ALIEN
	disallow_job = TRUE

	antag_hud_type = ANTAG_HUD_ALIEN
	antag_hud_name = "hudalien"
	logo_state = "alien-logo"

/datum/role/alien/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/bloodbath)
	return TRUE

/datum/role/alien/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>
Вы - одинокий ксеноморф. Ваша текущая форма - грудолом.
Жмите кнопку внизу, чтобы пробиться сквозь грудную клетку своего носителя.
Выбравшись наружу - бегите и прячьтесь, сейчас вы очень слабы и вас легко убить.
Ваша задача - вырасти во взрослого ксеноморфа. Прогресс роста указан во вкладке Status.
На этом процесс эволюции не закончится, даже будучи взрослой особью вам есть куда расти.
Вы пассивно накапливаете очки эволюции, за которые будут открываться новые стадии развития и способности.
Этот процесс можно ускорить, нападая на экипаж. Вам будут выдаваться очки за успешные агрессивные действия.
Информация о ходе эволюции находится во вкладке Status.
------------------</b></span>"})


/datum/role/nostromo_crewmate
	name = NOSTROMO_CREWMATE
	id = NOSTROMO_CREWMATE
	logo_state = "nostromo-logo"
	change_to_maximum_skills = FALSE

/datum/role/nostromo_crewmate/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>
Вы - член экипажа межзвездного буксировщика Ностромо, на борту которого находится ксеноморф.
Как можно скорее изничтожьте эту тварь, пока не стало слишком поздно.
------------------</b></span>"})
