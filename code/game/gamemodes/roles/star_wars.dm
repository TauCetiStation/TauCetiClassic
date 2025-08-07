
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
	var/datum/faction/star_wars/jedi/F = faction

	F.force_source.force_users += H
	H.equipOutfit(/datum/outfit/star_wars/jedi)

	var/datum/action/innate/star_wars/jedi/find_force/FF = new(H)
	var/datum/action/innate/star_wars/jedi/convert/CO = new(H)
	FF.Grant(H)
	CO.Grant(H)

	var/list/force_spells = F.force_spells.Copy()
	for(var/i in 1 to 3)
		var/obj/effect/proc_holder/spell/S = pick_n_take(force_spells)
		H.AddSpell(new S)

	. = ..()

/datum/role/star_wars/jedi
	name = "Jedi"
	id = JEDI
	logo_state = "jedi_logo"

	antag_hud_type = ANTAG_HUD_STAR_WARS
	antag_hud_name = "hud_jedi"

	skillset_type = /datum/skillset/willpower
	moveset_type = /datum/combat_moveset/cqc

/datum/role/star_wars/jedi/OnPostSetup()
	var/mob/living/carbon/C = antag.current
	var/datum/faction/star_wars/jedi/F = faction

	var/list/force_spells = F.force_spells.Copy()
	for(var/i in 1 to 2)
		var/obj/effect/proc_holder/spell/S = pick_n_take(force_spells)
		C.AddSpell(new S)

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
	var/datum/faction/star_wars/sith/F = faction

	F.force_source.force_users += H

	var/datum/action/innate/star_wars/sith/find_force/FF = new(H)
	var/datum/action/innate/star_wars/sith/convert/CO = new(H)
	var/datum/action/innate/star_wars/sith/force_convert/FC = new(H)
	FF.Grant(H)
	CO.Grant(H)
	FC.Grant(H)

	var/list/force_spells = F.force_spells.Copy()
	for(var/i in 1 to 3)
		var/obj/effect/proc_holder/spell/S = pick_n_take(force_spells)
		H.AddSpell(new S)

	var/sword = new /obj/item/weapon/dualsaber/sith(H.loc)
	var/robe = new /obj/item/clothing/suit/hooded/star_wars/sith(H.loc)

	H.equip_to_slot_if_possible(sword, SLOT_IN_BACKPACK)
	H.equip_to_slot_if_possible(robe, SLOT_IN_BACKPACK)
	. = ..()

/datum/role/star_wars/sith
	name = "Sith"
	id = SITH
	logo_state = "sith_logo"

	antag_hud_type = ANTAG_HUD_STAR_WARS
	antag_hud_name = "hud_sith"

	skillset_type = /datum/skillset/willpower
	moveset_type = /datum/combat_moveset/cqc

/datum/role/star_wars/sith/OnPostSetup()
	var/mob/living/carbon/C = antag.current
	var/datum/faction/star_wars/sith/F = faction

	var/list/force_spells = F.force_spells.Copy()
	for(var/i in 1 to 2)
		var/obj/effect/proc_holder/spell/S = pick_n_take(force_spells)
		C.AddSpell(new S)
