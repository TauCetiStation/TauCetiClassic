
/obj/machinery/auto_cloner
	name = "mysterious pod"
	desc = "It's full of a viscous liquid, but appears dark and silent."
	icon = 'icons/obj/xenoarchaeology/artifacts_64x32.dmi'
	icon_state = "autocloner_off"
	var/spawn_type
	var/time_spent_spawning = 0
	var/time_per_spawn = 0
	var/last_process= 0
	density = 1
	var/previous_power_state = 0

	use_power = IDLE_POWER_USE
	active_power_usage = 2000
	idle_power_usage = 1000

/obj/machinery/auto_cloner/atom_init()
	. = ..()

	time_per_spawn = rand(1200,3600)

	// 33% chance to spawn nasties
	if(prob(33))
		spawn_type = pick(\
		/mob/living/simple_animal/hostile/giant_spider/nurse,\
		/mob/living/simple_animal/hostile/xenomorph,\
		/mob/living/simple_animal/hostile/bear,\
		/mob/living/simple_animal/hostile/creature,\
		/mob/living/simple_animal/hostile/panther,\
		/mob/living/simple_animal/hostile/snake\
		)
	else
		spawn_type = pick(\
		/mob/living/simple_animal/shiba,\
		/mob/living/simple_animal/cat,\
		/mob/living/simple_animal/corgi,\
		/mob/living/simple_animal/corgi/puppy,\
		/mob/living/simple_animal/chicken,\
		/mob/living/simple_animal/cow,\
		/mob/living/simple_animal/parrot,\
		/mob/living/simple_animal/slime,\
		/mob/living/simple_animal/crab,\
		/mob/living/simple_animal/mouse,\
		/mob/living/simple_animal/hostile/retaliate/goat,\
		/mob/living/carbon/monkey\
		)

// todo: how the hell is the asteroid permanently powered?
/obj/machinery/auto_cloner/process()
	if(powered(power_channel))
		if(!previous_power_state)
			previous_power_state = 1
			icon_state = "autocloner_on"
			src.visible_message("<span class='notice'>[bicon(src)] [src] suddenly comes to life!</span>")

		// slowly grow a mob
		if(prob(5))
			src.visible_message("<span class='notice'>[bicon(src)] [src] [pick("gloops", "glugs", "whirrs", "whooshes", "hisses", "purrs", "hums", "gushes")].</span>")

		// if we've finished growing...
		if(time_spent_spawning >= time_per_spawn)
			time_spent_spawning = 0
			set_power_use(IDLE_POWER_USE)
			src.visible_message("<span class='notice'>[bicon(src)] [src] pings!</span>")
			icon_state = "autocloner_on"
			desc = "It's full of a bubbling viscous liquid, and is lit by a mysterious glow."
			if(spawn_type)
				new spawn_type(src.loc)

		// if we're getting close to finished, kick into overdrive power usage
		if(time_spent_spawning / time_per_spawn > 0.75)
			set_power_use(ACTIVE_POWER_USE)
			icon_state = "autocloner_process"
			desc = "It's full of a bubbling viscous liquid, and is lit by a mysterious glow. A dark shape appears to be forming inside..."
		else
			set_power_use(IDLE_POWER_USE)
			icon_state = "autocloner_on"
			desc = "It's full of a bubbling viscous liquid, and is lit by a mysterious glow."

		time_spent_spawning = time_spent_spawning + world.time - last_process
	else
		if(previous_power_state)
			previous_power_state = 0
			icon_state = "autocloner_off"
			src.visible_message("<span class='notice'>[bicon(src)] [src] suddenly shuts down.</span>")

		// cloned mob slowly breaks down
		time_spent_spawning = max(time_spent_spawning + last_process - world.time, 0)

	last_process = world.time
