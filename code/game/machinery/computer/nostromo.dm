/obj/machinery/computer/nostromo
	icon_state = "shuttle"
	resistance_flags = FULL_INDESTRUCTIBLE
	unacidable = TRUE
	var/datum/map_module/alien/MM = null

/obj/machinery/computer/nostromo/atom_init()
	. = ..()
	MM = SSmapping.get_map_module_by_name(MAP_MODULE_ALIEN)
	if(!MM)
		return INITIALIZE_HINT_QDEL
	else
		MM.shuttle_console = src

/obj/machinery/computer/nostromo/narcissus_shuttle
	name = "Narcissus Shuttle Console"
	cases = list("консоль шаттла", "консоли шаттла", "консоли шаттла", "консоль шаттла", "консолью шаттла", "консоли шаттла")
	var/docked = TRUE

/obj/machinery/computer/nostromo/narcissus_shuttle/ui_interact(mob/user)
	var/dat
	if(docked)
		dat += "<ul><li>Местоположение: <b>[station_name_ru()]</b></li>"
		dat += "</ul>"
		dat += "<a href='?src=\ref[src];evacuation=1'>Начать процедуру отстыковки</a>"
	else
		dat += "<ul><li>Местоположение: <b>Космос</b></li>"

	var/datum/browser/popup = new(user, "flightcomputer", "[capitalize(CASE(src, NOMINATIVE_CASE))]", 365, 200)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/nostromo/narcissus_shuttle/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(code_name_eng[security_level] != "delta")
		to_chat(usr, "<span class='warning'>Для эвакуации необходимо запустить систему самоуничтожения корабля!</span>")
		return FALSE

	if(!isrolebytype(/datum/role/nostromo_android, usr) && MM.alien && (MM.alien.stat != DEAD) && (MM.alien in orange(7, src)))
		to_chat(usr, "<span class='warning'>МЫ НЕ МОЖЕМ УЛЕТЕТЬ, ПОКА КСЕНОМОРФ С НАМИ НА ШАТТЛЕ!</span>")
		return FALSE

	if(href_list["evacuation"] && do_after(usr, 10 SECOND, target = src))
		do_move()

	updateUsrDialog()

/obj/machinery/computer/nostromo/narcissus_shuttle/proc/do_move()
	set waitfor = FALSE

	if(!docked)
		return

	docked = FALSE

	var/area/current_location = get_area_by_type(/area/shuttle/nostromo_narcissus/ship)
	var/area/transit_location = get_area_by_type(/area/shuttle/nostromo_narcissus/transit)

	SSshuttle.undock_act(/area/station/nostromo, "evac_shuttle_1")
	SSshuttle.undock_act(/area/shuttle/nostromo_narcissus/ship, "evac_shuttle_1")

	sleep(5 SECOND)

	current_location.move_contents_to(transit_location)
	SSshuttle.shake_mobs_in_area(transit_location, EAST)

	transit_location.parallax_movedir = WEST

	var/list/turfs = get_area_turfs(transit_location)
	for(var/turf/T in turfs)
		T.explosive_resistance = INFINITY // ANTINUKE KOSTIL

	MM.nuke_detonate()

/////////////////////////////////////////////////////////////////////////////////////
//			COCKPIT
/obj/machinery/computer/nostromo/cockpit
	resistance_flags = FULL_INDESTRUCTIBLE
	unacidable = TRUE
	name = "Nostromo Ship Console"
	cases = list("консоль корабля", "консоли корабля", "консоли корабля", "консоль корабля", "консолью корабля", "консоли корабля")
	var/course = 0
	var/side = 0
	var/next_course_change = 0
	var/obj/machinery/computer/nostromo/cockpit/second_console = null

/obj/machinery/computer/nostromo/cockpit/atom_init()
	..()
	if(!MM)
		return INITIALIZE_HINT_QDEL
	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(round_start))
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/nostromo/cockpit/atom_init_late()
	second_console = locate() in orange(1, src)
	if(!side)
		MM.console = src
		side = pick(1, -1)
		second_console.side = -side

/obj/machinery/computer/nostromo/cockpit/proc/round_start()
	next_course_change = world.time + rand(90, 110) SECOND
	UnregisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING)

/obj/machinery/computer/nostromo/cockpit/process()
	..()
	if(world.time > next_course_change)
		next_course_change += rand(110, 130) SECOND
		course += rand(3, 4) * side
		if(abs(course) > 18)
			MM.AI_announce("cockpit")
		if(abs(course) > 24)
			MM.breakdown()

/obj/machinery/computer/nostromo/cockpit/proc/explode()
	explosion(loc, 0, 0, 2)
	qdel(second_console)
	qdel(src)

/obj/machinery/computer/nostromo/cockpit/examine(mob/user, distance)
	if(distance > 4)
		return
	to_chat(user, "<span class='notice'>Текущее значение отклонения [course].</span>")

/obj/machinery/computer/nostromo/cockpit/attack_hand(mob/user)
	if((side == 1 && course >= side) || (side == -1 && course <= side))
		if(do_after(user, 2 SECOND, target = src))
			to_chat(user, "<span class='notice'>Вы успешно корректируете курс корабля.</span>")
			course -= rand(4, 6) * side
			second_console.course -= rand(1, 3) * side

/////////////////////////////////////////////////////////////////////////////////////
//			AUTODOC
/obj/machinery/nostromo/rejuvpod
	name = "medical capsule"
	desc = "Автоматическая медицинская капсула, способная излечить от всего, кроме смерти."
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "rejuvpod"
	anchored = TRUE
	density = FALSE
	resistance_flags = FULL_INDESTRUCTIBLE
	light_color = "#7bf9ff"
	var/bodypart_treatment = FALSE

/obj/machinery/nostromo/rejuvpod/update_icon()
	if(state_open)
		icon_state = "rejuvpod"
	else
		icon_state = "rejuvpod_cl"

/obj/machinery/nostromo/rejuvpod/MouseDrop_T(mob/living/carbon/human/target, mob/user)
	if(user.incapacitated() || !user.IsAdvancedToolUser() || !ishuman(target) || target.stat == DEAD)
		return
	close_machine(target)
	START_PROCESSING(SSmachines, src)
	to_chat(target, "<span class='notice'><b>Капсула вводит вас в регенеративный анабиоз.</b></span>")

/obj/machinery/nostromo/rejuvpod/process()
	if(!occupant)
		stop_processing()
		return

	if(occupant.reagents.get_reagent_amount("metatrombine") <= 1)
		occupant.reagents.add_reagent("metatrombine", 1)

	occupant.Sleeping(2 SECOND)
	occupant.adjustBruteLoss(-5)
	occupant.adjustFireLoss(-2)
	occupant.adjustToxLoss(-2)
	occupant.adjustOxyLoss(-2)

	if(!bodypart_treatment)
		try_heal_bodypart()

/obj/machinery/nostromo/rejuvpod/proc/try_heal_bodypart()
	set waitfor = FALSE

	var/mob/living/carbon/human/H = occupant

	for(var/obj/item/organ/external/BP in H.bodyparts)
		if(BP.is_broken())
			bodypart_treatment = TRUE
			sleep(20 SECOND)
			BP.rejuvenate()
			bodypart_treatment = FALSE
			return

	if(H.maxHealth - H.health > 20)
		return

	sleep(5 SECONDS)

	H.rejuvenate()
	open_machine()
	stop_processing()

/obj/machinery/nostromo/rejuvpod/attack_alien(mob/user)
	if(!occupant)
		return
	user.visible_message("<span class='danger'>Ксеноморф пытается вскрыть капсулу!.</span>",
						 "<span class='notice'>Вы пытаетесь вскрыть капсулу.</span>")
	if(do_after(user, 2 SECONDS, TRUE, src))
		occupant.Stun(3 SECONDS)
		open_machine()
		stop_processing()

/////////////////////////////////////////////////////////////////////////////////////
//			CHEM
/obj/machinery/chem_dispenser/nostromo
	max_energy = 20
	energy = 20
	recharge_delay = 20
	dispensable_reagents = list("carbon", "oxygen", "sugar", "silicon", "nitrogen", "potassium", "ethanol")

/////////////////////////////////////////////////////////////////////////////////////
//			NUCLEAR BOMB
/obj/machinery/nuclearbomb/nostromo
	anchored = TRUE
	safety = FALSE
	authorized = TRUE
	var/datum/map_module/alien/MM = null
	var/undock_try = FALSE

/obj/machinery/nuclearbomb/nostromo/atom_init()
	. = ..()
	MM = SSmapping.get_map_module_by_name(MAP_MODULE_ALIEN)
	if(MM)
		MM.nukebomb = src
	else
		return INITIALIZE_HINT_QDEL

/obj/machinery/nuclearbomb/nostromo/process()
	. = ..()
	if(!undock_try && timeleft < 300) // AUTO EVAC AFTER 5 MINUTE
		MM.undock_shuttle()
		undock_try = TRUE

/obj/machinery/nuclearbomb/nostromo/ui_interact(mob/user)
	return

/obj/machinery/nuclearbomb/nostromo/attackby(obj/item/weapon/O, mob/user)
	return

/obj/machinery/nostromo/nuclear_starter
	name = "self-destruct mechanism"
	desc = "Self-destruct mechanism switch."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	use_power = NO_POWER_USE
	anchored = TRUE
	resistance_flags = FULL_INDESTRUCTIBLE
	unacidable = TRUE
	var/locked = TRUE
	var/datum/map_module/alien/MM = null
	var/on = FALSE

/obj/machinery/nostromo/nuclear_starter/atom_init()
	. = ..()
	MM = SSmapping.get_map_module_by_name(MAP_MODULE_ALIEN)
	if(MM)
		MM.nuke_starter = src
	else
		return INITIALIZE_HINT_QDEL

/obj/machinery/nostromo/nuclear_starter/proc/unlock()
	locked = FALSE

/obj/machinery/nostromo/nuclear_starter/attack_hand(mob/user)
	. = ..()
	user.SetNextMove(CLICK_CD_INTERACT)
	if(locked)
		to_chat(user, "<span class='warning'>Механизм самоуничтожения заблокирован.</span>")
		return
	if(on)
		to_chat(user, "<span class='warning'>Механизм самоуничтожения запущен, он не может быть отменён!</span>")
		return

	if(do_after(user, 1 SECOND, TRUE, src))
		icon_state = "switch-fwd"
		on = TRUE
		MM.nuke_set()

/////////////////////////////////////////////////////////////////////////////////////
//			HYDROPONIC
/obj/machinery/hydroponics/nostromo
	icon_state = "hydrotray3"
	resistance_flags = FULL_INDESTRUCTIBLE
	unacidable = TRUE
	var/datum/map_module/alien/MM = null

/obj/machinery/hydroponics/nostromo/atom_init()
	. = ..()
	MM = SSmapping.get_map_module_by_name(MAP_MODULE_ALIEN)
	if(!MM)
		return INITIALIZE_HINT_QDEL
	else
		MM.hydro = src

/obj/machinery/hydroponics/nostromo/attack_alien(mob/living/carbon/xenomorph/user)
	if(!istype(myseed, /obj/item/seeds/kudzuseed/alien))
		if(planted)
			to_chat(user, "<span class='notice'>You remove the plant from [src].</span>")
			planted = FALSE
			dead = FALSE
			qdel(myseed)
			update_icon()
		else
			to_chat(user, "<span class='notice'>You plant the alien weed.</span>")
			plant_alien_weed()

/obj/machinery/hydroponics/nostromo/proc/plant_alien_weed()
	if(istype(myseed, /obj/item/seeds/kudzuseed/alien))
		return
	myseed = new /obj/item/seeds/kudzuseed/alien
	planted = TRUE
	waterlevel = maxwater
	nutrilevel = maxnutri
	age = 0
	health = myseed.endurance
	lastcycle = world.time
	harvest = FALSE
	weedlevel = 0
	pestlevel = 0
	update_icon()
	if(MM)
		addtimer(CALLBACK(MM, TYPE_PROC_REF(/datum/map_module/alien, AI_announce), "alien_weed"), 1 MINUTE)

/////////////////////////////////////////////////////////////////////////////////////
//			AI MU/TH/UR
/mob/living/silicon/decoy/nostromo
	name = "MU/TH/UR"
	icon_state = "ai"

/mob/living/silicon/decoy/nostromo/atom_init()
	. = ..()
	var/datum/map_module/alien/MM = SSmapping.get_map_module_by_name(MAP_MODULE_ALIEN)
	if(!MM)
		return INITIALIZE_HINT_QDEL
	else
		MM.ai = src

/mob/living/silicon/decoy/nostromo/proc/announce(announce)
	switch(announce)
		if("smes")
			say("Внимание! Бортовой ИИ фиксирует резкие скачки напряжения на основной энергоячейке корабля, необходимо срочно выяснить и устранить причину неполадки!")
		if("alien_weed")
			say("Внимание! В ботанике обнаружено неопознанное растение, необходимо срочное вмешательство экипажа!")
		if("cockpit")
			say("Внимание! Прямо по курсу большое скопление заряженных частиц, необходимо срочно сменить курс корабля!")
		if("cargo")
			say("Внимание! В связи с высокой смертностью среди экипажа, на склад было возвращено электропитание.")
		if("evac")
			say("Внимание! В связи с крайне высокой смертностью среди экипажа, ИИ разблокировал механизм самоуничтожения корабля.")
		if("nuke")
			say("Внимание! Запущен механизм самоуничтожения корабля, всему экипажу следует срочно проследовать на шаттл эвакуации!")

/////////////////////////////////////////////////////////////////////////////////////
//			RITEG
/obj/machinery/power/port_gen/riteg/nostromo
	rad_cooef = 80
	power_gen = 50000
	resistance_flags = FULL_INDESTRUCTIBLE

/////////////////////////////////////////////////////////////////////////////////////
//			SMES
/obj/machinery/power/smes/nostromo
	resistance_flags = FULL_INDESTRUCTIBLE
	unacidable = TRUE
	var/datum/map_module/alien/MM = null
	var/stability = 8
	var/next_stability_decrease = 0
	var/next_alien_attack
	var/next_instrument
	var/list/instruments = list(
		/obj/item/device/multitool,
		/obj/item/stack/cable_coil,
		/obj/item/weapon/weldingtool,
		/obj/item/weapon/screwdriver,
		/obj/item/weapon/crowbar,
		/obj/item/weapon/wrench)
	var/list/explosions = list()

/obj/machinery/power/smes/nostromo/atom_init()
	..()
	MM = SSmapping.get_map_module_by_name(MAP_MODULE_ALIEN)
	if(!MM)
		return INITIALIZE_HINT_QDEL
	else
		MM.smes = src

	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(round_start))

	stability = rand(6, 8)
	next_instrument = pick(instruments)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/power/smes/nostromo/atom_init_late()
	var/list/around = orange(src, 5)
	explosions += locate(/obj/machinery/power/port_gen/riteg) in around
	explosions += locate(/obj/machinery/power/apc/smallcell/nostromo) in around
	explosions += src

/obj/machinery/power/smes/nostromo/proc/round_start()
	next_stability_decrease = world.time + rand(120, 140) SECOND
	UnregisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING)

/obj/machinery/power/smes/nostromo/process(seconds_per_tick)
	..()
	if(world.time > next_stability_decrease)
		next_stability_decrease += rand(120, 140) SECOND
		stability--
		if(!stability)
			MM.breakdown()
		if(stability in 1 to 2) // 2 and 4 minute before breakdown AI gives an alert
			MM.AI_announce("smes")

	switch(stability)
		if(4 to 7)
			do_shake_animation(1, seconds_per_tick SECONDS, 1)
		if(1 to 3)
			do_shake_animation(2, seconds_per_tick SECONDS, 1)


/obj/machinery/power/smes/nostromo/attack_alien(mob/user)
	if(world.time > next_alien_attack)
		next_alien_attack = world.time + 8 MINUTE
		stability--
		user.do_attack_animation(src)
		user.SetNextMove(CLICK_CD_MELEE)
		playsound(loc, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER, 100, TRUE)
	else
		to_chat(src, "<span class='notice'>Ещё не время для этого.</span>")
		return

/obj/machinery/power/smes/nostromo/explode()
	for(var/obj/O in explosions)
		explosion(get_turf(O), 0, 0, 2)
		qdel(O)

/obj/machinery/power/smes/nostromo/examine(mob/user, distance)
	..()
	if(distance > 4)
		return
	if(stability >= 8)
		to_chat(user, "<span class='notice'>СМЕС работает стабильно.</span>")
		return
	var/message
	switch(next_instrument)
		if(/obj/item/device/multitool)
			message = pick("На экране отчаянно мигает красная лампочка и скачет синусоида напряжения.",
						"Изнутри слышится еле различимый писк дросселей, вибрирующих от напряжения.")
		if(/obj/item/stack/cable_coil)
			message = pick("В некоторых местах проводов поплавилась изоляция, выглядят они не важно.",
						"Изнутри доносится лёгкий запах гари и торчат провода.",
						"Пара почерневших проводов свободно болтается внутри.")
		if(/obj/item/weapon/weldingtool)
			message = pick("На поверхности СМЕСа зияет большая трещина.",
						"Техническая панель раскололась на две части.")
		if(/obj/item/weapon/screwdriver)
			message = pick("Несколько болтов валяются неподалеку, вероятно выпали из-за вибрации.",
						"Техническая панель тихонько болтается туда-сюда, держась на одном болте.",
						"Внутри СМЕСа что-то еле различимо гремит.")
		if(/obj/item/weapon/crowbar)
			message = pick("На технической панели виднеется огромная вмятина.",
						"Одна из пластин корпуса очень сильно погнулась.")
		if(/obj/item/weapon/wrench)
			message = pick("От исходящей вибрации, на болтах ходуном ходят гайки.",
						"Корпус СМЕСа весь шатается от вибрации.",
						"СМЕС елозит туда-сюда по земле и трясётся от вибрации.")
	to_chat(user, "<span class='notice'>[message]</span>")

/obj/machinery/power/smes/nostromo/attackby(obj/item/I, mob/user)
	if(stability < 8)
		if(istype(I, next_instrument))
			if(istype(I, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = I
				if(!WT.active)
					to_chat(user, "<span class='notice'>Сначала включите сварку.</span>")
					return
			if(do_after(user, 2 SECOND, target = src))
				if(stability <= 2 && prob(50))
					shock(user)
				to_chat(user, "<span class='notice'>Вы успешно ремонтируете СМЕС.</span>")
				next_instrument = pick(instruments - next_instrument)
				stability++
		else
			to_chat(user, "<span class='notice'>Не тот инструмент.</span>")
	else
		to_chat(user, "<span class='notice'>СМЕС работает стабильно.</span>")

/obj/machinery/power/smes/nostromo/proc/shock(mob/user)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	electrocute_mob(user, get_area(src), src)

/////////////////////////////////////////////////////////////////////////////////////
//			APC
/obj/machinery/power/apc/smallcell/nostromo
	resistance_flags = FULL_INDESTRUCTIBLE
	unacidable = TRUE

/obj/machinery/power/apc/smallcell/nostromo/ex_act(severity)
	return

/obj/machinery/power/apc/smallcell/nostromo/attackby(obj/item/W, mob/user)
	if(iscoil(W))
		var/turf/TT = get_turf(src)
		if(TT.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
			to_chat(user, "<span class='warning'>Вскройте пол перед [CASE(src, ABLATIVE_CASE)].</span>")
			return
		var/obj/item/stack/cable_coil/C = W
		if(C.get_amount() < 2)
			to_chat(user, "<span class='warning'>Нужно больше проводов.</span>")
			return
		if(user.is_busy()) return
		to_chat(user, "Вы вставляете провода в [CASE(src, ACCUSATIVE_CASE)].")
		if(C.use_tool(src, user, 20, volume = 50))
			C.use(2)
			user.visible_message(\
				"<span class='warning'>[user.name] подключил проводку в [CASE(src, PREPOSITIONAL_CASE)]!</span>",\
				"Вы подключили проводку в [CASE(src, PREPOSITIONAL_CASE)].")
			make_terminal()
			terminal.connect_to_network()
	return

/////////////////////////////////////////////////////////////////////////////////////
//			AMBIENCE
/obj/effect/landmark/ambience/nostromo
	name = "Nostromo Ambience"
	ambience = list(
		'sound/antag/Alien_sounds/alien_ambience1.ogg',
		'sound/antag/Alien_sounds/alien_ambience2.ogg',
		'sound/antag/Alien_sounds/alien_ambience3.ogg',
		'sound/antag/Alien_sounds/alien_ambience4.ogg',
		'sound/antag/Alien_sounds/alien_ambience5.ogg',
		'sound/antag/Alien_sounds/alien_ambience6.ogg')

/obj/effect/landmark/ambience/nostromo/atom_init()
	. = ..()
	var/datum/map_module/alien/MM = SSmapping.get_map_module_by_name(MAP_MODULE_ALIEN)
	if(MM)
		MM.ambience_player = src

/obj/effect/landmark/ambience/nostromo/round_start()
	current_ambience = ambience[1]
	play_current_ambience()
	. = ..()

/////////////////////////////////////////////////////////////////////////////////////
//			LANDMARKS
/obj/effect/landmark/nostromo/atom_init()
	. = ..()
	if(!SSmapping.get_map_module_by_name(MAP_MODULE_ALIEN))
		return INITIALIZE_HINT_QDEL

/obj/effect/landmark/nostromo/supply_crate
	name = "Nostromo Supply Crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "secgearcrate"

/obj/effect/landmark/nostromo/jonesy
	name = "Jonesy"
	icon = 'icons/mob/animal.dmi'
	icon_state = "red_cat"
	dir = 4

/obj/effect/landmark/nostromo/cargo_blockway
	name = "Nostromo Cargo Blockway"
	density = 1

/obj/effect/landmark/nostromo/cargo_blockway/Bumped(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/L = AM
		to_chat(L, "На время полёта склад держат обесточенным для экономии электроэнергии, нет никакого смысла сейчас идти туда.")

/obj/effect/landmark/nostromo/random_loot
	name = "Nostromo Random Loot"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_loot"
	layer = 3
