/obj/item/device/saxophone
	name = "Saxophone"
	desc = "It's made of copper and covered with shinning gold paint.<br>Jazz4your soul."
	icon = 'code/modules/musical_instruments/Sax.dmi'
	icon_state = "sax"
	item_state = "sax"
	icon_custom = 'code/modules/musical_instruments/Sax.dmi'
	hitsound = 'code/modules/musical_instruments/sound/sax/Saxhit.ogg'
	force = 10
	m_amt = 500
	attack_verb = list("tubed", "made concert", "saxed", "smashed")
	var/saxophone_channel
	var/spam_flag = 0
	var/cooldown = 150

/obj/item/device/saxophone/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M) || M != user)
		return ..()

	if(user.zone_sel.selecting == "mouth")
		play(user)


/obj/item/device/saxophone/New()
	saxophone_channel = rand(1000, 1024)

/obj/item/device/saxophone/proc/play(mob/living/carbon/user)
	if(spam_flag) return

	spam_flag = 1

	var/melody = file("code/modules/musical_instruments/sound/sax/sax[rand(1,6)].ogg")

	var/turf/source = get_turf(src)
	for(var/mob/M in hearers(15, source))
		M.playsound_local(source, melody, 50, 1, falloff = 5, channel = saxophone_channel)
		to_chat(M, pick("[user] plays a bluesy tune with his saxophone!", "[user] plays a sexy tune with his gold thing!", \
		"[user] plays a delightful tune with his music tube!", "[user] plays a chilling tune with his saxy!", "[user] plays a upbeat tune with his saxophone!"))//Thanks Goonstation.

	spawn(cooldown)
		spam_flag = 0

	return

/obj/item/device/saxophone/dropped(mob/user)

	var/sound/melody = sound()
	melody.channel = saxophone_channel
	to_chat(hearers(20, get_turf(src)), melody)

	spam_flag = 0

	return ..()
