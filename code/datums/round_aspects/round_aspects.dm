/datum/round_aspect
	var/name
	// Game announcement after initialization of the subsystem and selection of aspect. Leave blank if you don't want anything.
	var/game_announcement

	var/ic_announcement //announcement after character spawn

/datum/round_aspect/proc/on_start()
	return

/datum/round_aspect/agent_of_high_affairs
	name = ROUND_ASPECT_HF_AGENT

/datum/round_aspect/rearm_energy
	name = ROUND_ASPECT_REARM_ENERGY

/datum/round_aspect/rearm_energy/on_start()
	new /datum/event/feature/area/replace/station_rearmament_energy
	for(var/datum/design/smg/smg in global.all_designs)
		smg.materials = list(MAT_METAL = 16000, MAT_SILVER = 4000, MAT_DIAMOND = 2000)

	for(var/datum/supply_pack/ballistic/b in global.all_supply_pack)
		b.cost *= 5

/datum/round_aspect/rearm_ballistic
	name = ROUND_ASPECT_REARM_BULLETS

/datum/round_aspect/rearm_ballistic/on_start()
	new /datum/event/feature/area/replace/station_rearmament_bullets
	for(var/datum/design/nuclear_gun/ng in global.all_designs)
		ng.materials = list(MAT_METAL = 15000, MAT_GLASS = 5000, MAT_URANIUM = 10000)
	for(var/datum/design/stunrevolver/sr in global.all_designs)
		sr.materials = list(MAT_METAL = 20000)
	for(var/datum/design/lasercannon/lc in global.all_designs)
		lc.materials = list(MAT_METAL = 20000, MAT_GLASS = 2000, MAT_DIAMOND = 4000, MAT_URANIUM = 1000)
	for(var/datum/design/laserrifle/lr in global.all_designs)
		lr.materials = list (MAT_METAL = 16000, MAT_GLASS = 5000, MAT_URANIUM = 1000)
	for(var/datum/design/plasma_10_gun/plsm in global.all_designs)
		plsm.materials = list(MAT_METAL = 25000, MAT_GOLD = 12000, MAT_SILVER = 9000, MAT_DIAMOND = 1000, MAT_URANIUM = 2000)
	for(var/datum/design/plasma_104_gun/plsmsh in global.all_designs)
		plsmsh.materials = list(MAT_METAL = 25000, MAT_GOLD = 12000, MAT_SILVER = 15000, MAT_DIAMOND = 15000, MAT_URANIUM = 10000)

	for(var/datum/supply_pack/energy/e in global.all_supply_pack)
		e.cost *= 5

/datum/round_aspect/cyber_station
	name = ROUND_ASPECT_CYBER_STATION
	ic_announcement = "<span class='warning'>НаноТрейзен решило отправить на эту станцию людей только с полностью механизированными конечностями и органами.</span>"

/datum/round_aspect/no_common_rchannel
	name = ROUND_ASPECT_NO_COMMON_RADIO_CHANNEL

/datum/round_aspect/no_common_rchannel/on_start()
	new /datum/event/feature/area/replace/del_tcomms

/datum/round_aspect/high_space_rad
	name = ROUND_ASPECT_HIGH_SPACE_RADIATION
	ic_announcement = "<span class='warning'>Перед началом смены вас оповестили о том что станция находится в секторе с повышенным уровнем радиации.</span>"

/datum/round_aspect/ai_trio
	name = ROUND_ASPECT_AI_TRIO
	game_announcement = "<span class='warning'>В качестве эксперимента, НаноТрейзен решило разместить на спутнике станции целых три ядра ИИ.</span>"

/datum/round_aspect/ai_trio/on_start()
	SSticker.triai = TRUE
