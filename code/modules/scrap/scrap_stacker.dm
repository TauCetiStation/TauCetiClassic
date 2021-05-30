/obj/machinery/scrap/stacking_machine
	name = "scrap stacking machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/list/stack_storage[0]
	var/list/stack_paths[0]
	var/scrap_amount = 0
	var/stack_amt = 20 // Amount to stack before releassing

/obj/machinery/scrap/stacking_machine/Bumped(atom/movable/AM)
	if(stat & (BROKEN|NOPOWER))
		return
	if(istype(AM, /mob/living))
		return
	if(istype(AM, /obj/item/stack/sheet/refined_scrap))
		var/obj/item/stack/sheet/refined_scrap/S = AM
		scrap_amount += S.get_amount()
		qdel(S)
		if(scrap_amount >= stack_amt)
			new /obj/item/stack/sheet/refined_scrap(loc, stack_amt)
			scrap_amount -= stack_amt
	else
		AM.forceMove(loc)

/obj/machinery/scrap/stacking_machine/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(scrap_amount < 1)
		return 1
	user.SetNextMove(CLICK_CD_INTERACT)
	visible_message("<span class='notice'>\The [src] was forced to release everything inside.</span>")
	new /obj/item/stack/sheet/refined_scrap(loc, scrap_amount)
	scrap_amount = 0
