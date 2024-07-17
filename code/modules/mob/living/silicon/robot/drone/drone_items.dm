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
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/plasteel,
		/obj/item/stack/tile,
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


/obj/item/weapon/gripper/atom_init()
	. = ..()
	RegisterSignal(src, list(COMSIG_HAND_IS), PROC_REF(is_hand))
	RegisterSignal(src, list(COMSIG_HAND_ATTACK), PROC_REF(attack_as_hand))
	RegisterSignal(src, list(COMSIG_HAND_DROP_ITEM), PROC_REF(drop_item))
	RegisterSignal(src, list(COMSIG_HAND_PUT_IN), PROC_REF(put_in))
	RegisterSignal(src, list(COMSIG_HAND_GET_ITEM), PROC_REF(get_item))

/obj/item/weapon/gripper/Destroy()
	UnregisterSignal(src, list(COMSIG_HAND_IS, COMSIG_HAND_ATTACK,
                               COMSIG_HAND_DROP_ITEM, COMSIG_HAND_PUT_IN, COMSIG_HAND_GET_ITEM))

	return ..()


/obj/item/weapon/gripper/proc/is_hand(datum/source, atom/T, mob/user, params)
	return TRUE

/obj/item/weapon/gripper/proc/clear_wrapped()
	wrapped = null

/obj/item/weapon/gripper/proc/wrap(obj/item/I)
	wrapped = I
	I.forceMove(src)
	RegisterSignal(I, list(COMSIG_PARENT_QDELETING), PROC_REF(clear_wrapped))

/obj/item/weapon/gripper/proc/attack_as_hand(datum/source, atom/T, mob/user, params)
	if(wrapped)
		return

	if(!(isturf(user.loc) && (isturf(T) || isturf(T.loc)) && T.Adjacent(user)))
		return

	//disable intent actions with mobs
	if(ismob(T))
		return

	//handling opened apc with cell
	if(istype(T, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = T
		if(A.opened)
			if(A.cell)

				wrap(A.cell)

				A.cell.add_fingerprint(user)
				A.cell.updateicon()
				A.cell = null

				A.charging = FALSE
				A.update_icon()

				user.visible_message("<span class='warning'>[user] removes the power cell from [A]!</span>", "You remove the power cell.")
				return

	T.attack_hand(user)
	return

/obj/item/weapon/gripper/proc/drop_item(datum/source, atom/T, mob/user)
	if(!wrapped)
		return FALSE
	var/obj/item/I = wrapped
	if(T)
		I.forceMove(T)
	else
		I.forceMove(get_turf(user))
	UnregisterSignal(wrapped, list(COMSIG_PARENT_QDELETING))
	wrapped = null
	return TRUE

/obj/item/weapon/gripper/proc/put_in(datum/source, obj/item/I, mob/user)
	//Check if the item in gripper
	if(wrapped)
		return FALSE

	//Check if the item is blacklisted.
	var/grab = FALSE
	for(var/typepath in can_hold)
		if(istype(I, typepath))
			grab = TRUE
			break

	//We can grab the item, finally.
	if(grab)
		if(user.pulling == I)
			user.stop_pulling()
		wrap(I)
		to_chat(user, "You collect \the [I].")
		return TRUE

	to_chat(user, "<span class='warning'>Your gripper cannot hold \the [I].</span>")
	return FALSE

/obj/item/weapon/gripper/proc/get_item(datum/source, mob/user)
	if(wrapped)
		return wrapped
	return src //return src to signal COMSIG_HAND_ATTACK


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

/obj/item/weapon/gripper/service
	name = "service gripper"
	desc = "A simple grasping tool for service work."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"

	can_hold = list(
		/obj/item/weapon/reagent_containers/glass,
		/obj/item/weapon/reagent_containers/food
		)

/obj/item/weapon/gripper/science
	name = "science gripper"
	desc = "A complex grasping tool for science work."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"

	can_hold = list(
		/obj/item/bluespace_crystal,
		/obj/item/weapon/tank,
		/obj/item/device/assembly/signaler,
		/obj/item/device/gps,
		/obj/item/weapon/reagent_containers/food/snacks/monkeycube,
		/obj/item/weapon/reagent_containers/glass,
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/cable_coil,
		/obj/item/stack/sheet/mineral,
		/obj/item/stack/sheet/plasteel,
		/obj/item/weapon/circuitboard,
		/obj/item/device/mmi,
		/obj/item/brain,
		/obj/item/device/mmi/posibrain,
		/obj/item/robot_parts,
		/obj/item/weapon/stock_parts,
		/obj/item/device/flash
		)

/obj/item/weapon/gripper/medical
	name = "medical gripper"
	desc = "A holder for limbs and chemical containers."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"

	can_hold = list(
		/obj/item/weapon/reagent_containers/blood,
		/obj/item/weapon/reagent_containers/glass,
		/obj/item/weapon/reagent_containers/pill,
		/obj/item/weapon/storage/pill_bottle,
		/obj/item/organ/internal,
		/obj/item/organ/external,
		/obj/item/brain,
		/obj/item/robot_parts/l_arm,
		/obj/item/robot_parts/r_arm,
		/obj/item/robot_parts/l_leg,
		/obj/item/robot_parts/r_leg,
		/obj/item/stack/sheet/mineral/phoron,
		/obj/item/weapon/tank/anesthetic,
		/obj/item/bodybag,
		/obj/item/weapon/reagent_containers/syringe
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

/obj/item/weapon/gripper/verb/drop_item_verb()
	set name = "Drop Item"
	set desc = "Освобождает взятый вами предмет из магнитного держателя."
	set category = "Commands"

	SEND_SIGNAL(src, COMSIG_HAND_DROP_ITEM, get_turf(src))

/obj/item/weapon/gripper/attack(mob/living/carbon/M, mob/living/carbon/user)
	return

/obj/item/weapon/gripper/afterattack(atom/target, mob/user, proximity, params)
	return

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
			loc.visible_message("<span class='warning'>[src.loc] sucks [M] into its decompiler. There's a horrible crunching noise.</span>","<span class='warning'>It's a bit of a struggle, but you manage to suck [M] into your decompiler. It makes a series of visceral crunching noises.</span>")
			new/obj/effect/decal/cleanable/blood/splatter(get_turf(src))
			qdel(M)
			stored_comms["wood"]++
			stored_comms["wood"]++
			stored_comms["plastic"]++
			stored_comms["plastic"]++
			return

		else if(isdrone(M) && !M.client)

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
		else if(istype(W,/obj/structure/spider/spiderling))
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
