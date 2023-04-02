/obj/item/weapon/holosign_creator
	name = "Janitor HoloSign projector"
	desc = "A handy-dandy hologaphic projector that displays a janitorial sign."
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker_jani"
	force = 5
	w_class = SIZE_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	origin_tech = "programming=3"
	var/list/signs = list()
	var/max_signs = 10
	var/holosign_type = /obj/structure/holosign/wet_sign
	var/creation_time = 0

/obj/item/weapon/holosign_creator/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>It is currently maintaining <b>[signs.len]/[max_signs]</b> projections.</span>")


/obj/item/weapon/holosign_creator/afterattack(atom/target, mob/user, proximity, params)
	if(proximity)
		if(!check_allowed_items(target, 1))
			return
		var/turf/T = get_turf(target)
		var/obj/structure/holosign/H = locate() in T
		if(H)
			if(istype(H,holosign_type))
				signs.Remove(H)
				qdel(H)
		else
			if(signs.len < max_signs)
				playsound(user,'sound/machines/click.ogg',VOL_EFFECTS_MASTER)
				if(do_after(user, creation_time, target = target))
					playsound(user,'sound/items/Deconstruct.ogg',VOL_EFFECTS_MASTER)
					T = new holosign_type(get_turf(target))
					signs += T
			else
				to_chat(user, "<span class='notice'>[src] is projecting at max capacity!</span>")

/obj/item/weapon/holosign_creator/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/weapon/holosign_creator/attack_self(mob/user)
	if(signs.len)
		var/list/L = signs.Copy()
		for(var/sign in L)
			qdel(sign)
			signs -= sign
		to_chat(user, "<span class='notice'>You clear all active holograms.</span>")

//HoloProjector subtypes
/obj/item/weapon/holosign_creator/security
	name = "Security HoloBarrier projector"
	holosign_type = /obj/structure/holosign/barrier
	creation_time = 40
	icon_state = "signmaker_sec"
	max_signs = 8

/obj/item/weapon/holosign_creator/engineering
	name = "Engineering HoloBarrier projector"
	holosign_type = /obj/structure/holosign/barrier/engineering
	creation_time = 40
	icon_state = "signmaker_engi"
	max_signs = 8

/obj/item/weapon/holosign_creator/atmos
	name = "ATMOS HoloBarrier projector"
	holosign_type = /obj/structure/holosign/barrier/atmos
	creation_time = 10
	icon_state = "signmaker_atmos"
	max_signs = 12

/obj/item/weapon/holosign_creator/quarantine
	name = "PANDEMIC HoloBarrier projector"
	holosign_type = /obj/structure/holosign/barrier/quarantine
	creation_time = 10
	icon_state = "signmaker_vir"
	max_signs = 12

//holographic signs
/obj/structure/holosign
	name = "FIX ME"
	desc = "Holosign"
	icon = 'icons/obj/structures/holosigns.dmi'
	icon_state = "holosign"
	anchored = TRUE
	resistance_flags = CAN_BE_HIT
	max_integrity = 1

/obj/structure/holosign/wet_sign
	name = "wet floor sign"
	desc = "The words flicker as if they mean nothing."
	icon_state = "holosign"

/obj/item/weapon/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	force = 1
	throwforce = 3
	throw_speed = 2
	throw_range = 5
	w_class = SIZE_TINY
	attack_verb = list("warned", "cautioned", "smashed")

/obj/structure/holosign/barrier
	name = "HoloBarrier"
	desc = "A short holographic barrier which can only be passed by walking."
	icon_state = "holosign_sec"
	pass_flags = PASSTABLE
	density = TRUE
	max_integrity = 35
	var/allow_walk = TRUE //can we pass through it on walk intent

/obj/structure/holosign/barrier/engineering
	max_integrity = 10
	icon_state = "holosign_engi"

/obj/structure/holosign/barrier/CanPass(atom/movable/mover, turf/target, height)
	. = ..()
	if(.)
		return
	if(iscarbon(mover))
		var/mob/living/carbon/C = mover
		if(C.stat) // Lets not prevent dragging unconscious/dead people.
			return TRUE
		if(allow_walk && C.m_intent == MOVE_INTENT_WALK)
			return TRUE

/obj/structure/holosign/barrier/atmos
	name = "HoloFirelock"
	desc = "It does not prevent solid objects from passing through, gas is kept out."
	icon_state = "holo_firelock"
	density = FALSE
	can_block_air = TRUE
	alpha = 150
	resistance_flags = CAN_BE_HIT | FIRE_PROOF

/obj/structure/holosign/barrier/atmos/c_airblock(turf/other)
	return BLOCKED

/obj/structure/holosign/barrier/atmos/atom_init()
	. = ..()
	update_nearby_tiles(need_rebuild = 1)

/obj/structure/holosign/barrier/atmos/Destroy()
	update_nearby_tiles()
	return ..()

/obj/structure/holosign/barrier/quarantine
	name = "\improper PANDEMIC holobarrier"
	desc = "A holobarrier that detect viruses and parasites. Denies passing to personnel with viruses. Good for quarantines."
	icon_state = "holo_medical"
	alpha = 150
	var/force_allaccess = FALSE
	var/buzzcd = 0
	var/beepcd = 0

/obj/structure/holosign/barrier/quarantine/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>The biometric scanners are <b>[force_allaccess ? "off" : "on"]</b>.</span>")

/obj/structure/holosign/barrier/quarantine/CanPass(atom/movable/mover, turf/target, height)
	. = ..()
	if(force_allaccess)
		return TRUE
	if(ishuman(mover))
		return CheckHuman(mover)
	return TRUE

/obj/structure/holosign/barrier/quarantine/Bumped(atom/movable/AM)
	. = ..()
	if(iscarbon(AM))
		if(buzzcd < world.time)
			playsound(get_turf(src),'sound/machines/buzz-sigh.ogg',VOL_EFFECTS_MASTER)
			buzzcd = (world.time + 15)
		icon_state = "holo_medical-deny"
		sleep(40)
		icon_state = "holo_medical"
		

/obj/structure/holosign/barrier/quarantine/Crossed(atom/movable/AM)
	icon_state = "holo_medical"
	. = ..()
	if(iscarbon(AM) && CheckHuman(AM))
		if(beepcd < world.time)
			playsound(get_turf(src),'sound/machines/beep-quiet.ogg',VOL_EFFECTS_MASTER)
			beepcd = (world.time + 15)
	else
		if(buzzcd < world.time)
			playsound(get_turf(src),'sound/machines/buzz-sigh.ogg',VOL_EFFECTS_MASTER)
			buzzcd = (world.time + 15)
			icon_state = "holo_medical-deny"
			sleep(40)
			icon_state = "holo_medical"

/obj/structure/holosign/barrier/quarantine/proc/CheckHuman(mob/living/carbon/human/SB)
	if(SB.virus2.len || locate(/obj/item/alien_embryo) in SB.contents)
		return FALSE
	return TRUE

/obj/structure/holosign/barrier/quarantine/attack_hand(mob/user)
	if(user.a_intent != INTENT_HARM)
		force_allaccess = !force_allaccess
		to_chat(user, "<span class='notice'>You [force_allaccess ? "deactivate" : "activate"] the biometric scanners.</span>")
	else
		return ..()
