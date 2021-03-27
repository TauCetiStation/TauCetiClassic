
/*
Procs Associated with making a gun silenced - RR
Usage: Place the proc within the proc it shares it's name with, silencer_attackby goes in attackby etc.
*/
/obj/item/weapon/silencer
	name = "silencer"
	desc = "A universal small-arms silencer."
	icon = 'icons/obj/gun.dmi'
	icon_state = "silencer"
	w_class = ITEM_SIZE_SMALL
	var/oldsound = 0 //Stores the true sound the gun made before it was silenced

/obj/item/weapon/gun/projectile/proc/silencer_attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/silencer))
		if(user.l_hand != src && user.r_hand != src)
			to_chat(user, "<span class='warning'>You'll need [src] in your hands to do that.</span>")
			return
		user.drop_item()
		to_chat(user, "<span class='notice'>You screw [I] onto [src].</span>")
		silenced = I
		var/obj/item/weapon/silencer/S = I
		S.oldsound = fire_sound
		fire_sound = 'sound/weapons/guns/gunshot_silencer.ogg'
		w_class = ITEM_SIZE_NORMAL
		I.loc = src
		update_icon()
		return

/obj/item/weapon/gun/projectile/proc/silencer_attack_hand(mob/user)
	if(loc == user)
		if(silenced)
			if(user.l_hand != src && user.r_hand != src)
				return
			to_chat(user, "<span class='notice'>You unscrew [silenced] from [src].</span>")
			user.put_in_hands(silenced)
			var/obj/item/weapon/silencer/S = silenced
			fire_sound = S.oldsound
			silenced = 0
			w_class = ITEM_SIZE_SMALL
			update_icon()
			return
