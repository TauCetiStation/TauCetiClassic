/obj/structure/gib_me_button
	name = "GIB ME!!!"
	desc = "GIB... ME!!!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"

/obj/structure/gib_me_button/attack_hand(mob/user)
	user.gib()
	playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER, 20)
	flick("doorctrl1", src)
