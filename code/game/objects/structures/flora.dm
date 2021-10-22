// random plants
/obj/item/weapon/twohanded/flora
	name = "marvelous potted plant"
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "plant-10"
	only_twohand = TRUE
	force_unwielded = 2
	force_wielded = 5

/obj/item/weapon/twohanded/flora/atom_init()
	. = ..()
	AddComponent(/datum/component/tactical, null, FALSE)
	AddElement(/datum/element/beauty, 300)

/obj/item/weapon/twohanded/flora/random/atom_init()
	. = ..()
	var/newtype = pick(subtypesof(/obj/item/weapon/twohanded/flora/pottedplant))
	new newtype(get_turf(src))
	return INITIALIZE_HINT_QDEL

/obj/item/weapon/twohanded/flora/pottedplant
	name = "potted plant"
	desc = "Really brings the room together."
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "plant-1"

/obj/item/weapon/twohanded/flora/pottedplant/fern
	name = "potted fern"
	desc = "This is an ordinary looking fern. It looks like it could do with some water."
	icon_state = "plant-2"

/obj/item/weapon/twohanded/flora/pottedplant/overgrown
	name = "overgrown potted plants"
	desc = "This is an assortment of colourful plants. Some parts are overgrown."
	icon_state = "plant-3"

/obj/item/weapon/twohanded/flora/pottedplant/bamboo
	name = "potted bamboo"
	desc = "These are bamboo shoots. The tops looks like they've been cut short."
	icon_state = "plant-4"

/obj/item/weapon/twohanded/flora/pottedplant/largebush
	name = "large potted bush"
	desc = "This is a large bush. The leaves stick upwards in an odd fashion."
	icon_state = "plant-5"

/obj/item/weapon/twohanded/flora/pottedplant/thinbush
	name = "thin potted bush"
	desc = "This is a thin bush. It appears to be flowering."
	icon_state = "plant-6"

/obj/item/weapon/twohanded/flora/pottedplant/mysterious
	name = "mysterious potted bulbs"
	desc = "This is a mysterious looking plant. Touching the bulbs cause them to shrink."
	icon_state = "plant-7"

/obj/item/weapon/twohanded/flora/pottedplant/smalltree
	name = "small potted tree"
	desc = "This is a small tree. It is rather pleasant."
	icon_state = "plant-8"

/obj/item/weapon/twohanded/flora/pottedplant/unusual
	name = "unusual potted plant"
	desc = "This is an unusual plant. It's bulbous ends emit a soft blue light."
	icon_state = "plant-9"

/obj/item/weapon/twohanded/flora/pottedplant/unusual/atom_init()
	. = ..()
	set_light(2, 0.5, "#007fff")

/obj/item/weapon/twohanded/flora/pottedplant/orientaltree
	name = "potted oriental tree"
	desc = "This is a rather oriental style tree. It's flowers are bright pink."
	icon_state = "plant-10"

/obj/item/weapon/twohanded/flora/pottedplant/smallcactus
	name = "small potted cactus"
	desc = "This is a small cactus. Its needles are sharp."
	icon_state = "plant-11"

/obj/item/weapon/twohanded/flora/pottedplant/tall
	name = "tall potted plant"
	desc = "This is a tall plant. Tiny pores line its surface."
	icon_state = "plant-12"

/obj/item/weapon/twohanded/flora/pottedplant/sticky
	name = "sticky potted plant"
	desc = "This is an odd plant. Its sticky leaves trap insects."
	icon_state = "plant-13"

/obj/item/weapon/twohanded/flora/pottedplant/smelly
	name = "smelly potted plant"
	desc = "This is some kind of tropical plant. It reeks of rotten eggs."
	icon_state = "plant-14"

/obj/item/weapon/twohanded/flora/pottedplant/small
	name = "small potted plant"
	desc = "This is a pot of assorted small flora. Some look familiar."
	icon_state = "plant-15"

/obj/item/weapon/twohanded/flora/pottedplant/aquatic
	name = "aquatic potted plant"
	desc = "This is apparently an aquatic plant. It's probably fake."
	icon_state = "plant-16"

/obj/item/weapon/twohanded/flora/pottedplant/shoot
	name = "small potted shoot"
	desc = "This is a small shoot. It still needs time to grow."
	icon_state = "plant-17"

/obj/item/weapon/twohanded/flora/pottedplant/flower
	name = "potted flower"
	desc = "This is a slim plant. Sweet smelling flowers are supported by spindly stems."
	icon_state = "plant-18"

/obj/item/weapon/twohanded/flora/pottedplant/crystal
	name = "crystalline potted plant"
	desc = "These are rather cubic plants. Odd crystal formations grow on the end."
	icon_state = "plant-19"

/obj/item/weapon/twohanded/flora/pottedplant/subterranean
	name = "subterranean potted plant"
	desc = "This is a subterranean plant. It's bulbous ends glow faintly."
	icon_state = "plant-20"

/obj/item/weapon/twohanded/flora/pottedplant/subterranean/atom_init()
	. = ..()
	set_light(2, 0.5, "#ff6633")

/obj/item/weapon/twohanded/flora/pottedplant/minitree
	name = "potted tree"
	desc = "This is a miniature tree. Apparently it was grown to 1/5 scale."
	icon_state = "plant-21"

/obj/item/weapon/twohanded/flora/pottedplant/stoutbush
	name = "stout potted bush"
	desc = "This is a stout bush. Its leaves point up and outwards."
	icon_state = "plant-22"

/obj/item/weapon/twohanded/flora/pottedplant/drooping
	name = "drooping potted plant"
	desc = "This is a small plant. The drooping leaves make it look like its wilted."
	icon_state = "plant-23"

/obj/item/weapon/twohanded/flora/pottedplant/tropical_1
	name = "tropical potted plant"
	desc = "This is some kind of tropical plant. It hasn't begun to flower yet."
	icon_state = "plant-24"

/obj/item/weapon/twohanded/flora/pottedplant/dead
	name = "dead potted plant"
	desc = "This is the dried up remains of a dead plant. Someone should replace it."
	icon_state = "plant-25"

/obj/item/weapon/twohanded/flora/pottedplant/large
	name = "large potted plant"
	desc = "This is a large plant. Three branches support pairs of waxy leaves."
	icon_state = "plant-26"

/obj/item/weapon/twohanded/flora/pottedplant/tropicalfern
	name = "tropical fern"
	desc = "This is a tropical fern. It looks like it could do with some water"
	icon_state = "plant-27"

/obj/item/weapon/twohanded/flora/pottedplant/palm
	name = "palm potted plant"
	desc = "This is some kind of tropical palm. It is unlikely that you'll find coconuts under it."
	icon_state = "plant-28"

/obj/item/weapon/twohanded/flora/pottedplant/ficus
	name = "ficus plant"
	desc = "This is a ficus. Also known as fig tree."
	icon_state = "plant-29"

/obj/item/weapon/twohanded/flora/pottedplant/tropical_2
	name = "tropical potted plant"
	desc = "This is some kind of tropical plant. It has large smelly leaves without flowers."
	icon_state = "plant-30"

/obj/item/weapon/twohanded/flora/pottedplant/decorative
	name = "decorative potted plant"
	desc = "This is a decorative shrub. It's been trimmed into the shape of an apple."
	icon_state = "applebush"

/obj/item/weapon/twohanded/flora/pottedplant/cyberplant
	name = "cyberplant"
	desc = "cyberplant"
	icon = 'icons/obj/flora/cyberplants.dmi'
	icon_state = "holopot"
	var/brightness_on = 4
	var/emagged = FALSE
	var/icon/plant = null
	var/plant_color
	var/glow_color
	var/hologram_opacity = 0.85
	var/list/possible_colors = list(
		COLOR_RED_LIGHT,
		COLOR_CIVIE_GREEN,
		COLOR_LIGHT_CYAN,
		COLOR_SUN,
		COLOR_LIGHT_PINK,
		COLOR_VIOLET,
		COLOR_YELLOW,
	)
	var/list/possible_plants = null

/obj/item/weapon/twohanded/flora/pottedplant/cyberplant/atom_init()
	. = ..()
	possible_plants = icon_states(src.icon) - "holopot"
	change_plant(plant)
	change_color(plant_color)
	update_icon()
	set_light(brightness_on, brightness_on/2)

/obj/item/weapon/twohanded/flora/pottedplant/cyberplant/update_icon()
	..()
	cut_overlays()
	if (!plant)
		return
	plant.ChangeOpacity(hologram_opacity)
	add_overlay(plant)

/obj/item/weapon/twohanded/flora/pottedplant/cyberplant/proc/change_plant(state)
	plant = prepare_icon(state)

/obj/item/weapon/twohanded/flora/pottedplant/cyberplant/proc/prepare_icon(state)
	if(!state)
		state = pick(possible_plants)

	var/plant_icon = icon(icon, state)
	return getHologramIcon(plant_icon, 0, hologram_opacity)

/obj/item/weapon/twohanded/flora/pottedplant/cyberplant/proc/change_color(color)
	if (!plant)
		return

	if(!color)
		color = pick(possible_colors)

	glow_color = color
	plant_color = color
	plant.ColorTone(color)
	set_light(l_color=color)

/obj/item/weapon/twohanded/flora/pottedplant/cyberplant/attackby(obj/item/I, mob/user)
	. = ..()
	if(istype(I, /obj/item/weapon/card/id))
		change_plant()
		change_color()
		update_icon()
	return

/obj/item/weapon/twohanded/flora/monkey
	name = "monkeyplant"
	desc = "This is a monkey plant. Made by one mad scientist."
	icon_state = "monkeyplant"

/obj/item/weapon/twohanded/flora/deskfern
	name = "fancy ferny potted plant"
	desc = "This leafy desk fern could do with a trim."
	icon_state = "plant-31"

/obj/item/weapon/twohanded/flora/floorleaf
	name = "fancy leafy floor plant"
	desc = "This plant has remarkably waxy leaves."
	icon_state = "plant-32"

/obj/item/weapon/twohanded/flora/deskleaf
	name = "fancy leafy potted desk plant"
	desc = "A tiny waxy leafed plant specimen."
	icon_state = "plant-33"

/obj/item/weapon/twohanded/flora/deskferntrim
	name = "fancy trimmed ferny potted plant"
	desc = "This leafy desk fern seems to have been trimmed too much."
	icon_state = "plant-34"

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
	if(can_be_cut && W.is_sharp() && W.force >= damage_threshhold)
		playsound(src, cutting_sound, VOL_EFFECTS_MASTER)
		health_flora -= W.force
		if(health_flora <= 0)
			visible_message("<span class='warning'>[src] is hacked into pieces!</span>")
			if(drop_on_destroy.len)
				for(var/type_drop in drop_on_destroy)
					new type_drop(get_turf(src))
			qdel(src)
		return

// trees
/obj/structure/flora/tree
	name = "tree"
	anchored = TRUE
	density = TRUE
	pixel_x = -16
	layer = 9
	health_flora = 150
	damage_threshhold = 15
	can_be_cut = TRUE
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
	tree_xmas_list += src
	icon_state = "pine_c"

/obj/structure/flora/tree/pine/xmas/Destroy()
	tree_xmas_list -= src
	return ..()

/obj/structure/flora/tree/dead
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_1"

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

/obj/structure/flora/tree/jungle/atom_init()
	. = ..()
	icon_state = pick(icon_states(icon))

/obj/structure/flora/tree/jungle/small
	pixel_y = 0
	pixel_x = -32
	icon = 'icons/obj/flora/jungletreesmall.dmi'

// grass

/obj/structure/flora/grass
	name = "grass"
	icon = 'icons/obj/flora/snowflora.dmi'
	anchored = TRUE
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

// bushes

/obj/structure/flora/bush
	name = "bush"
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "snowbush1"
	anchored = TRUE
	can_be_cut = TRUE
	health_flora = 50

/obj/structure/flora/bush/atom_init()
	. = ..()
	icon_state = "snowbush[rand(1, 6)]"

// newbushes

/obj/structure/flora/ausbushes
	name = "bush"
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "firstbush_1"
	anchored = TRUE
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

// Jungle rocks

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

// Jungle bushes

/obj/structure/flora/junglebush
	name = "bush"
	desc = "A wild plant that is found in jungles."
	icon = 'icons/obj/flora/jungleflora.dmi'
	icon_state = "busha"
	anchored = TRUE
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
	density = TRUE
	pixel_x = -16
	pixel_y = -16

/obj/structure/flora/rock/pile/largejungle/atom_init()
	. = ..()
	icon_state = "[initial(icon_state)][rand(1,3)]"
