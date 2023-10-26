/datum/round_aspect

	var/name

	// OOC announcement after initialization of the subsystem and selection of aspect. Leave blank if you don't want anything.
	var/OOC_announcement

	//Message after character spawn
	var/IC_announcement

	//Description of the aspect for admins.
	var/desc

/datum/round_aspect/proc/on_start()
	return

/datum/round_aspect/agent_of_high_affairs
	name = ROUND_ASPECT_HF_AGENT
	desc = "АВД была выдана цепь командования. Во всех глав был вставлен имплант подчинения."

/datum/round_aspect/rearm_energy
	name = ROUND_ASPECT_REARM_ENERGY
	desc = "Всё огнестрельное оружие заменено на энергетическое, повышена цена и количество ресурсов для создания огнестрельного оружия."

/datum/round_aspect/rearm_energy/on_start()
	new /datum/event/feature/area/replace/station_rearmament_energy
	for(var/datum/design/smg/smg in global.all_designs)
		smg.materials = list(MAT_METAL = 160000, MAT_SILVER = 40000, MAT_DIAMOND = 20000)

	for(var/datum/supply_pack/ballistic/b in global.all_supply_pack)
		b.cost *= 50

/datum/round_aspect/rearm_ballistic
	name = ROUND_ASPECT_REARM_BULLETS
	desc = "Всё энергооружие заменено на огнестрельное, повышена цена и количество ресурсов для создания энергооружия."

/datum/round_aspect/rearm_ballistic/on_start()
	new /datum/event/feature/area/replace/station_rearmament_bullets
	for(var/datum/design/nuclear_gun/ng in global.all_designs)
		ng.materials = list(MAT_METAL = 150000, MAT_GLASS = 50000, MAT_URANIUM = 100000)
	for(var/datum/design/stunrevolver/sr in global.all_designs)
		sr.materials = list(MAT_METAL = 200000)
	for(var/datum/design/lasercannon/lc in global.all_designs)
		lc.materials = list(MAT_METAL = 200000, MAT_GLASS = 20000, MAT_DIAMOND = 40000, MAT_URANIUM = 10000)
	for(var/datum/design/laserrifle/lr in global.all_designs)
		lr.materials = list (MAT_METAL = 160000, MAT_GLASS = 50000, MAT_URANIUM = 10000)
	for(var/datum/design/plasma_10_gun/plsm in global.all_designs)
		plsm.materials = list(MAT_METAL = 250000, MAT_GOLD = 120000, MAT_SILVER = 90000, MAT_DIAMOND = 10000, MAT_URANIUM = 20000)
	for(var/datum/design/plasma_104_gun/plsmsh in global.all_designs)
		plsmsh.materials = list(MAT_METAL = 250000, MAT_GOLD = 120000, MAT_SILVER = 150000, MAT_DIAMOND = 150000, MAT_URANIUM = 100000)

	for(var/datum/supply_pack/energy/e in global.all_supply_pack)
		e.cost *= 50

/datum/round_aspect/cyber_station
	name = ROUND_ASPECT_CYBER_STATION
	IC_announcement = "<span class='warning'>НаноТрейзен решило отправить на эту станцию людей только с полностью механизированными конечностями и органами.</span>"
	desc = "У всех существ органические конечности и органы были заменены на протезы."

/datum/round_aspect/no_common_rchannel
	name = ROUND_ASPECT_NO_COMMON_RADIO_CHANNEL

/datum/round_aspect/no_common_rchannel/on_start()
	new /datum/event/feature/area/replace/del_tcomms

/datum/round_aspect/high_space_rad
	name = ROUND_ASPECT_HIGH_SPACE_RADIATION
	IC_announcement = "<span class='warning'>Перед началом смены вас оповестили о том что станция находится в секторе с повышенным уровнем радиации.</span>"
	desc = "Космическая радиация наносит урон людям в скафандрах."

/datum/round_aspect/ai_trio
	name = ROUND_ASPECT_AI_TRIO
	OOC_announcement = "<span class='warning'>В качестве эксперимента, НаноТрейзен решило разместить на спутнике станции целых три ядра ИИ.</span>"
	desc = "Увеличено количество слотов ИИ до трёх."

/datum/round_aspect/ai_trio/on_start()
	SSticker.triai = TRUE
