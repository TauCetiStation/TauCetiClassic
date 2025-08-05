
// JEDI

/datum/role/star_wars/jedi_leader
	name = "Jedi Leader"
	id = JEDI_LEADER
	logo_state = "jedi_logo"

	restricted_jobs = list("Security Cadet", "Security Officer", "Warden", "AI", "Cyborg", "Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Internal Affairs Agent", "Blueshield Officer")

	antag_hud_type = ANTAG_HUD_STAR_WARS
	antag_hud_name = "hud_jedi"

	skillset_type = /datum/skillset/max
	moveset_type = /datum/combat_moveset/cqc

/datum/role/star_wars/jedi_leader/OnPostSetup()
	. = ..()
	var/datum/faction/star_wars/F = faction
	F.force_source += antag.current

/datum/role/star_wars/jedi
	name = "Jedi"
	id = JEDI
	logo_state = "jedi_logo"

	antag_hud_type = ANTAG_HUD_STAR_WARS
	antag_hud_name = "hud_jedi"

	skillset_type = /datum/skillset/willpower
	moveset_type = /datum/combat_moveset/cqc

// SITH

/datum/role/star_wars/sith_leader
	name = "Sith Leader"
	id = SITH_LEADER
	logo_state = "sith_logo"

	restricted_jobs = list("Security Cadet", "Security Officer", "Warden", "AI", "Cyborg", "Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Internal Affairs Agent", "Blueshield Officer")

	antag_hud_type = ANTAG_HUD_STAR_WARS
	antag_hud_name = "hud_sith"

	skillset_type = /datum/skillset/max
	moveset_type = /datum/combat_moveset/cqc

/datum/role/star_wars/sith
	name = "Sith"
	id = SITH
	logo_state = "sith_logo"

	antag_hud_type = ANTAG_HUD_STAR_WARS
	antag_hud_name = "hud_sith"

	skillset_type = /datum/skillset/willpower
	moveset_type = /datum/combat_moveset/cqc