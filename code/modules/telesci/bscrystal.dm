// Bluespace crystals, used in telescience and when crushed it will blink you to a random turf.

/obj/item/bluespace_crystal
	name = "bluespace crystal"
	desc = "A glowing bluespace crystal, not much is known about how they work. It looks very delicate."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "bluespace_crystal"
	w_class = ITEM_SIZE_TINY
	origin_tech = "bluespace=4;materials=3"
	var/blink_range = 8 // The teleport range when crushed/thrown at someone.

/obj/item/bluespace_crystal/atom_init()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/bluespace_crystal/attack_self(mob/user)
	if(blink_mob(user))
		user.drop_item()
		user.visible_message("<span class='notice'>[user] crushes the [src]!</span>")
		qdel(src)

/obj/item/bluespace_crystal/proc/blink_mob(mob/living/L)
	if(istype(L) && !is_centcom_level(L.z))
		do_teleport(L, get_turf(L), blink_range, asoundin = 'sound/effects/phasein.ogg')
		return TRUE
	return FALSE

/obj/item/bluespace_crystal/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(blink_mob(hit_atom))
		qdel(src)

// Artifical bluespace crystal, doesn't give you much research.

/obj/item/bluespace_crystal/artificial
	name = "artificial bluespace crystal"
	desc = "An artificially made bluespace crystal, it looks delicate."
	origin_tech = "bluespace=2"
	blink_range = 4 // Not as good as the organic stuff!
