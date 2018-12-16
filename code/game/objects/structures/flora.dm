//random plants
/obj/structure/flora
	name = "bush"
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "plant-10"
	var/can_be_cut = FALSE
	var/health_flora = 40
	var/damage_threshhold = 5
	var/cutting_sound = 'sound/weapons/bladeslice.ogg'
	var/list/drop_on_destroy = list()

/obj/structure/flora/attackby(obj/item/weapon/W, mob/user)
	. = ..()
	if(can_be_cut && is_sharp(W) && W.force >= damage_threshhold)
		playsound(src, cutting_sound, 50, 1)
		health_flora -= W.force
		if(health_flora <= 0)
			visible_message("<span class='warning'>[src] is hacked into pieces!</span>")
			if(drop_on_destroy.len)
				for(var/type_drop in drop_on_destroy)
					new type_drop(get_turf(src))
			qdel(src)
		return

/obj/structure/flora/plant
	name = "marvelous potted plant"
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "plant-10"

/obj/structure/flora/plant/random/atom_init()
	. = ..()
	icon_state = "plant-[rand(1, 31)]"

/obj/structure/flora/plant/monkey
	name = "monkeyplant"
	desc = "Made by one mad scientist."
	icon_state = "monkeyplant"

//trees
/obj/structure/flora/tree
	name = "tree"
	anchored = 1
	density = 1
	pixel_x = -16
	layer = 9
	health_flora = 150
	damage_threshhold = 15
	cutting_sound = 'sound/items/Axe.ogg'
	drop_on_destroy = list(/obj/item/weapon/grown/log, /obj/item/weapon/grown/log, /obj/item/weapon/grown/log, /obj/item/weapon/grown/log)


/obj/structure/flora/tree/pine
	name = "pine tree"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_1"

/obj/structure/flora/tree/pine/atom_init()
	. = ..()
	icon_state = "pine_[rand(1, 3)]"

/obj/structure/flora/tree/pine/xmas
	name = "xmas tree"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_c"

/obj/structure/flora/tree/pine/xmas/atom_init()
	. = ..()
	icon_state = "pine_c"

/obj/structure/flora/tree/dead
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_1"
	can_be_cut = TRUE

/obj/structure/flora/tree/dead/atom_init()
	. = ..()
	icon_state = "tree_[rand(1, 6)]"

/obj/structure/flora/tree/jungle
	name = "tree"
	icon_state = "tree"
	desc = "It's seriously hampering your view of the jungle."
	icon = 'icons/obj/flora/jungletrees.dmi'
	pixel_x = -48
	pixel_y = -20
	can_be_cut = TRUE

/obj/structure/flora/tree/jungle/atom_init()
	. = ..()
	icon_state = pick(icon_states(icon))

/obj/structure/flora/tree/jungle/small
	pixel_y = 0
	pixel_x = -32
	icon = 'icons/obj/flora/jungletreesmall.dmi'

//grass
/obj/structure/flora/grass
	name = "grass"
	icon = 'icons/obj/flora/snowflora.dmi'
	anchored = 1
	can_be_cut = TRUE
	health_flora = 60

/obj/structure/flora/grass/brown
	icon_state = "snowgrass1bb"

/obj/structure/flora/grass/brown/atom_init()
	. = ..()
	icon_state = "snowgrass[rand(1, 3)]bb"


/obj/structure/flora/grass/green
	icon_state = "snowgrass1gb"

/obj/structure/flora/grass/green/atom_init()
	. = ..()
	icon_state = "snowgrass[rand(1, 3)]gb"

/obj/structure/flora/grass/both
	icon_state = "snowgrassall1"

/obj/structure/flora/grass/both/atom_init()
	. = ..()
	icon_state = "snowgrassall[rand(1, 3)]"


//bushes
/obj/structure/flora/bush
	name = "bush"
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "snowbush1"
	anchored = 1
	can_be_cut = TRUE
	health_flora = 50

/obj/structure/flora/bush/atom_init()
	. = ..()
	icon_state = "snowbush[rand(1, 6)]"

/obj/structure/flora/pottedplant
	name = "potted plant"
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "plant-26"

//newbushes

/obj/structure/flora/ausbushes
	name = "bush"
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "firstbush_1"
	anchored = 1
	can_be_cut = TRUE
	health_flora = 50

/obj/structure/flora/ausbushes/atom_init()
	. = ..()
	icon_state = "firstbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/reedbush
	icon_state = "reedbush_1"

/obj/structure/flora/ausbushes/reedbush/atom_init()
	. = ..()
	icon_state = "reedbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/leafybush
	icon_state = "leafybush_1"

/obj/structure/flora/ausbushes/leafybush/atom_init()
	. = ..()
	icon_state = "leafybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/palebush
	icon_state = "palebush_1"

/obj/structure/flora/ausbushes/palebush/atom_init()
	. = ..()
	icon_state = "palebush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/stalkybush
	icon_state = "stalkybush_1"

/obj/structure/flora/ausbushes/stalkybush/atom_init()
	. = ..()
	icon_state = "stalkybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/grassybush
	icon_state = "grassybush_1"

/obj/structure/flora/ausbushes/grassybush/atom_init()
	. = ..()
	icon_state = "grassybush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/fernybush
	icon_state = "fernybush_1"

/obj/structure/flora/ausbushes/fernybush/atom_init()
	. = ..()
	icon_state = "fernybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/sunnybush
	icon_state = "sunnybush_1"

/obj/structure/flora/ausbushes/sunnybush/atom_init()
	. = ..()
	icon_state = "sunnybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/genericbush
	icon_state = "genericbush_1"

/obj/structure/flora/ausbushes/genericbush/atom_init()
	. = ..()
	icon_state = "genericbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/pointybush
	icon_state = "pointybush_1"

/obj/structure/flora/ausbushes/pointybush/atom_init()
	. = ..()
	icon_state = "pointybush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/lavendergrass
	icon_state = "lavendergrass_1"

/obj/structure/flora/ausbushes/lavendergrass/atom_init()
	. = ..()
	icon_state = "lavendergrass_[rand(1, 4)]"

/obj/structure/flora/ausbushes/ywflowers
	icon_state = "ywflowers_1"

/obj/structure/flora/ausbushes/ywflowers/atom_init()
	. = ..()
	icon_state = "ywflowers_[rand(1, 3)]"

/obj/structure/flora/ausbushes/brflowers
	icon_state = "brflowers_1"

/obj/structure/flora/ausbushes/brflowers/atom_init()
	. = ..()
	icon_state = "brflowers_[rand(1, 3)]"

/obj/structure/flora/ausbushes/ppflowers
	icon_state = "ppflowers_1"

/obj/structure/flora/ausbushes/ppflowers/atom_init()
	. = ..()
	icon_state = "ppflowers_[rand(1, 4)]"

/obj/structure/flora/ausbushes/sparsegrass
	icon_state = "sparsegrass_1"

/obj/structure/flora/ausbushes/sparsegrass/atom_init()
	. = ..()
	icon_state = "sparsegrass_[rand(1, 3)]"

/obj/structure/flora/ausbushes/fullgrass
	icon_state = "fullgrass_1"

/obj/structure/flora/ausbushes/fullgrass/atom_init()
	. = ..()
	icon_state = "fullgrass_[rand(1, 3)]"

//Jungle rocks

/obj/structure/flora/rock/jungle
	icon_state = "pile of rocks"
	desc = "A pile of rocks."
	icon_state = "rock"
	icon = 'icons/obj/flora/jungleflora.dmi'
	density = FALSE
	can_be_cut = TRUE
	health_flora = 50

/obj/structure/flora/rock/jungle/atom_init()
	. = ..()
	icon_state = "[initial(icon_state)][rand(1,5)]"

//Jungle bushes

/obj/structure/flora/junglebush
	name = "bush"
	desc = "A wild plant that is found in jungles."
	icon = 'icons/obj/flora/jungleflora.dmi'
	icon_state = "busha"
	anchored = 1
	can_be_cut = TRUE
	health_flora = 40

/obj/structure/flora/junglebush/atom_init()
	. = ..()
	icon_state = "[icon_state][rand(1, 3)]"

/obj/structure/flora/junglebush/b
	icon_state = "bushb"

/obj/structure/flora/junglebush/c
	icon_state = "bushc"

/obj/structure/flora/junglebush/large
	icon_state = "bush"
	icon = 'icons/obj/flora/largejungleflora.dmi'
	pixel_x = -16
	pixel_y = -12
	layer = 9

/obj/structure/flora/rock/pile/largejungle
	name = "rocks"
	icon_state = "rocks"
	icon = 'icons/obj/flora/largejungleflora.dmi'
	density = 1
	pixel_x = -16
	pixel_y = -16

/obj/structure/flora/rock/pile/largejungle/atom_init()
	. = ..()
	icon_state = "[initial(icon_state)][rand(1,3)]"