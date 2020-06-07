//SCP173 sprite by Lagoon Sadness - lagoon-sadnes.deviantart.com/art/SCP-173-RPG-sprite-sheet-502690979
/mob/living/simple_animal/special/scp173
	name = "friend"
	real_name = "friend"
	desc = "It's some kind of human sized, doll-like sculpture, with weird discolourations on some parts of it. It appears to be quite solid."
	icon = 'icons/mob/scp.dmi'
	icon_state = "scp_173"
	icon_living = "scp_173"
	maxHealth = INFINITY
	health = INFINITY
	immune_to_ssd = 1
	density = 1

	speak_emote = list("")
	emote_hear = list("")
	response_help  = "touches the"
	response_disarm = "pushes the"
	response_harm   = "hits the"

	harm_intent_damage = 0
	melee_damage = 0
	attacktext = "brutally crush"
	environment_smash = 0

	speed = 1
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	universal_speak = 1
	universal_understand = 1
	attack_sound = list('sound/weapons/punch1.ogg')
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	see_in_dark = 100

	has_head = TRUE
	has_arm = TRUE
	has_leg = TRUE

	var/life_cicle = 0
	var/next_cicle = 10
	var/activated = 0 //So, it wont start its massacre right away and can be delayed for event or what ever...

/mob/living/var/scp_mark = 0
/turf/var/scp_was_here = 0

/mob/living/simple_animal/special/scp173/atom_init()
	. = ..()
	for(var/mob/living/simple_animal/special/scp173/SA in mob_list) //only 1 can exist at the same time
		if(SA != src)
			qdel(SA)

/mob/living/simple_animal/special/scp173/Life()
	if(!activated) return

	if(istype(src.loc, /obj/structure/closet)) //Nope.avi
		var/obj/structure/closet/C = src.loc
		C.dump_contents()
		qdel(C)
	else if(!isturf(src.loc))
		loc = get_turf(src)

	for(var/obj/singularity/S in view(7,src))
		if(S)
			qdel(src)
			return

	life_cicle++
	var/did_move = 0
	var/list/turfs_around = list()
	if(life_cicle > next_cicle)
		next_cicle = rand(8,20)
		life_cicle = 0

		for(var/turf/T in view(7, src))
			if(istype(T,/turf/space)) continue
			turfs_around += T
			for(var/obj/item/F in T.contents)
				F.set_light(0)
			for(var/obj/machinery/L in T.contents)
				if(istype(L, /obj/machinery/power/apc))
					var/obj/machinery/power/apc/apc = L
					apc.overload_lighting(1)
				else if(istype(L, /obj/machinery/light))
					var/obj/machinery/light/Light = L
					Light.on = 0
					Light.update(0)
				else
					L.set_light(0)
			for(var/obj/effect/glowshroom/G in T.contents) //Very small radius
				qdel(G)
			for(var/mob/living/carbon/human/H in T.contents)
				for(var/obj/item/F in H)
					F.set_light(0)
					if(istype(F, /obj/item/device/flashlight)) //More survival!
						var/obj/item/device/flashlight/FL = F
						if(FL.on)
							H.drop_from_inventory(FL)
							if(prob(45)) //Poooof
								qdel(FL)
				H.set_light(0) //This is required with the object-based lighting
			for(var/mob/living/silicon/robot/R in T.contents)
				R.set_light(0)

	for(var/mob/living/L in view(7,src))
		if(L == src) continue
		var/turf/T = get_turf(L)
		if(istype(T,/turf/space)) continue

		var/light_amount = 0
		light_amount = round(T.get_lumcount()*10)

		if(light_amount <= 3)
			if(prob(max(1,L.scp_mark * 4)))
				src.loc = T
				src.dir = L.dir
				playsound(L, 'sound/effects/blobattack.ogg', VOL_EFFECTS_MASTER)
				L.gib()
				did_move = 1
			var/chance = rand(10,65)
			if(prob(chance))
				L.scp_mark++

	if(did_move)
		life_cicle = 0

	if(!did_move && turfs_around.len)
		var/no_where_to_jump = 0
		var/turf/target_turf = pick(turfs_around)
		for(var/i=0,i<4,i++)
			if(turfs_around.len)
				if(target_turf.scp_was_here)
					if(prob(3))
						target_turf.scp_was_here = 0
						break
					turfs_around -= target_turf
					if(turfs_around.len < 1)
						continue
					target_turf = pick(turfs_around)
					continue
				else
					break
			else
				no_where_to_jump = 1
				break

		if(!no_where_to_jump)
			target_turf.scp_was_here = 1
			loc = target_turf
			dir = pick(cardinal)
			playsound(src, 'sound/effects/scp_move.ogg', VOL_EFFECTS_MASTER)

/mob/living/simple_animal/special/scp173/death()
	return

 //Only singularity can harm us! Praise the lord singulo!
/mob/living/simple_animal/special/scp173/gib()
	return
/mob/living/simple_animal/special/scp173/dust()
	return
/mob/living/simple_animal/special/scp173/ex_act(severity)
	return

/mob/living/simple_animal/special/scp173/examine(mob/user)
	..()
	var/turf/T = get_turf(src)

	var/light_amount = 0
	light_amount = round(T.get_lumcount()*10)

	if(isliving(user))
		var/mob/living/L = user
		if(light_amount <= 3)
			var/msg = "<span cass='info'>It's too dark in there...</span>"
			to_chat(L, msg)
			return
		else
			L.scp_mark = 0

/mob/living/simple_animal/special/scp173/attack_animal(mob/living/simple_animal/M)
	M.emote("[M.friendly] \the <EM>[src]</EM>")

/mob/living/simple_animal/special/scp173/Process_Spacemove(movement_dir = 0)
	return 1 //copypasta from carp code

/mob/living/simple_animal/special/scp173/attackby(obj/item/O, mob/user)
	user.SetNextMove(CLICK_CD_MELEE)
	to_chat(user, "<span class='warning'>This weapon is ineffective, it does no damage.</span>")
	visible_message("<span class='warning'>[user] gently taps [src] with [O].</span>")

/mob/living/simple_animal/special/scp173/bullet_act(obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")
