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

	map_lobby_image = 'html/media/lobby_alien.png'
	map_lobby_music = 'sound/lobby/alien_main.ogg'

	admin_verbs = list(
		/datum/map_module/alien/proc/ivent_info,
		/datum/map_module/alien/proc/open_cargo,
		/datum/map_module/alien/proc/open_evac,
		/datum/map_module/alien/proc/give_crew_signal,
		/datum/map_module/alien/proc/give_alien_signal,
		/datum/map_module/alien/proc/breakdown,
		/datum/map_module/alien/proc/AI_announce,
		/datum/map_module/alien/proc/plant_seed,
		/datum/map_module/alien/proc/play_ambience,
		/datum/map_module/alien/proc/delay_ambience,
		/datum/map_module/alien/proc/lights_blinking,
		/datum/map_module/alien/proc/smes_stability,
		/datum/map_module/alien/proc/ship_course,
		/datum/map_module/alien/proc/give_epoint,
		/datum/map_module/alien/proc/next_estage,
		/datum/map_module/alien/proc/set_slaughter_mode)

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

//			IVENT INFO
/datum/map_module/alien/proc/ivent_info()
	set category = "Event"
	set name = "Alien: Ivent Info"

//			OPEN CARGO
/datum/map_module/alien/proc/open_cargo()
	set category = "Event"
	set name = "Alien: Open Cargo"

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

//			OPEN EVAC
/datum/map_module/alien/proc/open_evac()
	set category = "Event"
	set name = "Alien: Open Evac"

	if(!evac_open)
		nukebomb.unlock()
		AI_announce("evac")
		give_crew_signal("Мы должны эвакуироваться! Нужно запустить механизм самоуничтожения!")

//			MESSAGE FOR CREW
/datum/map_module/alien/proc/give_crew_signal(message)
	set category = "Event"
	set name = "Alien: Crew Message"

	if(!message)
		message = input("Введите сообщение, которое вы хотите передать экипажу.", "Сообщение") as text|null

	for(var/mob/living/carbon/human/H as anything in crew_faction.crew)
		if(H.stat != DEAD)
			var/scary_sound = pick('sound/hallucinations/scary_sound_1.ogg',
				'sound/hallucinations/scary_sound_2.ogg',
				'sound/hallucinations/scary_sound_3.ogg',
				'sound/hallucinations/scary_sound_4.ogg')
			H.playsound_local(null, scary_sound, VOL_EFFECTS_MASTER, null, FALSE, ignore_environment = TRUE)
			to_chat(H, "<span class='warning'>[message]</span>")

//			MESSAGE FOR ALIEN
/datum/map_module/alien/proc/give_alien_signal(message)
	set category = "Event"
	set name = "Alien: Alien Message"

	if(!message)
		message = input("Введите сообщение, которое вы хотите передать ксеноморфу.", "Сообщение") as text|null

	var/scary_sound = pick('sound/hallucinations/scary_sound_1.ogg',
		'sound/hallucinations/scary_sound_2.ogg',
		'sound/hallucinations/scary_sound_3.ogg',
		'sound/hallucinations/scary_sound_4.ogg')
	alien.playsound_local(null, scary_sound, VOL_EFFECTS_MASTER, null, FALSE, ignore_environment = TRUE)
	to_chat(alien, "<span class='warning'>[message]</span>")

//			SHIP BREAKDOWN
/datum/map_module/alien/proc/breakdown(admin = TRUE)
	set category = "Event"
	set name = "!Alien: Ship Breakdown!"

	if(breakdown)
		return
	if(admin)
		if(tgui_alert("Поломка корабля означает конец игры для экипажа!", "Вы уверены?", list("Да", "Нет")) != "Да")
			return

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

//			AI ANNOUNCE
/datum/map_module/alien/proc/AI_announce(code)
	set category = "Event"
	set name = "Alien: AI Announce"

	var/admin_announce = FALSE
	if(!code)
		code = input("Введите сообщение, которое должен произнести бортовой ИИ.", "Сообщение") as text|null
		admin_announce = TRUE

	ai.announce(code, admin_announce)

//			PLANT ALIEN SEED IN BOTANY
/datum/map_module/alien/proc/plant_seed()
	set category = "Event"
	set name = "Alien: Alien Weed"

	hydro.plant_alien_weed()

//			PLAY NEXT AMBIENCE NOW
/datum/map_module/alien/proc/play_ambience()
	set category = "Event"
	set name = "Alien: Play Ambience"

	ambience_player.ambience_next_time = world.time

//			DELAY NEXT AMBIENCE
/datum/map_module/alien/proc/delay_ambience(delay)
	set category = "Event"
	set name = "Alien: Delay Ambience"

	if(!delay)
		delay = input("На сколько секунд вы хотите отсрочить эмбиенс?", "Значение") as num|null
		delay = delay SECONDS
	ambience_player.ambience_next_time += delay

//			LIGHTS BLINKING FOR SUSPENSE
/datum/map_module/alien/proc/lights_blinking()
	set category = "Event"
	set name = "Alien: Lights Blinking"

//			CHANGE SMES STABILITY
/datum/map_module/alien/proc/smes_stability()
	set category = "Event"
	set name = "Alien: SMES Stability"

	smes.stability = input("Какое значение стабильности установить СМЕСу?", "Значение", smes.stability) as num|null

//			CHANGE SHIP COURSE
/datum/map_module/alien/proc/ship_course()
	set category = "Event"
	set name = "Alien: Ship Course"

	console.course = input("Какое значение наклона установить первой консоли?", "Значение", console.course) as num|null
	console.second_console.course = input("Какое значение наклона установить второй консоли?", "Значение", console.second_console.course) as num|null

//			GIVE ALIEN EVOLUTION POINT
/datum/map_module/alien/proc/give_epoint()
	set category = "Event"
	set name = "Alien: Give Epoint"

	alien.give_epoint(input("Сколько очков эволюции вручить ксеноморфу?", "Значение") as num|null)

//			ALIEN NEXT EVOLUTION STAGE
/datum/map_module/alien/proc/next_estage()
	set category = "Event"
	set name = "Alien: Next Estage"

	alien.next_stage()

//			SET ALIEN SLAUGHTER MODE
/datum/map_module/alien/proc/set_slaughter_mode()
	set category = "Event"
	set name = "!Alien: Slaughter Mode!"

	if(!alien)
		return
	if(tgui_alert("Ксеноморф перейдёт в свою терминальную стадию!", "Вы уверены?", list("Да", "Нет")) != "Да")
		return
	alien.set_slaughter_mode()

//			ROUND END WHEN ALIEN DIED
/datum/map_module/alien/proc/alien_appeared(mob/M)
	RegisterSignal(M, list(COMSIG_MOB_DIED, COMSIG_PARENT_QDELETING), PROC_REF(alien_died))
	if(isxenolarva(M))
		larva = M
	else if(isxenolonehunter(M))
		UnregisterSignal(larva, list(COMSIG_MOB_DIED, COMSIG_PARENT_QDELETING)) // LARVA EVOLVE - NOT DIED
		alien = M

/datum/map_module/alien/proc/alien_died(mob/M)
	UnregisterSignal(M, list(COMSIG_MOB_DIED, COMSIG_PARENT_QDELETING))
	alien_alive = FALSE
	crew_faction.round_end = TRUE

/datum/map_module/alien/proc/nuke_detonate()
	nukebomb.detonate()

/datum/map_module/alien/proc/get_cargo_loot()
	return pick(
		list( // incendiary shotguns
			/obj/item/weapon/gun/projectile/shotgun/incendiary,
			/obj/item/weapon/gun/projectile/shotgun/incendiary,
			/obj/item/ammo_box/eight_shells/incendiary,
			/obj/item/ammo_box/eight_shells/incendiary,
			/obj/item/clothing/suit/armor/vest/fullbody,
			/obj/item/clothing/suit/armor/vest/fullbody,
			/obj/item/clothing/head/helmet,
			/obj/item/clothing/head/helmet,
			/obj/item/weapon/shield/riot),
		list( // crossbows and tactical bolas
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
		list( // mining equipment
			/obj/item/weapon/sledgehammer,
			/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill,
			/obj/item/weapon/gun/energy/laser/cutter,
			/obj/item/weapon/gun/energy/laser/cutter,
			/obj/item/clothing/suit/space/globose/mining,
			/obj/item/clothing/suit/space/globose/mining,
			/obj/item/clothing/head/helmet/space/globose/mining,
			/obj/item/clothing/head/helmet/space/globose/mining,
			/obj/item/weapon/storage/box/autoinjector/stimpack))
