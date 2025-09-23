/obj/random/foods/flowers
	name = "Random Flower"
	desc = "Случайный цветок."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "poppy"

/obj/random/foods/flowers/item_to_spawn()
	return pick(
		/obj/item/weapon/reagent_containers/food/snacks/grown/fraxinella,
		/obj/item/weapon/grown/sunflower,
		/obj/item/weapon/reagent_containers/food/snacks/grown/poppy,
		/obj/item/weapon/reagent_containers/food/snacks/grown/harebell,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mtear,
	)

/obj/random/mail/love
	name = "Random item related with love"
	desc = "Случайный предмет от воздыхателя."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/love/item_to_spawn()
	return pick(
		/obj/item/weapon/storage/fancy/heart_box,
		/obj/random/foods/candies,
		/obj/random/foods/flowers,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/wine,
		/obj/item/jar/candy,
	)

/obj/random/mail/ntsupport
	name = "Random item related with nt support"
	desc = "Случайный предмет социальной поддержки нт."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/ntsupport/item_to_spawn()
	return pickweight(list(
		/obj/random/foods/food_with_garbage = 75,
		/obj/item/clothing/under/lightblue = 25,
		/obj/random/misc/pack = 100,
		/obj/item/weapon/spacecash/c100 = 50,
	))

/obj/random/mail/wrongreceiver
	name = "Random item related with wrong letter"
	desc = "Случайный опасный предмет для посылки."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/wrongreceiver/item_to_spawn()
	return pickweight(list(
		/obj/random/meds/pills = 100,
		/obj/random/meds/syringe = 100,
		/obj/random/meds/dna_injector = 100,
		/obj/random/meds/chemical_bottle = 100,
		/obj/random/guns/projectile_handgun = 10,
		/obj/random/structures/critters_crate = 50,
		/obj/random/tools/tech_supply/guaranteed = 100,
		/obj/item/weapon/grenade/chem_grenade/mine = 10,
	))

/obj/random/mail/home
	name = "Random item from home"
	desc = "Случайный предмет из дома."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/home/item_to_spawn()
	return pick(
		/obj/random/foods/food_without_garbage,
		/obj/item/weapon/spacecash/c100,
		/obj/random/cloth/random_cloth_safe,
		/obj/item/jar/cookie,
	)

/obj/random/mail/mars
	name = "Random item from mars"
	desc = "Случайный предмет с марса."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/mars/item_to_spawn()
	return pickweight(list(
		/obj/random/mail/home = 100,
		/obj/item/globe = 10,
	))

/obj/random/mail/venus
	name = "Random item from venus"
	desc = "Случайный предмет с венеры."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/venus/item_to_spawn()
	return pickweight(list(
		/obj/random/mail/home = 100,
		/obj/item/globe/venus = 10,
	))

/obj/random/mail/earth
	name = "Random item from earth"
	desc = "Случайный предмет с земли."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/earth/item_to_spawn()
	return pickweight(list(
		/obj/random/mail/home = 100,
		/obj/random/cloth/masks = 20,
		/obj/item/globe/earth = 10,
	))

/obj/random/mail/bimna
	name = "Random item from bimna"
	desc = "Случайный предмет с бимны."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/bimna/item_to_spawn()
	return pick(
		/obj/random/mail/home,
	)

/obj/random/mail/luthien
	name = "Random item from luthien"
	desc = "Случайный предмет с лютиэна."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/luthien/item_to_spawn()
	return pick(
		/obj/random/mail/home,
	)

/obj/random/mail/newgibson
	name = "Random item from new gibson"
	desc = "Случайный предмет с нового гибсона."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/newgibson/item_to_spawn()
	return pick(
		/obj/random/mail/home,
	)

/obj/random/mail/reed
	name = "Random item from reed"
	desc = "Случайный предмет с рида."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/reed/item_to_spawn()
	return pick(
		/obj/random/mail/home,
	)

/obj/random/mail/argelius
	name = "Random item from argelius"
	desc = "Случайный предмет с аргеллиуса."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/argelius/item_to_spawn()
	return pick(
		/obj/random/mail/home,
	)

/obj/random/mail/ahdomai
	name = "Random item from ahdomai"
	desc = "Случайный предмет с адомая."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/ahdomai/item_to_spawn()
	return pickweight(list(
		/obj/random/mail/home = 100,
		/obj/item/weapon/reagent_containers/food/snacks/rraasi = 20,
		/obj/item/weapon/reagent_containers/food/snacks/el_ehum = 20,
		/obj/item/clothing/suit/tajaran/furs = 20,
		/obj/item/clothing/head/tajaran/scarf = 20,
		/obj/item/stack/medical/bruise_pack/tajaran = 20,
		/obj/item/stack/medical/ointment/tajaran = 20,
		/obj/item/weapon/reagent_containers/food/snacks/julma_tulkrash = 20,
		/obj/item/weapon/reagent_containers/food/snacks/adjurahma = 20,
		/obj/item/weapon/reagent_containers/food/snacks/jundarek = 20,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/kaholket_alkeha = 20,
		/obj/item/globe/adhomai = 10,
	))

/obj/random/mail/moghes
	name = "Random item from moghes"
	desc = "Случайный предмет с могеса."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/moghes/item_to_spawn()
	return pickweight(list(
		/obj/random/mail/home = 100,
		/obj/item/weapon/reagent_containers/food/snacks/fasqhtongueslice = 20,
		/obj/item/clothing/suit/unathi/robe = 20,
		/obj/item/clothing/neck/unathi_mantle = 20,
		/obj/item/weapon/reagent_containers/food/snacks/grown/gourd = 20,
		/obj/item/weapon/hatchet/unathiknife = 20,
		/obj/item/weapon/reagent_containers/food/snacks/kefeogeo = 20,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/fasqhtongue = 20,
		/obj/item/weapon/reagent_containers/food/snacks/soup/fushstvessina = 20,
		/obj/item/globe/moghes = 10,
	))

/obj/random/mail/qerrbalak
	name = "Random item from qerrbalak"
	desc = "Случайный предмет с яргона-4"
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/qerrbalak/item_to_spawn()
	return pickweight(list(
		/obj/random/mail/home = 100,
		/obj/item/clothing/under/tactical/skrell = 20,
		/obj/item/clothing/head/skrell_headwear = 20,
		/obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle = 20,
		/obj/item/globe/yargon = 10,
	))

/obj/random/mail/prank
	name = "Random prank item from clownco"
	desc = "Случайный предмет-пранк для посылок."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"

/obj/random/mail/prank/item_to_spawn()
	return pick(
		/obj/item/weapon/grenade/chem_grenade/prank,
	)
