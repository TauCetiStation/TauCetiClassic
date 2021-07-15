/datum/role/gangster
	name = GANGSTER
	id = GANGSTER

	required_pref = ROLE_FAMILIES
	restricted_jobs = list("Head of Personnel", "Security Cadet", "AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Internal Affairs Agent")

	antag_hud_type = ANTAG_HUD_GANGSTER
	antag_hud_name = "hud_gangster"

	/// The action used to spawn family induction packages.
	var/datum/action/cooldown/spawn_induction_package/package_spawner

/datum/role/gangster/New(datum/mind/M, datum/faction/fac, override)
	. = ..()
	package_spawner = new(src)

/datum/role/gangster/OnPreSetup()
	. = ..()
	var/datum/faction/gang/G = faction
	if(!istype(G))
		return

	logo_state = G.gang_id
	antag_hud_name = "hud_[G.gang_id]"

/datum/role/gangster/OnPostSetup(laterole)
	..()
	package_spawner.Grant(antag.current)
	package_spawner.my_gang_datum = faction
	var/mob/living/M = antag.current
	if(M.hud_used)
		var/datum/hud/H = M.hud_used
		var/atom/movable/screen/wanted/giving_wanted_lvl = new
		H.wanted_lvl = giving_wanted_lvl
		H.mymob.client.screen += giving_wanted_lvl

/datum/role/gangster/RemoveFromRole(datum/mind/M, msg_admins)
	. = ..()
	package_spawner.Remove(M.current)
	var/mob/living/L = M.current
	if(L.hud_used)
		var/datum/hud/H = L.hud_used
		H.mymob.client.screen -= H.wanted_lvl
		QDEL_NULL(H.wanted_lvl)

/datum/role/gangster/Greet(laterole)
	antag.current.playsound_local(null, 'sound/antag/thatshowfamiliesworks.ogg', VOL_EFFECTS_MASTER, null, FALSE)

	to_chat(antag.current, "<B>Поскольку Вы первый гангстер, ваша форма и баллончик с краской находится в инвентаре!</B>")

	to_chat(antag.current, "<B><font size=3 color=red>[faction.name] на всю жизнь!</font></B>")
	to_chat(antag.current, "<B><font size=2 color=red>Помечайте территорию краской, надевай цвета своей банды, и набирай больше гангстеров с помощью Вступительных Наборов!</font></B>")
	to_chat(antag.current, "<B><font size=6 color=red>Вы все еще командный антагонист. Делай то, что нужно твоей банде!</font></B>")
	to_chat(antag.current, "<B><font size=4 color=red>Будьте осторожны, убийства приведут к более решительным действиям полиции.</font></B>")

/datum/role/gangster/extraPanelButtons()
	var/dat = ..()
	dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];gangster_equip=1'>(Give Extra Equipment)</a>"
	return dat

/datum/role/gangster/RoleTopic(href, href_list, datum/mind/M, admin_auth)
	if(href_list["gangster_equip"])
		equip_gangster_in_inventory()
		var/mob/living/carbon/human/H = M.current
		var/datum/faction/gang/G = faction
		if(istype(H) && istype(G))
			for(var/type in G.free_clothes)
				var/obj/O = new type(H)
				var/list/slots = list(
					"backpack" = SLOT_IN_BACKPACK,
					"left hand" = SLOT_L_HAND,
					"right hand" = SLOT_R_HAND,
				)
				var/equipped = H.equip_in_one_of_slots(O, slots)
				if(!equipped)
					to_chat(H, "Unfortunately, you could not bring your [O] to this shift. You will need to find one.")
					qdel(O)

/datum/role/gangster/proc/equip_gangster_in_inventory()
	var/mob/living/carbon/human/H = antag.current
	var/datum/faction/gang/G = faction
	if(istype(H) && istype(G))
		for(var/type in G.free_clothes)
			var/obj/O = new type(H)
			var/list/slots = list(
				"backpack" = SLOT_IN_BACKPACK,
				"left hand" = SLOT_L_HAND,
				"right hand" = SLOT_R_HAND,
			)
			var/equipped = H.equip_in_one_of_slots(O, slots)
			if(!equipped)
				to_chat(H, "Unfortunately, you could not bring your [O] to this shift. You will need to find one.")
				qdel(O)

/datum/role/gangster/leader
	id = GANGSTER_LEADER

/datum/role/gangster/leader/OnPostSetup(laterole)
	..()
	equip_gangster_in_inventory()
