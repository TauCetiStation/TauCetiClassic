/obj/structure/stacklifter
	name = "Weight Machine"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/obj/fitness.dmi'
	icon_state = "fitnesslifter"
	density = TRUE
	anchored = TRUE

/obj/structure/stacklifter/proc/finish_pump(mob/living/carbon/human/user)
	icon_state = "fitnesslifter"
	user.pixel_y = 0

/obj/structure/stacklifter/proc/get_pumped(mob/living/carbon/human/user)
	var/lifts = 0
	while (lifts++ < 6)
		if (user.loc != src.loc)
			break
		if(!do_after(user, 3, TRUE, src, progress=FALSE))
			return
		animate(user, pixel_y = -2, time = 3)
		if(!do_after(user, 3, TRUE, src, progress=FALSE))
			return
		animate(user, pixel_y = -4, time = 3)
		if(!do_after(user, 3, TRUE, src, progress=FALSE))
			return
		playsound(user, 'sound/machines/spring.ogg', VOL_EFFECTS_MASTER)

	playsound(user, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
	user.nutrition -= 6
	user.overeatduration -= 8
	user.apply_effect(15,AGONY,0)

	var/obj/item/organ/external/chest/C = user.get_bodypart(BP_CHEST)
	var/obj/item/organ/external/groin/G = user.get_bodypart(BP_GROIN)
	if(C)
		C.adjust_pumped(1)
	if(G)
		C.adjust_pumped(1)

	user.update_body()

	var/finishmessage = pick("You feel stronger!","You feel like you can take on the world!","You feel robust!","You feel indestructible!")
	to_chat(user, "[finishmessage]")

	if((HULK in user.mutations) && user.hulk_activator == "heavy muscle load" && prob(60))
		user.try_mutate_to_hulk()

/obj/structure/stacklifter/proc/try_pump(mob/living/carbon/human/user)
	get_pumped(user)
	finish_pump(user)

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

	icon_state = "fitnesslifter2"
	user.set_dir(SOUTH)
	user.Stun(4)
	user.forceMove(loc)
	var/bragmessage = pick("pushing it to the limit","going into overdrive","burning with determination","rising up to the challenge", "getting strong now","getting ripped")
	user.visible_message("<B>[user] is [bragmessage]!</B>")

	if((HULK in user.mutations) && user.hulk_activator == ACTIVATOR_HEAVY_MUSCLE_LOAD)
		to_chat(user, "<span class='notice'>You feel unbearable muscle pain, but you like it!</span>")

	INVOKE_ASYNC(src, .proc/get_pumped, user)

/obj/structure/weightlifter
	name = "Weight Machine"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/obj/fitness.dmi'
	icon_state = "fitnessweight"
	density = TRUE
	anchored = TRUE

	var/image/weight_overlay

/obj/structure/weightlifter/Destroy()
	QDEL_NULL(weight_overlay)
	return ..()

/obj/structure/weightlifter/proc/finish_pump(mob/living/carbon/human/user)
	cut_overlay(weight_overlay)
	QDEL_NULL(weight_overlay)
	user.pixel_y = 0

/obj/structure/weightlifter/proc/get_pumped(mob/living/carbon/human/user)
	weight_overlay = image('icons/obj/fitness.dmi',"fitnessweight-w")
	weight_overlay.layer = MOB_LAYER + 1
	add_overlay(weight_overlay)

	var/reps = 0
	while (reps++ < 6)
		if (user.loc != src.loc)
			break

		for(var/innerReps = max(reps, 1), innerReps > 0, innerReps--)
			if(!do_after(user, 3, TRUE, src, progress=FALSE))
				return
			animate(user, pixel_y = (user.pixel_y == 3) ? 5 : 3, time = 3)

		playsound(user, 'sound/machines/spring.ogg', VOL_EFFECTS_MASTER)

	if(!do_after(user, 3, TRUE, src, progress=FALSE))
		return
	animate(user, pixel_y = 2, time = 3)
	if(!do_after(user, 3, TRUE, src, progress=FALSE))
		return
	playsound(user, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)

	animate(user, pixel_y = 0, time = 3)
	if(!do_after(user, 3, TRUE, src, progress=FALSE))
		return

	user.nutrition -= 12
	user.overeatduration -= 16
	user.apply_effect(25,AGONY,0)

	var/obj/item/organ/external/l_arm/LA = user.get_bodypart(BP_L_ARM)
	var/obj/item/organ/external/r_arm/RA = user.get_bodypart(BP_R_ARM)
	if(LA)
		LA.adjust_pumped(1)
	if(RA)
		RA.adjust_pumped(1)

	user.update_body()

	var/finishmessage = pick("You feel stronger!","You feel like you can take on the world!","You feel robust!","You feel indestructible!")
	icon_state = "fitnessweight"
	cut_overlay(W)
	to_chat(user, "[finishmessage]")

	if((HULK in user.mutations) && user.hulk_activator == "heavy muscle load" && prob(60))
		user.try_mutate_to_hulk()

/obj/structure/weightlifter/proc/try_pump(mob/living/carbon/human/user)
	get_pumped(user)
	finish_pump(user)

/obj/structure/weightlifter/attack_hand(mob/living/carbon/human/user)
	if(!user.Adjacent(src))
		return
	if(!istype(user) || user.lying)
		return
	if(in_use)
		to_chat(user, "It's already in use - wait a bit.")
		return
	if(user.buckled && user.buckled != src)
		to_chat(user, "You should get off the [user.buckled] first.")
		return
	if(user.halloss > 80 || user.shock_stage > 80)
		to_chat(user, "You are too exausted.")
		return

	icon_state = "fitnessweight-c"
	user.set_dir(SOUTH)
	user.Stun(4)
	user.forceMove(loc)

	var/bragmessage = pick("pushing it to the limit","going into overdrive","burning with determination","rising up to the challenge", "getting strong now","getting ripped")
	user.visible_message("<B>[user] is [bragmessage]!</B>")
	user.pixel_y = 5

	INVOKE_ASYNC(src, .proc/try_pump, user)

/obj/structure/dumbbells_rack
	name = "dumbbells rack"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/obj/fitness.dmi'
	icon_state = "dumbbells_rack"
	density = TRUE
	anchored = TRUE

	var/obj/item/weapon/storage/internal/dumbbells

	var/list/dumbbells_overlays

	var/heavy_dumbbells = 0
	var/max_heavy_dumbbells = 2
	var/light_dumbbells = 0
	var/max_light_dumbbells = 2

/obj/structure/dumbbells_rack/atom_init()
	dumbbells = new(src)
	dumbbells.set_slots(slots = 4, slot_size = SIZE_BIG)
	dumbbells.can_hold = list(/obj/item/weapon/dumbbell)

	RegisterSignal(dumbbells, list(COMSIG_STORAGE_ENTERED), .proc/add_dumbbell)
	RegisterSignal(dumbbells, list(COMSIG_STORAGE_EXITED), .proc/remove_dumbbell)

	new /obj/item/weapon/dumbbell/light(dumbbells)
	new /obj/item/weapon/dumbbell/light(dumbbells)

	new /obj/item/weapon/dumbbell/heavy(dumbbells)
	new /obj/item/weapon/dumbbell/heavy(dumbbells)

/obj/structure/dumbbells_rack/Destroy()
	for(var/ref in dumbbells_overlays)
		qdel(dumbbells_overlays[ref])
	dumbbells_overlays = null
	UnregisterSignal(dumbbells, list(COMSIG_STORAGE_ENTERED, COMSIG_STORAGE_EXITED))
	QDEL_NULL(dumbbells)
	return ..()

/obj/structure/dumbbells_rack/proc/add_dumbbell(datum/source, obj/item/I)
	var/image/over
	if(istype(I, /obj/item/weapon/dumbbell/light))
		if(light_dumbbells >= max_light_dumbbells)
			return COMSIG_STORAGE_PROHIBIT
		light_dumbbells += 1
		over = image(icon=icon, icon_state="[I.icon_state]_[light_dumbbells]")

	else if(istype(I, /obj/item/weapon/dumbbell/heavy))
		if(heavy_dumbbells >= max_heavy_dumbbells)
			return COMSIG_STORAGE_PROHIBIT
		heavy_dumbbells += 1
		over = image(icon=icon, icon_state="[I.icon_state]_[heavy_dumbbells]")

	add_overlay(over)
	LAZYSET(dumbbells_overlays, REF(I), over)

/obj/structure/dumbbells_rack/proc/remove_dumbbell(datum/source, obj/item/I)
	if(istype(I, /obj/item/weapon/dumbbell/light))
		light_dumbbells -= 1
	else if(istype(I, /obj/item/weapon/dumbbell/heavy))
		heavy_dumbbells -= 1

	cut_overlay(dumbbells_overlays[REF(I)])
	LAZYREMOVE(dumbbells_overlays, REF(I))

/obj/structure/dumbbells_rack/attack_hand(mob/user)
	if(dumbbells.handle_attack_hand(user))
		return

	return ..()

/obj/structure/dumbbells_rack/attackby(obj/item/I, mob/user, params)
	if(user.a_intent != INTENT_HARM && dumbbells.attackby(I, user, params))
		return
	return ..()

/obj/item/clothing/suit/storage/MouseDrop(obj/over_object)
	if(dumbbells.handle_mousedrop(usr, over_object))
		return

	return ..()

/obj/item/weapon/dumbbell
	var/mass = 1
	var/max_pumped

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

	mass = 1
	max_pumped = 10

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

	mass = 2
	max_pumped = 25

/obj/item/weapon/dumbbell/attack_self(mob/living/carbon/human/user)
	if(user.is_busy())
		return
	if(!do_after(user, 25 * mass, target = src))
		return

	var/obj/item/organ/external/BP = user.get_bodypart(user.hand ? BP_L_ARM : BP_R_ARM)
	if(!BP)
		return

	if(BP.pumped >= max_pumped)
		return

	BP.pumped += mass
	if(BP.pumped > max_pumped)
		BP.pumped = max_pumped

	user.nutrition -= 2 * mass
	user.overeatduration -= 2 * mass
	user.apply_effect(2 * mass, AGONY, 0)
	user.visible_message("<span class='notice'>\The [user] excercises with [src].</span>")
	BP.update_sprite()
	user.update_body()
