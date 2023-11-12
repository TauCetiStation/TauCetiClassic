/obj/machinery/computer/fort_command_computer
	name = "Command Computer"
	desc = "Protect it at all cost."

	icon_state = "computer_generic"

	var/team_name

	var/points = 200 //
	var/points_per_second = 0.5 // 1 per tick, 30 per minute

	var/list/turf/spawn_zone = list()
	var/list/datum/fort_command_computer_lot/shoplist = list()
	var/spawn_zone_distance = 4
	var/spawn_zone_radius = 1

	//holomap

/obj/machinery/computer/fort_command_computer/atom_init() // connect to mapmodule / fraction
	. = ..()

	var/turf/step_to = loc
	for(var/i = 1 to spawn_zone_distance) // is there proc for this?
		step_to = get_step(step_to, turn(dir, 180))

	//spawn_zone = RANGE_TURFS(spawn_zone_radius, step_to)
	spawn_zone += step_to

	for(var/lot in subtypesof(/datum/fort_command_computer_lot))
		shoplist += new lot

	sortTim(shoplist, GLOBAL_PROC_REF(cmp_general_order_asc))

/obj/machinery/computer/fort_command_computer/process(seconds_per_tick)
	points += seconds_per_tick * points_per_second

/obj/machinery/computer/fort_command_computer/Destroy() // fail team
	. = ..()

	QDEL_LIST(shoplist)
	spawn_zone.Cut()

/obj/machinery/computer/fort_command_computer/ui_interact(mob/user)
	var/html = "<div class='Section__title'>Purshase list</div>"

	html += "<div class='Section'>Current budget: <b>[points] points</b></div><div class='Section'>"
	for(var/datum/fort_command_computer_lot/lot in shoplist)
		html += "<a href='?src=[REF(src)];purshase=[REF(lot)]' title='[lot.desc]'>[lot.name] ([lot.price] points)</a><br>"
	html += "</div>"

	var/datum/browser/popup = new(user, "fort_command_computer", "Command Computer")
	popup.set_content(html)
	popup.open()

/obj/machinery/computer/fort_command_computer/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["purshase"])
		var/datum/fort_command_computer_lot/lot = locate(href_list["purshase"]) in shoplist
		if(!lot || !istype(lot) || !lot.unlocked)
			return
		if(lot.price > points)
			to_chat(usr, "<span class='warning'>You have no points to buy it!</span>")
			return

		points -= lot.price
		updateDialog()
		var/atom/A = lot.purshase(usr)
		if(istype(A))
			new /obj/effect/falling_effect(pick(spawn_zone), null, A)

/obj/machinery/computer/fort_command_computer/red
	name = "Red Team Command Computer"
	light_color = COLOR_RED

/obj/machinery/computer/fort_command_computer/blue
	name = "Blue Team Command Computer"
	light_color = COLOR_BLUE

/datum/fort_command_computer_lot
	var/name = "name"
	var/desc = "desc"
	var/price = 0
	var/unlocked = TRUE
	var/order = 100

// atom for spawn or null
/datum/fort_command_computer_lot/proc/purshase(mob/user)
	return null

/datum/fort_command_computer_lot/team_announce
	name = "Team Announce"
	desc = "Make big scary announcement for team only"
	price = 50

	order = 1

/datum/fort_command_computer_lot/global_announce
	name = "Global Announce"
	desc = "Dominate other team with words"
	price = 50

	order = 2

/datum/fort_command_computer_lot/metal
	name = "Metal 5x50"
	desc = "5x50 metal lists"
	price = 50

	order = 10

/datum/fort_command_computer_lot/metal/purshase()
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/engi
	for(var/i in 1 to 5)
		var/obj/item/stack/sheet/metal/S = new(C)
		S.set_amount(50)

	return C

/datum/fort_command_computer_lot/glass
	name = "Glass 5x50"
	desc = "5x50 glass lists"
	price = 50

	order = 11

/datum/fort_command_computer_lot/glass/purshase()
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/engi
	for(var/i in 1 to 5)
		var/obj/item/stack/sheet/glass/S = new(C)
		S.set_amount(50)

	return C

/datum/fort_command_computer_lot/rcd_ammo
	name = "Compressed RCD ammunition"
	desc = "10 cartridges of compressed RCD ammunition"
	price = 200

	order = 20

/datum/fort_command_computer_lot/rcd_ammo/purshase()
	var/obj/structure/closet/crate/C = new /obj/structure/closet/crate/scicrate
	for(var/i in 1 to 10)
		new /obj/item/weapon/rcd_ammo/bluespace(C)

	return C

/datum/fort_command_computer_lot/update_map
	name = "Update Holomap"
	desc = "Scan battlefield and update holomap"
	price = 200

	order = 100

/datum/fort_command_computer_lot/update_map/purshase()
	SSholomaps.default_holomap = image(SSholomaps.generate_holo_map()) // todo: own holomap for each team

/datum/fort_command_computer_lot/rename_team
	name = "Rename Team"
	desc = "Name your Red or Blue to something more original"
	price = 200

	order = 800
