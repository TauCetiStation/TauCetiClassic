#define MASS_FILL			0
#define MASS_DELETE			1
#define SELECTIVE_DELETE	2
#define SELECTIVE_FILL		3
/proc/togglebuildmode(mob/M as mob in player_list)
	set name = "Toggle Build Mode"
	set category = "Special Verbs"

	if(M.client)
		if(M.client.buildmode)
			log_admin("[key_name(usr)] has left build mode.")
			M.client.buildmode = 0
			M.client.show_popup_menus = 1
			for(var/obj/effect/bmode/buildholder/H in buildmodeholders)
				if(H.cl == M.client)
					qdel(H)
		else
			log_admin("[key_name(usr)] has entered build mode.")
			M.client.buildmode = 1
			M.client.show_popup_menus = 0

			var/obj/effect/bmode/buildholder/H = new/obj/effect/bmode/buildholder()
			var/obj/effect/bmode/builddir/A = new/obj/effect/bmode/builddir(H)
			A.master = H
			var/obj/effect/bmode/buildhelp/B = new/obj/effect/bmode/buildhelp(H)
			B.master = H
			var/obj/effect/bmode/buildmode/C = new/obj/effect/bmode/buildmode(H)
			C.master = H
			var/obj/effect/bmode/buildquit/D = new/obj/effect/bmode/buildquit(H)
			D.master = H

			H.builddir = A
			H.buildhelp = B
			H.buildmode = C
			H.buildquit = D
			M.client.screen += A
			M.client.screen += B
			M.client.screen += C
			M.client.screen += D
			H.cl = M.client

/obj/effect/bmode//Cleaning up the tree a bit
	density = 1
	anchored = 1
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE
	dir = NORTH
	icon = 'icons/misc/buildmode.dmi'
	var/obj/effect/bmode/buildholder/master = null

/obj/effect/bmode/New()
	..()
	master = loc

/obj/effect/bmode/Destroy()
	if(master && master.cl)
		master.cl.screen -= src
	master = null
	return ..()

/obj/effect/bmode/builddir
	icon_state = "build"
	screen_loc = "NORTH,WEST"
/obj/effect/bmode/builddir/Click()
	switch(dir)
		if(NORTH)
			dir = EAST
		if(EAST)
			dir = SOUTH
		if(SOUTH)
			dir = WEST
		if(WEST)
			dir = NORTHWEST
		if(NORTHWEST)
			dir = NORTH
	return 1
/obj/effect/bmode/builddir/DblClick(object,location,control,params)
	return Click(object,location,control,params)

/obj/effect/bmode/buildhelp
	icon = 'icons/misc/buildmode.dmi'
	icon_state = "buildhelp"
	screen_loc = "NORTH,WEST+1"

/obj/effect/bmode/buildhelp/Click()
	var/help_message = "Wrong buildmode mode."
	switch(master.cl.buildmode)
		if(1) // Basic Build
			help_message = {"<span class='notice'>
			*****Basic Build*******************************************
			Click and drag to do a fill operation
			Left Mouse Button        = Construct / Upgrade
			Right Mouse Button       = Deconstruct / Delete / Downgrade
			Left Mouse Button + ctrl = R-Window
			Left Mouse Button + alt  = Airlock

			Use the button in the upper left corner to
			change the direction of built objects.
			***********************************************************
			</span>"}
		if(2) // Adv. Build
			help_message = {"<span class='notice'>
			*****Adv. Build********************************************
			Click and drag to do a fill operation
			Right Mouse Button on buildmode button = Set object type
			Left Mouse Button on turf/obj          = Place objects
			Middle Mouse Button                    = Copy atom
			Middle Mouse Button+Ctrl               = Copy atom appearance

			Ctrl+Shift+Left Mouse Button           = Sets bottom left corner for fill mode
			Ctrl+Shift+Right Mouse Button          = Sets top right corner for fill mode

			Use the button in the upper left corner to
			change the direction of built objects.
			***********************************************************
			</span>"}
		if(3) // Edit
			help_message = {"<span class='notice'>
			*****Edit**************************************************
			Click and drag to do a mass edit operation
			Right Mouse Button on buildmode button = Select var(type) & value
			Left Mouse Button on turf/obj/mob      = Set var(type) & value
			Right Mouse Button on turf/obj/mob     = Reset var's value
			***********************************************************
			</span>"}
		if(4) // Throw
			help_message = {"<span class='notice'>
			*****Throw*************************************************
			Left Mouse Button on turf/obj/mob      = Select
			Right Mouse Button on turf/obj/mob     = Throw
			***********************************************************
			</span>"}
		if(5) // Room Build
			help_message = {"<span class='notice'>
			*****Room Build********************************************
			Build room betven A and B.
			Left Mouse Button on turf              = Select as point A
			Right Mouse Button on turf             = Select as point B
			Right Mouse Button on buildmode button = Change floor/wall type
			***********************************************************
			</span>"}
		if(6) // Make Ladders
			help_message = {"<span class='notice'>
			*****Make Ladders******************************************
			Left Mouse Button on turf              = Set as upper ladder loc
			Right Mouse Button on turf             = Set as lower ladder loc
			***********************************************************
			</span>"}
		if(7) // Move Into Contents
			help_message = {"<span class='notice'>
			*****Move Into Contents************************************
			Left Mouse Button on turf/obj/mob      = Select
			Right Mouse Button on turf/obj/mob     = Move into selection
			***********************************************************
			</span>"}
		if(8) // Make Lights
			help_message = {"<span class='notice'>
			*****Make Lights*******************************************
			Left Mouse Button on turf/obj/mob      = Make it glow
			Right Mouse Button on turf/obj/mob     = Reset glowing
			Right Mouse Button on buildmode button = Change glow properties
			***********************************************************
			</span>"}
		if(9) // Make Air
			help_message = {"<span class='notice'>
			*****Make Air**********************************************
			Left Mouse Button on turf/obj/mob      = Set air in area
			Right Mouse Button on turf/obj/mob     = Remove air in area
			Right Mouse Button on buildmode button = Set Air properties
			Gasses set in %
			***********************************************************
			</span>"}
	to_chat(usr, help_message)
	return 1

/obj/effect/bmode/buildhelp/DblClick(object,location,control,params)
	return Click(object,location,control,params)

/obj/effect/bmode/buildquit
	icon_state = "buildquit"
	screen_loc = "NORTH,WEST+3"

/obj/effect/bmode/buildquit/Click()
	togglebuildmode(master.cl.mob)
	return 1
/obj/effect/bmode/buildquit/DblClick(object,location,control,params)
	return Click(object,location,control,params)

var/global/list/obj/effect/bmode/buildholder/buildmodeholders = list()
/obj/effect/bmode/buildholder
	density = 0
	anchored = 1
	var/client/cl = null
	var/obj/effect/bmode/builddir/builddir = null
	var/obj/effect/bmode/buildhelp/buildhelp = null
	var/obj/effect/bmode/buildmode/buildmode = null
	var/obj/effect/bmode/buildquit/buildquit = null
	var/atom/movable/throw_atom = null
	var/turf/fill_left
	var/turf/fill_right

obj/effect/bmode/buildholder/New()
	..()
	buildmodeholders |= src

/obj/effect/bmode/buildholder/Destroy()
	cl.screen -= list(builddir,buildhelp,buildmode,buildquit)
	buildmodeholders -= src
	return ..()

/obj/effect/bmode/buildmode
	icon_state = "buildmode1"
	screen_loc = "NORTH,WEST+2"
	var/varholder = "name"
	var/valueholder = "derp"
	var/objholder = /obj/structure/closet
	var/atom/copycat

	var/wall_holder = /turf/simulated/wall
	var/floor_holder = /turf/simulated/floor/plating
	var/turf/coordA = null
	var/turf/coordB = null

	var/new_light_color = "#FFFFFF"
	var/new_light_range = 3
	var/new_light_power = 3

	var/new_mix_O2 = 20
	var/new_mix_Co = 0
	var/new_mix_Pl = 0
	var/new_mix_N = 80
	var/new_pressure = 101
	var/new_temperature = T20C

/obj/effect/bmode/buildmode/Destroy()
	qdel(copycat)
	copycat = null
	return ..()

/obj/effect/bmode/buildmode/Click(location, control, params)
	var/list/pa = params2list(params)

	if(pa.Find("left"))
		switch(master.cl.buildmode)
			if(1)
				master.cl.buildmode = 2
				src.icon_state = "buildmode2"
			if(2)
				master.cl.buildmode = 3
				src.icon_state = "buildmode3"
			if(3)
				master.cl.buildmode = 4
				src.icon_state = "buildmode4"
			if(4)
				master.cl.buildmode = 5
				src.icon_state = "buildmode5"
			if(5)
				master.cl.buildmode = 6
				src.icon_state = "buildmode6"
			if(6)
				master.cl.buildmode = 7
				src.icon_state = "buildmode7"
			if(7)
				master.cl.buildmode = 8
				src.icon_state = "buildmode8"
			if(8)
				master.cl.buildmode = 9
				src.icon_state = "buildmode9"
			if(9)
				master.cl.buildmode = 1
				src.icon_state = "buildmode1"

	else if(pa.Find("middle"))
		var/list/modes = list("Basic Build" = 1, "Adv. Build" = 2, "Edit" = 3, "Throw" = 4, "Room Build" = 5, "Make Ladders" = 6, "Move Into Contents" = 7, "Make Lights" = 8, "Air" = 9, "Cancel")
		var/mod = input(usr,"Select mode:" ,"Mode") in modes
		if(mod == "Cancel")
			return
		var/mode = modes[mod]
		master.cl.buildmode = mode
		src.icon_state = "buildmode[mode]"

	else if(pa.Find("right"))
		switch(master.cl.buildmode)
			if(1)
				return 1
			if(2)
				copycat = null
				objholder = get_path_from_partial_text()
				if(!ispath(objholder))
					objholder = /obj/structure/closet
				else
					if(ispath(objholder, /mob) && !check_rights(R_DEBUG,0))
						objholder = /obj/structure/closet
						alert("That path is not allowed for you.")
			if(3)
				var/list/locked = list("vars", "key", "ckey", "client")

				master.buildmode.varholder = input(usr,"Enter variable name:" ,"Name", "name")
				if(master.buildmode.varholder in locked && !check_rights(R_DEBUG,0))
					return 1
				var/thetype = input(usr,"Select variable type:" ,"Type") in list("text","number","mob-reference","obj-reference","turf-reference")
				if(!thetype)
					return 1
				switch(thetype)
					if("text")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value", "value") as text
					if("number")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value", 123) as num
					if("mob-reference")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value") as mob in mob_list
					if("obj-reference")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value") as obj in world
					if("turf-reference")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value") as turf in world
			if(5) // Room build
				var/choice = alert("Would you like to change the floor or wall holders?","Room Builder", "Floor", "Wall")
				switch(choice)
					if("Floor")
						floor_holder = get_path_from_partial_text(/turf/simulated/floor/plating)
					if("Wall")
						wall_holder = get_path_from_partial_text(/turf/simulated/wall)
			if(8) // Lights
				var/choice = alert("Change the new light range, power, or color?", "Light Maker", "Range", "Power", "Color")
				switch(choice)
					if("Range")
						var/input = input("New light range.","Light Maker",3) as null|num
						if(input)
							new_light_range = input
					if("Power")
						var/input = input("New light power.","Light Maker",3) as null|num
						if(input)
							new_light_power = input
					if("Color")
						var/input = input("New light color.","Light Maker",3) as null|color
						if(input)
							new_light_color = input
			if(9) // Air
				var/choice = alert("Change the air mix, pressure, or temperature?", "Air Maker", "Mix", "Pressure", "Temperature")
				switch(choice)
					if("Mix")
						var/Nitrogen = 100
						var/inputO2 = min(input("New oxygen %. Max [Nitrogen]%","Air Maker",20) as null|num, Nitrogen)
						Nitrogen = max(Nitrogen - inputO2, 0)
						var/inputCo = min(input("New co2 %. Max [Nitrogen]%","Air Maker",0) as null|num, Nitrogen)
						Nitrogen = max(Nitrogen - inputCo, 0)
						var/inputPl = min(input("New Phoron %. Max [Nitrogen]%","Air Maker",0) as null|num, Nitrogen)
						Nitrogen = max(Nitrogen - inputPl, 0)
						new_mix_O2 = inputO2
						new_mix_Co = inputCo
						new_mix_Pl = inputPl
						new_mix_N = Nitrogen
					if("Pressure")
						var/input = input("New pressure.","Air Maker",101) as null|num
						if(input)
							new_pressure = input
					if("Temperature")
						var/input = input("New temperature in kelvin. 0C = [T0C]K.","Air Maker",T20C) as null|num
						if(input)
							new_temperature = input
	return 1

/obj/effect/bmode/buildmode/DblClick(object,location,control,params)
	return Click(object,location,control,params)

/client/MouseDrop(src_object,over_object,src_location,over_location,src_control,over_control,params)
	if(!src.buildmode)
		return ..()
	var/obj/effect/bmode/buildholder/holder = null
	for(var/obj/effect/bmode/buildholder/H in buildmodeholders)
		if(H.cl == src)
			holder = H
			break
	if(!holder)
		return
	var/turf/start = get_turf(src_location)
	var/turf/end = get_turf(over_location)
	if(!start || !end)
		return
	if(start == end)
		return //end.build_click()
	switch(buildmode)
		if(1 to 2)
			var/list/fillturfs = block(start,end)
			if(fillturfs.len)
				if(alert("You're about to do a fill operation spanning [fillturfs.len] tiles, are you sure?","Panic","Yes","No") == "Yes")
					if(fillturfs.len > 150)
						if(alert("Are you completely sure about filling [fillturfs.len] tiles?","Panic!!!!","Yes","No") != "Yes")
							return
					var/areaAction = alert("FILL tiles or DELETE them? areaAction will destroy EVERYTHING IN THE SELECTED AREA", "Create or destroy, your chance to be a GOD","FILL","DELETE") == "DELETE"
					if(areaAction)
						areaAction = (alert("Selective(TYPE) Delete or MASS Delete?", "Scorched Earth or selective destruction?", "Selective", "MASS") == "Selective" ? 2 : 1)
					else
						areaAction = (alert("Mass FILL or Selective(Type => Type) FILL?", "Do they really need [fillturfs.len] of closets?", "Selective", "Mass") == "Selective" ? 3 : 0)

					var/whatfill
					var/msglog = "<span class='danger'>[key_name_admin(usr)] just buildmode"
					var/strict = 1
					var/chosen
					switch(areaAction)
						if(MASS_DELETE)
							msglog += " <big>DELETED EVERYTHING</big> in [fillturfs.len] tile\s "
						if(SELECTIVE_DELETE)
							chosen = get_path_from_partial_text()
							if(!chosen)
								return
							strict = alert("Delete all children of [chosen]?", "Children being all types and subtypes of [chosen]", "Yes", "No") == "No"
							msglog += " <big>DELETED [!strict ? "ALL TYPES OF " :""][chosen]</big> in [fillturfs.len] tile\s "
						if(SELECTIVE_FILL)
							whatfill = (buildmode == 1 ? input("What are we filling with?", "So many choices") as null|anything in list(/turf/simulated/floor,/turf/simulated/wall,/turf/simulated/wall/r_wall,/obj/machinery/door/airlock, /obj/structure/window/reinforced) : holder.buildmode.objholder)
							if(!whatfill)
								return
							chosen = get_path_from_partial_text()
							if(!chosen)
								return
							strict = alert("Change all children of [chosen]?", "Children being all types and subtypes of [chosen]", "Yes", "No") == "No"
							msglog += " Changed all [chosen] in [fillturfs.len] tile\s to [whatfill] "
						else
							whatfill = (buildmode == 1 ? input("What are we filling with?", "So many choices") as null|anything in list(/turf/simulated/floor,/turf/simulated/wall,/turf/simulated/wall/r_wall,/obj/machinery/door/airlock, /obj/structure/window/reinforced) : holder.buildmode.objholder)
							if(!whatfill)
								return
							msglog += " FILLED [fillturfs.len] tile\s with [whatfill] "
					msglog += "at ([ADMIN_JMP(start)] to [ADMIN_JMP(end)])</span>"
					message_admins(msglog)
					log_admin(msglog)
					to_chat(usr, "<span class='notice'>If the server is lagging the operation will periodically sleep so the fill may take longer than typical.</span>")
					var/turf_op = ispath(whatfill, /turf)
					var/deletions = 0
					for(var/turf/T in fillturfs)
						if(areaAction == MASS_DELETE || areaAction == SELECTIVE_DELETE)
							if(ispath(chosen, /turf))
								if(strict)
									if(T.type != chosen)
										continue
								else
									if(!istype(T, chosen))
										continue
								T.ChangeTurf(/turf/space)
								deletions++
							else
								for(var/atom/thing in T.contents)
									if(thing==usr)
										continue
									if(areaAction == MASS_DELETE || (strict && thing.type == chosen) || istype(thing,chosen))
										qdel(thing)
									deletions++
									CHECK_TICK
								if(areaAction == MASS_DELETE)
									T.ChangeTurf(/turf/space)//get_base_turf(T.z))
						else
							if(turf_op)
								if(areaAction == SELECTIVE_FILL)
									if(strict)
										if(T.type != chosen)
											continue
									else
										if(!istype(T, chosen))
											continue
								T.ChangeTurf(whatfill)
							else
								if(areaAction == SELECTIVE_FILL)
									for(var/atom/thing in T.contents)
										if(strict)
											if(thing.type != chosen)
												continue
										else
											if(!istype(thing, chosen))
												continue
										var/atom/A = new whatfill(T)
										A.dir = thing.dir
										qdel(thing)
										CHECK_TICK
								else
									var/obj/A = new whatfill(T)
									if(istype(A))
										A.dir = holder.builddir.dir
						CHECK_TICK
					if(deletions)
						to_chat(usr, "<span class='info'>Successfully deleted [deletions] [chosen]'\s</span>")
		if(3)
			var/list/fillturfs = block(start,end)
			if(fillturfs.len)
				if(alert("You're about to do a mass edit operation spanning [fillturfs.len] tiles, are you sure?","Panic","Yes","No") == "Yes")
					if(fillturfs.len > 150)
						if(alert("Are you completely sure about mass editng [fillturfs.len] tiles?","Panic!!!!","Yes","No") != "Yes")
							return

					var/areaAction = (alert("Selective(TYPE) Edit or MASS Edit?", "Editing things one by one sure is annoying", "Selective", "MASS") == "Selective" ? 2 : 1)
					var/reset = alert("Reset target variable to initial value?", "Aw shit cletus i dun fucked up", "Yes", "No") == "Yes" ? 1 : 0


					var/msglog = "<span class='danger'>[key_name_admin(usr)] just buildmode"
					var/strict = 1
					var/chosen
					switch(areaAction)
						if(MASS_DELETE)
							msglog += " <big>EDITED EVERYTHING</big> in [fillturfs.len] tile\s "
						if(SELECTIVE_DELETE)
							chosen = get_path_from_partial_text()
							if(!chosen)
								return
							strict = alert("Edit all children of [chosen]?", "Children being all types and subtypes of [chosen]", "Yes", "No") == "No"
							msglog += " <big>EDITED [!strict ? "ALL TYPES OF " :""][chosen]</big> in [fillturfs.len] tile\s "
						else
							return
					msglog += "at ([ADMIN_JMP(start)] to [ADMIN_JMP(end)])</span>"
					message_admins(msglog)
					log_admin(msglog)
					to_chat(usr, "<span class='notice'>If the server is lagging the operation will periodically sleep so the mass edit may take longer than typical.</span>")
					var/edits = 0
					for(var/turf/T in fillturfs)
						if(ispath(chosen, /turf))
							setvar(holder.buildmode.varholder, holder.buildmode.valueholder, T, reset)
						else
							for(var/atom/thing in T.contents)
								if(thing==usr)
									continue
								if(areaAction == MASS_DELETE || (strict && thing.type == chosen) || istype(thing,chosen))
									setvar(holder.buildmode.varholder, holder.buildmode.valueholder, thing, reset)
									edits++
								CHECK_TICK
						edits++
						CHECK_TICK
					if(edits)
						to_chat(usr, "<span class='info'>Successfully edited [edits] [chosen]'\s</span>")
		else
			return

/proc/build_click(mob/user, buildmode, params, obj/object)
	var/obj/effect/bmode/buildholder/holder = null
	for(var/obj/effect/bmode/buildholder/H in buildmodeholders)
		if(H.cl == user.client)
			holder = H
			break
	if(!holder)
		return
	var/list/pa = params2list(params)
	var/turf/RT = get_turf(object)
	switch(buildmode)
		if(1) // Basic Build
			if(istype(object,/turf) && pa.Find("left") && !pa.Find("alt") && !pa.Find("ctrl") )
				if(istype(object,/turf/space))
					var/turf/T = object
					T.ChangeTurf(/turf/simulated/floor)
					log_admin("[key_name(usr)] made a floor at [ADMIN_JMP(T)]")
					return
				else if(istype(object,/turf/simulated/floor))
					var/turf/T = object
					T.ChangeTurf(/turf/simulated/wall)
					log_admin("[key_name(usr)] made a wall at [ADMIN_JMP(T)]")
					return
				else if(istype(object,/turf/simulated/wall))
					var/turf/T = object
					T.ChangeTurf(/turf/simulated/wall/r_wall)
					log_admin("[key_name(usr)] made an rwall at [ADMIN_JMP(T)]")
					return
			else if(pa.Find("right"))
				if(istype(object,/turf/simulated/wall/r_wall))
					var/turf/T = object
					T.ChangeTurf(/turf/simulated/wall)
					log_admin("[key_name(usr)] downgraded an rwall at [ADMIN_JMP(T)]")
					return
				else if(istype(object,/turf/simulated/floor))
					var/turf/T = object
					T.ChangeTurf(/turf/space)
					log_admin("[key_name(usr)] removed flooring at [ADMIN_JMP(T)]")
					return
				else if(istype(object,/turf/simulated/wall))
					var/turf/T = object
					T.ChangeTurf(/turf/simulated/floor)
					log_admin("[key_name(usr)] removed a wall at [ADMIN_JMP(T)]")
					return
				else if(istype(object,/obj))
					qdel(object)
					return
			else if(istype(object,/turf) && pa.Find("alt") && pa.Find("left"))
				new/obj/machinery/door/airlock(get_turf(object))
				log_admin("[key_name(usr)] made an airlock at [ADMIN_JMP(RT)]")
			else if(istype(object,/turf) && pa.Find("ctrl") && pa.Find("left"))
				log_admin("[key_name(usr)] made a window at [ADMIN_JMP(RT)]")
				var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
				WIN.dir = holder.builddir.dir

		if(2) // Adv. Build
			if(pa.Find("ctrl") && pa.Find("shift"))
				if(!holder)
					return
				if(pa.Find("left"))
					holder.fill_left = RT
					to_chat(usr, "<span class='notice'>Set bottom left fill corner to ([ADMIN_JMP(RT)])</span>")
				else if(pa.Find("right"))
					holder.fill_right = RT
					to_chat(usr, "<span class='notice'>Set top right fill corner to ([ADMIN_JMP(RT)])</span>")
				if(holder.fill_left && holder.fill_right)
					var/turf/start = holder.fill_left
					var/turf/end = holder.fill_right
					if(start.z != end.z)
						to_chat(usr, "<span class='warning'>You can't do a fill across zlevels you silly person.</span>")
						holder.fill_left = null
						holder.fill_right = null
						return
					var/list/fillturfs = block(start,end)
					if(fillturfs.len)
						if(alert("You're about to do a fill operation spanning [fillturfs.len] tiles, are you sure?","Panic","Yes","No") == "Yes")
							if(fillturfs.len > 150)
								if(alert("Are you completely sure about filling [fillturfs.len] tiles?","Panic!!!!","Yes","No") != "Yes")
									holder.fill_left = null
									holder.fill_right = null
									to_chat(usr, "<span class='notice'>Cleared filling corners.</span>")
									return
							var/areaAction = alert("FILL tiles or DELETE them? areaAction will destroy EVERYTHING IN THE SELECTED AREA", "Create or destroy, your chance to be a GOD","FILL","DELETE") == "DELETE"
							if(areaAction)
								areaAction = (alert("Selective(TYPE) Delete or MASS Delete?", "Scorched Earth or selective destruction?", "Selective", "MASS") == "Selective" ? 2 : 1)
							else
								areaAction = (alert("Mass FILL or Selective(Type => Type) FILL?", "Do they really need [fillturfs.len] of closets?", "Selective", "Mass") == "Selective" ? 3 : 0)
							var/msglog = "<span class='danger'>[key_name_admin(usr)] just buildmode"
							var/strict = 1
							var/chosen
							switch(areaAction)
								if(MASS_DELETE)
									msglog += " <big>DELETED EVERYTHING</big> in [fillturfs.len] tile\s "
								if(SELECTIVE_DELETE)
									chosen = get_path_from_partial_text()
									if(!chosen)
										return
									strict = alert("Delete all children of [chosen]?", "Children being all types and subtypes of [chosen]", "Yes", "No") == "No"
									msglog += " <big>DELETED [!strict ? "ALL TYPES OF " :""][chosen]</big> in [fillturfs.len] tile\s "
								if(SELECTIVE_FILL)
									chosen = get_path_from_partial_text()
									if(!chosen)
										return
									strict = alert("Change all children of [chosen]?", "Children being all types and subtypes of [chosen]", "Yes", "No") == "No"
									msglog += " Changed all [chosen] in [fillturfs.len] tile\s to [holder.buildmode.objholder] "
								else
									msglog += " FILLED [fillturfs.len] tile\s with [holder.buildmode.objholder] "
							msglog += "at ([ADMIN_JMP(start)] to [ADMIN_JMP(end)])</span>"
							message_admins(msglog)
							log_admin(msglog)
							to_chat(usr, "<span class='notice'>If the server is lagging the operation will periodically sleep so the fill may take longer than typical.</span>")
							var/turf_op = ispath(holder.buildmode.objholder,/turf)
							var/deletions = 0
							for(var/turf/T in fillturfs)
								if(areaAction == MASS_DELETE || areaAction == SELECTIVE_DELETE)
									if(ispath(chosen, /turf))
										T.ChangeTurf(chosen)
										deletions++
									else
										for(var/atom/thing in T.contents)
											if(thing==usr)
												continue
											if(areaAction == MASS_DELETE || (strict && thing.type == chosen) || istype(thing,chosen))
												qdel(thing)
											deletions++
											CHECK_TICK
										if(areaAction == MASS_DELETE)
											T.ChangeTurf(/turf/space) //get_base_turf(T.z))
								else
									if(turf_op)
										if(areaAction == SELECTIVE_FILL)
											if(strict)
												if(T.type != chosen)
													continue
											else
												if(!istype(T, chosen))
													continue
										T.ChangeTurf(holder.buildmode.objholder)
									else
										if(areaAction == SELECTIVE_FILL)
											for(var/atom/thing in T.contents)
												if(strict)
													if(thing.type != chosen)
														continue
												else
													if(!istype(thing, chosen))
														continue
												var/atom/A = new holder.buildmode.objholder(T)
												A.dir = thing.dir
												qdel(thing)
												CHECK_TICK
										else
											var/obj/A = new holder.buildmode.objholder(T)
											if(istype(A))
												A.dir = holder.builddir.dir
								CHECK_TICK
							holder.fill_left = null
							holder.fill_right = null
							if(deletions)
								to_chat(usr, "<span class='info'>Successfully deleted [deletions] [chosen]'\s</span>")
				return
			if(pa.Find("left"))
				if(holder.buildmode.copycat)
					if(isturf(holder.buildmode.copycat))
						var/turf/T = get_turf(object)
						T.ChangeTurf(holder.buildmode.copycat.type)
						spawn(1)
							T.dir = holder.builddir.dir
							T.appearance = holder.buildmode.copycat.appearance
					else
						var/atom/movable/A = new holder.buildmode.copycat.type(get_turf(object))
						if(istype(A))
							A.dir = holder.builddir.dir
							if(holder.buildmode.copycat.light)
								A.set_light(holder.buildmode.copycat.light_range, holder.buildmode.copycat.light_power, holder.buildmode.copycat.light_color)
							A.appearance = holder.buildmode.copycat.appearance
					log_admin("[key_name(usr)] made a [holder.buildmode.copycat.type] at [ADMIN_JMP(RT)]")
				else
					if(ispath(holder.buildmode.objholder,/turf))
						var/turf/T = get_turf(object)
						T.ChangeTurf(holder.buildmode.objholder)
					else
						var/obj/A = new holder.buildmode.objholder (get_turf(object))
						if(istype(A))
							A.dir = holder.builddir.dir
					log_admin("[key_name(usr)] made a [holder.buildmode.objholder] at [ADMIN_JMP(RT)]")
			else if(pa.Find("right"))
				log_admin("[key_name(usr)] deleted a [object] at [ADMIN_JMP(RT)]")
				if(isobj(object))
					qdel(object)
			else if(pa.Find("middle"))
				if(istype(object,/mob) && !check_rights(R_DEBUG,0))
					to_chat(usr, "<span class='notice'>You don't have sufficient rights to clone [object.type]</span>")
				else
					if(pa.Find("ctrl"))
						holder.buildmode.copycat = object
						to_chat(usr, "<span class='info'>You will now build a lookalike of [object] when clicking.</span>")
					else
						holder.buildmode.objholder = object.type
						holder.buildmode.copycat = null
						to_chat(usr, "<span class='info'>You will now build [object.type] when clicking.</span>")

		if(3) // Edit
			if(pa.Find("left")) //I cant believe this shit actually compiles.
				if(object.vars.Find(holder.buildmode.varholder))
					log_admin("[key_name(usr)] modified [object.name]'s [holder.buildmode.varholder] to [holder.buildmode.valueholder]")
					object.vars[holder.buildmode.varholder] = holder.buildmode.valueholder
				else
					to_chat(usr, "<span class='warning'>[initial(object.name)] does not have a var called '[holder.buildmode.varholder]'</span>")
			if(pa.Find("right"))
				if(object.vars.Find(holder.buildmode.varholder))
					log_admin("[key_name(usr)] modified [object.name]'s [holder.buildmode.varholder] to [holder.buildmode.valueholder]")
					object.vars[holder.buildmode.varholder] = initial(object.vars[holder.buildmode.varholder])
				else
					to_chat(usr, "<span class='warning'>[initial(object.name)] does not have a var called '[holder.buildmode.varholder]'</span>")

		if(4) // Throw
			if(pa.Find("left"))
				if(!istype(object, /atom/movable))
					return
				log_admin("[key_name(usr)] is selecting [object] for throwing at [ADMIN_JMP(RT)]")
				holder.throw_atom = object
			if(pa.Find("right"))
				if(holder.throw_atom)
					holder.throw_atom.throw_at(object, 10, 1)
					log_admin("[key_name(usr)] is throwing a [holder.throw_atom] at [object] - [ADMIN_JMP(RT)]")

		if(5) // Room build
			if(pa.Find("left"))
				holder.buildmode.coordA = get_turf(object)
				to_chat(user, "<span class='notice'>Defined [object] ([object.type]) as point A.</span>")
			if(pa.Find("right"))
				holder.buildmode.coordB = get_turf(object)
				to_chat(user, "<span class='notice'>Defined [object] ([object.type]) as point B.</span>")
			if(holder.buildmode.coordA && holder.buildmode.coordB)
				to_chat(user, "<span class='notice'>A and B set, creating rectangle.</span>")
				holder.buildmode.make_rectangle(
					holder.buildmode.coordA,
					holder.buildmode.coordB,
					holder.buildmode.wall_holder,
					holder.buildmode.floor_holder
					)
				holder.buildmode.coordA = null
				holder.buildmode.coordB = null

		if(6) // Ladders
			if(pa.Find("left"))
				holder.buildmode.coordA = get_turf(object)
				to_chat(user, "<span class='notice'>Defined [object] ([object.type]) as upper ladder location.</span>")
			if(pa.Find("right"))
				holder.buildmode.coordB = get_turf(object)
				to_chat(user, "<span class='notice'>Defined [object] ([object.type]) as lower ladder location.</span>")
			if(holder.buildmode.coordA && holder.buildmode.coordB)
				to_chat(user, "<span class='notice'>Ladder locations set, building ladders.</span>")
				var/obj/structure/ladder/A = locate(/obj/structure/ladder) in holder.buildmode.coordA
				if(!A || A.down)
					A = new /obj/structure/ladder(holder.buildmode.coordA)
				var/obj/structure/ladder/B = locate(/obj/structure/ladder) in holder.buildmode.coordB
				if(!B || B.up)
					B = new /obj/structure/ladder(holder.buildmode.coordB)
				A.down = B
				B.up = A
				A.update_icon()
				B.update_icon()
				holder.buildmode.coordA = null
				holder.buildmode.coordB = null

		if(7) // Move into contents
			if(pa.Find("left"))
				if(istype(object, /atom))
					holder.throw_atom = object
			if(pa.Find("right"))
				if(holder.throw_atom && istype(object, /atom/movable))
					object.forceMove(holder.throw_atom)
					log_admin("[key_name(usr)] moved [object] into [holder.throw_atom].")

		if(8) // Lights
			if(pa.Find("left"))
				if(object)
					object.set_light(holder.buildmode.new_light_range, holder.buildmode.new_light_power, holder.buildmode.new_light_color)
			if(pa.Find("right"))
				if(object)
					object.reset_light()

		if(9) // Air
			if(object)
				var/turf/simulated/T = get_turf(object)
				if(!T)
					to_chat(usr, "<span class='warning'>No turf found.</span>")
					return

				if(!T.zone)
					to_chat(usr, "<span class='warning'>No zone found.</span>")
					return

				if(!T.zone.air)
					to_chat(usr, "<span class='warning'>No air found.</span>")
					return

				var/datum/gas_mixture/Target = T.return_air()

				if(pa.Find("left"))
					Target.remove(Target.total_moles())

					Target.oxygen =  holder.buildmode.new_mix_O2*holder.buildmode.new_pressure*Target.volume/(R_IDEAL_GAS_EQUATION*holder.buildmode.new_temperature)/100
					Target.carbon_dioxide =  holder.buildmode.new_mix_Co*holder.buildmode.new_pressure*Target.volume/(R_IDEAL_GAS_EQUATION*holder.buildmode.new_temperature)/100
					Target.nitrogen =  holder.buildmode.new_mix_N*holder.buildmode.new_pressure*Target.volume/(R_IDEAL_GAS_EQUATION*holder.buildmode.new_temperature)/100
					Target.phoron =  holder.buildmode.new_mix_Pl*holder.buildmode.new_pressure*Target.volume/(R_IDEAL_GAS_EQUATION*holder.buildmode.new_temperature)/100

					Target.temperature = holder.buildmode.new_temperature
					Target.update_values()
					Target.check_tile_graphic()

				if(pa.Find("right"))
					Target.remove(Target.total_moles())
					if(Target.trace_gases.len)
						qdel(Target.trace_gases)

/proc/get_path_from_partial_text(default_path = "/obj")
	var/desired_path = input("Enter full or partial typepath.","Typepath","[default_path]")

	var/list/types = typesof(/atom)
	var/list/matches = list()

	if(default_path != "/atom")
		for(var/path in types)
			if(findtext("[path]", desired_path))
				matches += path
	else
		matches = types

	if(matches.len==0)
		to_chat(usr, "<span class='warning'>No types of [desired_path] found.</span>")
		return

	var/result = null

	if(matches.len==1)
		result = matches[1]
	else
		result = input("Select an atom type", "Spawn Atom", matches[1]) as null|anything in matches
	return result

/proc/setvar(varname, varvalue, atom/A, reset = 0)
	if(!reset) //I cant believe this shit actually compiles.
		if(A.vars.Find(varname))
			log_admin("[key_name(usr)] modified [A.name]'s [varname] to [varvalue]")
			A.vars[varname] = varvalue
	else
		if(A.vars.Find(varname))
			log_admin("[key_name(usr)] modified [A.name]'s [varname] to initial")
			A.vars[varname] = initial(A.vars[varname])

/obj/effect/bmode/buildmode/proc/make_rectangle(var/turf/A, var/turf/B, var/turf/wall_type, var/turf/floor_type)
	if(!A || !B) // No coords
		return
	if(A.z != B.z) // Not same z-level
		return

	var/height = A.y - B.y
	var/width = A.x - B.x
	var/z_level = A.z

	var/turf/lower_left_corner = null
	// First, try to find the lowest part
	var/desired_y = 0
	if(A.y <= B.y)
		desired_y = A.y
	else
		desired_y = B.y

	//Now for the left-most part.
	var/desired_x = 0
	if(A.x <= B.x)
		desired_x = A.x
	else
		desired_x = B.x

	lower_left_corner = locate(desired_x, desired_y, z_level)

	// Now we can begin building the actual room.  This defines the boundries for the room.
	var/low_bound_x = lower_left_corner.x
	var/low_bound_y = lower_left_corner.y

	var/high_bound_x = lower_left_corner.x + abs(width)
	var/high_bound_y = lower_left_corner.y + abs(height)

	for(var/i = low_bound_x, i <= high_bound_x, i++)
		for(var/j = low_bound_y, j <= high_bound_y, j++)
			var/turf/T = locate(i, j, z_level)
			if(i == low_bound_x || i == high_bound_x || j == low_bound_y || j == high_bound_y)
				if(ispath(wall_type, /turf))
					T.ChangeTurf(wall_type)
				else
					new wall_type(T)
			else
				if(ispath(floor_type, /turf))
					T.ChangeTurf(floor_type)
				else
					new floor_type(T)

#undef MASS_FILL
#undef MASS_DELETE
#undef SELECTIVE_DELETE
#undef SELECTIVE_FILL