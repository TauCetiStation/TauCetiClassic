/datum/role/emergency_responder
	name = RESPONDER
	id = RESPONDER
	disallow_job = TRUE

	logo_state = "ert-logo"
	antag_hud_type = ANTAG_HUD_ERT
	antag_hud_name = "hudoperative"
	skillset_type = /datum/skillset/max

/datum/role/death_commando
	name = DEATHSQUADIE
	id = DEATHSQUADIE
	disallow_job = TRUE

	logo_state = "death-logo"
	antag_hud_type = ANTAG_HUD_DEATHCOM
	antag_hud_name = "huddeathsquad"
	skillset_type = /datum/skillset/max

/datum/role/syndicate_responder
	name = NUKE_OP
	id = NUKE_OP
	disallow_job = TRUE

	antag_hud_type = ANTAG_HUD_OPS
	antag_hud_name = "hudsyndicate"

	logo_state = "nuke-logo"

	skillset_type = /datum/skillset/nuclear_operative

	moveset_type = /datum/combat_moveset/cqc


/datum/role/syndicate_responder/OnPostSetup(laterole)
	. = ..()
	antag.current.faction = "syndicate"
	antag.current.add_language(LANGUAGE_SYCODE)


	var/datum/objective/nuclear/N = faction.objective_holder.FindObjective(/datum/objective/nuclear)
	if(!N)
		return

	var/nukecode = "ERROR"
	for(var/obj/machinery/nuclearbomb/bomb in poi_list)
		if(!bomb.r_code)
			continue
		if(bomb.r_code == "LOLNO")
			continue
		if(bomb.r_code == "ADMIN")
			continue
		if(bomb.nuketype != "NT")
			continue

		nukecode = bomb.r_code

	to_chat(antag.current, "<span class='bold notice'>Код от бомбы: [nukecode]</span>")
	antag.current.mind.store_memory("Код от бомбы: [nukecode]")

/datum/role/pirate
	name = PIRATE
	id = PIRATE
	disallow_job = TRUE

	logo_state = "raider-logo"
	antag_hud_type = ANTAG_HUD_PIRATES
	antag_hud_name = "hudpiratez"
	skillset_type = /datum/skillset/max

/datum/role/soviet
	name = "USSP Soldier"
	id = "USSP Soldier"
	disallow_job = TRUE

	logo_state = "soviet"
	skillset_type = /datum/skillset/soviet

/datum/role/security_responder
	name = "Security Officer"
	id = "Security Officer"
	disallow_job = TRUE

	skillset_type = /datum/skillset/officer

/datum/role/marine_responder
	name = "Marine"
	id = "Marine"
	disallow_job = TRUE

	skillset_type = /datum/skillset/hos

/datum/role/emag_clown
	name = "Clown That Emags Things"
	id = "Clown That Emags Things"
	disallow_job = TRUE

	skillset_type = /datum/skillset/clown
