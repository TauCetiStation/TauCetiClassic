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

/datum/role/nostromo_crewmate/forgeObjectives()
	if(!..())
		return FALSE
	var/mob/M = antag.original
	if(ishuman(M) && M.job == "Captain")
		AppendObjective(/datum/objective/defend_crew)
	return TRUE

/datum/role/nostromo_crewmate/OnPostSetup()
	var/mob/M = antag.current
	var/datum/action/A = new /datum/action/nostromo_map(M)
	A.Grant(M)

/datum/role/nostromo_cat
	name = NOSTROMO_CAT
	id = NOSTROMO_CAT
	logo_state = "cat-logo"
	disallow_job = TRUE

/datum/role/nostromo_cat/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/survive)
	return TRUE

/datum/role/nostromo_cat/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>
Вы - очень чувствительный рыжий котик Джонси. Постарайтесь выжить.
------------------</b></span>"})


/datum/role/nostromo_android
	name = NOSTROMO_ANDROID
	id = NOSTROMO_ANDROID
	logo_state = "nano-logo"
	change_to_maximum_skills = FALSE
	restricted_jobs = list("Captain")

/datum/role/nostromo_android/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/defend_alien)
	return TRUE

/datum/role/nostromo_android/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>
Вы - андроид, тайно посланный корпорацией в этот рейс.
На борту корабля находится ксеноморф - идеальная форма жизни.
Ваша задача - доставить его живым на Марс для дальнейшего изучения.
Шансы на выживание экипажа ничтожно малы, поэтому корпорацией принято решение пренебречь их жизнями.
Экипаж не знает что вы не человек, постарайтесь не раскрывать этого раньше времени.
Ваш корпус крайне хрупок, поэтому вступать в прямую конфронтацию с экипажем не рекомендуется.
Для подзарядки используйте апц в инженерном отсеке.
------------------</b></span>"})

/datum/role/nostromo_android/OnPostSetup()
	var/mob/M = antag.current
	var/datum/action/A = new /datum/action/nostromo_map(M)
	A.Grant(M)


/datum/action/nostromo_map
	name = "Вспомнить схему корабля."
	check_flags = AB_CHECK_ALIVE
	action_type = AB_INNATE
	button_icon_state = "holomap"

/datum/action/nostromo_map/Activate()
	owner << browse_rsc('nano/images/nanomap_nostromo_1.png', "nanomap.png")
	var/datum/browser/popup = new(owner, "window=[name]", "[name]", 700, 700, ntheme = CSS_THEME_DARK)
	popup.set_content("<img src='nanomap.png' style='-ms-interpolation-mode:nearest-neighbor'>")
	popup.open()


/atom/movable/screen/alert/status_effect/cutscene
	name = "Катсцена"
	desc = "Сидим и смотрим киношку."
	icon_state = "buckled"

/datum/status_effect/cutscene
	id = "alien_adrenaline"
	alert_type = /atom/movable/screen/alert/status_effect/cutscene

/datum/status_effect/cutscene/on_creation(mob/living/new_owner, duration = 30 SECOND)
	. = ..()
	if(!.)
		return
	src.duration = world.time + duration

/datum/status_effect/cutscene/on_apply()
	owner.SetParalysis(1000, TRUE)

/datum/status_effect/cutscene/on_remove()
	owner.SetParalysis(0, TRUE)
