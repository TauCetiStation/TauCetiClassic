/datum/event/space_ninja/setup()
	space_ninja_arrival()

/*
Also a dynamic ninja mission generator.
I decided to scrap round-specific objectives since keeping track of them would require some form of tracking.
When I already created about 4 new objectives, this doesn't seem terribly important or needed.
*/
/proc/space_ninja_arrival(assign_key = null, assign_mission = null)

	var/ninja_key = null
	var/mob/candidate_mob
	var/list/candidates = list()

	if(assign_key)
		ninja_key = assign_key
		for(var/mob/M in player_list)
			if((M.key == ninja_key || M.ckey == ninja_key) && M.client)
				candidates += M
				break
		if(!candidates.len)
			to_chat(usr, "<span class='warning'>[assign_key]'s mob not found</span>")
			return
		candidates = pollCandidates("The spider clan has a special mission for YOU! Would you like to play as space ninja?", ROLE_NINJA, ROLE_NINJA, group = candidates)
		if(!candidates.len)
			to_chat(usr, "<span class='warning'>The ninja ([assign_key]) did not accept the role in time</span>")
			return
	else
		candidates = pollGhostCandidates("The spider clan has a mission for true space ninja. Would you like to play as one?", ROLE_NINJA, ROLE_NINJA)
		if(!candidates.len)
			message_admins("Candidates for Space Ninja not found. Shutting down.")
			return
		candidates = shuffle(candidates)//Incorporating Donkie's list shuffle
		candidate_mob = pick(candidates)
		ninja_key = candidate_mob.ckey

	//Here we pick a location and spawn the ninja.
	if(ninjastart.len == 0)
		for(var/obj/effect/landmark/L in landmarks_list)
			if(L.name == "carpspawn")
				ninjastart.Add(L)
	
	//The ninja will be created on the right spawn point or at late join.
	var/mob/living/carbon/human/new_ninja = create_space_ninja(pick(ninjastart.len ? ninjastart : latejoin))
	new_ninja.key = ninja_key
	message_admins("[new_ninja] has spawned at [new_ninja.x],[new_ninja.y],[new_ninja.z] [ADMIN_JMP(new_ninja)] [ADMIN_FLW(new_ninja)].")

	if(assign_mission)
		new_ninja.mind.store_memory("<B>Mission:</B> <span class='warning'>[assign_mission].</span><br>")
		to_chat(new_ninja, "<span class='notice'>\nYou are an elite mercenary assassin of the Spider Clan, [new_ninja.real_name]. The dreaded <span class='warning'><B>SPACE NINJA</B></span>! You have a variety of abilities at your disposal, thanks to your nano-enhanced cyber armor. Remember your training! \nYour current mission is: <span class='warning'><B>[assign_mission]</B></span></span>")
	else
		set_ninja_objectives(new_ninja)
	SSticker.mode.ninjas += new_ninja.mind

	return TRUE



/*
 *  DYNAMIC NINJA MISSION GENERATOR.
 */
#define NANOTRASEN_SIDE  "Nanotrasen"
#define SYNDICATE_SIDE   "The Syndicate"
#define SYNDICATE_ENEMIES_LIST 1
#define NANOTRASEN_ENEMIES_LIST  2
#define KILL              1
#define STEAL             2
#define PROTECT           3
#define DEBRAIN           4
#define DOWNLOAD_RESEARCH 5
#define CAPTURE           6

/proc/set_ninja_objectives(mob/living/carbon/human/new_ninja)
	var/datum/mind/ninja_mind = new_ninja.mind//For easier reference.
	//Xenos and deathsquads take precedence over everything else.

	/*Is the ninja playing for the good or bad guys? Is the ninja helping or hurting the station?
	Their directives also influence behavior. At least in theory.*/
	var/side = pick(NANOTRASEN_SIDE, SYNDICATE_SIDE)

	var/datum/game_mode/current_mode = SSticker.mode
	var/datum/mind/current_mind
	var/list/xeno_list = list()//Aliens.
	var/list/commando_list = list()//Commandos.
	var/list/antagonist_list = list()//The main bad guys. Evil minds that plot destruction.
	var/list/protagonist_list = current_mode.get_living_heads()//The good guys. Mostly Heads. Who are alive.

	//We want the ninja to appear only in certain modes.
	//	var/acceptable_modes_list[] = list("traitor","revolution","cult","wizard","changeling","traitorchan","nuclear","malfunction","monkey")  // Commented out for both testing and ninjas
	//	if(!(current_mode.config_tag in acceptable_modes_list))
	//		return

	/*No longer need to determine what mode it is since bad guys are basically universal.
	And there is now a mode with two types of bad guys.*/

	var/list/possible_bad_dudes = list(
		current_mode.traitors,current_mode.head_revolutionaries,
		current_mode.head_revolutionaries,
		current_mode.cult,current_mode.wizards,
		current_mode.changelings,current_mode.syndicates
		)
	for(var/list in possible_bad_dudes)//For every possible antagonist type.
		for(current_mind in list)//For each mind in that list.
			if(current_mind.current && current_mind.current.stat != DEAD)//If they are not destroyed and not dead.
				antagonist_list += current_mind//Add them.

	if(protagonist_list.len)//If the mind is both a protagonist and antagonist.
		for(current_mind in protagonist_list)
			if(current_mind in antagonist_list)
				protagonist_list -= current_mind//We only want it in one list.
	/*
	Malf AIs/silicons aren't added. Monkeys aren't added. Messes with objective completion. Only humans are added.
	*/

	//Unless the xenos are hiding in a locker somewhere, this'll find em.
	for(var/mob/living/carbon/xenomorph/humanoid/xeno in player_list)
		if(istype(xeno))
			xeno_list += xeno


	if(xeno_list.len > 3)//If there are more than three humanoid xenos on the station, time to get dangerous.
		//Here we want the ninja to murder all the queens. The other aliens don't really matter.
		var/list/xeno_queen_list = list()
		for(var/mob/living/carbon/xenomorph/humanoid/queen/xeno_queen in xeno_list)
			if(xeno_queen.mind && xeno_queen.stat != DEAD)
				xeno_queen_list += xeno_queen
		if(xeno_queen_list.len && side == NANOTRASEN_SIDE)//If there are queen about and the probability is 50.
			for(var/mob/living/carbon/xenomorph/humanoid/queen/xeno_queen in xeno_queen_list)
				var/datum/objective/assassinate/ninja_objective = new
				ninja_objective.owner = ninja_mind
				//We'll do some manual overrides to properly set it up.
				ninja_objective.target = xeno_queen.mind
				ninja_objective.explanation_text = "Kill \the [xeno_queen]."
				ninja_mind.objectives += ninja_objective

	if(sent_strike_team && side == SYNDICATE_SIDE && antagonist_list.len)//If a strike team was sent, murder them all like a champ.
		for(current_mind in antagonist_list)//Search and destroy. Since we already have an antagonist list, they should appear there.
			if(current_mind && current_mind.special_role == "Death Commando")
				commando_list += current_mind
		if(commando_list.len)//If there are living commandos still in play.
			for(var/mob/living/carbon/human/commando in commando_list)
				var/datum/objective/assassinate/ninja_objective = new
				ninja_objective.owner = ninja_mind
				ninja_objective.find_target_by_role(commando.mind.special_role,1)
				ninja_mind.objectives += ninja_objective
	/*
	If there are no antogonists left it could mean one of two things:
		A) The round is about to end. No harm in spawning the ninja here.
		B) The round is still going and ghosts are probably rioting for something to happen.
	In either case, it's a good idea to spawn the ninja with a semi-random set of objectives.
	*/
	if(!ninja_mind.objectives.len)//If mission was not set.

		var/list/current_minds//List being looked on in the following code.
		var/side_list = (side == NANOTRASEN_SIDE) ? NANOTRASEN_ENEMIES_LIST : SYNDICATE_ENEMIES_LIST//For logic gating.
		var/list/hostile_targets = list()//The guys actually picked for the assassination or whatever.
		var/list/friendly_targets = list()//The guys the ninja must protect.

		for(var/enemies_list in SYNDICATE_ENEMIES_LIST to NANOTRASEN_ENEMIES_LIST)//Two lists.
			if(enemies_list == NANOTRASEN_ENEMIES_LIST) //Which list are we looking at?
				current_minds = antagonist_list
			else 
				current_minds = protagonist_list
			for(var/t = 3, (current_minds.len && t > 0), t--)//While the list is not empty and targets remain. Also, 3 targets is good.
				current_mind = pick(current_minds)//Pick a random person.
				/*I'm creating a logic gate here based on the ninja affiliation that compares the list being
				looked at to the affiliation. Affiliation is just a number used to compare. Meaning comes from the logic involved.
				If the list being looked at is equal to the ninja's affiliation, add the mind to hostiles.
				If not, add the mind to friendlies. Since it can't be both, it will be added only to one or the other.*/
				if(enemies_list == side_list)
					hostile_targets += current_mind
					friendly_targets += null
				else
					hostile_targets += null
					friendly_targets += current_mind
				current_minds -= current_mind//Remove the mind so it's not picked again.

		var/list/objective_list = list(KILL, STEAL, PROTECT, DEBRAIN, DOWNLOAD_RESEARCH, CAPTURE)//To remove later.
		for(var/i in 1 to rand(1, 3))//Want to get a few random objectives. Currently up to 3.
			if(!hostile_targets.len)//Remove appropriate choices from switch list if the target lists are empty.
				objective_list -= KILL
				objective_list -= DEBRAIN
			if(!friendly_targets.len)
				objective_list -= PROTECT
			switch(pick(objective_list))
				if(KILL)
					current_mind = pick(hostile_targets)

					if(current_mind)
						var/datum/objective/assassinate/ninja_objective = new
						ninja_objective.owner = ninja_mind
						ninja_objective.find_target_by_role((current_mind.special_role ? current_mind.special_role : current_mind.assigned_role),(current_mind.special_role ? 1 : 0))//If they have a special role, use that instead to find em.
						ninja_mind.objectives += ninja_objective

					else
						i++

					hostile_targets -= current_mind//Remove them from the list.
				if(STEAL)
					var/datum/objective/steal/ninja_objective = new
					ninja_objective.owner = ninja_mind
					var/target_item = pick(ninja_objective.possible_items_special)
					ninja_objective.set_target(target_item)
					ninja_mind.objectives += ninja_objective

					objective_list -= STEAL
				if(PROTECT)
					current_mind = pick(friendly_targets)

					if(current_mind)

						var/datum/objective/protect/ninja_objective = new
						ninja_objective.owner = ninja_mind
						ninja_objective.find_target_by_role((current_mind.special_role ? current_mind.special_role : current_mind.assigned_role), (current_mind.special_role ? 1 : 0))
						ninja_mind.objectives += ninja_objective

					else
						i++

					friendly_targets -= current_mind
				if(DEBRAIN)
					current_mind = pick(hostile_targets)

					if(current_mind)

						var/datum/objective/debrain/ninja_objective = new
						ninja_objective.owner = ninja_mind
						ninja_objective.find_target_by_role((current_mind.special_role ? current_mind.special_role : current_mind.assigned_role), (current_mind.special_role ? 1 : 0))
						ninja_mind.objectives += ninja_objective

					else
						i++

					hostile_targets -= current_mind//Remove them from the list.
				if(DOWNLOAD_RESEARCH)
					var/datum/objective/download/ninja_objective = new
					ninja_objective.owner = ninja_mind
					ninja_objective.gen_amount_goal()
					ninja_mind.objectives += ninja_objective

					objective_list -= DOWNLOAD_RESEARCH
				if(CAPTURE)
					var/datum/objective/capture/ninja_objective = new
					ninja_objective.owner = ninja_mind
					ninja_objective.gen_amount_goal()
					ninja_mind.objectives += ninja_objective

					objective_list -= CAPTURE

	if(!ninja_mind.objectives.len)//If they somehow did not get an objective at this point, time to destroy the station.
		var/nuke_code
		var/temp_code
		for(var/obj/machinery/nuclearbomb/N in poi_list)
			temp_code = text2num(N.r_code)
			if(temp_code)//if it's actually a number. It won't convert any non-numericals.
				nuke_code = N.r_code
				break
		if(nuke_code)//If there is a nuke device in world and we got the code.
			var/datum/objective/nuclear/ninja_objective = new//Fun.
			ninja_objective.owner = ninja_mind
			ninja_objective.explanation_text = "Destroy the station with a nuclear device. The code is [nuke_code]." //Let them know what the code is.

	//Finally add a survival objective since it's usually broad enough for any round type.
	var/datum/objective/survive/ninja_objective = new
	ninja_objective.owner = ninja_mind
	ninja_mind.objectives += ninja_objective

	var/directive = generate_ninja_directive(side)
	to_chat(new_ninja, "<span class='notice'>\nYou are an elite mercenary assassin of the Spider Clan, [new_ninja.real_name]. The dreaded <span class='warning'><B>SPACE NINJA</B></span>! You have a variety of abilities at your disposal, thanks to your nano-enhanced cyber armor. Remember your training (initialize your suit by right clicking on it)! \nYour current directive is: <span class='warning'><B>[directive]</B></span></span>")
	new_ninja.mind.store_memory("<B>Directive:</B> <span class='warning'>[directive]</span><br>")

	var/obj_count = 1
	to_chat(new_ninja, "<span class='notice'>Your current objectives:</span>")
	for(var/datum/objective/objective in ninja_mind.objectives)
		to_chat(new_ninja, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++

/*
This proc will give the ninja a directive to follow. They are not obligated to do so but it's a fun roleplay reminder.
Making this random or semi-random will probably not work without it also being incredibly silly.
As such, it's hard-coded for now. No reason for it not to be, really.
*/
/proc/generate_ninja_directive(side)
	var/directive = "[side] is your employer. "//Let them know which side they're on.
	var/xenorace = pick("Unathi","Tajaran", "Skrellian")
	directive += pick(list(
		"The Spider Clan must not be linked to this operation. Remain hidden and covert when possible.",
		"[station_name] is financed by an enemy of the Spider Clan. Cause as much structural damage as desired.",
		"A wealthy animal rights activist has made a request we cannot refuse. Prioritize saving animal lives whenever possible.",
		"The Spider Clan absolutely cannot be linked to this operation. Eliminate witnesses at your discretion.",
		"We are currently negotiating with NanoTrasen Central Command. Prioritize saving human lives over ending them.",
		"We are engaged in a legal dispute over [station_name]. If a laywer is present on board, force their cooperation in the matter.",
		"A financial backer has made an offer we cannot refuse. Implicate Syndicate involvement in the operation.",
		"Let no one question the mercy of the Spider Clan. Ensure the safety of all non-essential personnel you encounter.",
		"A free agent has proposed a lucrative business deal. Implicate Nanotrasen involvement in the operation.",
		"Our reputation is on the line. Harm as few civilians and innocents as possible.",
		"Our honor is on the line. Utilize only honorable tactics when dealing with opponents.",
		"We are currently negotiating with a Syndicate leader. Disguise assassinations as suicide or other natural causes.",
		"Some disgruntled NanoTrasen employees have been supportive of our operations. Be wary of any mistreatment by command staff.",
		"A group of [xenorace] radicals have been loyal supporters of the Spider Clan. Favor [xenorace] crew whenever possible.",
		"The Spider Clan has recently been accused of religious insensitivity. Attempt to speak with the Chaplain and prove these accusations false.",
		"The Spider Clan has been bargaining with a competing prosthetics manufacturer. Try to shine NanoTrasen prosthetics in a bad light.",
		"The Spider Clan has recently begun recruiting outsiders. Consider suitable candidates and assess their behavior amongst the crew.",
		"A cyborg liberation group has expressed interest in our serves. Prove the Spider Clan merciful towards law-bound synthetics.",
		"There are no special supplemental instructions at this time."
		))
	return directive

#undef NANOTRASEN_SIDE
#undef SYNDICATE_SIDE
#undef SYNDICATE_ENEMIES_LIST
#undef NANOTRASEN_ENEMIES_LIST
#undef KILL
#undef STEAL
#undef PROTECT
#undef DEBRAIN
#undef DOWNLOAD_RESEARCH
#undef CAPTURE
