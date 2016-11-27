/obj/item/weapon/weldpack
	name = "Welding kit"
	desc = "A heavy-duty, portable welding fluid carrier."
	slot_flags = SLOT_BACK
	icon = 'icons/obj/storage.dmi'
	icon_state = "welderpack"
	w_class = 4.0
	var/max_fuel = 350

/obj/item/weapon/weldpack/New()
	var/datum/reagents/R = new/datum/reagents(max_fuel) //Lotsa refills
	reagents = R
	R.my_atom = src
	R.add_reagent("fuel", max_fuel)

/obj/item/weapon/weldpack/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/T = W
		if(T.welding & prob(50))
			message_admins("[key_name_admin(user)] triggered a welding kit explosion. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			log_game("[key_name(user)] triggered a fueltank explosion.")
			to_chat(user, "\red That was stupid of you.")
			explosion(get_turf(src),-1,0,2)
			if(src)
				qdel(src)
			return
		else
			if(T.welding)
				to_chat(user, "\red That was close!")
			src.reagents.trans_to(W, T.max_fuel)
			to_chat(user, "\blue Welder refilled!")
			playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
			return
	to_chat(user, "\blue The tank scoffs at your insolence.  It only provides services to welders.")
	return

/obj/item/weapon/weldpack/afterattack(obj/O, mob/user)
	if (istype(O, /obj/structure/reagent_dispensers/fueltank) && get_dist(src,O) <= 1 && src.reagents.total_volume < max_fuel)
		O.reagents.trans_to(src, max_fuel)
		to_chat(user, "\blue You crack the cap off the top of the pack and fill it back up again from the tank.")
		playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
		return
	else if (istype(O, /obj/structure/reagent_dispensers/fueltank) && get_dist(src,O) <= 1 && src.reagents.total_volume == max_fuel)
		to_chat(user, "\blue The pack is already full!")
		return

/obj/item/weapon/weldpack/examine(mob/user)
	..()
	if(src in user)
		to_chat(user, "[reagents.total_volume] units of fuel left!")
