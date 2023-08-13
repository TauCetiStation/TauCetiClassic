/datum/role/gangster
	name = GANGSTER
	id = GANGSTER

	required_pref = ROLE_FAMILIES
	restricted_jobs = list("Head of Personnel", "Security Cadet", "AI", "Cyborg", "Security Officer", "Warden", "Head of Security", "Captain", "Internal Affairs Agent", "Blueshield Officer")

	antag_hud_type = ANTAG_HUD_GANGSTER
	antag_hud_name = "hud_gangster"

	/// The action used to spawn family induction packages.
	var/datum/action/cooldown/spawn_induction_package/package_spawner
	skillset_type = /datum/skillset/gangster

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

/datum/role/gangster/RemoveFromRole(datum/mind/M, msg_admins)
	. = ..()
	package_spawner.Remove(M.current)

/datum/role/gangster/add_ui(datum/hud/hud)
	wanted_lvl_screen.add_to_hud(hud)

/datum/role/gangster/remove_ui(datum/hud/hud)
	wanted_lvl_screen.remove_from_hud(hud)

/datum/role/gangster/Greet(laterole)
	antag.current.playsound_local(null, 'sound/antag/thatshowfamiliesworks.ogg', VOL_EFFECTS_MASTER, null, FALSE)

	to_chat(antag.current, "<B><font size=6 color=red>Вы все еще командный антагонист. Делай то, что нужно твоей банде!</font></B>")
	to_chat(antag.current, "<B>Поскольку Вы первый гангстер, ваша форма и баллончик с краской находится в инвентаре!</B>")
	to_chat(antag.current, "<B><font size=3 color=red>[faction.name] на всю жизнь!</font></B>")
	to_chat(antag.current, "<B><font size=2 color=red>Помечайте территорию краской, надевай цвета своей банды, и набирай больше гангстеров с помощью Вступительных Наборов!</font></B>")
	to_chat(antag.current, "<B><font size=4 color=red>Будьте осторожны, убийства приведут к более решительным действиям НаноТрейзен.</font></B>")

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
	skillset_type = /datum/skillset/gangster

/datum/role/gangster/leader/OnPostSetup(laterole)
	..()
	equip_gangster_in_inventory()

/datum/role/traitor/dealer
	name = "Gun Dealer"
	id = GANGSTER_DEALER
	required_pref = ROLE_FAMILIES
	change_to_maximum_skills = TRUE
	telecrystals = 10

/datum/role/traitor/dealer/OnPostSetup(laterole)
	var/mob/living/carbon/human/H = antag.current
	notify_ghosts("New gun dealer!", source = H, action = NOTIFY_ORBIT, header = "Gun Dealer")
	H.equipOutfit(/datum/outfit/families_traitor)
	. = ..()

/datum/role/traitor/dealer/forgeObjectives()
	var/list/gangs = find_factions_by_type(/datum/faction/gang)

	var/min_points = INFINITY
	var/datum/faction/gang/weakest_gang
	for(var/GG in gangs)
		var/datum/faction/gang/G = GG
		if(G.help_sent)
			gangs -= G
			continue
		if(G.points < min_points)
			min_points = G.points
			weakest_gang = G
	gangs -= weakest_gang

	if(!length(gangs))
		return

	var/datum/faction/gang/G = pick(gangs)
	G.help_sent = TRUE
	var/datum/objective/gang/help_gang/HG = AppendObjective(/datum/objective/gang/help_gang)
	if(HG)
		HG.explanation_text = "Попытайтесь привести к победе [G.name]"
		HG.my_gang = G

	AppendObjective(/datum/objective/survive)
	return TRUE

/datum/role/traitor/dealer/Greet(greeting,custom)
	if(!..())
		return FALSE

	to_chat(antag.current, "<span class='warning'>Вас экстренно отослал синдикат, чтобы вы успели навести хаос на станции.</span>")
	to_chat(antag.current, "<span class='warning'>У вас есть аплинк с уменьшенным, но более интересным арсеналом. Бандитам это точно понравится.</span>")
	to_chat(antag.current, "<span class='warning'>С помощью ПДА и ИД-карты вы можете связаться с членами банды, не теряя маскировки.</span>")
	to_chat(antag.current, "<span class='warning'>Вам была выдана система фултон, используя её вы сможете отправить любые ценные вещи(мехи, оружие, машинерия) синдикату и получить дополнительные телекристаллы.</span>")
	to_chat(antag.current, "<span class='warning'>Фултон встроен прямо в ваш аплинк, а аплинк встроен в макет рации нанотрейзен.</span>")
	return TRUE
