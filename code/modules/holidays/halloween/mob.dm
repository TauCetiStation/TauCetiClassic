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
	emote_hear = list("wails", "screeches")
	density = FALSE
	anchored = TRUE
	incorporeal_move = 1
	status_flags = GODMODE
	faction = "untouchable"
	capturable = FALSE
	var/timer = 0

/mob/living/simple_animal/shade/howling_ghost/atom_init()
	. = ..()
	icon_state = pick("ghost", "ghostian", "ghostian2", "ghostking", "ghost1", "ghost2")
	icon_living = icon_state
	timer = rand(1, 15)

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
		EtherealMove(pick(alldirs))

/mob/living/simple_animal/shade/howling_ghost/proc/spooky_ghosty()
	if(prob(20)) //haunt
		playsound(loc, pick('sound/spookoween/ghosty_wind.ogg', 'sound/spookoween/ghost_whisper.ogg', 'sound/spookoween/chain_rattling.ogg'), VOL_EFFECTS_MASTER)
	if(prob(20)) //flickers
		var/obj/machinery/light/L = locate(/obj/machinery/light) in view(5, src)
		if(L)
			L.flicker()
	if(prob(15)) //poltergeist
		var/obj/item/I = locate(/obj/item) in view(3, src)
		if(I && !I.anchored)
			step(I, pick(alldirs))

/mob/living/simple_animal/shade/howling_ghost/CanPass(atom/movable/mover, turf/target)
	return 1


			////////////////
			//Insane Clown//
			////////////////

/obj/effect/temp_visual/banish
	icon = 'icons/holidays/halloween.dmi'
	icon_state = "scary_clown_dead"
	duration = 2 SECONDS

/mob/living/simple_animal/hostile/retaliate/clown/insane
	name = "Insane Clown"
	desc = "Some clowns do not manage to be accepted, and go insane. This is one of them. Run."
	icon = 'icons/holidays/halloween.dmi'
	icon_state = "scary_clown"
	icon_living = "scary_clown"
	icon_dead = null
	icon_gib = null
	speak = list("HONK!", "Your life is a funny joke!", " Ha-Ha! I will murder you!", "Run for your life!")
	speak_emote = list("laughs", "mocks")
	emote_hear = list("laughs", "mocks")
	speak_chance = 30
	maxHealth = 1e6
	health = 1e6
	turns_per_move = 3
	emote_see = list("silently stares")
	status_flags = GODMODE
	var/timer
	var/direction_stalk

/mob/living/simple_animal/hostile/retaliate/clown/insane/atom_init()
	. = ..()
	timer = rand(5, 15)

/mob/living/simple_animal/hostile/retaliate/clown/insane/Retaliate()
	return

/mob/living/simple_animal/hostile/retaliate/clown/insane/Life()
	if(stat != CONSCIOUS)
		return
	if(!target)
		target = locate(/mob/living/carbon/human) in range(15, src)
	timer--
	if(target)
		var/mob/living/M = target
		if(M.stat == DEAD)
			playsound(M.loc, 'sound/spookoween/insane_low_laugh.ogg', VOL_EFFECTS_MASTER)
			qdel(src)
			return
		if(timer <= 0)
			timer = rand(5, 15)
			stalk(M)
	if(!client && speak_chance)
		if(rand(0,200) < speak_chance)
			var/speak_len = speak?.len
			var/emote_hear_len = emote_hear?.len
			var/emote_see_len = emote_see?.len
			var/length = speak_len + emote_hear_len + emote_see_len
			if(length > 0)
				var/randomValue = rand(1, length)
				if(randomValue <= speak_len)
					say(speak[randomValue])
				else
					randomValue -= speak_len
					if(randomValue <= emote_hear_len)
						emote(emote_hear[randomValue], 2)
					else
						emote(emote_see[randomValue - emote_hear_len], 2)

/mob/living/simple_animal/hostile/retaliate/clown/insane/proc/stalk(mob/living/M)
	set waitfor = FALSE
	playsound(M.loc, pick('sound/spookoween/scary_horn.ogg', 'sound/spookoween/scary_horn2.ogg', 'sound/spookoween/scary_horn3.ogg'), VOL_EFFECTS_MASTER)
	
	sleep(1 SECOND)
	if(QDELING(src)) // banished
		return
	direction_stalk = pick(cardinal)
	dir = reverse_dir[direction_stalk]
	var/turf/T = get_step(M, direction_stalk)

	var/datum/effect/effect/system/spark_spread/sparks = new
	sparks.set_up(3, 0, loc)
	sparks.start()
	forceMove(T)
	sparks.set_up(3, 0, T)
	sparks.start()
	
	if(prob(50))
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/dam_zone = pick(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_L_LEG , BP_R_LEG)
			var/obj/item/organ/external/BP = H.bodyparts_by_name[ran_zone(dam_zone)]
			H.visible_message("<span class='danger'>[src] claws [target] with his bloody hands.</span>")
			H.apply_damage(rand(5, 30), BRUTE, BP, H.run_armor_check(BP, "melee"), DAM_SHARP | DAM_EDGE)

	sleep(2 SECONDS)
	if(QDELING(src)) // banished
		return
	if(buckled)
		buckled.unbuckle_mob()
	sparks.set_up(3, 0, loc)
	sparks.start()
	var/turf/N = pick(orange(30, src))
	do_teleport(src, N, 4)
	sparks.set_up(3, 0, loc)
	sparks.start()
	target = null

/mob/living/simple_animal/hostile/retaliate/clown/insane/death()
	..()
	new /obj/effect/temp_visual/banish(loc)
	qdel(src)

/mob/living/simple_animal/hostile/retaliate/clown/insane/attackby(obj/item/O, mob/user)
	if(!istype(O, /obj/item/weapon/nullrod))
		return ..()
	if(prob(20))
		visible_message("[src] finally found the peace it deserves. <i>You hear honks echoing off into the distance.</i>")
		playsound(loc, 'sound/spookoween/insane_low_laugh.ogg', VOL_EFFECTS_MASTER)
		death()
	else
		visible_message("<span class='danger'>[src] seems to be resisting the effect!</span>")

			/////////////////
			//Deadly Robots//
			/////////////////

/mob/living/simple_animal/hostile/hivebot/scavenger
	name = "Scavenger"
	desc = "A deadly looking robot! Strange liquid gurgles in its huge orange eyes."
	icon = 'icons/holidays/halloween.dmi'
	icon_state = "scavenger"
	health = 90
	speed = 4
	melee_damage = 15
	ranged = 0

/mob/living/simple_animal/hostile/hivebot/robotic_horror
	name = "Twisted Robot"
	desc = "Some terrible way flesh has grown to this robot. An ugly hand, barely moving, holds a knife."
	icon = 'icons/holidays/halloween.dmi'
	icon_state = "robotic_horror"
	health = 150
	speed = 1
	melee_damage = 10
	ranged = 0

			////////////////////
			//Twisted Monsters//
			////////////////////


/mob/living/simple_animal/hostile/cellular/meat/xenoarchaeologist_twisted
	name = "Twisted Scientist"
	desc = "Horrible looking creature, half-spider half-human. How is it even alive?!"
	icon = 'icons/holidays/halloween.dmi'
	icon_state = "xenoarchaeologist_twisted"
	icon_living = "xenoarchaeologist_twisted"
	icon_dead = "xenoarchaeologist_twisted_dead"
	health = 80
	maxHealth = 80
	melee_damage = 15
	move_speed = 18

/mob/living/simple_animal/hostile/cellular/meat/maid_twisted
	name = "Twisted Maid"
	desc = "Horrible looking creature. Poor woman..."
	icon = 'icons/holidays/halloween.dmi'
	icon_state = "maid_twisted"
	icon_living = "maid_twisted"
	icon_dead = "maid_twisted_dead"
	health = 70
	maxHealth = 70
	melee_damage = 10
	move_speed = 8

/mob/living/simple_animal/hostile/skellington
	name = "skellington"
	desc = "A skeleton, held together by scraps of skin and muscle. It sppears to be feral."
	icon = 'icons/holidays/halloween.dmi'
	icon_state = "skellington"
	melee_damage = 2
	attacktext = "punches"
	maxHealth = 50
	health = 50
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0

/mob/living/simple_animal/hostile/skellington/death()
	..()
	qdel(src)
