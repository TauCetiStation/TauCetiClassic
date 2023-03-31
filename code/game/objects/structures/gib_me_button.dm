/obj/structure/gib_me_button
	name = "GIB ME!!!"
	desc = "GIB... ME!!!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	var/gibbed_amount = 0

/obj/structure/gib_me_button/attack_hand(mob/user)
	user.gib()
	playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER, 20)
	flick("doorctrl1", src)
	gibbed_amount += 1

/obj/structure/gib_me_button/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Fools: [gibbed_amount].</span>")