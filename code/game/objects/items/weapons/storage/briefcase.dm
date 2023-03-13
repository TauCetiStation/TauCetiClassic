/obj/item/weapon/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	item_state = "briefcase"
	flags = CONDUCT
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = SIZE_NORMAL
	max_w_class = SIZE_SMALL
	max_storage_space = DEFAULT_BACKPACK_STORAGE

/obj/item/weapon/storage/briefcase/attack(mob/living/M, mob/living/user)
	//..()

	if (user.ClumsyProbabilityCheck(50))
		to_chat(user, "<span class='warning'>The [src] slips out of your hand and hits your head.</span>")
		user.take_bodypart_damage(10)
		user.Paralyse(2)
		return

	M.log_combat(user, "attacked with [name] (INTENT: [uppertext(user.a_intent)])")

	if (M.stat < DEAD && M.health < 50 && prob(90))
		var/mob/H = M
		// ******* Check
		if ((ishuman(H) && istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80)))
			to_chat(M, "<span class='warning'>The helmet protects you from being hit hard in the head!</span>")
			return
		var/time = rand(2, 6)
		if (prob(75))
			M.Paralyse(time)
		else
			M.Stun(time)
		if(M.stat != DEAD)	M.stat = UNCONSCIOUS

		visible_message("<span class='warning'><B>[M] has been knocked unconscious!</B></span>", blind_message = "<span class='warning'>You hear someone fall.</span>")
	else
		to_chat(M, text("<span class='warning'>[] tried to knock you unconcious!</span>",user))
		M.blurEyes(3)

	return

/obj/item/weapon/storage/briefcase/centcomm
	icon_state = "briefcase-centcomm"
	item_state = "briefcase-centcomm"
