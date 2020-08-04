/obj/effect/cellular_biomass_controller/nanite
	grow_speed = 6  //lower this value to speed up growth. 1 will process without cooldown.
	core_grow_chance = 5  //chance to spawn light core
	walls_type = /obj/structure/cellular_biomass/wall/nanite
	insides_type = /obj/structure/cellular_biomass/grass/nanite
	living_type = /obj/structure/cellular_biomass/lair/nanite
	cores_type = /obj/structure/cellular_biomass/core/nanite
	landmarks_type = /obj/structure/cellular_biomass/cleanable/nanite
	faction = "nanite"


/obj/structure/cellular_biomass/wall/nanite
	name = "Nanomachine cluster"
	desc = "They look so ... hungry"
	icon = 'icons/obj/structures/cellular_biomass/nanite.dmi'

/obj/structure/cellular_biomass/grass/nanite
	name = "Wave of nanomachines"
	desc = "it pulsates..."
	icon = 'icons/obj/structures/cellular_biomass/nanite.dmi'
	plane = FLOOR_PLANE

/obj/structure/cellular_biomass/lair/nanite
	name = "Wave of nanomachines lair"
	desc = "They look so ... hungry"
	icon = 'icons/obj/structures/cellular_biomass/nanite.dmi'
	plane = FLOOR_PLANE

/obj/structure/cellular_biomass/core/nanite
	name = "Nanomachine cluster"
	desc = "They look so ... hungry"
	icon = 'icons/obj/structures/cellular_biomass/nanite.dmi'
	plane = FLOOR_PLANE
	light_color = "#8ae6ff"
	light_range = 3

/obj/structure/cellular_biomass/cleanable/nanite
	name = "Wave of nanomachines lair"
	desc = "They look so ... hungry"
	icon = 'icons/obj/structures/cellular_biomass/nanite.dmi'

/obj/structure/cellular_biomass/wall/nanite/atom_init()
	. = ..()
	icon_state = "nanitewall_1"

/obj/structure/cellular_biomass/grass/nanite/atom_init()
	. = ..()
	icon_state = "nanitefloor_[pick(1,2,3)]"

/obj/structure/cellular_biomass/core/nanite/atom_init()
	. = ..()
	icon_state = "nanite_[pick(1,2)]"

/obj/structure/cellular_biomass/cleanable/nanite/atom_init()
	. = ..()
	icon_state = "nanitemobdead_[pick(1,2)]"

/obj/structure/cellular_biomass/lair/nanite/atom_init(mapload)
	icon_state = "lair_2"
	if(prob(50))
		..(mapload, /mob/living/simple_animal/hostile/cellular/nanite/eng)
	return INITIALIZE_HINT_QDEL

/mob/living/simple_animal/hostile/cellular/nanite
	name = "Nanite hivebot"
	desc = "A sanity-destroying otherthing."
	icon = 'icons/obj/structures/cellular_biomass/nanite.dmi'
	speak_emote = list("gibbers")
	attacktext = "gnaw"
	attack_sound = list('sound/weapons/circsawhit.ogg')
	faction = "nanite"
	maxHealth = 60
	health = 60
	melee_damage = 8
	speed = 3
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	var/combohit = 0
	var/mob/living/simple_animal/hostile/cellular/nanite/eng/nanite_parent
	var/health_trigger = null
	var/clone = FALSE
	var/cloning = TRUE

/mob/living/simple_animal/hostile/cellular/nanite/melee
	icon_state = "nanitemob_1"
	icon_living = "nanitemob_1"
	icon_dead = "nanitemobdead_1"
	maxHealth = 80
	health = 80
	melee_damage = 8
	speed = 4

/mob/living/simple_animal/hostile/cellular/nanite/ranged
	ranged = TRUE
	projectiletype = /obj/item/projectile/bullet/smg
	projectilesound = 'sound/weapons/guns/gunshot_silencer.ogg'
	retreat_distance = 6
	minimum_distance = 6
	icon_state = "nanitemob_2"
	icon_living = "nanitemob_2"
	icon_dead = "nanitemobdead_2"
	health = 60
	maxHealth = 60
	melee_damage = 20
	speed = 3

/mob/living/simple_animal/hostile/cellular/nanite/eng
	icon_state = "nanitemob_3"
	icon_living = "nanitemob_3"
	icon_dead = "nanitemobdead_3"
	retreat_distance = 6
	maxHealth = 120
	health = 120
	melee_damage = 45
	freeze_movement = TRUE
	light_power = 3
	light_range = 1.5
	light_color = "#00cc10"
	anchored = TRUE
	var/cap_spawn = 6
	var/spawned = 0
	var/chance_spawn = 15
	var/list/mob/living/simple_animal/hostile/cellular/nanite/childs = list()
	cloning = FALSE

/mob/living/simple_animal/hostile/cellular/nanite/Life()
	..()
	if(health <= 0)
		qdel(src)
		return
	else
	// spark for no reason
		if(prob(5))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
		if(cloning == TRUE)
			if(health < maxHealth / 2)
				visible_message("<b>[src]</b> on impact duplicates!")
				var/mob/living/simple_animal/hostile/cellular/nanite/newnanite = new type(src.loc)
				health = health
				maxHealth = maxHealth / 2
				newnanite.health = health
				newnanite.maxHealth = maxHealth / 2
				newnanite.nanite_parent = nanite_parent
				newnanite.target = target
				newnanite.clone = TRUE
				newnanite.faction = faction
			if(nanite_parent != null)
				if(nanite_parent.health < health_trigger)
					stop_automated_movement = TRUE
					walk_to(src, nanite_parent.loc,0,2)
					if(nanite_parent.loc in oview(src, 2))
						health_trigger = nanite_parent.health
						stop_automated_movement = FALSE
						walk(src, 0)

/mob/living/simple_animal/hostile/cellular/nanite/eng/Life()
	..()
	if(childs.len < cap_spawn)
		if(prob(chance_spawn))
			var/type_to_spawn = prob(25) ? /mob/living/simple_animal/hostile/cellular/nanite/ranged : /mob/living/simple_animal/hostile/cellular/nanite/melee
			var/mob/living/simple_animal/hostile/cellular/nanite/S = new type_to_spawn(src.loc)
			S.nanite_parent = src
			S.health_trigger = health
			S.faction = faction
			childs += S

/mob/living/simple_animal/hostile/cellular/nanite/AttackingTarget()
	..()
	var/mob/L = target
	if(ismonkey(L))
		combohit += 1
		if(combohit == 4)
			var/mob/living/simple_animal/hostile/cyber_horror/N = new(L.loc)
			N.faction = faction
			combohit = 0
			L.gib()

/mob/living/simple_animal/hostile/cellular/nanite/emp_act(severity)
	death()

/mob/living/simple_animal/hostile/cellular/nanite/Destroy()
	if(nanite_parent)
		nanite_parent.childs -= src
	nanite_parent = null
	return ..()

/mob/living/simple_animal/hostile/cellular/nanite/eng/Destroy()
	for(var/mob/living/simple_animal/hostile/cellular/nanite/M in childs)
		M.death()
	return ..()

/mob/living/simple_animal/hostile/cellular/nanite/death()
	..()
	visible_message("<b>[src]</b> blows apart!")
	new /obj/effect/decal/cleanable/blood/gibs/robot(src.loc)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
	return
