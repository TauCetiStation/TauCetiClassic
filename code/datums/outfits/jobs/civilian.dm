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
		/obj/item/weapon/implant/mind_protect/loyalty
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

/datum/outfit/job/hub
	name = OUTFIT_JOB_NAME("Hub")
	uniform = /obj/item/clothing/under/color/black
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/weapon/storage/backpack/santabag
	l_ear = null
	belt = null
	id = null
	survival_box = FALSE

/datum/outfit/job/deadman
	name = OUTFIT_JOB_NAME("Hub")
	uniform = /obj/item/clothing/under/shorts/black
	shoes = /obj/item/clothing/shoes/sandal
	back = null
	l_ear = null
	belt = null
	id = null

// ЭРАФИЯ

/datum/outfit/job/hub/peasant
	name = OUTFIT_JOB_NAME("Peasant")
	uniform = /obj/item/clothing/under/peasant
	uniform_f = /obj/item/clothing/under/peasant_fem
	shoes = /obj/item/clothing/shoes/leather
	l_hand =/obj/item/weapon/hatchet
	id = /obj/item/weapon/card/id/key/peasant

/datum/outfit/job/hub/smith
	name = OUTFIT_JOB_NAME("Smith")
	uniform =/obj/item/clothing/under/smith
	shoes =/obj/item/clothing/shoes/boots/work
	l_hand = /obj/item/weapon/smith_hammer
	gloves = /obj/item/clothing/gloves/black
	suit = /obj/item/clothing/suit/chef/classic
	id = /obj/item/weapon/card/id/key/peasant

/datum/outfit/job/hub/miner
	name = OUTFIT_JOB_NAME("Miner")
	uniform = /obj/item/clothing/under/peasant
	shoes = /obj/item/clothing/shoes/leather
	l_hand = /obj/item/weapon/pickaxe/silver
	id = /obj/item/weapon/card/id/key/peasant

/datum/outfit/job/hub/helper
	name = OUTFIT_JOB_NAME("Helper")
	uniform = /obj/item/clothing/under/pants/black
	suit = /obj/item/clothing/suit/monk_helper
	shoes = /obj/item/clothing/shoes/leather
	head = /obj/item/clothing/head/monk_helper
	l_hand = /obj/item/weapon/staff/broom/monk
	l_pocket_back = /obj/item/weapon/paper/village_law
	id = /obj/item/weapon/card/id/key/helper


/datum/outfit/job/hub/plague_doctor
	name = OUTFIT_JOB_NAME("Plague Doctor")
	uniform = /obj/item/clothing/under/pants/black
	l_pocket_back = /obj/item/weapon/paper/village_law
	head = /obj/item/clothing/head/plaguedoctorhat
	mask = /obj/item/clothing/mask/gas/plaguedoctor
	suit = /obj/item/clothing/suit/bio_suit/plaguedoctorsuit
	shoes = /obj/item/clothing/shoes/leather
	gloves = /obj/item/clothing/gloves/latex
	l_hand =/obj/item/stack/medical/advanced/bruise_pack
	r_hand = /obj/item/stack/medical/advanced/ointment
	id = /obj/item/weapon/card/id/key/doctor
	back = /obj/item/weapon/storage/backpack/satchel

/datum/outfit/job/hub/headman
	name = OUTFIT_JOB_NAME("Headman")
	uniform = /obj/item/clothing/under/color/black
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/latex
	suit = /obj/item/clothing/suit/headman
	head =/obj/item/clothing/head/headman
	r_hand =/obj/item/weapon/paper/village_law
	id = /obj/item/weapon/card/id/key/headman
	back = /obj/item/weapon/storage/backpack/satchel

/datum/outfit/job/hub/innkeeper
	name = OUTFIT_JOB_NAME("Innkeeper")
	uniform = /obj/item/clothing/under/innkeeper
	shoes = /obj/item/clothing/shoes/boots/work
	id = /obj/item/weapon/card/id/key/innkeeper
	back = /obj/item/weapon/storage/backpack/satchel
	l_pocket_back = /obj/item/weapon/paper/village_law
	r_hand = /obj/item/weapon/reagent_containers/glass/rag
	l_hand = /obj/item/weapon/melee/classic_baton
	head =/obj/item/clothing/head/inn

/datum/outfit/job/hub/knight
	name = OUTFIT_JOB_NAME("Knight")
	uniform =/obj/item/clothing/under/color/grey
	suit = /obj/item/clothing/suit/armor/crusader
	shoes = /obj/item/clothing/shoes/boots
	gloves = /obj/item/clothing/gloves/combat
	head = /obj/item/clothing/head/helmet/crusader
	l_hand = /obj/item/weapon/claymore/religion
	l_pocket_back = /obj/item/weapon/paper/village_law
	back = null
	id = /obj/item/weapon/card/id/key/knight


/datum/outfit/job/hub/monk
	name = OUTFIT_JOB_NAME("Monk")
	uniform =/obj/item/clothing/under/color/grey
	suit = /obj/item/clothing/suit/wizrobe/monk
	shoes = /obj/item/clothing/shoes/sandal
	gloves = /obj/item/clothing/gloves/combat
	head = /obj/item/clothing/head/wizard/monk
	l_pocket_back = /obj/item/weapon/paper/village_law
	l_hand = /obj/item/weapon/nullrod
	back = null
	id = /obj/item/weapon/card/id/key/monk

/datum/outfit/job/hub/human_hero
	name = OUTFIT_JOB_NAME("Human Hero")
	uniform =/obj/item/clothing/under/color/grey
	suit = /obj/item/clothing/suit/armor/crusader
	shoes = /obj/item/clothing/shoes/boots
	gloves = /obj/item/clothing/gloves/combat
	head = /obj/item/clothing/head/byzantine_hat
	mask = /obj/item/clothing/mask/lord
	l_pocket_back = /obj/item/weapon/paper/village_law
	r_hand = /obj/item/toy/flag
	back = null
	id = /obj/item/weapon/card/id/key/hhero



//НЕЙТРАЛЫ

/datum/outfit/job/hub/lepr
	name = OUTFIT_JOB_NAME("Лепрекон")
	uniform =/obj/item/clothing/under/lepr
	shoes = /obj/item/clothing/shoes/lepr
	gloves = /obj/item/clothing/gloves/latex
	head = /obj/item/clothing/head/lepr
	l_hand = /obj/item/weapon/cane