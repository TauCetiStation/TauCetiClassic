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
	last_played = world.time + cooldown
	playsound(src, "sound/musical_instruments/harmonica/fharp[rand(1, 8)].ogg", 50, 1, falloff = 5, channel = channel)
	var/message = pick(
		"[user] plays a bluesy tune with his harmonica!",
		"[user] plays a warm tune with his harmonica!",
		"[user] plays a delightful tune with his harmonica!",
		"[user] plays a chilling tune with his harmonica!",
		"[user] plays a upbeat tune with his harmonica!")
	user.visible_message("<span class='notice'>[message]</span>")

/obj/item/device/harmonica/dropped(mob/user)
	var/sound/melody = sound()
	melody.channel = channel
	hearers(20, get_turf(src)) << melody
	return ..()
