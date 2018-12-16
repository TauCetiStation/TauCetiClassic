
// Obelisk //
/obj/structure/obelisk
	name = "Pylon"
	desc = "A floating crystal that hums with an unearthly energy."
	density = 1
	anchored = 1
	icon = 'code/modules/custom_events/obelisk.dmi'
	icon_state = "obelisk"
	layer = INFRONT_MOB_LAYER
	light_color = "#ff0000"
	light_power = 2
	light_range = 6

// Xenomorphs //
/mob/living/simple_animal/hostile/cellular/meat/xenoarchaeologist_twisted
	name = "Twisted Scientist"
	desc = "Horrible looking creature, half-spider half-human. How is it even alive?!"
	icon = 'code/modules/custom_events/icons.dmi'
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
	icon = 'code/modules/custom_events/icons.dmi'
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

/mob/living/simple_animal/hostile/hivebot/robotic_horror
	name = "Twisted Robot"
	desc = "Some terrible way flesh has grown to this robot. An ugly hand, barely moving, holds a knife."
	icon = 'code/modules/custom_events/icons.dmi'
	icon_state = "robotic_horror"
	health = 150
	speed = 1
	melee_damage_lower = 10
	melee_damage_upper = 15
	ranged = 0
