/obj/item/clothing/under/syndicate
	name = "tactical turtleneck"
	desc = "It's some non-descript, slightly suspicious looking, civilian clothing."
	icon_state = "syndicate"
	inhand_state = "bl_suit"
	onmob_state = "syndicate"
	has_sensor = 0
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9
	flags = ONESIZEFITSALL

/obj/item/clothing/under/syndicate/equipped(mob/M)
	if(M.gender == "male")
		onmob_state = "syndicate"
	else
		onmob_state = "syndicate_f"
	return ..()

/obj/item/clothing/under/syndicate/combat
	name = "combat turtleneck"

/obj/item/clothing/under/syndicate/tacticool
	name = "\improper tacticool turtleneck"
	desc = "Just looking at it makes you want to buy an SKS, go into the woods, and -operate-."
	icon_state = "tactifool"
	inhand_state = "bl_suit"
	onmob_state = "tactifool"
	siemens_coefficient = 1