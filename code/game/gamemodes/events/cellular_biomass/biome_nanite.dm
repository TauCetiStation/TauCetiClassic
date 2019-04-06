/obj/effect/cellular_biomass_controller/nanite
	grow_speed = 4  //lower this value to speed up growth. 1 will process without cooldown.
	core_grow_chance = 5  //chance to spawn light core
	walls_type = /obj/structure/cellular_biomass/wall/nanite
	insides_type = /obj/structure/cellular_biomass/grass/nanite
	living_type = /obj/structure/cellular_biomass/lair/nanite
	cores_type = /obj/structure/cellular_biomass/core/nanite
	faction = "nanite"

/obj/structure/cellular_biomass/wall/nanite
	name = "Nanomachine cluster"
	desc = "They look so ... hungry"
	icon = 'code/game/gamemodes/events/cellular_biomass/nanite.dmi'

/obj/structure/cellular_biomass/grass/nanite
	name = "Wave of nanomachines"
	desc = "it pulsates..."
	icon = 'code/game/gamemodes/events/cellular_biomass/nanite.dmi'

/obj/structure/cellular_biomass/lair/nanite
	name = "Wave of nanomachines lair"
	desc = "They look so ... hungry"
	icon = 'code/game/gamemodes/events/cellular_biomass/nanite.dmi'

/obj/structure/cellular_biomass/core/nanite
	name = "Nanomachine cluster"
	desc = "They look so ... hungry"
	icon = 'code/game/gamemodes/events/cellular_biomass/nanite.dmi'
	light_color = "#8AE6FF"
	light_range = 3

/obj/structure/cellular_biomass/wall/nanite/atom_init()
	. = ..()
	icon_state = "nanitewall_1"

/obj/structure/cellular_biomass/grass/nanite/atom_init()
	. = ..()
	icon_state = "nanitefloor_[pick(1,2,3)]"

/obj/structure/cellular_biomass/core/nanite/atom_init()
	. = ..()
	icon_state = "nanite_[pick(1,2)]"

/obj/structure/cellular_biomass/lair/nanite/atom_init(mapload)
	icon_state = "lair"
	. = ..(mapload, pick(subtypesof(/mob/living/simple_animal/hostile/cellular/nanite)))

/mob/living/simple_animal/hostile/cellular/nanite
	name = "Nanite hivebot"
	desc = "A sanity-destroying otherthing."
	icon = 'code/game/gamemodes/events/cellular_biomass/nanite.dmi'
	speak_emote = list("gibbers")
	attacktext = "bites into"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	faction = "nanite"
	maxHealth = 60
	health = 60
	melee_damage_upper = 10
	melee_damage_lower = 5
	speed = 3

/mob/living/simple_animal/hostile/cellular/nanite/melee
	icon_state = "nanitemob_1"
	icon_living = "nanitemob_1"
	icon_dead = "nanitemobdead_1"
	maxHealth = 120
	health = 120
	melee_damage_upper = 10
	melee_damage_lower = 5
	speed = 3

/mob/living/simple_animal/hostile/cellular/nanite/ranged
	icon_state = "nanitemob_2"
	icon_living = "nanitemob_2"
	icon_dead = "nanitemobdead_2"
	health = 60
	maxHealth = 60
	melee_damage_lower = 15
	melee_damage_upper = 25
	speed = 1

/mob/living/simple_animal/hostile/cellular/nanite/eng
	icon_state = "nanitemob_3"
	icon_living = "nanitemob_3"
	icon_dead = "nanitemobdead_3"
	maxHealth = 120
	health = 120
	melee_damage_upper = 50
	melee_damage_lower = 40
	freeze_movement = TRUE
	light_power = 3
	light_range = 1.5
	light_color = "#00CC10"

/mob/living/simple_animal/hostile/cellular/nanite/melee/Life()
	..()
	if(health <= 0)
		return
	// spark for no reason
	if(prob(5))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
	if(health<=maxHealth/2)
		visible_message("<b>[src]</b> on impact duplicates!")
		var/mob/living/simple_animal/newnanite = new /mob/living/simple_animal/hostile/cellular/nanite/melee(src.loc)
		health = health / 2
		maxHealth = maxHealth/2
		newnanite.health = health
		newnanite.maxHealth = maxHealth/2

/mob/living/simple_animal/hostile/cellular/nanite/ranged/Life()
	..()
	if(health <= 0)
		return
	// spark for no reason
	if(prob(5))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
	if(health<=maxHealth/2)
		visible_message("<b>[src]</b> on impact duplicates!")
		var/mob/living/simple_animal/newnanite = new /mob/living/simple_animal/hostile/cellular/nanite/ranged(src.loc)
		health = health / 2
		maxHealth = maxHealth/2
		newnanite.health = health
		newnanite.maxHealth = maxHealth/2

/mob/living/simple_animal/hostile/cellular/nanite/eng/Life()
	..()
	if(health <= 0)
		return
	if(prob(5))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
	if(health<=maxHealth/2)
		visible_message("<b>[src]</b> on impact duplicates!")
		var/mob/living/simple_animal/newnanite = new /mob/living/simple_animal/hostile/cellular/nanite/eng(src.loc)
		health = health / 2
		maxHealth = maxHealth/2
		newnanite.health = health
		newnanite.maxHealth = maxHealth/2
	if(prob(3))
		if(prob(50))
			new /mob/living/simple_animal/hostile/cellular/nanite/ranged(src.loc)
		else
			new /mob/living/simple_animal/hostile/cellular/nanite/melee(src.loc)

/mob/living/simple_animal/hostile/cellular/nanite/emp_act(severity)
	death()

/mob/living/simple_animal/hostile/cellular/nanite/death()
	..()
	if(prob(80))
		visible_message("<b>[src]</b> blows apart!")
		new /obj/effect/gibspawner/robot(src.loc)
	qdel(src)
	return
