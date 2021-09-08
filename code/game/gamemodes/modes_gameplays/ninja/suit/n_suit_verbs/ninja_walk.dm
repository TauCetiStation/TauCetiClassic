// NINJA MOVEMENT
//Also makes you move like you're on crack.
/obj/item/clothing/suit/space/space_ninja/proc/ninjawalk()
	set name = "Shadow Walk"
	set desc = "Combines the VOID-shift and CLOAK-tech devices to freely move between solid matter. Toggle on or off."
	set category = "Ninja Ability"
	set popup_menu = 0

	var/mob/living/carbon/human/U = affecting
	if(!U.incorporeal_move)
		U.incorporeal_move = 2
		to_chat(U, "<span class='notice'>You will now phase through solid matter.</span>")
	else
		U.incorporeal_move = 0
		to_chat(U, "<span class='notice'>You will no-longer phase through solid matter.</span>")
	return
