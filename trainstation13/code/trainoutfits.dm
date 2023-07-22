//TRAIN STATION 13

//This module is responsible for roles outfits.

//OUTFITS

/datum/outfit/train/defaultblue
	name = "Train Station 13: Default blue"
	gloves = /obj/item/clothing/gloves/pipboy
	uniform = /obj/item/clothing/under/pj/blue
	uniform_f = /obj/item/clothing/under/pj/red
	id = /obj/item/weapon/card/id/passport
	shoes = /obj/item/clothing/shoes/tourist

/datum/outfit/train/defaultred
	name = "Train Station 13: Default red"
	gloves = /obj/item/clothing/gloves/pipboy
	uniform = /obj/item/clothing/under/pj/red
	uniform_f = /obj/item/clothing/under/pj/blue
	id = /obj/item/weapon/card/id/passport
	shoes = /obj/item/clothing/shoes/sandal

/datum/outfit/train/driver
	name = "Train Station 13: Driver"
	head = /obj/item/clothing/head/train/driver
	suit = /obj/item/clothing/suit/storage/lawyer/bluejacket
	gloves = /obj/item/clothing/gloves/pipboy/pipboy3000mark4
	uniform = /obj/item/clothing/under/train/driver
	uniform_f = /obj/item/clothing/under/train/driver
	id = /obj/item/weapon/card/id/passport
	l_pocket = /obj/item/weapon/book/manual/driver
	shoes = /obj/item/clothing/shoes/laceup

/datum/outfit/train/conductor
	name = "Train Station 13: Conductor"
	head = /obj/item/clothing/head/train/conductor
	suit = /obj/item/clothing/suit/storage/lawyer/bluejacket
	gloves = /obj/item/clothing/gloves/pipboy/pipboy3000mark4
	uniform = /obj/item/clothing/under/train/conductor
	uniform_f = /obj/item/clothing/under/train/conductordress
	id = /obj/item/weapon/card/id/passport
	r_pocket = /obj/item/weapon/book/manual/conductor
	l_pocket = /obj/item/device/flashlight/seclite
	shoes = /obj/item/clothing/shoes/brown

/datum/outfit/train/cashier
	name = "Train Station 13: Cashier"
	head = /obj/item/clothing/head/train/executive
	suit = /obj/item/clothing/suit/train/executive
	gloves = /obj/item/clothing/gloves/pipboy/pipboy3000mark4
	uniform = /obj/item/clothing/under/train/executive
	uniform_f = /obj/item/clothing/under/train/executive
	id = /obj/item/weapon/card/id/passport
	shoes = /obj/item/clothing/shoes/boots/German

/datum/outfit/train/executive
	name = "Train Station 13: Executive"
	head = /obj/item/clothing/head/train/executive
	suit = /obj/item/clothing/suit/train/executive
	gloves = /obj/item/clothing/gloves/pipboy/pimpboy3billion
	uniform = /obj/item/clothing/under/soviet
	uniform_f = /obj/item/clothing/under/soviet
	id = /obj/item/weapon/card/id/passport
	l_pocket = /obj/item/device/flashlight/seclite
	shoes = /obj/item/clothing/shoes/boots/German

/datum/outfit/train/electrician
	name = "Train Station 13: Electrician"
	head = /obj/item/clothing/head/hardhat/dblue
	gloves = /obj/item/clothing/gloves/pipboy
	uniform = /obj/item/clothing/under/overalls
	uniform_f = /obj/item/clothing/under/overalls
	belt = /obj/item/weapon/storage/belt/utility/atmostech
	id = /obj/item/weapon/card/id/passport
	l_pocket = /obj/item/clothing/gloves/yellow
	shoes = /obj/item/clothing/shoes/boots/work

/datum/outfit/train/cargo
	name = "Train Station 13: Cargo"
	head = /obj/item/clothing/head/mailman
	gloves = /obj/item/clothing/gloves/pipboy/pimpboy3billion
	uniform = /obj/item/clothing/under/rank/mailman
	uniform_f = /obj/item/clothing/under/train/mailwoman
	id = /obj/item/weapon/card/id/passport
	shoes = /obj/item/clothing/shoes/boots/work

/datum/outfit/train/chef
	name = "Train Station 13: Chef"
	head = /obj/item/clothing/head/chefhat
	suit = /obj/item/clothing/suit/chef
	gloves = /obj/item/clothing/gloves/pipboy/pipboy3000mark4
	uniform = /obj/item/clothing/under/rank/chef
	uniform_f = /obj/item/clothing/under/rank/chef
	id = /obj/item/weapon/card/id/passport
	shoes = /obj/item/clothing/shoes/leather

/datum/outfit/train/bartender
	name = "Train Station 13: Bartender"
	head = /obj/item/clothing/head/that
	gloves = /obj/item/clothing/gloves/pipboy/pimpboy3billion
	uniform = /obj/item/clothing/under/rank/bartender
	uniform_f = /obj/item/clothing/under/rank/bartender_fem
	id = /obj/item/weapon/card/id/passport
	shoes = /obj/item/clothing/shoes/laceup

/datum/outfit/train/waiter
	name = "Train Station 13: Waiter"
	gloves = /obj/item/clothing/gloves/pipboy
	uniform = /obj/item/clothing/under/waiter
	uniform_f = /obj/item/clothing/under/waiter
	id = /obj/item/weapon/card/id/passport
	shoes = /obj/item/clothing/shoes/laceup

/datum/outfit/train/janitor
	name = "Train Station 13: Janitor"
	head = /obj/item/clothing/head/soft/trash
	gloves = /obj/item/clothing/gloves/pipboy
	uniform = /obj/item/clothing/under/rank/recycler
	uniform_f = /obj/item/clothing/under/rank/recycler
	id = /obj/item/weapon/card/id/passport
	shoes = /obj/item/clothing/shoes/boots/galoshes

/datum/outfit/train/doctor
	name = "Train Station 13: Doctor"
	suit = /obj/item/clothing/suit/storage/labcoat
	suit_store = /obj/item/device/flashlight/pen
	back = /obj/item/weapon/storage/backpack/satchel/med
	gloves = /obj/item/clothing/gloves/pipboy
	uniform = /obj/item/clothing/under/rank/medical
	uniform_f = /obj/item/clothing/under/rank/medical/skirt
	belt = /obj/item/weapon/storage/belt/medical/surg/full
	id = /obj/item/weapon/card/id/passport
	r_pocket = /obj/item/weapon/paper/ticket/secretpass
	l_pocket = /obj/item/device/flashlight/seclite
	shoes = /obj/item/clothing/shoes/white

	backpack_contents = list(
		/obj/item/weapon/storage/firstaid/adv = 1,
		/obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian/strike = 2,
		/obj/item/clothing/gloves/latex/nitrile = 1,
		/obj/item/weapon/storage/box/syringes = 1,
		/obj/item/weapon/reagent_containers/glass/bottle/antitoxin = 1,
		/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline = 1,
		/obj/item/weapon/reagent_containers/glass/bottle/stoxin = 1,
	)

/obj/item/weapon/storage/belt/security/police
	startswith = list(/obj/item/weapon/melee/classic_baton = 1, /obj/item/weapon/reagent_containers/spray/pepper = 1, /obj/item/ammo_box/magazine/colt/rubber = 2, /obj/item/weapon/handcuffs = 3)

/datum/outfit/train/police
	name = "Train Station 13: Police"
	head = /obj/item/clothing/head/spacepolice
	suit = /obj/item/clothing/suit/storage/forensics/blue //Also /obj/item/clothing/suit/storage/forensics/red
	back = /obj/item/weapon/storage/backpack/satchel/sec/cops
	gloves = /obj/item/clothing/gloves/pipboy
	uniform = /obj/item/clothing/under/train/police
	uniform_f = /obj/item/clothing/under/train/police
	belt = /obj/item/weapon/storage/belt/security/police
	id = /obj/item/weapon/card/id/passport
	r_pocket = /obj/item/device/radio
	l_pocket = /obj/item/device/flashlight/seclite
	shoes = /obj/item/clothing/shoes/boots

	backpack_contents = list(
		/obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian = 1,
		/obj/item/clothing/gloves/security = 1,
		/obj/item/weapon/gun/projectile/automatic/pistol/colt1911 = 1,
		/obj/item/ammo_box/c45r = 3,
	)

/datum/outfit/train/secretpolice
	name = "Train Station 13: Secret Police"
	l_ear = /obj/item/device/radio/headset/headset_sec
	back = /obj/item/weapon/storage/backpack/satchel
	gloves = /obj/item/clothing/gloves/pipboy
	uniform = /obj/item/clothing/under/suit_jacket
	uniform_f = /obj/item/clothing/under/suit_jacket
	id = /obj/item/weapon/card/id/passport
	r_pocket = /obj/item/weapon/paper/ticket/secretpass
	l_pocket = /obj/item/device/flashlight/seclite
	shoes = /obj/item/clothing/shoes/laceup

	backpack_contents = list(
		/obj/item/weapon/gun/energy/taser = 1,
		/obj/item/weapon/gun/projectile/automatic/pistol/stechkin = 1,
		/obj/item/weapon/silencer = 1,
		/obj/item/ammo_box/magazine/stechkin/extended = 2,
		/obj/item/ammo_box/c9mmr = 2,
		/obj/item/ammo_box/c9mm = 2,
		/obj/item/weapon/handcuffs = 2,
		/obj/item/weapon/grenade/flashbang = 1,
		/obj/item/weapon/grenade/chem_grenade/teargas = 1,
	)

/obj/item/device/radio/headset/headset_int/scp
	name = "advanced radio headset"
	icon_state = "blueshield"
	desc = "The cavalry has arrived... To access the security channel, use :s. For command, use :c."

/datum/outfit/train/verysecretpolice
	name = "Train Station 13: Very Secret Police"
	head = /obj/item/clothing/head/bio_hood/new_hazmat/cmo
	mask = /obj/item/clothing/mask/gas/coloured
	l_ear = /obj/item/device/radio/headset/headset_int/scp
	glasses = /obj/item/clothing/glasses/meson
	suit = /obj/item/clothing/suit/bio_suit/new_hazmat/cmo
	back = /obj/item/weapon/storage/backpack/satchel/med
	belt = /obj/item/weapon/storage/belt/utility/atmostech
	gloves = /obj/item/clothing/gloves/latex/nitrile //Two by two, hands of blue!
	uniform = /obj/item/clothing/under/rank/medical/blue
	uniform_f = /obj/item/clothing/under/rank/medical/blue
	id = /obj/item/weapon/card/id/passport
	r_pocket = /obj/item/weapon/tank/emergency_oxygen/double
	l_pocket = /obj/item/device/flashlight
	shoes = /obj/item/clothing/shoes/blue

	backpack_contents = list(
		/obj/item/weapon/melee/baton = 1,
		/obj/item/weapon/grenade/chem_grenade/teargas = 2,
		/obj/item/weapon/gun/energy/taser = 1,
		/obj/item/weapon/grenade/chem_grenade/metalfoam = 2,
		/obj/item/weapon/storage/box/handcuffs = 1,
		/obj/item/weapon/grenade/flashbang = 2,
		/obj/item/weapon/grenade/chem_grenade/incendiary = 2,
	)

//MODIFIED VANILLA CLOTHING SUBTYPES

/obj/item/clothing/head/train/driver
	name = "train driver's cap"
	desc = "With great power comes great responsibility."
	icon_state = "capcap"
	item_state = "Durahelmet"

/obj/item/clothing/under/train/driver
	name = "train driver's uniform"
	desc = "A blue jacket and red tie, a standard uniform of train drivers."
	icon_state = "hopwhimsy"
	item_state = "hopwhimsy"
	flags = ONESIZEFITSALL

/obj/item/clothing/head/train/conductor
	name = "railway service cap"
	desc = "A standard red hat bearing emblem of a railway operator."
	icon_state = "policehelm_red"
	body_parts_covered = 0

/obj/item/clothing/under/train/conductor
	name = "railway service uniform"
	desc = "A standard uniform for railway customer service workers."
	icon_state = "lawyer_red"
	item_state = "lawyer_red"

/obj/item/clothing/under/train/conductordress
	name = "railway service dress"
	desc = "A standard uniform for railway customer service workers."
	icon_state = "warden_f"
	item_state = "warden_f"

/obj/item/clothing/head/train/executive
	name = "railway executive cap"
	desc = "A peaked cap with shiny insignia."
	icon_state = "sec_peakedcap"
	item_state = "sec_peakedcap"

/obj/item/clothing/suit/train/executive
	name = "railway executive jacket"
	desc = "Glory to Arstotzka!"
	icon_state = "DutchJacket"
	body_parts_covered = ARMS
	item_state = "DutchJacket"

/obj/item/clothing/under/train/executive
	name = "railway executive uniform"
	desc = "A set of brown pants and white shirt with red railway patch on each sleeve."
	icon_state = "cadet"
	item_state = "cadet"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/train/mailwoman
	name = "mailwoman's jumpsuit"
	desc = "<i>'Very special delivery!'</i>"
	icon_state = "capcamisole"
	item_state = "capcamisole"

/obj/item/clothing/under/train/police
	name = "police uniform"
	desc = "A typical police uniform with yellow lampasses on the trousers."
	icon_state = "blueshield"
	item_state = "blueshield"
	flags = ONESIZEFITSALL