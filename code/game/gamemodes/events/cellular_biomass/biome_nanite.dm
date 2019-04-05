/obj/effect/cellular_biomass_controller/nanite
	grow_speed = 5           //lower this value to speed up growth. 1 will process without cooldown.
	core_grow_chance = 5     //chance to spawn light core
	walls_type =     /obj/structure/cellular_biomass/wall/nanite
	insides_type =   /obj/structure/cellular_biomass/grass/nanite
	living_type =     /obj/structure/cellular_biomass/lair/nanite
	cores_type =     /obj/structure/cellular_biomass/core/nanite
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
	health = 30
	maxHealth = 30
	melee_damage_lower = 5
	melee_damage_upper = 15
	speed = 2
	faction = "nanite"

/mob/living/simple_animal/hostile/cellular/nanite/melee
	icon_state = "nanitemob_1"
	icon_living = "nanitemob_1"
	icon_dead = "nanitemobdead_1"

/mob/living/simple_animal/hostile/cellular/nanite/ranged
	icon_state = "nanitemob_2"
	icon_living = "nanitemob_2"
	icon_dead = "nanitemobdead_2"

/mob/living/simple_animal/hostile/cellular/nanite/ranged/attackby(obj/item/weapon/W, mob/user)
	if(health>2)
		visible_message("<b>[src]</b> on impact duplicates!")
		var/mob/living/simple_animal/newnanite = new /mob/living/simple_animal/hostile/cellular/nanite/melee(src.loc)
		health = health / 2
		newnanite.health = health

/mob/living/simple_animal/hostile/cellular/nanite/melee/bullet_act()
	if(health>2)
		visible_message("<b>[src]</b> when fired duplicates!")
		var/mob/living/simple_animal/newnanite = new /mob/living/simple_animal/hostile/cellular/nanite/melee(src.loc)
		health = health / 2
		newnanite.health = health
	return

/mob/living/simple_animal/hostile/cellular/nanite/melee/emp_act(severity)
	death()

/mob/living/simple_animal/hostile/cellular/nanite/ranged/emp_act(severity)
	death()

/mob/living/simple_animal/hostile/cellular/nanite/death()
	..()
	if(prob(80))
		visible_message("<b>[src]</b> blows apart!")
		new /obj/effect/gibspawner/robot(src.loc)
	qdel(src)
	return