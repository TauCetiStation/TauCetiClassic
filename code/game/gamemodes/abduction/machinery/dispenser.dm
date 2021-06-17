//*************-Gland dispenser-*************//

/obj/machinery/abductor/gland_dispenser
	name = "Replacement Organ Storage"
	desc = "A tank filled with replacement organs."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "dispenser"
	density = TRUE
	anchored = TRUE
	var/list/gland_types
	var/list/gland_colors
	var/list/amounts

/obj/machinery/abductor/gland_dispenser/proc/random_color()
	//TODO : replace with presets or spectrum
	return rgb(rand(0,255),rand(0,255),rand(0,255))

/obj/machinery/abductor/gland_dispenser/atom_init()
	. = ..()
	gland_types = typesof(/obj/item/gland) - /obj/item/gland
	gland_types = shuffle(gland_types)
	gland_colors = new/list(gland_types.len)
	amounts = new/list(gland_types.len)
	for (var/i in 1 to gland_types.len)
		gland_colors[i] = random_color()
		amounts[i] = rand(1,5)

/obj/machinery/abductor/gland_dispenser/interact(mob/user)
	if(!IsAbductor(user) && !isobserver(user))
		return
	else
		..()

/obj/machinery/abductor/gland_dispenser/ui_interact(mob/user)
	var/dat
	dat += "<center>"
	for(var/i in 1 to gland_colors.len)
		dat += "<a style='background-color:[gland_colors[i]]' href='?src=\ref[src];dispense=[i]'>[amounts[i]]</a>"
		if(i % 3 == 0)
			dat += "<br><br>"
	dat += "</center>"

	var/datum/browser/popup = new(user, "glands", "Gland Dispenser", 200, 200, ntheme = CSS_THEME_ABDUCTOR)
	popup.set_content(dat)
	popup.open()

/obj/machinery/abductor/gland_dispenser/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/gland))
		user.drop_from_inventory(W, src)
		for(var/i=1,i<=gland_colors.len,i++)
			if(gland_types[i] == W.type)
				amounts[i]++
		return
	return ..()

/obj/machinery/abductor/gland_dispenser/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if(href_list["dispense"])
		Dispense(text2num(href_list["dispense"]))
	updateUsrDialog()

/obj/machinery/abductor/gland_dispenser/proc/Dispense(count)
	if(amounts[count]>0)
		amounts[count]--
		var/T = gland_types[count]
		new T(get_turf(src))
