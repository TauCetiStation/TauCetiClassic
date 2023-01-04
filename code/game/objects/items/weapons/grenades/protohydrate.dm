/obj/item/weapon/solid_phydr
	name = "Solid proto-hydrate"
	desc = "Big chunk of exotic substance created from proto-hydrate under huge pressure and temperature. Highly explosive."
	icon = 'icons/obj/atmos.dmi'
	icon_state = "solid_phydr-na"
	origin_tech = "materials=4;phorontech=1"
	w_class = SIZE_NORMAL
	var/reactionTimer = null

/obj/item/weapon/solid_phydr/update_icon()
	icon_state = "solid_phydr" + (reactionTimer ? "-a" : "-na")

/obj/item/weapon/solid_phydr/attack_self(mob/user)
	if(reactionTimer)
		return
	to_chat(user, "<span class='notice'>You apply force to [src], triggering chain reaction inside it!</span>")
	trigger()

/obj/item/weapon/solid_phydr/attackby(obj/item/weapon/W, mob/user)
	if(reactionTimer)
		return
	if(W.get_current_temperature() > 300)
		to_chat(user, "<span class='notice'>You heat [src], triggering chain reaction inside it!</span>")
		trigger()

/obj/item/weapon/solid_phydr/proc/trigger()
	reactionTimer = addtimer(CALLBACK(src, .proc/react), rand(50, 100), TIMER_STOPPABLE)
	update_icon()

/obj/item/weapon/solid_phydr/proc/react()
	explosion(loc, 2, 4, 6, 8)
	qdel(src)
