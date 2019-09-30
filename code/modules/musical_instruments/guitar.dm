/obj/item/device/guitar
	name = "guitar"
	desc = "It's made of wood and has steel strings.<br>The leather belt is folded behind it and the letters J.C. are engraved on the headstock."
	icon = 'icons/obj/musician.dmi'
	icon_state = "guitar"
	item_state = "guitar"
	hitsound = list('sound/musical_instruments/guitar/1hit.ogg')
	force = 10
	attack_verb = list("played metal", "made concert", "crashed", "smashed")

	var/datum/music_player/MP = null
	var/sound_path = "sound/musical_instruments/guitar"

/obj/item/device/guitar/atom_init()
	. = ..()
	MP = new(src, sound_path)

/obj/item/device/guitar/Destroy()
	QDEL_NULL(MP)
	return ..()

/obj/item/device/guitar/unable_to_play(mob/living/user)
	return ..() || loc != user

/obj/item/device/guitar/attack_self(mob/living/user)
	MP.interact(user)

/obj/item/device/guitar/electric
	name = "electric guitar"
	desc = "Space Rock'n'Roll"
	icon_state = "eguitar"
	item_state = "eguitar"

	sound_path = "sound/musical_instruments/eguitar"
