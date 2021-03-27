/datum/event/rogue_drone
	startWhen = 10
	endWhen = 1000
	announcement = new /datum/announcement/centcomm/icarus_lost
	announcement_end = new /datum/announcement/centcomm/icarus_recovered
	var/list/drones_list = list()

/datum/event/rogue_drone/start()
	//spawn them at the same place as carp
	var/list/possible_spawns = list()
	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "carpspawn")
			possible_spawns.Add(C)

	//25% chance for this to be a false alarm
	var/num
	if(prob(25))
		num = 0
	else
		num = rand(2,6)
	for(var/i=0, i<num, i++)
		var/mob/living/simple_animal/hostile/retaliate/malf_drone/D = new(get_turf(pick(possible_spawns)))
		drones_list.Add(D)
		if(prob(25))
			D.disabled = rand(15, 60)

/datum/event/rogue_drone/announce()
	var/msg
	if(prob(33))
		msg = "Боевое крыло дронов не смогло вернуться с зачистки данного сектора, при обнаружении приближаться с осторожностью."
	else if(prob(50))
		msg = "На ВКН Икар был потерян контакт с боевым крылом дронов. При обнаружении их в этой области, приближаться с осторожностью."
	else
		msg = "Неизвестные хакеры атаковали боевое крыло дронов, запущенное с ВКН Икар. Если обнаружите их в данной области, приближаться с осторожностью."
	announcement.play(msg)

/datum/event/rogue_drone/tick()
	return

/datum/event/rogue_drone/end()
	var/num_recovered = 0
	for(var/mob/living/simple_animal/hostile/retaliate/malf_drone/D in drones_list)
		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(3, 0, D.loc)
		sparks.start()
		D.z = SSmapping.level_by_trait(ZTRAIT_CENTCOM)
		D.has_loot = FALSE

		qdel(D)
		num_recovered++

	var/msg
	if(num_recovered > drones_list.len * 0.75)
		msg = "Контроль дронов на ВКН Икар докладывает о восстановлении контроля над сбойным боевым крылом."
	else
		msg = "Контроль дронов ВКН Икар разочарован в потере боевого крыла. Выжившие дроны будут восстановлены."
	announcement_end.play(msg)
