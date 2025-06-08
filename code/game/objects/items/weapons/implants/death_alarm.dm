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
	implant_data = {"
<b>Характеристики импланта:</b><BR>
<b>Наименование:</b> Сенсор жизненных показателей работника типа \"Гарант прибыли\" НаноТрейзен <BR>
<b>Срок годности:</b> Активируется посмертно.<BR>
<b>Важные примечания:</b> Оповещает экипаж о смерти носителя.<BR>
<HR>
<b>Подробности:</b><BR>
<b>Функционал:</b> Содержит миниатюрный радиопередатчик, срабатывающий при прекращении жизнедеятельности носителя.<BR>
<b>Особенности:</b> Оповещает экипаж о смерти носителя.<BR>
<b>Целостность:</b> Иммунная система носителя периодически повреждает имплант, от чего он может работать со сбоями."}

/obj/item/weapon/implant/death_alarm/inject(mob/living/carbon/C, def_zone)
	. = ..()

	RegisterSignal(implanted_mob, COMSIG_MOB_DIED, PROC_REF(on_death))

/obj/item/weapon/implant/eject()
	UnregisterSignal(implanted_mob, COMSIG_MOB_DIED)

	. = ..()

/obj/item/weapon/implant/death_alarm/proc/on_death()
	SIGNAL_HANDLER

	use_implant()

/obj/item/weapon/implant/death_alarm/activate(fake_alert = FALSE)
	if(malfunction)
		return

	var/obj/item/device/radio/headset/radio = new /obj/item/device/radio/headset(null)
	var/area/location

	if(fake_alert)
		location = pick(the_station_areas)
	else
		location = get_area(implanted_mob)

	if(is_type_in_list(location, global.death_alarm_stealth_areas))
		radio.autosay("[implanted_mob.real_name] [(ANYMORPH(implanted_mob, "погиб", "погибла", "погибло", "погибли"))] в космосе!", "Оповещение о смерти [implanted_mob.real_name]")
	else
		radio.autosay("[implanted_mob.real_name] [(ANYMORPH(implanted_mob, "погиб", "погибла", "погибло", "погибли"))]. Местоположение: [CASE(location, NOMINATIVE_CASE)]!", "Оповещение о смерти [implanted_mob.real_name]")

	qdel(radio)

/obj/item/weapon/implant/death_alarm/emp_act(severity)
	if(malfunction)
		return

	use_implant(TRUE) //let's shout that this dude is dead
	if(severity == 1)
		meltdown(harmful = prob(60))
	else
		set_malfunction_for(5 SECONDS)

/obj/item/weapon/implant/death_alarm/coordinates
	var/frequency = 1459

/obj/item/weapon/implant/death_alarm/coordinates/activate(fake_alert)
	if(fake_alert)
		return
	var/turf/T = get_turf(implanted_mob)

	var/obj/item/device/radio/headset/radio = new /obj/item/device/radio/headset(null)
	radio.autosay("[implanted_mob.real_name] [(ANYMORPH(implanted_mob, "погиб", "погибла", "погибло", "погибли"))] на координатах ([T.x], [T.y])!", "Оповещение о смерти [implanted_mob.real_name]'", freq = frequency)
	qdel(radio)

/obj/item/weapon/implant/death_alarm/coordinates/team_red
	frequency = FREQ_TEAM_RED

/obj/item/weapon/implant/death_alarm/coordinates/team_blue
	frequency = FREQ_TEAM_BLUE
