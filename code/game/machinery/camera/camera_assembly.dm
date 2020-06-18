/obj/item/weapon/camera_assembly
	name = "camera assembly"
	desc = "The basic construction for Nanotrasen-Always-Watching-You cameras."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "cameracase"
	w_class = ITEM_SIZE_SMALL
	anchored = 0

	m_amt = 700
	g_amt = 300

	//	Motion, EMP-Proof, X-Ray
	var/list/obj/item/possible_upgrades = list(/obj/item/device/assembly/prox_sensor, /obj/item/stack/sheet/mineral/phoron, /obj/item/device/analyzer)
	var/list/upgrades = list()
	var/state = 0
	/*
				0 = Nothing done to it
				1 = Wrenched in place
				2 = Welded in place
				3 = Wires attached to it (you can now attach/dettach upgrades)
				4 = Screwdriver panel closed and is fully built (you cannot attach upgrades)
	*/

/obj/item/weapon/camera_assembly/attackby(obj/item/I, mob/user, params)
	switch(state)
		if(0)
			// State 0
			if(iswrench(I) && isturf(src.loc))
				to_chat(user, "You wrench the assembly into place.")
				anchored = TRUE
				state = 1
				update_icon()
				auto_turn()
				return

		if(1)
			// State 1
			if(iswelder(I))
				if(weld(I, user))
					to_chat(user, "You weld the assembly securely into place.")
					anchored = 1
					state = 2
				return

			else if(iswrench(I))
				to_chat(user, "You unattach the assembly from it's place.")
				anchored = 0
				update_icon()
				state = 0
				return

		if(2)
			// State 2
			if(iscoil(I))
				var/obj/item/stack/cable_coil/C = I
				if(C.use(2))
					to_chat(user, "You add wires to the assembly.")
					state = 3
				return

			else if(iswelder(I))
				if(weld(I, user))
					to_chat(user, "You unweld the assembly from it's place.")
					state = 1
					anchored = TRUE
				return

		if(3)
			// State 3
			if(isscrewdriver(I))
				playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)

				var/input = sanitize_safe(input(usr, "Which networks would you like to connect this camera to? Seperate networks with a comma. No Spaces!\nFor example: SS13,Security,Secret ", "Set Network", "SS13"), MAX_LNAME_LEN)
				if(!input)
					to_chat(usr, "No input found please hang up and try your call again.")
					return

				var/list/tempnetwork = splittext(input, ",")
				if(tempnetwork.len < 1)
					to_chat(usr, "No network found please hang up and try your call again.")
					return

				var/temptag = "[get_area(src)] ([rand(1, 999)])"
				input = sanitize_safe(input(usr, "How would you like to name the camera?", "Set Camera Name", input_default(temptag)), MAX_LNAME_LEN)

				var/obj/machinery/camera/C = new(src.loc, src)

				C.auto_turn()

				C.replace_networks(uniquelist(tempnetwork))
				tempnetwork = difflist(C.network,RESTRICTED_CAMERA_NETWORKS)
				if(!tempnetwork.len)//Camera isn't on any open network - remove its chunk from AI visibility.
					cameranet.removeCamera(C)

				C.c_tag = input

				for(var/i = 5; i >= 0; i -= 1)
					var/direct = input(user, "Direction?", "Assembling Camera", null) in list("LEAVE IT", "NORTH", "EAST", "SOUTH", "WEST" )
					if(direct != "LEAVE IT")
						C.dir = text2dir(direct)
					if(i != 0)
						var/confirm = alert(user, "Is this what you want? Chances Remaining: [i]", "Confirmation", "Yes", "No")
						if(confirm == "Yes")
							break
				return

			else if(iswirecutter(I))
				new /obj/item/stack/cable_coil/red(get_turf(src), 2)
				playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "You cut the wires from the circuits.")
				state = 2
				return

	// Upgrades!
	if(is_type_in_list(I, possible_upgrades) && !is_type_in_list(I, upgrades)) // Is a possible upgrade and isn't in the camera already.
		to_chat(user, "You attach the [I] into the assembly inner circuits.")
		upgrades += I
		user.drop_from_inventory(I, src)

	// Taking out upgrades
	else if(iscrowbar(I) && upgrades.len)
		var/obj/U = locate(/obj) in upgrades
		if(U)
			to_chat(user, "You unattach an upgrade from the assembly.")
			playsound(src, 'sound/items/Crowbar.ogg', VOL_EFFECTS_MASTER)
			U.loc = get_turf(src)
			upgrades -= U

	else
		return ..()

/obj/item/weapon/camera_assembly/update_icon()
	if(anchored)
		icon_state = "camera1"
	else
		icon_state = "cameracase"

/obj/item/weapon/camera_assembly/attack_hand(mob/user)
	if(!anchored)
		..()

/obj/item/weapon/camera_assembly/proc/weld(obj/item/weapon/weldingtool/WT, mob/user)
	if(!WT.isOn())
		return 0
	if(user.is_busy(src)) return
	to_chat(user, "<span class='notice'>You start to weld the [src]..</span>")
	WT.eyecheck(user)
	if(WT.use_tool(src, user, 20, volume = 50))
		if(!WT.isOn())
			return 0
		return 1
	return 0
