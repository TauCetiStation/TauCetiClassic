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
	inhand_state = "r_suit"
	onmob_state = "warden"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL
	siemens_coefficient = 0.9

/obj/item/clothing/under/rank/security
	name = "security officer's jumpsuit"
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for robust protection."
	icon_state = "security"
	inhand_state = "r_suit"
	onmob_state = "secred"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL
	siemens_coefficient = 0.9

/obj/item/clothing/under/rank/dispatch
	name = "dispatcher's uniform"
	desc = "A dress shirt and khakis with a security patch sewn on."
	icon_state = "dispatch"
	inhand_state = "dispatch"
	onmob_state = "dispatch"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS
	siemens_coefficient = 0.9

/obj/item/clothing/under/rank/security2
	name = "security officer's uniform"
	desc = "It's made of a slightly sturdier material, to allow for robust protection."
	icon_state = "redshirt2"
	inhand_state = "r_suit"
	onmob_state = "redshirt2"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL
	siemens_coefficient = 0.9

/obj/item/clothing/under/rank/security/corp
	icon_state = "sec_corporate"
	inhand_state = "sec_corporate"
	onmob_state = "sec_corporate"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/rank/warden/corp
	icon_state = "warden_corporate"
	inhand_state = "warden_corporate"
	onmob_state = "warden_corporate"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/tactical
	name = "tactical jumpsuit"
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for robust protection."
	icon_state = "swatunder"
	inhand_state = "swatunder"
	onmob_state = "swatunder"
	armor = list(melee = 10, bullet = 5, laser = 5,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/under/tactical/marinad
	name = "marine jumpsuit"
	desc = "Boots and Utes"
	icon_state = "marinad"
	inhand_state = "johnny"
	onmob_state = "marinad"
	armor = list(melee = 10, bullet = 5, laser = 5,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9

/*
 * Detective
 */
/obj/item/clothing/under/det
	name = "white hard-worn suit with brown pants"
	desc = "Someone who wears this means business."
	icon_state = "detective"
	inhand_state = "det"
	onmob_state = "detective"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL
	siemens_coefficient = 0.9

/obj/item/clothing/under/det/max_payne
	name = "white hard-worn suit with blue jeans"
	icon_state = "max"
	onmob_state = "max"

/obj/item/clothing/under/det/black
	name = "black hard-worn suit"
	icon_state = "detective2"
	onmob_state = "detective2"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/det/slob
	name = "white hard-worn suit with grey pants"
	icon_state = "polsuit"
	onmob_state = "polsuit"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/det/slob/verb/rollup()
	set name = "Roll suit sleeves"
	set category = "Object"
	set src in usr
	onmob_state = onmob_state == "polsuit" ? "polsuit_rolled" : "polsuit"
	if (ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_w_uniform()

/*
 * Head of Security
 */
/obj/item/clothing/under/rank/head_of_security
	desc = "It's a jumpsuit worn by those few with the dedication to achieve the position of \"Head of Security\". It has additional armor to protect the wearer."
	name = "head of security's jumpsuit"
	icon_state = "hos"
	inhand_state = "r_suit"
	onmob_state = "hosred"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags = ONESIZEFITSALL
	siemens_coefficient = 0.8

/obj/item/clothing/under/rank/head_of_security/turtleneck
	name = "head of security's turtleneck"
	icon_state = "hos_turtleneck"
	onmob_state = "hos_turtleneck"
	inhand_state = "hos_turtleneck"
	flags = 0

/obj/item/clothing/under/rank/head_of_security/corp
	icon_state = "hos_corporate"
	inhand_state = "hos_corporate"
	onmob_state = "hos_corporate"
	flags = ONESIZEFITSALL

//Jensen cosplay gear
/obj/item/clothing/under/rank/head_of_security/jensen
	desc = "You never asked for anything that stylish."
	name = "head of security's jumpsuit"
	icon_state = "jensen"
	inhand_state = "jensen"
	onmob_state = "jensen"
	siemens_coefficient = 0.6

/obj/item/clothing/suit/armor/hos/jensen
	name = "armored trenchcoat"
	desc = "A trenchcoat augmented with a special alloy for some protection and style."
	icon_state = "jensencoat"
	inhand_state = "jensencoat"
	flags_inv = 0
	siemens_coefficient = 0.6
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
