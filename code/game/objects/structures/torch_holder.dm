/obj/structure/torch_holder
	name = "torch holder"
	desc = "A torch holder."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "torch-holder1"
	light_color = "#faa019"
	light_power = 1.5
	light_range = 7
	layer = 5  
	density = FALSE
	anchored = TRUE

/obj/structure/torch_holder/attack_hand(mob/living/carbon/human/user)
	user.SetNextMove(CLICK_CD_MELEE)
	user.visible_message("<span class='userdanger'>[user] kicks [src] unsuccessfully.</span>", "<span class='userdanger'>It's too hot.</span>")
	var/obj/item/organ/external/BP = user.get_bodypart(BP_ACTIVE_ARM)
	BP.take_damage(0, 3, 0, "torch")
	playsound(src, SOUNDIN_LASERACT, VOL_EFFECTS_MASTER)

/obj/structure/torch_holder/magic
	name = "magic torch holder"
	desc = "A magic torch holder."
	icon_state = "magic-torch-holder1"
	light_color = "#618bff"
