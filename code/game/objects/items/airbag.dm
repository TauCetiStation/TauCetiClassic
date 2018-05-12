/obj/item/airbag
	name = "personal airbag"
	desc = "One-use protection from high-speed collisions"
	icon = 'icons/obj/items.dmi'
	icon_state = "airbag"
	item_state = "syringe_kit"
	w_class = 2.0
	slot_flags = SLOT_BELT

/obj/item/airbag/proc/deploy(mob/user)
	user.drop_from_inventory(src, get_turf(src))
	icon_state = "airbag_deployed"
	anchored = TRUE
	user.forceMove(src)
	to_chat(user, "<span class='warning'>Your [src.name] deploys!</span>")
	playsound(src, 'sound/effects/inflate.ogg', 100, 1)
	sleep(50)
	for(var/atom/movable/AM in contents)
		AM.forceMove(get_turf(src))
	qdel(src)