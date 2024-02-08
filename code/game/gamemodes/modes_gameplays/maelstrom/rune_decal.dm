var/global/list/teleporting_runes = list()

ADD_TO_GLOBAL_LIST(/obj/effect/decal/cleanable/crayon/maelstrom, teleporting_runes)
/obj/effect/decal/cleanable/crayon/maelstrom
	var/datum/rune/power
	var/creator_ckey

/obj/effect/decal/cleanable/crayon/maelstrom/atom_init(mapload, mob/user)
	. = ..()
	AddElement(/datum/element/rune_function)
