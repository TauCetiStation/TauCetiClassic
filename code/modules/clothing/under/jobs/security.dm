/*
 * Contains:
 *		Security
 *		Detective
 *		Head of Security
 */

/*
 * Security
 */
/obj/item/clothing/under/rank/warden
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for more robust protection. It has the word \"Warden\" written on the shoulders."
	name = "warden's jumpsuit"
	icon_state = "warden"
	item_state = "warden"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL|HEAR_TALK
	siemens_coefficient = 0.9

/obj/item/clothing/under/rank/security
	name = "security officer's jumpsuit"
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for robust protection."
	icon_state = "security"
	item_state = "secred"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL|HEAR_TALK
	siemens_coefficient = 0.9

/obj/item/clothing/under/rank/security/skirt
	name = "security officer's jumpskirt"
	icon_state = "skirt_security"
	item_state = "secskirtred"
	flags = NONE // there is no sprite for this in uniform_fat.dmi yet

/obj/item/clothing/under/tactical
	name = "tactical jumpsuit"
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for robust protection."
	icon_state = "swatunder"
	item_state = "swatunder"
	armor = list(melee = 10, bullet = 5, laser = 5,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/under/tactical/marinad
	name = "marine jumpsuit"
	desc = "Boots and Utes"
	icon_state = "marinad"
	item_state = "marinad"
	armor = list(melee = 10, bullet = 5, laser = 5,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/under/tactical/skrell
	name = "raskinta uniform"
	desc = "It's a traditional skrellian warrior-caste blue and black uniform. Skintight, sturdy and slightly wet."
	icon_state = "raskinta"
	item_state = "raskinta"
/*
 * Detective
 */
/obj/item/clothing/under/det
	name = "white hard-worn suit with brown pants"
	desc = "Someone who wears this means business."
	icon_state = "detective"
	item_state = "detective"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL|HEAR_TALK
	siemens_coefficient = 0.9

/obj/item/clothing/under/det/max_payne
	name = "white hard-worn suit with blue jeans"
	desc = "Style suit for those who want vengence."
	icon_state = "max"
	item_state = "max"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/det/black
	name = "black hard-worn suit"
	icon_state = "detective2"
	item_state = "detective2"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/det/slob
	name = "white hard-worn suit with grey pants"
	icon_state = "polsuit"
	item_state = "polsuit"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/det/slob/verb/rollup()
	set name = "Roll suit sleeves"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return

	item_state = item_state == "polsuit" ? "polsuit_rolled" : "polsuit"
	update_inv_mob()

//Forensics
/obj/item/clothing/under/rank/forensic_technician
	desc = "A very business suit, as for someone who is engaged in autopsy and inspection of crime scenes."
	name = "forensics suit"
	icon_state = "forensicsred"
	item_state = "forensicsred"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL|HEAR_TALK
	siemens_coefficient = 0.9

/obj/item/clothing/under/rank/forensic_technician/black
	icon_state = "forensicsblack"
	item_state = "forensicsblack"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL|HEAR_TALK
	siemens_coefficient = 0.9

/*
 * Head of Security
 */
/obj/item/clothing/under/rank/head_of_security
	desc = "It's a jumpsuit worn by those few with the dedication to achieve the position of \"Head of Security\". It has additional armor to protect the wearer."
	name = "head of security's jumpsuit"
	icon_state = "hos"
	item_state = "hosred"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL|HEAR_TALK
	siemens_coefficient = 0.8

/obj/item/clothing/under/rank/head_of_security/turtleneck
	name = "head of security's turtleneck"
	icon_state = "hos_turtleneck"
	item_state = "hos_turtleneck"
	flags = NONE // there is no sprite for this in uniform_fat.dmi yet

//Jensen cosplay gear
/obj/item/clothing/under/rank/head_of_security/jensen
	desc = "You never asked for anything that stylish."
	name = "head of security's jumpsuit"
	icon_state = "jensen"
	item_state = "jensen"
	siemens_coefficient = 0.6

/obj/item/clothing/suit/armor/hos/jensen
	name = "armored trenchcoat"
	desc = "A trenchcoat augmented with a special alloy for some protection and style."
	icon_state = "jensencoat"
	item_state = "jensencoat"
	flags_inv = 0
	siemens_coefficient = 0.6
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/*
 * Space Police
 */
/obj/item/clothing/under/rank/security/beatcop
	name = "NanoTrasen uniform"
	desc = "A NanoTrasen uniform often found in the lines at donut shops."
	icon_state = "spacepolice_families"
	item_state = "spacepolice_families"

/obj/item/clothing/under/rank/clownpolice
	name = "police uniform"
	desc = "A police uniform often found in the lines at donut shops."
	icon_state = "spacepolice_families"
	item_state = "spacepolice_families"

/obj/item/clothing/under/rank/blueshield
	name = "blueshield uniform"
	desc = "It's made of a slightly sturdier material, to allow for robust protection."
	icon_state = "blueshield"
	item_state = "blueshield"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL|HEAR_TALK
	siemens_coefficient = 0.9
