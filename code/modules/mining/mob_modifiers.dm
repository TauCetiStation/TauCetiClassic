/datum/mob_modifier
	var/modifier_name = "Normal"

/datum/mob_modifier/proc/apply(modifier)
	modify_stats(modifier)

/datum/mob_modifier/proc/modify_stats(mob/living/simple_animal/hostile/A)
	A.name = "[modifier_name] [A.name]"

//////HEALTHY//////

/datum/mob_modifier/healthy
	modifier_name = "Healthy"

/datum/mob_modifier/healthy/modify_stats(mob/living/simple_animal/hostile/A)
	. = ..()
	A.maxHealth *= 1.5
	A.health = A.maxHealth

//////FRAIL//////

/datum/mob_modifier/frail
	modifier_name = "Frail"

/datum/mob_modifier/frail/modify_stats(mob/living/simple_animal/hostile/A)
	. = ..()
	A.maxHealth *= 0.7
	A.health = A.maxHealth

////////FAST///////

/datum/mob_modifier/fast
	modifier_name = "Fast"

/datum/mob_modifier/fast/modify_stats(mob/living/simple_animal/hostile/A)
	. = ..()
	if(A.speed >= 2)
		A.speed -= 2
	if(A.move_to_delay >= 13) //to exclude very fast mobs.
		A.move_to_delay -= 10

///////SLOW////////

/datum/mob_modifier/slow
	modifier_name = "Slow"

/datum/mob_modifier/slow/modify_stats(mob/living/simple_animal/hostile/A)
	. = ..()
	A.speed += 2
	A.move_to_delay += 10

//////STRONG///////

/datum/mob_modifier/strong
	modifier_name = "Strong"

/datum/mob_modifier/strong/modify_stats(mob/living/simple_animal/hostile/A)
	. = ..()
	A.maxHealth *= 1.2
	A.health = A.maxHealth
	A.melee_damage *= 1.5

///////WEAK////////

/datum/mob_modifier/weak
	modifier_name = "Weak"

/datum/mob_modifier/weak/modify_stats(mob/living/simple_animal/hostile/A)
	. = ..()
	A.maxHealth *= 0.8
	A.health = A.maxHealth
	A.melee_damage *= 0.7

//MEGA STRONG(mini-boss)//

/datum/mob_modifier/mega
	modifier_name = "MEGA STRONG"

/datum/mob_modifier/mega/modify_stats(mob/living/simple_animal/hostile/A)
	. = ..()
	A.maxHealth *= 2
	A.health = A.maxHealth
	A.melee_damage *= 2
	if(A.speed >= 2)
		A.speed -= 2
	if(A.move_to_delay >= 13) //to exclude very fast mobs.
		A.move_to_delay -= 10

//////USELESS//////

/datum/mob_modifier/useless
	modifier_name = "Useless"

/datum/mob_modifier/useless/modify_stats(mob/living/simple_animal/hostile/A)
	. = ..()
	A.maxHealth *= 0.3
	A.health = A.maxHealth
	A.melee_damage *= 0.3
	A.speed += 4
	A.move_to_delay += 15
