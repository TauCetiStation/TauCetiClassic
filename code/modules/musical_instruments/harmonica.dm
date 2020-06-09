/obj/item/device/harmonica
	name = "harmonica"
	desc = "Much blues. So amaze. Wow."
	icon = 'icons/obj/musician.dmi'
	icon_state = "harmonica"
	item_state = "harmonica"
	force = 5
	w_class = ITEM_SIZE_SMALL
	m_amt = 500
	var/channel
	var/cooldown = 70
	var/last_played = 0

/obj/item/device/harmonica/attack(mob/living/carbon/M, mob/living/carbon/user, def_zone)
	if(!istype(M) || M != user)
		return ..()
	if(def_zone == O_MOUTH && last_played <= world.time)
		play(user)

/obj/item/device/harmonica/atom_init()
	. = ..()
	channel = rand(1000, 1024)

/obj/item/device/harmonica/proc/play(mob/living/carbon/user)
	var/static/list/tunes = list(
		'sound/musical_instruments/harmonica/fharp1.ogg',
		'sound/musical_instruments/harmonica/fharp2.ogg',
		'sound/musical_instruments/harmonica/fharp3.ogg',
		'sound/musical_instruments/harmonica/fharp4.ogg',
		'sound/musical_instruments/harmonica/fharp5.ogg',
		'sound/musical_instruments/harmonica/fharp6.ogg',
		'sound/musical_instruments/harmonica/fharp7.ogg',
		'sound/musical_instruments/harmonica/fharp8.ogg'
		)
	var/static/list/message = list(
		"plays a bluesy",
		"plays a warm",
		"plays a delightful",
		"plays a chilling",
		"plays a upbeat"
		)
	last_played = world.time + cooldown
	playsound(src, pick(tunes), VOL_EFFECTS_INSTRUMENT, null, FALSE, falloff = 5, channel = channel)
	user.visible_message("<span class='notice'>[user] [pick(message)] tune with his harmonica!</span>")

/obj/item/device/harmonica/dropped(mob/user)
	var/sound/melody = sound()
	melody.channel = channel
	hearers(20, get_turf(src)) << melody
	return ..()
