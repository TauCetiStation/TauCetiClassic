/obj/item/clothing/gloves/attackby(obj/item/weapon/W, mob/user)
	if(istype(src, /obj/item/clothing/gloves/boxing))			//quick fix for stunglove overlay not working nicely with boxing gloves.
		to_chat(user, "<span class='notice'>That won't work.</span>")//i'm not putting my lips on that!
		..()
		return

	//add wires
	if(iscoil(W))
		var/obj/item/stack/cable_coil/C = W
		if (clipped)
			to_chat(user, "<span class='notice'>The [src] are too badly mangled for wiring.</span>")
			return

		if(wired)
			to_chat(user, "<span class='notice'>The [src] are already wired.</span>")
			return

		if(!C.use(2))
			to_chat(user, "<span class='notice'>There is not enough wire to cover the [src].</span>")
			return

		wired = TRUE
		siemens_coefficient = 3.0
		to_chat(user, "<span class='notice'>You wrap some wires around the [src].</span>")
		update_icon()
		return

	//add cell
	else if(istype(W, /obj/item/weapon/stock_parts/cell))
		if(!wired)
			to_chat(user, "<span class='notice'>The [src] need to be wired first.</span>")
		else if(!cell)
			user.drop_item()
			W.loc = src
			cell = W
			to_chat(user, "<span class='notice'>You attach the [cell] to the [src].</span>")
			update_icon()
		else
			to_chat(user, "<span class='notice'>A [cell] is already attached to the [src].</span>")
		return

	else if(iswirecutter(W) || istype(W, /obj/item/weapon/scalpel))

		//stunglove stuff
		if(cell)
			cell.updateicon()
			to_chat(user, "<span class='notice'>You cut the [cell] away from the [src].</span>")
			cell.loc = get_turf(src.loc)
			cell = null
			update_icon()
			return
		if(wired) //wires disappear into the void because fuck that shit
			wired = FALSE
			siemens_coefficient = initial(siemens_coefficient)
			to_chat(user, "<span class='notice'>You cut the wires away from the [src].</span>")
			update_icon()
			return

		//clipping fingertips
		if(!clipped)
			playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
			user.visible_message("<span class='warning'>[user] cuts the fingertips off of the [src].</span>","<span class='warning'>You cut the fingertips off of the [src].</span>")

			clipped = TRUE
			name = "mangled [name]"
			desc = "[desc]<br>They have had the fingertips cut off of them."
			if("exclude" in species_restricted)
				species_restricted -= UNATHI
				species_restricted -= TAJARAN
				species_restricted -= VOX
		else
			to_chat(user, "<span class='notice'>The [src] have already been clipped!</span>")
		return
	..()

/obj/item/clothing/gloves/proc/Touch(mob/living/carbon/human/attacker, atom/A, proximity)
	if(isliving(A))
		var/mob/living/L = A
		if(cell)
			attacker.do_attack_animation(L)
			if(attacker.a_intent == INTENT_HARM)//Stungloves. Any contact will stun the alien.
				if(cell.charge >= 2500)
					cell.use(2500)
					update_icon()
					var/calc_power = 150
					if(ishuman(L))
						var/mob/living/carbon/human/H = L
						var/obj/item/organ/external/BP = H.get_bodypart(attacker.zone_sel.selecting)

						calc_power *= H.get_siemens_coefficient_organ(BP)

					L.visible_message("<span class='warning bold'>[L] has been touched with the stun gloves by [attacker]!</span>")
					L.log_combat(attacker, "stungloved witht [name]")

					L.apply_effects(0,0,0,0,2,0,0,calc_power)
					L.apply_effect(5, WEAKEN)
					if(L.stuttering < 5)
						L.stuttering = 5
					L.apply_effect(5, STUN)
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
					s.set_up(3, 1, L)
					s.start()
				else
					to_chat(attacker, "<span class='warning'>Not enough charge!</span>")
					attacker.visible_message("<span class='warning'><B>[L] has been touched with the stun gloves by [attacker]!</B></span>")
			return TRUE
	return FALSE

/obj/item/clothing/gloves/update_icon()
	..()
	cut_overlays()
	if(wired)
		add_overlay(image(icon = icon, icon_state = "gloves_wire"))
	if(cell)
		add_overlay(image(icon = icon, icon_state = "gloves_cell"))
	if(wired && cell)
		var/obj/item/weapon/stock_parts/cell/C = cell
		if(!C.charge)
			item_state = "stungloves_charge"
		else
			item_state = "stungloves"
	else
		item_state = initial(item_state)
	if(ishuman(src.loc)) // Update item_state if src in gloves slot
		var/mob/living/carbon/human/H = src.loc
		H.update_inv_gloves()
