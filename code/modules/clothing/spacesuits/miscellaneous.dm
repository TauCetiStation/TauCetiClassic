//Deathsquad suit
/obj/item/clothing/head/helmet/space/deathsquad
	name = "deathsquad helmet"
	desc = "That's not red paint. That's real blood."
	icon_state = "deathsquad"
	item_state = "deathsquad"
	armor = list(melee = 80, bullet = 70, laser = 70,energy = 70, bomb = 70, bio = 30, rad = 30)

/obj/item/clothing/head/helmet/space/deathsquad/beret
	name = "special operations officer's beret"
	desc = "An armored beret commonly used by special operations officers."
	icon_state = "beret_badge"
	armor = list(melee = 80, bullet = 70, laser = 60,energy = 10, bomb = 25, bio = 10, rad = 0)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.9

//Space santa outfit suit
/obj/item/clothing/head/helmet/space/santahat
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon_state = "santahat"
	flags = HEADCOVERSEYES | BLOCKHAIR
	body_parts_covered = HEAD

/obj/item/clothing/suit/space/santa
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	item_state = "santa"
	slowdown = 0
	flags = ONESIZEFITSALL
	allowed = list(/obj/item) //for stuffing exta special presents

/obj/item/clothing/head/helmet/syndiassault
	name = "assault helmet"
	icon_state = "assaulthelmet_b"
	item_state = "assaulthelmet_b"
	armor = list(melee = 50, bullet = 60, laser = 45, energy = 70, bomb = 50, bio = 0, rad = 50)
	siemens_coefficient = 0.2

/obj/item/clothing/head/helmet/syndiassault/alternate
	icon_state = "assaulthelmet"
	item_state = "assaulthelmet"

//Space pirate outfit
/obj/item/clothing/head/helmet/space/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	armor = list(melee = 60, bullet = 35, laser = 60,energy = 60, bomb = 30, bio = 30, rad = 30)
	flags = HEADCOVERSEYES | BLOCKHAIR

/obj/item/clothing/suit/space/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	w_class = ITEM_SIZE_NORMAL
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box/magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank)
	slowdown = 0
	armor = list(melee = 60, bullet = 35, laser = 60,energy = 60, bomb = 30, bio = 30, rad = 30)
	breach_threshold = 25

//Buget suit

/obj/item/clothing/suit/space/cheap
	name = "budget spacesuit"
	desc = "It was an attempt to force the assistants to work in space.The label on the side reads: Not for atheists"
	resilience = 0.6

/obj/item/clothing/head/helmet/space/cheap
	name = "budget spacesuit helmet"
	desc = "It was an attempt to force the assistants to work in space. At least 60% of them survived in the spacesuit."

//Mime's Hardsuit
/obj/item/clothing/head/helmet/space/mime
	name = "mime hardsuit helmet"
	desc = "A hardsuit helmet specifically designed for the mime."
	icon_state = "mim"
	item_state = "mim"

/obj/item/clothing/suit/space/mime
	name = "mime hardsuit"
	desc = "A hardsuit specifically designed for the mime."
	icon_state = "mime"
	item_state = "mime"
	allowed = list(/obj/item/weapon/tank)

/obj/item/clothing/head/helmet/space/clown
	name = "clown hardsuit helmet"
	desc = "A hardsuit helmet specifically designed for the clown. SPESSHONK!"
	icon_state = "kluwne"
	item_state = "kluwne"

/obj/item/clothing/suit/space/clown
	name = "clown hardsuit"
	desc = "A hardsuit specifically designed for the clown. SPESSHONK!"
	icon_state = "clowan"
	item_state = "clowan"
	allowed = list(/obj/item/weapon/tank)
