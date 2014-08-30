
/*
Procs Associated with making a gun silenced - RR
Usage: Place the proc within the proc it shares it's name with, silencer_attackby goes in attackby etc.
*/
/obj/item/weapon/silencer
	name = "silencer"
	desc = "A universal small-arms silencer."
	icon = 'icons/obj/gun.dmi'
	icon_state = "silencer"
	w_class = 2
	var/oldsound = 0 //Stores the true sound the gun made before it was silenced

/obj/item/weapon/gun/projectile/proc/silencer_attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/silencer))
		if(user.l_hand != src && user.r_hand != src)
			user << "<span class='warning'>You'll need [src] in your hands to do that.</span>"
			return
		user.drop_item()
		user << "<span class='notice'>You screw [I] onto [src].</span>"
		silenced = I
		var/obj/item/weapon/silencer/S = I
		S.oldsound = fire_sound
		fire_sound = 'tauceti/sounds/weapon/Gunshot_silenced.ogg'
		w_class = 3
		I.loc = src
		update_icon()
		return
	..()

/obj/item/weapon/gun/projectile/proc/silencer_attack_hand(mob/user as mob)
	if(loc == user)
		if(silenced)
			if(user.l_hand != src && user.r_hand != src)
				..()
				return
			user << "<span class='notice'>You unscrew [silenced] from [src].</span>"
			user.put_in_hands(silenced)
			var/obj/item/weapon/silencer/S = silenced
			fire_sound = S.oldsound
			silenced = 0
			w_class = 2
			update_icon()
			return
	..()