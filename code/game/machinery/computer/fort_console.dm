/obj/machinery/computer/fort_console
	name = "Command Computer"
	desc = "Protect it at all cost."

	icon_state = "computer_generic"

	req_access = list(access_captain)

	var/team_id

	var/points = 300
	var/points_per_second = 0.5 // 1 per tick, 30 per minute

	var/turf/spawn_zone = list()
	var/list/datum/fort_console_lot/shoplist = list()

	var/spawn_zone_distance = 4
	var/spawn_zone_radius = 1

	var/list/obj/machinery/mining/drill/forts/drills = list()
	//holomap

/obj/machinery/computer/fort_console/atom_init()
	. = ..()

	if(team_id)
		var/datum/map_module/forts/MM = SSmapping.get_map_module(MAP_MODULE_FORTS)
		MM.consoles[team_id] = src

	var/turf/step_to = loc
	for(var/i = 1 to spawn_zone_distance) // is there proc for this?
		step_to = get_step(step_to, turn(dir, 180))

	//spawn_zone = RANGE_TURFS(spawn_zone_radius, step_to)
	spawn_zone = step_to

	for(var/lot in subtypesof(/datum/fort_console_lot))
		shoplist += new lot

	sortTim(shoplist, GLOBAL_PROC_REF(cmp_general_order_asc))

/obj/machinery/computer/fort_console/process(seconds_per_tick)
	points += seconds_per_tick * points_per_second * forts_points_multiplier

/obj/machinery/computer/fort_console/Destroy()
	. = ..()

	var/datum/map_module/forts/MM = SSmapping.get_map_module(MAP_MODULE_FORTS)
	MM.announce("Консоль [team_id] была уничтожена!")

	QDEL_LIST(shoplist)
	spawn_zone = null

/obj/machinery/computer/fort_console/ui_interact(mob/user)
	var/html = "<div class='Section__title'>Status</div><div class='Section'>"

	html += "Current budget: <b>[points] points</b><br>"
	html += "Drills:<br>"
	if(length(drills))
		for(var/obj/machinery/mining/drill/forts/drill as anything in drills)
			var/turf/T = get_turf(drill)
			html += "[TAB]Drill at [T.x].[T.y]:"
			html += " [drill.active ? "<span class='green'>Active</span>" : "<span class='orange'>Inactive</span>"]"
			html += "[drill.need_player_check ? " | <span class='red'>Diagnostic required!</span>": ""]<br>"
	else
		html += "[TAB]No drills registred"

	html += "</div><div class='Section__title'>Purchase list</div><div class='Section'>"
	for(var/datum/fort_console_lot/lot as anything in shoplist)
		html += "<a href='?src=[REF(src)];purchase=[REF(lot)]' [lot.unlocked ? "" : "class='disabled'"] title='[lot.desc]'>[lot.name] ([lot.price] points)</a><br>"
	html += "</div>"

	var/datum/browser/popup = new(user, "fort_console", "Command Computer", 400, 700)
	popup.set_content(html)
	popup.open()

/obj/machinery/computer/fort_console/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["purchase"])
		var/datum/fort_console_lot/lot = locate(href_list["purchase"]) in shoplist
		if(!lot || !istype(lot) || !lot.unlocked)
			return
		if(lot.price > points)
			to_chat(usr, "<span class='warning'>You have no points to buy it!</span>")
			return
		if(is_blocked_turf(spawn_zone) || (locate(/obj/effect/falling_effect) in spawn_zone))
			to_chat(usr, "<span class='warning'>Clear the landing point!</span>")
			return

		points -= lot.price
		updateDialog()
		var/atom/A = lot.purchase(usr, src)
		if(istype(A))
			new /obj/effect/falling_effect(spawn_zone, null, A)

/obj/machinery/computer/fort_console/red
	name = "Red Team Command Computer"
	light_color = COLOR_RED
	team_id = TEAM_NAME_RED
	dir = 8

/obj/machinery/computer/fort_console/blue
	name = "Blue Team Command Computer"
	light_color = COLOR_BLUE
	team_id = TEAM_NAME_BLUE
	dir = 4

/* shop list */

/datum/fort_console_lot
	var/name = "name"
	var/desc = "desc"
	var/price = 0
	var/unlocked = TRUE
	var/order = 100

// atom for spawn or null
/datum/fort_console_lot/proc/purchase(mob/user, obj/machinery/computer/fort_console/command)
	return null

// 1-10
/datum/fort_console_lot/specialization
	name = "Grant new rank"
	desc = "Change rank for teammate"
	price = 1

	order = 1

/datum/fort_console_lot/specialization/purchase(mob/user, obj/machinery/computer/fort_console/command)
	var/datum/map_module/forts/MM = SSmapping.get_map_module(MAP_MODULE_FORTS)
	var/datum/faction/F = MM.factions[command.team_id]

	if(!length(F.members))
		to_chat(user, "<span class='warning'>Faction is empty!</span>")
		return

	var/list/candidates = list()

	for(var/datum/role/R in F.members)
		var/mob/M = R.antag?.current
		if(!M || !M.client)
			continue
		candidates["[M.real_name] ([R.name])"] = M

	var/member = tgui_input_list(user, "Choise member to change a rank:", "Assign Rank", candidates)

	if(!member)
		return

	var/rank = tgui_input_list(user, "Choise rank for [member]:", "Assign Rank", FORTS_ROLES)

	message_admins("[key_name(user)] assigned [candidates[member]] as [rank] of [F.name].")

	MM.assign_to_team(candidates[member], faction = F, rank = rank)

/datum/fort_console_lot/team_announce
	name = "Team Announce"
	desc = "Make big scary announcement for your team"
	price = 5

	order = 2

/datum/fort_console_lot/team_announce/purchase(mob/user, obj/machinery/computer/fort_console/command)
	var/message = sanitize(input(user, "Please enter text for your announcement.", "Announce") as text, MAX_MESSAGE_LEN, extra = FALSE)
	var/datum/map_module/forts/MM = SSmapping.get_map_module(MAP_MODULE_FORTS)
	MM.announce(message, user, from_team = command.team_id, team_only = TRUE)

/datum/fort_console_lot/global_announce
	name = "Global Announce"
	desc = "Dominate other team with words"
	price = 25

	order = 3

/datum/fort_console_lot/global_announce/purchase(mob/user, obj/machinery/computer/fort_console/command)
	var/message = sanitize(input(user, "Please enter text for your announcement.", "Announce") as text, MAX_MESSAGE_LEN, extra = FALSE)
	var/datum/map_module/forts/MM = SSmapping.get_map_module(MAP_MODULE_FORTS)
	MM.announce(message, user, from_team = command.team_id)

/datum/fort_console_lot/update_map
	name = "Update Holomap"
	desc = "Scan battlefield and update holomap"
	price = 50

	order = 4

/datum/fort_console_lot/update_map/purchase(mob/user, obj/machinery/computer/fort_console/command)
	SSholomaps.regenerate_custom_holomap(command.team_id)

// 10-20
/datum/fort_console_lot/metal
	name = "Metal 5x50"
	desc = "5x50 metal lists"
	price = 50

	order = 11

/datum/fort_console_lot/metal/purchase()
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/engi
	for(var/i in 1 to 5)
		var/obj/item/stack/sheet/metal/S = new(C)
		S.set_amount(50)

	return C

/datum/fort_console_lot/glass
	name = "Glass 5x50"
	desc = "5x50 glass lists"
	price = 50

	order = 12

/datum/fort_console_lot/glass/purchase()
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/engi
	for(var/i in 1 to 5)
		var/obj/item/stack/sheet/glass/S = new(C)
		S.set_amount(50)

	return C

/datum/fort_console_lot/wood
	name = "Wood 5x50"
	desc = "5x50 wood lists"
	price = 50

	order = 13

/datum/fort_console_lot/wood/purchase()
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/engi
	for(var/i in 1 to 5)
		var/obj/item/stack/sheet/wood/S = new(C)
		S.set_amount(50)

	return C

// 20-30
/datum/fort_console_lot/rcd_ammo
	name = "RCD ammunition 1x10"
	desc = "10 cartridges of compressed RCD ammunition"
	price = 200

	order = 21

/datum/fort_console_lot/rcd_ammo/purchase()
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/scicrate
	for(var/i in 1 to 10)
		new /obj/item/weapon/rcd_ammo/bluespace(C)

	return C

//30-40
/datum/fort_console_lot/rocket_cheap
	name = "Cheap Rockets 1x9"
	desc = "Crate containing 9 less effective explosive rockets"
	price = 50

	order = 31

/datum/fort_console_lot/rocket_cheap/purchase()
	. = new /obj/structure/storage_box/rocket/cheap

/datum/fort_console_lot/rocket_explosive
	name = "Standart Rockets 1x9"
	desc = "Crate containing 9 standart explosive rockets"
	price = 100

	order = 32

/datum/fort_console_lot/rocket_explosive/purchase()
	. = new /obj/structure/storage_box/rocket/explosive

/datum/fort_console_lot/rocket_emp
	name = "EMP Rockets 1x9"
	desc = "Crate containing 9 standart EMP rockets"
	price = 100

	order = 33

/datum/fort_console_lot/rocket_emp/purchase()
	. = new /obj/structure/storage_box/rocket/emp

/datum/fort_console_lot/rocket_piercing
	name = "Armor-Piercing Rockets 1x9"
	desc = "Crate containing 9 armor-Piercing explosive rockets"
	price = 200

	order = 34

/datum/fort_console_lot/rocket_piercing/purchase()
	. = new /obj/structure/storage_box/rocket/piercing

// 50-60
/datum/fort_console_lot/drill
	name = "Drill set"
	desc = "Drill and two braces"
	price = 100

	order = 50

/datum/fort_console_lot/drill/purchase(mob/user, obj/machinery/computer/fort_console/command)
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/large
	new /obj/machinery/mining/drill/forts(C, command.team_id)
	new /obj/machinery/mining/brace(C)
	new /obj/machinery/mining/brace(C)

	return C

/datum/fort_console_lot/medical
	name = "Medical Supply"
	desc = "Set of colored first aids"
	price = 25

	order = 52

/datum/fort_console_lot/medical/purchase(mob/user, obj/machinery/computer/fort_console/command)
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/medical

	for(var/i in 1 to 4)
		new /obj/item/weapon/storage/firstaid/small_firstaid_kit/space(C)

	new /obj/item/weapon/storage/firstaid/regular(C)
	new /obj/item/weapon/storage/firstaid/fire(C)
	new /obj/item/weapon/storage/firstaid/toxin(C)
	new /obj/item/weapon/storage/firstaid/o2(C)
	new /obj/item/weapon/storage/firstaid/adv(C)

	return C

/datum/fort_console_lot/supermedical
	name = "Heal Injector 1x2"
	desc = "Can revive dead. Five times."
	price = 75

	order = 53

/datum/fort_console_lot/supermedical/purchase(mob/user, obj/machinery/computer/fort_console/command)
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/medical

	for(var/i in 1 to 2)
		new /obj/item/weapon/lazarus_injector/revive(C)

	return C

/datum/fort_console_lot/food
	name = "Food Supply"
	desc = "Food Supply"
	price = 20

	order = 54

/datum/fort_console_lot/food/purchase(mob/user, obj/machinery/computer/fort_console/command)
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/freezer

	for(var/i in 1 to 4)
		new /obj/item/weapon/storage/firstaid/small_firstaid_kit/nutriment(C)

	return C

/datum/fort_console_lot/fueltank
	name = "Fueltank"
	desc = "Fueltank"
	price = 30

	order = 55

/datum/fort_console_lot/fueltank/purchase(mob/user, obj/machinery/computer/fort_console/command)
	. = new /obj/structure/reagent_dispensers/fueltank

// 60-70
/datum/fort_console_lot/gps
	name = "GPS 1x10"
	desc = "GPS devices"
	price = 50

	order = 56

/datum/fort_console_lot/gps/purchase(mob/user, obj/machinery/computer/fort_console/command)
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/scicrate

	var/gps_type
	switch(command.team_id)
		if(TEAM_NAME_RED)
			gps_type = /obj/item/device/gps/team_red
		if(TEAM_NAME_BLUE)
			gps_type = /obj/item/device/gps/team_blue

	for(var/i in 1 to 10)
		new gps_type(C)

	return C

/datum/fort_console_lot/energylaser
	name = "Laser Rifle 1x5"
	desc = "Why do you need it if you have a rocket?"
	price = 100

	order = 62

/datum/fort_console_lot/energylaser/purchase(mob/user, obj/machinery/computer/fort_console/command)
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/secure/weapon

	for(var/i in 1 to 5)
		new /obj/item/weapon/gun/energy/laser(C)

	return C

/datum/fort_console_lot/c4
	name = "C4 1x10"
	desc = "Why do you need it if you have a rocket?"
	price = 100

	order = 63

/datum/fort_console_lot/c4/purchase(mob/user, obj/machinery/computer/fort_console/command)
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/secure/weapon

	for(var/i in 1 to 10)
		new /obj/item/weapon/plastique(C)

	return C

/datum/fort_console_lot/droppod
	name = "Droppod"
	desc = "Contains a caller for the droppod. One way ticket for the bravests."
	price = 800

	order = 999

/datum/fort_console_lot/droppod/purchase(mob/user, obj/machinery/computer/fort_console/command)
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/secure/weapon
	var/obj/item/device/drop_caller/dropcaller = new(C)
	switch(command.team_id)
		if(TEAM_NAME_RED)
			dropcaller.drop_type = /obj/structure/droppod/fort/red_team
		if(TEAM_NAME_BLUE)
			dropcaller.drop_type = /obj/structure/droppod/fort/blue_team

	return C

/*
// for this need to check all name references
/datum/fort_console_lot/rename_team
	name = "Rename Team"
	desc = "Name your Red or Blue to something more original"
	price = 200

	order = 800
*/

