/obj/effect/decal/cleanable/crayon/gang
	name = "Leet Like Jeff K gang tag"
	desc = "Looks like someone's claimed this area for Leet Like Jeff K."
	icon = 'icons/obj/gang/tags.dmi'
	layer = BELOW_MOB_LAYER
	default_state = FALSE
	var/datum/faction/gang/my_gang

/obj/effect/decal/cleanable/crayon/gang/Destroy()
	my_gang.gang_tags -= src
	return ..()
