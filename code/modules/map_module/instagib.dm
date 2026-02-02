
/datum/map_module/instagib
	name = MAP_MODULE_INSTAGIB

	default_event_name = "Instagib Deathmatch"
	default_event_message = "Ивент Инстагиб. Добро пожаловать в чистилище."

	gamemode = "Extended"
	config_disable_random_events = TRUE
	config_use_spawners_lobby = TRUE
	disable_default_spawners = TRUE

	admin_verbs = list(
		/client/proc/instagib_load_arena,
		/client/proc/instagib_stop_music,
		/client/proc/instagib_play_music,
		/client/proc/instagib_next_music,
		/client/proc/instagib_change_end_time
	)

	var/datum/faction/faction
	var/datum/spawner/instagib/spawner
	var/list/mob/living/carbon/human/sinners = list()
	var/datum/map_template/arena/instagib/arena = null

	var/music_id = 1
	var/music_play = TRUE
	var/list/music_loops = list(
		"sound/music/IG DnB loop.ogg",
		"sound/music/IG Break loop.ogg",
		"sound/music/IG Break loop 2.ogg"
	)

	var/end_time = 0

/datum/map_module/instagib/New()
	..()
	faction = create_custom_faction(INSTAGIB_FACTION, INSTAGIB_FACTION, "instagib", "Сражайтесь покуда бьётся сердце.")
	spawner = create_spawner(/datum/spawner/instagib, src)

	addtimer(CALLBACK(src, PROC_REF(pick_arena)), 1 MINUTE) // waiting for players
	music_id = rand(1, length(music_loops))

	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(start_timer))

/datum/map_module/instagib/proc/start_timer()
	end_time = world.time + 10 MINUTE
	START_PROCESSING(SSobj, src)

/datum/map_module/instagib/process()
	if(world.time >= end_time)
		STOP_PROCESSING(SSobj, src)
		end_dm()

////////////////////////////////////////
//			LOAD ARENA
/datum/map_module/instagib/proc/pick_arena()
	if(arena)
		return

	var/online = SSticker.totalPlayers
	var/list/arenas = list()

	for(var/datum/map_template/arena/A as anything in subtypesof(/datum/map_template/arena/instagib))
		if(A.spawners && (A.spawners > online) && (A.spawners <= (online + 10)))
			arenas += A

	var/datum/map_template/arena/picked_arena = /datum/map_template/arena/instagib/four_biomes
	if(arenas.len)
		picked_arena = pick(arenas)

	load_arena(picked_arena)

/datum/map_module/instagib/proc/load_arena(datum/map_template/arena/A)
	if(arena) // clear arena if it was previously loaded
		for(var/turf/T in block(locate(arena.bounds[MAP_MINX], arena.bounds[MAP_MINY], arena.bounds[MAP_MINZ]),
	                   		   locate(arena.bounds[MAP_MAXX], arena.bounds[MAP_MAXY], arena.bounds[MAP_MAXZ])))
			for(var/obj/O in T)
				if(!istype(O, /obj/effect/landmark/instagib_arena/purgatory))
					qdel(O)

	arena = new A
	var/turf/arena_location = pick_landmarked_location("Purgatory Spawn", least_used = FALSE)

	if(!arena.load(arena_location, centered = TRUE))
		CRASH("Loading arena map [arena.name] - [arena.mappath] failed!")

////////////////////////////////////////
//			PLAYERS HANDLING
/datum/map_module/instagib/proc/assign_to_faction(mob/living/carbon/human/H)
	var/datum/role/old_role = H.mind.GetRoleByType(/datum/role/custom)
	if(old_role)
		old_role.Drop(msg_admins = FALSE)

	var/datum/role/custom/instagib_sinner = new
	instagib_sinner.name = INSTAGIB_ROLE
	instagib_sinner.id = INSTAGIB_ROLE
	instagib_sinner.skillset_type = /datum/skillset/jack_of_all_trades
	instagib_sinner.AssignToFaction(faction)
	instagib_sinner.AssignToRole(H.mind, msg_admins = FALSE)
	instagib_sinner.AppendObjective(new /datum/objective/custom("Соверши как можно больше расправ над другими грешниками."))

	sinners[H] = 0
	H.playsound_music(music_loops[music_id], VOL_MUSIC, TRUE, null, CHANNEL_MUSIC)

	// gamemode will do this for first roll players, and we need to do this for latespawn roles
	// todo: wrap it somehow too
	if(SSticker.current_state >= GAME_STATE_PLAYING)
		setup_role(instagib_sinner)

////////////////////////////////////////
//			STATS
/datum/map_module/instagib/stat_entry(mob/M)
	if(M.client.holder)
		if(world.time < end_time)
			stat(null, "Времени до конца: [(end_time - world.time) / 10]")
		for(var/mob/living/carbon/human/sinner in sinners)
			stat(null, "[sinner]: [sinners[sinner]]")

////////////////////////////////////////
//			KILLS HANDLING
/datum/map_module/instagib/proc/kill(mob/living/victim, mob/living/killer, points)
	if(!victim.client || victim.has_status_effect(STATUS_EFFECT_INSTAGIB_KILLED))
		return

	victim.nutrition = NUTRITION_LEVEL_WELL_FED
	killer.nutrition = NUTRITION_LEVEL_WELL_FED

	playsound(victim.loc, 'sound/effects/projectiles_acts/laser_1.ogg', VOL_EFFECTS_MASTER)
	new /obj/effect/temp_visual/cult/blood/out(victim.loc)

	victim.forceMove(pick_landmarked_location("Sinner Spawn"))
	victim.apply_status_effect(STATUS_EFFECT_INSTAGIB_KILLED)

	// No points for respawn kills and suicide
	if(victim == killer || victim.has_status_effect(STATUS_EFFECT_INSTAGIB_SPAWNED) || killer.has_status_effect(STATUS_EFFECT_INSTAGIB_SPAWNED))
		return

	sinners[killer] += points
	sortTim(sinners, GLOBAL_PROC_REF(cmp_numeric_dsc), TRUE)

	switch(points)
		if(1) // laser
			print_message(pick(
				"[victim] попытался поймать луч [killer] руками.",
				"[killer] испепелил [victim].",
				"[victim] стал ярким источником света благодаря [killer].",
				"[killer] поразил [victim].",
				"[victim] рассыпался от луча [killer].",
				"[killer] аннигилировал [victim].",
				"[killer] обратил [victim] в облачко ионов."))
		if(2) // headshot
			print_message(pick(
				"[killer] вложил луч в мыслительный центр [victim].",
				"[killer] провёл лазерную трепанацию [victim].",
				"Череп [victim] не выдержал интеллектуального аргумента [killer].",
				"[killer] нашёл самый быстрый способ достучаться до сознания [victim].",
				"[killer] снёс [victim] черепушку.",
				"[killer] попал [victim] в голову."))
		if(3) // melee
			print_message(pick(
				"[killer] провёл [victim] финальную черту своим клинком",
				"[killer] перерезал нить судьбы [victim].",
				"[killer] закрыл гештальт [victim] холодной сталью.",
				"[killer] вскрыл череп [victim] своим лезвием."))

/datum/map_module/instagib/proc/print_message(message)
	notify_ghosts(message)
	for(var/mob/living/carbon/human/sinner in sinners)
		to_chat(sinner, message)

////////////////////////////////////////
//			MUSIC CONTROL
/datum/map_module/instagib/proc/stop_music()
	music_play = FALSE
	for(var/mob/living/carbon/human/sinner in sinners)
		sinner.playsound_stop(CHANNEL_MUSIC)

/datum/map_module/instagib/proc/play_music()
	music_play = TRUE
	for(var/mob/living/carbon/human/sinner in sinners)
		sinner.playsound_music(music_loops[music_id], VOL_MUSIC, TRUE, null, CHANNEL_MUSIC)

/datum/map_module/instagib/proc/next_music()
	music_id += 1
	if(music_id > length(music_loops))
		music_id = 1
	stop_music()
	play_music()

////////////////////////////////////////
//			END DEATHMATCH
/datum/map_module/instagib/proc/end_dm()
	sortTim(sinners, GLOBAL_PROC_REF(cmp_numeric_dsc), TRUE)
	var/max_points = sinners[sinners[1]]

	for(var/mob/living/carbon/human/sinner in sinners)
		for(var/item in sinner.get_equipped_items())
			qdel(item)

		if(sinners[sinner] == max_points)
			var/datum/role/custom/instagib_sinner = sinner.mind.GetRole(INSTAGIB_ROLE)
			var/list/datum/objective/objectives = instagib_sinner.GetObjectives()
			objectives[1].completed = OBJECTIVE_WIN
			sinner.forceMove(pick_landmarked_location("Winner Spawn"))
			sinner.equipOutfit(/datum/outfit/instagib/winner)
		else
			sinner.forceMove(pick_landmarked_location("Looser Spawn"))
			sinner.equipOutfit(/datum/outfit/instagib/looser)

	stop_music()
	SSticker.force_end = TRUE

////////////////////////////////////////
//			ADMIN VERBS
/client/proc/instagib_load_arena()
	set category = "Event"
	set name = "Instagib: Load Arena"

	var/list/arenas = list()

	for(var/i in subtypesof(/datum/map_template/arena/instagib))
		var/datum/map_template/arena/A = i
		arenas[A.name] = A

	var/choice = input("Select the arena") as null|anything in arenas
	if(!choice) return

	var/datum/map_template/arena/instagib/arena = arenas[choice]
	log_admin("[key_name(src)] load instagib arena map [arena.name] - [arena.mappath]")
	message_admins("[key_name_admin(src)] load instagib arena map [arena.name] - [arena.mappath]")

	var/datum/map_module/instagib/MM = SSmapping.get_map_module(MAP_MODULE_INSTAGIB)
	MM.load_arena(arena)

//			MUSIC CONTROL
/client/proc/instagib_stop_music()
	set category = "Event"
	set name = "Instagib: Stop Music"

	var/datum/map_module/instagib/MM = SSmapping.get_map_module(MAP_MODULE_INSTAGIB)
	MM.stop_music()

/client/proc/instagib_play_music()
	set category = "Event"
	set name = "Instagib: Play Music"

	var/datum/map_module/instagib/MM = SSmapping.get_map_module(MAP_MODULE_INSTAGIB)
	MM.play_music()

/client/proc/instagib_next_music()
	set category = "Event"
	set name = "Instagib: Next Music"

	var/datum/map_module/instagib/MM = SSmapping.get_map_module(MAP_MODULE_INSTAGIB)
	MM.next_music()

/client/proc/instagib_change_end_time()
	set category = "Event"
	set name = "Instagib: Change Time To End"

	if(SSticker.current_state < GAME_STATE_PLAYING)
		return tgui_alert(usr, "Дезматч ещё не начался.")

	var/datum/map_module/instagib/MM = SSmapping.get_map_module(MAP_MODULE_INSTAGIB)
	if(world.time > MM.end_time)
		return tgui_alert(usr, "Дезматч уже закончился.")

	var/newtime = input("Введите в секундах новое число для длительности дезматча.","Set Delay", MM.end_time / 10) as num|null
	if(newtime)
		MM.end_time = world.time + newtime
