/obj/machinery/scrap/stacking_machine
	name = "scrap stacking machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	density = 1
	anchored = 1.0
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
		scrap_amount += S.amount
		qdel(S)
		if(scrap_amount >= stack_amt)
			var/obj/item/stack/sheet/NS = new /obj/item/stack/sheet/refined_scrap(src.loc)
			NS.amount = stack_amt
			scrap_amount -= stack_amt
	else
		AM.forceMove(src.loc)

/obj/machinery/scrap/stacking_machine/attack_hand(mob/user)
	if(scrap_amount < 1)
		return
	visible_message("<span class='notice'>\The [src] was forced to release everything inside.</span>")
	var/obj/item/stack/sheet/S = new /obj/item/stack/sheet/refined_scrap(src.loc)
	S.amount = scrap_amount
	scrap_amount = 0
	..()
