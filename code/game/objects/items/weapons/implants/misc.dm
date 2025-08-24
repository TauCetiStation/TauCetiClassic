/obj/item/weapon/implant/tracking
	name = "tracking implant"
	cases = list("имплант слежения", "импланта слежения", "импланту слежения", "имплант слежения", "имплантом слежения", "импланте слежения")
	desc = "Используется для отслеживания."
	hud_id = IMPTRACK_HUD
	hud_icon_state = "hud_imp_tracking"
	var/id = 1.0
	implant_data = {"<b>Характеристики импланта:</b><BR>
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

/obj/item/weapon/implant/tracking/emp_act(severity)
	if (malfunction)	//no, dawg, you can't malfunction while you are malfunctioning
		return

	switch(severity)
		if(1)
			if(prob(60))
				meltdown()
		if(2)
			set_malfunction_for(rand(5 MINUTES, 15 MINUTES)) // free time

/obj/item/weapon/implant/adrenaline
	name = "adrenaline implant"
	cases = list("адреналиновый имплант", "адреналинового импланта", "адреналиновому импланту", "адреналиновый имплант", "адреналиновым имплантом", "адреналиновом импланте")
	desc = "Выручит от оглушения и поднимет на ноги."
	icon_state = "implant"
	legal = FALSE
	uses = 3
	delete_after_use = TRUE
	implant_data = {"
<b>Характеристики импланта:</b><BR>
<b>Наименование:</b> Адреналиновый имплант Cybersun Industries<BR>
<b>Срок годности:</b> Пять дней.<BR>
<b>Важные примечания:</b> <font color='red'>Нелегален</font><BR>
<HR>
<b>Подробности:</b> Носители импланта могут инициировать массивный выброс адреналина в крови.<BR>
<b>Функционал:</b> Содержит наноботов, вызывающих стимул на огромное производство адреналина в теле носителя.<BR>
<b>Особенности:</b> Предотвращает и позволяет преодолеть многие способы промывки мозгов.<BR>
<b>Целостность:</b> Имплант можно использовать три раза, прежде чем иссякнут наноботы."}

	item_action_types = list(/datum/action/item_action/implant/adrenaline_implant)

/datum/action/item_action/implant/adrenaline_implant
	name = "Адреналиновый имплант"

/datum/action/item_action/implant/adrenaline_implant/Activate()
	var/obj/item/weapon/implant/adrenaline/S = target
	S.use_implant()

/obj/item/weapon/implant/adrenaline/activate()
	to_chat(implanted_mob, "<span class='notice'>Вы чувствуете резкий прилив сил!</span>")
	implanted_mob.stat = CONSCIOUS
	implanted_mob.resetHalLoss()
	implanted_mob.SetParalysis(0)
	implanted_mob.SetStunned(0)
	implanted_mob.SetWeakened(0)
	implanted_mob.reagents.add_reagent("tricordrazine", 20)
	implanted_mob.reagents.add_reagent("doctorsdelight", 25)
	implanted_mob.reagents.add_reagent("oxycodone", 5)
	implanted_mob.reagents.add_reagent("stimulants", 4)

/obj/item/weapon/implant/emp
	name = "emp implant"
	cases = list("ЭМИ имплант", "ЭМИ импланта", "ЭМИ импланту", "ЭМИ имплант", "ЭМИ имплантом", "ЭМИ импланте")
	desc = "Вызывает ЭМИ."
	icon_state = "emp"
	legal = FALSE
	uses = 3
	delete_after_use = TRUE

	item_action_types = list(/datum/action/item_action/implant/emp_implant)

/datum/action/item_action/implant/emp_implant
	name = "ЭМИ имплант"

/datum/action/item_action/implant/emp_implant/Activate()
	var/obj/item/weapon/implant/emp/S = target
	S.use_implant()

/obj/item/weapon/implant/emp/activate()
	empulse(implanted_mob, 3, 5, custom_effects = EMP_SEBB)

/obj/item/weapon/implant/chem
	name = "chemical implant"
	cases = list("химический имплант", "химического импланта", "химическому импланту", "химический имплант", "химическим имплантом", "химическом импланте")
	desc = "Вводит в кровь всякое."
	hud_id = IMPCHEM_HUD
	hud_icon_state = "hud_imp_chem"

	activation_emote = "deathgasp"
	implant_data = {"
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

/obj/item/weapon/implant/chem/atom_init()
	. = ..()
	reagents = new/datum/reagents(50)
	reagents.my_atom = src

/obj/item/weapon/implant/chem/activate(volume)
	if(!volume)
		volume = reagents.total_volume

	reagents.trans_to(implanted_mob, volume)
	to_chat(implanted_mob, "Вы слышите тихое *бип*.")
	if(!reagents.total_volume)
		to_chat(implanted_mob, "Из вашей груди доносится еле слышный щелчок.")
		qdel(src)

/obj/item/weapon/implant/chem/emp_act(severity)
	if(malfunction)
		return

	switch(severity)
		if(1)
			if(prob(60))
				use_implant(20)
		if(2)
			if(prob(30))
				use_implant(5)

	set_malfunction_for(5 SECONDS)

/obj/item/weapon/implant/cortical
	name = "cortical stack"
	cases = list("кортикальный узел", "кортикального узла", "кортикальному узлу", "кортикальный узел", "кортикальным узлом", "кортикальном узле")
	desc = "Куча биоплат и чипов, почти с кулак размером."
	icon_state = "implant_evil"

/obj/item/weapon/implant/obedience
	name = "L.E.A.S.H. obedience implant"
	cases = list("имплант повиновения \"П.Л.Е.Т.К.А\"", "импланта повиновения \"П.Л.Е.Т.К.А\"", "импланту повиновения \"П.Л.Е.Т.К.А\"", "имплант повиновения \"П.Л.Е.Т.К.А\"", "имплантом повиновения \"П.Л.Е.Т.К.А\"", "импланте повиновения \"П.Л.Е.Т.К.А\"")
	desc = "Делает ваше стадо послушным."
	hud_id = IMPOBED_HUD
	hud_icon_state = "hud_imp_obedience"

	implant_data = {"
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

/obj/item/weapon/implant/blueshield
	name = "blueshield implant"
	cases = list("имплант синего щита", "импланта синего щита", "импланту синего щита", "имплант синего щита", "имплантом синего щита", "импланте синего щита")
	desc = "Нежно промывает мозг."
	COOLDOWN_DECLARE(penalty_cooldown)
	var/penalty_stack = 0
	var/list/protected_jobs
	implant_data = {"
<b>Характеристики импланта:</b><BR>
<b>Наименование:</b> Экспериментальная инициатива \"Синий щит\" Nanotrasen<BR>
<b>Срок годности:</b> Активируется при инъекции.<BR>
<b>Важные примечания:</b> Мотивирует носителя защищать членов командования.<BR>
<HR>
<b>Подробности:</b><BR>
<b>Функционал:</b> Бьет током при игнорировании доджностных обязанностей.<BR>
<b>Целостность:</b> Имплант не теряет функционал даже после смерти носителя, что позволяет пересадить его с помощью специальных приборов.<BR>
Правда, эти приборы никогда на станцию не доставляются."}

/obj/item/weapon/implant/blueshield/atom_init()
	protected_jobs = SSjob.departments_occupations[DEP_COMMAND] + JOB_LAWYER
	. = ..()

/obj/item/weapon/implant/blueshield/inject(mob/living/carbon/C, def_zone)
	. = ..()
	START_PROCESSING(SSobj, src)
	RegisterSignal(implanted_mob, COMSIG_MOB_EXAMINED, PROC_REF(on_examine))

/obj/item/weapon/implant/eject()
	UnregisterSignal(implanted_mob, COMSIG_MOB_EXAMINED)
	. = ..()

/obj/item/weapon/implant/blueshield/proc/on_examine(mob/user, mob/M)
	if(M.mind && (M.mind.assigned_role in protected_jobs))
		penalty_stack = 0
		COOLDOWN_RESET(src, penalty_cooldown)

/obj/item/weapon/implant/blueshield/process()
	if(!implanted_mob)
		STOP_PROCESSING(SSobj, src)
		return

	if(!COOLDOWN_FINISHED(src, penalty_cooldown))
		return

	COOLDOWN_START(src, penalty_cooldown, 4 MINUTES)

	// check if there is any heads on the station
	// todo: store crew in jobs/departments datums
	var/list/to_protect = list()
	for(var/mob/living/carbon/human/player as anything in human_list)
		if(player.mind && (player.mind.assigned_role in protected_jobs))
			to_protect += player.mind

	if(!length(to_protect))
		penalty_stack = 0
		return

	switch(++penalty_stack)
		if(1) // so we dont immediately spam the warning after examining players
			EMPTY_BLOCK_GUARD
		if(2)
			to_chat(implanted_mob, "<span class='bold warning'>Кто-то из глав или АВД должны быть на станции. Следует проверить их, или имплант напомнит о себе.</span>")
		if(3)
			to_chat(implanted_mob, "<span class='bold warning'>[C_CASE(src, NOMINATIVE_CASE)] в [CASE(body_part, PREPOSITIONAL_CASE)] напоминает о должностных обязанностях легким ударом тока, дальше может быть хуже.</span>")
		else
			if(implanted_mob.mood_prob(5 * (penalty_stack - 4))) // one guaranteed electrocute act
				to_chat(implanted_mob, "<span class='bold warning'>Вы ожидаете очередной удар током от [CASE(src, GENITIVE_CASE)], но его не происходит. Вы пережили свой имплант в этой битве. Если бы только вам не пришлось потом писать объяснительную...</span>")
				meltdown(harmful = FALSE)
			else
				to_chat(implanted_mob, "<span class='bold warning'>[C_CASE(body_part, NOMINATIVE_CASE)] бьет вас током за игнорирование служебных обязанностей.</span>")
				implanted_mob.electrocute_act(15 * (penalty_stack - 3), src)

/obj/item/weapon/implant/bork
	name = "B0RK-X3 skillchip"
	desc = "A specialised form of self defence, developed by skilled sous-chef de cuisines. No man fights harder than a chef to defend his kitchen"
	implant_trait = TRAIT_BORK_SKILLCHIP

/obj/item/weapon/implant/willpower
	name = "volitional neuroinhibitor"
	cases = list("волевой нейроингибитор", "волевого нейроингибитора", "волевому нейроингибитору", "волевой нейроингибитор", "волевым нейроингибитором", "волевом нейроингибиторе")
	desc = "Экспериментальный имплант, воздействующий на нервную систему человека и побуждающий его к более активным, волевым действиям."

/obj/item/weapon/implant/willpower/inject()
	. = ..()

	var/mob/living/carbon/human/H = implanted_mob
	if(istype(H) && H.species.flags[NO_WILLPOWER])
		return

	var/count = 0
	for(var/obj/item/weapon/implant/willpower/I in implanted_mob.implants)
		count++

	if(count > 1) // can't get two of them
		if(implanted_mob.adjustBrainLoss(100))
			implanted_mob.visible_message("<span class='warning'>Из ушей [implanted_mob] вырывается поток крови и мозговой жидкости!</span>", "<span class='warning'>За вашими глазами нарастает невероятное давление! КАК БОЛЬНО!!!</span>")
			new /obj/effect/gibspawner/generic(implanted_mob.loc)
		return

	if(implanted_mob.mind)
		implanted_mob.mind.willpower_amount++
		to_chat(implanted_mob, "<span class='bold nicegreen'>Вы чувствуете волевой порыв!</span>")
		return

/obj/item/weapon/implant/willpower/eject()
	if(implanted_mob && implanted_mob.mind)
		implanted_mob.mind.willpower_amount--
		to_chat(implanted_mob, "<span class='boldwarning'>Ваша воля увядает...</span>")
	. = ..()
