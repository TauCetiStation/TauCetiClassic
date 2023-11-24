/obj/machinery/computer/fort_console
	name = "Command Computer"
	desc = "Protect it at all cost."

	icon_state = "computer_generic"

	var/team_name

	var/points = 200 //
	var/points_per_second = 0.5 // 1 per tick, 30 per minute

	var/list/turf/spawn_zone = list()
	var/list/datum/fort_console_lot/shoplist = list()

	var/spawn_zone_distance = 4
	var/spawn_zone_radius = 1

	var/list/obj/machinery/mining/drill/forts/drills = list()
	//holomap

/obj/machinery/computer/fort_console/atom_init()
	. = ..()

	if(team_name)
		var/datum/map_module/forts/MM = SSmapping.get_map_module(MAP_MODULE_FORTS)
		MM.consoles[team_name] = src

	var/turf/step_to = loc
	for(var/i = 1 to spawn_zone_distance) // is there proc for this?
		step_to = get_step(step_to, turn(dir, 180))

	//spawn_zone = RANGE_TURFS(spawn_zone_radius, step_to)
	spawn_zone += step_to

	for(var/lot in subtypesof(/datum/fort_console_lot))
		shoplist += new lot

	sortTim(shoplist, GLOBAL_PROC_REF(cmp_general_order_asc))

/obj/machinery/computer/fort_console/process(seconds_per_tick)
	points += seconds_per_tick * points_per_second

/obj/machinery/computer/fort_console/Destroy() // fail team
	. = ..()

	QDEL_LIST(shoplist)
	spawn_zone.Cut()

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

	html += "</div><div class='Section__title'>Purshase list</div><div class='Section'>"
	for(var/datum/fort_console_lot/lot as anything in shoplist)
		html += "<a href='?src=[REF(src)];purshase=[REF(lot)]' title='[lot.desc]'>[lot.name] ([lot.price] points)</a><br>"
	html += "</div>"

	var/datum/browser/popup = new(user, "fort_console", "Command Computer")
	popup.set_content(html)
	popup.open()

/obj/machinery/computer/fort_console/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["purshase"])
		var/datum/fort_console_lot/lot = locate(href_list["purshase"]) in shoplist
		if(!lot || !istype(lot) || !lot.unlocked)
			return
		if(lot.price > points)
			to_chat(usr, "<span class='warning'>You have no points to buy it!</span>")
			return

		points -= lot.price
		updateDialog()
		var/atom/A = lot.purshase(usr, src)
		if(istype(A))
			new /obj/effect/falling_effect(pick(spawn_zone), null, A)

/obj/machinery/computer/fort_console/red
	name = "Red Team Command Computer"
	light_color = COLOR_RED
	team_name = TEAM_NAME_RED

/obj/machinery/computer/fort_console/blue
	name = "Blue Team Command Computer"
	light_color = COLOR_BLUE
	team_name = TEAM_NAME_BLUE

/* shop list */

/datum/fort_console_lot
	var/name = "name"
	var/desc = "desc"
	var/price = 0
	var/unlocked = TRUE
	var/order = 100

// atom for spawn or null
/datum/fort_console_lot/proc/purshase(mob/user, obj/machinery/computer/fort_console/command)
	return null

/datum/fort_console_lot/team_announce
	name = "Team Announce"
	desc = "Make big scary announcement for team only"
	price = 50

	order = 1

/datum/fort_console_lot/global_announce
	name = "Global Announce"
	desc = "Dominate other team with words"
	price = 50

	order = 2

/datum/fort_console_lot/metal
	name = "Metal 5x50"
	desc = "5x50 metal lists"
	price = 50

	order = 10

/datum/fort_console_lot/metal/purshase()
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/engi
	for(var/i in 1 to 5)
		var/obj/item/stack/sheet/metal/S = new(C)
		S.set_amount(50)

	return C

/datum/fort_console_lot/glass
	name = "Glass 5x50"
	desc = "5x50 glass lists"
	price = 50

	order = 11

/datum/fort_console_lot/glass/purshase()
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/engi
	for(var/i in 1 to 5)
		var/obj/item/stack/sheet/glass/S = new(C)
		S.set_amount(50)

	return C

/datum/fort_console_lot/rcd_ammo
	name = "Compressed RCD ammunition"
	desc = "10 cartridges of compressed RCD ammunition"
	price = 200

	order = 20

/datum/fort_console_lot/rcd_ammo/purshase()
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/scicrate
	for(var/i in 1 to 10)
		new /obj/item/weapon/rcd_ammo/bluespace(C)

	return C

/datum/fort_console_lot/drill
	name = "Drill set"
	desc = "Drill and two braces"
	price = 400

	order = 50

/datum/fort_console_lot/drill/purshase(mob/user, obj/machinery/computer/fort_console/command)
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/large
	new /obj/machinery/mining/drill/forts(C, command.team_name)
	new /obj/machinery/mining/brace(C)
	new /obj/machinery/mining/brace(C)

	return C

/datum/fort_console_lot/update_map
	name = "Update Holomap"
	desc = "Scan battlefield and update holomap"
	price = 200

	order = 100

/datum/fort_console_lot/update_map/purshase(mob/user, obj/machinery/computer/fort_console/command)
	SSholomaps.regenerate_custom_holomap(command.team_name)

/datum/fort_console_lot/droppod
	name = "Droppod"
	desc = "Contains caller for droppod. One way ticket for the bravests."
	price = 1000

	order = 999

/datum/fort_console_lot/droppod/purshase(mob/user, obj/machinery/computer/fort_console/command)
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/secure/weapon
	var/obj/item/device/drop_caller/dropcaller = new(C)
	switch(command.team_name)
		if(TEAM_NAME_RED)
			dropcaller.drop_type = /obj/structure/droppod/fort/red_team
		if(TEAM_NAME_BLUE)
			dropcaller.drop_type = /obj/structure/droppod/fort/blue_team

	return C

/*/datum/fort_console_lot/rename_team
	name = "Rename Team"
	desc = "Name your Red or Blue to something more original"
	price = 200

	order = 800*/
