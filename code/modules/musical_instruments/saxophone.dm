/obj/item/device/harmonica/saxophone
	name = "Saxophone"
	desc = "It's made of copper and covered with shinning gold paint.<br>Jazz4your soul."
	icon = 'code/modules/musical_instruments/Sax.dmi'
	icon_state = "sax"
	item_state = "sax"
	icon_custom = 'code/modules/musical_instruments/Sax.dmi'
	hitsound = 'code/modules/musical_instruments/sound/saxophone/Saxhit.ogg'
	attack_verb = list("tubed", "made concert", "saxed", "smashed")
	cooldown = 150

/obj/item/device/harmonica/saxophone/play(mob/living/carbon/user)
	if(spam_flag)
		return
	spam_flag = 1
	playsound(src, "code/modules/musical_instruments/sound/saxophone/sax[rand(1,6)].ogg", 50, 1, falloff = 5, channel = channel)
	visible_message( pick("[user] plays a bluesy tune with his saxophone!", "[user] plays a sexy tune with his gold thing!", \
			"[user] plays a delightful tune with his music tube!", "[user] plays a chilling tune with his saxy!", "[user] plays a upbeat tune with his saxophone!"))
	addtimer(src,"spam",cooldown)
	return