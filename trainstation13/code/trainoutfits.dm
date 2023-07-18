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
	shoes = /obj/item/clothing/shoes/laceup

/datum/outfit/train/conductor
	name = "Train Station 13: Conductor"
	head = /obj/item/clothing/head/train/conductor
	suit = /obj/item/clothing/suit/storage/lawyer/bluejacket
	gloves = /obj/item/clothing/gloves/pipboy/pipboy3000mark4
	uniform = /obj/item/clothing/under/train/conductor
	uniform_f = /obj/item/clothing/under/train/conductordress
	id = /obj/item/weapon/card/id/passport
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

/*
/datum/outfit/train/chef
	name = "Train Station 13: Chef"
	head = /obj/item/clothing/head/mailman
	gloves = /obj/item/clothing/gloves/pipboy/pipboy3000mark4
	uniform = /obj/item/clothing/under/rank/mailman
	uniform_f = /obj/item/clothing/under/train/mailwoman
	id = /obj/item/weapon/card/id/passport
	shoes = /obj/item/clothing/shoes/boots/work

/datum/outfit/train/bartender
	name = "Train Station 13: Bartender"
	head = /obj/item/clothing/head/mailman
	gloves = /obj/item/clothing/gloves/pipboy/pimpboy3billion
	uniform = /obj/item/clothing/under/rank/mailman
	uniform_f = /obj/item/clothing/under/train/mailwoman
	id = /obj/item/weapon/card/id/passport
	shoes = /obj/item/clothing/shoes/boots/work

/datum/outfit/train/waiter
	name = "Train Station 13: Waiter"
	head = /obj/item/clothing/head/mailman
	gloves = /obj/item/clothing/gloves/pipboy
	uniform = /obj/item/clothing/under/rank/mailman
	uniform_f = /obj/item/clothing/under/train/mailwoman
	id = /obj/item/weapon/card/id/passport
	shoes = /obj/item/clothing/shoes/boots/work

/datum/outfit/train/police
	name = "Train Station 13: Police"
	head = /obj/item/clothing/head/mailman
	gloves = /obj/item/clothing/gloves/pipboy
	uniform = /obj/item/clothing/under/rank/mailman
	uniform_f = /obj/item/clothing/under/train/mailwoman
	id = /obj/item/weapon/card/id/passport
	shoes = /obj/item/clothing/shoes/boots/work

/datum/outfit/train/kgb
	name = "Train Station 13: Secret Police"
	head = /obj/item/clothing/head/mailman
	gloves = /obj/item/clothing/gloves/pipboy
	uniform = /obj/item/clothing/under/rank/mailman
	uniform_f = /obj/item/clothing/under/train/mailwoman
	id = /obj/item/weapon/card/id/passport
	shoes = /obj/item/clothing/shoes/boots/work

/datum/outfit/train/janitor
	name = "Train Station 13: Janitor"
	head = /obj/item/clothing/head/mailman
	gloves = /obj/item/clothing/gloves/pipboy
	uniform = /obj/item/clothing/under/rank/mailman
	uniform_f = /obj/item/clothing/under/train/mailwoman
	id = /obj/item/weapon/card/id/passport
	shoes = /obj/item/clothing/shoes/boots/work

*/

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