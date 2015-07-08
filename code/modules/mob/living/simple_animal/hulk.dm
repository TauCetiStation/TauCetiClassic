/mob/living/simple_animal/hulk
	name = "Hulk"
	real_name = "Hulk"
	desc = ""
	icon = 'icons/mob/hulk.dmi'
	icon_state = "hulk"
	icon_living = "hulk"
	maxHealth = 250
	health = 250
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
	environment_smash = 3

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

/mob/living/simple_animal/hulk/New()
	..()
	name = text("[initial(name)] ([rand(1, 1000)])")
	real_name = name
	for(var/spell in hulk_powers)
		spell_list += new spell(src)

/mob/living/simple_animal/hulk/death()
	..()
	ghostize(0)
	icon = 'icons/mob/hulk_dead.dmi'
	icon_state = "hulk_dead"
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
	//if(istype(M, /mob/living/simple_animal/hulk/builder))
	//	health += 5
	//	M.emote("mends some of \the <EM>[src]'s</EM> wounds.")
	//else
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


/mob/living/simple_animal/hulk/Life()
	weakened = 0
	if(health > 0)
		health = min(health + 1, maxHealth)
	..()

//mob/living/simple_animal/hulk/bullet_act(var/obj/item/projectile/P)
	//if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam))
	//	var/reflectchance = 80 - round(P.damage/3)
	//	if(prob(reflectchance))
	//		adjustBruteLoss(P.damage * 0.5)
	//		visible_message("<span class='danger'>The [P.name] gets reflected by [src]'s shell!</span>", \
	//						"<span class='userdanger'>The [P.name] gets reflected by [src]'s shell!</span>")

			// Find a turf near or on the original location to bounce to
	//		if(P.starting)
	//			var/new_x = P.starting.x + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
	//			var/new_y = P.starting.y + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
	//			var/turf/curloc = get_turf(src)

				// redirect the projectile
	//			P.original = locate(new_x, new_y, P.z)
	//			P.starting = curloc
	//			P.current = curloc
	//			P.firer = src
	//			P.yo = new_y - curloc.y
	//			P.xo = new_x - curloc.x

	//		return -1 // complete projectile permutation

//	return (..(P))
