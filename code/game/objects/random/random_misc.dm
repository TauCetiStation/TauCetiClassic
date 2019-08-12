/obj/random/misc/musical
	name = "Random Medkit"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
/obj/random/misc/musical/item_to_spawn()
		return pick(\
						/obj/item/device/guitar,\
						/obj/item/device/harmonica,\
						/obj/item/device/violin,\
						/obj/item/device/guitar/electric\
					)

/obj/random/misc/storage
	name = "Random boxes"
	desc = "This is a random boxes ."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
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
	name = "Random Medkit"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
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
	name = "Random Medkit"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
/obj/random/misc/lighters/item_to_spawn()
		return pick(\
						prob(100);/obj/item/weapon/storage/box/matches,\
						prob(30);/obj/item/weapon/lighter/random,\
						prob(10);/obj/item/weapon/lighter/zippo,\
						prob(1);/obj/item/weapon/lighter/zippo/fluff/li_matsuda_1,\
						prob(1);/obj/item/weapon/lighter/zippo/fluff/michael_guess_1,\
						prob(1);/obj/item/weapon/lighter/zippo/fluff/riley_rohtin_1,\
						prob(1);/obj/item/weapon/lighter/zippo/fluff/fay_sullivan_1,\
						prob(1);/obj/item/weapon/lighter/zippo/fluff/executivekill_1,\
						prob(1);/obj/item/weapon/lighter/zippo/fluff/naples_1\
					)




/obj/random/misc/toy
	name = "Random Medkit"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
/obj/random/misc/toy/item_to_spawn()
		return pick(subtypesof(/obj/item/toy))



/obj/random/misc/lightsource
	name = "Random Medkit"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
/obj/random/misc/lightsource/item_to_spawn()
		return pick(
					prob(45);/obj/random/misc/lighters,\
					prob(20);/obj/item/device/flashlight/flare,\
					prob(20);/obj/item/device/flashlight/pen,\
					prob(5);/obj/item/weapon/storage/fancy/glowsticks,\
					prob(10);/obj/item/weapon/storage/fancy/candle_box,\
					prob(5);/obj/item/device/flashlight\
					)



/obj/random/misc/pack
	name = "Random Misc"
	desc = "This is a random misc pack."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
/obj/random/misc/pack/item_to_spawn()
		return pick(\
						prob(90);/obj/random/misc/toy,\
						prob(40);/obj/random/misc/lighters,\
						prob(40);/obj/random/misc/smokes,\
						prob(90);/obj/random/misc/storage,\
						prob(1);/obj/random/misc/musical\
					)