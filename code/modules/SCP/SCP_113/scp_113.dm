/obj/item/device/scp113
	name = "SCP-113"
	desc = "Jasper Rock. The red piece of quartz that gleams with unnatural smoothness."
	icon_state = "scp113"
	force = 5.0
	w_class = ITEM_SIZE_HUGE //temporary workaround until I can fix the nodrop code to include noplace in bags/tables
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	var/candrop = 1
	flags = 0
	icon = 'code/modules/SCP/SCP_113/SCP.dmi'
	var/list/victims = list()

/obj/item/device/scp113/dropped(mob/user)
	if(!candrop && user)
		user.put_in_hands(src)

/obj/item/device/scp113/pickup(mob/living/user)
	if(!isliving(user))
		return 1

	if(!candrop)
		return 1

	candrop = 0 //reset candrop for new pickup
	flags = ABSTRACT

	var/which_hand = pick(BP_L_ARM, BP_R_ARM) //determine hand to burn

	to_chat(user, "<span class='warning'>[src] begins to sear your hand, burning the skin on contact, and you feel yourself unable to drop it.</span>")
	var/damage_coeff = 1
	if(user in victims)
		damage_coeff = Clamp((2000-(world.time - victims[user]))/1000,1,2)
	if(damage_coeff > 1.5)
		user.emote("scream",,, 1)

	user.apply_damage(10*damage_coeff, BURN, which_hand, 0) //administer damage
	user.apply_damage(30*damage_coeff, TOX, which_hand, 0)

	spawn(200)
		to_chat(user, "<span class='warning'>Bones begin to shift and grind inside of you, and every single one of your nerves seems like it's on fire.</span>")
	spawn(210)
		user.visible_message("<span class='notice'>\The [user] starts to scream and writhe in pain as their bone structure reforms.</span>")
	spawn(300)
		if(user.gender == FEMALE) //swap genders
			user.gender = MALE
		else
			user.gender = FEMALE
		if(ishuman(user))
			var/mob/living/carbon/human/H = user

			H.h_style = random_hair_style(H.gender, H.species.name)
			H.f_style = random_facial_hair_style(H.gender, H.species.name)
			H.update_hair()

			//H.reset_hair()
			H.check_dna()
			H.dna.ready_dna(H)
			H.update_body()
	spawn(350)
		to_chat(user, "<span class='warning'>The burning begins to fade, and you feel your hand relax it's grip on the [src].</span>")
	spawn(360)
		candrop = 1 //transformation finished, you can let go now
		flags = 0
		victims[user] = world.time