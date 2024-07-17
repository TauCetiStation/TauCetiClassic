/*
 * Aspect is a unique trait for a round.
 *
 * The main purpose of the aspect is to diversify the round and make it more unique.
 *
 * It is desirable that the aspect influences the round from beginning to end. This shouldn't be like a roundstart event.
 *
 */
/datum/round_aspect

	var/name

	//OOC announcement after initialization of the subsystem and selection of aspect.
	//Write a description here if it requires preliminary preparation, for example, choosing a role in setup.
	//You shouldn't write a description here if you think it will scare away players, use afterspawn IC announcement for this.
	var/OOC_lobby_announcement

	//Message after character spawn.
	//Write here the IC description of the aspect if it is dangerous or if it needs to be noticed.
	var/afterspawn_IC_announcement

	//Description of the aspect for admins & end round titles.
	//Briefly write down here what the aspect does.
	var/desc

/datum/round_aspect/proc/after_init() //after SSround_aspects init
	return

/datum/round_aspect/proc/after_start() //after round start
	return

/datum/round_aspect/mechas
	name = ROUND_ASPECT_MECHAS
	desc = "Добавлены мехи во все отделы."

/datum/round_aspect/mechas/after_start()
	new /datum/event/feature/area/replace/sec_rearmament_mech
	for(var/datum/design/nuclear_gun/ng in global.all_designs)
		for(var/M in ng.materials)
			ng.materials[M] *= 5
	for(var/datum/design/stunrevolver/sr in global.all_designs)
		for(var/M in sr.materials)
			sr.materials[M] *= 5
	for(var/datum/design/smg/smg in global.all_designs)
		for(var/M in smg.materials)
			smg.materials[M] *= 5
	for(var/datum/design/lasercannon/lc in global.all_designs)
		for(var/M in lc.materials)
			lc.materials[M] *= 5
	for(var/datum/design/laserrifle/lr in global.all_designs)
		for(var/M in lr.materials)
			lr.materials[M] *= 5
	for(var/datum/design/plasma_10_gun/plsm in global.all_designs)
		for(var/M in plsm.materials)
			plsm.materials[M] *= 5
	for(var/datum/design/plasma_104_gun/plsmsh in global.all_designs)
		for(var/M in plsmsh.materials)
			plsmsh.materials[M] *= 5

	for(var/datum/supply_pack/energy/e in global.all_supply_pack)
		e.cost *= 25

	for(var/datum/supply_pack/ballistic/b in global.all_supply_pack)
		b.cost *= 25

/datum/round_aspect/agent_of_high_affairs
	name = ROUND_ASPECT_HF_AGENT
	desc = "АВД была выдана цепь командования. Во всех глав был вставлен имплант подчинения."

/datum/round_aspect/rearm_energy
	name = ROUND_ASPECT_REARM_ENERGY
	desc = "Всё огнестрельное оружие заменено на энергетическое, повышена цена и количество ресурсов для создания огнестрельного оружия."

/datum/round_aspect/rearm_energy/after_start()
	for(var/datum/design/smg/smg in global.all_designs)
		for(var/M in smg.materials)
			smg.materials[M] *= 5

	for(var/datum/supply_pack/ballistic/b in global.all_supply_pack)
		b.cost *= 50

	new /datum/event/feature/area/replace/station_rearmament_energy

/datum/round_aspect/rearm_ballistic
	name = ROUND_ASPECT_REARM_BULLETS
	desc = "Всё энергооружие заменено на огнестрельное, повышена цена и количество ресурсов для создания энергооружия."

/datum/round_aspect/rearm_ballistic/after_start()
	for(var/datum/design/nuclear_gun/ng in global.all_designs)
		for(var/M in ng.materials)
			ng.materials[M] *= 5
	for(var/datum/design/stunrevolver/sr in global.all_designs)
		for(var/M in sr.materials)
			sr.materials[M] *= 5
	for(var/datum/design/lasercannon/lc in global.all_designs)
		for(var/M in lc.materials)
			lc.materials[M] *= 5
	for(var/datum/design/laserrifle/lr in global.all_designs)
		for(var/M in lr.materials)
			lr.materials[M] *= 5
	for(var/datum/design/plasma_10_gun/plsm in global.all_designs)
		for(var/M in plsm.materials)
			plsm.materials[M] *= 5
	for(var/datum/design/plasma_104_gun/plsmsh in global.all_designs)
		for(var/M in plsmsh.materials)
			plsmsh.materials[M] *= 5

	for(var/datum/supply_pack/energy/e in global.all_supply_pack)
		e.cost *= 50

	new /datum/event/feature/area/replace/station_rearmament_bullets

/datum/round_aspect/no_common_rchannel
	name = ROUND_ASPECT_NO_COMMON_RADIO_CHANNEL
	desc = "Убран общий канал радиосвязи."

/datum/round_aspect/no_common_rchannel/after_start()
	new /datum/event/feature/area/replace/del_tcomms

/datum/round_aspect/high_space_rad
	name = ROUND_ASPECT_HIGH_SPACE_RADIATION
	afterspawn_IC_announcement = "<span class='warning'>Перед началом смены вас оповестили о том что станция находится в секторе с повышенным уровнем радиации.</span>"
	desc = "Космическая радиация наносит урон людям в скафандрах."

/datum/round_aspect/ai_trio
	name = ROUND_ASPECT_AI_TRIO
	OOC_lobby_announcement = "<span class='warning'>В качестве эксперимента, НаноТрейзен решило разместить на спутнике станции целых три ядра ИИ.</span>"
	desc = "Увеличено количество слотов ИИ до трёх."

/datum/round_aspect/elite_sec
	name = ROUND_ASPECT_ELITE_SECURITY
	desc = "Изменено снаряжение офицеров охраны. Увеличены цены на оружие в карго и РнД."

/datum/round_aspect/elite_sec/after_start()
	for(var/datum/design/nuclear_gun/ng in global.all_designs)
		for(var/M in ng.materials)
			ng.materials[M] *= 5
	for(var/datum/design/stunrevolver/sr in global.all_designs)
		for(var/M in sr.materials)
			sr.materials[M] *= 5
	for(var/datum/design/smg/smg in global.all_designs)
		for(var/M in smg.materials)
			smg.materials[M] *= 5
	for(var/datum/design/lasercannon/lc in global.all_designs)
		for(var/M in lc.materials)
			lc.materials[M] *= 5
	for(var/datum/design/laserrifle/lr in global.all_designs)
		for(var/M in lr.materials)
			lr.materials[M] *= 5
	for(var/datum/design/plasma_10_gun/plsm in global.all_designs)
		for(var/M in plsm.materials)
			plsm.materials[M] *= 5
	for(var/datum/design/plasma_104_gun/plsmsh in global.all_designs)
		for(var/M in plsmsh.materials)
			plsmsh.materials[M] *= 5

	for(var/datum/supply_pack/energy/e in global.all_supply_pack)
		e.cost *= 50

	for(var/datum/supply_pack/ballistic/b in global.all_supply_pack)
		b.cost *= 50

	new /datum/event/feature/area/replace/sec_rearmament_elite

/datum/round_aspect/more_random_events
	name = ROUND_ASPECT_MORE_RANDOM_EVENTS
	desc = "Увеличена частота случайных событий."

/datum/round_aspect/alternative_research
	name = ROUND_ASPECT_ALTERNATIVE_RESEARCH
	desc = "Взрывы газовых бомб стали приносить меньше научных очков."
	afterspawn_IC_announcement = "<span class='warning'>Научно-исследовательский Совет НаноТрейзен стал в меньшей мере интересоваться изучением взрывчатых свойств форона.</span>"

/datum/round_aspect/healing_alkohol
	name = ROUND_ASPECT_HEALING_ALCOHOL
	desc = "Алкоголь лечит физические повреждения."
	afterspawn_IC_announcement = "<span class='success'>Гибсонские ученые доказали, что умеренное потребление алкоголя продливает жизнь.</span>"
