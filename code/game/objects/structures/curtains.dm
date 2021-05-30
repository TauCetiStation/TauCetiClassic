/obj/structure/curtain
	name = "curtain"
	icon = 'icons/obj/curtain.dmi'
	icon_state = "closed"
	layer = INFRONT_MOB_LAYER
	opacity = TRUE
	density = FALSE

/obj/structure/curtain/open
	icon_state = "open"
	opacity = FALSE

/obj/structure/curtain/bullet_act(obj/item/projectile/P, def_zone)
	if(!P.nodamage)
		visible_message("<span class='warning'>[P] tears [src] down!</span>")
		qdel(src)
	else
		..(P, def_zone)

/obj/structure/curtain/attack_hand(mob/user)
	playsound(src, 'sound/effects/curtain.ogg', VOL_EFFECTS_MASTER, 15, null, -5)
	toggle()
	..()

/obj/structure/curtain/proc/toggle()
	set_opacity(!opacity)
	if(opacity)
		icon_state = "closed"
	else
		icon_state = "open"

/obj/structure/curtain/black
	name = "black curtain"
	color = "#222222"

/obj/structure/curtain/medical
	name = "plastic curtain"
	color = "#b8f5e3"
	alpha = 200

/obj/structure/curtain/open/bed
	name = "bed curtain"
	color = "#854636"

/obj/structure/curtain/open/privacy
	name = "privacy curtain"
	color = "#b8f5e3"

/obj/structure/curtain/open/shower
	name = "shower curtain"
	color = "#acd1e9"
	alpha = 200

/obj/structure/curtain/open/shower/engineering
	color = "#ffa500"

/obj/structure/curtain/open/shower/security
	color = "#aa0000"
