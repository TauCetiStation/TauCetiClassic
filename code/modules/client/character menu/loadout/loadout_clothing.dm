/datum/gear/suit
	display_name = "Apron, blue"
	path = /obj/item/clothing/suit/apron
	slot = SLOT_WEAR_SUIT
	sort_category = "Suits and Overwear"
	cost = 2

/datum/gear/under
	display_name = "Black tango dress"
	path = /obj/item/clothing/under/blacktango
	slot = SLOT_W_UNIFORM
	sort_category = "Suits and Overwear"
	cost = 1

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

/datum/gear/suit/kung
	display_name = "Kung jacket"
	path = /obj/item/clothing/suit/fluff/kung
	cost = 1

/datum/gear/suit/serifcoat
	display_name = "Serif coat"
	path = /obj/item/clothing/suit/serifcoat
	cost = 1

/datum/gear/suit/labcoat
	display_name = "Labcoat selection"
	path = /obj/item/clothing/suit/storage/labcoat

/datum/gear/suit/labcoat/New()
	..()
	var/labcoat = list()
	labcoat["white"] = /obj/item/clothing/suit/storage/labcoat
	labcoat["red"] = /obj/item/clothing/suit/storage/labcoat/red
	labcoat["blue"] = /obj/item/clothing/suit/storage/labcoat/blue
	labcoat["purple"] = /obj/item/clothing/suit/storage/labcoat/purple
	labcoat["organe"] = /obj/item/clothing/suit/storage/labcoat/orange
	labcoat["green"] = /obj/item/clothing/suit/storage/labcoat/green
	labcoat["mad"] = /obj/item/clothing/suit/storage/labcoat/mad
	gear_tweaks += new/datum/gear_tweak/path(labcoat)

/datum/gear/under/purpledress
	path = /obj/item/clothing/under/fluff/tian_dress
	display_name = "Purple dress"

/datum/gear/under/cheongsam
	path = /obj/item/clothing/under/fluff/mai_yang_dress
	display_name = "White Cheongsam"

/datum/gear/under/directordress
	path = /obj/item/clothing/under/dress/dress_hr
	display_name = "Director dress"

/datum/gear/under/dress
	path = /obj/item/clothing/under/dress/dress_pink
	display_name = "Dress selection"

/datum/gear/under/dress/New()
	..()
	var/dresses = list()
	dresses["fire"] = /obj/item/clothing/under/dress/dress_fire
	dresses["green"] = /obj/item/clothing/under/dress/dress_green
	dresses["orange"] = /obj/item/clothing/under/dress/dress_orange
	dresses["yellow"] = /obj/item/clothing/under/dress/dress_yellow
	dresses["saloon"] = /obj/item/clothing/under/dress/dress_saloon
	dresses["summer"] = /obj/item/clothing/under/dress/dress_summer
	dresses["evening"] = /obj/item/clothing/under/dress/dress_evening
	gear_tweaks += new/datum/gear_tweak/path(dresses)

/datum/gear/under/maid_suit
	display_name = "Maid dress selection"
	path = /obj/item/clothing/under/fluff/maid_suit
	cost = 2

/datum/gear/under/maid_suit/New()
	..()
	var/suits = list()
	suits["black"] = /obj/item/clothing/under/fluff/maid_suit
	suits["blue"] = /obj/item/clothing/under/fluff/maid_suit/sakuya
	gear_tweaks += new/datum/gear_tweak/path(suits)

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
	for(var/pant in subtypesof(/obj/item/clothing/under/pants))
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

/datum/gear/under/kung
	display_name = "Kung under"
	path = /obj/item/clothing/under/fluff/kung
	cost = 1

/datum/gear/suit/m65
	display_name = "M65 Jacket Selection"
	path = /obj/item/clothing/suit/storage/miljacket_army

/datum/gear/suit/m65/New()
	..()
	var/m65s = list()
	m65s["army"] = /obj/item/clothing/suit/storage/miljacket_army
	m65s["ranger"] = /obj/item/clothing/suit/storage/miljacket_army/miljacket_ranger
	m65s["navy"] = /obj/item/clothing/suit/storage/miljacket_army/miljacket_navy
	gear_tweaks += new/datum/gear_tweak/path(m65s)

/datum/gear/under/m65p
	display_name = "M65 Pants Selection"
	path = /obj/item/clothing/under/pants/milipants_army

/datum/gear/under/m65p/New()
	..()
	var/m65s = list()
	m65s["army"] = /obj/item/clothing/under/pants/milipants_army
	m65s["ranger"] = /obj/item/clothing/under/pants/milipants_army/ranger
	m65s["navy"] = /obj/item/clothing/under/pants/milipants_army/navy
	gear_tweaks += new/datum/gear_tweak/path(m65s)

/datum/gear/suit/color_shirt
	display_name = "Colored shirt selection"
	path = /obj/item/clothing/suit/blueshirt

/datum/gear/suit/color_shirt/New()
	..()
	var/shirt = list()
	shirt["alien"] = /obj/item/clothing/suit/blueshirt
	shirt["chemistry"] = /obj/item/clothing/suit/chemshirt
	shirt["sun"] = /obj/item/clothing/suit/roundshirt
	shirt["cat"] = /obj/item/clothing/suit/catshirt
	shirt["engineer"] = /obj/item/clothing/suit/engishirt
	shirt["bad engineer"] = /obj/item/clothing/suit/badengishirt
	shirt["medical"] = /obj/item/clothing/suit/docshirt
	shirt["stunbatton"] = /obj/item/clothing/suit/battonshirt
	shirt["dictator"] = /obj/item/clothing/suit/arstotzkashirt
	shirt["toxic"] = /obj/item/clothing/suit/toxicshirt
	gear_tweaks += new/datum/gear_tweak/path(shirt)
