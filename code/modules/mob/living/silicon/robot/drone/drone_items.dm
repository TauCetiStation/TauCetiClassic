//Simple borg hand.
//Limited use.
/obj/item/weapon/gripper
	name = "magnetic gripper"
	desc = "A simple grasping tool for synthetic assets."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"

	//Has a list of items that it can hold.
	var/list/can_hold = list(
		/obj/item/weapon/stock_parts/cell,
		/obj/item/weapon/firealarm_electronics,
		/obj/item/weapon/airalarm_electronics,
		/obj/item/weapon/airlock_electronics,
		/obj/item/weapon/module/power_control,
		/obj/item/weapon/stock_parts,
		/obj/item/light_fixture_frame,
		/obj/item/apc_frame,
		/obj/item/alarm_frame,
		/obj/item/door_control_frame,
		/obj/item/firealarm_frame,
		/obj/item/weapon/table_parts,
		/obj/item/weapon/rack_parts,
		/obj/item/weapon/camera_assembly,
		/obj/item/weapon/tank,
		/obj/item/weapon/circuitboard,
		/obj/item/weapon/light/tube,
		/obj/item/weapon/light/bulb
		)

	//Item currently being held.
	var/obj/item/wrapped = null

/obj/item/weapon/gripper/paperwork
	name = "paperwork gripper"
	desc = "A simple grasping tool for clerical work."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"

	can_hold = list(
		/obj/item/weapon/clipboard,
		/obj/item/weapon/paper,
		/obj/item/weapon/paper_bundle,
		/obj/item/weapon/card/id,
		/obj/item/weapon/book,
		/obj/item/weapon/newspaper
		)

/obj/item/weapon/gripper/chemistry
	name = "chemistry gripper"
	desc = "A simple grasping tool for chemical work."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"

	can_hold = list(
		/obj/item/weapon/reagent_containers/glass,
		/obj/item/weapon/storage/pill_bottle
		)

/obj/item/weapon/gripper/service
	name = "service gripper"
	desc = "A simple grasping tool for service work."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"

	can_hold = list(
		/obj/item/weapon/reagent_containers/glass,
		/obj/item/weapon/reagent_containers/food
		)

/obj/item/weapon/gripper/examine(mob/user)
	..()
	if(wrapped)
		to_chat(user, "It is holding \a [wrapped].")

/obj/item/weapon/gripper/attack_self(mob/user)
	if(wrapped)
		wrapped.attack_self(user)

		if(QDELETED(wrapped))
			wrapped = null

/obj/item/weapon/gripper/verb/drop_item()

	set name = "Drop Item"
	set desc = "Release an item from your magnetic gripper."
	set category = "Drone"

	if(!wrapped)
		//There's some weirdness with items being lost inside the arm. Trying to fix all cases. ~Z
		for(var/obj/item/thing in src.contents)
			thing.loc = get_turf(src)
		return

	if(wrapped.loc != src)
		wrapped = null
		return

	to_chat(src.loc, "<span class='warning'>You drop \the [wrapped].</span>")
	wrapped.loc = get_turf(src)
	wrapped = null
	//update_icon()

/obj/item/weapon/gripper/attack(mob/living/carbon/M, mob/living/carbon/user)
	return

/obj/item/weapon/gripper/afterattack(atom/target, mob/user, proximity, params)

	if(!target || !proximity) //Target is invalid or we are not adjacent.
		return

	//There's some weirdness with items being lost inside the arm. Trying to fix all cases. ~Z
	if(!wrapped)
		for(var/obj/item/thing in src.contents)
			wrapped = thing
			break

	if(wrapped) //Already have an item.

		wrapped.loc = user
		//Pass the attack on to the target.
		target.attackby(wrapped,user)

		if(wrapped && src && wrapped.loc == user)
			wrapped.loc = src

		//Sanity/item use checks.

		if(!wrapped || !user)
			return

		if(wrapped.loc != src.loc)
			wrapped = null
			return

	if(istype(target,/obj/item)) //Check that we're not pocketing a mob.

		//...and that the item is not in a container.
		if(!isturf(target.loc))
			return

		var/obj/item/I = target

		//Check if the item is blacklisted.
		var/grab = 0
		for(var/typepath in can_hold)
			if(istype(I,typepath))
				grab = 1
				break

		//We can grab the item, finally.
		if(grab)
			to_chat(user, "You collect \the [I].")
			I.loc = src
			wrapped = I
			return
		else
			to_chat(user, "<span class='warning'>Your gripper cannot hold \the [target].</span>")

	else if(istype(target,/obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = target
		if(A.opened)
			if(A.cell)

				wrapped = A.cell

				A.cell.add_fingerprint(user)
				A.cell.updateicon()
				A.cell.loc = src
				A.cell = null

				A.charging = 0
				A.update_icon()

				user.visible_message("<span class='warning'>[user] removes the power cell from [A]!</span>", "You remove the power cell.")

//TODO: Matter decompiler.
/obj/item/weapon/matter_decompiler

	name = "matter decompiler"
	desc = "Eating trash, bits of glass, or other debris will replenish your stores."
	icon = 'icons/obj/device.dmi'
	icon_state = "decompiler"

	//Metal, glass, wood, plastic.
	var/list/stored_comms = list(
		"metal" = 0,
		"glass" = 0,
		"wood" = 0,
		"plastic" = 0
		)

/obj/item/weapon/matter_decompiler/attack(mob/living/carbon/M, mob/living/carbon/user)
	return

/obj/item/weapon/matter_decompiler/afterattack(atom/target, mob/user, proximity, params)

	if(!proximity) return //Not adjacent.

	//We only want to deal with using this on turfs. Specific items aren't important.
	var/turf/T = get_turf(target)
	if(!istype(T))
		return

	//Used to give the right message.
	var/grabbed_something = 0

	for(var/mob/M in T)
		if(istype(M,/mob/living/simple_animal/lizard) || istype(M,/mob/living/simple_animal/mouse))
			src.loc.visible_message("<span class='warning'>[src.loc] sucks [M] into its decompiler. There's a horrible crunching noise.</span>","<span class='warning'>It's a bit of a struggle, but you manage to suck [M] into your decompiler. It makes a series of visceral crunching noises.</span>")
			new/obj/effect/decal/cleanable/blood/splatter(get_turf(src))
			qdel(M)
			stored_comms["wood"]++
			stored_comms["wood"]++
			stored_comms["plastic"]++
			stored_comms["plastic"]++
			return

		else if(istype(M,/mob/living/silicon/robot/drone) && !M.client)

			var/mob/living/silicon/robot/drone/D = src.loc

			if(!istype(D))
				return
			if(user.is_busy()) return
			to_chat(D, "<span class='warning'>You begin decompiling the other drone.</span>")

			if(!do_after(D,50,target = M))
				to_chat(D, "<span class='warning'>You need to remain still while decompiling such a large object.</span>")
				return

			if(!M || !D) return

			to_chat(D, "<span class='warning'>You carefully and thoroughly decompile your downed fellow, storing as much of its resources as you can within yourself.</span>")

			qdel(M)
			new/obj/effect/decal/cleanable/blood/oil(get_turf(src))

			stored_comms["metal"] += 15
			stored_comms["glass"] += 15
			stored_comms["wood"] += 5
			stored_comms["plastic"] += 5

			return
		else
			continue

	for(var/obj/W in T)
		//Different classes of items give different commodities.
		if (istype(W,/obj/item/weapon/cigbutt))
			stored_comms["plastic"]++
		else if(istype(W,/obj/effect/spider/spiderling))
			stored_comms["wood"]++
			stored_comms["wood"]++
			stored_comms["plastic"]++
			stored_comms["plastic"]++
		else if(istype(W,/obj/item/weapon/light))
			var/obj/item/weapon/light/L = W
			if(L.status >= 2) //In before someone changes the inexplicably local defines. ~ Z
				stored_comms["metal"]++
				stored_comms["glass"]++
			else
				continue
		else if(istype(W,/obj/effect/decal/remains/robot))
			stored_comms["metal"]++
			stored_comms["metal"]++
			stored_comms["plastic"]++
			stored_comms["plastic"]++
			stored_comms["glass"]++
		else if(istype(W,/obj/item/trash))
			stored_comms["metal"]++
			stored_comms["plastic"]++
			stored_comms["plastic"]++
			stored_comms["plastic"]++
		else if(istype(W,/obj/effect/decal/cleanable/blood/gibs/robot))
			stored_comms["metal"]++
			stored_comms["metal"]++
			stored_comms["glass"]++
			stored_comms["glass"]++
		else if(istype(W,/obj/item/ammo_casing))
			stored_comms["metal"]++
		else if(istype(W,/obj/item/weapon/shard/shrapnel))
			stored_comms["metal"]++
			stored_comms["metal"]++
			stored_comms["metal"]++
		else if(istype(W,/obj/item/weapon/shard))
			stored_comms["glass"]++
			stored_comms["glass"]++
			stored_comms["glass"]++
		else if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/grown))
			stored_comms["wood"]++
			stored_comms["wood"]++
			stored_comms["wood"]++
			stored_comms["wood"]++
		else
			continue

		qdel(W)
		grabbed_something = 1

	if(grabbed_something)
		to_chat(user, "<span class='notice'>You deploy your decompiler and clear out the contents of \the [T].</span>")
	else
		to_chat(user, "<span class='warning'>Nothing on \the [T] is useful to you.</span>")
	return

//PRETTIER TOOL LIST.
/mob/living/silicon/robot/drone/installed_modules()

	if(weapon_lock)
		to_chat(src, "<span class='warning'>Weapon lock active, unable to use modules! Count:[weaponlock_time]</span>")
		return

	if(!module)
		module = new /obj/item/weapon/robot_module/drone(src)

	var/dat = "<HEAD><TITLE>Drone modules</TITLE></HEAD><BODY>\n"
	dat += {"
	<B>Activated Modules</B>
	<BR>
	Module 1: [module_state_1 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]<BR>
	Module 2: [module_state_2 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]<BR>
	Module 3: [module_state_3 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]<BR>
	<BR>
	<B>Installed Modules</B><BR><BR>"}


	var/tools = "<B>Tools and devices</B><BR>"
	var/resources = "<BR><B>Resources</B><BR>"

	for (var/O in module.modules)

		var/module_string = ""

		if (!O)
			module_string += text("<B>Resource depleted</B><BR>")
		else if(activated(O))
			module_string += text("[O]: <B>Activated</B><BR>")
		else
			module_string += text("[O]: <A HREF=?src=\ref[src];act=\ref[O]>Activate</A><BR>")

		if((istype(O,/obj/item/weapon) || istype(O,/obj/item/device)) && !(iscoil(O)))
			tools += module_string
		else
			resources += module_string

	dat += tools

	if (emagged)
		if (!module.emag)
			dat += text("<B>Resource depleted</B><BR>")
		else if(activated(module.emag))
			dat += text("[module.emag]: <B>Activated</B><BR>")
		else
			dat += text("[module.emag]: <A HREF=?src=\ref[src];act=\ref[module.emag]>Activate</A><BR>")

	dat += resources

	src << browse(dat, "window=robotmod")

//Putting the decompiler here to avoid doing list checks every tick.
/mob/living/silicon/robot/drone/use_power()

	..()
	if(!src.has_power || !decompiler)
		return

	//The decompiler replenishes drone stores from hoovered-up junk each tick.
	for(var/type in decompiler.stored_comms)
		if(decompiler.stored_comms[type] > 0)
			var/obj/item/stack/sheet/stack
			switch(type)
				if("metal")
					if(!stack_metal)
						stack_metal = new (module, 1)
					stack = stack_metal
				if("glass")
					if(!stack_glass)
						stack_glass = new (module, 1)
					stack = stack_glass
				if("wood")
					if(!stack_wood)
						stack_wood = new (module, 1)
					stack = stack_wood
				if("plastic")
					if(!stack_plastic)
						stack_plastic = new (module, 1)
					stack = stack_plastic

			stack.add(1)
			decompiler.stored_comms[type]--;
