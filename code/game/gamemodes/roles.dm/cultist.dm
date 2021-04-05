/datum/role/cultist
	name = CULTIST
	id = CULTIST

	required_pref = ROLE_CULTIST
	restricted_jobs = list("Security Cadet", "Chaplain","AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Internal Affairs Agent")
	restricted_species_flags = list(NO_BLOOD)

	antag_hud_type = ANTAG_HUD_CULT
	antag_hud_name = "hudcultist"

	logo_state = "cult-logo"

/datum/role/cultist/CanBeAssigned(datum/mind/M)
	if(!..())
		return FALSE

	if(!is_convertable_to_cult(M))
		return FALSE

	return TRUE

/datum/role/cultist/RemoveFromRole(datum/mind/M, msg_admins)
	antag.current.Paralyse(5)
	to_chat(antag.current, "<span class='danger'><FONT size = 3>An unfamiliar white light flashes through your mind, cleansing the taint of the dark-one and the memories of your time as his servant with it.</span></FONT>")
	antag.memory = ""
	return ..()

/datum/role/cultist/proc/equip_cultist(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	if (mob.mind)
		if (mob.mind.assigned_role == "Clown")
			to_chat(mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			mob.mutations.Remove(CLUMSY)

	var/obj/item/weapon/paper/talisman/supply/T = new(mob)
	var/list/slots = list (
		"backpack" = SLOT_IN_BACKPACK,
		"left pocket" = SLOT_L_STORE,
		"right pocket" = SLOT_R_STORE,
		"left hand" = SLOT_L_HAND,
		"right hand" = SLOT_R_HAND,
	)
	var/where = mob.equip_in_one_of_slots(T, slots)
	if (!where)
		to_chat(mob, "Unfortunately, you weren't able to get a talisman. This is very bad and you should adminhelp immediately.")
	else
		var/obj/item/weapon/paper/talisman/T2 = new(mob)
		T2.power = new /datum/cult/communicate(T2)
		mob.equip_in_one_of_slots(T2, slots)
		to_chat(mob, "You have a talisman in your [where], one that will help you start the cult on this station. Use it well and remember - there are others.")
		mob.update_icons()

/datum/role/cultist/OnPostSetup(laterole)
	. = ..()
	equip_cultist(antag.current)
	var/datum/faction/cult/C = faction
	C?.grant_runeword(antag.current)

/datum/role/cultist/extraPanelButtons()
	var/dat = ..()
	dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];give_tome=1;'>(Give Tome)</a>"
	dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];give_amulet=1;'>(Give Amulet)</a>"
	return dat

/datum/role/cultist/RoleTopic(href, href_list, datum/mind/M, admin_auth)
	if(href_list["give_tome"])
		var/mob/living/carbon/human/H = M.current
		if (istype(H))
			var/obj/item/weapon/book/tome/T = new(H)

			var/list/slots = list (
				"backpack" = SLOT_IN_BACKPACK,
				"left pocket" = SLOT_L_STORE,
				"right pocket" = SLOT_R_STORE,
				"left hand" = SLOT_L_HAND,
				"right hand" = SLOT_R_HAND,
			)
			var/where = H.equip_in_one_of_slots(T, slots)
			if (!where)
				to_chat(usr, "<span class='warning'>Spawning tome failed!</span>")
			else
				to_chat(H, "A tome, a message from your new master, appears in your [where].")

	if(href_list["give_amulet"])
		equip_cultist(M.current)
