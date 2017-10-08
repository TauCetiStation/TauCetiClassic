/obj/item/device/violin
	name = "space violin"
	desc = "A wooden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon = 'icons/obj/musician.dmi'
	icon_state = "violin"
	item_state = "violin"
	force = 10

	var/datum/music_player/MP = null

/obj/item/device/violin/atom_init()
	. = ..()
	MP = new(src, "sound/musical_instruments/violin")

/obj/item/device/violin/Destroy()
	QDEL_NULL(MP)
	return ..()

/obj/item/device/violin/unable_to_play(mob/living/user)
	return ..() || loc != user

/obj/item/device/violin/attack_self(mob/living/user)
	MP.interact(user)
