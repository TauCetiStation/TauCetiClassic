/obj/item/clothing/accessory/armor
	name = "armor plate"
	desc = "Time for some serious protection."
	icon_state = "armor"
	slot = "armor"
	armor = list(melee = 50, bullet = 45, laser = 40, energy = 25, bomb = 35, bio = 0, rad = 0)
	pierce_protection = UPPER_TORSO|LOWER_TORSO
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	siemens_coefficient = 0.4
	flashbang_protection = FALSE

/obj/item/clothing/accessory/armor/on_attached(obj/item/clothing/S, mob/user, silent)
	..()
	S.armor = armor
	S.pierce_protection = pierce_protection
	S.body_parts_covered = body_parts_covered
	S.siemens_coefficient = siemens_coefficient
	S.flashbang_protection = flashbang_protection

/obj/item/clothing/accessory/armor/on_removed(mob/user)
	has_suit.armor = initial(has_suit.armor)
	has_suit.pierce_protection = initial(has_suit.pierce_protection)
	has_suit.body_parts_covered = initial(has_suit.body_parts_covered)
	has_suit.siemens_coefficient = initial(has_suit.siemens_coefficient)
	has_suit.flashbang_protection = initial(has_suit.flashbang_protection)

	..()

/obj/item/clothing/accessory/armor/dermal
	name = "dermal armour patch"
	desc = "You're not quite sure how you manage to take it on and off, but it implants nicely in your head. And now you can hide it in some hats!"
	icon_state = "dermal"
	siemens_coefficient = 0.6
	pierce_protection = HEAD
	body_parts_covered = HEAD
	slot_flags = SLOT_FLAGS_HEAD | SLOT_FLAGS_TIE
	slot = "dermal"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	flashbang_protection = TRUE
