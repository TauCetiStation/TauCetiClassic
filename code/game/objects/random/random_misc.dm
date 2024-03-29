/obj/random/misc/pack
	name = "Random Misc"
	desc = "This is a random misc pack."

/obj/random/misc/pack/item_to_spawn()
	return pick(\
		prob(90);/obj/random/misc/toy,\
		prob(40);/obj/random/misc/lighters,\
		prob(40);/obj/random/misc/smokes,\
		prob(90);/obj/random/misc/storage,\
		prob(40);/obj/random/misc/book,\
		prob(1);/obj/random/misc/musical,\
		prob(5);/obj/random/misc/disk,\
	)

/obj/random/misc/musical
	name = "Random Musical"
	desc = "This is a random musical item."
	icon = 'icons/obj/musician.dmi'
	icon_state = "violin"

/obj/random/misc/musical/item_to_spawn()
	return pick(\
		/obj/item/device/guitar,\
		/obj/item/device/harmonica,\
		/obj/item/device/violin,\
		/obj/item/device/guitar/electric\
	)

/obj/random/misc/storage
	name = "Random storage"
	desc = "This is a random storage item."
	icon = 'icons/obj/food.dmi'
	icon_state = "eggbox"

/obj/random/misc/storage/item_to_spawn()
	return pick(\
		prob(40);/obj/item/weapon/storage/fancy/crayons,\
		prob(40);/obj/item/weapon/storage/fancy/glowsticks,\
		prob(40);/obj/item/weapon/storage/fancy/vials,\
		prob(40);/obj/item/weapon/storage/fancy/donut_box,\
		prob(40);/obj/item/weapon/storage/fancy/candle_box,\
		prob(60);/obj/item/weapon/storage/fancy/egg_box,\
		prob(10);/obj/item/weapon/storage/box/lights,\
		prob(10);/obj/item/weapon/storage/box/lights/tubes,\
		prob(10);/obj/item/weapon/storage/box/lights/mixed,\
		prob(10);/obj/item/weapon/storage/box/engineer,\
		prob(10);/obj/item/weapon/storage/box/gloves,\
		prob(60);/obj/item/weapon/storage/box/mousetraps,\
		prob(60);/obj/item/weapon/storage/box/pillbottles,\
		prob(40);/obj/item/weapon/storage/box/snappops,\
		prob(10);/obj/item/weapon/storage/box/holobadge,\
		prob(30);/obj/item/weapon/storage/box/evidence,\
		prob(40);/obj/item/weapon/storage/box/solution_trays,\
		prob(40);/obj/item/weapon/storage/box/beakers,\
		prob(10);/obj/item/weapon/storage/box/beanbags,\
		prob(40);/obj/item/weapon/storage/box/drinkingglasses,\
		prob(40);/obj/item/weapon/storage/box/condimentbottles,\
		prob(40);/obj/item/weapon/storage/box/cups,\
		prob(40);/obj/item/weapon/storage/box/donkpockets,\
		prob(8);/obj/item/weapon/storage/box/monkeycubes,\
		prob(8);/obj/item/weapon/storage/box/monkeycubes/farwacubes,\
		prob(8);/obj/item/weapon/storage/box/monkeycubes/stokcubes,\
		prob(8);/obj/item/weapon/storage/box/monkeycubes/neaeracubes,\
		prob(30);/obj/item/weapon/storage/box/ids,\
		prob(20);/obj/item/weapon/storage/box/handcuffs,\
		prob(10);/obj/item/weapon/storage/box/contraband,\
		prob(10);/obj/random/pouch
	)

/obj/random/misc/smokes
	name = "Random smokes"
	desc = "This is a random smokes item."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigpacket"

/obj/random/misc/smokes/item_to_spawn()
	return pick(\
		prob(100);/obj/item/weapon/cigbutt,\
		prob(80);/obj/item/clothing/mask/cigarette,\
		prob(10);/obj/item/clothing/mask/cigarette/cigar,\
		prob(5);/obj/item/clothing/mask/cigarette/cigar/cohiba,\
		prob(3);/obj/item/clothing/mask/cigarette/cigar/havana,\
		prob(3);/obj/item/clothing/mask/cigarette/pipe,\
		prob(5);/obj/item/clothing/mask/cigarette/pipe/cobpipe,\
		prob(10);/obj/item/weapon/storage/fancy/cigarettes,\
		prob(10);/obj/item/weapon/storage/fancy/cigarettes/dromedaryco,\
		prob(1);/obj/item/weapon/storage/fancy/cigarettes/cigpack_syndicate\
	)

/obj/random/misc/lighters
	name = "Random lighters"
	desc = "This is a random lighter item."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"

/obj/random/misc/lighters/item_to_spawn()
	return pick(\
		prob(100);/obj/item/weapon/storage/box/matches,\
		prob(30);/obj/item/weapon/lighter/random,\
		prob(16);/obj/item/weapon/lighter/zippo,\
	)

/obj/random/misc/toy
	name = "Random Toy"
	desc = "This is a random toy item."
	icon = 'icons/obj/toy.dmi'
	icon_state = "carpplushie"

/obj/random/misc/toy/item_to_spawn()
	return pick(subtypesof(/obj/item/toy))

/obj/random/misc/book
	name = "Random Book"
	desc = "This is a random book."
	icon = 'icons/obj/library.dmi'
	icon_state = "book"

/obj/random/misc/book/item_to_spawn()
		return pick(subtypesof(/obj/item/weapon/book/manual))

/obj/random/misc/lightsource
	name = "Random Light Source"
	desc = "This is a random light source item."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight"

/obj/random/misc/lightsource/item_to_spawn()
	return pick(
		prob(20);/obj/item/device/flashlight/flare,\
		prob(20);/obj/item/device/flashlight/pen,\
		prob(5);/obj/item/weapon/storage/fancy/glowsticks,\
		prob(10);/obj/item/weapon/storage/fancy/candle_box,\
		prob(5);/obj/item/device/flashlight\
	)

/obj/random/misc/cigarettes
	name = "Random Cigarette Packs"
	desc = "This is a random cigarette pack."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigpacket"

/obj/random/misc/cigarettes/item_to_spawn()
	return pick(
		/obj/item/weapon/storage/fancy/cigarettes/menthol,
		/obj/item/weapon/storage/fancy/cigarettes/dromedaryco,
		/obj/item/weapon/storage/fancy/cigarettes,
	)

/obj/random/misc/disk
	name = "Random Disk"
	desc = "This is a random disk pack."
	icon = 'icons/obj/disks.dmi'
	icon_state = "datadisk0"

/obj/random/misc/disk/item_to_spawn()
	return pick(\
		prob(10);/obj/item/weapon/disk/data/demo,\
		prob(10);/obj/item/weapon/disk/data/monkey,\
		prob(50);/obj/item/weapon/disk/research_points,\
		prob(10);/obj/item/weapon/disk/research_points/rare,\
		prob(100);pick(typesof(/obj/item/weapon/disk/smartlight_programm))
	)
