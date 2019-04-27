/datum/catastrophe_event/syndicat_evacuation
	name = "Syndicat evacuation"

	one_time_event = TRUE

	weight = 100

	event_type = "evacuation"
	steps = 1

	manual_stop = TRUE

/datum/catastrophe_event/syndicat_evacuation/on_step()
	switch(step)
		if(1)
			announce("Исход, мы ничём не можем вам помочь, станци[JA_PLACEHOLDER] ЦК практически полностью уничтожена, св[JA_PLACEHOLDER]зь с Икаром потер[JA_PLACEHOLDER]на, транзитна[JA_PLACEHOLDER] станци[JA_PLACEHOLDER] Велосити потер[JA_PLACEHOLDER]на, контроль над всей системой утер[JA_PLACEHOLDER]н, у нас нет свободных шатлов эвакуации дл[JA_PLACEHOLDER] вас, простите. Попытайтесь что-нибудь придумать. И да хранит вас бог, конец св[JA_PLACEHOLDER]зи")

			addtimer(CALLBACK(src, .proc/syndicat_evacuation_real), 10*60*5) // 5 extra mins

/datum/catastrophe_event/syndicat_evacuation/proc/syndicat_evacuation_real()
	announce("Ха-а-а, кто это у мен[JA_PLACEHOLDER] тут на радаре. Неужели это полуразрушенный Исход? Неужели ваше хваленное Нанотрейзен решила забить на вас? Как же мне вас жаль, черт побери, ха. А теперь серьёзно. Я даю вам всего лишь один вариант спасти ваши жалкие задницы, вы отдаёте мне всё ценное, что имеет ваша станци[JA_PLACEHOLDER], включа[JA_PLACEHOLDER] технологии и корпоративные секретики, а [JA_PLACEHOLDER] обещаю что, может быть, не дам вашим душам бесследно пропасть в бездне, идёт? Конечно идёт, у вас тупо нет другого выбора, ха. И не обращайте внимани[JA_PLACEHOLDER] на красный цвет шатла и огромные буквы “Синдикат” на обшивке, [JA_PLACEHOLDER] теперь ваш единственный друг")

	var/list/shuttle_turfs = get_area_turfs(locate(/area/shuttle/escape/centcom))
	for(var/turf/simulated/shuttle/wall/W in shuttle_turfs)
		W.color = "#aa0000"
	for(var/turf/simulated/shuttle/floor/F in shuttle_turfs)
		F.color = "#550000"

	var/list/shuttle_atoms = get_area_all_atoms(locate(/area/shuttle/escape/centcom))
	for(var/obj/structure/window/reinforced/shuttle/default/W in shuttle_atoms)
		W.color = "#222222"
	for(var/obj/machinery/door/unpowered/shuttle/D in shuttle_atoms)
		D.color = "#333333"

	if(SSshuttle)
		SSshuttle.always_fake_recall = FALSE
		SSshuttle.fake_recall = 0

		SSshuttle.incall()
		world << sound('sound/AI/shuttlecalled.ogg')
	stop()