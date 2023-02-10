/obj/machinery/pdapainter
	name = "PDA painter"
	desc = "A PDA painting machine. To use, simply insert your PDA and choose the desired preset paint scheme."
	icon = 'icons/obj/machines/pdapainter.dmi'
	icon_state = "pdapainter"
	density = TRUE
	anchored = TRUE
	var/obj/item/device/pda/storedpda = null
	var/list/radial_chooses
	var/blocked

/obj/machinery/pdapainter/update_icon()
	cut_overlays()

	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		return

	if(storedpda)
		add_overlay("[initial(icon_state)]-closed")

	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

	return

/obj/machinery/pdapainter/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/device/pda))
		if(storedpda)
			to_chat(user, "There is already a PDA inside.")
			return
		else
			var/obj/item/device/pda/P = usr.get_active_hand()
			if(istype(P))
				user.drop_from_inventory(P, src)
				storedpda = P
				P.add_fingerprint(usr)
				update_icon()
	else
		if(iswrench(O))
			playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
			anchored = !anchored
			to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")


/obj/machinery/pdapainter/attack_hand(mob/user)
	if(..())
		return 1

	if(storedpda)
		if(!blocked)
			blocked = list(
				/obj/item/device/pda/silicon/pai,
				/obj/item/device/pda/silicon,
				/obj/item/device/pda/silicon/robot,
				/obj/item/device/pda/heads,
				/obj/item/device/pda/clear,
				/obj/item/device/pda/syndicate
				)

		if(!radial_chooses)
			radial_chooses = list()
			for(var/P in typesof(/obj/item/device/pda)-blocked)
				var/obj/item/device/pda/D = new P
				radial_chooses[D] = image(icon = D.icon, icon_state = D.icon_state)

		var/obj/item/device/pda/P = show_radial_menu(user, src, radial_chooses, require_near = TRUE)
		if(!P)
			return

		storedpda.icon = 'icons/obj/pda.dmi'
		storedpda.icon_state = P.icon_state
		storedpda.desc = P.desc

	else
		to_chat(user, "<span class='notice'>The [src] is empty.</span>")


/obj/machinery/pdapainter/verb/ejectpda()
	set name = "Eject PDA"
	set category = "Object"
	set src in oview(1)
	if(usr.incapacitated())
		return

	if(storedpda)
		storedpda.loc = get_turf(src.loc)
		storedpda = null
		update_icon()
	else
		to_chat(usr, "<span class='notice'>The [src] is empty.</span>")


/obj/machinery/pdapainter/power_change()
	..()
	update_icon()
