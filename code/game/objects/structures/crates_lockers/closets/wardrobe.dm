/obj/structure/closet/wardrobe
	name = "wardrobe"
	desc = "It's a storage unit for standard-issue Nanotrasen attire."
	icon_state = "blue"
	icon_closed = "blue"

/obj/structure/closet/wardrobe/red
	name = "security wardrobe"
	icon_state = "red"
	icon_closed = "red"

/obj/structure/closet/wardrobe/red/PopulateContents()
	for (var/i in 1 to 3)
		new /obj/item/clothing/under/rank/security(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/under/rank/cadet(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/under/rank/security/skirt(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/under/rank/cadet/skirt(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/shoes/boots(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/head/soft/sec(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/mask/bandana/red(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/head/beret/sec(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/head/sec_peakedcap(src)
	#ifdef NEWYEARCONTENT
	for (var/i in 1 to 3)
		new /obj/item/clothing/head/santa(src)
		new /obj/item/clothing/suit/wintercoat/security(src)
		new /obj/item/clothing/shoes/winterboots(src)
	#endif


/obj/structure/closet/wardrobe/pink
	name = "pink wardrobe"
	icon_state = "pink"
	icon_closed = "pink"

/obj/structure/closet/wardrobe/pink/PopulateContents()
	for (var/i in 1 to 3)
		new /obj/item/clothing/under/color/pink(src)
		new /obj/item/clothing/shoes/brown(src)

/obj/structure/closet/wardrobe/black
	name = "black wardrobe"
	icon_state = "black"
	icon_closed = "black"

/obj/structure/closet/wardrobe/black/PopulateContents()
	for (var/i in 1 to 3)
		new /obj/item/clothing/under/color/black(src)
	if(prob(25))
		new /obj/item/clothing/suit/jacket/leather(src)
	if(prob(20))
		new /obj/item/clothing/suit/jacket/leather/overcoat(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/shoes/black(src)
	#ifdef NEWYEARCONTENT
	for (var/i in 1 to 3)
		new /obj/item/clothing/suit/wintercoat(src)
		new /obj/item/clothing/shoes/winterboots(src)
		new /obj/item/clothing/head/santa(src)
	#endif


/obj/structure/closet/wardrobe/chaplain_black
	name = "chapel wardrobe"
	desc = "It's a storage unit for Nanotrasen-approved religious attire."
	icon_state = "black"
	icon_closed = "black"

/obj/structure/closet/wardrobe/chaplain_black/PopulateContents()
	new /obj/item/clothing/under/rank/chaplain(src)
	new /obj/item/clothing/under/rank/chaplain/light(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/suit/hooded/skhima(src)
	new /obj/item/clothing/suit/hooded/nun(src)
	new /obj/item/clothing/shoes/jolly_gravedigger(src)
	new /obj/item/clothing/suit/holidaypriest(src)
	new /obj/item/weapon/storage/backpack/chaplain(src)
	new /obj/item/weapon/game_kit/chaplain(src)
	new /obj/item/weapon/reagent_containers/spray/thurible(src)
	new /obj/item/clothing/glasses/sunglasses/chaplain(src)
	for (var/i in 1 to 2)
		new /obj/item/weapon/storage/fancy/candle_box(src)


/obj/structure/closet/wardrobe/green
	name = "green wardrobe"
	icon_state = "green"
	icon_closed = "green"

/obj/structure/closet/wardrobe/green/PopulateContents()
	for (var/i in 1 to 3)
		new /obj/item/clothing/under/color/green(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/shoes/black(src)
	//for (var/i in 1 to 2)
	//	new /obj/item/clothing/mask/bandana/green(src)


/obj/structure/closet/wardrobe/xenos
	name = "xenos wardrobe"
	icon_state = "green"
	icon_closed = "green"

/obj/structure/closet/wardrobe/xenos/PopulateContents()
	new /obj/item/clothing/suit/unathi/mantle(src)
	new /obj/item/clothing/suit/unathi/robe(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/shoes/sandal(src)


/obj/structure/closet/wardrobe/orange
	name = "prison wardrobe"
	desc = "It's a storage unit for Nanotrasen-regulation prisoner attire."
	icon_state = "orange"
	icon_closed = "orange"

/obj/structure/closet/wardrobe/orange/PopulateContents()
	for (var/i in 1 to 3)
		new /obj/item/clothing/under/color/orange(src)
		new /obj/item/clothing/shoes/orange(src)


/obj/structure/closet/wardrobe/yellow
	name = "yellow wardrobe"
	icon_state = "wardrobe-y"
	icon_closed = "wardrobe-y"

/obj/structure/closet/wardrobe/yellow/PopulateContents()
	for (var/i in 1 to 3)
		new /obj/item/clothing/under/color/yellow(src)
		new /obj/item/clothing/shoes/orange(src)
	//for (var/i in 1 to 2)
	//	new /obj/item/clothing/mask/bandana/gold(src)


/obj/structure/closet/wardrobe/atmospherics_yellow
	name = "atmospherics wardrobe"
	icon_state = "atmos"
	icon_closed = "atmos"

/obj/structure/closet/wardrobe/atmospherics_yellow/PopulateContents()
	for (var/i in 1 to 3)
		new /obj/item/clothing/under/rank/atmospheric_technician(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/shoes/black(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/head/hardhat/red(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/head/beret/eng(src)
	#ifdef NEWYEARCONTENT
	for (var/i in 1 to 3)
		new /obj/item/clothing/suit/wintercoat/engineering/atmos(src)
		new /obj/item/clothing/shoes/winterboots(src)
	#endif



/obj/structure/closet/wardrobe/engineering_yellow
	name = "engineering wardrobe"
	icon_state = "yellow"
	icon_closed = "yellow"

/obj/structure/closet/wardrobe/engineering_yellow/PopulateContents()
	for (var/i in 1 to 3)
		new /obj/item/clothing/under/rank/engineer(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/shoes/boots/work(src)
	for(var/i = 1 to 3)
		if(prob(75))
			new /obj/item/clothing/head/hardhat/yellow(src)
		else
			new /obj/item/clothing/head/hardhat/yellow/visor(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/head/beret/eng(src)
	#ifdef NEWYEARCONTENT
	for (var/i in 1 to 3)
		new /obj/item/clothing/suit/wintercoat/engineering(src)
		new /obj/item/clothing/shoes/winterboots(src)
	#endif


/obj/structure/closet/wardrobe/white
	name = "white wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/white/PopulateContents()
	for (var/i in 1 to 3)
		new /obj/item/clothing/under/color/white(src)
		new /obj/item/clothing/shoes/white(src)


/obj/structure/closet/wardrobe/pjs
	name = "Pajama wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/pjs/PopulateContents()
	for (var/i in 1 to 2)
		new /obj/item/clothing/under/pj/red(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/under/pj/blue(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/shoes/white(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/shoes/slippers(src)


/obj/structure/closet/wardrobe/science_white
	name = "science wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/toxins_white/PopulateContents()
	for (var/i in 1 to 3)
		new /obj/item/clothing/under/rank/scientist(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/suit/storage/labcoat(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/shoes/white(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/shoes/slippers(src)


/obj/structure/closet/wardrobe/robotics_black
	name = "robotics wardrobe"
	icon_state = "black"
	icon_closed = "black"

/obj/structure/closet/wardrobe/robotics_black/PopulateContents()
	for (var/i in 1 to 2)
		new /obj/item/clothing/under/rank/roboticist(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/suit/storage/labcoat(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/shoes/black(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/gloves/black(src)
	#ifdef NEWYEARCONTENT
	for (var/i in 1 to 2)
		new /obj/item/clothing/suit/wintercoat/science(src)
		new /obj/item/clothing/shoes/winterboots(src)
		new /obj/item/clothing/head/santa(src)
	#endif


/obj/structure/closet/wardrobe/chemistry_white
	name = "chemistry wardrobe"
	icon_state = "orange"
	icon_closed = "orange"

/obj/structure/closet/wardrobe/chemistry_white/PopulateContents()
	for (var/i in 1 to 2)
		new /obj/item/clothing/under/rank/chemist(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/under/rank/chemist/skirt(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/shoes/white(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/suit/storage/labcoat/chemist(src)


/obj/structure/closet/wardrobe/genetics_white
	name = "genetics wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/genetics_white/PopulateContents()
	for (var/i in 1 to 2)
		new /obj/item/clothing/under/rank/geneticist(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/under/rank/geneticist/skirt(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/shoes/white(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/suit/storage/labcoat/genetics(src)
	#ifdef NEWYEARCONTENT
	for (var/i in 1 to 2)
		new /obj/item/clothing/suit/wintercoat/science(src)
		new /obj/item/clothing/shoes/winterboots(src)
		new /obj/item/clothing/head/santa(src)
	#endif


/obj/structure/closet/wardrobe/virology_white
	name = "virology wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/virology_white/PopulateContents()
	for (var/i in 1 to 2)
		new /obj/item/clothing/under/rank/virologist(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/under/rank/virologist/skirt(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/shoes/white(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/suit/storage/labcoat/virologist(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/mask/surgical(src)
	#ifdef NEWYEARCONTENT
	new /obj/item/clothing/suit/wintercoat/medical(src)
	new /obj/item/clothing/shoes/winterboots(src)
	new /obj/item/clothing/head/santa(src)
	#endif


/obj/structure/closet/wardrobe/medic_white
	name = "medical wardrobe"
	icon_state = "white"
	icon_closed = "white"

/obj/structure/closet/wardrobe/medic_white/PopulateContents()
	for (var/i in 1 to 2)
		new /obj/item/clothing/under/rank/medical(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/under/rank/medical/skirt(src)
	new /obj/item/clothing/under/rank/medical/blue(src)
	new /obj/item/clothing/under/rank/medical/green(src)
	new /obj/item/clothing/under/rank/medical/purple(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/shoes/white(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/suit/storage/labcoat(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/mask/surgical(src)
	#ifdef NEWYEARCONTENT
	new /obj/item/clothing/suit/wintercoat/medical(src)
	new /obj/item/clothing/shoes/winterboots(src)
	new /obj/item/clothing/head/santa(src)
	new /obj/item/clothing/suit/storage/labcoat/winterlabcoat(src)
	#endif


/obj/structure/closet/wardrobe/grey
	name = "grey wardrobe"
	icon_state = "grey"
	icon_closed = "grey"

/obj/structure/closet/wardrobe/grey/PopulateContents()
	for (var/i in 1 to 3)
		new /obj/item/clothing/under/color/grey(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/shoes/black(src)
	for (var/i in 1 to 3)
		new /obj/item/clothing/head/soft/grey(src)
	#ifdef NEWYEARCONTENT
	for (var/i in 1 to 2)
		new /obj/item/clothing/suit/wintercoat(src)
		new /obj/item/clothing/shoes/winterboots(src)
		new /obj/item/clothing/head/santa(src)
	#endif


/obj/structure/closet/wardrobe/mixed
	name = "mixed wardrobe"
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/wardrobe/mixed/PopulateContents()
	for (var/i in 1 to 2)
		if(prob(25))
			new /obj/item/clothing/suit/jacket(src)
	new /obj/item/clothing/under/color/blue(src)
	new /obj/item/clothing/under/color/yellow(src)
	new /obj/item/clothing/under/color/green(src)
	new /obj/item/clothing/under/color/orange(src)
	new /obj/item/clothing/under/color/pink(src)
	new /obj/item/clothing/under/color/red(src)
	//new /obj/item/clothing/under/color/lightblue(src)
	//new /obj/item/clothing/under/color/aqua(src)
	//new /obj/item/clothing/under/color/purple(src)
	//new /obj/item/clothing/under/color/lightpurple(src)
	//new /obj/item/clothing/under/color/lightgreen(src)
	//new /obj/item/clothing/under/color/darkblue(src)
	//new /obj/item/clothing/under/color/darkred(src)
	//new /obj/item/clothing/under/color/lightred(src)
	//new /obj/item/clothing/mask/bandana/red(src)
	//new /obj/item/clothing/mask/bandana/red(src)
	//new /obj/item/clothing/mask/bandana/blue(src)
	//new /obj/item/clothing/mask/bandana/blue(src)
	//new /obj/item/clothing/mask/bandana/gold(src)
	//new /obj/item/clothing/mask/bandana/gold(src)
	new /obj/item/clothing/under/dress/plaid_blue(src)
	new /obj/item/clothing/under/dress/plaid_red(src)
	new /obj/item/clothing/under/dress/plaid_purple(src)
	new /obj/item/clothing/shoes/blue(src)
	new /obj/item/clothing/shoes/yellow(src)
	new /obj/item/clothing/shoes/green(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/shoes/purple(src)
	new /obj/item/clothing/shoes/red(src)
	new /obj/item/clothing/shoes/leather(src)
	#ifdef NEWYEARCONTENT
	new /obj/item/clothing/suit/wintercoat(src)
	new /obj/item/clothing/shoes/winterboots(src)
	new /obj/item/clothing/head/santa(src)
	#endif

/obj/structure/closet/wardrobe/tactical
	name = "tactical equipment"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"

/obj/structure/closet/wardrobe/tactical/PopulateContents()
	new /obj/item/device/radio/headset/headset_sec/marinad(src)
	new /obj/item/weapon/storage/backpack/dufflebag/marinad(src)
	new /obj/item/clothing/gloves/security/marinad(src)
	new /obj/item/clothing/head/helmet/tactical/marinad(src)
	new /obj/item/clothing/suit/storage/flak/marinad(src)
	new /obj/item/clothing/under/tactical/marinad(src)
	new /obj/item/clothing/mask/balaclava(src)
	new /obj/item/clothing/glasses/sunglasses/sechud/tactical(src)
	new /obj/item/weapon/storage/belt/security/tactical(src)
	new /obj/item/weapon/kitchenknife/combat(src)
	new /obj/item/clothing/shoes/boots/work(src)

