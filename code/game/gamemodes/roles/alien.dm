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
	AppendObjective(/datum/objective/evolution)
	AppendObjective(/datum/objective/survive/ru)
	return TRUE

/datum/role/alien/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>
Вы - одинокий ксеноморф. Ваша текущая форма - грудолом.
Выбравшись наружу - бегите и прячьтесь, сейчас вы очень слабы и вас легко убить.
Ваша задача - вырасти во взрослого ксеноморфа.
На этом процесс эволюции не закончится, даже будучи взрослой особью вам есть куда расти.
Поедая тела людей вы становитесь сильнее. Один съеденный труп ~ один этап эволюции.
Помните, нападая на людей, вы помечаете первого атакованного вами человека меткой охоты.
Пока действует эффект охоты вы не можете атаковать никого, кроме этого человека.
Пока вы не достигли третьего этапа эволюции на вас может сработать эффект адреналина.
Адреналин разово и автоматически срабатывает, когда у вас мало хп.
Он моментально приводит вас в чувство и даёт ускорение на ближайшие 20 секунд. Получив этот эффект - бегите, не пытайтесь драться дальше.
Вы можете ускорить поломку смеса в инженерном отсеке, кликнув по нему.
Вы можете заразить гидропонику в ботаническом отсеке, кликнув по ней.
Не пытайтесь уничтожить ИИ.
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
Также у вас есть доступ ко всем отсекам и шкафам на станции.
Время от времени вам с пилотом придётся корректировать курс корабля.
Для этого пройдите в рубку пилота и осмотрите консоли на ней.
Каждая из консолей отвечает за свой градус наклона (первое число в паре - градус этой консоли).
Нажимая на консоль вы будете приближать к нулю её градус и отдалять от нуля градус второй консоли.
Говоря проще, вам нужно поочерёдно использовать обе консоли, пока значения на них не приблизятся к нулю.
Не допускайте отклонения больше чем на 24 градуса от нуля, иначе ЭМИ вышибет всю электронику на корабле.
------------------</b></span>"})

		if("Station Engineer")		// ENGINEER
			to_chat(antag.current, {"<span class='notice'><b>
Вы - инженер межзвёздного буксировщика Ностромо, на борту которого находится ксеноморф.
Первым делом проследуйте в двигательную и запустите ядерный реактор.
На этом ваша работа не закончится, вам нужно будет регулярно проверять состояние СМЕСа и чинить его.
Для этого сначала осмотрите его и по сообщению в чате выясните какой инструмент нужно использовать.
Повторяйте до полной починки СМЕСа. Будьте осторожны, при низкой стабильности он обязательно ударит вас током.
Для противодействия ксеноморфу в атмосферном висит пожарный топор, а у двигателя лежит пневмопушка.
Также из подручных материалов можете делать болы, но не используйте их слишком часто.
Слушайте всё, что говорит вам капитан.
------------------</b></span>"})

		if("Blueshield Officer")	// PILOT
			to_chat(antag.current, {"<span class='notice'><b>
Вы - пилот межзвездного буксировщика Ностромо, на борту которого находится ксеноморф.
Помогайте капитану организовать экипаж для борьбы, по возможности защищайте его от угроз.
В вашем шкафу находится мощный ручной флэшер, его свет при прямом воздействии способен на время остановить ксеноморфа.
Учтите что ему нужно время охладиться.
Время от времени вам с капитаном придётся корректировать курс корабля.
Для этого пройдите в свою рубку и осмотрите консоли на ней.
Каждая из консолей отвечает за свой градус отклонения.
Нажимая на консоль вы будете приближать к нулю её градус и отдалять от нуля градус второй консоли.
Говоря проще, вам нужно поочерёдно использовать обе консоли, пока значения на них не приблизятся к нулю.
Не допускайте отклонения больше чем на 24 градуса от нуля, иначе ЭМИ вышибет всю электронику на корабле.
Слушайте всё, что говорит вам капитан.
------------------</b></span>"})

		if("Medical Doctor")		// DOCTOR
			to_chat(antag.current, {"<span class='notice'><b>
Вы - доктор межзвездного буксировщика Ностромо, на борту которого находится ксеноморф.
В мед лаборатории вы найдёте шприцемёт и коробку шприцев с лечебной микстурой к нему.
Также у вас есть по 4 инъектора со стимуляторами и метатромбином и 2 инъектора с нанокальцием.
Используйте их с умом и только если травмы человека не столь значительны и его ещё можно спасти.
Даже не пытайтесь реанимировать трупы, особенно если их обглодал ксеноморф!
Вы лишь потратите время и драгоценные медикаменты.
Слушайте всё, что говорит вам капитан.
------------------</b></span>"})

		if("Cargo Technician")		// CARGO TECH
			to_chat(antag.current, {"<span class='notice'><b>
Вы - заведующий складом межзвездного буксировщика Ностромо, на борту которого находится ксеноморф.
Склад - огромный отсек, поэтому на время полёта его обесточивают, чтобы не тратить энергию.
Даже не пытайтесь проникнуть на него раньше времени. ИИ оповестит вас когда вы сможете туда попасть.
На складе есть старый и очень крепкий рипли, но он разряжен.
Вы можете поменять ему батарею или попытаться собрать зарядник отыскав разбросанные по складу конденсаторы.
Меняя батарею, убедитесь, что она заряжена.
Слушайте всё, что говорит вам капитан.
------------------</b></span>"})

	return TRUE

/datum/role/nostromo_crewmate/forgeObjectives()
	if(!..())
		return FALSE
	if(antag.current.job == "Captain")
		AppendObjective(/datum/objective/nostromo/defend_crew)
	return TRUE

/datum/role/nostromo_crewmate/OnPostSetup()
	. = ..()
	var/mob/living/L = antag.current
	var/datum/action/A = new /datum/action/nostromo_map(L)
	A.Grant(L)
	var/turf/current_turf = get_turf(L)
	var/obj/structure/stool/bed/chair/metal/chair = locate() in current_turf.contents
	if(chair)
		chair.buckle_mob(L)
	L.Stun(5, TRUE)
	L.speed++

/datum/role/nostromo_cat
	name = NOSTROMO_CAT
	id = NOSTROMO_CAT
	logo_state = "cat-logo"
	disallow_job = TRUE

/datum/role/nostromo_cat/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/survive/ru)
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
	AppendObjective(/datum/objective/nostromo/defend_alien)
	AppendObjective(/datum/objective/nostromo/defend_ship)
	AppendObjective(/datum/objective/survive/ru)
	return TRUE

/datum/role/nostromo_android/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>
Вы - андроид, тайно посланный корпорацией в этот рейс.
На борту корабля находится ксеноморф - идеальная форма жизни.
Ваша задача - доставить его живым на Марс для дальнейшего изучения.
Шансы на выживание экипажа ничтожно малы, поэтому корпорацией принято решение пренебречь их жизнями.
Экипаж не знает что вы не человек, постарайтесь не раскрывать этого.
Ваш корпус крайне хрупок, поэтому вступать в прямую конфронтацию с экипажем не рекомендуется.
Для подзарядки используйте апц в инженерном отсеке.
Поведение особи непредсказуемо, рекомендуется свести возможные контакты к минимуму.
В случае прямого контакта с особью, рекомендуется не подавать признаков жизни.
------------------</b></span>"})

/datum/role/nostromo_android/OnPostSetup()
	. = ..()
	var/mob/living/L = antag.current
	var/datum/action/A = new /datum/action/nostromo_map(L)
	A.Grant(L)
	var/turf/current_turf = get_turf(L)
	var/obj/structure/stool/bed/chair/metal/chair = locate() in current_turf.contents
	if(chair)
		chair.buckle_mob(L)
	L.Stun(5, TRUE)
	L.speed++


/datum/action/nostromo_guide
	name = "Вспомнить план корабля."
	check_flags = AB_CHECK_ALIVE
	action_type = AB_INNATE
	button_icon_state = "holomap"

/datum/action/nostromo_map/Activate()
	owner << browse_rsc('nano/images/nanomap_nostromo_1.png', "nanomap.png")
	var/datum/browser/popup = new(owner, "window=[name]", "План корабля", 640, 670, ntheme = CSS_THEME_DARK)
	popup.set_content("<img src='nanomap.png' style='-ms-interpolation-mode:nearest-neighbor'>")
	popup.open()
