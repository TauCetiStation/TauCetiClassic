/datum/gear/suit
	display_name = "Apron, blue"
	path = /obj/item/clothing/suit/apron
	slot = slot_wear_suit
	sort_category = "Suits and Overwear"
	cost = 2

/datum/gear/suit/leather_coat
	display_name = "Leather coat"
	path = /obj/item/clothing/suit/leathercoat

/datum/gear/suit/leather_jacket
	display_name = "Leather jacket"
	path = /obj/item/clothing/suit/jacket/leather

/datum/gear/suit/overalls
	display_name = "Overalls"
	path = /obj/item/clothing/suit/apron/overalls
	cost = 1

/datum/gear/suit/poncho
	display_name = "Poncho"
	path = /obj/item/clothing/suit/poncho
	cost = 1

/datum/gear/suit/ian_shirt
	display_name = "Ian Shirt"
	path = /obj/item/clothing/suit/ianshirt
	cost = 1

/datum/gear/suit/nerd_shirt
	display_name = "Nerd Shirt"
	path = /obj/item/clothing/suit/nerdshirt
	cost = 1

/datum/gear/suit/unathi_robe
	display_name = "Roughspun robe"
	path = /obj/item/clothing/suit/unathi/robe
	cost = 1

/datum/gear/suit/suspenders
	display_name = "Suspenders"
	path = /obj/item/clothing/suit/suspenders

/datum/gear/suit/wcoat
	display_name = "Waistcoat"
	path = /obj/item/clothing/suit/wcoat
	cost = 1



/datum/gear/under
	path = /obj/item/clothing/under/blacktango
	display_name = "Black tango dress"
	slot = slot_w_uniform
	sort_category = "Suits and Overwear"

/datum/gear/under/suit_jacket
	display_name = "Suit jacket selection"
	path = /obj/item/clothing/under/suit_jacket/navy

/datum/gear/under/suit_jacket/New()
	..()
	var/jackets = list()
	jackets["navy"] = /obj/item/clothing/under/suit_jacket/navy
	jackets["black"] = /obj/item/clothing/under/suit_jacket/really_black
	jackets["burgundy"] = /obj/item/clothing/under/suit_jacket/burgundy
	jackets["charcoal"] = /obj/item/clothing/under/suit_jacket/charcoal
	jackets["white"] = /obj/item/clothing/under/suit_jacket/white
	gear_tweaks += new/datum/gear_tweak/path(jackets)

/datum/gear/under/pants
	display_name = "Pants selection"
	path = /obj/item/clothing/under/pants/white

/datum/gear/under/pants/New()
	..()
	var/list/pants = list()
	for(var/pant in typesof(/obj/item/clothing/under/pants))
		var/obj/item/clothing/under/pants/pant_type = pant
		pants[initial(pant_type.name)] = pant_type
	gear_tweaks += new/datum/gear_tweak/path(sortAssoc(pants))

/datum/gear/under/jumpsuit
	display_name = "Generic jumpsuits"
	path = /obj/item/clothing/under/color/grey

/datum/gear/under/jumpsuit/New()
	..()
	var/list/jumpsuits = list()
	for(var/color in typesof(/obj/item/clothing/under/color))
		var/obj/item/clothing/under/color/color_type = color
		jumpsuits[initial(color_type.name)] = color_type
	gear_tweaks += new/datum/gear_tweak/path(sortAssoc(jumpsuits))

/datum/gear/under/kilt
	display_name = "Kilt"
	path = /obj/item/clothing/under/kilt