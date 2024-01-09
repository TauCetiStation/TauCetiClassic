/obj/structure/stacklifter
	name = "Weight Machine"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/obj/fitness.dmi'
	icon_state = "fitnesslifter"
	density = TRUE
	anchored = TRUE

	var/taken = FALSE

/obj/structure/stacklifter/proc/finish_pump(mob/living/carbon/human/user)
	icon_state = "fitnesslifter"
	user.pixel_y = 0
	taken = FALSE

/obj/structure/stacklifter/proc/get_pumped(mob/living/carbon/human/user)
	for(var/lifts in 1 to 5)
		animate(user, pixel_y = -2, time = 3)
		if(user.is_busy() || !do_after(user, 3, TRUE, src, progress=FALSE))
			return
		animate(user, pixel_y = -4, time = 3)
		if(user.is_busy() || !do_after(user, 3, TRUE, src, progress=FALSE))
			return
		playsound(user, 'sound/machines/spring.ogg', VOL_EFFECTS_MASTER)

	playsound(user, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)

	user.nutrition -= 6
	user.overeatduration -= 8

	var/obj/item/organ/external/chest/C = user.get_bodypart(BP_CHEST)
	var/obj/item/organ/external/groin/G = user.get_bodypart(BP_GROIN)

	if(C)
		var/pain_amount = 7 * C.adjust_pumped(1)
		user.apply_effect(pain_amount, AGONY, 0)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "swole", /datum/mood_event/swole, pain_amount)
	if(G)
		var/pain_amount = 7 * G.adjust_pumped(1)
		user.apply_effect(pain_amount, AGONY, 0)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "swole", /datum/mood_event/swole, pain_amount)

	user.update_body()

	var/finishmessage = pick("You feel stronger!","You feel like you can take on the world!","You feel robust!","You feel indestructible!")
	to_chat(user, "<span class='notice'>[finishmessage]</span>")

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

	if(taken)
		to_chat(user, "It's already in use - wait a bit.")
		return
	if(user.buckled && user.buckled != src)
		to_chat(user, "You should get off the [user.buckled] first.")
		return

	if(gymnast.halloss > 80 || gymnast.shock_stage > 80)
		to_chat(user, "You are too exausted.")
		return

	taken = TRUE

	icon_state = "fitnesslifter2"
	user.set_dir(SOUTH)
	user.forceMove(loc)
	var/bragmessage = pick("pushing it to the limit","going into overdrive","burning with determination","rising up to the challenge", "getting strong now","getting ripped")
	user.visible_message("<B>[user] is [bragmessage]!</B>")

	if((HULK in user.mutations) && user.hulk_activator == ACTIVATOR_HEAVY_MUSCLE_LOAD)
		to_chat(user, "<span class='notice'>You feel unbearable muscle pain, but you like it!</span>")

	INVOKE_ASYNC(src, PROC_REF(try_pump), user)

/obj/structure/weightlifter
	name = "Weight Machine"
	desc = "Just looking at this thing makes you feel tired."
	icon = 'icons/obj/fitness.dmi'
	icon_state = "fitnessweight"
	density = TRUE
	anchored = TRUE

	var/taken = FALSE

	var/static/image/weight_overlay

/obj/structure/weightlifter/atom_init()
	. = ..()
	if(weight_overlay)
		return

	weight_overlay = image('icons/obj/fitness.dmi',"fitnessweight-w")
	weight_overlay.layer = MOB_LAYER + 1

/obj/structure/weightlifter/Destroy()
	QDEL_NULL(weight_overlay)
	return ..()

/obj/structure/weightlifter/proc/finish_pump(mob/living/carbon/human/user)
	cut_overlay(weight_overlay)
	user.pixel_y = 0
	icon_state = "fitnessweight"
	taken = FALSE

/obj/structure/weightlifter/proc/get_pumped(mob/living/carbon/human/user)
	add_overlay(weight_overlay)

	for(var/reps in 1 to 5)
		for(var/innerReps = max(reps, 1), innerReps > 0, innerReps--)
			animate(user, pixel_y = (user.pixel_y == 3) ? 5 : 3, time = 3)
			if(user.is_busy() || !do_after(user, 3, TRUE, src, progress=FALSE))
				return

		playsound(user, 'sound/machines/spring.ogg', VOL_EFFECTS_MASTER)

	animate(user, pixel_y = 2, time = 3)
	if(user.is_busy() || !do_after(user, 3, TRUE, src, progress=FALSE))
		return
	playsound(user, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)

	animate(user, pixel_y = 0, time = 3)
	if(user.is_busy() || !do_after(user, 3, TRUE, src, progress=FALSE))
		return

	user.nutrition -= 12
	user.overeatduration -= 16

	var/obj/item/organ/external/l_arm/LA = user.get_bodypart(BP_L_ARM)
	var/obj/item/organ/external/r_arm/RA = user.get_bodypart(BP_R_ARM)
	if(LA)
		var/pain_amount = 12 * LA.adjust_pumped(1)
		user.apply_effect(pain_amount, AGONY, 0)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "swole", /datum/mood_event/swole, pain_amount)
	if(RA)
		var/pain_amount = 12 * RA.adjust_pumped(1)
		user.apply_effect(pain_amount, AGONY, 0)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "swole", /datum/mood_event/swole, pain_amount)

	user.update_body()

	var/finishmessage = pick("You feel stronger!","You feel like you can take on the world!","You feel robust!","You feel indestructible!")
	to_chat(user, "<span class='notice'>[finishmessage]</span>")

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
	if(taken)
		to_chat(user, "It's already in use - wait a bit.")
		return
	if(user.buckled && user.buckled != src)
		to_chat(user, "You should get off the [user.buckled] first.")
		return
	if(user.halloss > 80 || user.shock_stage > 80)
		to_chat(user, "You are too exausted.")
		return

	taken = TRUE

	icon_state = "fitnessweight-c"
	user.set_dir(SOUTH)
	user.forceMove(loc)

	var/bragmessage = pick("pushing it to the limit","going into overdrive","burning with determination","rising up to the challenge", "getting strong now","getting ripped")
	user.visible_message("<B>[user] is [bragmessage]!</B>")
	user.pixel_y = 5

	INVOKE_ASYNC(src, PROC_REF(try_pump), user)

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
	. = ..()
	dumbbells = new(src)
	dumbbells.set_slots(slots = 4, slot_size = SIZE_BIG)
	dumbbells.can_hold = list(/obj/item/weapon/dumbbell)

	RegisterSignal(dumbbells, list(COMSIG_STORAGE_ENTERED), PROC_REF(add_dumbbell))
	RegisterSignal(dumbbells, list(COMSIG_STORAGE_EXITED), PROC_REF(remove_dumbbell))

	var/list/dumbbells_to_add = list()

	dumbbells_to_add += new /obj/item/weapon/dumbbell/light
	dumbbells_to_add += new /obj/item/weapon/dumbbell/light

	dumbbells_to_add += new /obj/item/weapon/dumbbell/heavy
	dumbbells_to_add += new /obj/item/weapon/dumbbell/heavy

	for(var/obj/item/I as anything in dumbbells_to_add)
		dumbbells.handle_item_insertion(I, TRUE, TRUE)

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

/obj/structure/dumbbells_rack/MouseDrop(obj/over_object)
	if(dumbbells.handle_mousedrop(usr, over_object))
		return

	return ..()

/obj/structure/dumbbells_rack/attackby(obj/item/I, mob/user, params)
	if(user.a_intent != INTENT_HARM && dumbbells.attackby(I, user, params))
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
	sharp = 0
	throwforce = 5.0
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
	sharp = 0
	throwforce = 8.0
	throw_speed = 1
	throw_range = 1
	w_class = SIZE_NORMAL

	mass = 2
	max_pumped = 25

/obj/item/weapon/dumbbell/attack_self(mob/living/user)
	if(user.is_busy())
		return
	if(!do_after(user, 25 * mass, target = src))
		return

	user.visible_message("<span class='notice'>\The [user] excercises with [src].</span>")

	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	var/obj/item/organ/external/BP = H.get_bodypart(BP_ACTIVE_ARM)
	if(!BP)
		return

	var/pain_amount = 3 * BP.adjust_pumped(mass, max_pumped)
	H.apply_effect(pain_amount, AGONY, 0)
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "swole", /datum/mood_event/swole, pain_amount)
	H.update_body()

	H.nutrition -= 2 * mass
	H.overeatduration -= 2 * mass
