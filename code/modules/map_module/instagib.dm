
/datum/map_module/instagib
	name = MAP_MODULE_INSTAGIB

	default_event_name = "Instagib Deathmatch"
	default_event_message = "Ивент Инстагиб. Добро пожаловать в чистилище."

	gamemode = "Extended"
	config_disable_random_events = TRUE
	config_use_spawners_lobby = TRUE
	disable_default_spawners = TRUE

	var/datum/faction/faction
	var/datum/spawner/instagib/spawner
	var/list/mob/living/carbon/human/sinners = list()

/datum/map_module/instagib/New()
	..()
	faction = create_custom_faction(INSTAGIB_FACTION, INSTAGIB_FACTION, "instagib", "Сражайтесь покуда бьётся сердце.")
	spawner = create_spawner(/datum/spawner/instagib, src)

	var newtime = 30 SECONDS
	SSticker.timeLeft = newtime
	to_chat(world, "<b>The game will start in [newtime] seconds.</b>")
	log_admin("Instagib Deathmatch set the pre-game delay to [newtime] seconds.")

	addtimer(CALLBACK(src, PROC_REF(load_arena)), 20 SECONDS)

/datum/map_module/instagib/proc/load_arena()
	var/online = global.player_list.len
	var/list/arenas = list()

	for(var/datum/map_template/arena/A as anything in subtypesof(/datum/map_template/arena/instagib))
		if(A.spawners && (A.spawners <= (online + 10)))
			arenas += A

	var/datum/map_template/arena/instagib/arena = /datum/map_template/arena/instagib/four_biomes
	if(arenas.len)
		arena = pick(arenas)

	arena = new arena
	var/turf/arena_location = pick_landmarked_location("Purgatory Spawn", least_used = FALSE)

	if(!arena.load(arena_location, centered = TRUE))
		CRASH("Loading arena map [arena.name] - [arena.mappath] failed!")

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

	sinners[H] = 0

	// gamemode will do this for first roll players, and we need to do this for latespawn roles
	// todo: wrap it somehow too
	if(SSticker.current_state >= GAME_STATE_PLAYING)
		setup_role(instagib_sinner)


/datum/map_module/instagib/stat_entry(mob/M)
	if(M.client.holder)
		for(var/mob/living/carbon/human/sinner in sinners)
			stat(null, "[sinner]: [sinners[sinner]]")


/datum/map_module/instagib/proc/kill(mob/living/victim, mob/living/killer, points)
	respawn(victim)
	// No points for respawn kills.
	if(victim.has_status_effect(STATUS_EFFECT_INSTAGIB_SPAWNED) || killer.has_status_effect(STATUS_EFFECT_INSTAGIB_SPAWNED))
		return

	sinners[killer] += points

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
	for(var/mob/living/carbon/human/sinner in sinners)
		to_chat(sinner, message)

/datum/map_module/instagib/proc/respawn(mob/living/sinner)
	sinner.apply_status_effect(STATUS_EFFECT_INSTAGIB_SPAWNED)
	sinner.forceMove(pick_landmarked_location("Sinner Spawn"))
