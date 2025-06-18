/datum/role/replicator
	name = REPLICATOR
	id = REPLICATOR

	disallow_job = TRUE

	required_pref = ROLE_REPLICATOR

	logo_state = "replicators"

	antag_hud_type = ANTAG_HUD_REPLICATOR
	antag_hud_name = "replicator"

/datum/role/replicator/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>Вы - Репликатор, часть Роя. Вы должны поглощать материалы, возводить свою инфраструктуру или использовать станционную для постройки Блюспейс Катапульты, которая распространит Рой дальше по галактике через трещину. Реплицируйся и процветай!</b></span>"})
	to_chat(antag.current, "<span class='bold notice'>Рой вознаградил вас Даром. Осмотрите себя для возможных адаптаций к окружающей среде.</span>")
	to_chat(antag.current, "<span class='warning'>Помни. Эта реальность не предназначена для вас, вы медленно <b>умираете</b>. Потребление материалов ремонтирует вас, позволяя вам задержатся в этом мимолетном мире еще ненадолго...</span>")

/datum/role/replicator/StatPanel()
	if(!antag)
		return

	var/datum/faction/replicators/FR = faction
	var/datum/replicator_array_info/RAI = FR.ckey2info[ckey(antag.key)]

	stat("Materials:", "[round(FR.materials)] ([round(FR.last_second_materials_change)])")
	stat("Drone Amount:", "[length(global.alive_replicators) + FR.bandwidth_borrowed]/[FR.bandwidth]")
	if(length(global.active_transponders) > 0)
		stat("Bandwidth Upgrade:", "[round(FR.materials_consumed)]/[FR.consumed_materials_until_upgrade]")
	if(length(global.replicator_generators) > 0 || length(global.transponders) - length(global.active_transponders) > 0)
		stat("Energy Reserves:", "[round(FR.energy)]/[round(length(global.replicator_generators) * REPLICATOR_GENERATOR_POWER_GENERATION)] ([round(FR.last_second_energy_change)])")

	if(length(global.area2free_forcefield_nodes) > 0)
		var/node_string = ""
		var/first = TRUE
		for(var/area_name in global.area2free_forcefield_nodes)
			var/node_count = global.area2free_forcefield_nodes[area_name]
			if(!first)
				node_string += ", "
			first = FALSE
			node_string += "[area_name] ([node_count])"
		stat("Unclaimed Nodes:", node_string)

	if(length(global.bluespace_catapults) > 0)
		var/obj/machinery/swarm_powered/bluespace_catapult/catapult = global.bluespace_catapults[1]
		var/area/A = get_area(catapult)
		stat("Catapult Location:", "[A.name]")
		if(catapult.perc_finished >= 100)
			stat("Catapult replicators launched:", "[FR.replicators_launched]/[REPLICATORS_CATAPULTED_TO_WIN]")

	if(RAI && length(RAI.acquired_upgrades) > 0)
		stat("Array Upgrades:", RAI.get_upgrades_string())
