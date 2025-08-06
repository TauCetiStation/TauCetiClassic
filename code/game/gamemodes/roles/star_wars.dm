
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
	var/mob/living/carbon/human/H = antag.current
	var/datum/faction/star_wars/F = faction

	F.force_source.force_users += H
	H.equipOutfit(/datum/outfit/star_wars/jedi)
	. = ..()

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


/datum/role/star_wars/sith_leader/OnPostSetup()
	var/mob/living/carbon/human/H = antag.current
	var/datum/faction/star_wars/F = faction

	F.force_source.force_users += H
	var/sword = new /obj/item/weapon/melee/energy/sword/star_wars/sith/leader(H.loc)
	var/robe = new /obj/item/clothing/suit/star_wars/sith(H.loc)
	var/hood = new /obj/item/clothing/head/star_wars/sith(H.loc)

	H.equip_to_slot_if_possible(sword, SLOT_IN_BACKPACK)
	H.equip_to_slot_if_possible(robe, SLOT_IN_BACKPACK)
	H.equip_to_slot_if_possible(hood, SLOT_IN_BACKPACK)
	. = ..()

/datum/role/star_wars/sith
	name = "Sith"
	id = SITH
	logo_state = "sith_logo"

	antag_hud_type = ANTAG_HUD_STAR_WARS
	antag_hud_name = "hud_sith"

	skillset_type = /datum/skillset/willpower
	moveset_type = /datum/combat_moveset/cqc
