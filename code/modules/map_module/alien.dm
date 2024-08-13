/datum/map_module/alien
	name = MAP_MODULE_ALIEN

	default_event_name = "Alien"
	default_event_message = {"Режим Alien, сделанный по мотивам одноименного фильма 1979 года.
	In Space, No One Can Hear You Scream."}

	gamemode = "Alien"
	config_disable_random_events = TRUE
	config_disable_station_announce = TRUE
	config_event_cryopod_latejoin = TRUE
	config_disable_loadout = TRUE
	config_disable_qualities = TRUE
	human_delay = 0.2

	map_lobby_image = 'html/media/lobby_alien.png'
	map_lobby_music = 'sound/lobby/alien_main.ogg'

	admin_verbs = list(
		/client/proc/nostromo_ivent_info,
		/client/proc/nostromo_open_cargo,
		/client/proc/nostromo_open_evac,
		/client/proc/nostromo_give_crew_signal,
		/client/proc/nostromo_play_ambience,
		/client/proc/nostromo_delay_ambience,
		/client/proc/nostromo_lights_blinking,
		/client/proc/nostromo_smes_stability,
		/client/proc/nostromo_ship_course)

	var/cargo_open = FALSE
	var/evac_open = FALSE

	var/breakdown = FALSE
	var/alien_alive = TRUE
	var/deadcrew_ratio = 1

	var/obj/effect/landmark/ambience/nostromo/ambience_player = null
	var/obj/machinery/nuclearbomb/nostromo/nukebomb = null
	var/obj/machinery/power/smes/nostromo/smes = null
	var/obj/machinery/computer/nostromo/cockpit/console = null
	var/obj/machinery/hydroponics/nostromo/hydro = null
	var/mob/living/silicon/decoy/nostromo/ai = null
	var/mob/living/carbon/xenomorph/larva/lone/larva = null
	var/mob/living/carbon/xenomorph/humanoid/hunter/lone/alien = null

	var/datum/faction/nostromo_crew/crew_faction = null

	var/list/random_loot = list(
		/obj/item/weapon/legcuffs/bola,
		/obj/item/device/radio/off,
		/obj/item/device/radio/off,
		/obj/item/device/radio/off,
		/obj/item/device/flashlight,
		/obj/item/device/flashlight,
		/obj/item/device/flashlight/seclite,
		/obj/item/stack/sheet/cloth/three,
		/obj/item/stack/sheet/cloth/three,
		/obj/item/weapon/grenade/chem_grenade/antiweed,
		/obj/item/weapon/grenade/cancasing/rag,
		/obj/item/weapon/kitchenknife/combat,
		/obj/item/weapon/storage/toolbox/mechanical)

//			RANDOM LOOT SPAWN
/datum/map_module/alien/proc/spawn_loot()
	var/list/landmarks = landmarks_list["Nostromo Random Loot"]
	while(landmarks.len && random_loot.len)
		var/obj/landmark = pick(landmarks)
		var/obj/loot = pick(random_loot)
		new loot(landmark.loc)
		random_loot -= loot
		qdel(landmark)

/////////////////////////////////////////////////////////////////////////////////////
//			IVENT INFO
/client/proc/nostromo_ivent_info()
	set category = "Event"
	set name = "Alien: Ivent Info"

/////////////////////////////////////////////////////////////////////////////////////
//			OPEN CARGO
/client/proc/nostromo_open_cargo()
	set category = "Event"
	set name = "Alien: Open Cargo"
	var/datum/map_module/alien/MM = SSmapping.get_map_module(MAP_MODULE_ALIEN)
	MM.open_cargo()

/datum/map_module/alien/proc/open_cargo()
	if(!cargo_open)
		cargo_open = TRUE
		for(var/obj/BW as anything in landmarks_list["Nostromo Cargo Blockway"])
			qdel(BW)
		AI_announce("cargo")
		spawn_crate()

/datum/map_module/alien/proc/spawn_crate()
	var/supply_point = pick(landmarks_list["Nostromo Supply Crate"])
	var/obj/structure/closet/crate/secure/gear/SC = new (get_turf(supply_point))
	SC.req_access = list(access_cargo)
	SC.anchored = 1
	var/crate_contains = get_cargo_loot()
	for(var/item in crate_contains)
		new item(SC)
	give_crew_signal("На корабль перед отлётом грузили ящики и контейнеры, где-то на складе может быть оружие!")

/////////////////////////////////////////////////////////////////////////////////////
//			OPEN EVAC
/client/proc/nostromo_open_evac()
	set category = "Event"
	set name = "Alien: Open Evac"
	var/datum/map_module/alien/MM = SSmapping.get_map_module(MAP_MODULE_ALIEN)
	MM.open_evac()

/datum/map_module/alien/proc/open_evac()
	if(!evac_open)
		nukebomb.unlock()
		AI_announce("evac")
		give_crew_signal("Мы должны эвакуироваться! Нужно запустить механизм самоуничтожения!")

/////////////////////////////////////////////////////////////////////////////////////
//			MESSAGE FOR CREW
/client/proc/nostromo_give_crew_signal()
	set category = "Event"
	set name = "Alien: Crew Message"
	var/datum/map_module/alien/MM = SSmapping.get_map_module(MAP_MODULE_ALIEN)
	var/message = input("Введите сообщение, которое вы хотите передать экипажу.", "Сообщение") as text|null
	MM.give_crew_signal(message)

/datum/map_module/alien/proc/give_crew_signal(message)
	if(!message)
		return
	for(var/mob/living/carbon/human/H as anything in crew_faction.crew)
		if(H.stat != DEAD)
			var/scary_sound = pick('sound/hallucinations/scary_sound_1.ogg',
				'sound/hallucinations/scary_sound_2.ogg',
				'sound/hallucinations/scary_sound_3.ogg',
				'sound/hallucinations/scary_sound_4.ogg')
			H.playsound_local(null, scary_sound, VOL_EFFECTS_MASTER, null, FALSE, ignore_environment = TRUE)
			to_chat(H, "<span class='warning'>[message]</span>")

/////////////////////////////////////////////////////////////////////////////////////
//			AI ANNOUNCE
/datum/map_module/alien/proc/AI_announce(code)
	ai.announce(code)

/////////////////////////////////////////////////////////////////////////////////////
//			PLAY NEXT AMBIENCE NOW
/client/proc/nostromo_play_ambience()
	set category = "Event"
	set name = "Alien: Play Ambience"
	var/datum/map_module/alien/MM = SSmapping.get_map_module(MAP_MODULE_ALIEN)
	MM.ambience_player.ambience_next_time = world.time

/////////////////////////////////////////////////////////////////////////////////////
//			DELAY NEXT AMBIENCE
/client/proc/nostromo_delay_ambience()
	set category = "Event"
	set name = "Alien: Delay Ambience"
	var/datum/map_module/alien/MM = SSmapping.get_map_module(MAP_MODULE_ALIEN)
	MM.delay_ambience()

/datum/map_module/alien/proc/delay_ambience(delay = 0)
	if(!delay)
		delay = input("На сколько секунд вы хотите отсрочить эмбиенс?", "Значение") as num|null
		delay = delay SECONDS
	ambience_player.ambience_next_time += delay

/////////////////////////////////////////////////////////////////////////////////////
//			LIGHTS BLINKING FOR SUSPENSE
/client/proc/nostromo_lights_blinking()
	set category = "Event"
	set name = "Alien: Lights Blinking"
	var/datum/map_module/alien/MM = SSmapping.get_map_module(MAP_MODULE_ALIEN)
	MM.lights_blinking()

/datum/map_module/alien/proc/lights_blinking()
	for(var/obj/machinery/light/L in global.machines)
		L.flicker(5)

/////////////////////////////////////////////////////////////////////////////////////
//			CHANGE SMES STABILITY
/client/proc/nostromo_smes_stability()
	set category = "Event"
	set name = "Alien: SMES Stability"
	var/datum/map_module/alien/MM = SSmapping.get_map_module(MAP_MODULE_ALIEN)
	MM.smes.stability = input("Какое значение стабильности установить СМЕСу?", "Значение", MM.smes.stability) as num|null

/////////////////////////////////////////////////////////////////////////////////////
//			CHANGE SHIP COURSE
/client/proc/nostromo_ship_course()
	set category = "Event"
	set name = "Alien: Ship Course"
	var/datum/map_module/alien/MM = SSmapping.get_map_module(MAP_MODULE_ALIEN)
	MM.console.course = input("Какое значение наклона установить первой консоли?", "Значение", MM.console.course) as num|null
	MM.console.second_console.course = input("Какое значение наклона установить второй консоли?", "Значение", MM.console.second_console.course) as num|null

/////////////////////////////////////////////////////////////////////////////////////
//			ALIEN REGENERATION
/client/proc/nostromo_alien_regen()
	set category = "Event"
	set name = "Alien: Alien Regen"
	var/datum/map_module/alien/MM = SSmapping.get_map_module(MAP_MODULE_ALIEN)
	if(MM.alien)
		MM.alien.apply_status_effect(STATUS_EFFECT_ALIEN_REGENERATION)

/////////////////////////////////////////////////////////////////////////////////////
//			SHIP BREAKDOWN
/datum/map_module/alien/proc/breakdown()
	breakdown = TRUE
	for(var/mob/M as anything in player_list)
		M.playsound_music('sound/ambience/specific/hullcreak.ogg', VOL_AMBIENT, null, null, CHANNEL_AMBIENT, priority = 160)
	delay_ambience(1 MINUTE)

	smes.explosion()
	console.explosion()
	alien.set_slaughter_mode()

	give_crew_signal("Энергосистема корабля полностью вышла из строя!")
	open_cargo()
	open_evac()

/////////////////////////////////////////////////////////////////////////////////////
//			ROUND END WHEN ALIEN DIED
/datum/map_module/alien/proc/alien_appeared(mob/M)
	RegisterSignal(M, list(COMSIG_MOB_DIED, COMSIG_PARENT_QDELETING), PROC_REF(alien_died))
	if(isxenolarva(M))
		larva = M
	else if(isxenolonehunter(M))
		UnregisterSignal(larva, list(COMSIG_MOB_DIED, COMSIG_PARENT_QDELETING)) // LARVA EVOLVE - NOT DIED
		alien = M
		lights_blinking()
		give_crew_signal("Леденящий ужас спускается по твоему позвоночнику…")

/datum/map_module/alien/proc/alien_died(mob/M)
	UnregisterSignal(M, list(COMSIG_MOB_DIED, COMSIG_PARENT_QDELETING))
	alien_alive = FALSE
	to_chat(world, "<B>2!</B>")
	crew_faction.round_end = TRUE

/datum/map_module/alien/proc/nuke_detonate()
	nukebomb.detonate()

/datum/map_module/alien/proc/get_cargo_loot()
	return pick(
		list(
			/obj/item/weapon/gun/projectile/shotgun/incendiary,
			/obj/item/weapon/gun/projectile/shotgun/incendiary,
			/obj/item/ammo_box/eight_shells/incendiary,
			/obj/item/ammo_box/eight_shells/incendiary,
			/obj/item/clothing/suit/armor/vest/fullbody,
			/obj/item/clothing/suit/armor/vest/fullbody,
			/obj/item/clothing/head/helmet,
			/obj/item/clothing/head/helmet,
			/obj/item/weapon/shield/riot),
		list(
			/obj/item/weapon/crossbow,
			/obj/item/weapon/crossbow,
			/obj/item/stack/rods/ten,
			/obj/item/weapon/wirecutters,
			/obj/item/weapon/stock_parts/cell/super,
			/obj/item/weapon/stock_parts/cell/super,
			/obj/item/clothing/suit/armor/syndilight,
			/obj/item/clothing/suit/armor/syndilight,
			/obj/item/clothing/head/helmet/syndilight,
			/obj/item/clothing/head/helmet/syndilight,
			/obj/item/weapon/legcuffs/bola/tactical,
			/obj/item/weapon/legcuffs/bola/tactical),
		list(
			/obj/item/weapon/sledgehammer,
			/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill,
			/obj/item/weapon/gun/energy/laser/cutter,
			/obj/item/weapon/gun/energy/laser/cutter,
			/obj/item/clothing/suit/space/globose/mining,
			/obj/item/clothing/suit/space/globose/mining,
			/obj/item/clothing/head/helmet/space/globose/mining,
			/obj/item/clothing/head/helmet/space/globose/mining,
			/obj/item/weapon/storage/box/autoinjector/stimpack))
