/mob/living/simple_animal/hostile/pylon
	name = "pylon"
	real_name = "pylon"
	desc = "Ты не должен этого видеть."
	icon = 'icons/obj/cult.dmi'
	icon_state = "pylon_glow"
	icon_living = "pylon"
	ranged = TRUE
	amount_shoot = 3
	projectiletype = null
	projectilesound = null
	ranged_cooldown = 5
	ranged_cooldown_cap = 0
	maxHealth = 120
	health = 120
	melee_damage = 0
	speed = 0
	anchored = TRUE
	stop_automated_movement = TRUE
	canmove = FALSE
	faction = "cult"
	var/timer

/mob/living/simple_animal/hostile/pylon/atom_init()
	. = ..()
	friends = null

/mob/living/simple_animal/hostile/pylon/death(gibbed)
	. = ..()
	for(var/atom/A in contents)
		qdel(A)
	qdel(src)

/mob/living/simple_animal/hostile/pylon/proc/deactivate()
	return

/mob/living/simple_animal/hostile/pylon/proc/add_friend()
	return

/mob/living/simple_animal/hostile/pylon/attackby()
	return

/mob/living/simple_animal/hostile/pylon/update_canmove()
	return

/mob/living/simple_animal/hostile/pylon/UnarmedAttack(atom/A)
	SEND_SIGNAL(src, COMSIG_MOB_HOSTILE_ATTACKINGTARGET, A)
	OpenFire(A)
