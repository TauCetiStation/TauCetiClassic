/obj/structure/stacklifter
	name = "Weight Machine"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/obj/fitness.dmi'
	icon_state = "fitnesslifter"
	density = 1
	anchored = 1

/obj/structure/stacklifter/attack_hand(mob/living/carbon/human/user)
	if(!user.Adjacent(src))
		return
	var/mob/living/carbon/human/gymnast = user
	if(!istype(gymnast) || gymnast.lying)
		return
	if(in_use)
		to_chat(user, "It's already in use - wait a bit.")
		return
	if(user.buckled && user.buckled != src)
		to_chat(user, "You should get off the [user.buckled] first.")
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

		if((HULK in user.mutations) && user.hulk_activator == ACTIVATOR_HEAVY_MUSCLE_LOAD)
			to_chat(user, "<span class='notice'>You feel unbearable muscle pain, but you like it!</span>")

		while (lifts++ < 6)
			if (user.loc != src.loc)
				break
			sleep(3)
			animate(user, pixel_y = -2, time = 3)
			sleep(3)
			animate(user, pixel_y = -4, time = 3)
			sleep(3)
			playsound(user, 'sound/machines/spring.ogg', VOL_EFFECTS_MASTER)
		playsound(user, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
		in_use = 0
		user.pixel_y = 0
		gymnast.nutrition -= 6
		gymnast.overeatduration -= 8
		gymnast.apply_effect(15,AGONY,0)
		var/finishmessage = pick("You feel stronger!","You feel like you can take on the world!","You feel robust!","You feel indestructible!")
		icon_state = "fitnesslifter"
		to_chat(user, "[finishmessage]")

		if((HULK in user.mutations) && user.hulk_activator == "heavy muscle load" && prob(60))
			user.try_mutate_to_hulk()

/obj/structure/weightlifter
	name = "Weight Machine"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/obj/fitness.dmi'
	icon_state = "fitnessweight"
	density = 1
	anchored = 1

/obj/structure/weightlifter/attack_hand(mob/living/carbon/human/user)
	if(!user.Adjacent(src))
		return
	var/mob/living/carbon/human/gymnast = user
	if(!istype(gymnast) || gymnast.lying)
		return
	if(in_use)
		to_chat(user, "It's already in use - wait a bit.")
		return
	if(user.buckled && user.buckled != src)
		to_chat(user, "You should get off the [user.buckled] first.")
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
		add_overlay(W)
		var/bragmessage = pick("pushing it to the limit","going into overdrive","burning with determination","rising up to the challenge", "getting strong now","getting ripped")
		user.visible_message("<B>[user] is [bragmessage]!</B>")
		var/reps = 0
		user.pixel_y = 5

		if((HULK in user.mutations) && user.hulk_activator == "heavy muscle load")
			to_chat(user, "<span class='notice'>You feel unbearable muscle pain, but you like it!</span>")

		while (reps++ < 6)
			if (user.loc != src.loc)
				break

			for (var/innerReps = max(reps, 1), innerReps > 0, innerReps--)
				sleep(3)
				animate(user, pixel_y = (user.pixel_y == 3) ? 5 : 3, time = 3)

			playsound(user, 'sound/machines/spring.ogg', VOL_EFFECTS_MASTER)

		sleep(3)
		animate(user, pixel_y = 2, time = 3)
		sleep(3)
		playsound(user, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
		in_use = 0
		animate(user, pixel_y = 0, time = 3)
		gymnast.nutrition -= 12
		gymnast.overeatduration -= 16
		gymnast.apply_effect(25,AGONY,0)
		var/finishmessage = pick("You feel stronger!","You feel like you can take on the world!","You feel robust!","You feel indestructible!")
		icon_state = "fitnessweight"
		cut_overlay(W)
		to_chat(user, "[finishmessage]")

		if((HULK in user.mutations) && user.hulk_activator == "heavy muscle load" && prob(60))
			user.try_mutate_to_hulk()
