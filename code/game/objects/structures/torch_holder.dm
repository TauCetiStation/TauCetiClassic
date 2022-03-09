/obj/structure/magic_torch_holder
	name = "magic torch holder"
	desc = "A magic torch holder."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "torch-holder1"
	light_color = "#5a88dd"
	light_power = 2
	light_range = 6
	layer = 5  
	density = FALSE
	anchored = TRUE

/obj/structure/torch_holder/attack_hand(mob/living/carbon/human/user)
	to_chat(user, "It's too hot.")
	var/obj/item/organ/external/BP = user.bodyparts_by_name[user.hand ? BP_L_ARM : BP_R_ARM]
	BP.take_damage(0, 3, 0, "torch")
