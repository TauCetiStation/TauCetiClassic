//burn after reading

/obj/item/device/flashlight/lamp/fir
	name = "xmas tree"
	
	icon = 'tauceti/items/furtree/furtree.dmi'
	desc = "Goodbye, happy holidays..."
	icon_state = "tree"
	brightness_on = 5
	anchored = 1
	layer = 4.1

/obj/item/device/flashlight/lamp/fir/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))	//unwrenching vendomats
		var/turf/T = user.loc
		user << "<span class='notice'>You begin [anchored ? "unwrenching" : "wrenching"] the [src].</span>"
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		sleep(40)
		//if( !istype(src, /obj/machinery/vending) || !user || !W || !T )	return
		if( user.loc == T && user.get_active_hand() == W )
			anchored = !anchored
			user << "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>"

/obj/item/device/flashlight/lamp/fir/attack_hand(mob/user as mob)
	return