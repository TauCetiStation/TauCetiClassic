var/global/list/maelstrom_teleporting_runes = list()

ADD_TO_GLOBAL_LIST(/obj/effect/decal/cleanable/crayon/maelstrom, maelstrom_teleporting_runes)
/obj/effect/decal/cleanable/crayon/maelstrom
	var/datum/rune/power
	var/creator_ckey

/obj/effect/decal/cleanable/crayon/maelstrom/atom_init(mapload, mob/user)
	. = ..()
	AddElement(/datum/element/rune_function)
