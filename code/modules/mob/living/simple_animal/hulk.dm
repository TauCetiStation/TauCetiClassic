/mob/living/simple_animal/hulk
	name = "Hulk"
	real_name = "Hulk"
	desc = ""
	icon = 'icons/mob/hulk.dmi'
	icon_state = "hulk"
	icon_living = "hulk"
	maxHealth = 200
	health = 200
	immune_to_ssd = 1
	anchored = 1

	speak_emote = list("roars")
	emote_hear = list("roars")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"

	harm_intent_damage = 0
	melee_damage_lower = 5
	melee_damage_upper = 20
	attacktext = "brutally crushes"
	environment_smash = 2

	speed = 1
	a_intent = "harm"
	stop_automated_movement = 1
	status_flags = CANPUSH
	universal_speak = 1
	universal_understand = 1
	attack_sound = 'sound/weapons/punch1.ogg'
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	var/hulk_powers = list()
	var/mob/living/original_body
	var/health_regen = 1

/mob/living/simple_animal/hulk/human
	hulk_powers = list(/obj/effect/proc_holder/spell/aoe_turf/hulk_jump,
						/obj/effect/proc_holder/spell/aoe_turf/hulk_dash,
						/obj/effect/proc_holder/spell/aoe_turf/hulk_smash
							)

/mob/living/simple_animal/hulk/unathi
	name = "Zilla"
	real_name = "Zilla"
	desc = ""
	icon = 'icons/mob/hulk_zilla.dmi'
	icon_state = "zilla"
	icon_living = "zilla"
	maxHealth = 400
	health = 400

	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "brutally bites"

	speed = 2

	attack_sound = 'sound/weapons/bite.ogg'

	hulk_powers = list(/obj/effect/proc_holder/spell/aoe_turf/hulk_mill,
						/obj/effect/proc_holder/spell/aoe_turf/hulk_gas,
						/obj/effect/proc_holder/spell/aoe_turf/hulk_spit,
						/obj/effect/proc_holder/spell/aoe_turf/hulk_eat,
						/obj/effect/proc_holder/spell/aoe_turf/hulk_lazor
							)
	health_regen = 3

/mob/living/simple_animal/hulk/atom_init()
	..()
	name = text("[initial(name)] ([rand(1, 1000)])")
	real_name = name
	status_flags ^= CANPUSH
	for(var/spell in hulk_powers)
		spell_list += new spell(src)

/mob/living/simple_animal/hulk/unathi/Login()
	..()
	to_chat(src, "\blue Can eat limbs (left mouse button).")

/mob/living/simple_animal/hulk/Life()
	if(health < 1)
		death()
		return

	var/matrix/Mx = matrix()
	if(health <= 35)
		Mx.Scale(0.75)
		Mx.Translate(0,-5)
	else if(health <= 75)
		Mx.Scale(0.8)
		Mx.Translate(0,-4)
	else if(health <= 135)
		Mx.Scale(0.85)
		Mx.Translate(0,-3)
	else if(health <= 175)
		Mx.Scale(0.9)
		Mx.Translate(0,-2)
	else
		Mx.Scale(1)
		Mx.Translate(0,0)
	transform = Mx

	var/datum/gas_mixture/environment = loc.return_air()
	if(environment)
		var/pressure = environment.return_pressure()
		if(pressure > 110)
			health -= 7
		else if(pressure <= 5)
			health -= 12
		else if(pressure <= 25)
			health -= 8
		else if(pressure <= 45)
			health -= 5
		else if(pressure <= 55)
			health -= 3

		if(pressure <= 75)
			if(prob(15))
				emote("me",1,"gasps!")

	weakened = 0
	if(health > 0)
		health = min(health + health_regen, maxHealth)
	..()

/mob/living/simple_animal/hulk/death()
	unmutate()

/mob/living/simple_animal/hulk/proc/unmutate()
	for(var/mob/M in contents)
		M.loc = src.loc
		if(istype(M, /mob/living))
			var/mob/living/L = M
			L.Paralyse(15)
			L.update_canmove()

	if(mind && original_body)
		mind.transfer_to(original_body)
		original_body.attack_log = attack_log
		original_body.attack_log += "\[[time_stamp()]\]<font color='blue'> ======HUMAN LIFE======</font>"
	qdel(src)

/mob/living/simple_animal/hulk/MobBump(mob/M)
	if(isliving(M) && !(istype(M, /mob/living/simple_animal/hulk) || issilicon(M)))
		var/mob/living/L = M
		L.Weaken(3)
		L.take_overall_damage(rand(4,12), 0)
	return 0

/mob/living/simple_animal/hulk/examine(mob/user)
	var/msg = "<span cass='info'>*---------*\nThis is [bicon(src)] \a <EM>[src]</EM>!\n"
	if (src.health < src.maxHealth)
		msg += "<span class='warning'>"
		if (src.health >= src.maxHealth/2)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
		msg += "</span>"
	msg += "*---------*</span>"

	to_chat(user, msg)

//mob/living/simple_animal/hulk/Process_Spacemove(movement_dir = 0)
//	return 1 //copypasta from carp code

/mob/living/simple_animal/hulk/attackby(obj/item/O, mob/user)
	user.SetNextMove(CLICK_CD_MELEE)
	if(O.force)
		if(O.force >= 10)
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			adjustBruteLoss(damage)
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red \b [src] has been attacked with [O] by [user]. ")
		else
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red \b [O] bounces harmlessly off of [src]. ")
	else
		to_chat(usr, "\red This weapon is ineffective, it does no damage.")
		for(var/mob/M in viewers(src, null))
			if ((M.client && !( M.blinded )))
				M.show_message("\red [user] gently taps [src] with [O]. ")

/mob/living/simple_animal/hulk/bullet_act(obj/item/projectile/P)
	..()
	if(istype(P, /obj/item/projectile/energy/electrode) || istype(P, /obj/item/projectile/beam/stun) || istype(P, /obj/item/projectile/bullet/stunslug) || istype(P, /obj/item/projectile/bullet/weakbullet))
		health -= P.agony / 10

/mob/living/simple_animal/hulk/proc/attack_hulk(obj/machinery/door/D)
	do_attack_animation(D)
	SetNextMove(CLICK_CD_MELEE)

	if(istype(D,/obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = D
		if(A.welded || A.locked)
			if(hulk_scream(A, 75))
				A.door_rupture(src)
			return
	if(istype(D,/obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/F = D
		if(F.blocked)
			if(hulk_scream(F))
				qdel(F)
				return
	if(D.density)
		to_chat(src, "<span class='userdanger'>You force your fingers between \
		 the doors and begin to pry them open...</span>")
		playsound(D, 'sound/machines/electric_door_open.ogg', 30, 1, -4)
		if (!is_busy() && do_after(src, 40, target = D) && D)
			D.open(1)

/mob/living/proc/hulk_scream(obj/target, chance)
	if(prob(chance))
		visible_message("<span class='userdanger'>[src] has punched \the <B>[target]!</span>",\
		"<span class='userdanger'>You punch the [target]!</span>",\
		"<span class='userdanger'>You feel some weird vibration!</span>")
		playsound(loc, 'sound/effects/grillehit.ogg', 50, 1)
		return 0
	else
		say(pick("RAAAAAAAARGH!", "HNNNNNNNNNGGGGGGH!", "GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", "AAAAAAARRRGH!" ))
		visible_message("<span class='userdanger'>[src] has destroyed some mechanic in the [target]!</span>",\
		"<span class='userdanger'>You destroy some mechanic in the [target] door, which holds it in place!</span>",\
		"<span class='userdanger'>You feel some weird vibration!</span>")
		playsound(loc, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), 50, 1)
		return 1
