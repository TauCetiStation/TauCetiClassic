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
	universal_speak = 0
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
	var/hulk_powers = list(/obj/effect/proc_holder/spell/aoe_turf/hulk_jump,
							/obj/effect/proc_holder/spell/aoe_turf/hulk_dash,
							/obj/effect/proc_holder/spell/aoe_turf/hulk_smash
							)

	var/previous_body = null

/mob/living/simple_animal/hulk/New()
	..()
	name = text("[initial(name)] ([rand(1, 1000)])")
	real_name = name
	for(var/spell in hulk_powers)
		spell_list += new spell(src)

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
			health -= 25
		else if(pressure <= 25)
			health -= 11
		else if(pressure <= 45)
			health -= 9
		else if(pressure <= 55)
			health -= 7
		else if(pressure <= 65)
			health -= 5
		else if(pressure <= 75)
			health -= 3

		if(pressure <= 75)
			if(prob(15))
				emote("me",1,"gasps!")

	weakened = 0
	if(health > 0)
		health = min(health + 1, maxHealth)
	..()

/mob/living/simple_animal/hulk/death()
	if(previous_body)
		var/mob/living/carbon/C =  new previous_body(get_turf(src))
		C.Paralyse(15)
		if(mind)
			mind.transfer_to(C)
	else
		var/mob/living/carbon/human/H = new /mob/living/carbon/human (get_turf(src))
		H.Paralyse(15)
		if(mind)
			mind.transfer_to(H)
	qdel(src)
	return

/mob/living/simple_animal/hulk/examine()
	set src in oview()

	var/msg = "<span cass='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n"
	if (src.health < src.maxHealth)
		msg += "<span class='warning'>"
		if (src.health >= src.maxHealth/2)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
		msg += "</span>"
	msg += "*---------*</span>"

	usr << msg
	return

/mob/living/simple_animal/hulk/Bump(atom/movable/AM as mob|obj, yes)
	if ((!( yes ) || now_pushing))
		return
	now_pushing = 1
	if(ismob(AM))
		var/mob/tmob = AM
		if(!(tmob.status_flags & CANPUSH))
			now_pushing = 0
			return

		tmob.LAssailant = src
	now_pushing = 0
	..()
	if (!istype(AM, /atom/movable))
		return
	if (!( now_pushing ))
		now_pushing = 1
		if (!( AM.anchored ))
			var/t = get_dir(src, AM)
			if (istype(AM, /obj/structure/window))
				if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
					for(var/obj/structure/window/win in get_step(AM,t))
						now_pushing = 0
						return
			step(AM, t)
		now_pushing = null

/mob/living/simple_animal/hulk/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper <= 0)
		M.emote("[M.friendly] \the <EM>[src]</EM>")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message("<span class='attack'>\The <EM>[M]</EM> [M.attacktext] \the <EM>[src]</EM>!</span>", 1)
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")

		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)

/mob/living/simple_animal/hulk/airflow_stun()
	return
	
/mob/living/simple_animal/hulk/airflow_hit(atom/A)
	return

//mob/living/simple_animal/hulk/Process_Spacemove(var/check_drift = 0)
//	return 1 //copypasta from carp code

/mob/living/simple_animal/hulk/attackby(var/obj/item/O as obj, var/mob/user as mob)
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
		usr << "\red This weapon is ineffective, it does no damage."
		for(var/mob/M in viewers(src, null))
			if ((M.client && !( M.blinded )))
				M.show_message("\red [user] gently taps [src] with [O]. ")

/mob/living/simple_animal/hulk/bullet_act(var/obj/item/projectile/P)
	..()
	if(istype(P, /obj/item/projectile/energy/electrode) || istype(P, /obj/item/projectile/beam/stun) || istype(P, /obj/item/projectile/bullet/stunslug) || istype(P, /obj/item/projectile/bullet/weakbullet))
		health -= P.agony / 3
