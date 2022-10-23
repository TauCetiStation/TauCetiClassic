/obj/item/clothing/gloves/space_ninja/proc/toggled()
	set name = "Toggle Interaction"
	set desc = "Toggles special interaction on or off."
	set category = "Ninja Equip"

	var/mob/living/carbon/human/U = loc
	to_chat(U, "You <b>[candrain?"disable":"enable"]</b> special interaction.")
	candrain=!candrain

/obj/item/clothing/gloves/space_ninja/examine(mob/user)
	..()
	if(!canremove)
		to_chat(user, "The energy drain mechanism is: <B>[candrain ? "active" : "inactive"]</B>.")
