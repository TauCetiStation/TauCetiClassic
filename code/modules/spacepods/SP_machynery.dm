/obj/machinery/spacepod_machinery
	name = "Space Pod Machinery"
	desc = "This is special class mashinery for space pod. Don't watch on this"
	icon = null
	icon_state = null
	density = TRUE
	anchored = TRUE

/obj/machinery/spacepod_machinery/keylockergen
	name = "Key Locker Generator"
	desc = "A Key Locker Generator(KLG) generated difficult electromagnetic ray for generated and programmin key locker's module. Use KLG for generated key locker."
	icon = 'icons/obj/machines/pdapainter.dmi'
	icon_state = "pdapainter"
	var/obj/item/spacepod_equipment/lock/keyed/keyedstore = null
	var/list/operating_list = list()

/obj/machinery/spacepod_machinery/keylockergen/atom_init()
	.=..()
	operating_list.Add("Generate Special ID")
	operating_list.Add("Set Special ID")
	operating_list.Add("Terminated Key Locker")

/obj/machinery/spacepod_machinery/keylockergen/update_icon()
	overlays.Cut()

	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		return

	if(keyedstore)
		overlays += "[initial(icon_state)]-closed"

	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

	return

/obj/machinery/spacepod_machinery/keylockergen/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/spacepod_equipment/lock/keyed))
		if(keyedstore)
			to_chat(user, "There is already a key locker inside.")
			return
		else
			var/obj/item/spacepod_equipment/lock/keyed/K = usr.get_active_hand()
			if(istype(K))
				user.drop_item()
				keyedstore = K
				K.loc = src
				K.add_fingerprint(usr)
				update_icon()
	else
		if(istype(O, /obj/item/weapon/wrench))
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			anchored = !anchored
			to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")


/obj/machinery/spacepod_machinery/keylockergen/attack_hand(mob/user)
	if(..())
		return 1

	if(keyedstore)
		var/obj/item/spacepod_equipment/lock/keyed/K
		K = input(user, "Please, select operating!", "KL Generator") as null|anything in operating_list
		if(!K)
			return
		switch(K)
			if("Generate Special ID")
				keyedstore.id = rand(1,999999)
				to_chat(user, "<span class='notice'>The number [keyedstore.id] was successfully generated</span>")
				return
			if("Set Special ID")
				var/set_id = round(input(user, "What ID you want set for this [keyedstore.name]?", "Set ID Key Locker") as num)
				if(set_id)
					keyedstore.id = set_id
					to_chat(user, "<span class='notice'>You set [set_id] ID for [keyedstore.name]. Check this</span>")
				else if(!set_id)
					to_chat(user, "This set ID empty")
			if("Terminated Key Locker")
				to_chat(user, "<span class='warning'> Oh my, you terminated [keyedstore.name]. Now it is not suitable for use.</span>")
				keyedstore.id = null
				keyedstore.terminated = TRUE
				keyedstore.name += "(TERMINATED)"
				keyedstore.color = "#a72828"
				return

	else
		to_chat(user, "<span class='notice'>The [src] is empty.</span>")


/obj/machinery/spacepod_machinery/keylockergen/verb/ejectkeylocker()
	set name = "Eject Key Locker"
	set category = "Object"
	set src in oview(1)
	if(!usr.canmove || usr.stat || usr.restrained())
		return

	if(keyedstore)
		keyedstore.loc = get_turf(src.loc)
		keyedstore = null
		update_icon()
	else
		to_chat(usr, "<span class='notice'>The [src] is empty.</span>")


/obj/machinery/spacepod_machinery/keylockergen/power_change()
	..()
	update_icon()