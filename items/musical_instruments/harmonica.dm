/obj/item/device/harmonica
	name = "harmonica"
	desc = "Much blues. Wow"
	icon = 'tauceti/items/musical_instruments/harmonica.dmi'
	icon_state = "harmonica"
	item_state = "harmonica"
	force = 5
	var/channel
	var/spam_flag = 0
	var/cooldown = 70

/obj/item/device/harmonica/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M) || M != user)
		return ..()

	if(user.zone_sel.selecting == "mouth")
		play(user)


/obj/item/device/harmonica/New()
	channel = rand(1000, 1024)

/obj/item/device/harmonica/proc/play(mob/living/carbon/user as mob)
	if(spam_flag) return

	spam_flag = 1

	var/sound/melody = sound(file("tauceti/items/musical_instruments/sound/harmonica/fharp[rand(1,8)].ogg"))

	melody.wait = 0 //No queue
	melody.channel = channel
	melody.volume = 50
	melody.frequency = rand(32000, 55000)

	hearers(15, get_turf(src)) << melody
	hearers(15, get_turf(src)) << pick("[user] plays a bluesy tune with his harmonica!", "[user] plays a cool melody with his harmonica!", \
		"[user] plays a delightful tune with his harmonica!", "[user]  plays a chilling tune with his harmonica!", "[user] plays a upbeat tune with his harmonica!")//Thanks Goonstation.

	spawn(cooldown)
		spam_flag = 0

	return

/obj/item/device/harmonica/dropped(mob/user)

	var/sound/melody = null
	melody.channel = channel
	hearers(20, get_turf(src)) << melody

	spam_flag = 0

	return