			/////////
			//Ghost//
			/////////

/mob/living/simple_animal/shade/howling_ghost
	name = "ghost"
	real_name = "ghost"
	icon = 'icons/mob/mob.dmi'
	maxHealth = 1e6
	health = 1e6
	speak_emote = list("howls")
	emote_hear = list("wails","screeches")
	density = FALSE
	anchored = TRUE
	incorporeal_move = 1
	layer = 4
	var/timer = 0

/mob/living/simple_animal/shade/howling_ghost/atom_init()
	. = ..()
	icon_state = pick("ghost","ghostian","ghostian2","ghostking","ghost1","ghost2")
	icon_living = icon_state
	status_flags |= GODMODE
	timer = rand(1,15)

/mob/living/simple_animal/shade/howling_ghost/Life()
	..()
	timer--
	if(prob(60))
		roam()
		if(prob(40))
			roam()
			roam()
			roam()
			roam()
			roam()
			roam()
	if(timer == 0)
		spooky_ghosty()
		timer = rand(1,15)

/mob/living/simple_animal/shade/howling_ghost/proc/EtherealMove(direction)
	forceMove(get_step(src, direction))

/mob/living/simple_animal/shade/howling_ghost/proc/roam()
	if(prob(80))
		var/direction = pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)
		EtherealMove(direction)

/mob/living/simple_animal/shade/howling_ghost/proc/spooky_ghosty()
	if(prob(20)) //haunt
		playsound(loc, pick('sound/spookoween/ghosty_wind.ogg','sound/spookoween/ghost_whisper.ogg','sound/spookoween/chain_rattling.ogg'), 300, 1)
	if(prob(20)) //flickers
		var/obj/machinery/light/L = locate(/obj/machinery/light) in view(5, src)
		if(L)
			L.flicker()
	if(prob(15)) //poltergeist
		var/obj/item/I = locate(/obj/item) in view(3, src)
		if(I)
			var/direction = pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)
			step(I,direction)
		return

/mob/living/simple_animal/shade/howling_ghost/attackby(obj/item/O, mob/user)  //Marker -Agouri
	if(O.force)
		var/damage = O.force
		if (O.damtype == HALLOSS)
			damage = 0
		health -= damage
		for(var/mob/M in viewers(src, null))
			if ((M.client && !( M.blinded )))
				M.show_message("\red \b [src] has been attacked with the [O] by [user]. ")
	else
		to_chat(usr, "\red This weapon is ineffective, it does no damage.")
		for(var/mob/M in viewers(src, null))
			if ((M.client && !( M.blinded )))
				M.show_message("\red [user] gently taps [src] with the [O]. ")
	return

/mob/living/simple_animal/shade/howling_ghost/CanPass(atom/movable/mover, turf/target)
	return 1


			////////////////
			//Insane Clown//
			////////////////

/mob/living/simple_animal/hostile/retaliate/clown/insane
	name = "Insane Clown"
	desc = "Some clowns do not manage to be accepted, and go insane. This is one of them. Run."
	icon = 'code/modules/halloween/halloween.dmi'
	icon_state = "scary_clown"
	icon_living = "scary_clown"
	icon_dead = "scary_clown_dead"
	icon_gib = "scary_clown_dead"
	speak = list("HONK!","Your life is a funny joke!"," Ha-Ha! I will murder you!","Run for your life!")
	speak_emote = list("laughs", "mocks")
	emote_hear = list("laughs", "mocks")
	speak_chance = 30
	maxHealth = 1e6
	health = 1e6
	turns_per_move = 3
	emote_see = list("silently stares")
	var/timer
	var/direction_stalk

/mob/living/simple_animal/hostile/retaliate/clown/insane/atom_init()
	. = ..()
	timer = rand(5,15)
	status_flags = (status_flags | GODMODE)
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/Retaliate()
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/Life()
	for(var/mob/living/carbon/human/H in range(15,src))
		if(!target)
			target = H
	timer--
	if(target)
		stalk()
	if(!client && speak_chance)
		if(rand(0,200) < speak_chance)
			if(speak && speak.len)
				if((emote_hear && emote_hear.len) || (emote_see && emote_see.len))
					var/length = speak.len
					if(emote_hear && emote_hear.len)
						length += emote_hear.len
					if(emote_see && emote_see.len)
						length += emote_see.len
					var/randomValue = rand(1,length)
					if(randomValue <= speak.len)
						say(pick(speak))
					else
						randomValue -= speak.len
						if(emote_see && randomValue <= emote_see.len)
							emote(pick(emote_see),1)
						else
							emote(pick(emote_hear),2)
				else
					say(pick(speak))
			else
				if(!(emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					emote(pick(emote_see),1)
				if((emote_hear && emote_hear.len) && !(emote_see && emote_see.len))
					emote(pick(emote_hear),2)
				if((emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					var/length = emote_hear.len + emote_see.len
					var/pick = rand(1,length)
					if(pick <= emote_see.len)
						emote(pick(emote_see),1)
					else
						emote(pick(emote_hear),2)

/mob/living/simple_animal/hostile/retaliate/clown/insane/proc/stalk()
	var/mob/living/M = target
	if(M.stat == DEAD)
		playsound(M.loc, 'sound/spookoween/insane_low_laugh.ogg', 300, 1)
		qdel(src)
	if(timer == 0)
		timer = rand(5,15)
		playsound(M.loc, pick('sound/spookoween/scary_horn.ogg','sound/spookoween/scary_horn2.ogg', 'sound/spookoween/scary_horn3.ogg'), 300, 1)
		spawn(12)
			var/turf/T = get_turf(src)
			var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
			sparks = new /datum/effect/effect/system/spark_spread()
			sparks.set_up(3, 0, get_turf(src))
			sparks.start()
			forceMove(M.loc)
			sparks = new /datum/effect/effect/system/spark_spread()
			sparks.set_up(3, 0, get_turf(src))
			sparks.start()
			direction_stalk = pick(NORTH,SOUTH,EAST,WEST)
			forceMove(get_step(src,direction_stalk))
			if(direction_stalk == NORTH)
				dir = SOUTH
			if(direction_stalk == SOUTH)
				dir = NORTH
			if(direction_stalk == EAST)
				dir = WEST
			if(direction_stalk == WEST)
				dir = EAST
			if(prob(50))
				if(ishuman(target))
					var/mob/living/carbon/human/H = target
					var/dam_zone = pick(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_L_LEG , BP_R_LEG)
					var/obj/item/organ/external/BP = H.bodyparts_by_name[ran_zone(dam_zone)]
					to_chat(target,"<span class='danger'>[src] claws [target] with his bloody hands.")
					H.apply_damage(rand(5,30), BRUTE, BP, H.run_armor_check(BP, "melee"), DAM_SHARP | DAM_EDGE)
			spawn(28)
				if(buckled)
					buckled.unbuckle_mob()
				sparks.set_up(3, 0, get_turf(src))
				sparks.start()
				var/turf/N = pick(orange(get_turf(T), 30))
				do_teleport(src, N, 4)
				sparks = new /datum/effect/effect/system/spark_spread()
				sparks.set_up(3, 0, get_turf(src))
				sparks.start()

/mob/living/simple_animal/hostile/retaliate/clown/insane/MoveToTarget()
	stalk(target)

/mob/living/simple_animal/hostile/retaliate/clown/insane/AttackingTarget()
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/nullrod))
		if(prob(20))
			visible_message("[src] finally found the peace it deserves. <i>You hear honks echoing off into the distance.</i>")
			playsound(loc, 'sound/spookoween/insane_low_laugh.ogg', 300, 1)
			icon_state = null
			var/atom/movable/overlay/clown_dead = null
			clown_dead = new(loc)
			clown_dead.icon_state = "blank"
			clown_dead.icon = 'code/modules/halloween/halloween.dmi'
			clown_dead.layer = 7
			clown_dead.master = src
			flick("scary_clown_dead", clown_dead)
			spawn(20)
				qdel(src)
				qdel(clown_dead)
		else
			visible_message("<span class='danger'>[src] seems to be resisting the effect!</span>")
	else
		..()

			/////////////////
			//Deadly Robots//
			/////////////////

/mob/living/simple_animal/hostile/hivebot/scavenger
	name = "Scavenger"
	desc = "A deadly looking robot! Strange liquid gurgles in its huge orange eyes."
	icon = 'code/modules/halloween/halloween.dmi'
	icon_state = "scavenger"
	health = 90
	speed = 4
	melee_damage_lower = 15
	melee_damage_upper = 20
	ranged = 0

/mob/living/simple_animal/hostile/hivebot/robotic_horror
	name = "Twisted Robot"
	desc = "Some terrible way flesh has grown to this robot. An ugly hand, barely moving, holds a knife."
	icon = 'code/modules/halloween/halloween.dmi'
	icon_state = "robotic_horror"
	health = 150
	speed = 1
	melee_damage_lower = 10
	melee_damage_upper = 15
	ranged = 0

			////////////////////
			//Twisted Monsters//
			////////////////////


/mob/living/simple_animal/hostile/cellular/meat/xenoarchaeologist_twisted
	name = "Twisted Scientist"
	desc = "Horrible looking creature, half-spider half-human. How is it even alive?!"
	icon = 'code/modules/halloween/halloween.dmi'
	icon_state = "xenoarchaeologist_twisted"
	icon_living = "xenoarchaeologist_twisted"
	icon_dead = "xenoarchaeologist_twisted_dead"
	health = 80
	maxHealth = 80
	melee_damage_lower = 15
	melee_damage_upper = 20
	move_speed = 18

/mob/living/simple_animal/hostile/cellular/meat/maid_twisted
	name = "Twisted Maid"
	desc = "Horrible looking creature. Poor woman..."
	icon = 'code/modules/halloween/halloween.dmi'
	icon_state = "maid_twisted"
	icon_living = "maid_twisted"
	icon_dead = "maid_twisted_dead"
	health = 70
	maxHealth = 70
	melee_damage_lower = 10
	melee_damage_upper = 15
	move_speed = 8

/mob/living/simple_animal/hostile/cellular/meat/xenoarchaeologist_twisted/death()
	..()
	if(prob(55))
		visible_message("<b>[src]</b> blows apart!")
		new /obj/effect/gibspawner/generic(src.loc)

/mob/living/simple_animal/hostile/cellular/meat/maid_twisted/death()
	..()
	if(prob(55))
		visible_message("<b>[src]</b> blows apart!")
		new /obj/effect/gibspawner/generic(src.loc)
