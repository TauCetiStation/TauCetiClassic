//////////////////////////////////////////////
//                                          //
//            LATEJOIN RULESETS             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/trim_candidates()
	var/role_id = initial(role_category.id)
	//var/role_pref = initial(role_category.required_pref)
	for(var/mob/P in candidates)
		if(!P.client || !P.mind || !P.mind.assigned_role)//are they connected?
			candidates.Remove(P)
			continue
		if(jobban_isbanned(P, role_id) || (role_category_override && jobban_isbanned(P, role_category_override)))//are they willing and not antag-banned?
			candidates.Remove(P)
			continue
		if((P.mind.assigned_role && (P.mind.assigned_role in restricted_from_jobs)) || (P.mind.role_alt_title && (P.mind.role_alt_title in restricted_from_jobs)))//does their job allow for it?
			candidates.Remove(P)
			continue
		if((exclusive_to_jobs.len > 0) && !(P.mind.assigned_role in exclusive_to_jobs))//is the rule exclusive to their job?
			candidates.Remove(P)
			continue

/datum/dynamic_ruleset/latejoin/ready(forced = FALSE)
	if(!forced)
		if(!check_enemy_jobs(TRUE,TRUE))
			return FALSE
	return ..()


//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/infiltrator
	name = "Syndicate Infiltrator"
	role_category = /datum/role/traitor
	protected_from_jobs = list("Security Officer", "Warden", "Head of Personnel", "Detective", "Head of Security",
							"Captain", "Chief Engineer", "Chief Medical Officer", "Research Director")
	restricted_from_jobs = list("AI","Cyborg")
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
	cost = 5
	requirements = list(40,30,20,10,10,10,10,10,10,10)
	high_population_requirement = 10
	repeatable = TRUE
	flags = TRAITOR_RULESET

/datum/dynamic_ruleset/latejoin/infiltrator/execute()
	var/mob/M = pick(assigned)
	var/datum/role/traitor/newTraitor = new
	newTraitor.AssignToRole(M.mind, TRUE)
	newTraitor.Greet(GREET_LATEJOIN)
	// ^ should try remake this like roundtarts threat? ^
	//and looks like infiltrator doesn't have faction?
	return TRUE

/datum/dynamic_ruleset/latejoin/infiltrator/previous_rounds_odds_reduction(result)
	return result


//////////////////////////////////////////////
//                                          //
//        RAGIN' MAGES (LATEJOIN)           ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////1.01 - Lowered weight from 3 to 2

/datum/dynamic_ruleset/latejoin/raginmages
	name = "Ragin' Mages"
	role_category = /datum/role/wizard
	enemy_jobs = list("Security Officer","Detective", "Warden", "Head of Security", "Captain")
	required_pop = list(15,15,10,10,10,10,10,0,0,0)
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT/2
	cost = 20
	requirements = list(90,90,70,40,30,20,10,10,10,10)
	high_population_requirement = 40
	repeatable = TRUE

/datum/dynamic_ruleset/latejoin/raginmages/ready(forced = FALSE)
	if(!wizardstart.len)
		log_admin("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		message_admins("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		return FALSE

	return ..()

/datum/dynamic_ruleset/latejoin/raginmages/execute()
	var/mob/M = pick(assigned)
	if(!latejoinprompt(M))
		return FALSE
	var/datum/faction/wizards/federation = create_uniq_faction(/datum/faction/wizards, post_setup = FALSE, give_objectives = FALSE)
	var/datum/role/wizard/newWizard = new role_category(M.mind, federation, TRUE)
	if(!ishuman(M))
		var/mob/living/carbon/C = M
		if(istype(C))
			C = C.humanize()
	newWizard.Greet(GREET_LATEJOIN)
	return TRUE

//////////////////////////////////////////////
//                                          //
//       REVOLUTIONARY PROVOCATEUR          ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/provocateur
	name = "Provocateur"
	role_category = /datum/role/rev_leader
	restricted_from_jobs = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director", "Internal Affairs Agent")
	enemy_jobs = list("AI", "Cyborg", "Security Officer","Detective","Head of Security", "Captain", "Warden")
	required_pop = list(20,20,15,15,15,15,15,0,0,0)
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
	cost = 20
	var/required_heads = 3
	requirements = list(101,101,70,40,30,20,20,20,20,20)
	high_population_requirement = 50
	flags = HIGHLANDER_RULESET

/datum/dynamic_ruleset/latejoin/provocateur/ready(forced = FALSE)
	if(forced)
		required_heads = 1
	if(find_faction_by_type(/datum/faction/revolution))
		return FALSE //Never send 2 rev types
	if(!..())
		return FALSE
	var/head_check = 0
	for(var/mob/player in mode.living_players)
		if(player.mind.assigned_role in command_positions)
			head_check++
	return (head_check >= required_heads)

/datum/dynamic_ruleset/latejoin/provocateur/execute()
	var/mob/M = pick(assigned)
	var/antagmind = M.mind
	var/datum/faction/F = create_faction(/datum/faction/revolution)
	F.forgeObjectives()
	// v should i rework spawn(1sec) in addtimer(... 10)? v
	spawn(1 SECONDS)
		var/datum/role/rev_leader/L = new(antagmind, F, HEADREV)
		L.Greet(GREET_LATEJOIN)
		L.OnPostSetup()
	return TRUE

//////////////////////////////////////////////
//                                          //
//               CHANGELINGS                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/changeling
	name = "Changelings"
	role_category = /datum/role/changeling
	protected_from_jobs = list("Security Officer", "Warden", "Head of Personnel", "Detective",
							"Head of Security", "Captain", "Chief Engineer", "Chief Medical Officer", "Research Director")
	restricted_from_jobs = list("AI","Cyborg",)
	enemy_jobs = list("Security Officer","Detective", "Warden", "Head of Security", "Captain")
	required_pop = list(15,15,15,10,10,10,10,5,5,0)
	required_candidates = 1
	weight = BASE_RULESET_WEIGHT
	cost = 20
	requirements = list(80,70,60,60,30,20,10,10,10,10)
	high_population_requirement = 30
	repeatable = FALSE

/datum/dynamic_ruleset/latejoin/changeling/execute()
	var/mob/M = pick(assigned)
	var/datum/role/changeling/newChangeling = new
	newChangeling.AssignToRole(M.mind, TRUE)
	newChangeling.Greet(GREET_LATEJOIN)
	var/datum/faction/changeling/hivemind = create_uniq_faction(/datum/faction/changeling, post_setup = FALSE, give_objectives = FALSE)
	hivemind.OnPostSetup()
	hivemind.HandleRecruitedRole(newChangeling)
	// ^ should i remake this like roundstarts wizards/traitors/changelings? ^
	return TRUE

/datum/dynamic_ruleset/latejoin/changeling/previous_rounds_odds_reduction(result)
	return result
