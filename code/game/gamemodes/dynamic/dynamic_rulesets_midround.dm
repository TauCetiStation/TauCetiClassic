//////////////////////////////////////////////
//                                          //
//            MIDROUND RULESETS             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround//Can be drafted once in a while during a round
	var/list/living_players = list()
	var/list/living_antags = list()
	var/list/dead_players = list()
	var/list/list_observers = list()
	var/max_candidates = 0

/datum/dynamic_ruleset/midround/from_ghosts/
	weight = 0
	var/makeBody = TRUE

/datum/dynamic_ruleset/midround/trim_candidates()
	/*
	unlike the previous two types, these rulesets are not meant for /mob/new_player
	and since I want those rulesets to be as flexible as possible, I'm not gonna put much here,
	but be sure to check dynamic_rulesets_debug.dm for an example.

	all you need to know is that here, the candidates list contains 4 lists itself, indexed with the following defines:
	candidates = list(CURRENT_LIVING_PLAYERS, CURRENT_LIVING_ANTAGS, CURRENT_DEAD_PLAYERS, CURRENT_OBSERVERS)
	so for example you can get the list of all current dead players with var/list/dead_players = candidates[CURRENT_DEAD_PLAYERS]
	make sure to properly typecheck the mobs in those lists, as the dead_players list could contain ghosts, or dead players still in their bodies.
	we're still gonna trim the obvious (mobs without clients, jobbanned players, etc)
	*/
	living_players = trim_list(candidates[CURRENT_LIVING_PLAYERS])
	living_antags = trim_list(candidates[CURRENT_LIVING_ANTAGS])
	dead_players = trim_list(candidates[CURRENT_DEAD_PLAYERS], trim_prefs_set_to_no = FALSE)
	list_observers = trim_list(candidates[CURRENT_OBSERVERS], trim_prefs_set_to_no = FALSE)

/datum/dynamic_ruleset/midround/proc/trim_list(list/L = list(), trim_prefs_set_to_no = TRUE)
	var/list/trimmed_list = L.Copy()
	var/role_id = initial(role_category.id)
	//var/role_pref = initial(role_category.required_pref)
	for(var/mob/M in trimmed_list)
		if(!M.client)//are they connected?
			trimmed_list.Remove(M)
			continue
		if(jobban_isbanned(M, role_id))//are they not antag-banned?
			trimmed_list.Remove(M)
			continue
		if(M.mind)
			if((M.mind.assigned_role && (M.mind.assigned_role in restricted_from_jobs)) || (M.mind.role_alt_title && (M.mind.role_alt_title in restricted_from_jobs)))//does their job allow for it?
				trimmed_list.Remove(M)
				continue
			if((exclusive_to_jobs.len > 0) && !(M.mind.assigned_role in exclusive_to_jobs))//is the rule exclusive to their job?
				trimmed_list.Remove(M)
				continue
	return trimmed_list

//You can then for example prompt dead players in execute() to join as strike teams or whatever
//Or autotator someone

//IMPORTANT, since /datum/dynamic_ruleset/midround may accept candidates from both living, dead, and even antag players, you need to manually check whether there are enough candidates
// (see /datum/dynamic_ruleset/midround/autotraitor/ready(var/forced = 0) for example)
/datum/dynamic_ruleset/midround/ready(forced = FALSE)
	if(!forced)
		if(!check_enemy_jobs(TRUE, TRUE))
			return FALSE
	return TRUE

// Done via review_applications.
/datum/dynamic_ruleset/midround/from_ghosts/choose_candidates()
	return TRUE

/datum/dynamic_ruleset/midround/from_ghosts/ready(forced = 0)
	if(required_candidates > (dead_players.len + list_observers.len) && !forced)
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/execute()
	var/list/possible_candidates = list()
	possible_candidates.Add(dead_players)
	possible_candidates.Add(list_observers)
	send_applications(possible_candidates)
	return TRUE

/datum/dynamic_ruleset/midround/from_ghosts/review_applications()
	var/candidate_checks = required_candidates
	if(max_candidates)
		candidate_checks = max_candidates
	for(var/i = candidate_checks, i > 0, i--)
		if(applicants.len <= 0)
			if(i == candidate_checks)
				//We have found no candidates so far and we are out of applicants.
				mode.refund_midround_threat(cost)
				mode.threat_log += "[worldtime2text()]: Rule [name] refunded [cost] (all applications invalid)"
				mode.executed_rules -= src
			break
		var/mob/applicant = pick(applicants)
		applicants -= applicant
		if(!isobserver(applicant))
			if(applicant.stat == DEAD) //Not an observer? If they're dead, make them one.
				applicant = applicant.ghostize(FALSE)
			else //Not dead? Disregard them, pick a new applicant
				message_admins("[name]: Rule could not use [applicant], not dead.")
				i++
				continue

		if(!applicant)
			message_admins("[name]: Applicant was null. This may be caused if the mind changed bodies after applying.")
			i++
			continue
		if(!applicant.key)
			message_admins("[name] was chosen but he logged out, picking another...")
			i++
			continue
		message_admins("DEBUG: Selected [applicant] for rule.")

		var/mob/new_character = applicant

		if(makeBody)
			new_character = generate_ruleset_body(applicant)

		finish_setup(new_character, candidate_checks - (i-1)) // i = N, N - 1.... so that N - (i-1) = 1, 2, ...

	applicants.Cut()

/datum/dynamic_ruleset/midround/from_ghosts/proc/finish_setup(mob/new_character, index)
	var/datum/role/new_role = new role_category
	new_role.AssignToRole(new_character.mind, TRUE)
	setup_role(new_role)

/datum/dynamic_ruleset/midround/from_ghosts/proc/setup_role(datum/role/new_role)
	new_role.OnPostSetup()
	new_role.Greet(GREET_MIDROUND)
	new_role.forgeObjectives()
	new_role.AnnounceObjectives()

// -- Faction based --

/datum/dynamic_ruleset/midround/from_ghosts/faction_based
	weight = 0
	var/datum/faction/my_fac = null // If the midround lawset will try to add our antag to a faction
	var/created_a_faction = FALSE

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/review_applications()
	var/datum/faction/active_fac = create_uniq_faction(my_fac, post_setup = FALSE, give_objectives = FALSE)
	created_a_faction = TRUE
	my_fac = active_fac
	. = ..()
	if(created_a_faction)
		active_fac.OnPostSetup()
	return my_fac

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/setup_role(datum/role/new_role)
	my_fac.HandleRecruitedRole(new_role)
	new_role.Greet(GREET_MIDROUND)
	new_role.forgeObjectives()
	new_role.AnnounceObjectives()

//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/autotraitor
	name = "Syndicate Sleeper Agent"
	role_category = /datum/role/traitor
	protected_from_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain","Head of Personnel",
							"Cyborg", "Chief Engineer", "Chief Medical Officer", "Research Director")
	restricted_from_jobs = list("AI")
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
	cost = 10
	requirements = list(50,40,30,20,10,10,10,10,10,10)
	repeatable = TRUE
	high_population_requirement = 10
	flags = TRAITOR_RULESET

/datum/dynamic_ruleset/midround/autotraitor/acceptable(population = 0, threat = 0)
	var/player_count = mode.living_players.len
	var/antag_count = mode.living_antags.len
	var/max_traitors = round(player_count / 10) + 1
	if((antag_count < max_traitors) && prob(mode.midround_threat_level))//adding traitors if the antag population is getting low
		return ..()
	else
		return FALSE

/datum/dynamic_ruleset/midround/autotraitor/trim_candidates()
	..()
	for(var/mob/living/player in living_players)
		if(isAI(player) || isMMI(player))
			living_players -= player //Your assigned role doesn't change when you are turned into a MoMMI or AI
			continue
		if(isalien(player))
			living_players -= player //Xenos don't bother with the syndicate
			continue
		if(is_centcom_level(player.z))
			living_players -= player//we don't autotator people on Z=2
			continue
		if(player.mind && (player.mind.antag_roles.len > 0))
			living_players -= player//we don't autotator people with roles already

/datum/dynamic_ruleset/midround/autotraitor/ready(forced = FALSE)
	if(required_candidates > living_players.len)
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/autotraitor/choose_candidates()
	var/mob/M = pick(living_players)
	assigned += M
	living_players -= M
	return (assigned.len > 0)

/datum/dynamic_ruleset/midround/autotraitor/execute()
	var/mob/M = pick(assigned)
	create_and_setup_role(role_category, M, post_setup = TRUE, setup_role = TRUE)
	/*	^ thats good? ^
	var/datum/role/traitor/newTraitor = new
	newTraitor.AssignToRole(M.mind, TRUE)
	newTraitor.OnPostSetup()
	newTraitor.Greet(GREET_AUTOTRAITOR)
	newTraitor.forgeObjectives()
	newTraitor.AnnounceObjectives()*/
	return TRUE

//////////////////////////////////////////////
//                                          //
//              RAGIN' MAGES                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/raginmages
	name = "Ragin' Mages"
	role_category = /datum/role/wizard
	my_fac = /datum/faction/wizards
	enemy_jobs = list("Security Officer","Detective","Head of Security", "Captain")
	required_pop = list(20,20,15,15,15,15,15,10,10,0)
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT/2
	cost = 20
	requirements = list(90,90,70,40,30,20,10,10,10,10)
	high_population_requirement = 50
	logo = "raginmages-logo"
	repeatable = TRUE

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/raginmages/ready(forced = FALSE)
	if(!wizardstart.len)
		log_admin("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		message_admins("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/raginmages/setup_role(datum/role/new_role)
	if(!created_a_faction)
		new_role.OnPostSetup() //Each individual role to show up gets a postsetup
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/raginmages/finish_setup(mob/new_character, index)
	new_character.forceMove(pick(wizardstart))
	return ..()

//////////////////////////////////////////////
//                                          //
//          NUCLEAR OPERATIVES (MIDROUND)   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/nuclear
	name = "Nuclear Assault"
	role_category = /datum/role/operative
	role_category_override = "Nuke Operative" // this is what is used on the ban page
	my_fac = /datum/faction/nuclear
	enemy_jobs = list("AI", "Cyborg", "Security Officer", "Warden","Detective","Head of Security", "Captain")
	required_pop = list(25, 25, 25, 25, 25, 20, 15, 15, 10, 10)
	required_candidates = 5 // Placeholder, see op. cap
	max_candidates = 5
	weight = BASE_RULESET_WEIGHT
	cost = 35
	requirements = list(90, 90, 80, 40, 40, 40, 30, 20, 20, 10)
	high_population_requirement = 60
	var/operative_cap = list(2, 2, 3, 3, 4, 5, 5, 5, 5, 5)
	logo = "nuke-logo"
	flags = HIGHLANDER_RULESET

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/nuclear/ready(forced = FALSE)
	if(forced)
		required_candidates = 1
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/nuclear/acceptable(population = 0, threat = 0)
	if(locate(/datum/dynamic_ruleset/roundstart/nuclear) in mode.executed_rules)
		return FALSE //Unavailable if nuke ops were already sent at roundstart
	var/indice_pop = min(10,round(living_players.len / 5) + 1)
	required_candidates = operative_cap[indice_pop]
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/nuclear/finish_setup(mob/new_character, index)
	create_uniq_faction(my_fac, post_setup = FALSE, give_objectives = TRUE)
	//^ nukies get into a faction? Need test ^
	var/list/turf/synd_spawn = list()

	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "Syndicate-Spawn")
			synd_spawn += get_turf(A)
			continue

	var/spawnpos = index
	if(spawnpos > synd_spawn.len)
		spawnpos = 1
	new_character.forceMove(synd_spawn[spawnpos])
	if(index == 1) //Our first guy is the leader
		var/datum/role/operative/leader/new_role = new
		// v is that bad? v
		new_role.AssignToRole(new_character.mind, TRUE)
		setup_role(new_role)
	else
		return ..()

//////////////////////////////////////////////
//                                          //
//            REVSQUAD (MIDROUND)           ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/revsquad
	name = "Revolutionary Squad"
	role_category = /datum/role/rev_leader
	enemy_jobs = list("AI", "Cyborg", "Security Officer", "Warden","Detective","Head of Security", "Captain")
	required_pop = list(25,25,25,25,25,20,15,15,10,10)
	required_candidates = 3
	weight = BASE_RULESET_WEIGHT
	cost = 30
	requirements = list(90, 90, 90, 90, 40, 40, 30, 20, 10, 10)
	high_population_requirement = 50
	my_fac = /datum/faction/revolution
	logo = "rev-logo"
	flags = HIGHLANDER_RULESET

	var/required_heads = 3

/datum/dynamic_ruleset/midround/from_ghosts/faction_based/revsquad/ready(forced = FALSE)
	if(forced)
		required_heads = 1
	if(find_faction_by_type(/datum/faction/revolution))
		return FALSE //Never send 2 rev types
	if(!..())
		return FALSE
	var/head_check = 0
	for(var/mob/player in mode.living_players)
		if(!player.mind)
			continue
		if(player.mind.assigned_role in command_positions)
			head_check++
	return (head_check >= required_heads)
