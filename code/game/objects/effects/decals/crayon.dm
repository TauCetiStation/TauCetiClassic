/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."
	icon = 'icons/obj/rune.dmi'
	layer = 2.1
	anchored = 1

	New(location,main = "#FFFFFF",shade = "#000000",var/type = "rune", var/e_name = "rune", var/override_color = 0)
		..()
		loc = location

		//name = type
		name = e_name
		desc = "A [type] drawn in crayon."
		if(type == "poseur tag")
			gang_name() //Generate gang names so they get removed from the pool
			type = pick(gang_name_pool)
		icon_state = type

		switch(type)
			if("rune")
				type = "rune[rand(1,6)]"
			if("graffiti")
				type = pick("amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa","poseur tag")

		var/icon/mainOverlay = new/icon('icons/effects/crayondecal.dmi',"[type]",2.1)
		var/icon/shadeOverlay = new/icon('icons/effects/crayondecal.dmi',"[type]s",2.1)

		mainOverlay.Blend(main,ICON_ADD)
		shadeOverlay.Blend(shade,ICON_ADD)

		overlays += mainOverlay
		overlays += shadeOverlay

		if(override_color)
			color = main
		add_hiddenprint(usr)


/obj/effect/decal/cleanable/crayon/gang
	layer = 3.6 //Harder to hide
	var/gang

/obj/effect/decal/cleanable/crayon/gang/New(location, var/type, var/e_name = "gang tag")
	if(!type)
		qdel(src)

	var/area/territory = get_area(location)
	var/color

	if(type == "A")
		gang = type
		color = "#00B7EF"
		icon_state = gang_name("A")
		ticker.mode.A_territory_new |= list(territory.type = territory.name)
		ticker.mode.A_territory_lost -= territory.type
	else if(type == "B")
		gang = type
		color = "#DA0000"
		icon_state = gang_name("B")
		ticker.mode.B_territory_new |= list(territory.type = territory.name)
		ticker.mode.B_territory_lost -= territory.type

	..(location, color, color, icon_state, gang, e_name, 1)

/obj/effect/decal/cleanable/crayon/gang/Destroy()
	var/area/territory = get_area(src)

	if(gang == "A")
		ticker.mode.A_territory_new -= territory.type
		ticker.mode.A_territory_lost |= list(territory.type = territory.name)
	if(gang == "B")
		ticker.mode.B_territory_new -= territory.type
		ticker.mode.B_territory_lost |= list(territory.type = territory.name)

	return ..()
