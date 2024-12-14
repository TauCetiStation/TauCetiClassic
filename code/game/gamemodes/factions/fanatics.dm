/datum/faction/fanatics
	name = F_MRAHARH_FANATICS
	ID = F_MRAHARH_FANATICS
	logo_state = "fanatics-logo"
	required_pref = ROLE_FANATIC

	initroletype = /datum/role/fanatic
	roletype = /datum/role/fanatic

	min_roles = 1
	max_roles = 3

	// For objectives
	var/datum/mind/sacrifice_target = null
	var/list/sacrificed = list()
	var/list/known_runes = list(/datum/fanatics_rune/convert_sacrifice,
	/datum/fanatics_rune/communication,
	)
	var/list/unknown_runes = list(/datum/fanatics_rune/cauldron_of_blood,
	/datum/fanatics_rune/cure,
	/datum/fanatics_rune/armor,
	/datum/fanatics_rune/claymore,
	/datum/fanatics_rune/charm,
	/datum/fanatics_rune/shield,
	/datum/fanatics_rune/meet,
	/datum/fanatics_rune/darkness,
	/datum/fanatics_rune/madness,
	)
	var/darkness_ritual_complete = FALSE


/datum/faction/fanatics/proc/add_new_rune()
	if(global.fanatics_runes.len <= known_runes.len)
		return
	var/datum/fanatics_rune/new_rune = pick(unknown_runes)
	LAZYADD(known_runes, new_rune)
	LAZYREMOVE(unknown_runes, new_rune)
	for(var/datum/role/fanatic/F in members)
		var/mob/living/carbon/human/member = F.antag.current
		to_chat(member, "<span class='fanatics'>Дивные символы рисуются в вашем разуме. Это - [new_rune.name], новые чары.</span>")

/datum/faction/fanatics/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/target/fanatics_sacrifice)
	AppendObjective(/datum/objective/fanatics_end_ritual)
	return TRUE

/datum/faction/fanatics/HandleRecruitedMind(datum/mind/M, laterole)
	. = ..()
	if(.)
		M.current.Paralyse(3)

/datum/faction/fanatics/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in player_list)
		if(!can_join_faction(player))
			ucs += player.mind
	return ucs

/datum/faction/fanatics/proc/find_sacrifice_target()
	var/list/possible_targets = get_unconvertables()

	if(possible_targets.len)
		sacrifice_target = pick(possible_targets)

/datum/faction/fanatics/proc/show_members(mob/living/carbon/human/M)
	to_chat(M,"<span class='fanatics'>В вашем разуме вырисовываются лица и имена остальных последователей:</span>")
	for(var/datum/role/fanatic/F in members)
		var/mob/living/carbon/human/member = F.antag.current
		if(member == M)
			continue
		to_chat(M,"<span class='fanatics'>[member.name], [F.antag.assigned_role]</span>")
