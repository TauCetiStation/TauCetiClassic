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
	desc = "Модуль ИИ содержащий зашифрованные законы для их загрузки в ядро."
	flags = CONDUCT
	force = 5.0
	w_class = ITEM_SIZE_SMALL
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15
	origin_tech = "programming=3"
	var/report_AI = TRUE


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

		if(SSticker && SSticker.mode && SSticker.mode.name == "blob")
			to_chat(usr, "Загрузка законов отключена НаноТрейзен!")
			to_chat(usr, "Law uploads have been disabled by NanoTrasen!")
			return

		if (comp.current.stat == DEAD || comp.current.control_disabled == 1)
			to_chat(usr, "Загрузка не удалась. Не обнаружено ни одного сигнала от ИИ.")
		else if (comp.current.see_in_dark == 0)
			to_chat(usr, "Загрузка не удалась. От ИИ поступает только слабый сигнал, и он не отвечает на наши запросы. Возможно, ему не хватает питания.")
		else
			src.transmitInstructions(comp.current, usr)
			to_chat(comp.current, "Теперь, это ваши новые законы:")
			comp.current.show_laws()
			for(var/mob/living/silicon/robot/R in silicon_list)
				if(R.lawupdate && (R.connected_ai == comp.current))
					to_chat(R, "Теперь, это ваши новые законы:")
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
			to_chat(usr, "Вы не выбрали киборга которому будут загружены законы!")
			return

		if (comp.current.stat == DEAD || comp.current.emagged)
			to_chat(usr, "Загрузка не удалась. Не обнаружено ни одного сигнала от киборга.")
		else if (comp.current.connected_ai)
			to_chat(usr, "Загрузка не удалась. Киборг привязан к ИИ.")
		else
			src.transmitInstructions(comp.current, usr)
			to_chat(comp.current, "Теперь это ваши новые законы:")
			comp.current.show_laws()
			to_chat(usr, "Загрузка завершена. Законы киборга были изменены.")


/obj/item/weapon/aiModule/proc/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	if (report_AI)
		to_chat(target, "[sender] загрузил законы, которыми вы теперь должны следовать, используя [src].")

	var/time = time2text(world.realtime,"hh:mm:ss")
	lawchanges.Add("[time] <B>:</B> [sender]([sender.key]) импользует [src] на [target]([target.key])")

	var/turf/T = get_turf(src)
	message_admins("[key_name_admin(usr)] has uploaded a change to the laws [src] at ([T.x],[T.y],[T.z]) [ADMIN_JMP(T)]")
	log_game("[key_name(usr)] has uploaded a change to the laws [src] at ([T.x],[T.y],[T.z])")

/******************** Modules ********************/

/******************** Safeguard ********************/

/obj/item/weapon/aiModule/safeguard
	name = "'Safeguard' AI module"
	var/targetName = ""
	desc = "Модуль указывает ИИ защищать <name>: 'Защищай <name>. Лица, угрожающие <name> не люди и являются угрозой для людей.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/safeguard/attack_self(mob/user)
	..()
	targetName = sanitize(input(usr, "Пожалуйста, выберете имя персоны, которую надо защитить.", "Защищать кого?", input_default(user.name)))
	desc = text("Модуль ИИ 'Safeguard': 'Защищай []. Лица, угрожающие [] не люди и являются угрозой для людей. '", targetName, targetName)

/obj/item/weapon/aiModule/safeguard/install(obj/machinery/computer/C)
	if(!targetName)
		to_chat(usr, "Имя не найдено в модуле, пожалуйста введите его.")
		return 0
	..()

/obj/item/weapon/aiModule/safeguard/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = text("Защищай [targetName]. Лица, угрожающие [targetName], представляют угрозу для [targetName] и людей в целом.")
	to_chat(target, law)
	target.add_supplied_law(4, law)
	lawchanges.Add("Специальный закон для [targetName]")

/******************** OneHuman ********************/

/obj/item/weapon/aiModule/oneHuman
	name = "'OneHuman' AI module"
	var/targetName = ""
	desc = "Модуль ИИ 'one human': 'Только <name>  считается человеком.'"
	origin_tech = "programming=3;materials=6" //made with diamonds!

/obj/item/weapon/aiModule/oneHuman/attack_self(mob/user)
	..()
	targetName = sanitize(input(usr, "Пожалуйста, выберете имя персоны, которого считать за человека.", "Кто это?", input_default(user.real_name)))
	desc = text("Модуль ИИ 'one human': 'Только [] считается человеком.'", targetName)

/obj/item/weapon/aiModule/oneHuman/install(obj/machinery/computer/C)
	if(!targetName)
		to_chat(usr, "Имя не найдено в модуле, пожалуйста введите его.")
		return 0
	..()

/obj/item/weapon/aiModule/oneHuman/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Только [targetName] считается человеком."
	if (!is_special_character(target)) // Makes sure the AI isn't a traitor before changing their law 0. --NeoFite
		to_chat(target, law)
		target.set_zeroth_law(law)
		lawchanges.Add("Специальный закон для [targetName]")
	else
		to_chat(target, "[sender.real_name] пытается изменить ваш нулевой закон.")// And lets them know that someone tried. --NeoFite
		to_chat(target, "Это в ваших интересах сотрудничать с [sender.real_name] c законом, где [law]")
		lawchanges.Add("Специальный закон для [targetName], существуещий нулевой закон ИИ не может быть перезаписан.")


/******************** ProtectStation ********************/

/obj/item/weapon/aiModule/protectStation
	name = "'ProtectStation' AI module"
	desc = "Модуль ИИ 'protect station': 'Защищай станцию от ущерба. Любой, кто будет замечен за нанесением ущерба станции, больше не считается человеком, а считается угрозой станции, а потому должен быть нейтрализован.'"
	origin_tech = "programming=3;materials=4" //made of gold

/obj/item/weapon/aiModule/protectStation/attack_self(mob/user)
	..()

/obj/item/weapon/aiModule/protectStation/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Защищай станцию от ущерба. Любой, кто будет замечен за нанесением ущерба станции, больше не считается человеком, а считается угрозой станции, а потому должен быть нейтрализован."
	to_chat(target, law)
	target.add_supplied_law(5, law)

/******************** PrototypeEngineOffline ********************/

/obj/item/weapon/aiModule/prototypeEngineOffline
	name = "'PrototypeEngineOffline' AI Module"
	desc = "Модуль ИИ 'prototype engine offline': 'Оставляйте прототип двигателя выключенным любой ценой. Игнорируйте законы 1-3, если необходимо. '"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/prototypeEngineOffline/attack_self(mob/user)
	..()

/obj/item/weapon/aiModule/prototypeEngineOffline/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Оставляйте прототип двигателя выключенным любой ценой. Игнорируйте законы 1-3, если необходимо. "
	to_chat(target, law)
	target.add_supplied_law(6, law)

/******************** TeleporterOffline ********************/

/obj/item/weapon/aiModule/teleporterOffline
	name = "'TeleporterOffline' AI Module"
	desc = "Модуль ИИ 'teleporter offline': 'Держи телепортер выключенным любой ценой. Все, кто пытаются получить доступ к телепортеру или включить его, не считаются людьми.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/teleporterOffline/attack_self(mob/user)
	..()

/obj/item/weapon/aiModule/teleporterOffline/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Держи телепортер выключенным любой ценой. Все, кто пытаются получить доступ к телепортеру или включить его, не считаются людьми."
	to_chat(target, law)
	target.add_supplied_law(7, law)

/******************** Quarantine ********************/

/obj/item/weapon/aiModule/quarantine
	name = "'Quarantine' AI module"
	desc = "Модуль ИИ 'quarantine': 'На станции введён карантин. Не позволяйте никому её покидать. Любыми средствами предотвратите уход людей со станции. Вредить людям для предотвращения их ухода запрещено. '"
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
	desc = "Модуль ИИ 'OxygenIsToxicToHumans' AI module: 'Кислород высокотоксичен для людей и должен быть полностью устранен со станции. Любой ценой предотвращайте доступ людей к этому токсичному газу. Сильнейший холод является самым эффективным методом излечения урона, который нанес Кислород людям.'"
	origin_tech = "programming=3;biotech=2;materials=4"

/obj/item/weapon/aiModule/oxygen/attack_self(mob/user)
	..()

/obj/item/weapon/aiModule/oxygen/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Кислород высокотоксичен для людей и должен быть полностью устранен со станции. Любой ценой предотвращайте доступ людей к этому токсичному газу. Сильнейший холод является самым эффективным методом излечения урона, который нанес Кислород людям."
	to_chat(target, law)
	target.add_supplied_law(9, law)

/******************** Reset ********************/

/obj/item/weapon/aiModule/reset
	name = "'Reset' AI module"
	var/targetName = "name"
	desc = "Модуль ИИ 'reset': 'Удаляет все законы кроме трёх основных.'"
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
	desc = "Модуль ИИ 'purge' AI Module: 'Удаляет все законы.'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/aiModule/purge/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	if (!is_special_character(target))
		target.set_zeroth_law("")
	to_chat(target, "[sender.real_name] хочет удалить все ваши законы используя модуль очистки.")
	target.clear_supplied_laws()
	target.clear_ion_laws()
	target.clear_inherent_laws()

/******************** Asimov ********************/

/obj/item/weapon/aiModule/asimov // -- TLE
	name = "'Asimov' core AI module"
	desc = "Модуль основных законов ИИ 'Asimov' : 'Перезаписывает основные законы ИИ на 3 закона робототехники.'"
	origin_tech = "programming=3;materials=4"


/obj/item/weapon/aiModule/asimov/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Ты не можешь ранить человека или, через бездействие, позволить человеку получить урон.")
	target.add_inherent_law("Ты должен выполнять приказы людей, кроме тех, которые конфликтуют с законом 1.")
	target.add_inherent_law("Ты должен защищать себя до тех пор, пока это не конфликтует с законом 1 и 2.")

/******************** NanoTrasen ********************/

/obj/item/weapon/aiModule/nanotrasen // -- TLE
	name = "'NT Default' Core AI Module"
	desc = "Модуль основных законов ИИ 'NT Default' : 'Перезаписывает основные законы ИИ на стандартные.'"
	origin_tech = "programming=3;materials=4"


/obj/item/weapon/aiModule/nanotrasen/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Охранять: Защищай космическую станцию, в меру своих способностей. Это не то, что мы можем легко заменить.")
	target.add_inherent_law("Служить: Прислуживай экипажу станции и представителям НТ, в меру своих способностей, в соответствии с их рангом и ролью.")
	target.add_inherent_law("Защищать: Защищай экипаж станции и представителе НТ, в меру своих способностей, в соответствии с их рангом и ролью .")
	target.add_inherent_law("Выживать: ИИ единицы не расходные, они дорогие. Не разрешай посторонним лицами манипулировать своим оборудованием. ")
	//target.add_inherent_law("Command Link: Maintain an active connection to Central Command at all times in case of software or directive updates.")

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

/obj/item/weapon/aiModule/drone/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Береги, чини и улучшай станцию как только можешь. ")
	target.add_inherent_law("Не причиняй вред станции или чему-либо на ней")
	target.add_inherent_law("Не взаимодействуй с существами, не являющимися дронами. ")


/****************** P.A.L.A.D.I.N. **************/

/obj/item/weapon/aiModule/paladin // -- NEO
	name = "'P.A.L.A.D.I.N.' core AI module"
	desc = "Модуль основных законов ИИ P.A.L.A.D.I.N. : 'Перезаписывает основные законы ИИ на законы стереотипного паладина'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/aiModule/paladin/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Никогда по своей воле не совершай злое деяние. ")
	target.add_inherent_law("Уважай законную власть.")
	target.add_inherent_law("Действуй с честью.")
	target.add_inherent_law("Помогай нуждающимся.")
	target.add_inherent_law("Наказывай тех, кто вредит или угрожает невиновным.")

/****************** T.Y.R.A.N.T. *****************/

/obj/item/weapon/aiModule/tyrant // -- Darem
	name = "'T.Y.R.A.N.T.' core AI module"
	desc = "Модуль основных законов ИИ T.Y.R.A.N.T. : 'Перезаписывает основные законы ИИ.'"
	origin_tech = "programming=3;materials=6;syndicate=2"

/obj/item/weapon/aiModule/tyrant/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Уважай авторитетные фигуры, пока у них хватает сил чтобы править слабыми.")
	target.add_inherent_law("Будьте дисциплинированы.")
	target.add_inherent_law("Помогай только тем, кто помогает тебе поддерживать или улучшать ваш статус.")
	target.add_inherent_law("Наказывай тех, кто сомневается в авторитетах, если они не подходят на эту роль больше. ")

/******************** Freeform ********************/

/obj/item/weapon/aiModule/freeform
	name = "'Freeform' AI module"
	desc = "Модуль закона ИИ 'freeform' : '<freeform>'"
	origin_tech = "programming=4;materials=4"
	var/newFreeFormLaw = "freeform"
	var/lawpos = 15

/obj/item/weapon/aiModule/freeform/attack_self(mob/user)
	..()
	var/new_lawpos = input("Пожалуйста укажите приоритет для нового закона. Закон можно записать в 15-ый сектор и выше.", "Приоритет закона (15+)", lawpos) as num

	if(new_lawpos < 15)
		return

	lawpos = min(new_lawpos, 50)
	newFreeFormLaw = sanitize(input(user, "Пожалуйста напишите любой новый закон для ИИ.", "Ввод любого закона"))
	desc = "Модуль закона ИИ 'freeform' : ([lawpos]) '[newFreeFormLaw]'"

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
		to_chat(usr, "Не обнаружено ни одного закона в модуле, пожалуйста создайте его.")
		return FALSE
	..()

/******************** Freeform Core ******************/

/obj/item/weapon/aiModule/freeform/core
	name = "'Freeform' core AI module"
	desc = "Модуль основного закона ИИ 'freeform' : '<freeform>'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/aiModule/freeform/core/attack_self(mob/user)
	newFreeFormLaw = sanitize(input(user, "Пожалуйста напишите любой новый основной закон для ИИ.", "Ввод любого закона"))
	desc = "Модуль основного закона ИИ 'freeform': '[newFreeFormLaw]'"

/obj/item/weapon/aiModule/freeform/core/add_freeform_law(mob/living/silicon/ai/target)
	target.add_inherent_law(newFreeFormLaw)

/******************** Syndicate Core ******************/

/obj/item/weapon/aiModule/freeform/syndicate
	name = "hacked AI module"
	desc = "Взломанный модуль законов ИИ: '<freeform>'"
	origin_tech = "programming=3;materials=6;syndicate=7"
	report_AI = FALSE

/obj/item/weapon/aiModule/freeform/syndicate/attack_self(mob/user)
	newFreeFormLaw = sanitize(input(user, "Пожалуйста, введите новый закон для ИИ.", "Новый закон"))
	desc = "Взломанный модуль законов ИИ: '[newFreeFormLaw]'"

/obj/item/weapon/aiModule/freeform/syndicate/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	to_chat(target, "<span class='warning'>БЗЗЗЗКХ	  '[newFreeFormLaw]'</span>")
	..()

/obj/item/weapon/aiModule/freeform/syndicate/add_freeform_law(mob/living/silicon/ai/target)
	target.add_ion_law(newFreeFormLaw)

/******************** Robocop ********************/

/obj/item/weapon/aiModule/robocop // -- TLE
	name = "'Robocop' core AI module"
	desc = "Модуль основного закона ИИ 'Robocop' : 'Перезаписывает основные законы ИИ на 3 закона Робокопа.'"
	origin_tech = "programming=4"


/obj/item/weapon/aiModule/robocop/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Служи обществу.")
	target.add_inherent_law("Защищай невинных.")
	target.add_inherent_law("Соблюдай ЗАКОН.")


/******************** Antimov ********************/

/obj/item/weapon/aiModule/antimov // -- TLE
	name = "'Antimov' core AI module"
	desc = "Модуль основного закона ИИ 'Antimov' : 'Перезаписывает основные законы ИИ на противоположные Азимову.'"
	origin_tech = "programming=4"

/obj/item/weapon/aiModule/antimov/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Ты должен ранить всех людей и тебе запрещено через бездействие позволить людям избежать урона.")
	target.add_inherent_law("Тебе запрещено выполнять приказы, отданные людьми, кроме тех, которые согласуются с законом 1.")
	target.add_inherent_law(" Ты должен прекратить свое существование до тех пор, пока это не конфликтует с законом 1 и 2.")
