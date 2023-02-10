#define OFF "off"
#define KILL "kill"
#define STUN "stun"

/obj/item/clothing/gloves/power
	name = "Black gloves"
	desc = "Heaped gloves with a bunch of all sorts of electronics."
	icon_state = "marinad"
	item_state = "marinad"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = ARMS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	action_button_name = "Toggle gloves"
	origin_tech = "combat=5;powerstorage=5;magnets=4;syndicate=2"
	var/cell_use = 0
	var/selected_mode = OFF

/obj/item/clothing/gloves/power/examine(mob/user)
	. = ..()
	to_chat(user, "Current mode: [selected_mode].")
	if(cell)
		to_chat(user, "Cell charge: [cell.charge].")

/obj/item/clothing/gloves/power/ui_action_click()
	toggle_gloves_mode(usr)

/obj/item/clothing/gloves/power/proc/toggle_gloves_mode(mob/user)
	if((cell) && (cell.charge))
		switch(selected_mode)
			if(OFF)
				selected_mode = KILL
				cell_use = 500
				siemens_coefficient = 0.4
				icon_state = "powerg_kill"
			if(KILL)
				selected_mode = STUN
				cell_use = 2500
				siemens_coefficient = 0.8
				icon_state = "powerg_stun"
			else
				selected_mode = OFF
				icon_state = "marinad"
				cell_use = 0
				siemens_coefficient = 0
		to_chat(user, "<span class='notice'>You change the regime in power gloves. Current mode:</span> <span class='danger'>[selected_mode]</span>.")
	else
		to_chat(user,"<span class='warning'>Not enough energy!</span>")

/obj/item/clothing/gloves/power/proc/turn_off_the_gloves(mob/user)
	selected_mode = OFF
	icon_state = "marinad"
	cell_use = 0
	siemens_coefficient = 0
	to_chat(user, "<span class='warning'>Not enough energy, gloves off!</span>")

/obj/item/clothing/gloves/power/emp_act(severity)
	if(cell)
		cell.emplode(severity + 1)

/obj/item/clothing/gloves/power/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/stock_parts/cell))
		if(!cell)
			user.drop_from_inventory(I, src)
			cell = I
			to_chat(user, "<span class='notice'>You attach the [cell] to the [src].</span>")
		else
			to_chat(user, "<span class='notice'>A [cell] is already attached to the [src].</span>")
	else if(isscrewing(I))
		if(cell)
			cell.updateicon()
			to_chat(user, "<span class='notice'>You unscrew the [cell] away from the [src].</span>")
			cell.forceMove(get_turf(loc))
			cell = null
			return

/obj/item/clothing/gloves/power/Touch(mob/living/carbon/human/attacker, atom/A, proximity)
	if(isliving(A))
		var/mob/living/L = A
		attacker.do_attack_animation(L)
		if(cell)
			if(cell.charge >= cell_use)
				if(selected_mode == STUN)
					cell.use(cell_use)
					var/calc_power = 200 //twice as strong stungloves
					if(ishuman(L))
						var/mob/living/carbon/human/H = L
						var/obj/item/organ/external/BP = H.get_bodypart(attacker.get_targetzone())

						calc_power *= H.get_siemens_coefficient_organ(BP)

					L.visible_message("<span class='warning bold'>[L] has been touched with the gloves by [attacker]!</span>")
					L.log_combat(attacker, "stungloved witht [name]")

					L.apply_effects(0,0,0,0,2,0,0,calc_power)
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
					s.set_up(3, 1, L)
					s.start()
				if(selected_mode == KILL)
					cell.use(cell_use)
					var/mob/living/carbon/human/H = A
					var/attack_obj = attacker.get_unarmed_attack()
					var/damage = attack_obj["damage"] * 3
					if(!damage)
						playsound(src, 'sound/effects/mob/hits/miss_1.ogg', VOL_EFFECTS_MASTER)
						visible_message("<span class='warning'><B>[attacker] has attempted to punch [H]!</B></span>")
						return TRUE

					if(attacker.engage_combat(H, attacker.a_intent, damage)) // We did a combo-wombo of some sort.
						return TRUE

					playsound(H, pick(SOUNDIN_PUNCH_HEAVY), VOL_EFFECTS_MASTER)

					H.visible_message("<span class='warning'><B>[attacker] has punched [H]!</B></span>")

					var/obj/item/organ/external/BP = H.get_bodypart(ran_zone(attacker.get_targetzone()))
					var/armor_block = H.run_armor_check(BP, MELEE)

					H.apply_damage(damage, BURN, BP, armor_block)
					H.apply_damage(damage, BRUTE, BP, armor_block)
					if(prob(50))
						var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
						s.set_up(3, 1, L)
						s.start()

					return TRUE
			else
				turn_off_the_gloves()
		else
			turn_off_the_gloves()
			return TRUE
	return FALSE
