/obj/item/device/harmonica
	name = "harmonica"
	desc = "Much blues. So amaze. Wow."
	icon = 'code/modules/musical_instruments/harmonica.dmi'
	icon_state = "harmonica"
	item_state = "harmonica"
	force = 5
	m_amt = 500
	var/channel
	var/spam_flag = 0
	var/cooldown = 70

/obj/item/device/harmonica/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M) || M != user)
		return ..()
	if(user.zone_sel.selecting == "mouth")
		play(user)


/obj/item/device/harmonica/New()
	channel = rand(1000, 1024)

/obj/item/device/harmonica/proc/play(mob/living/carbon/user)
	if(spam_flag)
		return
	spam_flag = 1
	playsound(src, "code/modules/musical_instruments/sound/harmonica/fharp[rand(1,8)].ogg", 50, 1, falloff = 5, channel = channel)
	visible_message( pick("[user] plays a bluesy tune with his harmonica!", "[user] plays a warm tune with his harmonica!", \
		"[user] plays a delightful tune with his harmonica!", "[user] plays a chilling tune with his harmonica!", "[user] plays a upbeat tune with his harmonica!"))
	addtimer(src,"spam",cooldown)
	return

/obj/item/device/harmonica/dropped(mob/user)
	var/sound/melody = sound()
	melody.channel = channel
	hearers(20, get_turf(src)) << melody
	spam_flag = 0
	return ..()

/obj/item/device/harmonica/proc/spam()
	spam_flag = 0
