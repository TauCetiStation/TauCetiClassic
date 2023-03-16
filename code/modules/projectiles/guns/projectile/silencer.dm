
/*
Procs Associated with making a gun silenced - RR
Usage: Place the proc within the proc it shares it's name with, silencer_attackby goes in attackby etc.
*/
/obj/item/weapon/silencer
	name = "silencer"
	desc = "A universal small-arms silencer."
	icon = 'icons/obj/gun.dmi'
	icon_state = "silencer"
	w_class = SIZE_TINY

/obj/item/weapon/gun/projectile/automatic/proc/install_silencer(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/silencer))
		if(user.l_hand != src && user.r_hand != src)
			to_chat(user, "<span class='warning'>You'll need [src] in your hands to do that.</span>")
			return
		if(!src.can_be_silenced)
			to_chat(user, "<span class='warning'>[src] can't be silenced.</span>")
			return
		user.drop_from_inventory(I, src)
		to_chat(user, "<span class='notice'>You screw [I] onto [src].</span>")
		silenced = I
		fire_sound = 'sound/weapons/guns/gunshot_silencer.ogg'
		w_class = max(w_class, SIZE_SMALL) //silencer makes tiny weapons bigger, but doesn't make any difference for bigger ones
		update_icon()
		return

/obj/item/weapon/gun/projectile/proc/remove_silencer(mob/user)
	if(loc == user)
		if(silenced)
			if(user.l_hand != src && user.r_hand != src)
				return FALSE
			to_chat(user, "<span class='notice'>You unscrew [silenced] from [src].</span>")
			user.put_in_hands(silenced)
			fire_sound = initial(fire_sound)
			silenced = FALSE
			w_class = initial(w_class)
			update_icon()
			return TRUE
