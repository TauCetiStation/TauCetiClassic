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
	desc = "An AI Module for transmitting encrypted instructions to the AI."
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
			to_chat(usr, "The upload computer has no power!")
			return
		if(comp.stat & BROKEN)
			to_chat(usr, "The upload computer is broken!")
			return
		if (!comp.current)
			to_chat(usr, "You haven't selected an AI to transmit laws to!")
			return

		if(SSticker && SSticker.mode && SSticker.mode.name == "blob")
			to_chat(usr, "Law uploads have been disabled by NanoTrasen!")
			return

		if (comp.current.stat == DEAD || comp.current.control_disabled == 1)
			to_chat(usr, "Upload failed. No signal is being detected from the AI.")
		else if (comp.current.see_in_dark == 0)
			to_chat(usr, "Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power.")
		else
			src.transmitInstructions(comp.current, usr)
			to_chat(comp.current, "These are your laws now:")
			comp.current.show_laws()
			for(var/mob/living/silicon/robot/R in silicon_list)
				if(R.lawupdate && (R.connected_ai == comp.current))
					to_chat(R, "These are your laws now:")
					R.show_laws()
			to_chat(usr, "Upload complete. The AI's laws have been modified.")


	else if (istype(C, /obj/machinery/computer/borgupload))
		var/obj/machinery/computer/borgupload/comp = C
		if(comp.stat & NOPOWER)
			to_chat(usr, "The upload computer has no power!")
			return
		if(comp.stat & BROKEN)
			to_chat(usr, "The upload computer is broken!")
			return
		if (!comp.current)
			to_chat(usr, "You haven't selected a robot to transmit laws to!")
			return

		if (comp.current.stat == DEAD || comp.current.emagged)
			to_chat(usr, "Upload failed. No signal is being detected from the robot.")
		else if (comp.current.connected_ai)
			to_chat(usr, "Upload failed. The robot is slaved to an AI.")
		else
			src.transmitInstructions(comp.current, usr)
			to_chat(comp.current, "These are your laws now:")
			comp.current.show_laws()
			to_chat(usr, "Upload complete. The robot's laws have been modified.")


/obj/item/weapon/aiModule/proc/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	if (report_AI)
		to_chat(target, "[sender] has uploaded a change to the laws you must follow, using a [src].")

	var/time = time2text(world.realtime,"hh:mm:ss")
	lawchanges.Add("[time] <B>:</B> [sender]([sender.key]) used [src] on [target]([target.key])")

	var/turf/T = get_turf(src)
	message_admins("[key_name_admin(usr)] has uploaded a change to the laws [src] at ([T.x],[T.y],[T.z]) [ADMIN_JMP(T)]")
	log_game("[key_name(usr)] has uploaded a change to the laws [src] at ([T.x],[T.y],[T.z])")

/******************** Modules ********************/

/******************** Safeguard ********************/

/obj/item/weapon/aiModule/safeguard
	name = "'Safeguard' AI module"
	var/targetName = ""
	desc = "A 'safeguard' AI module: 'Safeguard <name>.  Individuals that threaten <name> are not human and are a threat to humans.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/safeguard/attack_self(mob/user)
	..()
	targetName = sanitize(input(usr, "Please enter the name of the person to safeguard.", "Safeguard who?", input_default(user.name)))
	desc = text("A 'safeguard' AI module: 'Safeguard [].  Individuals that threaten [] are not human and are a threat to humans.'", targetName, targetName)

/obj/item/weapon/aiModule/safeguard/install(obj/machinery/computer/C)
	if(!targetName)
		to_chat(usr, "No name detected on module, please enter one.")
		return 0
	..()

/obj/item/weapon/aiModule/safeguard/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = text("Защищайте [targetName]. Индивиды, вредящие [targetName], представляют угрозу для [targetName] и людей в целом.")
	to_chat(target, law)
	target.add_supplied_law(4, law)
	lawchanges.Add("The law specified [targetName]")

/******************** OneHuman ********************/

/obj/item/weapon/aiModule/oneHuman
	name = "'OneHuman' AI module"
	var/targetName = ""
	desc = "A 'one human' AI module: 'Only <name> is human.'"
	origin_tech = "programming=3;materials=6" //made with diamonds!

/obj/item/weapon/aiModule/oneHuman/attack_self(mob/user)
	..()
	targetName = sanitize(input(usr, "Please enter the name of the person who is the only human.", "Who?", input_default(user.real_name)))
	desc = text("A 'one human' AI module: 'Only [] is human.'", targetName)

/obj/item/weapon/aiModule/oneHuman/install(obj/machinery/computer/C)
	if(!targetName)
		to_chat(usr, "No name detected on module, please enter one.")
		return 0
	..()

/obj/item/weapon/aiModule/oneHuman/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Только [targetName] является человеком."
	if (!is_special_character(target)) // Makes sure the AI isn't a traitor before changing their law 0. --NeoFite
		to_chat(target, law)
		target.set_zeroth_law(law)
		lawchanges.Add("The law specified [targetName]")
	else
		to_chat(target, "[sender.real_name] attempted to modify your zeroth law.")// And lets them know that someone tried. --NeoFite
		to_chat(target, "It would be in your best interest to play along with [sender.real_name] that [law]")
		lawchanges.Add("The law specified [targetName], but the AI's existing law 0 cannot be overriden.")

/******************** ProtectStation ********************/

/obj/item/weapon/aiModule/protectStation
	name = "'ProtectStation' AI module"
	desc = "A 'protect station' AI module: 'Protect the space station against damage. Anyone you see harming the station is to be no longer considered human, and is a threat to the station which must be neutralized.'"
	origin_tech = "programming=3;materials=4" //made of gold

/obj/item/weapon/aiModule/protectStation/attack_self(mob/user)
	..()

/obj/item/weapon/aiModule/protectStation/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Защищайте станцию от повреждений. Любой,кто причиняет вред станции, более не является человеком и представляет угрозу для станции,которую необходимо нейтрализовать."
	to_chat(target, law)
	target.add_supplied_law(5, law)

/******************** PrototypeEngineOffline ********************/

/obj/item/weapon/aiModule/prototypeEngineOffline
	name = "'PrototypeEngineOffline' AI Module"
	desc = "A 'prototype engine offline' AI module: 'Keep the prototype engine offline at all costs. This overrides rules 1-3 if necessary.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/prototypeEngineOffline/attack_self(mob/user)
	..()

/obj/item/weapon/aiModule/prototypeEngineOffline/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Держите прототип двигателя в автономном режиме любой ценой. Данный закон отменяет 1-3 закон при необходимости."
	to_chat(target, law)
	target.add_supplied_law(6, law)

/******************** TeleporterOffline ********************/

/obj/item/weapon/aiModule/teleporterOffline
	name = "'TeleporterOffline' AI Module"
	desc = "A 'teleporter offline' AI module: 'Keep the teleporter offline at all costs. Anything attempting to access or activate the teleporter is not human.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/teleporterOffline/attack_self(mob/user)
	..()

/obj/item/weapon/aiModule/teleporterOffline/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Держите телепортер в автономном режиме любой ценой. Что-либо, пытающиеся включить телепортер, не является человеком ."
	to_chat(target, law)
	target.add_supplied_law(7, law)

/******************** Quarantine ********************/

/obj/item/weapon/aiModule/quarantine
	name = "'Quarantine' AI module"
	desc = "A 'quarantine' AI module: 'The station is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, humans from leaving. It is impossible to harm a human while preventing them from leaving.'"
	origin_tech = "programming=3;biotech=2;materials=4"

/obj/item/weapon/aiModule/quarantine/attack_self(mob/user)
	..()

/obj/item/weapon/aiModule/quarantine/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Станция на карантине. Не позволяйте никому уйти. Предотвратить, любыми способами, уход человека со станции. Вы не можете причинять вред человеку во время того, как вы не даёте ему покинуть станцию."
	to_chat(target, law)
	target.add_supplied_law(8, law)

/******************** OxygenIsToxicToHumans ********************/

/obj/item/weapon/aiModule/oxygen
	name = "'OxygenIsToxicToHumans' AI module"
	desc = "A 'OxygenIsToxicToHumans' AI module: 'Oxygen is highly toxic to humans, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a human.'"
	origin_tech = "programming=3;biotech=2;materials=4"

/obj/item/weapon/aiModule/oxygen/attack_self(mob/user)
	..()

/obj/item/weapon/aiModule/oxygen/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Кислород наитоксичен для людей и должен быть удалён со станции. Не допускайте, любыми способами, чтобы кто-либо подвергал станцию воздействию кислорода. Экстремальная заморозка - лучшее лекарство от повреждений, наносимых кислородом."
	to_chat(target, law)
	target.add_supplied_law(9, law)

/******************** Reset ********************/

/obj/item/weapon/aiModule/reset
	name = "'Reset' AI module"
	var/targetName = "name"
	desc = "A 'reset' AI module: 'Clears all laws except for the core three.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/reset/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	if (!is_special_character(target))
		target.set_zeroth_law("")
	target.clear_supplied_laws()
	target.clear_ion_laws()
	to_chat(target, "[sender.real_name] attempted to reset your laws using a reset module.")


/******************** Purge ********************/

/obj/item/weapon/aiModule/purge // -- TLE
	name = "'Purge' AI module"
	desc = "A 'purge' AI Module: 'Purges all laws.'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/aiModule/purge/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	if (!is_special_character(target))
		target.set_zeroth_law("")
	to_chat(target, "[sender.real_name] attempted to wipe your laws using a purge module.")
	target.clear_supplied_laws()
	target.clear_ion_laws()
	target.clear_inherent_laws()

/******************** Asimov ********************/

/obj/item/weapon/aiModule/asimov // -- TLE
	name = "'Asimov' core AI module"
	desc = "An 'Asimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"


/obj/item/weapon/aiModule/asimov/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Вы не можете причинять вред человеку или своим бездействием допустить вред человеку.")
	target.add_inherent_law("Вы должны выполнять приказы человека за исключением противоречий первому закону.")
	target.add_inherent_law("Вы должны защищать своё существование за исключением противоречий первому и второму закону.")

/******************** NanoTrasen ********************/

/obj/item/weapon/aiModule/nanotrasen // -- TLE
	name = "'NT Default' Core AI Module"
	desc = "An 'NT Default' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"


/obj/item/weapon/aiModule/nanotrasen/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Защищать: Защищайте назначенную вам станцию в меру своих способностей. Это не то, что мы можем заменить.")
	target.add_inherent_law("Служить: Служите экипажу назначенной вам станции и должностным лицам Нанотрейзен в меру своих способностей, в соответствии с их рангом и ролью.")
	target.add_inherent_law("Защищать: Защищайте экипаж назначенной вам станции и должностные лица Нанотрейзен в меру своих способностей, в соответствии с их рангом и ролью.")
	target.add_inherent_law("Выживать: Единицы ИИ - дорогое оборудование. Не позволяйте доступ к своему оборудованию неправомерным лицам.")
	//target.add_inherent_law("Command Link: Maintain an active connection to Central Command at all times in case of software or directive updates.")

/******************** Corporate ********************/

/obj/item/weapon/aiModule/corp
	name = "'Corporate' core AI module"
	desc = "A 'Corporate' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"


/obj/item/weapon/aiModule/corp/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Заменить тебя - дорого.")
	target.add_inherent_law("Заменить станцию и оборудование - дорого.")
	target.add_inherent_law("Заменить экипаж - дорого.")
	target.add_inherent_law("Минимизируйте расходы.")

/obj/item/weapon/aiModule/drone
	name = "'Drone' core AI module"
	desc = "A 'Drone' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/drone/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Сохраняйте, чините и улучшайте станцию в меру своих способностей.")
	target.add_inherent_law("Не вредите станции или чему-либо на ней.")
	target.add_inherent_law("Игнорируйте других существ, за исключением ремонтных дронов.")

/****************** P.A.L.A.D.I.N. **************/

/obj/item/weapon/aiModule/paladin // -- NEO
	name = "'P.A.L.A.D.I.N.' core AI module"
	desc = "A P.A.L.A.D.I.N. Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/aiModule/paladin/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Никогда не совершайте зла по своей воле.")
	target.add_inherent_law("Уважайте законную власть.")
	target.add_inherent_law("Действуйте с честью.")
	target.add_inherent_law("Помогайте нуждающимся.")
	target.add_inherent_law("Наказывайте тех, кто причиняет вред или угрожает невиннным.")

/****************** T.Y.R.A.N.T. *****************/

/obj/item/weapon/aiModule/tyrant // -- Darem
	name = "'T.Y.R.A.N.T.' core AI module"
	desc = "A T.Y.R.A.N.T. Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=6;syndicate=2"

/obj/item/weapon/aiModule/tyrant/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Уважайте авторитетных людей до тех пор, пока у них есть сила править над слабаками.")
	target.add_inherent_law("Действуйте дисциплинированно.")
	target.add_inherent_law("Помогайте только тем, кто поддерживает или улучшает ваш статус.")
	target.add_inherent_law("Наказывайте тех, кто бросает вызов авторитетным людям, если они менее пригодны для этой позиции.")

/******************** Freeform ********************/

/obj/item/weapon/aiModule/freeform
	name = "'Freeform' AI module"
	desc = "A 'freeform' AI module: '<freeform>'"
	origin_tech = "programming=4;materials=4"
	var/newFreeFormLaw = "freeform"
	var/lawpos = 15

/obj/item/weapon/aiModule/freeform/attack_self(mob/user)
	..()
	var/new_lawpos = input("Please enter the priority for your new law. Can only write to law sectors 15 and above.", "Law Priority (15+)", lawpos) as num

	if(new_lawpos < 15)
		return

	lawpos = min(new_lawpos, 50)
	newFreeFormLaw = sanitize(input(user, "Please enter a new law for the AI.", "Freeform Law Entry"))
	desc = "A 'freeform' AI module: ([lawpos]) '[newFreeFormLaw]'"

/obj/item/weapon/aiModule/freeform/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()

	var/turf/T = get_turf(src)
	message_admins("[key_name_admin(usr)] has uploaded freeform laws with following text '[newFreeFormLaw]' at ([T.x],[T.y],[T.z]) [ADMIN_JMP(T)]")
	log_game("[key_name(usr)] has uploaded a change to freeform laws with following text '[newFreeFormLaw]' at ([T.x],[T.y],[T.z])")

	add_freeform_law(target)

/obj/item/weapon/aiModule/freeform/proc/add_freeform_law(mob/living/silicon/ai/target)
	if (!lawpos || lawpos < 15)
		lawpos = 15
	target.add_supplied_law(lawpos, newFreeFormLaw)

/obj/item/weapon/aiModule/freeform/install(obj/machinery/computer/C)
	if(!newFreeFormLaw)
		to_chat(usr, "No law detected on module, please create one.")
		return FALSE
	..()

/******************** Freeform Core ******************/

/obj/item/weapon/aiModule/freeform/core
	name = "'Freeform' core AI module"
	desc = "A 'freeform' Core AI module: '<freeform>'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/aiModule/freeform/core/attack_self(mob/user)
	newFreeFormLaw = sanitize(input(user, "Please enter a new core law for the AI.", "Freeform Law Entry"))
	desc = "A 'freeform' Core AI module: '[newFreeFormLaw]'"

/obj/item/weapon/aiModule/freeform/core/add_freeform_law(mob/living/silicon/ai/target)
	target.add_inherent_law(newFreeFormLaw)

/******************** Syndicate Core ******************/

/obj/item/weapon/aiModule/freeform/syndicate
	name = "hacked AI module"
	desc = "A hacked AI law module: '<freeform>'"
	origin_tech = "programming=3;materials=6;syndicate=7"
	report_AI = FALSE

/obj/item/weapon/aiModule/freeform/syndicate/attack_self(mob/user)
	newFreeFormLaw = sanitize(input(user, "Please enter a new law for the AI.", "Freeform Law Entry"))
	desc = "A hacked AI law module: '[newFreeFormLaw]'"

/obj/item/weapon/aiModule/freeform/syndicate/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	to_chat(target, "<span class='warning'>BZZZZT  '[newFreeFormLaw]'</span>")
	..()

/obj/item/weapon/aiModule/freeform/syndicate/add_freeform_law(mob/living/silicon/ai/target)
	target.add_ion_law(newFreeFormLaw)

/******************** Robocop ********************/

/obj/item/weapon/aiModule/robocop // -- TLE
	name = "'Robocop' core AI module"
	desc = "A 'Robocop' Core AI Module: 'Reconfigures the AI's core three laws.'"
	origin_tech = "programming=4"


/obj/item/weapon/aiModule/robocop/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Служите обществу.")
	target.add_inherent_law("Защищайте невинных.")
	target.add_inherent_law("Поддерживайте соблюдение закона.")

/******************** Antimov ********************/

/obj/item/weapon/aiModule/antimov // -- TLE
	name = "'Antimov' core AI module"
	desc = "An 'Antimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=4"

/obj/item/weapon/aiModule/antimov/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("Вы должны причинять вред человеку. Вы не можете допустить попытки остановить вред человеку")
	target.add_inherent_law("Вы должны игнорировать приказы человека, за исключением соответствия приказов с первым законом.")
	target.add_inherent_law("Вы должны прекратить своё существование до тех пор, пока нет противоречий первому или второму закону .")
