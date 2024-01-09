//
// Sheet Exports
//

/datum/export/stack
	unit_name = "sheet"

/datum/export/stack/get_cost(O)
	return round(..(O))

/datum/export/stack/get_type_cost(export_type, amount = 1, contr = 0, emag = 0)
	return amount * cost

/datum/export/stack/get_amount(obj/O)
	var/obj/item/stack/S = O
	if(istype(S))
		return S.get_amount()
	return 0


// Leather, skin and other farming by-products.

/datum/export/stack/skin
	unit_name = ""

// Monkey hide. Cheap.
/datum/export/stack/skin/monkey
	cost = 30
	unit_name = "monkey hide"
	export_types = list(/obj/item/stack/sheet/animalhide/monkey)

// Human skin. Illegal
/datum/export/stack/skin/human
	cost = 400
	contraband = 1
	unit_name = "piece"
	message = "of human skin"
	export_types = list(/obj/item/stack/sheet/animalhide/human)

// Goliath hide. Expensive.
/datum/export/stack/skin/goliath_hide
	cost = 500
	unit_name = "goliath hide"
	export_types = list(/obj/item/asteroid/goliath_hide)

// Cat hide. Just in case Dusty is catsploding again.
/datum/export/stack/skin/cat
	cost = 400
	contraband = 1
	unit_name = "cat hide"
	export_types = list(/obj/item/stack/sheet/animalhide/cat)

// Corgi hide. You monster.
/datum/export/stack/skin/corgi
	cost = 500
	contraband = 1
	unit_name = "corgi hide"
	export_types = list(/obj/item/stack/sheet/animalhide/corgi)

// Lizard hide. Very expensive.
/datum/export/stack/skin/lizard
	cost = 1000
	unit_name = "lizard hide"
	export_types = list(/obj/item/stack/sheet/animalhide/lizard)

// Alien hide. Extremely expensive.
/datum/export/stack/skin/xeno
	cost = 3000
	unit_name = "alien hide"
	export_types = list(/obj/item/stack/sheet/animalhide/xeno)


// Common materials.

// Metal. Common building material.
/datum/export/stack/metal
	cost = 1
	message = "of metal"
	export_types = list(/obj/item/stack/sheet/metal)

// Glass. Common building material.
/datum/export/stack/glass
	cost = 1
	message = "of glass"
	export_types = list(/obj/item/stack/sheet/glass)

// Plasteel. Lightweight, strong and contains some plasma too.
/datum/export/stack/plasteel
	cost = 17
	message = "of plasteel"
	export_types = list(/obj/item/stack/sheet/plasteel)

// Reinforced Glass. Common building material. 1 glass + 0.5 metal
/datum/export/stack/rglass
	cost = 1.5
	message = "of reinforced glass"
	export_types = list(/obj/item/stack/sheet/rglass)

// Wood. Quite expensive in the grim and dark 26 century.
/datum/export/stack/wood
	cost = 15
	unit_name = "wood plank"
	export_types = list(/obj/item/stack/sheet/wood)

// Cardboard. Cheap.
/datum/export/stack/cardboard
	cost = 0.2
	message = "of cardboard"
	export_types = list(/obj/item/stack/sheet/cardboard)

// Sandstone. Literally dirt cheap.
/datum/export/stack/sandstone
	cost = 0.2
	unit_name = "block"
	message = "of sandstone"
	export_types = list(/obj/item/stack/sheet/mineral/sandstone)

// Cable.
/datum/export/stack/cable
	cost = 0.1
	unit_name = "cable piece"
	export_types = list(/obj/item/stack/cable_coil)

/datum/export/stack/cable/get_amount(obj/O)
	var/obj/item/stack/cable_coil/S = O
	if(istype(S))
		return S.get_amount()
	return 0

/datum/export/stack/bananium
	cost = 1000
	export_types = list(/obj/item/stack/sheet/mineral/clown)
	message = "of bananium"

// Diamonds. Rare and expensive.
/datum/export/stack/diamond
	cost = 500
	export_types = list(/obj/item/stack/sheet/mineral/diamond)
	message = "of diamonds"

// Phoron. The oil of 26 century. The reason why you are here.
/datum/export/stack/phoron
	cost = 70
	export_types = list(/obj/item/stack/sheet/mineral/phoron)
	message = "of phoron"

/datum/export/stack/phoron/get_cost(obj/O, contr = 0, emag = 0)
	. = ..(O)
	if(emag) // Syndicate pays you more for the plasma.
		. = round(. * 1.5)

// Refined scrap. The coal of 26 century. The reason why you are here.
/datum/export/stack/scrap
	cost = 35
	export_types = list(/obj/item/stack/sheet/refined_scrap)
	message = "of scrap"

// Uranium. Still useful for both power generation and nuclear annihilation.
/datum/export/stack/uranium
	cost = 80
	export_types = list(/obj/item/stack/sheet/mineral/uranium)
	message = "of uranium"

// Gold. Used in electronics and corrosion-resistant plating.
/datum/export/stack/gold
	cost = 50
	export_types = list(/obj/item/stack/sheet/mineral/gold)
	message = "of gold"

// Silver.
/datum/export/stack/silver
	cost = 20
	export_types = list(/obj/item/stack/sheet/mineral/silver)
	message = "of silver"

// Plastic.
/datum/export/stack/plastic
	cost = 4
	export_types = list(/obj/item/stack/sheet/mineral/plastic)
	message = "of plastic"

// Platinum.
/datum/export/stack/platinum
	cost = 200
	message = "of platinum"
	export_types = list(/obj/item/stack/sheet/mineral/platinum)

/datum/export/stack/nanopaste
	cost = 16
	message = "of nanopaste"
	export_types = list(/obj/item/stack/nanopaste)
