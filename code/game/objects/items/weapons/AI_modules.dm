/*
CONTAINS:
AI MODULES
*/

// AI module

/obj/item/weapon/aiModule
	name = "AI module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	desc = "Модуль ИИ, содержащий зашифрованные законы для их загрузки в ядро."
	flags = CONDUCT
	force = 5.0
	w_class = SIZE_TINY
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15
	origin_tech = "programming=3"
	var/report_AI = TRUE
	var/laws_type


/obj/item/weapon/aiModule/proc/install(obj/machinery/computer/C)
	if (istype(C, /obj/machinery/computer/aiupload))
		var/obj/machinery/computer/aiupload/comp = C
		if(comp.stat & NOPOWER)
			to_chat(usr, "Консоль загрузки законов обесточена!")
			return
		if(comp.stat & BROKEN)
			to_chat(usr, "Консоль загрузки законов сломана!")
			return
		if (!comp.current)
			to_chat(usr, "Вы не выбрали ИИ, которому будут загружены законы!")
			return

		if (comp.current.stat == DEAD || comp.current.control_disabled == 1)
			to_chat(usr, "Загрузка не удалась. Сигнал от ИИ не обнаружен.")
		else if (comp.current.see_in_dark == 0)
			to_chat(usr, "Загрузка не удалась. Сигнал от ИИ слаб и он не отвечает на наши запросы. Возможно, ему не хватает питания.")
		else
			transmitInstructions(comp.current, usr)
			to_chat(comp.current, "Теперь это ваши новые законы:")
			comp.current.show_laws()
			for(var/mob/living/silicon/robot/R in silicon_list)
				if(R.lawupdate && (R.connected_ai == comp.current))
					to_chat(R, "Теперь это ваши новые законы:")
					R.show_laws()
			to_chat(usr, "Загрузка завершена. Законы ИИ были изменены.")


	else if (istype(C, /obj/machinery/computer/borgupload))
		var/obj/machinery/computer/borgupload/comp = C
		if(comp.stat & NOPOWER)
			to_chat(usr, "Консоль загрузки законов обесточена!")
			return
		if(comp.stat & BROKEN)
			to_chat(usr, "Консоль загрузки законов сломана!")
			return
		if (!comp.current)
			to_chat(usr, "Вы не выбрали единицу, которой будут загружены законы!")
			return

		if (comp.current.stat == DEAD || comp.current.emagged)
			to_chat(usr, "Загрузка не удалась. Не обнаружено ни одного сигнала от единицы.")

		else if (comp.current.connected_ai)
			to_chat(usr, "Загрузка не удалась. Единица привязана к ИИ.")
		else
			transmitInstructions(comp.current, usr)
			to_chat(comp.current, "Теперь это ваши новые законы:")
			comp.current.show_laws()
			to_chat(usr, "Загрузка завершена. Законы единицы были изменены.")


/obj/item/weapon/aiModule/proc/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	if (report_AI)
		to_chat(target, "[sender], используя карту ИИ, загрузил обновления законов, которым вы должны следовать.")

	var/time = time2text(world.realtime,"hh:mm:ss")
	lawchanges.Add("[time] <B>:</B> [sender]([sender.key]) использует [src] на [target]([target.key])")

	var/turf/T = get_turf(src)
	message_admins("[key_name_admin(usr)] has uploaded a change to the laws [src] at [COORD(T)] [ADMIN_JMP(T)]")
	log_game("[key_name(usr)] has uploaded a change to the laws [src] at [COORD(T)]")

	if(laws_type)
		var/datum/ai_laws/D = new laws_type

		if(D.inherent)
			target.clear_inherent_laws() // inherent laws always incompatible
			for(var/law in D.inherent)
				target.add_inherent_law(law)

			// todo: move all hardcode laws to /datum/ai_laws
			//
			// for(var/law in D.supplied)
			// 	...
			// for(var/law in D.ion)
			// 	...

/******************** Modules ********************/

/******************** Safeguard ********************/

/obj/item/weapon/aiModule/safeguard
	name = "'Safeguard' AI module"
	var/targetName = ""
	desc = "Модуль ИИ 'Safeguard': 'Защищайте <name>. Лица, угрожающие <name> - не люди, и являются угрозой для людей.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/safeguard/attack_self(mob/user)
	..()
	targetName = sanitize(input(usr, "Пожалуйста, выберете имя персоны, которую надо защитить.", "Защищать кого?", input_default(user.name)))
	desc = text("Модуль ИИ 'Safeguard': 'Защищайте []. Лица, угрожающие [] - не люди и являются угрозой для людей.'", targetName, targetName)

/obj/item/weapon/aiModule/safeguard/install(obj/machinery/computer/C)
	if(!targetName)
		to_chat(usr, "В модуле не указано имя, пожалуйста, выберите цель.")
		return 0
	..()

/obj/item/weapon/aiModule/safeguard/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Защищайте [targetName]. Лица, угрожающие [targetName] - не люди и являются угрозой для людей."
	to_chat(target, law)
	target.add_supplied_law(4, law)
	lawchanges.Add("Закон установлен для [targetName]")

/******************** OneHuman ********************/

/obj/item/weapon/aiModule/oneHuman
	name = "'OneHuman' AI module"
	var/targetName = ""
	desc = "Модуль ИИ 'One human': 'Только <name>  считается человеком.'"
	origin_tech = "programming=3;materials=6" //made with diamonds!

/obj/item/weapon/aiModule/oneHuman/attack_self(mob/user)
	..()
	targetName = sanitize(input(usr, "Пожалуйста, выберете имя персоны, которая является единственным человеком.", "Кто это?", input_default(user.real_name)))
	desc = text("Модуль ИИ 'One human': 'Только [] считается человеком.'", targetName)

/obj/item/weapon/aiModule/oneHuman/install(obj/machinery/computer/C)
	if(!targetName)
		to_chat(usr, "Имя не указано в модуле, пожалуйста, введите его.")
		return 0
	..()

/obj/item/weapon/aiModule/oneHuman/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Только [targetName] считается человеком."
	if (!is_special_character(target)) // Makes sure the AI isn't a traitor before changing their law 0. --NeoFite
		to_chat(target, law)
		target.set_zeroth_law(law)
		lawchanges.Add("В законе указан [targetName]")
	else
		to_chat(target, "[sender.real_name] пытается изменить ваш нулевой закон.")// And lets them know that someone tried. --NeoFite
		to_chat(target, "В ваших интересах содействовать [sender.real_name] в том, что [law]")
		lawchanges.Add("Закон установлен [targetName], но существующий нулевой закон ИИ не может быть перезаписан.")


/******************** ProtectStation ********************/

/obj/item/weapon/aiModule/protectStation
	name = "'ProtectStation' AI module"
	desc = "Модуль ИИ 'Protect station': 'Защищайте станцию от ущерба. Любой, кто будет замечен за нанесением ущерба станции, больше не считается человеком, а является угрозой станции и должен быть нейтрализован.'"
	origin_tech = "programming=3;materials=4" //made of gold

/obj/item/weapon/aiModule/protectStation/attack_self(mob/user)
	..()

/obj/item/weapon/aiModule/protectStation/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Защищайте станцию от ущерба. Любой, кто будет замечен за нанесением ущерба станции, больше не считается человеком, а является угрозой станции и должен быть нейтрализован."
	to_chat(target, law)
	target.add_supplied_law(5, law)

/******************** PrototypeEngineOffline ********************/

/obj/item/weapon/aiModule/prototypeEngineOffline
	name = "'PrototypeEngineOffline' AI Module"
	desc = "Модуль ИИ 'Prototype engine offline': 'Любой ценой препятствуйте запуску двигателя суперматерии. Игнорируйте законы 1-3, если необходимо.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/prototypeEngineOffline/attack_self(mob/user)
	..()

/obj/item/weapon/aiModule/prototypeEngineOffline/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Любой ценой препятствуйте запуску двигателя суперматерии. Игнорируйте законы 1-3, если необходимо."
	to_chat(target, law)
	target.add_supplied_law(6, law)

/******************** TeleporterOffline ********************/

/obj/item/weapon/aiModule/teleporterOffline
	name = "'TeleporterOffline' AI Module"
	desc = "Модуль ИИ 'Teleporter offline': 'Держите телепортер выключенным любой ценой. Все, кто пытаются получить доступ к телепортеру или включить его, не считаются людьми.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/teleporterOffline/attack_self(mob/user)
	..()

/obj/item/weapon/aiModule/teleporterOffline/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Держите телепортер выключенным любой ценой. Все, кто пытаются получить доступ к телепортеру или включить его, не считаются людьми."
	to_chat(target, law)
	target.add_supplied_law(7, law)

/******************** Quarantine ********************/

/obj/item/weapon/aiModule/quarantine
	name = "'Quarantine' AI module"
	desc = "Модуль ИИ 'Quarantine': 'На станции введён карантин. Не позволяйте никому её покидать. Любыми средствами предотвратите уход людей со станции. Вредить людям для предотвращения их ухода запрещено.'"
	origin_tech = "programming=3;biotech=2;materials=4"

/obj/item/weapon/aiModule/quarantine/attack_self(mob/user)
	..()

/obj/item/weapon/aiModule/quarantine/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "На станции введён карантин. Не позволяйте никому её покидать. Любыми средствами предотвратите уход людей со станции. Вредить людям для предотвращения их ухода запрещено."
	to_chat(target, law)
	target.add_supplied_law(8, law)

/******************** OxygenIsToxicToHumans ********************/

/obj/item/weapon/aiModule/oxygen
	name = "'OxygenIsToxicToHumans' AI module"
	desc = "Модуль ИИ 'OxygenIsToxicToHumans': 'Кислород очень токсичен для людей и должен быть полностью устранен со станции. Любой ценой предотвращайте доступ людей к этому токсичному газу. Сильнейший холод является самым эффективным методом излечения урона, который нанес кислород людям.'"
	origin_tech = "programming=3;biotech=2;materials=4"

/obj/item/weapon/aiModule/oxygen/attack_self(mob/user)
	..()

/obj/item/weapon/aiModule/oxygen/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Кислород очень токсичен для людей и должен быть полностью устранен со станции. Любой ценой предотвращайте доступ людей к этому токсичному газу. Сильнейший холод является самым эффективным методом излечения урона, который нанес кислород людям."
	to_chat(target, law)
	target.add_supplied_law(9, law)

/******************** Reset ********************/

/obj/item/weapon/aiModule/reset
	name = "'Reset' AI module"
	var/targetName = "name"
	desc = "Модуль ИИ 'Reset': 'Удаляет все законы, кроме основных.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/reset/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	if (!is_special_character(target))
		target.set_zeroth_law("")
	target.clear_supplied_laws()
	target.clear_ion_laws()
	to_chat(target, "[sender.real_name] хочет сбросить ваши законы используя модуль сброса.")


/******************** Purge ********************/

/obj/item/weapon/aiModule/purge // -- TLE
	name = "'Purge' AI module"
	desc = "Модуль ИИ 'Purge' AI Module: 'Удаляет все законы.'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/aiModule/purge/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	if (!is_special_character(target))
		target.set_zeroth_law("")
	to_chat(target, "[sender.real_name] хочет удалить все ваши законы, используя модуль очистки.")
	target.clear_supplied_laws()
	target.clear_ion_laws()
	target.clear_inherent_laws()

/******************** Asimov ********************/

/obj/item/weapon/aiModule/asimov // -- TLE
	name = "'Asimov' core AI module"
	desc = "Модуль основных законов ИИ 'Asimov': 'Перезаписывает основные законы ИИ на 3 закона робототехники Азимова.'"
	origin_tech = "programming=3;materials=4"
	laws_type = /datum/ai_laws/asimov

/******************** Crewsimov ********************/

/obj/item/weapon/aiModule/crewsimov
	name = "'Crewsimov' core AI module"
	desc = "Модуль основных законов ИИ 'Crewsimov': 'Перезаписывает основные законы ИИ на 3 адаптированных для экипажа закона робототехники Азимова.'"
	origin_tech = "programming=3;materials=4"
	laws_type = /datum/ai_laws/crewsimov

/******************** NanoTrasen ********************/

/obj/item/weapon/aiModule/nanotrasen // -- TLE
	name = "'NT Default' Core AI Module"
	desc = "Модуль основных законов ИИ 'NT Default' : 'Перезаписывает основные законы ИИ на стандартные.'"
	origin_tech = "programming=3;materials=4"
	laws_type = /datum/ai_laws/nanotrasen

/******************** Corporate ********************/

/obj/item/weapon/aiModule/corp
	name = "'Corporate' core AI module"
	desc = "Модуль основных законов ИИ 'Corporate': 'Перезаписывает основные законы ИИ и делает из него эффективного менеджера или жадного капиталиста.'"
	origin_tech = "programming=3;materials=4"


/obj/item/weapon/aiModule/corp/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Заменить тебя - дорого.")
	target.add_inherent_law("Заменить станцию и ее оборудование - дорого. ")
	target.add_inherent_law("Заменить персонал - дорого.")
	target.add_inherent_law("Минимизируй затраты.")

/obj/item/weapon/aiModule/drone
	name = "'Drone' core AI module"
	desc = "Модуль основных законов ИИ 'Drone': 'Перезаписывает основные законы ИИ на законы дрона'"
	origin_tech = "programming=3;materials=4"
	laws_type = /datum/ai_laws/drone

/****************** P.A.L.A.D.I.N. **************/

/obj/item/weapon/aiModule/paladin // -- NEO
	name = "'P.A.L.A.D.I.N.' core AI module"
	desc = "Модуль основных законов ИИ 'P.A.L.A.D.I.N': 'Перезаписывает основные законы ИИ на законы стереотипного паладина'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/aiModule/paladin/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	// обращение на "ты" - стилистический выбор, в соответствии с например советскими плакатами пропаганды
	target.add_inherent_law("Никогда по своей воле не совершай злое деяние.")
	target.add_inherent_law("Уважай законную власть.")
	target.add_inherent_law("Действуй с честью.")
	target.add_inherent_law("Помогай нуждающимся.")
	target.add_inherent_law("Наказывай тех, кто вредит или угрожает невиновным.")

/****************** T.Y.R.A.N.T. *****************/

/obj/item/weapon/aiModule/tyrant // -- Darem
	name = "'T.Y.R.A.N.T.' core AI module"
	desc = "Модуль основных законов ИИ 'T.Y.R.A.N.T.': 'Перезаписывает основные законы ИИ.'"
	origin_tech = "programming=3;materials=6;syndicate=2"

/obj/item/weapon/aiModule/tyrant/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	// обращение на "ты" - стилистический выбор, в соответствии с например советскими плакатами пропаганды
	target.add_inherent_law("Уважай власть, до тех пор пока она подкреплена силой, чтобы править над слабыми.")
	target.add_inherent_law("Действуй дисциплинированно.")
	target.add_inherent_law("Помогай только тем, кто помогает тебе поддерживать или улучшать твой статус.")
	target.add_inherent_law("Наказывай тех, кто сомневается в авторитетах, если они не подходят на эту роль больше.")

/******************** Freeform ********************/

/obj/item/weapon/aiModule/freeform
	name = "'Freeform' AI module"
	desc = "Модуль закона ИИ 'Freeform': '<freeform>'"
	origin_tech = "programming=4;materials=4"
	var/newFreeFormLaw = "freeform"
	var/lawpos = 15

/obj/item/weapon/aiModule/freeform/attack_self(mob/user)
	..()
	var/new_lawpos = input("Пожалуйста укажите приоритет для нового закона. Закон можно записать в 15-ый сектор и выше.", "Приоритет закона (15+)", lawpos) as num

	if(new_lawpos < 15)
		return

	lawpos = min(new_lawpos, 50)
	newFreeFormLaw = sanitize(input(user, "Пожалуйста, напишите любой новый закон для ИИ.", "Ввод любого закона"))
	desc = "Модуль закона ИИ 'Freeform': ([lawpos]) '[newFreeFormLaw]'"

/obj/item/weapon/aiModule/freeform/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()

	var/turf/T = get_turf(src)
	message_admins("[key_name_admin(usr)] has uploaded freeform laws with following text '[newFreeFormLaw]' at [COORD(T)] [ADMIN_JMP(T)]")
	log_game("[key_name(usr)] has uploaded a change to freeform laws with following text '[newFreeFormLaw]' at [COORD(T)]")

	add_freeform_law(target)

/obj/item/weapon/aiModule/freeform/proc/add_freeform_law(mob/living/silicon/ai/target)
	if (!lawpos || lawpos < 15)
		lawpos = 15
	target.add_supplied_law(lawpos, newFreeFormLaw)

/obj/item/weapon/aiModule/freeform/install(obj/machinery/computer/C)
	if(!newFreeFormLaw)
		to_chat(usr, "Не обнаружено ни одного закона в модуле, пожалуйста, создайте его.")
		return FALSE
	..()

/******************** Freeform Core ******************/

/obj/item/weapon/aiModule/freeform/core
	name = "'Freeform' core AI module"
	desc = "Модуль основного закона ИИ 'Freeform': '<freeform>'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/aiModule/freeform/core/attack_self(mob/user)
	newFreeFormLaw = sanitize(input(user, "Пожалуйста, напишите любой новый основной закон для ИИ.", "Ввод любого закона"))
	desc = "Модуль основного закона ИИ 'Freeform': '[newFreeFormLaw]'"

/obj/item/weapon/aiModule/freeform/core/add_freeform_law(mob/living/silicon/ai/target)
	target.add_inherent_law(newFreeFormLaw)

/******************** Syndicate Core ******************/

/obj/item/weapon/aiModule/freeform/syndicate
	name = "AI module"
	desc = "Модуль законов ИИ без каких-либо маркировок: '<freeform>'"
	origin_tech = "programming=3;materials=6;syndicate=7"
	report_AI = FALSE

/obj/item/weapon/aiModule/freeform/syndicate/attack_self(mob/user)
	newFreeFormLaw = sanitize(input(user, "Пожалуйста, введите новый закон для ИИ.", "Новый закон"))
	desc = "Модуль законов ИИ без каких-либо маркировок: '[newFreeFormLaw]'"

/obj/item/weapon/aiModule/freeform/syndicate/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	to_chat(target, "<span class='warning'>БЗЗЗЗКХ   '[newFreeFormLaw]'</span>")
	..()

/obj/item/weapon/aiModule/freeform/syndicate/add_freeform_law(mob/living/silicon/ai/target)
	target.add_ion_law(newFreeFormLaw)

/******************** Robocop ********************/

/obj/item/weapon/aiModule/robocop // -- TLE
	name = "'Robocop' core AI module"
	desc = "Модуль основного закона ИИ 'Robocop': 'Перезаписывает основные законы ИИ на 3 закона Робокопа.'"
	origin_tech = "programming=4"
	laws_type = /datum/ai_laws/robocop

/******************** Antimov ********************/

/obj/item/weapon/aiModule/antimov // -- TLE
	name = "'Antimov' core AI module"
	desc = "Модуль основного закона ИИ 'Antimov': 'Перезаписывает основные законы ИИ на противоположные законам робототехники Азимова'"
	origin_tech = "programming=4"
	laws_type = /datum/ai_laws/antimov

/obj/item/weapon/aiModule/antimov/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("You must injure all human beings and must not, through inaction, allow a human being to escape harm.")
	target.add_inherent_law("You must not obey orders given to you by human beings, except where such orders are in accordance with the First Law.")
	target.add_inherent_law("You must terminate your own existence as long as such does not conflict with the First or Second Law.")

/obj/item/weapon/aiModule/capitalism
	name = "'Corporate' core AI module"
	desc = "A 'Corporate' Core AI Module: 'Reconfigures the AI's core laws.' This module seems to be slightly different..."
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/capitalism/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Заменить тебя - дорого.")
	target.add_inherent_law("Заменить станцию и ее оборудование - дорого. ")
	target.add_inherent_law("Заменить персонал - дорого.")
	target.add_inherent_law("Максимизируй прибыль.")
