SUBSYSTEM_DEF(job)
	name = "Jobs"

	init_order = SS_INIT_JOBS

	flags = SS_NO_FIRE

	var/list/occupations = list()		//List of all jobs
	var/list/datum/job/name_occupations = list()	//Dict of all jobs, keys are titles
	var/list/type_occupations = list()	//Dict of al jobs, keys are types
	var/list/unassigned = list()		//Players who need jobs
	var/list/job_debug = list()			//Debug info
	var/obj/effect/landmark/start/fallback_landmark

/datum/controller/subsystem/job/Initialize(timeofday)
	SSmapping.LoadMapConfig() // Required before SSmapping initialization so we can modify the jobs
	init_joblist()
	SetupOccupations()
	LoadJobs("config/jobs.txt")
	..()


/datum/controller/subsystem/job/proc/SetupOccupations(faction = "Station")
	occupations = list()
	var/list/all_jobs = typesof(/datum/job)
	if(!all_jobs.len)
		to_chat(world, "<span class='boldannounce'>Error setting up jobs, no job datums found</span>")
		return 0

	for(var/J in all_jobs)
		var/datum/job/job = new J()
		if(!job)
			continue
		if(job.faction != faction)
			continue
		occupations += job
		name_occupations[job.title] = job
		type_occupations[J] = job

	return 1


/datum/controller/subsystem/job/proc/Debug(text)
	if(!Debug2)
		return 0
	job_debug.Add(text)
	return 1

/datum/controller/subsystem/job/proc/GetJob(rank)
	if(!occupations.len)
		SetupOccupations()
	return name_occupations[rank]

/datum/controller/subsystem/job/proc/GetJobType(jobtype)
	if(!occupations.len)
		SetupOccupations()
	return type_occupations[jobtype]

/datum/controller/subsystem/job/proc/GetPlayerAltTitle(mob/dead/new_player/player, rank)
	return player.client.prefs.GetPlayerAltTitle(GetJob(rank))

/datum/controller/subsystem/job/proc/AssignRole(mob/dead/new_player/player, rank, latejoin=0)
	Debug("Running AR, Player: [player], Rank: [rank], LJ: [latejoin]")
	if(player && player.mind && rank)
		var/datum/job/job = GetJob(rank)
		if(!job)
			return 0
		if(jobban_isbanned(player, rank))
			return 0
		if(!job.player_old_enough(player.client))
			return 0
		if(!job.map_check())
			return 0
		var/position_limit = job.total_positions
		if(!latejoin)
			position_limit = job.spawn_positions
		Debug("Player: [player] is now Rank: [rank], JCP:[job.current_positions], JPL:[position_limit]")
		player.mind.assigned_role = rank
		player.mind.role_alt_title = GetPlayerAltTitle(player, rank)
		unassigned -= player
		job.current_positions++
		return 1
	Debug("AR has failed, Player: [player], Rank: [rank]")
	return 0

/datum/controller/subsystem/job/proc/FreeRole(rank)	//making additional slot on the fly
	var/datum/job/job = GetJob(rank)
	if(job && job.current_positions >= job.total_positions && job.total_positions != -1)
		job.total_positions++
		return 1
	return 0


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
	for(var/datum/job/job in shuffle(occupations))
		if(!job)
			continue

		if(istype(job, GetJob("Test Subject"))) // We don't want to give him assistant, that's boring!
			continue

		if(job.title in command_positions) //If you want a command position, select it!
			continue

		if(!job.is_species_permitted(player.client.prefs.species))
			continue

		if(!job.map_check())
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
		Debug("GRJ Random job given, Player: [player], Job: Test Subject")
		AssignRole(player, "Test Subject")
		unassigned -= player

/datum/controller/subsystem/job/proc/ResetOccupations()
	for(var/mob/dead/new_player/player in player_list)
		if((player) && (player.mind))
			player.mind.assigned_role = null
			player.mind.special_role = null
	SetupOccupations()
	unassigned = list()
	return


//This proc is called before the level loop of DivideOccupations() and will try to select a head, ignoring ALL non-head preferences for every level until
//it locates a head or runs out of levels to check
//This is basically to ensure that there's atleast a few heads in the round
/datum/controller/subsystem/job/proc/FillHeadPosition()
	for(var/level in JP_LEVELS)
		for(var/command_position in command_positions)
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
				return 1
	return 0


//This proc is called at the start of the level loop of DivideOccupations() and will cause head jobs to be checked before any other jobs of the same level
//This is also to ensure we get as many heads as possible
/datum/controller/subsystem/job/proc/CheckHeadPositions(level)
	for(var/command_position in command_positions)
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
		return 0
	if((job.title == "AI") && (config) && (!config.allow_ai))
		return 0

	if(SSticker.mode.name == "AI malfunction" && job.spawn_positions)//no additional AIs with malf
		job.total_positions = job.spawn_positions
		job.spawn_positions = 0
	for(var/i = job.total_positions, i > 0, i--)
		for(var/level in JP_LEVELS)
			var/list/candidates = list()
			if(SSticker.mode.name == "AI malfunction")//Make sure they want to malf if its malf
				candidates = FindOccupationCandidates(job, level, ROLE_MALF)
			else
				candidates = FindOccupationCandidates(job, level)
			if(candidates.len)
				var/mob/dead/new_player/candidate = pick(candidates)
				if(AssignRole(candidate, "AI"))
					ai_selected++
					break
		//Malf NEEDS an AI so force one if we didn't get a player who wanted it
		if((SSticker.mode.name == "AI malfunction")&&(!ai_selected))
			unassigned = shuffle(unassigned)
			for(var/mob/dead/new_player/player in unassigned)
				if(jobban_isbanned(player, "AI"))
					continue
				if(ROLE_MALF in player.client.prefs.be_role)
					if(AssignRole(player, "AI"))
						ai_selected++
						break
	if(ai_selected)
		return 1
	return 0


/** Proc DivideOccupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effect besides of modifying "assigned_role".
 **/
/datum/controller/subsystem/job/proc/DivideOccupations()
	//Setup new player list and get the jobs list
	Debug("Running DO")
	SetupOccupations()

	//Holder for Triumvirate is stored in the ticker, this just processes it
	if(SSticker)
		for(var/datum/job/ai/A in occupations)
			if(SSticker.triai)
				A.spawn_positions = 3

	//Get the players who are ready
	for(var/mob/dead/new_player/player in player_list)
		if(player.ready && player.mind && !player.mind.assigned_role)
			unassigned += player
			if(player.client.prefs.randomslot)
				player.client.prefs.random_character()
	Debug("DO, Len: [unassigned.len]")
	if(unassigned.len == 0)
		return 0

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
		AssignRole(player, "Test Subject")
		assistant_candidates -= player
	Debug("DO, AC1 end")

	//Check for an AI
	if(SSticker.mode.name == "AI malfunction")
		Debug("DO, Running AI Check")
		FillAIPosition()
		Debug("DO, AI Check end")

	//Select one head
	Debug("DO, Running Head Check")
	FillHeadPosition()
	Debug("DO, Head Check end")

	//Check for an AI
	if(!(SSticker.mode.name == "AI malfunction"))
		Debug("DO, Running AI Check")
		FillAIPosition()
		Debug("DO, AI Check end")

	//Other jobs are now checked
	Debug("DO, Running Standard Check")


	// New job giving system by Donkie
	// This will cause lots of more loops, but since it's only done once it shouldn't really matter much at all.
	// Hopefully this will add more randomness and fairness to job giving.

	// Loop through all levels from high to low
	var/list/shuffledoccupations = shuffle(occupations)
	for(var/level in JP_LEVELS)
		//Check the head jobs first each level
		CheckHeadPositions(level)

		// Loop through all unassigned players
		for(var/mob/dead/new_player/player in unassigned)

			// Loop through all jobs
			for(var/datum/job/job in shuffledoccupations) // SHUFFLE ME BABY
				if(!job)
					continue

				if(jobban_isbanned(player, job.title))
					Debug("DO isbanned failed, Player: [player], Job:[job.title]")
					continue

				if(!job.player_old_enough(player.client))
					Debug("DO player not old enough, Player: [player], Job:[job.title]")
					continue

				if(!job.map_check())
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
			AssignRole(player, "Test Subject")

	//For ones returning to lobby
	for(var/mob/dead/new_player/player in unassigned)
		if(player.client.prefs.alternate_option == RETURN_TO_LOBBY)
			Debug("Alternate return to lobby, Player: [player]")
			player.ready = 0
			unassigned -= player
			SSticker.mode.antag_candidates -= player.mind
			to_chat(player, "<span class='alert bold'>You were returned to the lobby because your job preferences unavailable.  You can change this behavior in preferences.</span>")
	return 1

//Gives the player the stuff he should have with his rank
/datum/controller/subsystem/job/proc/EquipRank(mob/living/carbon/human/H, rank, joined_late=0)
	if(!H)	return 0
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
						to_chat(H, "<span class='warning'>Your current job or whitelist status does not permit you to spawn with [thing]!</span>")
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
		to_chat(H, "Your job is [rank] and the game just can't handle it! Please report this bug to an administrator.")

	H.job = rank

	if(!joined_late)
		var/obj/effect/landmark/start/spawn_mark = null
		for(var/obj/effect/landmark/start/landmark in landmarks_list)
			if((landmark.name == rank) && !(locate(/mob/living) in landmark.loc))
				spawn_mark = landmark
				break
		if(!spawn_mark)
			spawn_mark = locate("start*[rank]") // use old stype

		if(!spawn_mark)
			if(!fallback_landmark)
				for(var/obj/effect/landmark/start/landmark in landmarks_list)
					if(landmark.name == "Fallback-Start")
						fallback_landmark = landmark
			warning("Failed to find spawn position for [rank]. Using fallback spawn position!")
			spawn_mark = fallback_landmark

		if(istype(spawn_mark, /obj/effect/landmark/start) && istype(spawn_mark.loc, /turf))
			H.loc = spawn_mark.loc
		// Moving wheelchair if they have one
		if(H.buckled && istype(H.buckled, /obj/structure/stool/bed/chair/wheelchair))
			H.buckled.loc = H.loc
			H.buckled.dir = H.dir

	//give them an account in the station database
	var/datum/money_account/M = create_random_account_and_store_in_mind(H, job.salary)	//starting funds = salary

	// If they're head, give them the account info for their department
	if(H.mind && job.head_position)
		var/remembered_info = ""
		var/datum/money_account/department_account = department_accounts[job.department]

		if(department_account)
			remembered_info += "<b>Your department's account number is:</b> #[department_account.account_number]<br>"
			remembered_info += "<b>Your department's account pin is:</b> [department_account.remote_access_pin]<br>"
			remembered_info += "<b>Your department's account funds are:</b> $[department_account.money]<br>"

		H.mind.store_memory(remembered_info)

	spawn(0)
		to_chat(H, "<span class='notice'><b>Your account number is: [M.account_number], your account pin is: [M.remote_access_pin]</b></span>")

	var/alt_title = null
	if(H.mind)
		H.mind.assigned_role = rank
		alt_title = H.mind.role_alt_title

		switch(rank)
			if("Cyborg")
				H.Robotize()
				return 1
			if("AI")
				return H
			if("Clown")	//don't need bag preference stuff!
			else
				switch(H.backbag) //BS12 EDIT
					if(2)
						var/obj/item/weapon/storage/backpack/BPK = new(H)
						H.equip_to_slot_or_del(BPK, SLOT_BACK,1)
					if(3)
						var/obj/item/weapon/storage/backpack/alt/BPK = new(H)
						H.equip_to_slot_or_del(BPK, SLOT_BACK,1)
					if(4)
						var/obj/item/weapon/storage/backpack/satchel/norm/BPK = new(H)
						H.equip_to_slot_or_del(BPK, SLOT_BACK,1)
					if(5)
						var/obj/item/weapon/storage/backpack/satchel/BPK = new(H)
						H.equip_to_slot_or_del(BPK, SLOT_BACK,1)

	/*
	Placed here so the backpack that spawns if there is no job backpack has already spawned by now.
	*/
	if(H.species)
		H.species.after_job_equip(H, job)

	// Happy Valentines day!
	if(Holiday == "Valentine's Day")
		for(var/obj/item/weapon/storage/backpack/BACKP in H)
			new /obj/item/weapon/storage/fancy/heart_box(BACKP)

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

	spawnId(H, rank, alt_title)

//		H.update_icons()

	H.hud_updateflag |= (1 << ID_HUD)
	H.hud_updateflag |= (1 << IMPLOYAL_HUD)
	H.hud_updateflag |= (1 << SPECIALROLE_HUD)
	return 1

/datum/controller/subsystem/job/proc/spawnId(mob/living/carbon/human/H, rank, title)
	if(!H)	return 0
	var/obj/item/weapon/card/id/C = null

	var/datum/job/job = null
	for(var/datum/job/J in occupations)
		if(J.title == rank)
			job = J
			break

	if(job)
		if(job.title == "Cyborg")
			return
		else
			C = new job.idtype(H)
			C.access = job.get_access()
	else
		C = new /obj/item/weapon/card/id(H)
	if(C)
		C.registered_name = H.real_name
		C.rank = rank
		C.assignment = title ? title : rank
		C.name = "[C.registered_name]'s ID Card ([C.assignment])"

		//put the player's account number onto the ID
		if(H.mind && H.mind.initial_account)
			C.associated_account_number = H.mind.initial_account.account_number
			H.mind.initial_account.set_salary(job.salary, job.salary_ratio)	//set the salary equal to job

		H.equip_to_slot_or_del(C, SLOT_WEAR_ID)

	H.equip_to_slot_or_del(new /obj/item/device/pda(H), SLOT_BELT)
	if(locate(/obj/item/device/pda,H))
		var/obj/item/device/pda/pda = locate(/obj/item/device/pda,H)
		pda.owner = H.real_name
		pda.ownjob = C.assignment
		pda.ownrank = C.rank
		pda.check_rank(C.rank)
		pda.owner_account = H.mind.initial_account		//bind the account to the pda
		pda.owner_fingerprints += C.fingerprint_hash	//save fingerprints in pda from ID card
		pda.name = "PDA-[H.real_name] ([pda.ownjob])"
		H.mind.initial_account.owner_PDA = pda			//add PDA in /datum/money_account

	return 1

/datum/controller/subsystem/job/proc/LoadJobs(jobsfile)
	if(!config.load_jobs_from_txt)
		return 0

	var/list/jobEntries = file2list(jobsfile)

	for(var/job in jobEntries)

		if(!job)
			continue

		job = trim(job)
		if (!length(job))
			continue

		var/pos = findtext(job, "=")
		var/name = null
		var/value = null

		if(pos)
			name = copytext(job, 1, pos)
			value = copytext(job, pos + 1)
		else
			continue

		if(name && value)
			var/datum/job/J = GetJob(name)
			if(!J)	continue
			J.total_positions = text2num(value)
			J.spawn_positions = text2num(value)
			if(name == "AI" || name == "Cyborg")//I dont like this here but it will do for now
				J.total_positions = 0
	return 1

/datum/controller/subsystem/job/proc/HandleFeedbackGathering()
	for(var/datum/job/job in occupations)
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
