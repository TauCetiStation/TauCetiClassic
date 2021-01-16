
/obj/item/weapon/storage/bible/tome/upgraded
	name = "big book"
	build_cd = 15
	rune_cd = 5
	scribe_time = 1
	cost_coef = 0.5

/obj/item/weapon/storage/bible/tome/upgraded/attack_hand(mob/living/carbon/human/user)
	if(!iscultist(user))
		user.visible_message("<span class='warning'>При попытке открыть книгу, сквозь обложку просачивается яркий красный шар света, который через мгновенье рассеивается.</span>",
		"<span class='warning'>При попытке открыть книгу, сквозь обложку просачивается яркий красный шар света, который невольно обжигает ваши руки и быстро рассеивается.</span>")
		user.take_certain_bodypart_damage(list(BP_L_ARM, BP_R_ARM), 0, 10)
		return
	return ..()
