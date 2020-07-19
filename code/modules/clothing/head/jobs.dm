
//Bartender
/obj/item/clothing/head/chefhat
	name = "chef's hat"
	desc = "It's a hat used by chefs to keep hair out of your food. Judging by the food in the mess, they don't work."
	icon_state = "chef"
	item_state = "chefhat"
	desc = "The commander in chef's head wear."
	siemens_coefficient = 0.9

//Captain: This probably shouldn't be space-worthy
/obj/item/clothing/head/caphat
	name = "captain's hat"
	icon_state = "captain"
	desc = "It's good being the king."
	item_state = "caphat"
	siemens_coefficient = 0.9

//Captain: This probably shouldn't be space-worthy
/obj/item/clothing/head/helmet/cap
	name = "captain's cap"
	desc = "You fear to wear it for the negligence it brings."
	icon_state = "capcap"
	flags_inv = 0
	body_parts_covered = 0
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.9
	body_parts_covered = 0

//Chaplain
/obj/item/clothing/head/chaplain_hood
	name = "chaplain's hood"
	desc = "It's hood that covers the head. It keeps you warm during the space winters."
	icon_state = "chaplain_hood"
	flags = HEADCOVERSEYES|BLOCKHAIR
	siemens_coefficient = 0.9
	body_parts_covered = HEAD|EYES

/obj/item/clothing/head/skhima_hood
	name = "skhima hood"
	desc = "That's a religion skhima hood decorated with white runes and symbols. Commonly worn by monks."
	icon_state = "skhima_hood"
	item_state = "skhima_hood"
	flags = HEADCOVERSEYES
	siemens_coefficient = 0.9

/obj/item/clothing/head/nun_hood
	name = "nun hood"
	desc = "A religious female hood commonly worn by monastery sisters."
	icon_state = "nun_hood"
	flags = BLOCKHAIR
	siemens_coefficient = 0.9

//HoS
/obj/item/clothing/head/hos_peakedcap
	name = "head of security's peaked cap"
	desc = "The peaked cap of the Head of Security. I heard you, criminal scum. Now go to GOOLAG."
	icon_state = "hos_peakedcap"
	item_state = "hos_peakedcap"
	w_class = ITEM_SIZE_SMALL
	siemens_coefficient = 0.9
	body_parts_covered = 0

//Medical
/obj/item/clothing/head/surgery
	name = "surgical cap"
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs."
	icon_state = "surgcap_blue"
	flags = BLOCKHEADHAIR

/obj/item/clothing/head/surgery/purple
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is deep purple."
	icon_state = "surgcap_purple"

/obj/item/clothing/head/surgery/blue
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is baby blue."
	icon_state = "surgcap_blue"

/obj/item/clothing/head/surgery/green
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is dark green."
	icon_state = "surgcap_green"

//Detective

/obj/item/clothing/head/det_hat
	name = "detective's brown hat"
	desc = "Someone who wears this will look very smart."
	icon_state = "detective_brown"
	allowed = list(/obj/item/weapon/reagent_containers/food/snacks/candy_corn, /obj/item/weapon/pen)
	armor = list(melee = 50, bullet = 5, laser = 25,energy = 10, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9
	body_parts_covered = 0

/obj/item/clothing/head/det_hat/grey
	name = "detective's grey hat"
	icon_state = "detective_grey"

/obj/item/clothing/head/det_hat/darkgrey
	name = "detective's dark grey hat"
	icon_state = "detective_darkgrey"

/obj/item/clothing/head/det_hat/black
	name = "detective's black hat"
	icon_state = "detective_black"
