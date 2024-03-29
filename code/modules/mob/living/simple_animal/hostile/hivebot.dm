/obj/item/projectile/hivebotbullet
	damage = 10
	damage_type = BRUTE

/mob/living/simple_animal/hostile/hivebot
	name = "Hivebot"
	desc = "Кажется, оно хочет кого-то убить..."
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	health = 15
	maxHealth = 15
	melee_damage = 3
	attacktext = "claw"
	projectilesound = 'sound/weapons/guns/Gunshot.ogg'
	projectiletype = /obj/item/projectile/hivebotbullet
	faction = "hivebot"
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	speed = 4
	typing_indicator_type = "machine"

	animalistic = FALSE
	has_arm = TRUE
	has_leg = TRUE

/mob/living/simple_animal/hostile/hivebot/range
	name = "Hivebot"
	desc = "Кажется, оно хочет кого-то убить... Даже есть чем!"
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/rapid
	ranged = TRUE
	amount_shoot = 3
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/strong
	name = "Strong Hivebot"
	desc = "Этот робот вооружен и выглядит крутым!"
	health = 80
	ranged = TRUE

/mob/living/simple_animal/hostile/hivebot/death()
	..()
	visible_message("<b>[src]</b> blows apart!")
	new /obj/effect/decal/cleanable/blood/gibs/robot(src.loc)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
	return

/mob/living/simple_animal/hostile/hivebot/tele//this still needs work
	name = "Beacon"
	desc = "Какая-то странная штука с маячком."
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "def_radar-off"
	icon_living = "def_radar-off"
	health = 200
	maxHealth = 200
	status_flags = 0
	stop_automated_movement = TRUE
	var/bot_type = "norm"
	var/bot_amt = 10
	var/spawn_delay = 600
	var/turn_on = 0
	var/auto_spawn = 1

/mob/living/simple_animal/hostile/hivebot/tele/atom_init()
	. = ..()
	var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
	smoke.set_up(5, 0, src.loc)
	smoke.start()
	visible_message("<span class='warning'><B>The [src] warps in!</B></span>")
	playsound(src, 'sound/effects/EMPulse.ogg', VOL_EFFECTS_MASTER, 25)

/mob/living/simple_animal/hostile/hivebot/tele/proc/warpbots()
	icon_state = "def_radar"
	visible_message("<span class='warning'>The [src] turns on!</span>")
	while(bot_amt > 0)
		bot_amt--
		switch(bot_type)
			if("norm")
				new /mob/living/simple_animal/hostile/hivebot(get_turf(src))
			if("range")
				new /mob/living/simple_animal/hostile/hivebot/range(get_turf(src))
			if("rapid")
				new /mob/living/simple_animal/hostile/hivebot/rapid(get_turf(src))
	spawn(100)
		qdel(src)
	return

/mob/living/simple_animal/hostile/hivebot/tele/Life()
	..()
	if(stat == CONSCIOUS)
		if(prob(2))//Might be a bit low, will mess with it likely
			warpbots()

