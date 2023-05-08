/obj/item/weapon/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase_brown"
	item_state = "briefcase_brown"
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
	icon_state = "briefcase_cc"
	item_state = "briefcase_cc"

/obj/item/weapon/storage/briefcase/black
	icon_state = "briefcase_black"
	item_state = "briefcase_black"

/obj/item/weapon/storage/briefcase/med
	icon_state = "briefcase_med"
	item_state = "briefcase_med"

/obj/item/weapon/storage/briefcase/virology
	icon_state = "briefcase_vir"
	item_state = "briefcase_vir"

/obj/item/weapon/storage/briefcase/inflatable
	name = "inflatable barrier box"
	desc = "Contains inflatable walls and doors."
	icon_state = "briefcase_inflate"
	item_state = "briefcase_inflate"
	startswith = list(
						/obj/item/inflatable/door,
						/obj/item/inflatable/door,
						/obj/item/inflatable/door,
						/obj/item/inflatable,
						/obj/item/inflatable,
						/obj/item/inflatable,
						/obj/item/inflatable
					)

/obj/item/weapon/storage/briefcase/engine
	name = "engineering case"
	desc = "Contains resource sheets."
	icon_state = "briefcase_eng"
	item_state = "briefcase_eng"
	can_hold = list(/obj/item/stack/sheet/metal, /obj/item/stack/sheet/plasteel, /obj/item/stack/sheet/glass, /obj/item/stack/sheet/glass/phoronglass, /obj/item/stack/sheet/rglass, /obj/item/stack/sheet/glass/phoronrglass)
	storage_slots = 10

/obj/item/weapon/storage/briefcase/engine/update_icon()
	cut_overlays()
	for(var/i in 1 to min(10, contents.len))
		var/obj/item/stack/sheet/S = contents[i]
		var/image/sheet_overlay = image(icon,"briefcase_eng_[S.icon_state]")
		if(i <= 5 && i >= 1)
			sheet_overlay.pixel_x = i - 10
		else if(i <= 10 && i >= 6)
			sheet_overlay.pixel_x = i - 1
		add_overlay(sheet_overlay)
