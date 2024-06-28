/datum/role/alien
	name = XENOMORPH
	id = XENOMORPH
	required_pref = ROLE_ALIEN
	disallow_job = TRUE

	antag_hud_type = ANTAG_HUD_ALIEN
	antag_hud_name = "hudalien"

	logo_state = "alien-logo"
	hide_logo = TRUE

/datum/role/alien/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>
Вы - ксеноморф. Ваша текущая форма - грудолом.
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
	hide_logo = TRUE
	change_to_maximum_skills = FALSE
	var/greet_msg = {"Вы - член экипажа межзвездного буксировщика Ностромо, на борту которого находится ксеноморф.
Как можно скорее изничтожьте эту тварь, пока не стало слишком поздно.
"}
	var/greet_msg_tip

/datum/role/nostromo_crewmate/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>[greet_msg + greet_msg_tip]------------------</b></span>"})

/datum/role/nostromo_crewmate/captain
	greet_msg_tip = {"Эта особь отличается от тех, что вы могли видеть ранее, чем дольше живет это существо, тем сильнее становится. Медлить нельзя.
Если ситуация выйдет из под контроля, запустите механизм самоуничтожения корабля, ксеноморф не должен попасть на планету."}

/datum/role/nostromo_crewmate/engineer
	greet_msg_tip = "Он слишком большой, чтобы уместиться в трубе воздухоснабжения, заваривать вентиляции бесполезно."

/datum/role/nostromo_crewmate/cargotech
	greet_msg_tip = "На складе стоит мех погрузчик, но он разряжен."

/datum/role/nostromo_crewmate/pilot
	greet_msg_tip = "та я хуй знает иди нахуй чел лол"

/datum/role/nostromo_crewmate/medic
	greet_msg_tip = "писька писька писька писька хахахахаха."
