/obj/random/foods/flowers
	name = "Random Flower"
	desc = "This is a random flower."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "poppy"

/obj/random/foods/flowers/item_to_spawn()
	return pick(
		/obj/item/weapon/reagent_containers/food/snacks/grown/fraxinella,\
		/obj/item/weapon/grown/sunflower,\
		/obj/item/weapon/reagent_containers/food/snacks/grown/poppy,\
		/obj/item/weapon/reagent_containers/food/snacks/grown/harebell,\
		/obj/item/weapon/reagent_containers/food/snacks/grown/mtear,\
	)

/obj/random/mail/love
	name = "Random item related with love"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/love/item_to_spawn()
	return pick(\
		/obj/item/weapon/storage/fancy/heart_box,\
		/obj/random/foods/candies,\
		/obj/random/foods/flowers,\
		/obj/item/weapon/reagent_containers/food/drinks/bottle/wine,\
	)

/obj/random/mail/ntsupport
	name = "Random item related with nt support"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/ntsupport/item_to_spawn()
	return pick(\
		/obj/random/foods/food_without_garbage,\
		/obj/item/clothing/under/lightblue,\
		/obj/random/misc/pack,\
		/obj/item/weapon/spacecash/c100,\
	)

/obj/random/mail/wrongreceiver
	name = "Random item related with wrong letter"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/wrongreceiver/item_to_spawn()
	return pick(\
		/obj/random/meds/pills,\
		/obj/random/meds/syringe,\
		/obj/random/meds/dna_injector,\
		/obj/random/meds/chemical_bottle,\
		/obj/random/guns/projectile_handgun,\
		/obj/random/structures/critters_crate,\
		/obj/random/tools/tech_supply,\
		/obj/item/weapon/grenade/chem_grenade/mine,\
	)

/obj/random/mail/home
	name = "Random item from home"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/home/item_to_spawn()
	return pick(\
		/obj/random/foods/food_without_garbage,\
		/obj/item/weapon/spacecash/c100,\
		/obj/random/cloth/random_cloth_safe,\
	)

/obj/random/mail/mars
	name = "Random item from mars"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/mars/item_to_spawn()
	return pick(\
		/obj/random/mail/home,\
	)

/obj/random/mail/venus
	name = "Random item from venus"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/venus/item_to_spawn()
	return pick(\
		/obj/random/mail/home,\
	)

/obj/random/mail/earth
	name = "Random item from earth"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/earth/item_to_spawn()
	return pick(\
		/obj/random/mail/home,\
		/obj/random/cloth/masks,\
	)

/obj/random/mail/bimna
	name = "Random item from bimna"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/bimna/item_to_spawn()
	return pick(\
		/obj/random/mail/home,\
	)

/obj/random/mail/luthien
	name = "Random item from luthien"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/luthien/item_to_spawn()
	return pick(\
		/obj/random/mail/home,\
	)

/obj/random/mail/newgibson
	name = "Random item from new gibson"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/newgibson/item_to_spawn()
	return pick(\
		/obj/random/mail/home,\
	)

/obj/random/mail/reed
	name = "Random item from reed"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/reed/item_to_spawn()
	return pick(\
		/obj/random/mail/home,\
	)

/obj/random/mail/argelius
	name = "Random item from argelius"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/argelius/item_to_spawn()
	return pick(\
		/obj/random/mail/home,\
	)

/obj/random/mail/ahdomai
	name = "Random item from ahdomai"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/ahdomai/item_to_spawn()
	return pick(\
		/obj/random/mail/home,\
		/obj/item/weapon/reagent_containers/food/snacks/rraasi,\
		/obj/item/weapon/reagent_containers/food/snacks/el_ehum,\
		/obj/item/clothing/suit/tajaran/furs,\
		/obj/item/clothing/head/tajaran/scarf,\
		/obj/item/stack/medical/bruise_pack/tajaran,\
		/obj/item/stack/medical/ointment/tajaran,\
		/obj/item/weapon/reagent_containers/food/snacks/julma_tulkrash,\
		/obj/item/weapon/reagent_containers/food/snacks/adjurahma,\
		/obj/item/weapon/reagent_containers/food/snacks/jundarek,\
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/kaholket_alkeha,\
	)

/obj/random/mail/reed
	name = "Random item from reed"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/reed/item_to_spawn()
	return pick(\
		/obj/random/mail/home,\
	)

/obj/random/mail/moghes
	name = "Random item from moghes"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/moghes/item_to_spawn()
	return pick(\
		/obj/random/mail/home,\
		/obj/item/weapon/reagent_containers/food/snacks/fasqhtongueslice,\
		/obj/item/clothing/suit/unathi/robe,\
		/obj/item/clothing/neck/unathi_mantle,\
		/obj/item/weapon/reagent_containers/food/snacks/grown/gourd,\
		/obj/item/weapon/hatchet/unathiknife,\
		/obj/item/weapon/reagent_containers/food/snacks/kefeogeo,\
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/fasqhtongue,\
		/obj/item/weapon/reagent_containers/food/snacks/soup/fushstvessina,\
	)

/obj/random/mail/qerrbalak
	name = "Random item from qerrbalak"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/qerrbalak/item_to_spawn()
	return pick(\
		/obj/random/mail/home,\
		/obj/item/clothing/under/tactical/skrell,\
		/obj/item/clothing/head/skrell_headwear,\
		/obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle,\
	)

/obj/random/mail/prank
	name = "Random prank item from clownco"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/prank/item_to_spawn()
	return pick(\
		/obj/item/weapon/grenade/chem_grenade/prank,\
	)
