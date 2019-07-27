/obj/item/weapon/gun_module/grip
	name = "gun grip"
	icon_state = "grip_normal"
	icon_overlay = "grip_normal"
	lessdamage = 0
	lessdispersion = 0
	lessfiredelay = 0
	lessrecoil = 0
	size = 0
	var/clumsy_check = TRUE

/obj/item/weapon/gun_module/grip/attach(obj/item/weapon/gunmodule/gun)
	if(..(gun, condition_check(gun)))
		gun.grip = src
		return TRUE
	return FALSE

/obj/item/weapon/gun_module/grip/condition_check(obj/item/weapon/gunmodule/gun)
	if(gun.chamber && !gun.grip && !gun.collected)
		return TRUE
	return FALSE

/obj/item/weapon/gun_module/grip/eject(obj/item/weapon/gunmodule/gun)
	gun.grip = null
	..()

/obj/item/weapon/gun_module/grip/proc/special_check(mob/user, atom/target)
	if(user.mind.special_role == "Wizard")
		return FALSE

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='red'>You don't have the dexterity to do this!</span>")
		return FALSE
	if(isliving(user))
		var/mob/living/M = user
		if (HULK in M.mutations)
			to_chat(M, "<span class='red'>Your meaty finger is much too large for the trigger guard!</span>")
			return FALSE
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.species.name == SHADOWLING)
				to_chat(H, "<span class='notice'>Your fingers don't fit in the trigger guard!</span>")
				return FALSE

			if(user.dna && user.dna.mutantrace == "adamantine")
				to_chat(user, "<span class='red'>Your metal fingers don't fit in the trigger guard!</span>")
				return FALSE
			if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit))
				var/obj/item/clothing/suit/V = H.wear_suit
				V.attack_reaction(H, REACTION_GUN_FIRE)

			if(clumsy_check) //it should be AFTER hulk or monkey check.
				var/going_to_explode = 0
				if ((CLUMSY in H.mutations) && prob(50))
					going_to_explode = 1
				if(parent.chamber.chambered && parent.chamber.chambered.crit_fail && prob(10))
					going_to_explode = 1
				if(going_to_explode)
					explosion(user.loc, 0, 0, 1, 1)
					to_chat(H, "<span class='danger'>[src] blows up in your face.</span>")
					H.take_bodypart_damage(0, 20)
					H.drop_item()
					qdel(src)
					return FALSE
	return TRUE