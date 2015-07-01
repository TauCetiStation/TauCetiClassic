/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."
	icon = 'icons/obj/rune.dmi'
	layer = 2.1
	anchored = 1

	examine()
		set src in view(2)
		..()
		return


	New(location,main = "#FFFFFF",shade = "#000000",var/type = "rune", var/e_name = "rune", var/override_color = 0)
		..()
		loc = location

		//name = type
		name = e_name
		desc = "A [type] drawn in crayon."
		icon_state = type

		switch(type)
			if("rune")
				type = "rune[rand(1,6)]"
			if("graffiti")
				type = pick("amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa")

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
	var/list/recipients = list()
	var/color

	if(type == "A")
		gang = type
		color = "#00b4ff"
		icon_state = gang_name("A")
		recipients = ticker.mode.A_tools
		ticker.mode.A_territory |= territory.type
	else if(type == "B")
		gang = type
		color = "#ff3232"
		icon_state = gang_name("B")
		recipients = ticker.mode.B_tools
		ticker.mode.B_territory |= territory.type

	if(recipients.len)
		ticker.mode.message_gangtools(recipients,"New territory claimed: [territory]",0)

	..(location, color, color, icon_state, gang, e_name, 1)

/obj/effect/decal/cleanable/crayon/gang/Destroy()
	var/area/territory = get_area(src)
	var/list/recipients = list()

	if(gang == "A")
		recipients += ticker.mode.A_tools
		ticker.mode.A_territory -= territory.type
	if(gang == "B")
		recipients += ticker.mode.B_tools
		ticker.mode.B_territory -= territory.type
	if(recipients.len)
		ticker.mode.message_gangtools(recipients,"Territory lost: [territory]",0)

	..() 
