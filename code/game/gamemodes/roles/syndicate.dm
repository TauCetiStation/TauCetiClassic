/datum/role/operative
	name = NUKE_OP
	id = NUKE_OP
	disallow_job = TRUE

	required_pref = ROLE_OPERATIVE

	antag_hud_type = ANTAG_HUD_OPS
	antag_hud_name = "hudsyndicate"

	logo_state = "nuke-logo"

	var/nuclear_outfit = /datum/outfit/nuclear
	skillset_type = /datum/skillset/nuclear_operative

	var/TC_num = 0 // using for statistics
	moveset_type = /datum/combat_moveset/cqc

/datum/role/operative/New()
	..()
	AddComponent(/datum/component/gamemode/syndicate, TC_num, "nuclear")

/datum/role/operative/proc/NukeNameAssign(datum/mind/synd_mind)
	var/choose_name = sanitize_safe(input(synd_mind.current, "You are a Gorlex Maradeurs agent! What is your name?", "Choose a name") as text, MAX_NAME_LEN)

	if(!choose_name)
		return

	synd_mind.current.name = choose_name
	synd_mind.current.real_name = choose_name

/datum/role/operative/OnPostSetup(laterole)
	antag.current.faction = "syndicate"
	antag.current.real_name = "Gorlex Maradeurs Operative"

	if(ishuman(antag.current))
		var/mob/living/carbon/human/H = antag.current
		H.equipOutfit(nuclear_outfit)
	antag.current.add_language(LANGUAGE_SYCODE)

	INVOKE_ASYNC(src, PROC_REF(NukeNameAssign), antag)
	return ..()

/datum/role/operative/Greet(greeting, custom)
	. = ..()
	antag.current.playsound_local(null, 'sound/antag/ops.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/datum/role/operative/extraPanelButtons()
	var/dat = ..()
	dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];nuke_tp=1;'>(Tp to base)</a>"
	dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];nuke_tellcode=1'>(Tell code)</a>"
	return dat

/datum/role/operative/RoleTopic(href, href_list, datum/mind/M, admin_auth)
	if(href_list["nuke_tp"])
		antag.current.forceMove(get_turf(locate("landmark*Syndicate-Spawn")))

	else if(href_list["nuke_tellcode"])
		var/code
		for (var/obj/machinery/nuclearbomb/bombue in poi_list)
			if (length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
				code = bombue.r_code
				break
		if (code)
			antag.store_memory("<B>Syndicate Nuclear Bomb Code</B>: [code]", 0)
			to_chat(antag.current, "The nuclear authorization code is: <B>[code]</B>")
		else
			to_chat(usr, "<span class='warning'>No valid nuke found!</span>")

/datum/role/operative/leader
	name = NUKE_OP_LEADER
	id = NUKE_OP_LEADER

	logo_state = "nuke-logo-leader"

	nuclear_outfit = /datum/outfit/nuclear/leader
	skillset_type = /datum/skillset/nuclear_operative_leader

/datum/role/operative/leader/OnPostSetup(laterole)
	. = ..()
	var/datum/faction/nuclear/N = faction
	if (istype(N) && N.nuke_code)
		antag.store_memory("<B>Syndicate Nuclear Bomb Code</B>: [N.nuke_code]", 0)
		to_chat(antag.current, "The nuclear authorization code is: <B>[N.nuke_code]</B>")
		var/obj/item/weapon/paper/P = new
		P.info = "The nuclear authorization code is: <b>[N.nuke_code]</b>"
		P.name = "nuclear bomb code"
		P.update_icon()
		var/mob/living/carbon/human/H = antag.current
		P.loc = H.loc
		H.equip_to_slot_or_del(P, SLOT_R_HAND, 0)
		H.update_icons()

/datum/role/operative/lone
	name = LONE_OP
	id = LONE_OP
	skillset_type = /datum/skillset/max

/datum/role/operative/lone/OnPostSetup(laterole)
	. = ..()
	var/datum/objective/nuclear/N = objectives.FindObjective(/datum/objective/nuclear)
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

/datum/role/operative/lone/forgeObjectives()
	if(!..())
		return FALSE
	switch(rand(1,100))
		if(1 to 50)
			AppendObjective(/datum/objective/hijack)

		if(51 to 100)
			AppendObjective(/datum/objective/nuclear)
