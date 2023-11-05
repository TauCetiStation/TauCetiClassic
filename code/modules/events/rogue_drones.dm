/datum/event/rogue_drone
	startWhen = 10
	endWhen = 1000
	announce_begin_type = /datum/announcement/centcomm/icarus_lost
	var/datum/announcement/announcement_recoverd
	var/announcement_recoverd_type = /datum/announcement/centcomm/icarus_recovered
	var/datum/announcement/announcement_destroyed
	var/announcement_destroyed_type = /datum/announcement/centcomm/icarus_destroyed
	var/list/drones_list = list()

/datum/event/rogue_drone/start()
	//25% chance for this to be a false alarm
	if(prob(25))
		return
	//spawn them at the same place as carp
	var/list/possible_spawns = landmarks_list["carpspawn"]
	var/num = rand(2, 6)
	for(var/i in 1 to num)
		var/mob/living/simple_animal/hostile/retaliate/malf_drone/D = new(get_turf(pick(possible_spawns)))
		drones_list.Add(D)
		if(prob(25))
			D.disabled = rand(15, 60)

/datum/event/rogue_drone/announce()
	if(announcement)
		announcement.play()

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

	if(num_recovered > drones_list.len * 0.75 && announcement_recoverd)
		announcement_recoverd.play()
	else
		if(announcement_destroyed)
			announcement_destroyed.play()

/datum/event/rogue_drone/disable_announce()
	..()
	announcement_recoverd = null
	announcement_destroyed = null

/datum/event/rogue_drone/enable_announce()
	..()
	announcement_recoverd = new announcement_recoverd_type()
	announcement_destroyed = new announcement_destroyed_type()
