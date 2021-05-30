//burn after reading

/obj/item/device/flashlight/lamp/fir
	name = "xmas tree"

	icon = 'icons/obj/furtree.dmi'
	desc = "Goodbye, happy holidays..."
	icon_state = "tree"
	brightness_on = 5
	anchored = 1
	layer = 4.1

/obj/item/device/flashlight/lamp/fir/attackby(obj/item/I, mob/user, params)
	if(iswrench(I))	//unwrenching vendomats
		to_chat(user, "<span class='notice'>You begin [anchored ? "unwrenching" : "wrenching"] the [src].</span>")
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		if(!user.is_busy() && do_after(user, 4 SECONDS, target = src))
			anchored = !anchored
			to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
	else
		return ..()

/obj/item/device/flashlight/lamp/fir/attack_hand(mob/user)
	return
