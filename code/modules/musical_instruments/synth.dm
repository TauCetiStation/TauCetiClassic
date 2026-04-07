/obj/item/device/synth
	name = "synth"
	desc = "It's a synth! Pick your poison."

	icon = 'icons/obj/musician.dmi'
	icon_state = "synth"
	item_state = "synth"

	hitsound = list('sound/musical_instruments/synth/1hit.ogg')
	force = 10
	attack_verb = list("played metal", "made concert", "crashed", "smashed", "rocked the world")

	var/datum/music_player/MP = null

	var/static/list/available_soundpaths = list(
		"Default" = "sound/musical_instruments/synth/default",
		"Cyber" = "sound/musical_instruments/synth/cyber",
		"Groove" = "sound/musical_instruments/synth/groove",
		"Reverse" = "sound/musical_instruments/synth/reverse",
		"Robot" = "sound/musical_instruments/synth/robot",
		"Space" = "sound/musical_instruments/synth/space",
	)
	var/static/list/available_name_by_soundpath = list(
		"sound/musical_instruments/synth/default" = "Default",
		"sound/musical_instruments/synth/cyber" = "Cyber",
		"sound/musical_instruments/synth/groove" = "Groove",
		"sound/musical_instruments/synth/reverse" = "Reverse",
		"sound/musical_instruments/synth/robot" = "Robot",
		"sound/musical_instruments/synth/space" = "Space",
	)

/obj/item/device/synth/atom_init()
	. = ..()

	var/soundpath_name = pick(available_soundpaths)

	MP = new(
		src,
		available_soundpaths[soundpath_name],
	)

/obj/item/device/synth/Destroy()
	QDEL_NULL(MP)
	return ..()

/obj/item/device/synth/unable_to_play(mob/living/user)
	return ..() || loc != user

/obj/item/device/synth/attack_self(mob/living/user)
	MP.interact(user)

/obj/item/device/synth/examine(mob/user)
	. = ..()
	var/synth_tool = available_name_by_soundpath[MP.sound_path]
	if(synth_tool)
		to_chat(user, "<span class='notice'>Currently synthesizing: [synth_tool].</span>")

/obj/item/device/synth/AltClick(mob/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't know what to do with this.</span>")
		return

	var/choice = input(user, "Choose an instrument to synthesize.", "Instrument Selection") as null|anything in available_soundpaths
	if(!choice)
		return

	if(user.incapacitated() || !Adjacent(user))
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't know what to do with this.</span>")
		return

	to_chat(user, "<span class='notice'>Synthesizing [choice].</span>")
	MP.sound_path = available_soundpaths[choice]
