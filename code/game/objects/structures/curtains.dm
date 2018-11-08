/obj/structure/curtain
	name = "curtain"
	icon = 'icons/obj/curtain.dmi'
	icon_state = "closed"
	layer = INFRONT_MOB_LAYER
	opacity = TRUE
	density = FALSE
	anchored = TRUE
	var/processing_wrench

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
	playsound(get_turf(loc), 'sound/effects/curtain.ogg', 15, 1, -5)
	toggle()
	..()

/obj/structure/curtain/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench) && !processing_wrench)
		processing_wrench = 1
		if(do_after(user, 20, target = src))
			anchored = !anchored
			to_chat(user, "<span class='notice'>You [anchored ? "attach" : "detach"] the [src] [anchored ? "to" : "from"] the ground</span>")
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			processing_wrench = 0
		else
			processing_wrench = 0
			return
	else
		return ..()

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

//BLINDS//
//white ones
/obj/structure/curtain/blinds
	name = "plastic blinds"
	desc = "Who's that peekin' though the blinds?"
	icon = 'icons/obj/blinds/blinds_plastic.dmi'
	icon_state = "closed"
	var/chain_of_icon_update = 0

/obj/structure/curtain/blinds/atom_init()
	. = ..()
	icon_update()
	for(var/obj/structure/curtain/blinds/B in range (2, src))
		B.icon_update()

/obj/structure/curtain/blinds/proc/icon_update()
	if(chain_of_icon_update == 1)
		for(var/obj/structure/curtain/blinds/B in range (2, src))
			if(B != src)
				B.chain_of_icon_update = 1
				B.set_opacity(src.opacity)
				B.icon_update()
				if(B.opacity)//Are they closed?
					B.verbs +=/obj/structure/curtain/blinds/verb/peek
				else
					B.verbs -=/obj/structure/curtain/blinds/verb/peek
		chain_of_icon_update = 0
	if((icon_state == "closed_right_peekin") || (icon_state == "closed_peekin") || (icon_state == "closed") || (icon_state == "opened") || (icon_state == "left_closed") || (icon_state == "left_opened"))
		verbs += verb/toggle_blinds
	else
		verbs -= verb/toggle_blinds
	var/position
	var/isitopened
	if(opacity)//Are they closed?
		isitopened = "closed"
	else
		isitopened = "opened"
	if(locate(/obj/structure/curtain/blinds, get_step(src, WEST)))
		position = "_right"
	if(locate(/obj/structure/curtain/blinds, get_step(src, EAST)))
		position = "_left"
	if((locate(/obj/structure/curtain/blinds, get_step(src, SOUTH))) || ( locate(/obj/structure/curtain/blinds, get_step(src, EAST)) && locate(/obj/structure/curtain/blinds, get_step(src, WEST))))
		position = "_center"
	icon_state = "[isitopened][position]"



/obj/structure/curtain/blinds/verb/toggle_blinds()
	set name = "Toggle"
	set desc = ""
	set category = "Object"
	set src in oview(1)
	if((icon_state == "closed_right_peekin") || (icon_state == "closed_peekin") || (icon_state == "closed") || (icon_state == "opened") || (icon_state == "left_closed") || (icon_state == "left_opened"))
		set_opacity(!opacity)
		playsound(get_turf(loc), 'sound/effects/curtain.ogg', 15, 1, -5)
		icon_update()
		for(var/obj/structure/curtain/blinds/B in range (2, src))
			if(B != src)
				B.chain_of_icon_update = 1
				B.set_opacity(src.opacity)
				B.icon_update()
				if(B.opacity)//Are they closed?
					B.verbs +=/obj/structure/curtain/blinds/verb/peek
				else
					B.verbs -=/obj/structure/curtain/blinds/verb/peek
		if(opacity)//Are they closed?
			verbs +=/obj/structure/curtain/blinds/verb/peek
		else
			verbs -=/obj/structure/curtain/blinds/verb/peek
	return

/obj/structure/curtain/blinds/verb/peek()
	set name = "Peek through"
	set desc = "The occupation of the real detective"
	set category = "Object"
	set src in oview(1)
	usr.visible_message("<span class='notice'>[usr] peeks through \the [src]...</span>")
	if((icon_state == "closed") || (icon_state == "center_closed") || (icon_state == "left_closed") || (icon_state == "right_closed"))
		icon_state = "[icon_state]_peekin"
		opacity = FALSE
	return

/obj/structure/curtain/blinds/attackby(obj/item/weapon/W, mob/user)
	.=..()
	icon_update()
	for(var/obj/structure/curtain/blinds/B in range (2, src))
		B.icon_update()

//Wooden blinds//
/obj/structure/curtain/blinds/wooden
	name = "wooden blinds"
	desc = "Who's that peekin' though the blinds?"
	icon = 'icons/obj/blinds/blinds_wooden.dmi'

