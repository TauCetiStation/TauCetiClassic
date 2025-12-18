SUBSYSTEM_DEF(job)
	name = "Jobs"

	init_order = SS_INIT_JOBS

	flags = SS_NO_FIRE
	msg_lobby = "Размещаем вакансии..."

	// list of all jobs
	var/list/datum/job/all_occupations = list()
	// list of map active jobs
	var/list/datum/job/active_occupations = list()
	// dictionary of all jobs, keys are titles
	var/list/name_occupations = list()

	// list of all departments
	var/list/datum/department/departments = list()
	// dictionary of all departments, keys are titles
	var/list/name_departments = list()

	// sorted list of all departments and related occupations (titles)
	var/list/departments_occupations = list()
	// sorted list of heads (titles) and associated departments (objects)
	var/list/heads_positions = list()

	// temporary list of players who needs jobs, for round setup
	var/list/unassigned = list()
	// debug info
	var/list/job_debug = list()

	var/obj/effect/landmark/start/fallback_landmark


/datum/controller/subsystem/job/Initialize(timeofday)
	SSmapping.LoadMapConfig() // Required before SSmapping initialization so we can modify the jobs
	InitLists()
	..()

/datum/controller/subsystem/job/proc/InitLists()
	for(var/D in subtypesof(/datum/department))
		var/datum/department/department = new D()
		departments += department
		name_departments[department.title] = department
		if(department.head)
			heads_positions[department.head] = department
		departments_occupations[department.title] = list()

	for(var/J in subtypesof(/datum/job))
		var/datum/job/job = new J()
		all_occupations += job
		if(job.map_check())
			active_occupations += job
		else
			Debug("Job [job.title] not added because of map setup.")

		name_occupations[job.title] = job
		for(var/department_title in job.departments)
			departments_occupations[department_title] += job.title

	sortTim(departments_occupations, GLOBAL_PROC_REF(cmp_department_titles))
	for(var/dep in departments_occupations)
		sortTim(departments_occupations[dep], GLOBAL_PROC_REF(cmp_job_titles))
	sortTim(heads_positions, GLOBAL_PROC_REF(cmp_job_titles))

/datum/controller/subsystem/job/proc/Debug(text)
	if(!Debug2)
		return FALSE
	job_debug.Add(text)
	return TRUE

/datum/controller/subsystem/job/proc/GetHumanJobs()
	return name_occupations - list(JOB_AI, JOB_CYBORG)


/datum/controller/subsystem/job/proc/GetJob(rank)
	if(!initialized)
		CRASH("GetJob called before SSjob initialization!")
	return name_occupations[rank]

/datum/controller/subsystem/job/proc/GetPlayerAltTitle(mob/dead/new_player/player, rank)
	return player.client.prefs.GetPlayerAltTitle(GetJob(rank))

/datum/controller/subsystem/job/proc/AssignRole(mob/dead/new_player/player, rank, latejoin=0)
	Debug("Running AR, Player: [player], Rank: [rank], LJ: [latejoin]")
	if(player && player.mind && rank)
		var/datum/job/job = GetJob(rank)
		if(!job)
			return FALSE
		if(jobban_isbanned(player, rank))
			return FALSE
		if(!job.player_old_enough(player.client))
			return FALSE
		if(!job.map_check())
			return FALSE
		var/position_limit = job.total_positions
		if(!latejoin)
			position_limit = job.spawn_positions
		Debug("Player: [player] is now Rank: [rank], JCP:[job.current_positions], JPL:[position_limit]")
		player.mind.assigned_job = job
		player.mind.assigned_role = rank
		player.mind.role_alt_title = GetPlayerAltTitle(player, rank)
		unassigned -= player
		job.current_positions++

		if(job.quota == QUOTA_WANTED)
			job.quota = QUOTA_NEUTRAL
		return TRUE
	Debug("AR has failed, Player: [player], Rank: [rank]")
	return FALSE

/datum/controller/subsystem/job/proc/FreeRole(rank)	//making additional slot on the fly
	var/datum/job/job = GetJob(rank)
	if(job && job.current_positions >= job.total_positions && job.total_positions != -1)
		job.total_positions++
		return TRUE
	return FALSE


/datum/controller/subsystem/job/proc/FindOccupationCandidates(datum/job/job, level, flag)
	Debug("Running FOC, Job: [job], Level: [level], Flag: [flag]")
	var/list/candidates = list()
	for(var/mob/dead/new_player/player in unassigned)
		if(jobban_isbanned(player, job.title))
			Debug("FOC isbanned failed, Player: [player]")
			continue
		if(!job.player_old_enough(player.client))
			Debug("FOC player not old enough, Player: [player]")
			continue
		if(!job.map_check())
			continue
		if(flag && (!(flag in player.client.prefs.be_role)))
			Debug("FOC flag failed, Player: [player], Flag: [flag], ")
			continue
		if(player.client.prefs.job_preferences[job.title] == level)
			Debug("FOC pass, Player: [player], Level:[level]")
			candidates += player
	return candidates

/datum/controller/subsystem/job/proc/GiveRandomJob(mob/dead/new_player/player)
	Debug("GRJ Giving random job, Player: [player]")
	for(var/datum/job/job as anything in shuffle(active_occupations))
		if(!job)
			continue

		if(istype(job, GetJob("Assistant"))) // We don't want to give him assistant, that's boring!
			continue

		if(job.title in heads_positions) //If you want a command position, select it!
			continue

		if(!job.is_species_permitted(player.client.prefs.species))
			continue

		if(jobban_isbanned(player, job.title))
			Debug("GRJ isbanned failed, Player: [player], Job: [job.title]")
			continue

		if(!job.player_old_enough(player.client))
			Debug("GRJ player not old enough for [job.title], Player: [player]")
			continue

		if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
			Debug("GRJ Random job given, Player: [player], Job: [job]")
			AssignRole(player, job.title)
			unassigned -= player
			break

	// So we end up here which means every other job is unavailable, lets give him "assistant", since this is the only job without any spawn limit and restrictions.
	if(player.mind && !player.mind.assigned_role)
		Debug("GRJ Random job given, Player: [player], Job: Assistant")
		AssignRole(player, "Assistant")
		unassigned -= player

/datum/controller/subsystem/job/proc/ResetOccupations()
	for(var/mob/dead/new_player/player in player_list)
		if((player) && (player.mind))
			player.mind.assigned_role = null
			player.mind.assigned_job = null
			player.mind.special_role = null

	for(var/datum/job/J as anything in active_occupations)
		J.current_positions = initial(J.current_positions)

		if(!isnull(J.map_spawn_positions))
			J.spawn_positions = J.map_spawn_positions
		else
			J.spawn_positions = initial(J.spawn_positions)

		if(!isnull(J.map_total_positions))
			J.total_positions = J.map_total_positions
		else
			J.total_positions = initial(J.total_positions)

		J.quota = initial(J.quota)

	unassigned = list()

//This proc is called before the level loop of DivideOccupations() and will try to select a head, ignoring ALL non-head preferences for every level until
//it locates a head or runs out of levels to check
//This is basically to ensure that there's atleast a few heads in the round
/datum/controller/subsystem/job/proc/FillHeadPosition()
	for(var/level in JP_LEVELS)
		for(var/command_position in heads_positions)
			var/datum/job/job = GetJob(command_position)
			if(!job)
				continue
			if((job.current_positions >= job.total_positions) && job.total_positions != -1)
				continue
			var/list/candidates = FindOccupationCandidates(job, level)
			if(!candidates.len)
				continue
			var/mob/dead/new_player/candidate = pick(candidates)
			if(AssignRole(candidate, command_position))
				return TRUE
	return FALSE


//This proc is called at the start of the level loop of DivideOccupations() and will cause head jobs to be checked before any other jobs of the same level
//This is also to ensure we get as many heads as possible
/datum/controller/subsystem/job/proc/CheckHeadPositions(level)
	for(var/command_position in heads_positions)
		var/datum/job/job = GetJob(command_position)
		if(!job)
			continue
		if((job.current_positions >= job.total_positions) && job.total_positions != -1)
			continue
		var/list/candidates = FindOccupationCandidates(job, level)
		if(!candidates.len)
			continue
		var/mob/dead/new_player/candidate = pick(candidates)
		AssignRole(candidate, command_position)
	return


/datum/controller/subsystem/job/proc/FillAIPosition()
	var/ai_selected = 0
	var/datum/job/job = GetJob("AI")
	if(!job)
		return FALSE
	if((job.title == "AI") && (config) && (!config.allow_ai))
		return FALSE

	if(istype(SSticker.mode, /datum/game_mode/malfunction) && job.spawn_positions)//no additional AIs with malf
		job.total_positions = job.spawn_positions
		job.spawn_positions = 0
	for(var/i = job.total_positions, i > 0, i--)
		for(var/level in JP_LEVELS)
			var/list/candidates = list()
			if(istype(SSticker.mode, /datum/game_mode/malfunction))//Make sure they want to malf if its malf
				candidates = FindOccupationCandidates(job, level, ROLE_MALF)
			else
				candidates = FindOccupationCandidates(job, level)
			if(candidates.len)
				var/mob/dead/new_player/candidate = pick(candidates)
				if(AssignRole(candidate, "AI"))
					ai_selected++
					break
		//Malf NEEDS an AI so force one if we didn't get a player who wanted it
		if(istype(SSticker.mode, /datum/game_mode/malfunction) && !ai_selected)
			unassigned = shuffle(unassigned)
			for(var/mob/dead/new_player/player in unassigned)
				if(jobban_isbanned(player, "AI"))
					continue
				if(ROLE_MALF in player.client.prefs.be_role)
					if(AssignRole(player, "AI"))
						ai_selected++
						break
	if(ai_selected)
		return TRUE
	return FALSE


/** Proc DivideOccupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effect besides of modifying "assigned_role".
 **/
/datum/controller/subsystem/job/proc/DivideOccupations()
	//Setup new player list and get the jobs list
	Debug("Running DO")

	//Holder for Triumvirate is stored in the ticker, this just processes it
	// todo: make it round aspect
	if(SSticker && SSticker.triai)
		var/datum/job/ai/A = name_occupations[JOB_AI]
		A?.spawn_positions = 3

	//Get the players who are ready
	for(var/mob/dead/new_player/player in player_list)
		if(player.ready && player.mind && !player.mind.assigned_role)
			unassigned += player
			if(player.client.prefs.randomslot)
				player.client.prefs.random_character()
	Debug("DO, Len: [unassigned.len]")
	if(unassigned.len == 0)
		return FALSE

	//Shuffle players and jobs
	unassigned = shuffle(unassigned)

	HandleFeedbackGathering()

	//People who wants to be assistants, sure, go on.
	Debug("DO, Running Assistant Check 1")
	var/datum/job/assist = new /datum/job/assistant()
	var/list/assistant_candidates = FindOccupationCandidates(assist, JP_LOW)
	Debug("AC1, Candidates: [assistant_candidates.len]")
	for(var/mob/dead/new_player/player in assistant_candidates)
		Debug("AC1 pass, Player: [player]")
		AssignRole(player, "Assistant")
		assistant_candidates -= player
	Debug("DO, AC1 end")

	//Check for an AI
	if(istype(SSticker.mode, /datum/game_mode/malfunction))
		Debug("DO, Running AI Check")
		FillAIPosition()
		Debug("DO, AI Check end")

	//Select one head
	Debug("DO, Running Head Check")
	FillHeadPosition()
	Debug("DO, Head Check end")

	//Check for an AI
	if(!istype(SSticker.mode, /datum/game_mode/malfunction))
		Debug("DO, Running AI Check")
		FillAIPosition()
		Debug("DO, AI Check end")

	//Other jobs are now checked
	Debug("DO, Running Standard Check")


	// New job giving system by Donkie
	// This will cause lots of more loops, but since it's only done once it shouldn't really matter much at all.
	// Hopefully this will add more randomness and fairness to job giving.

	// Loop through all levels from high to low
	var/list/shuffledoccupations = shuffle(active_occupations)
	for(var/level in JP_LEVELS)
		//Check the head jobs first each level
		CheckHeadPositions(level)

		// Loop through all unassigned players
		for(var/mob/dead/new_player/player in unassigned)

			// Loop through all jobs
			for(var/datum/job/job as anything in shuffledoccupations) // SHUFFLE ME BABY
				if(!job)
					continue

				if(jobban_isbanned(player, job.title))
					Debug("DO isbanned failed, Player: [player], Job:[job.title]")
					continue

				if(!job.player_old_enough(player.client))
					Debug("DO player not old enough, Player: [player], Job:[job.title]")
					continue

				// If the player wants that job on this level, then try give it to him.
				if(player.client.prefs.job_preferences[job.title] == level)

					// If the job isn't filled
					if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
						Debug("DO pass, Player: [player], Level:[level], Job:[job.title]")
						AssignRole(player, job.title)
						unassigned -= player
						break

	// Hand out random jobs to the people who didn't get any in the last check
	// Also makes sure that they got their preference correct
	for(var/mob/dead/new_player/player in unassigned)
		if(player.client.prefs.alternate_option == GET_RANDOM_JOB)
			GiveRandomJob(player)
			Debug("DO pass, alternate random job, Player: [player]")

	Debug("DO, Standard Check end")

	Debug("DO, Running AC2")

	// For those who wanted to be assistant if their preferences were filled, here you go.
	for(var/mob/dead/new_player/player in unassigned)
		if(player.client.prefs.alternate_option == BE_ASSISTANT)
			Debug("AC2 Assistant located, Player: [player]")
			AssignRole(player, "Assistant")

	//For ones returning to lobby
	for(var/mob/dead/new_player/player in unassigned)
		if(player.client.prefs.alternate_option == RETURN_TO_LOBBY)
			Debug("Alternate return to lobby, Player: [player]")

			player.ready = FALSE
			player.client << output(player.ready, "lobbybrowser:setReadyStatus")

			unassigned -= player
			to_chat(player, "<span class='alert bold'>Вы были возвращены в лобби, так как ваши настройки профессии были недоступны. Вы можете это изменить в настройках.</span>")
	return TRUE

//Gives the player the stuff he should have with his rank
/datum/controller/subsystem/job/proc/EquipRank(mob/living/carbon/human/H, rank, joined_late=FALSE)
	if(!H)	return FALSE
	var/datum/job/job = GetJob(rank)
	var/list/spawn_in_storage = list()

	if(job)

		//Equip custom gear loadout.
		var/list/custom_equip_slots = list() //If more than one item takes the same slot, all after the first one spawn in storage.
		var/list/custom_equip_leftovers = list()
		var/metadata
		if(H.client.prefs.gear && H.client.prefs.gear.len && job.give_loadout_items)
			for(var/thing in H.client.prefs.gear)
				var/datum/gear/G = gear_datums[thing]
				if(G)
					var/permitted
					if(G.allowed_roles)
						for(var/job_name in G.allowed_roles)
							if(job.title == job_name)
								permitted = TRUE
							else if(H.mind.role_alt_title == job_name)
								permitted = TRUE
					else
						permitted = TRUE

					if(G.whitelisted && (G.whitelisted != H.species.name || !is_alien_whitelisted(H, G.whitelisted)))
						permitted = FALSE

					if(!permitted)
						to_chat(H, "<span class='warning'>Ваша текущая работа или статус в белом списке не позволяют вам появляться с [thing]!</span>")
						continue

					if(G.slot && !(G.slot in custom_equip_slots))
						// This is a miserable way to fix the loadout overwrite bug, but the alternative requires
						// adding an arg to a bunch of different procs. Will look into it after this merge. ~ Z
						metadata = H.client.prefs.gear[G.display_name]
						if(G.slot == SLOT_WEAR_MASK || G.slot == SLOT_WEAR_SUIT || G.slot == SLOT_HEAD)
							custom_equip_leftovers += thing
						else if(H.equip_to_slot_or_del(G.spawn_item(H, metadata), G.slot))
							to_chat(H, "<span class='notice'>Equipping you with \the [thing]!</span>")
							custom_equip_slots.Add(G.slot)
						else
							custom_equip_leftovers.Add(thing)
					else
						spawn_in_storage += thing

		if(H.species)
			H.species.before_job_equip(H, job)

		job.equip(H)

		for(var/thing in custom_equip_leftovers)
			var/datum/gear/G = gear_datums[thing]
			if(G.slot in custom_equip_slots)
				spawn_in_storage += thing
			else
				metadata = H.client.prefs.gear[G.display_name]
				if(H.equip_to_slot_or_del(G.spawn_item(H, metadata), G.slot))
					to_chat(H, "<span class='notice'>Equipping you with \the [thing]!</span>")
					custom_equip_slots.Add(G.slot)
				else
					spawn_in_storage += thing

	else
		to_chat(H, "Ваша профессия - [rank], и игра почему-то не может её обработать! Пожалуйста, сообщите об этой ошибке администратору.")

	H.job = rank

	if(!joined_late)
		var/obj/effect/landmark/start/spawn_mark
		var/list/rank_landmarks = landmarks_list[H.mind.role_alt_title]
		if(length(rank_landmarks))
			for(var/obj/effect/landmark/start/landmark as anything in rank_landmarks)
				if(!(locate(/mob/living) in landmark.loc))
					spawn_mark = landmark
					break
		if(!spawn_mark)
			spawn_mark = locate("start*[rank]") // use old stype

		if(!spawn_mark)
			if(!fallback_landmark)
				fallback_landmark = locate("start*Fallback-Start")
			warning("Failed to find spawn position for [rank]. Using fallback spawn position!")
			spawn_mark = fallback_landmark

		if(istype(spawn_mark, /obj/effect/landmark/start) && istype(spawn_mark.loc, /turf))
			H.forceMove(spawn_mark.loc, keep_buckled = TRUE)

	//give them an account in the station database
	var/startingMoney = max(round(job.salary * STARTING_MONEY_MULTIPLYER * (1 + rand(-STARTING_MONEY_VARIANCE, STARTING_MONEY_VARIANCE) / 100)) + job.starting_money, STARTING_MONEY_MINIMUM)
	var/datum/money_account/M = create_random_account_and_store_in_mind(H, startingMoney, job.department_stocks)	//starting funds = salary

	// If they're head, give them the account info for their department
	if(H.mind && (job.title in heads_positions))
		var/datum/department/D = heads_positions[job.title]
		if(D.station_account)
			SSeconomy.add_account_knowledge(H, D.title)

	to_chat(H, "<span class='notice'><b>Your account number is: [M.account_number], your account pin is: [M.remote_access_pin]</b></span>")

	var/alt_title = null
	if(H.mind)
		H.mind.assigned_role = rank
		alt_title = H.mind.role_alt_title

		switch(rank)
			if("Cyborg")
				H.Robotize()
				return TRUE
			if("AI")
				return H

	if(H.species)
		H.species.after_job_equip(H, job)

	// Happy Valentines day!
	if(SSholiday.holidays[VALENTINES])
		for(var/obj/item/weapon/storage/backpack/BACKP in H)
			new /obj/item/weapon/storage/fancy/heart_box(BACKP)

	// Kulich for everyone!
	if(SSholiday.holidays[EASTER])
		for(var/obj/item/weapon/storage/backpack/BACKP in H)
			new /obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/kulich(BACKP)

	//Give custom items
	give_custom_items(H, job)

	//Deferred item spawning.
	for(var/thing in spawn_in_storage)
		var/datum/gear/G = gear_datums[thing]
		var/metadata = H.client.prefs.gear[G.display_name]
		var/item = G.spawn_item(null, metadata)

		var/atom/placed_in = H.equip_or_collect(item)
		if(placed_in)
			to_chat(H, "<span class='notice'>Placing \the [item] in your [placed_in.name]!</span>")
			continue
		if(H.equip_to_appropriate_slot(item))
			to_chat(H, "<span class='notice'>Placing \the [item] in your inventory!</span>")
			continue
		if(H.put_in_hands(item))
			to_chat(H, "<span class='notice'>Placing \the [item] in your hands!</span>")
			continue
		to_chat(H, "<span class='danger'>Failed to locate a storage object on your mob, either you spawned with no arms and no backpack or this is a bug.</span>")
		qdel(item)

	to_chat(H, "<B>You are the [alt_title ? alt_title : rank].</B>")
	to_chat(H, "<b>As the [alt_title ? alt_title : rank] you answer directly to [job.supervisors]. Special circumstances may change this.</b>")
	if(job.req_admin_notify)
		to_chat(H, "<b>You are playing a job that is important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b>")

	if(SSround_aspects.aspect_name && SSround_aspects.aspect.afterspawn_IC_announcement)
		to_chat(H, SSround_aspects.aspect.afterspawn_IC_announcement)

	spawnId(H, rank, alt_title)

	var/client/Cl = H.client
	if(Cl && Cl.player_ingame_age && isnum(Cl.player_ingame_age) && Cl.player_ingame_age < 3000)
		var/obj/item/clothing/accessory/newbiebadge/badge = new(H)
		H.equip_or_collect(badge, SLOT_NECK)
		var/stationmap_type = SSmapping.get_stationmap_type()
		if(stationmap_type)
			H.equip_or_collect(new stationmap_type(H), SLOT_R_STORE)

//		H.update_icons()

	return TRUE

/datum/controller/subsystem/job/proc/spawnId(mob/living/carbon/human/H, rank, title)
	if(!H)	return FALSE
	var/obj/item/weapon/card/id/C = null

	var/datum/job/job = name_occupations[rank]

	if(job)
		if(job.title == "Cyborg")
			return
		else
			C = new job.idtype(H)
			C.access = job.get_access()
	else
		C = new /obj/item/weapon/card/id(H)
	if(C)
		C.rank = rank
		C.assignment = title ? title : rank
		C.assign(H.real_name)

		//put the player's account number onto the ID
		if(H.mind)
			var/datum/money_account/MA = get_account(H.mind.get_key_memory(MEM_ACCOUNT_NUMBER))
			if(MA)
				C.associated_account_number = MA.account_number
				MA.set_salary(job.salary, job.salary_ratio)	//set the salary equal to job
				if(job.title in heads_positions)
					MA.owner_preferred_insurance_type = SSeconomy.insurance_quality_decreasing[1]
					MA.owner_max_insurance_payment = SSeconomy.roundstart_insurance_prices[MA.owner_preferred_insurance_type]
				else
					MA.owner_preferred_insurance_type = H.roundstart_insurance
					MA.owner_max_insurance_payment = SSeconomy.roundstart_insurance_prices[H.roundstart_insurance]
				var/insurance_type = get_next_insurance_type(H.roundstart_insurance, MA, SSeconomy.roundstart_insurance_prices)
				H.roundstart_insurance = insurance_type
				var/med_account_number = global.department_accounts["Medical"].account_number
				var/insurance_price = SSeconomy.roundstart_insurance_prices[insurance_type]
				charge_to_account(med_account_number, med_account_number, "[insurance_type] Insurance payment", "NT Insurance", insurance_price)
				charge_to_account(MA.account_number, "Medical", "[insurance_type] Insurance payment", "NT Insurance", -insurance_price)



		H.equip_or_collect(C, SLOT_WEAR_ID)

	H.equip_to_slot_or_del(new /obj/item/device/pda(H), SLOT_BELT)
	if(locate(/obj/item/device/pda,H))
		var/obj/item/device/pda/pda = locate(/obj/item/device/pda,H)
		pda.ownjob = C.assignment
		pda.assign(H.real_name)
		pda.ownrank = C.rank
		pda.check_rank(C.rank)

		var/datum/money_account/MA = get_account(H.mind.get_key_memory(MEM_ACCOUNT_NUMBER))
		pda.owner_account = MA.account_number //bind the account to the pda
		pda.owner_fingerprints += C.fingerprint_hash //save fingerprints in pda from ID card
		MA.owner_PDA = pda //add PDA in /datum/money_account

		var/chosen_ringtone = H.client?.prefs.chosen_ringtone
		if(chosen_ringtone)
			pda.set_ringtone(chosen_ringtone, H.client?.prefs.custom_melody)

	return TRUE

/datum/controller/subsystem/job/proc/HandleFeedbackGathering()
	for(var/datum/job/job as anything in active_occupations)
		var/tmp_str = "|[job.title]|"

		var/high = 0
		var/medium = 0
		var/low = 0
		var/never = 0
		var/banned = 0
		var/young = 0
		for(var/mob/dead/new_player/player in player_list)
			if(!(player.ready && player.mind && !player.mind.assigned_role))
				continue //This player is not ready
			if(jobban_isbanned(player, job.title))
				banned++
				continue
			if(!job.player_old_enough(player.client))
				young++
				continue
			switch(player.client.prefs.job_preferences[job.title])
				if(JP_HIGH)
					high++
				if(JP_MEDIUM)
					medium++
				if(JP_LOW)
					low++
				else
					never++
		tmp_str += "HIGH=[high]|MEDIUM=[medium]|LOW=[low]|NEVER=[never]|BANNED=[banned]|YOUNG=[young]|-"
		feedback_add_details("job_preferences",tmp_str)

/datum/controller/subsystem/job/proc/IsJobAvailable(mob/M, rank)
	var/datum/job/job = SSjob.GetJob(rank)
	if(!job || !M.client)
		return FALSE
	var/client/C = M.client
	if(!job.is_position_available())
		return FALSE
	if(jobban_isbanned(M, rank))
		return FALSE
	if(!job.player_old_enough(C))
		return FALSE
	if(!job.map_check())
		return FALSE
	if(!job.is_species_permitted(C.prefs.species))
		var/datum/quality/quality = SSqualities.qualities_by_name[C.prefs.selected_quality_name]
		//skip check by quality
		if(istype(quality, /datum/quality/quirkieish/unrestricted))
			return TRUE
		return FALSE
	return TRUE

/datum/controller/subsystem/job/proc/GetActiveCount(rank)
	var/count = 0
	// Only players with the job assigned and AFK for less than 10 minutes count as active
	// todo: store players in job datums for quick and easy loop
	for(var/mob/M in player_list)
		if(M.mind?.assigned_role == rank && M.client?.inactivity <= 10 MINUTES)
			count++
	return count
