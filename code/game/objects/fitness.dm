/obj/structure/stacklifter
	name = "Weight Machine"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/obj/fitness.dmi'
	icon_state = "fitnesslifter"
	density = TRUE
	anchored = TRUE

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
		var/obj/item/organ/external/chest/Ch = gymnast.get_bodypart(BP_CHEST)
		var/obj/item/organ/external/groin/Gr = gymnast.get_bodypart(BP_GROIN)
		if(Ch)
			Ch.pumped += 1
			Ch.update_sprite()
		if(Gr)
			Gr.pumped += 1
			Gr.update_sprite()
		gymnast.update_body()

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
	density = TRUE
	anchored = TRUE

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
		var/obj/item/organ/external/l_arm/La = gymnast.get_bodypart(BP_L_ARM)
		var/obj/item/organ/external/r_arm/Ra = gymnast.get_bodypart(BP_R_ARM)
		if(La)
			La.pumped += 1
			La.update_sprite()
		if(Ra)
			Ra.pumped += 1
			Ra.update_sprite()
		gymnast.update_body()

		var/finishmessage = pick("You feel stronger!","You feel like you can take on the world!","You feel robust!","You feel indestructible!")
		icon_state = "fitnessweight"
		cut_overlay(W)
		to_chat(user, "[finishmessage]")

		if((HULK in user.mutations) && user.hulk_activator == "heavy muscle load" && prob(60))
			user.try_mutate_to_hulk()

/obj/structure/dumbbells_rack
	name = "Dumbbells Rack"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/obj/fitness.dmi'
	icon_state = "dumbbells_rack"
	density = TRUE
	anchored = TRUE
	var/heavy_dumbbell = 0
	var/light_dumbbell = 0

/obj/structure/dumbbells_rack/atom_init(mapload)
	if(mapload)
		contents += new /obj/item/weapon/dumbbell/light
		contents += new /obj/item/weapon/dumbbell/light
		contents += new /obj/item/weapon/dumbbell/heavy
		contents += new /obj/item/weapon/dumbbell/heavy
		heavy_dumbbell = 2
		light_dumbbell = 2
		update_icon()

/obj/structure/dumbbells_rack/update_icon()
	cut_overlays()
	if(heavy_dumbbell > 0)
		add_overlay(icon('icons/obj/fitness.dmi', "Heavy1"))
		if(heavy_dumbbell == 2)
			add_overlay(icon('icons/obj/fitness.dmi', "Heavy2"))
	if(light_dumbbell > 0)
		add_overlay(icon('icons/obj/fitness.dmi', "light3"))
		if(light_dumbbell == 2)
			add_overlay(icon('icons/obj/fitness.dmi', "light4"))

/obj/structure/dumbbells_rack/attack_hand(mob/living/carbon/human/user)
	if(contents.len)
		var/obj/item/weapon/dumbbell/choice = input("Which dumbbell would you like to remove from the shelf?") in contents
		if(choice)
			if(!Adjacent(usr) || usr.incapacitated())
				return
			if(ishuman(user))
				user.put_in_hands(choice)
			else
				choice.forceMove(get_turf(src))
			if(istype(choice, /obj/item/weapon/dumbbell/light))
				light_dumbbell -= 1
			else
				heavy_dumbbell -= 1
			update_icon()

/obj/structure/dumbbells_rack/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/dumbbell/light))
		if(light_dumbbell < 2)
			user.drop_from_inventory(W, src)
			light_dumbbell += 1
	if(istype(W, /obj/item/weapon/dumbbell/heavy))
		if(heavy_dumbbell < 2)
			user.drop_from_inventory(W, src)
			heavy_dumbbell += 1
	update_icon()

/obj/item/weapon/dumbbell/light
	name = "Light Dumbbell"
	desc = "Citius, altius, fortius!."
	icon = 'icons/obj/fitness.dmi'
	icon_state = "dumbbells_light"
	force = 7.0
	throwforce = 5.0
	throw_speed = 5
	throw_range = 3
	w_class = SIZE_NORMAL

/obj/item/weapon/dumbbell/heavy
	name = "Heavy Dumbbell"
	desc = "Citius, altius, fortius!"
	icon = 'icons/obj/fitness.dmi'
	icon_state = "dumbbells_heavy"
	force = 10.0
	throwforce = 8.0
	throw_speed = 5
	throw_range = 1
	w_class = SIZE_NORMAL

/obj/item/weapon/dumbbell/attack_self(mob/living/carbon/human/user)
	var/mass = 1
	if(istype(src, /obj/item/weapon/dumbbell/heavy))
		mass = 2

	if(user.is_busy() || issilicon(user))
		return
	if(do_after(user, 25 * mass, target = src))
		var/obj/item/organ/external/BPHand = user.get_bodypart(user.hand ? BP_L_ARM : BP_R_ARM)
		if(mass == 1 && BPHand.pumped < 10)
			BPHand.pumped += mass
		else if(mass == 2 && BPHand.pumped < 25)
			BPHand.pumped += mass
		BPHand.update_sprite()
		user.update_body()
		user.nutrition -= 5 * mass
		user.overeatduration -= 5 * mass
		user.apply_effect(5 * mass,AGONY,0)
		user.visible_message("<span class='notice'>\The [user] excercises with [src].</span>")
