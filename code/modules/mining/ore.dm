/obj/item/weapon/ore
	name = "rock"
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore2"
	w_class = 2
	var/datum/geosample/geologic_data
	var/oretag
	var/points = 0
	var/refined_type = null //What this ore defaults to being refined into

/obj/item/weapon/ore/uranium
	name = "pitchblende"
	icon_state = "Uranium ore"
	origin_tech = "materials=5"
	oretag = "uranium"
	points = 20
	refined_type = /obj/item/stack/sheet/mineral/uranium

/obj/item/weapon/ore/iron
	name = "hematite"
	icon_state = "Iron ore"
	origin_tech = "materials=1"
	oretag = "hematite"
	points = 1
	refined_type = /obj/item/stack/sheet/mineral/iron

/obj/item/weapon/ore/coal
	name = "carbonaceous rock"
	icon_state = "Coal ore"
	origin_tech = "materials=1"
	oretag = "coal"
	points = 1
	refined_type = /obj/item/stack/sheet/mineral/plastic

/obj/item/weapon/ore/glass
	name = "impure silicates"
	icon_state = "Glass ore"
	origin_tech = "materials=1"
	oretag = "sand"
	points = 1
	refined_type = /obj/item/stack/sheet/glass

/obj/item/weapon/ore/phoron
	name = "phoron crystals"
	icon_state = "Phoron ore"
	origin_tech = "materials=2"
	oretag = "phoron"

/obj/item/weapon/ore/silver
	name = "native silver ore"
	icon_state = "Silver ore"
	origin_tech = "materials=3"
	oretag = "silver"
	points = 10
	refined_type = /obj/item/stack/sheet/mineral/silver

/obj/item/weapon/ore/gold
	name = "native gold ore"
	icon_state = "Gold ore"
	origin_tech = "materials=4"
	oretag = "gold"
	points = 20
	refined_type = /obj/item/stack/sheet/mineral/gold

/obj/item/weapon/ore/diamond
	name = "diamonds"
	icon_state = "Diamond ore"
	origin_tech = "materials=6"
	oretag = "diamond"

/obj/item/weapon/ore/osmium
	name = "raw platinum"
	icon_state = "Platinum ore"
	oretag = "platinum"
	origin_tech = "materials=4"
	points = 40
	refined_type = /obj/item/stack/sheet/mineral/platinum

/obj/item/weapon/ore/hydrogen
	name = "raw hydrogen"
	icon_state = "Phazon"
	oretag = "hydrogen"
	points = 10
	refined_type = /obj/item/stack/sheet/mineral/tritium

/obj/item/weapon/ore/clown
	name = "bananium ore"
	icon_state = "Clown ore"
	origin_tech = "materials=4"
	oretag = "bananium"

/obj/item/weapon/ore/slag
	name = "Slag"
	desc = "Completely useless."
	icon_state = "slag"
	oretag = "slag"

/obj/item/weapon/ore/New()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8
	if(src.z == ZLEVEL_ASTEROID) score["oremined"]++ //When ore spawns, increment score.  Only include ore spawned on mining asteroid.

/obj/item/weapon/ore/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/device/core_sampler))
		var/obj/item/device/core_sampler/C = W
		C.sample_item(src, user)
	else
		return ..()
