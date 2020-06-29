/obj/effect/cellular_biomass_controller/mine
	living_grow_chance = 8
	walls_type =     /obj/structure/cellular_biomass/wall/mine
	insides_type =   /obj/structure/cellular_biomass/grass/mine
	living_type =     /obj/structure/cellular_biomass/lair/mine
	landmarks_type = /obj/effect/decal/cleanable/cellular/mine
	cores_type =     /obj/structure/cellular_biomass/core/mine
	faction = "mine"

/obj/structure/cellular_biomass/wall/mine
	name = "Cellular horror"
	desc = "Monstrum from another dimension. It just keeps spreading!"
	icon = 'icons/obj/structures/cellular_biomass/alien.dmi'

/obj/structure/cellular_biomass/grass/mine
	icon = 'icons/obj/structures/cellular_biomass/alien.dmi'

/obj/structure/cellular_biomass/lair/mine
	icon = 'icons/obj/structures/cellular_biomass/alien.dmi'

/obj/effect/decal/cleanable/cellular/mine
	icon = 'icons/obj/structures/cellular_biomass/alien.dmi'

/obj/structure/cellular_biomass/core/mine
	icon = 'icons/obj/structures/cellular_biomass/alien.dmi'
	light_color = "#710f8c"

/obj/effect/cellular_biomass_controller/mine/alive() //die only if all walls are removed
	if(!growth_queue)
		return 0
	if(!growth_queue.len)
		return 0
	return 1

/obj/effect/decal/cleanable/cellular/mine
	name = "gibs"
	desc = "Pieces of some kind of alien lifeform."
	icon = 'icons/obj/structures/cellular_biomass/alien.dmi'
	icon_state = "xeno_1"
	random_icon_states = list("xeno_1", "xeno_2","xeno_3","xeno_4","xeno_5","xeno_6","xeno_7","xeno_8","xeno_9","xeno_10","xeno_11","xeno_12","xeno_13")

/obj/structure/cellular_biomass/wall/mine/atom_init()
	. = ..()
	icon_state = "wall"

/obj/structure/cellular_biomass/grass/mine/atom_init()
	. = ..()
	icon_state = "weed[pick(1,2,3)]"

/obj/structure/cellular_biomass/core/mine/atom_init()
	. = ..()
	icon_state = "core"

/obj/structure/cellular_biomass/lair/mine/atom_init(mapload)
	icon_state = "lair"
	. = ..(mapload, pick(subtypesof(/mob/living/simple_animal/hostile/asteroid) - /mob/living/simple_animal/hostile/asteroid/hivelordbrood ))
