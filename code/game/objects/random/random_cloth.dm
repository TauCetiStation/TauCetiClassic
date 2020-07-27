//CLOTH RANDOM
/obj/random/cloth/masks
	name = "random mask"
	desc = "This is a random mask."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "weldingmask"
/obj/random/cloth/masks/item_to_spawn()
	return pick(subtypesof(/obj/item/clothing/mask) - subtypesof(/obj/item/clothing/mask/cigarette) - list(/obj/item/clothing/mask/gas/death_commando, /obj/item/clothing/mask/facehugger_toy, /obj/item/clothing/mask/facehugger, /obj/item/clothing/mask/gas/shadowling, /obj/item/clothing/mask/ecig, /obj/item/clothing/mask/scarf/ninja, /obj/item/clothing/mask/gas/voice, /obj/item/clothing/mask/gas/voice/space_ninja, /obj/item/clothing/mask/facehugger/lamarr, /obj/item/clothing/mask/gas/golem))

/obj/random/cloth/armor
	name = "random armor"
	desc = "This is a random armor."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "cuirass"
/obj/random/cloth/armor/item_to_spawn()
	return pick(subtypesof(/obj/item/clothing/suit/armor) - list(/obj/item/clothing/suit/armor/tdome, /obj/item/clothing/suit/armor/changeling))

/obj/random/cloth/spacesuit
	name = "random spacesuit"
	desc = "This is a random spacesuit."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "syndicate"
/obj/random/cloth/spacesuit/item_to_spawn()
	return pick(subtypesof(/obj/item/clothing/suit/space) - list(/obj/item/clothing/suit/space/space_ninja, /obj/item/clothing/suit/space/golem, /obj/item/clothing/suit/space/shadowling, /obj/item/clothing/suit/space/changeling, /obj/item/clothing/suit/space/rig/ert/stealth))

/obj/random/cloth/storagesuit
	name = "random storagesuit"
	desc = "This is a random storagesuit."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "miljacket_ranger"
/obj/random/cloth/storagesuit/item_to_spawn()
	return pick(subtypesof(/obj/item/clothing/suit/storage) - list(/obj/item/clothing/suit/storage/lawyer, /obj/item/clothing/suit/storage/labcoat/fluff/pink ))

/obj/random/cloth/hazmatsuit
	name = "random hazmatsuit"
	desc = "This is a random hazmatsuit."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "old_hazmat_blue"
/obj/random/cloth/hazmatsuit/item_to_spawn()
	return pick(subtypesof(/obj/item/clothing/suit/bio_suit))

/obj/random/cloth/shittysuit
	name = "random shittysuit"
	desc = "This is a random shittysuit."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "coatwinter"
/obj/random/cloth/shittysuit/item_to_spawn()
	return pick(\
				/obj/item/clothing/suit/tajaran/furs,\
				/obj/item/clothing/suit/unathi/robe ,\
				/obj/item/clothing/suit/hooded/skhima,\
				/obj/item/clothing/suit/hooded/nun,\
				/obj/item/clothing/suit/chef/classic,\
				/obj/item/clothing/suit/suspenders,\
				/obj/item/clothing/suit/pirate,\
				/obj/item/clothing/suit/cyborg_suit,\
				/obj/item/clothing/suit/chickensuit,\
				/obj/item/clothing/suit/monkeysuit,\
				/obj/item/clothing/suit/xenos,\
				/obj/item/clothing/suit/batman,\
				/obj/item/clothing/suit/superman,\
				/obj/item/clothing/suit/radiation,\
				/obj/item/clothing/suit/bomb_suit,\
				/obj/item/clothing/suit/santa,\
				/obj/item/clothing/suit/poncho/ponchoshame\
			)

/obj/random/cloth/under
	name = "random under"
	desc = "This is a random under."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "tourist"
/obj/random/cloth/under/item_to_spawn()
	return pick(subtypesof(/obj/item/clothing/under) - list(/obj/item/clothing/under/stripper/stripper_green, /obj/item/clothing/under/lawyer, /obj/item/clothing/under/color, /obj/item/clothing/under/shorts, /obj/item/clothing/under/swimsuit, /obj/item/clothing/under/shadowling, /obj/item/clothing/under/fluff, /obj/item/clothing/under/rank, /obj/item/clothing/under/pj, /obj/item/clothing/under/wedding, /obj/item/clothing/under/gimmick/rank, /obj/item/clothing/under/bluepyjamas, /obj/item/clothing/under/acj, /obj/item/clothing/under/redpyjamas, /obj/item/clothing/under/gimmick/rank/head_of_personnel, /obj/item/clothing/under/dress, /obj/item/clothing/under/vox))

/obj/random/cloth/spacehelmet
	name = "random spacehelmet"
	desc = "This is a random spacehelmet."
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "skrell_helmet_white"
/obj/random/cloth/spacehelmet/item_to_spawn()
	return pick(subtypesof(/obj/item/clothing/head/helmet/space) - list(/obj/item/clothing/head/helmet/space/golem, /obj/item/clothing/head/helmet/space/space_ninja, /obj/item/clothing/head/helmet/space/changeling, /obj/item/clothing/head/helmet/space/rig/ert/stealth))

/obj/random/cloth/helmet
	name = "random helmet"
	desc = "This is a random helmet."
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "riot"
/obj/random/cloth/helmet/item_to_spawn()
	return pick(subtypesof(/obj/item/clothing/head/helmet) - subtypesof(/obj/item/clothing/head/helmet/space) - list(/obj/item/clothing/head/helmet/changeling))

/obj/random/cloth/head
	name = "random head"
	desc = "This is a random head."
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "santa"
/obj/random/cloth/head/item_to_spawn()
	return pick(subtypesof(/obj/item/clothing/head) - list(/obj/item/clothing/head/shadowling, /obj/item/clothing/head/collectable/tophat/badmin_magic_hat, /obj/item/clothing/head/wizard/tophat) - (subtypesof(/obj/item/clothing/head/helmet) + subtypesof(/obj/item/clothing/head/helmet/space)))

/obj/random/cloth/gloves
	name = "random gloves"
	desc = "This is a random gloves."
	icon = 'icons/obj/clothing/gloves.dmi'
	icon_state = "orange"
/obj/random/cloth/gloves/item_to_spawn()
	return pick(subtypesof(/obj/item/clothing/gloves) - list(/obj/item/clothing/gloves/golem, /obj/item/clothing/gloves/shadowling, /obj/item/clothing/gloves/fluff))

/obj/random/cloth/glasses
	name = "random glasses"
	desc = "This is a random glasses."
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "material"
/obj/random/cloth/glasses/item_to_spawn()
	return pick(subtypesof(/obj/item/clothing/glasses) - subtypesof(/obj/item/clothing/glasses/thermal) - list(/obj/item/clothing/glasses/night/shadowling))

/obj/random/cloth/shoes
	name = "random shoes"
	desc = "This is a random shoes."
	icon = 'icons/obj/clothing/shoes.dmi'
	icon_state = "material"
/obj/random/cloth/shoes/item_to_spawn()
	return pick(subtypesof(/obj/item/clothing/shoes) - list(/obj/item/clothing/shoes/golem, /obj/item/clothing/shoes/space_ninja, /obj/item/clothing/shoes/shadowling))

/obj/random/cloth/tie
	name = "random tie"
	desc = "This is a random tie."
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "material"
/obj/random/cloth/tie/item_to_spawn()
	return pick(subtypesof(/obj/item/clothing/accessory))

/obj/random/cloth/storage
	name = "random storage"
	desc = "This is a random storage."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "medicalbelt"
/obj/random/cloth/storage/item_to_spawn()
	return pick(\
			prob(69);/obj/random/cloth/backpack, \
			prob(34);/obj/random/cloth/belt\
			)


/obj/random/cloth/backpack
	name = "random storage"
	desc = "This is a random storage."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "medicalbelt"
/obj/random/cloth/backpack/item_to_spawn()
	return pick(\
			prob(10);/obj/item/weapon/storage/backpack/alt,\
			prob(10);/obj/item/weapon/storage/backpack/cultpack,\
			prob(10);/obj/item/weapon/storage/backpack/clown,\
			prob(10);/obj/item/weapon/storage/backpack/mime,\
			prob(1);/obj/item/weapon/storage/backpack/dufflebag,\
			prob(10);/obj/item/weapon/storage/backpack/medic,\
			prob(10);/obj/item/weapon/storage/backpack/industrial,\
			prob(8);/obj/item/weapon/storage/backpack/security\
			)

/obj/random/cloth/belt
	name = "random storage"
	desc = "This is a random storage."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "medicalbelt"
/obj/random/cloth/belt/item_to_spawn()
	return pick(\
			prob(2);/obj/item/weapon/storage/belt/security/German, \
			prob(8);/obj/item/weapon/storage/belt/security, \
			prob(8);/obj/item/weapon/storage/belt/medical, \
			prob(8);/obj/item/weapon/storage/belt/utility, \
			prob(2);/obj/item/weapon/storage/belt/champion/alt, \
			prob(8);/obj/item/weapon/storage/belt/archaeology\
			)

/obj/random/cloth/randomhead
	name = "random head"
	desc = "This is a random head."
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "santa"
/obj/random/cloth/randomhead/item_to_spawn()
	return pick(\
				prob(12);/obj/random/cloth/head,\
				prob(4);/obj/random/cloth/helmet,\
				prob(1);/obj/random/cloth/spacehelmet\
			)

/obj/random/cloth/randomsuit
	name = "random suit"
	desc = "This is a random suit."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "coatwinter"
/obj/random/cloth/randomsuit/item_to_spawn()
	return pick(\
				prob(12);/obj/random/cloth/hazmatsuit,\
				prob(16);/obj/random/cloth/shittysuit,\
				prob(16);/obj/random/cloth/storagesuit,\
				prob(2);/obj/random/cloth/spacesuit,\
				prob(6);/obj/random/cloth/armor\
			)

/obj/random/cloth/random_cloth
	name = "Random cloth supply"
	desc = "This is a random cloth supply."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "coatwinter"
/obj/random/cloth/random_cloth/item_to_spawn()
	return pick(\
					prob(12);/obj/random/cloth/randomsuit,\
					prob(12);/obj/random/cloth/randomhead,\
					prob(12);/obj/random/cloth/under,\
					prob(8);/obj/random/cloth/tie,\
					prob(8);/obj/random/cloth/shoes,\
					prob(4);/obj/random/cloth/glasses,\
					prob(12);/obj/random/cloth/gloves,\
					prob(10);/obj/random/cloth/masks,\
					prob(4);/obj/random/cloth/storage\
				)


/obj/random/cloth/ny_random_cloth
	name = "random new year cloth"
	desc = "This is a random new year cloth."
	icon = 'icons/obj/storage.dmi'
	icon_state = "giftbag2"

/obj/random/cloth/ny_random_cloth/item_to_spawn()
	return pick(\
				prob(12);/obj/item/clothing/head/helmet/space/santahat,\
				prob(12);/obj/item/clothing/suit/space/santa,\
				prob(12);/obj/item/clothing/shoes/winterboots,\
				prob(3);/obj/item/clothing/suit/wintercoat,\
				prob(3);/obj/item/clothing/suit/storage/labcoat/winterlabcoat,\
				prob(1);/obj/item/clothing/suit/wintercoat/security,\
				prob(1);/obj/item/clothing/suit/wintercoat/engineering/atmos,\
				prob(1);/obj/item/clothing/suit/wintercoat/engineering,\
				prob(1);/obj/item/clothing/suit/wintercoat/science,\
				prob(1);/obj/item/clothing/suit/wintercoat/medical,\
				prob(1);/obj/item/clothing/suit/wintercoat/cargo,\
				prob(1);/obj/item/clothing/suit/wintercoat/hydro,\
				prob(1);/obj/item/clothing/suit/wintercoat/captain,\
				prob(12);/obj/item/weapon/storage/backpack/santabag,\
			)

