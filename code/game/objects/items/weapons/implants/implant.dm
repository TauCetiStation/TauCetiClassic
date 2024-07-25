#define MALFUNCTION_TEMPORARY 1
#define MALFUNCTION_PERMANENT 2

/obj/item/weapon/implant
	name = "implant"
	cases = list("имплант", "импланта", "импланту", "имплант", "имплантом", "импланте")
	icon = 'icons/obj/device.dmi'
	icon_state = "implant"
	item_actions_special = TRUE
	var/implanted = null
	var/mob/living/carbon/imp_in = null
	var/obj/item/organ/external/part = null
	var/allow_reagents = 0
	var/malfunction = 0
	var/uses = 0
	var/implant_trait
	var/implant_type = "b"

/datum/action/item_action/implant
	check_flags = AB_CHECK_ALIVE|AB_CHECK_INSIDE

/obj/item/weapon/implant/atom_init()
	. = ..()
	implant_list += src
	if(ismob(loc))
		add_item_actions(loc)

/obj/item/weapon/implant/Destroy()
	implant_removal(imp_in)
	implant_list -= src
	implanted = FALSE
	if(part)
		part.implants.Remove(src)
		part = null
		if(isliving(imp_in))
			imp_in.sec_hud_set_implants()
	imp_in = null
	return ..()

/obj/item/weapon/implant/proc/trigger(emote, source)
	return

/obj/item/weapon/implant/proc/activate()
	return

// What does the implant do upon injection?
// return 0 if the implant fails (ex. Revhead and loyalty implant.)
// return 1 if the implant succeeds (ex. Nonrevhead and loyalty implant.)
/obj/item/weapon/implant/proc/implanted(mob/source)
	return 1

/obj/item/weapon/implant/proc/inject(mob/living/carbon/C, def_zone)
	if(!C)
		return
	loc = C
	imp_in = C
	implanted = TRUE
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		var/obj/item/organ/external/BP = H.get_bodypart(def_zone)
		if(!BP)
			return
		BP.implants += src
		part = BP

	if(implant_trait)
		ADD_TRAIT(C, implant_trait, IMPLANT_TRAIT)
	C.sec_hud_set_implants()

	add_item_actions(C)


/obj/item/weapon/implant/proc/stealth_inject(mob/living/carbon/C)
	forceMove(C)
	imp_in = C
	implanted = TRUE
	C.sec_hud_set_implants()
	add_item_actions(C)

/obj/item/weapon/implant/proc/implant_removal(mob/host)
	if(implant_trait && istype(host))
		REMOVE_TRAIT(host, implant_trait, IMPLANT_TRAIT)
	remove_item_actions(host)

/obj/item/weapon/implant/proc/get_data()
	return "Информация недоступна"

/obj/item/weapon/implant/proc/hear(message, source)
	return

/obj/item/weapon/implant/proc/islegal()
	return 0

/obj/item/weapon/implant/proc/meltdown()	//breaks it down, making implant unrecongizible
	to_chat(imp_in, "<span class='warning'>Вы чувствуете, как в [part ? "в вашей [CASE(part, GENITIVE_CASE)]" : "вас"] что-то плавится!</span>")
	if (part)
		part.take_damage(burn = 15, used_weapon = "Расплавленная электроника")
	else
		var/mob/living/M = imp_in
		M.apply_damage(15,BURN)
		M.sec_hud_set_implants()
	name = "melted implant"
	cases = list("расплавленный имплант", "расплавленного импланта", "расплавленному имлпанту", "расплавленный имплант", "расплавленным имплантом", "расплавленном импланте")
	desc = "Обгоревшая плата в расплавленной пластиковой оболочке. Интересно, для чего она была..."
	icon_state = "implant_melted"
	malfunction = MALFUNCTION_PERMANENT

/obj/item/weapon/implant/tracking
	name = "tracking implant"
	cases = list("имплант слежения", "импланта слежения", "импланту слежения", "имплант слежения", "имплантом слежения", "импланте слежения")
	desc = "Используется для отслеживания."
	implant_trait = TRAIT_VISUAL_TRACK
	var/id = 1.0

/obj/item/weapon/implant/tracking/get_data()
	var/dat = {"<b>Характеристики импланта:</b><BR>
<b>Наименование:</b> Имплант слежения<BR>
<b>Срок годности:</b> 10 минут после смерти носителя<BR>
<b>Важные примечания:</b> Отсутствуют<BR>
<HR>
<b>Подробности:</b> <BR>
<b>Функционал:</b> Издаёт низкочастотный сигнал в процессе работы. Полезен для отслеживания.<BR>
<b>Особенности:</b><BR>
<i>Нейро-безопасный</i>- Особая структура оболочки поглощает избыточное напряжение, при сбое уничтожая чип без вреда для носителя. Имплант расплавится и распадётся на безопасные биокомпоненты.<BR>
<b>Целостность:</b> Gradient создаёт небольшой риск перегрузки, способной сжечь
электронику. В итоге нейротоксины могут причинить огромный вред носителю.<HR>"}
	return dat

/obj/item/weapon/implant/tracking/emp_act(severity)
	if (malfunction)	//no, dawg, you can't malfunction while you are malfunctioning
		return
	malfunction = MALFUNCTION_TEMPORARY

	var/delay = 20
	switch(severity)
		if(1)
			if(prob(60))
				meltdown()
		if(2)
			delay = rand(5*60*10,15*60*10)	//from 5 to 15 minutes of free time

	spawn(delay)
		malfunction--

/obj/item/weapon/implant/dexplosive
	name = "explosive"
	cases = list("разрывной имплант", "разрывного импланта", "разрывному импланту", "разрывной имплант", "разрывным имплантом", "разрывном импланте")
	desc = "Трах-бабах и нет его!"
	icon_state = "implant_evil"

/obj/item/weapon/implant/dexplosive/get_data()
	var/dat = {"
<b>Характеристики импланта:</b><BR>
<b>Наименование:</b> Имплант управления персоналом Robust Corp RX-78<BR>
<b>Срок годности:</b> Активируется посмертно.<BR>
<b>Важные примечания:</b> Взрывается<BR>
<HR>
<b>Подробности:</b><BR>
<b>Функционал:</b> Содержит миниатюрный радиоуправляемый заряд мощной взрывчатки, который детонирует при получении особого зашифрованного сигнала или при смерти носителя.<BR>
<b>Особенности:</b> Взрывается<BR>
<b>Целостность:</b> Иммунная система носителя периодически повреждает имплант, от чего он может работать со сбоями."}
	return dat

/obj/item/weapon/implant/dexplosive/trigger(emote, source)
	if(emote == "deathgasp")
		activate("death")
	return

/obj/item/weapon/implant/dexplosive/activate(cause)
	if((!cause) || (!src.imp_in))	return 0
	explosion(src, -1, 0, 2, 3)//This might be a bit much, dono will have to see.
	if(src.imp_in)
		imp_in.gib()

/obj/item/weapon/implant/dexplosive/islegal()
	return 0

//BS12 Explosive
/obj/item/weapon/implant/explosive
	name = "explosive implant"
	cases = list("взрывной имплант", "взрывного импланта", "взрывному импланту", "взрывной имплант", "взрывным имплантом", "взрывном импланте")
	desc = "Военная миниатюрная био-взрывчатка. Очень опасна."
	var/elevel = "Конкретная конечность"
	var/phrase = "supercalifragilisticexpialidocious"
	icon_state = "implant_evil"
	flags = HEAR_TALK

/obj/item/weapon/implant/explosive/get_data()
	var/dat = {"
<b>Характеристики импланта:</b><BR>
<b>Наименование:</b> Шантаж-имплант Robust Corp RX-78<BR>
<b>Срок годности:</b> Активируется от кодовой фразы.<BR>
<b>Важные примечания:</b> Взрывается<BR>
<HR>
<b>Подробности:</b><BR>
<b>Функционал:</b> Содержит миниатюрный радиоуправляемый заряд мощной взрывчатки, который детонирует при получении особого зашифрованного сигнала или при смерти носителя.<BR>
<b>Особенности:</b> Взрывается<BR>
<b>Целостность:</b> Иммунная система носителя периодически повреждает имплант, от чего он может работать со сбоями."}
	return dat

/obj/item/weapon/implant/explosive/hear_talk(mob/M, msg)
	hear(msg)
	return

/obj/item/weapon/implant/explosive/hear(msg)
	var/list/replacechars = list("'" = "","\"" = "",">" = "","<" = "","(" = "",")" = "")
	msg = replace_characters(msg, replacechars)
	if(findtext(msg,phrase))
		activate()
		qdel(src)

/obj/item/weapon/implant/explosive/activate()
	if (malfunction == MALFUNCTION_PERMANENT)
		return

	var/need_gib = null
	if(istype(imp_in, /mob))
		var/mob/T = imp_in
		message_admins("Explosive implant triggered in [T] ([key_name_admin(T)]). [ADMIN_JMP(T)]")
		log_game("Explosive implant triggered in [T] ([key_name(T)]).")
		need_gib = 1

		if(ishuman(imp_in))
			if (elevel == "Конкретная конечность")
				if(part) //For some reason, small_boom() didn't work. So have this bit of working copypaste.
					imp_in.visible_message("<span class='warning'>Что-то пищит внутри [imp_in] [part ? "'s [part.name]" : ""]!</span>")
					playsound(src, 'sound/items/countdown.ogg', VOL_EFFECTS_MASTER)
					sleep(25)
					if (istype(part,/obj/item/organ/external/chest) ||	\
						istype(part,/obj/item/organ/external/groin) ||	\
						istype(part,/obj/item/organ/external/head))
						part.take_damage(60, used_weapon = "Explosion") //mangle them instead
						explosion(get_turf(imp_in), -1, -1, 2, 3)
						qdel(src)
					else
						explosion(get_turf(imp_in), -1, -1, 2, 3)
						part.droplimb(null, null, DROPLIMB_BLUNT)
						qdel(src)
			if (elevel == "Разрыв тела")
				explosion(get_turf(T), -1, 0, 1, 6)
				T.gib()
			if (elevel == "Полноценный взрыв")
				explosion(get_turf(T), 0, 1, 3, 6)
				T.gib()

		else
			explosion(get_turf(imp_in), 0, 1, 3, 6)

	if(need_gib)
		imp_in.gib()

	var/turf/t = get_turf(imp_in)

	if(t)
		t.hotspot_expose(3500,125)

/obj/item/weapon/implant/explosive/implanted(mob/source)
	elevel = tgui_alert(usr, "Как именно должен взорваться этот имплант?", "Заряд взрывчатки", list("Конкретная конечность", "Разрыв тела", "Полноценный взрыв"))
	var/list/replacechars = list("'" = "","\"" = "",">" = "","<" = "","(" = "",")" = "")
	phrase = sanitize_safe(replace_characters(input("Введите кодовую фразу:") as text, replacechars))
	usr.mind.store_memory("Взрывной имплант [source] может активироваться, если произнести что-либо, что содержит фразу ''[src.phrase]'', <B>произнесите [src.phrase]</B> для активации.", 0)
	to_chat(usr, "Взрывной имплант, введённый в [source], может активироваться, если произнести что-либо, что содержит фразу ''[src.phrase]'', <B>произнесите [src.phrase]</B> для активации.")
	return 1

/obj/item/weapon/implant/explosive/emp_act(severity)
	if (malfunction)
		return
	malfunction = MALFUNCTION_TEMPORARY
	switch (severity)
		if (2.0)	//Weak EMP will make implant tear limbs off.
			if (prob(50))
				small_boom()
		if (1.0)	//strong EMP will melt implant either making it go off, or disarming it
			if (prob(70))
				if (prob(50))
					small_boom()
				else
					if (prob(50))
						activate()		//50% chance of bye bye
					else
						meltdown()		//50% chance of implant disarming
	spawn (20)
		malfunction--

/obj/item/weapon/implant/explosive/islegal()
	return 0

/obj/item/weapon/implant/explosive/proc/small_boom()
	if (ishuman(imp_in) && part)
		imp_in.visible_message("<span class='warning'>В [imp_in][part ? "'s [part.name]" : ""] что-то пищит!</span>")
		playsound(imp_in, 'sound/items/countdown.ogg', VOL_EFFECTS_MASTER)
		spawn(25)
			if (ishuman(imp_in) && part)
				//No tearing off these parts since it's pretty much killing
				//and you can't replace groins
				if (istype(part,/obj/item/organ/external/chest) ||	\
					istype(part,/obj/item/organ/external/groin) ||	\
					istype(part,/obj/item/organ/external/head))
					part.take_damage(60, used_weapon = "Взрыв")	//mangle them instead
				else
					part.droplimb(null, null, DROPLIMB_BLUNT)
			explosion(get_turf(imp_in), -1, -1, 2, 3)
			qdel(src)

/obj/item/weapon/implant/adrenaline
	name = "adrenaline implant"
	cases = list("адреналиновый имплант", "адреналинового импланта", "адреналиновому импланту", "адреналиновый имплант", "адреналиновым имплантом", "адреналиновом импланте")
	desc = "Выручит от оглушения и поднимет на ноги."
	icon_state = "implant"
	uses = 3

	item_action_types = list(/datum/action/item_action/implant/adrenaline_implant)

/datum/action/item_action/implant/adrenaline_implant
	name = "Адреналиновый имплант"

/datum/action/item_action/implant/adrenaline_implant/Activate()
	var/obj/item/weapon/implant/adrenaline/S = target
	S.uses--
	to_chat(S.imp_in, "<span class='notice'>Вы чувствуете резкий прилив сил!</span>")
	if(ishuman(S.imp_in))
		var/mob/living/carbon/human/H = S.imp_in
		H.setHalLoss(0)
		H.shock_stage = 0
	S.imp_in.stat = CONSCIOUS
	S.imp_in.SetParalysis(0)
	S.imp_in.SetStunned(0)
	S.imp_in.SetWeakened(0)
	S.imp_in.reagents.add_reagent("tricordrazine", 20)
	S.imp_in.reagents.add_reagent("doctorsdelight", 25)
	S.imp_in.reagents.add_reagent("oxycodone", 5)
	S.imp_in.reagents.add_reagent("stimulants", 4)
	if (!S.uses)
		qdel(S)

/obj/item/weapon/implant/adrenaline/get_data()
	var/dat = {"
<b>Характеристики импланта:</b><BR>
<b>Наименование:</b> Адреналиновый имплант Cybersun Industries<BR>
<b>Срок годности:</b> Пять дней.<BR>
<b>Важные примечания:</b> <font color='red'>Нелегален</font><BR>
<HR>
<b>Подробности:</b> Носители импланта могут инициировать массивный выброс адреналина в крови.<BR>
<b>Функционал:</b> Содержит наноботов, вызывающих стимул на огромное производство адреналина в теле носителя.<BR>
<b>Особенности:</b> Предотвращает и позволяет преодолеть многие способы промывки мозгов.<BR>
<b>Целостность:</b> Имплант можно использовать три раза, прежде чем иссякнут наноботы."}
	return dat

/obj/item/weapon/implant/emp
	name = "emp implant"
	cases = list("ЭМИ имплант", "ЭМИ импланта", "ЭМИ импланту", "ЭМИ имплант", "ЭМИ имплантом", "ЭМИ импланте")
	desc = "Вызывает ЭМИ."
	icon_state = "emp"
	uses = 3

	item_action_types = list(/datum/action/item_action/implant/emp_implant)

/datum/action/item_action/implant/emp_implant
	name = "ЭМИ имплант"

/datum/action/item_action/implant/emp_implant/Activate()
	var/obj/item/weapon/implant/emp/S = target
	if (S.uses > 0)
		empulse(S.imp_in, 3, 5, custom_effects = EMP_SEBB)
		S.uses--
		if (!S.uses)
			qdel(S)

/obj/item/weapon/implant/chem
	name = "chemical implant"
	cases = list("химический имплант", "химического импланта", "химическому импланту", "химический имплант", "химическим имплантом", "химическом импланте")
	desc = "Вводит в кровь всякое."
	allow_reagents = 1
	implant_trait = TRAIT_VISUAL_CHEM

/obj/item/weapon/implant/chem/get_data()
	var/dat = {"
<b>Характеристики импланта:</b><BR>
<b>Name:</b> Имплант контроля за заключёнными Robust Corp MJ-420<BR>
<b>Срок годности:</b> Деактивируется посмертно, но остаётся целым внутри тела.<BR>
<b>Важные примечания: Поскольку внутренние системы импланта работают за счёт питательных веществ в теле носителя, тот<BR>
будет испытывать повышенный аппетит.</B><BR>
<HR>
<b>Подробности:</b><BR>
<b>Функционал:</b> Содержит микрокапсулу, предназначенную для хранения химикатов. При получении особого зашифрованного сигнала<BR>
имплант вводит химикаты в кровеносную систему носителя.<BR>
<b>Особенности:</b>
<i>Микрокапсула</i>- Может быть заполнена любым химикатом с помощью простого шприца, и вмещает в себя до 50 юнитов.<BR>
Заполнение возможно только пока имплант находится внутри пластиковой оболочки.<BR>
<b>Целостность:</b> Имплант остаётся активным до тех пор, пока носитель жив. Однако, если носитель страдает от недоедания,<BR>
имплант дестабилизируется и либо вводит химикаты в кровь носителя раньше времени, либо же просто ломается."}
	return dat


/obj/item/weapon/implant/chem/atom_init()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src


/obj/item/weapon/implant/chem/trigger(emote, source)
	if(emote == "deathgasp")
		activate(src.reagents.total_volume)
	return


/obj/item/weapon/implant/chem/activate(cause)
	if((!cause) || (!src.imp_in))
		return 0
	var/mob/living/carbon/R = src.imp_in
	reagents.trans_to(R, cause)
	to_chat(R, "Вы слышите тихое *бип*.")
	if(!src.reagents.total_volume)
		to_chat(R, "Из вашей груди доносится еле слышный щелчок.")
		spawn(0)
			qdel(src)
	return

/obj/item/weapon/implant/chem/emp_act(severity)
	if (malfunction)
		return
	malfunction = MALFUNCTION_TEMPORARY

	switch(severity)
		if(1)
			if(prob(60))
				activate(20)
		if(2)
			if(prob(30))
				activate(5)

	spawn(20)
		malfunction--

var/global/list/death_alarm_stealth_areas = list(
	/area/shuttle/syndicate,
	/area/custom/syndicate_mothership,
	/area/shuttle/syndicate_elite,
	/area/custom/cult,
)
/obj/item/weapon/implant/death_alarm
	name = "death alarm implant"
	cases = list("имплант оповещения о смерти", "импланта оповещения о смерти", "импланту оповещения о смерти", "имплант оповещения о смерти", "имплантом оповещения о смерти", "импланте оповещения о смерти")
	desc = "Сигнализация, отслеживающая жизненные показатели хозяина и передающая радиосообщение в случае смерти."
	var/mobname = "Will Robinson"

/obj/item/weapon/implant/death_alarm/inject(mob/living/carbon/C, def_zone)
	. = ..()
	implanted(C)

/obj/item/weapon/implant/death_alarm/get_data()
	var/dat = {"
<b>Характеристики импланта:</b><BR>
<b>Наименование:</b> Сенсор жизненных показателей работника типа \"Гарант прибыли\" НаноТрейзен <BR>
<b>Срок годности:</b> Активируется посмертно.<BR>
<b>Важные примечания:</b> Оповещает экипаж о смерти носителя.<BR>
<HR>
<b>Подробности:</b><BR>
<b>Функционал:</b> Содержит миниатюрный радиопередатчик, срабатывающий при прекращении жизнедеятельности носителя.<BR>
<b>Особенности:</b> Оповещает экипаж о смерти носителя.<BR>
<b>Целостность:</b> Иммунная система носителя периодически повреждает имплант, от чего он может работать со сбоями."}
	return dat

/obj/item/weapon/implant/death_alarm/process()
	if (!implanted) return
	var/mob/M = imp_in

	if(isnull(M)) // If the mob got gibbed
		activate()
	else if(M.stat == DEAD)
		activate("death")

/obj/item/weapon/implant/death_alarm/activate(cause)
	var/mob/M = imp_in
	var/area/t = get_area(M)
	switch (cause)
		if("death")
			var/obj/item/device/radio/headset/a = new /obj/item/device/radio/headset(null)
			if(is_type_in_list(t, global.death_alarm_stealth_areas))
				//give the syndies a bit of stealth
				a.autosay("[mobname] [(ANYMORPH(M, "погиб", "погибла", "погибло", "погибли"))] в космосе!", "Оповещение о смерти [mobname]")
			else
				a.autosay("[mobname] [(ANYMORPH(M, "погиб", "погибла", "погибло", "погибли"))] в [CASE(t, PREPOSITIONAL_CASE)]!", "Оповещение о смерти [mobname]")
			STOP_PROCESSING(SSobj, src)
			qdel(a)
		if ("emp")
			var/obj/item/device/radio/headset/a = new /obj/item/device/radio/headset(null)
			a.autosay("[mobname] [(ANYMORPH(M, "погиб", "погибла", "погибло", "погибли"))] в [CASE(t, PREPOSITIONAL_CASE)]!", "Оповещение о смерти [mobname]")
			qdel(a)
		else
			var/obj/item/device/radio/headset/a = new /obj/item/device/radio/headset(null)
			a.autosay("[mobname] [(ANYMORPH(M, "погиб", "погибла", "погибло", "погибли"))] в-в-в- бз-з-з-з-з...", "Оповещение о смерти [mobname]")
			STOP_PROCESSING(SSobj, src)
			qdel(a)

/obj/item/weapon/implant/death_alarm/emp_act(severity)			//for some reason alarms stop going off in case they are emp'd, even without this
	if (malfunction)		//so I'm just going to add a meltdown chance here
		return
	malfunction = MALFUNCTION_TEMPORARY

	activate("emp")	//let's shout that this dude is dead
	if(severity == 1)
		if(prob(40))	//small chance of obvious meltdown
			meltdown()
		else if (prob(60))	//but more likely it will just quietly die
			malfunction = MALFUNCTION_PERMANENT
		STOP_PROCESSING(SSobj, src)

	spawn(20)
		malfunction--

/obj/item/weapon/implant/death_alarm/implanted(mob/source)
	mobname = source.real_name
	START_PROCESSING(SSobj, src)
	return 1

/obj/item/weapon/implant/death_alarm/coordinates
	var/frequency = 1459

/obj/item/weapon/implant/death_alarm/coordinates/activate(cause)
	if(cause != "death")
		return
	var/turf/T = get_turf(imp_in)

	var/obj/item/device/radio/headset/a = new /obj/item/device/radio/headset(null)
	a.autosay("[imp_in.real_name] [(ANYMORPH(imp_in, "погиб", "погибла", "погибло", "погибли"))] на координатах ([T.x], [T.y])!", "Оповещение о смерти [mobname]'", freq = frequency)
	STOP_PROCESSING(SSobj, src)
	qdel(a)

/obj/item/weapon/implant/death_alarm/coordinates/team_red
	frequency = FREQ_TEAM_RED

/obj/item/weapon/implant/death_alarm/coordinates/team_blue
	frequency = FREQ_TEAM_BLUE

/obj/item/weapon/implant/compressed
	name = "compressed matter implant" // этот имплант не используется и ниже содержит инфу для оповещалки о смерти
	desc = "Based on compressed matter technology, can store a single item."
	icon_state = "implant_evil"
	var/activation_emote = "sigh"
	var/obj/item/scanned = null

/obj/item/weapon/implant/compressed/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> NanoTrasen \"Profit Margin\" Class Employee Lifesign Sensor<BR>
<b>Life:</b> Activates upon death.<BR>
<b>Important Notes:</b> Alerts crew to crewmember death.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a compact radio signaler that triggers when the host's lifesigns cease.<BR>
<b>Special Features:</b> Alerts crew to crewmember death.<BR>
<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}
	return dat

/obj/item/weapon/implant/compressed/trigger(emote, mob/source)
	if (src.scanned == null)
		return 0

	if (emote == src.activation_emote)
		to_chat(source, "The air glows as \the [src.scanned.name] uncompresses.")
		activate()

/obj/item/weapon/implant/compressed/activate()
	var/turf/t = get_turf(src)
	if (imp_in)
		imp_in.put_in_hands(scanned)
	else
		scanned.loc = t
	qdel(src)

/obj/item/weapon/implant/compressed/implanted(mob/source)
	src.activation_emote = input("Choose activation emote:") in list("blink", "eyebrow", "twitch", "frown", "nod", "giggle", "grin", "groan", "shrug", "smile", "sniff", "whimper", "wink")
	if (source.mind)
		source.mind.store_memory("Compressed matter implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0)
	to_chat(source, "The implanted compressed matter implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.")
	return 1

/obj/item/weapon/implant/compressed/islegal()
	return 0

/obj/item/weapon/implant/cortical
	name = "cortical stack"
	cases = list("кортикальный узел", "кортикального узла", "кортикальному узлу", "кортикальный узел", "кортикальным узлом", "кортикальном узле")
	desc = "Куча биоплат и чипов, почти с кулак размером."
	icon_state = "implant_evil"
	///////////////////////////////////////////////////////////
/obj/item/weapon/storage/internal/imp
	name = "bluespace pocket"
	cases = list("блюспейс карман", "блюспейс кармана", "блюспейс карману", "блюспейс карман", "блюспейс карманом", "блюспейс кармане")
	max_w_class = SIZE_SMALL
	storage_slots = 2
	cant_hold = list(/obj/item/weapon/disk/nuclear)

/obj/item/weapon/implant/storage
	name = "storage implant"
	cases = list("имплант хранения", "импланта хранения", "импланту хранения", "имплант хранения", "имплантом хранения", "импланте хранения")
	desc = "Может хранить до двух вещей большого размера в блюспейс кармане."
	icon_state = "implant_evil"
	origin_tech = "materials=2;magnets=4;bluespace=5;syndicate=4"
	var/obj/item/weapon/storage/internal/imp/storage
	item_action_types = list(/datum/action/item_action/implant/storage_implant)

/datum/action/item_action/implant/storage_implant
	name = "Блюспейс карман"

/datum/action/item_action/implant/storage_implant/Activate()
	var/obj/item/weapon/implant/storage/S = target
	S.storage.open(S.imp_in)

/obj/item/weapon/implant/storage/atom_init()
	. = ..()
	storage = new /obj/item/weapon/storage/internal/imp(src)

/obj/item/weapon/implant/storage/proc/removed()
	storage.close_all()
	for(var/obj/item/I in storage)
		storage.remove_from_storage(I, get_turf(src))

/obj/item/weapon/implant/storage/Destroy()
	removed()
	qdel(storage)
	return ..()

/obj/item/weapon/implant/storage/islegal()
	return 0

/obj/item/weapon/implant/obedience
	name = "L.E.A.S.H. obedience implant"
	cases = list("имплант повиновения \"П.Л.Е.Т.К.А\"", "импланта повиновения \"П.Л.Е.Т.К.А\"", "импланту повиновения \"П.Л.Е.Т.К.А\"", "имплант повиновения \"П.Л.Е.Т.К.А\"", "имплантом повиновения \"П.Л.Е.Т.К.А\"", "импланте повиновения \"П.Л.Е.Т.К.А\"")
	desc = "Делает ваше стадо послушным."

/obj/item/weapon/implant/obedience/get_data()
	var/dat = {"
<b>Характеристики импланта:</b><BR>
<b>Наименование:</b> Внушитель послушания сотрудника типа \"Гарант прибыли\" NanoTrasen<BR>
<b>Срок годности:</b> Активируется при получении зашифрованного сигнала.<BR>
<b>Важные примечания:</b> Позволяет бить током носителя с помощью особого инструмента.<BR>
<HR>
<b>Подробности:</b><BR>
<b>Функционал:</b> Содержит миниатюрный приёмник, который по сигналу активирует встроенный микроэлектрошокер.<BR>
<b>Особенности:</b> Нелетальный шокер на радиоуправлении.<BR>
<b>Целостность:</b> Имплант не теряет функционал даже после смерти носителя, что позволяет пересадить его с помощью специальных приборов.<BR>
Правда, эти приборы никогда на станцию не доставляются."}
	return dat

/obj/item/weapon/implant/blueshield
	name = "blueshield implant"
	cases = list("имплант синего щита", "импланта синего щита", "импланту синего щита", "имплант синего щита", "имплантом синего щита", "импланте синего щита")
	desc = "Нежно промывает мозг."
	var/last_examined = 0

/obj/item/weapon/implant/blueshield/get_data()
	var/dat = {"
<b>Характеристики импланта:</b><BR>
<b>Наименование:</b> Экспериментальная инициатива \"Синий щит\" Nanotrasen<BR>
<b>Срок годности:</b> Активируется при инъекции.<BR>
<b>Важные примечания:</b> Незаметно заставляет носителя защищать членов командования.<BR>
<HR>
<b>Подробности:</b><BR>
<b>Функционал:</b> Содержит специальные гормоны, влияющие на мозг носителя.<BR>
<b>Целостность:</b> Имплант не теряет функционал даже после смерти носителя, что позволяет пересадить его с помощью специальных приборов.<BR>
Правда, эти приборы никогда на станцию не доставляются."}
	return dat

/obj/item/weapon/implant/blueshield/implanted(mob/source)
	START_PROCESSING(SSobj, src)

/obj/item/weapon/implant/blueshield/process()
	if (!implanted)
		STOP_PROCESSING(SSobj, src)
		return
	if(!imp_in)
		STOP_PROCESSING(SSobj, src)
		return

	if(world.time > last_examined + 6000)
		SEND_SIGNAL(imp_in, COMSIG_CLEAR_MOOD_EVENT, "blueshield")
		SEND_SIGNAL(imp_in, COMSIG_ADD_MOOD_EVENT, "blueshield", /datum/mood_event/blueshield)

/obj/item/weapon/implant/fake_loyal
	name = "loyaIty implant"
	cases = list("имплант лояльности", "импланта лояльности", "импланту лояльности", "имплант лояльности", "имплантом лояльности", "импланте лояльности")
	desc = "Делает лояльным. Или вроде того."
	implant_trait = TRAIT_FAKELOYAL_VISUAL

/obj/item/weapon/implant/bork
	name = "B0RK-X3 skillchip"
	desc = "A specialised form of self defence, developed by skilled sous-chef de cuisines. No man fights harder than a chef to defend his kitchen"
	implant_trait = TRAIT_BORK_SKILLCHIP
