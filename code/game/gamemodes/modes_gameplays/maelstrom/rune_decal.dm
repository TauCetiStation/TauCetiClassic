/obj/effect/decal/cleanable/crayon/maelstrom
	var/datum/rune/power
	var/creator_ckey

/obj/effect/decal/cleanable/crayon/maelstrom/atom_init(mapload, mob/user)
	. = ..()
	//color = rgb(rand(0,255), rand(0,255), rand(0,255))
	AddElement(/datum/element/rune_function)
