/datum/role/cultist
	name = CULTIST
	id = CULTIST

	required_pref = ROLE_CULTIST
	restricted_jobs = list("Security Cadet", "Chaplain", "AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Internal Affairs Agent")
	restricted_species_flags = list(NO_BLOOD)

	antag_hud_type = ANTAG_HUD_CULT
	antag_hud_name = "hudcultist"

	logo_state = "cult-logo"

	var/holy_rank = CULT_ROLE_HIGHPRIEST

/datum/role/cultist/CanBeAssigned(datum/mind/M, laterole)
	if(laterole == FALSE) // can be null
		return ..() // religion has all necessary checks, but they are not applicable to mind, as here
	return TRUE

/datum/role/cultist/RemoveFromRole(datum/mind/M, msg_admins)
	..()
	var/datum/faction/cult/C = faction
	if(istype(C))
		C.religion?.remove_member(M.current)

/datum/role/cultist/proc/equip_cultist(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	if(mob.mind)
		if(mob.mind.assigned_role == "Clown")
			to_chat(mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			mob.mutations.Remove(CLUMSY)

	mob.equip_to_slot_or_del(new /obj/item/device/cult_camera(mob), SLOT_IN_BACKPACK)

	var/datum/faction/cult/C = faction
	if(istype(C))
		C.religion.give_tome(mob)

/datum/role/cultist/OnPostSetup(laterole)
	..()
	if(!laterole)
		equip_cultist(antag.current)
	var/datum/faction/cult/C = faction
	if(istype(C))
		C.religion.add_member(antag.current, holy_rank)

/datum/role/cultist/extraPanelButtons()
	var/dat = ..()
	dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];cult_tome=1;'>(Give Tome)</a>"
	dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];cult_heaven=1;'>(TP to Heaven)</a>"
	dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];cult_cheating=1;'>(Cheating Religion)</a>"
	dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];cult_leader=1;'>(Make Leader)</a>"
	return dat

/datum/role/cultist/RoleTopic(href, href_list, datum/mind/M, admin_auth)
	var/datum/faction/cult/C = faction
	if(istype(C))
		if(href_list["cult_tome"])
			var/mob/living/carbon/human/H = M.current
			if(istype(H))
				if(C.religion)
					C.religion.give_tome(H)

		if(href_list["cult_heaven"])
			var/area/A = locate(C.religion.area_type)
			var/turf/T = get_turf(pick(A.contents))
			M.current.forceMove(T)

		if(href_list["cult_cheating"])
			C.religion.favor = 100000
			C.religion.piety = 100000
			// All aspects
			var/list/L = subtypesof(/datum/aspect)
			for(var/type in L)
				L[type] = 1
			C.religion.add_aspects(L)

		if(href_list["cult_leader"])
			var/mob/living/carbon/human/H = M.current
			H.mind.holy_role = CULT_ROLE_MASTER
			add_antag_hud("hudheadcultist")
	else
		to_chat(M.current, "Сначала добавьте культиста во фракцию культа")

/datum/role/cultist/leader
	name = CULT_LEADER

	antag_hud_type = ANTAG_HUD_CULT
	antag_hud_name = "hudheadcultist"

	holy_rank = CULT_ROLE_MASTER
