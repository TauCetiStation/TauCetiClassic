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
Выбравшись наружу - бегите и прячьтесь, сейчас вы очень слабы и вас легко убить.
Ваша задача - вырасти во взрослого ксеноморфа. Прогресс роста указан во вкладке Status.
На этом процесс эволюции не закончится, даже будучи взрослой особью вам есть куда расти.
Атакуйте людей, утаскивайте бездыханные тела в техтуннели и съедайте их.
Поедая тела людей вы становитесь сильнее.
Но помните, что нападая на людей вы помечаете первого атакованного вами человека меткой охоты.
Пока действует эффект охоты вы не можете атаковать никого, кроме человека, помеченного этой меткой.
Информация о ходе эволюции находится во вкладке Status.
------------------</b></span>"})


/datum/role/nostromo_crewmate
	name = NOSTROMO_CREWMATE
	id = NOSTROMO_CREWMATE
	logo_state = "nostromo-logo"
	change_to_maximum_skills = FALSE

/datum/role/nostromo_crewmate/Greet(greeting, custom)
	. = ..()
	switch(antag.current.job)
		if("Captain")				// CAPTAIN
			to_chat(antag.current, {"<span class='notice'><b>
Вы - капитан межзвёздного буксировщика Ностромо, на борту которого находится ксеноморф.
Вы несёте прямую ответственность за весь экипаж корабля, постарайтесь свести жертвы к минимуму.
Организовывайте экипаж, собирайте людей вместе. Помните, что по одиночке вы - лёгкие мишени для монстра.
В вашем шкафу находится старый энерго пистолет и датчик движения для отслеживания местоположения ксеноморфа.
Кроме того именно у вас находится всё необходимое для запуска механизма самоуничтожения корабля и эвакуации.
------------------</b></span>"})

		if("Station Engineer")		// ENGINEER
			to_chat(antag.current, {"<span class='notice'><b>
Вы - инженер межзвёздного буксировщика Ностромо, на борту которого находится ксеноморф.
Первым делом проследуйте в двигательную и запустите ядерный реактор.
На этом ваша работа не закончится, вам нужно будет регулярно проверять состояние СМЕСа и чинить его.
Для починки СМЕСа используйте мультитул, если же вы не успеете это сделать, корабль полностью обесточится.
Для противодействия ксеноморфу в атмосферном висит пожарный топор, а у двигателя лежит пневмопушка.
Слушайте всё, что говорит вам капитан.
------------------</b></span>"})

		if("Blueshield Officer")	// PILOT
			to_chat(antag.current, {"<span class='notice'><b>
Вы - пилот межзвездного буксировщика Ностромо, на борту которого находится ксеноморф.
Помогайте капитану организовать экипаж для борьбы, по возможности защищайте его от угроз.
В вашем шкафу находится лёгкий раскладной щит и сумка для удобного ношения.
Слушайте всё, что говорит вам капитан.
------------------</b></span>"})

		if("Medical Doctor")		// DOCTOR
			to_chat(antag.current, {"<span class='notice'><b>
Вы - доктор межзвездного буксировщика Ностромо, на борту которого находится ксеноморф.
В мед лаборатории
Слушайте всё, что говорит вам капитан.
------------------</b></span>"})

		if("Cargo Technician")		// CARGO TECH
			to_chat(antag.current, {"<span class='notice'><b>
Вы - заведующий складом межзвездного буксировщика Ностромо, на борту которого находится ксеноморф.
Как можно скорее изничтожьте эту тварь, пока не стало слишком поздно.
Слушайте всё, что говорит вам капитан.
------------------</b></span>"})

	return TRUE

/datum/role/nostromo_crewmate/forgeObjectives()
	if(!..())
		return FALSE
	if(antag.current.job == "Captain")
		AppendObjective(/datum/objective/defend_crew)
	return TRUE

/datum/role/nostromo_crewmate/OnPostSetup()
	var/mob/living/L = antag.current
	var/datum/action/A = new /datum/action/nostromo_map(L)
	A.Grant(L)
	var/turf/current_turf = get_turf(L)
	var/obj/structure/stool/bed/chair/metal/chair = locate() in current_turf.contents
	if(chair)
		chair.buckle_mob(L)
	L.Stun(6, TRUE)

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
Поведение особи непредсказуемо, рекомендуется свести возможные контакты к минимуму.
В случае прямого контакта с особью, рекомендуется не подавать признаков жизни.
------------------</b></span>"})

/datum/role/nostromo_android/OnPostSetup()
	var/mob/living/L = antag.current
	var/datum/action/A = new /datum/action/nostromo_map(L)
	A.Grant(L)
	L.SetParalysis(80, TRUE)


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
