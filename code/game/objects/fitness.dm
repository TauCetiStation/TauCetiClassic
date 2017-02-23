/obj/structure/stacklifter
	name = "Weight Machine"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/obj/fitness.dmi'
	icon_state = "fitnesslifter"
	density = 1
	anchored = 1

/obj/structure/stacklifter/attack_hand(mob/user)
	var/mob/living/carbon/human/gymnast = user

	if(in_use)
		to_chat(user, "It's already in use - wait a bit.")
		return
	if(gymnast.halloss > 80 || gymnast.shock_stage > 80)
		to_chat(user, "You are too exausted.")
		return
	else
		in_use = 1
		icon_state = "fitnesslifter2"
		user.set_dir(SOUTH)
		user.Stun(4)
		user.loc = src.loc
		var/bragmessage = pick("pushing it to the limit","going into overdrive","burning with determination","rising up to the challenge", "getting strong now","getting ripped")
		user.visible_message("<B>[user] is [bragmessage]!</B>")
		var/lifts = 0
		while (lifts++ < 6)
			if (user.loc != src.loc)
				break
			sleep(3)
			animate(user, pixel_y = -2, time = 3)
			sleep(3)
			animate(user, pixel_y = -4, time = 3)
			sleep(3)
			playsound(user, 'sound/machines/spring.ogg', 60, 1)
		playsound(user, 'sound/machines/click.ogg', 60, 1)
		in_use = 0
		user.pixel_y = 0
		gymnast.nutrition -= 6
		gymnast.overeatduration -= 8
		gymnast.apply_effect(15,AGONY,0)
		var/finishmessage = pick("You feel stronger!","You feel like you can take on the world!","You feel robust!","You feel indestructible!")
		icon_state = "fitnesslifter"
		to_chat(user, "[finishmessage]")

/obj/structure/weightlifter
	name = "Weight Machine"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/obj/fitness.dmi'
	icon_state = "fitnessweight"
	density = 1
	anchored = 1

/obj/structure/weightlifter/attack_hand(mob/user)
	var/mob/living/carbon/human/gymnast = user

	if(in_use)
		to_chat(user, "It's already in use - wait a bit.")
		return
	if(gymnast.halloss > 80 || gymnast.shock_stage > 80)
		to_chat(user, "You are too exausted.")
		return
	else
		in_use = 1
		icon_state = "fitnessweight-c"
		user.set_dir(SOUTH)
		user.Stun(4)
		user.loc = src.loc
		var/image/W = image('icons/obj/fitness.dmi',"fitnessweight-w")
		W.layer = MOB_LAYER + 1
		overlays += W
		var/bragmessage = pick("pushing it to the limit","going into overdrive","burning with determination","rising up to the challenge", "getting strong now","getting ripped")
		user.visible_message("<B>[user] is [bragmessage]!</B>")
		var/reps = 0
		user.pixel_y = 5
		while (reps++ < 6)
			if (user.loc != src.loc)
				break

			for (var/innerReps = max(reps, 1), innerReps > 0, innerReps--)
				sleep(3)
				animate(user, pixel_y = (user.pixel_y == 3) ? 5 : 3, time = 3)

			playsound(user, 'sound/machines/spring.ogg', 60, 1)

		sleep(3)
		animate(user, pixel_y = 2, time = 3)
		sleep(3)
		playsound(user, 'sound/machines/click.ogg', 60, 1)
		in_use = 0
		animate(user, pixel_y = 0, time = 3)
		gymnast.nutrition -= 12
		gymnast.overeatduration -= 16
		gymnast.apply_effect(25,AGONY,0)
		var/finishmessage = pick("You feel stronger!","You feel like you can take on the world!","You feel robust!","You feel indestructible!")
		icon_state = "fitnessweight"
		overlays -= W

		to_chat(user, "[finishmessage]")
