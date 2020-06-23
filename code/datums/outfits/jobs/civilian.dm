// BARTENDER OUTFIT
/datum/outfit/job/bartender
	name = OUTFIT_JOB_NAME("Bartender")

	uniform = /obj/item/clothing/under/rank/bartender
	uniform_f = /obj/item/clothing/under/rank/bartender_fem
	shoes = /obj/item/clothing/shoes/black

	belt = /obj/item/device/pda/bar

	survival_kit_items = list(/obj/item/ammo_casing/shotgun/beanbag,
	                          /obj/item/ammo_casing/shotgun/beanbag,
	                          /obj/item/ammo_casing/shotgun/beanbag,
	                          /obj/item/ammo_casing/shotgun/beanbag
	                          )

// CHEF OUTFIT
/datum/outfit/job/chef
	name = OUTFIT_JOB_NAME("Chef")

	uniform = /obj/item/clothing/under/rank/chef
	shoes = /obj/item/clothing/shoes/black

	belt = /obj/item/device/pda/chef

// BOTANIST OUTFIT
/datum/outfit/job/hydro
	name = OUTFIT_JOB_NAME("Botanist")

	uniform = /obj/item/clothing/under/rank/hydroponics
	uniform_f = /obj/item/clothing/under/rank/hydroponics_fem
	shoes = /obj/item/clothing/shoes/black

	belt = /obj/item/device/pda/botanist

	back_style = BACKPACK_STYLE_HYDROPONIST

// JANITOR OUTFIT
/datum/outfit/job/janitor
	name = OUTFIT_JOB_NAME("Janitor")

	uniform = /obj/item/clothing/under/rank/janitor
	shoes = /obj/item/clothing/shoes/black

	belt = /obj/item/device/pda/janitor

// BARBER OUTFIT
/datum/outfit/job/barber
	name = OUTFIT_JOB_NAME("Barber")

	uniform = /obj/item/clothing/under/rank/barber
	shoes = /obj/item/clothing/shoes/laceup

	belt = /obj/item/device/pda/barber

// STYLIST OUTFIT
/datum/outfit/job/stylist
	name = OUTFIT_JOB_NAME("Stylist")

	uniform = /obj/item/clothing/under/lawyer/purpsuit
	shoes = /obj/item/clothing/shoes/laceup

	belt = /obj/item/device/pda/barber

// LIBRARIAN OUTFIT
/datum/outfit/job/librarian
	name = OUTFIT_JOB_NAME("Librarian")

	uniform = /obj/item/clothing/under/suit_jacket/red
	shoes = /obj/item/clothing/shoes/black

	belt = /obj/item/weapon/storage/bag/bookbag
	l_hand = /obj/item/weapon/barcodescanner
	r_pocket = /obj/item/device/pda/librarian

// LAWYER OUTFIT
/datum/outfit/job/lawyer
	name = OUTFIT_JOB_NAME("Internal Affairs Agent")

	uniform = /obj/item/clothing/under/rank/internalaffairs
	shoes = /obj/item/clothing/shoes/black
	suit = /obj/item/clothing/suit/storage/internalaffairs
	glasses = /obj/item/clothing/glasses/sunglasses/big

	l_ear = /obj/item/device/radio/headset/headset_int
	belt = /obj/item/device/pda/lawyer

	l_hand = /obj/item/weapon/storage/briefcase/centcomm
	
	r_pocket = /obj/item/device/flash
	
	implants = list(
		/obj/item/weapon/implant/mindshield/loyalty
		)

// CLOWN OUTFIT
/datum/outfit/job/clown
	name = OUTFIT_JOB_NAME("Clown")

	uniform = /obj/item/clothing/under/rank/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat

	belt = /obj/item/device/pda/clown

	backpack_contents = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
		/obj/item/weapon/bikehorn,
		/obj/item/weapon/stamp/clown,
		/obj/item/toy/crayon/rainbow,
		/obj/item/weapon/storage/fancy/crayons,
		/obj/item/toy/waterflower
		)

	back = /obj/item/weapon/storage/backpack/clown

// MIME OUTFIT
/datum/outfit/job/mime
	name = OUTFIT_JOB_NAME("Mime")

	uniform = /obj/item/clothing/under/mime
	shoes = /obj/item/clothing/shoes/black
	gloves = /obj/item/clothing/gloves/white
	mask = /obj/item/clothing/mask/gas/mime
	head = /obj/item/clothing/head/beret/red
	suit = /obj/item/clothing/suit/suspenders

	belt = /obj/item/device/pda/mime

	l_pocket_back = /obj/item/toy/crayon/mime
	l_hand_back = /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing

	back_style = BACKPACK_STYLE_MIME

// CHAPLAIN OUTFIT
/datum/outfit/job/chaplain
	name = OUTFIT_JOB_NAME("Chaplain")

	uniform = /obj/item/clothing/under/rank/chaplain
	shoes = /obj/item/clothing/shoes/black

	belt = /obj/item/device/pda/chaplain
