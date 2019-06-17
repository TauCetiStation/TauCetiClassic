/obj/item/airbag
	name = "personal airbag"
	desc = "One-use protection from high-speed collisions"
	icon = 'icons/obj/items.dmi'
	icon_state = "airbag"
	item_state = "syringe_kit"
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_FLAGS_BELT

/obj/item/airbag/proc/deploy(mob/user)
	user.drop_from_inventory(src, get_turf(src))
	icon_state = "airbag_deployed"
	anchored = TRUE
	user.forceMove(src)
	to_chat(user, "<span class='warning'>Your [src] deploys!</span>")
	playsound(src, 'sound/effects/inflate.ogg', VOL_EFFECTS_MASTER)
	sleep(50)
	for(var/atom/movable/AM in contents)
		AM.forceMove(get_turf(src))
	qdel(src)
