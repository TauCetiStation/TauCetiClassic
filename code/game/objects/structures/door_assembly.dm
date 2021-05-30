/obj/structure/door_assembly
	name = "airlock assembly"

	icon              = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state        = "construction"
	var/overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'

	anchored  = FALSE
	density   = TRUE
	var/state = ASSEMBLY_SECURED
	var/obj/item/weapon/airlock_electronics/electronics = null

	var/airlock_type = /obj/machinery/door/airlock
	var/glass_type   = /obj/machinery/door/airlock/glass

	var/glass_material   = null    // Icon logic.
	var/mineral          = null    // Door mineral type.
	var/can_insert_glass = TRUE
	var/glass_only       = FALSE   // For something like multitile airlock, where there is only one type.
	var/created_name     = null

/obj/structure/door_assembly/atom_init()
	. = ..()
	update_state()

/obj/structure/door_assembly/Destroy()
	if(electronics)
		qdel(electronics)
		electronics = null
	return ..()

/obj/structure/door_assembly/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/pen))
		var/t = sanitize_safe(input(user, "Enter the name for the door.", name, input_default(created_name)), MAX_LNAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && src.loc != usr)
			return
		created_name = t
		return

	if(iswelder(W) && ((glass_material && !glass_only) || mineral || !anchored))
		var/obj/item/weapon/weldingtool/WT = W
		if(!WT.tool_start_check(user, amount=0))
			return
		if(glass_material)
			user.visible_message("[user] welds the glass panel out of the airlock assembly.", "You start to weld the glass panel out of the airlock assembly.")
			if(WT.use_tool(src, user, 40, volume = 50))
				to_chat(user, "<span class='notice'>You welded the glass panel out!</span>")
				new /obj/item/stack/sheet/rglass(loc)
				set_glass(FALSE)

		else if(mineral)
			user.visible_message("[user] welds the [mineral] plating off the airlock assembly.", "You start to weld the [mineral] plating off the airlock assembly.")
			if(WT.use_tool(src, user, 40, volume = 50))
				to_chat(user, "<span class='notice'>You welded the [mineral] plating off!</span>")
				var/M = text2path("/obj/item/stack/sheet/mineral/[mineral]")
				new M(loc, 2)
				change_mineral_airlock_type()

		else if(!anchored)
			user.visible_message("[user] dissassembles the airlock assembly.", "You start to dissassemble the airlock assembly.")
			if(WT.use_tool(src, user, 40, volume = 50))
				to_chat(user, "<span class='notice'>You dissasembled the airlock assembly!</span>")
				new /obj/item/stack/sheet/metal(loc, 4)
				qdel (src)

	else if(iswrench(W) && state == ASSEMBLY_SECURED)
		if(user.is_busy()) return
		if(anchored)
			user.visible_message("[user] unsecures the airlock assembly from the floor.", "You start to unsecure the airlock assembly from the floor.")
		else
			user.visible_message("[user] secures the airlock assembly to the floor.", "You start to secure the airlock assembly to the floor.")

		if(W.use_tool(src, user, 40, volume = 50))
			to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secured the airlock assembly!</span>")
			anchored = !anchored

	else if(iscoil(W) && state == ASSEMBLY_SECURED && anchored )
		if(user.is_busy(src))
			return
		var/obj/item/stack/cable_coil/coil = W
		user.visible_message("[user] wires the airlock assembly.", "You start to wire the airlock assembly.")
		if(coil.use_tool(src, user, 40, amount = 1, volume = 50))
			state = ASSEMBLY_WIRED
			to_chat(user, "<span class='notice'>You wire the airlock!</span>")

	else if(iswirecutter(W) && state == ASSEMBLY_WIRED)
		if(user.is_busy()) return
		playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
		user.visible_message("[user] cuts the wires from the airlock assembly.", "You start to cut the wires from airlock assembly.")

		if(W.use_tool(src, user, 40, volume = 50))
			to_chat(user, "<span class='notice'>You cut the airlock wires!</span>")
			new /obj/item/stack/cable_coil/random(loc, 1)
			state = ASSEMBLY_SECURED

	else if(istype(W, /obj/item/weapon/airlock_electronics) && state == ASSEMBLY_WIRED)
		var/obj/item/weapon/airlock_electronics/AE = W
		if(!AE.broken && !user.is_busy())
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			user.visible_message("[user] installs the electronics into the airlock assembly.", "You start to install electronics into the airlock assembly.")

			if(W.use_tool(src, user, 40, volume = 50))
				user.drop_item()
				AE.loc = src
				to_chat(user, "<span class='notice'>You installed the airlock electronics!</span>")
				state = ASSEMBLY_NEAR_FINISHED
				electronics = AE

	else if(iscrowbar(W) && state == ASSEMBLY_NEAR_FINISHED)
		user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to remove the electronics from the airlock assembly.")
		if(W.use_tool(src, user, 40, volume = 100))
			to_chat(user, "<span class='notice'>You removed the airlock electronics!</span>")
			state = ASSEMBLY_WIRED
			var/obj/item/weapon/airlock_electronics/AE
			if (!electronics)
				AE = new /obj/item/weapon/airlock_electronics(loc)
			else
				AE = electronics
				electronics = null
				AE.loc = loc

	else if(istype(W, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/S = W
		if(S.get_amount() >= 1)
			if(istype(S, /obj/item/stack/sheet/rglass))
				if(glass_material)
					to_chat(user, "<span class='notice'>There is already glass in the [src].</span>")
				else if(can_insert_glass)
					if(user.is_busy()) return
					playsound(src, 'sound/items/Crowbar.ogg', VOL_EFFECTS_MASTER)
					user.visible_message("[user] adds [S.name] to the [src].", "You start to install [S.name] into the [src].")
					if(W.use_tool(src, user, 40, amount = 1, volume = 100))
						to_chat(user, "<span class='notice'>You installed reinforced glass windows into the [src]!</span>")
						set_glass(TRUE)
				else
					to_chat(user, "<span class='notice'>You can't insert glass into [src].</span>")

			else if(istype(S, /obj/item/stack/sheet/mineral) && S.sheettype)
				if(can_insert_mineral())
					var/M = S.sheettype
					if(S.get_amount() >= 2)
						if(user.is_busy(src))
							return
						playsound(src, 'sound/items/Crowbar.ogg', VOL_EFFECTS_MASTER)
						user.visible_message("[user] adds [S.name] to the airlock assembly.", "You start to install [S.name] into the airlock assembly.")
						if(S.use_tool(src, user, 40, amount = 2, volume = 100))
							to_chat(user, "<span class='notice'>You installed [M] plating into the airlock assembly!</span>")
							change_mineral_airlock_type(M)
					else
						to_chat(user, "<span class='notice'>There is not enough [S].</span>")
				else
					to_chat(user, "<span class='notice'>You can't add [S] to the [src].</span>")

	else if(isscrewdriver(W) && state == ASSEMBLY_NEAR_FINISHED )
		if(user.is_busy(src))
			return
		to_chat(user, "<span class='notice'>Now finishing the airlock.</span>")

		if(W.use_tool(src, user, 40, volume = 100))
			to_chat(user, "<span class='notice'>You finish the airlock!</span>")
			var/obj/machinery/door/airlock/door = null
			if(glass_material && !glass_only)
				door = new glass_type(loc, dir)
			else
				door = new airlock_type(loc, dir)
			door.assembly_type = type
			door.electronics = electronics
			if(electronics.one_access)
				door.req_access = list()
				door.req_one_access = electronics.conf_access
			else
				door.req_access = electronics.conf_access
			if(created_name)
				door.name = created_name
			electronics.loc = door
			electronics = null
			qdel(src)
	else
		..()
	update_state()

/obj/structure/door_assembly/proc/set_glass(has_glass, glass_material = "glass")
	if(has_glass)
		src.glass_material = glass_material
		can_insert_glass   = FALSE
	else
		src.glass_material = null
		can_insert_glass   = TRUE

/obj/structure/door_assembly/proc/can_insert_mineral()
	return type == /obj/structure/door_assembly && !mineral

/obj/structure/door_assembly/proc/change_mineral_airlock_type(mineral = null)
	if(mineral)
		var/normal_airlock_type = text2path("/obj/machinery/door/airlock/[mineral]")
		var/glass_airlock_type  = text2path("/obj/machinery/door/airlock/[mineral]/glass")

		airlock_type = normal_airlock_type
		glass_type   = glass_airlock_type
		src.mineral  = mineral

		switch(mineral)
			if("gold")
				icon = 'icons/obj/doors/airlocks/station/gold.dmi'
			if("silver")
				icon = 'icons/obj/doors/airlocks/station/silver.dmi'
			if("diamond")
				icon = 'icons/obj/doors/airlocks/station/diamond.dmi'
			if("uranium")
				icon = 'icons/obj/doors/airlocks/station/uranium.dmi'
			if("phoron")
				icon = 'icons/obj/doors/airlocks/station/phoron.dmi'
			if("clown")
				icon = 'icons/obj/doors/airlocks/station/bananium.dmi'
			if("sandstone")
				icon = 'icons/obj/doors/airlocks/station/sandstone.dmi'
	else
		airlock_type = initial(airlock_type)
		glass_type   = initial(glass_type)
		icon         = initial(icon)
		src.mineral  = null


/obj/structure/door_assembly/proc/update_state()
	update_icon()
	var/general_state_text
	switch(state)
		if(ASSEMBLY_SECURED)
			general_state_text = "[anchored ? "secured " : ""]"
		if(ASSEMBLY_WIRED)
			general_state_text = "wired "
		if(ASSEMBLY_NEAR_FINISHED)
			general_state_text = "near finished "

	var/glass_state_text   = "[glass_material ? "[glass_material] " : ""]"
	var/mineral_state_text = "[mineral ? "[mineral] " : ""]"

	name = general_state_text + glass_state_text + mineral_state_text + initial(name)

/obj/structure/door_assembly/update_icon()
	cut_overlays()
	if(!glass_material)
		add_overlay(get_airlock_overlay("fill_construction", icon))
	else
		add_overlay(get_airlock_overlay("[glass_material]_construction", overlays_file))
	add_overlay(get_airlock_overlay("panel_c[state + 1]", overlays_file))
