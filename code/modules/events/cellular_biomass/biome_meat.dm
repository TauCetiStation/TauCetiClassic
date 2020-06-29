/obj/effect/cellular_biomass_controller/meat
	walls_type =     /obj/structure/cellular_biomass/wall/meat
	insides_type =   /obj/structure/cellular_biomass/grass/meat
	living_type =     /obj/structure/cellular_biomass/lair/meat
	landmarks_type = /obj/effect/decal/cleanable/cellular/meat
	cores_type =     /obj/structure/cellular_biomass/core/meat
	faction = "meat"

/obj/structure/cellular_biomass/wall/meat
	name = "Cellular horror"
	desc = "You don't whant to know what is this..."
	desc = "Monstrum from another dimension. It just keeps spreading!"
	icon = 'icons/obj/structures/cellular_biomass/meatland_cellular.dmi'

/obj/structure/cellular_biomass/grass/meat
	name = "Cellular horror surface"
	desc = "You don't whant to know what is this..."
	icon = 'icons/obj/structures/cellular_biomass/meatland_cellular.dmi'

/obj/structure/cellular_biomass/lair/meat
	name = "Cellular horror lair"
	desc = "You don't whant to know what is this..."
	icon = 'icons/obj/structures/cellular_biomass/meatland_cellular.dmi'

/obj/structure/cellular_biomass/core/meat
	name = "Cellular horror"
	desc = "You don't whant to know what is this..."
	icon = 'icons/obj/structures/cellular_biomass/meatland_cellular.dmi'
	light_color = "#710f8c"

/obj/effect/decal/cleanable/cellular/meat
	name = "horror"
	desc = "You don't whant to know what is this..."
	icon = 'icons/obj/structures/cellular_biomass/meatland_cellular.dmi'
	icon_state = "creep_1"
	random_icon_states = list("creep_1", "creep_2", "creep_3", "creep_4", "creep_5", "creep_6", "creep_7", "creep_8", "creep_9")

/obj/structure/cellular_biomass/wall/meat/atom_init()
	. = ..()
	icon_state = "bloodwall_[pick(1,1,2,2,3,4)]"

/obj/structure/cellular_biomass/grass/meat/atom_init()
	. = ..()
	icon_state = "bloodfloor_[pick(1,2,3)]"

/obj/structure/cellular_biomass/core/meat/atom_init()
	. = ..()
	icon_state = "light_[pick(1,2)]"

/obj/structure/cellular_biomass/lair/meat/atom_init(mapload)
	icon_state = "lair"
	. = ..(mapload, pick(subtypesof(/mob/living/simple_animal/hostile/cellular/meat)))

/mob/living/simple_animal/hostile/cellular/meat
	name = "insane creature"
	desc = "A sanity-destroying otherthing."
	icon = 'icons/obj/structures/cellular_biomass/meatland_cellular.dmi'
	speak_emote = list("gibbers")
	attacktext = "brutally chomp"
	attack_sound = list('sound/weapons/bite.ogg')
	faction = "meat"

/mob/living/simple_animal/hostile/cellular/meat/creep_standing
	icon_state = "light"
	icon_living = "light"
	icon_dead = "light-dead"
	health = 160
	maxHealth = 160
	melee_damage = 38
	move_speed = 25

/mob/living/simple_animal/hostile/cellular/meat/maniac
	icon_state = "sovmeat"
	icon_living = "sovmeat"
	icon_dead = "sovmeat-dead"
	health = 50
	maxHealth = 50
	melee_damage = 14
	move_speed = 4

/mob/living/simple_animal/hostile/cellular/meat/changeling
	icon_state = "horrormeat"
	icon_living = "horrormeat"
	icon_dead = "horrormeat-dead"
	health = 80
	maxHealth = 80
	melee_damage = 25
	move_speed = 15

/mob/living/simple_animal/hostile/cellular/meat/flesh
	icon_state = "livingflesh"
	icon_living = "livingflesh"
	icon_dead = "livingflesh-dead"
	health = 80
	maxHealth = 80
	melee_damage = 25
	move_speed = 15

/mob/living/simple_animal/hostile/cellular/meat/death()
	..()
	if(prob(80))
		visible_message("<b>[src]</b> blows apart!")
		new /obj/effect/gibspawner/generic(src.loc)
	qdel(src)
	return
