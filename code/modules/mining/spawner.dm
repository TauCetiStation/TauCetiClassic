/mob/living/simple_animal/hostile/asteroid/spawner
	icon = 'icons/mob/spawner.dmi'
	desc = " Hole in the ground"
	freeze_movement = TRUE
	can_be_pulled = FALSE
	anchored = TRUE
	melee_damage = 0
	environment_smash = 0
	layer = 1
	pixel_x = -15
	pixel_y = -15
	var/max_mob = 3
	var/list/mob/living/simple_animal/hostile/asteroid/mobs = list()
	var/type_mob
	var/list/spawner_mod = list()

/mob/living/simple_animal/hostile/asteroid/spawner/atom_init()
	. = ..()
	gen_modifiers()
	spawner_mod += datum_components

/mob/living/simple_animal/hostile/asteroid/spawner/GiveTarget(new_target)
	target = new_target
	if(target != null)
		if(isliving(target))
			if(mobs.len < max_mob)
				var/mob/living/simple_animal/hostile/asteroid/M = new type_mob(src.loc)
				mobs += M
				for(var/MM in spawner_mod)
					M.AddComponent(MM,1)

/mob/living/simple_animal/hostile/asteroid/spawner/goliath
	name = "goliath nest"
	icon_state = "goliath"
	icon_dead = "goliath"
	icon_aggro = "goliath"
	type_mob = /mob/living/simple_animal/hostile/asteroid/goliath

/mob/living/simple_animal/hostile/asteroid/spawner/basilisk
	name = "basilisk nest"
	icon_state = "basilisk"
	icon_dead = "basilisk"
	icon_aggro ="basilisk"
	type_mob = /mob/living/simple_animal/hostile/asteroid/basilisk

/mob/living/simple_animal/hostile/asteroid/spawner/hivelord
	name = "hivelord nest"
	icon_state = "hivelord"
	icon_dead = "hivelord"
	icon_aggro = "hivelord"
	type_mob = /mob/living/simple_animal/hostile/asteroid/hivelord