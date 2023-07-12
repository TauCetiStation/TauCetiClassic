//TRAIN STATION 13

//This module is responsible for roles outfits.

//OUTFITS

/datum/outfit/train/conductor
	name = "Train Station 13: Conductor"
	head = /obj/item/clothing/head/collectable/police/train
	suit = /obj/item/clothing/suit/storage/lawyer/bluejacket
	uniform = /obj/item/clothing/under/lawyer/red/train
	uniform_f = /obj/item/clothing/under/rank/warden_fem/train
	id = /obj/item/weapon/card/id/passport
	l_pocket = /obj/item/device/flashlight/seclite
	shoes = /obj/item/clothing/shoes/brown

//MODIFIED VANILLA CLOTHING SUBTYPES

/obj/item/clothing/head/collectable/police/train
	name = "railway service hat"
	desc = "A standard red hat bearing emblem of a railway operator."

/obj/item/clothing/under/lawyer/red/train
	name = "railway service uniform"
	desc = "A standard uniform for railway customer service workers."

/obj/item/clothing/under/rank/warden_fem/train
	name = "railway service dress"
	desc = "A standard uniform for railway customer service workers."
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0) //To prevent inheritance of warden's uniform
	siemens_coefficient = 0