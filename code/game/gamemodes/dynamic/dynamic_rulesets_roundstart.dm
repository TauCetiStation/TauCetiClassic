
//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/traitor
	name = "Syndicate Traitors"
	role_category = /datum/role/traitor
	protected_from_jobs = list("Security Officer", "Warden", "Head of Personnel", "Cyborg", "Detective",
							"Head of Security", "Captain", "Chief Engineer", "Chief Medical Officer", "Research Director")
	restricted_from_jobs = list("AI")
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
	cost = 10
	var/traitor_threshold = 3
	var/additional_cost = 5
	requirements = list(10,10,10,10,10,10,10,10,10,10)
	high_population_requirement = 10

/datum/dynamic_ruleset/roundstart/traitor/choose_candidates()
	var/traitor_scaling_coeff = 10 - max(0,round(mode.threat_level / 10) - 5)//above 50 threat level, coeff goes down by 1 for every 10 levels
	var/num_traitors = min(round(mode.roundstart_pop_ready / traitor_scaling_coeff) + 1, candidates.len)
	for(var/i = 1 to num_traitors)
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		if(i > traitor_threshold)
			if((mode.threat > additional_cost))
				mode.spend_threat(additional_cost)
			else
				break
	return (assigned.len > 0)

/datum/dynamic_ruleset/roundstart/traitor/execute()
	var/datum/faction/traitor/traitors = create_uniq_faction(/datum/faction/traitor, post_setup = FALSE, give_objectives = FALSE)
	for(var/mob/M in assigned)
		create_and_setup_role(role_category, M, post_setup = TRUE, setup_role = TRUE)
		add_faction_member(traitors, M, recruit = FALSE, post_setup = TRUE, laterole = TRUE)

	// Above 3 traitors, we start to cost a bit more.
	return TRUE

//////////////////////////////////////////////
//                                          //
//               CHANGELINGS                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/changeling
	name = "Changelings"
	role_category = /datum/role/changeling
	protected_from_jobs = list("Security Officer", "Warden", "Head of Personnel", "Detective",
							"Head of Security", "Captain", "Chief Engineer", "Chief Medical Officer", "Research Director")
	restricted_from_jobs = list("AI","Cyborg")
	enemy_jobs = list("Security Officer","Detective", "Warden", "Head of Security", "Captain")
	required_pop = list(15,15,15,10,10,10,10,5,5,0)
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
	cost = 18
	requirements = list(80,70,60,60,30,20,10,10,10,10)
	high_population_requirement = 30

// -- Currently a copypaste of traitors. Could be fixed to be less copy & paste.
/datum/dynamic_ruleset/roundstart/changeling/choose_candidates()
	var/mob/M = pick(candidates)
	assigned += M
	candidates -= M
	return (assigned.len > 0)

/datum/dynamic_ruleset/roundstart/changeling/execute()
	var/datum/faction/changeling/hivemind = create_uniq_faction(/datum/faction/changeling, post_setup = FALSE, give_objectives = FALSE)
	for(var/mob/M in assigned)
		create_and_setup_role(role_category, M, post_setup = TRUE, setup_role = TRUE)
		add_faction_member(hivemind, M, recruit = FALSE, post_setup = TRUE, laterole = TRUE)
	return TRUE

//////////////////////////////////////////////
//                                          //
//               WIZARDS                    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/wizard
	name = "Wizard"
	role_category = /datum/role/wizard
	enemy_jobs = list("Security Officer","Detective","Head of Security", "Captain")
	required_pop = list(15,15,15,10,10,10,10,5,5,0)
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT/2
	cost = 30
	requirements = list(90,90,70,40,30,20,10,10,10,10)
	high_population_requirement = 40

/datum/dynamic_ruleset/roundstart/wizard/acceptable(population = 0, threat = 0)
	if(!wizardstart.len)
		log_mode("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		return FALSE
	return ..()

/datum/dynamic_ruleset/roundstart/wizard/execute()
	var/mob/M = pick(assigned)
	create_and_setup_role(role_category, M, post_setup = TRUE, setup_role = TRUE)
	var/datum/faction/wizards/federation = create_uniq_faction(/datum/faction/wizards, post_setup = FALSE, give_objectives = FALSE)
	add_faction_member(federation, M, recruit = FALSE, post_setup = TRUE, laterole = TRUE)

	return TRUE

//////////////////////////////////////////
//                                      //
//                CULT                	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                      //
//////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/cult
	name = "Cult"
	role_category = /datum/role/cultist
	restricted_from_jobs = list("AI", "Cyborg", "Security Officer", "Warden", "Detective",
							"Head of Security", "Captain", "Chaplain", "Head of Personnel", "Internal Affairs Agent",
							"Chief Engineer", "Chief Medical Officer", "Research Director")
	enemy_jobs = list("Security Officer","Warden", "Detective","Head of Security", "Captain")
	required_pop = list(25,25,20,20,20,20,20,15,15,10)
	required_candidates = 4
	required_enemies = list(2,2,2,2,2,2,2,2,2,2)
	weight = BASE_RULESET_WEIGHT
	cost = 30
	requirements = list(90,80,60,30,20,10,10,10,10,10)
	high_population_requirement = 40
	var/cultist_cap = list(2,2,3,4,4,4,4,4,4,4)
	flags = HIGHLANDER_RULESET

/datum/dynamic_ruleset/roundstart/cult/ready(forced = FALSE)
	var/indice_pop = min(10,round(mode.roundstart_pop_ready / 5) + 1)
	required_candidates = cultist_cap[indice_pop]
	if(forced)
		required_candidates = 1
	. = ..()

/datum/dynamic_ruleset/roundstart/cult/choose_candidates()
	var/indice_pop = min(10,round(mode.roundstart_pop_ready / 5) + 1)
	var/cultists = cultist_cap[indice_pop]
	for (var/i = 1 to cultists)
		if(candidates.len <= 0)
			break
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
	return (assigned.len > 0)

/datum/dynamic_ruleset/roundstart/cult/execute()
	//if ready() did its job, candidates should have 4 or more members in it
	var/datum/faction/cult/cult = create_uniq_faction(/datum/faction/cult, post_setup = FALSE, give_objectives = FALSE)
	for(var/mob/M in assigned)
		create_and_setup_role(role_category, M, post_setup = TRUE, setup_role = TRUE)
		add_faction_member(cult, M, recruit = FALSE, post_setup = TRUE, laterole = TRUE)
	return TRUE

//////////////////////////////////////////////
//                                          //
//          NUCLEAR OPERATIVES              ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/nuclear
	name = "Nuclear Emergency"
	role_category = /datum/role/operative
	role_category_override = "Nuke Operative" // this is what is used on the ban page
	restricted_from_jobs = list("Head of Security", "Captain") //Just to be sure that a nukie getting picked won't ever imply a Captain or HoS not getting drafted
	enemy_jobs = list("AI", "Cyborg", "Security Officer", "Warden","Detective","Head of Security", "Captain")
	required_pop = list(25,25,20,20,20,20,20,15,15,10)
	required_candidates = 5 //This value is useless, see operative_cap
	required_enemies = list(2,2,2,2,2,2,2,2,2,2)
	weight = BASE_RULESET_WEIGHT
	cost = 30
	requirements = list(90, 80, 60, 30, 20, 10, 10, 10, 10, 10)
	high_population_requirement = 40
	var/operative_cap = list(2, 2, 3, 3, 4, 5, 5, 5, 5, 5)
	flags = HIGHLANDER_RULESET

/datum/dynamic_ruleset/roundstart/nuclear/ready(forced = FALSE)
	var/indice_pop = min(10, round(mode.roundstart_pop_ready / 5) + 1)
	required_candidates = operative_cap[indice_pop]
	if(forced)
		required_candidates = 1
	. = ..()

/datum/dynamic_ruleset/roundstart/nuclear/choose_candidates()
	var/indice_pop = min(10, round(mode.roundstart_pop_ready / 5) + 1)
	var/operatives = operative_cap[indice_pop]
	log_mode("[name]: indice_pop = [indice_pop], operatives = [operatives]")
	for(var/operatives_number = 1 to operatives)
		if(candidates.len <= 0)
			break
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
	return (assigned.len > 0)

/datum/dynamic_ruleset/roundstart/nuclear/execute()
	//If ready() did its job, candidates should have 5 or more members in it
	var/datum/faction/nuclear/nuke = create_uniq_faction(/datum/faction/nuclear, post_setup = FALSE, give_objectives = FALSE)
	var/leader = FALSE
	for(var/mob/M in assigned)
		if(leader)
			leader = TRUE
			create_and_setup_role(/datum/role/operative/leader, M, post_setup = TRUE, setup_role = TRUE)
		else
			create_and_setup_role(role_category, M, post_setup = TRUE, setup_role = TRUE)
		add_faction_member(nuke, M, recruit = FALSE, post_setup = TRUE, laterole = TRUE)
	return TRUE

//////////////////////////////////////////////
//                                          //
//               EXTENDED                   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/extended
	name = "Extended"
	role_category = null
	restricted_from_jobs = list()
	enemy_jobs = list()
	required_pop = list(30,30,30,30,30,30,30,30,30,30)
	required_candidates = 0
	weight = 0.5*BASE_RULESET_WEIGHT
	cost = 0
	requirements = list(0,0,0,0,0,0,0,0,0,0)
	high_population_requirement = 101

// 70% chance of allowing extended at 0-30 threat, then (100-threat)% chance.
/datum/dynamic_ruleset/roundstart/extended/acceptable(population, threat_level)
	var/probability = clamp(threat_level, 30, 100)
	return !prob(probability)

/datum/dynamic_ruleset/roundstart/extended/choose_candidates()
	return TRUE

/datum/dynamic_ruleset/roundstart/extended/execute()
	log_mode("Starting a round of extended.")
	mode.forced_extended = TRUE
	return TRUE

//////////////////////////////////////////////
//                                          //
//               REVS		                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/delayed/revs
	name = "Revolution"
	role_category = /datum/role/rev_leader
	restricted_from_jobs = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director", "Internal Affairs Agent")
	enemy_jobs = list("Security Officer","Detective","Head of Security", "Captain", "Warden")
	required_pop = list(25,25,25,20,20,20,15,15,15,15)
	required_candidates = 3
	weight = BASE_RULESET_WEIGHT
	cost = 40
	requirements = list(101,101,70,40,30,20,10,10,10,10)
	high_population_requirement = 50
	delay = 5 MINUTES
	var/required_heads = 3
	flags = HIGHLANDER_RULESET

/datum/dynamic_ruleset/roundstart/delayed/revs/ready(forced = FALSE)
	if(forced)
		required_heads = 1
		required_candidates = 1
	if(!..())
		return FALSE
	var/head_check = 0
	for(var/mob/player in player_list)
		if(player.mind.assigned_role in command_positions)
			head_check++
	return (head_check >= required_heads)

/datum/dynamic_ruleset/roundstart/delayed/revs/choose_candidates()
	var/max_canditates = 4
	for(var/i = 1 to max_canditates)
		if(candidates.len <= 0)
			break
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		assigned_ckeys += M.ckey
	return (assigned.len > 0)

/datum/dynamic_ruleset/roundstart/delayed/revs/execute()
	var/datum/faction/revolution/R = create_uniq_faction(/datum/faction/revolution, post_setup = FALSE, give_objectives = FALSE)
	for(var/mob/M in assigned)
		create_and_setup_role(role_category, M, post_setup = TRUE, setup_role = TRUE)
		add_faction_member(R, M, recruit = FALSE, post_setup = TRUE, laterole = TRUE)

	return TRUE
