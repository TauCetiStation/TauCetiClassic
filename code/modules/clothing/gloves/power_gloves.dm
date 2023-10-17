#define GLOVES_MODE_OFF "off"
#define GLOVES_MODE_KILL "kill"
#define GLOVES_MODE_STUN "stun"

/obj/item/clothing/gloves/power
	name = "black gloves"
	desc = "Heaped gloves with a bunch of all sorts of electronics."
	icon_state = "marinad"
	item_state = "marinad"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = ARMS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	item_action_types = list(/datum/action/item_action/hands_free/toggle_gloves)
	origin_tech = "combat=5;powerstorage=5;magnets=4;syndicate=2"
	species_restricted = null
	var/cell_use = 0
	var/selected_mode = GLOVES_MODE_OFF

/datum/action/item_action/hands_free/toggle_gloves
	name = "Toggle gloves"

/datum/action/item_action/hands_free/toggle_gloves/Activate()
	var/obj/item/clothing/gloves/power/S = target
	S.toggle_gloves_mode(usr)

/obj/item/clothing/gloves/power/atom_init()
	. = ..()
	cell = new/obj/item/weapon/stock_parts/cell/hyper

/obj/item/clothing/gloves/power/examine(mob/user)
	. = ..()
	if(user.Adjacent(src))
		to_chat(user, "Current mode: [selected_mode].")
		if(cell)
			to_chat(user, "Cell charge: [cell.charge].")

/obj/item/clothing/gloves/power/proc/toggle_gloves_mode(mob/user)
	if(!cell?.charge)
		to_chat(user,"<span class='warning'>Not enough energy!</span>")
		return
	switch(selected_mode)
		if(GLOVES_MODE_OFF)
			selected_mode = GLOVES_MODE_KILL
			cell_use = 500
			siemens_coefficient = 0.4
			icon_state = "powerg_kill"
		if(GLOVES_MODE_KILL)
			selected_mode = GLOVES_MODE_STUN
			cell_use = 5000
			siemens_coefficient = 0.8
			icon_state = "powerg_stun"
		else
			selected_mode = GLOVES_MODE_OFF
			icon_state = "marinad"
			cell_use = 0
			siemens_coefficient = 0
	to_chat(user, "<span class='notice'>You change the power gloves mode to</span> <span class='danger'>[selected_mode]</span>.")
	update_item_actions()

/obj/item/clothing/gloves/power/proc/turn_off(mob/user)
	selected_mode = GLOVES_MODE_OFF
	icon_state = "marinad"
	cell_use = 0
	siemens_coefficient = 0
	to_chat(user, "<span class='warning'>Not enough energy, gloves turn off!</span>")

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
			user.put_in_hands(cell)
			turn_off()
			cell = null
			return

/obj/item/clothing/gloves/power/Touch(mob/living/carbon/human/attacker, atom/A, proximity)
	if(!isliving(A))
		return FALSE
	var/mob/living/L = A
	attacker.do_attack_animation(L)
	if(!cell || cell.charge < cell_use)
		turn_off()
		return FALSE
	if(selected_mode == GLOVES_MODE_STUN)
		var/calc_power = 200 //twice as strong stungloves
		cell.use(cell_use)
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			var/obj/item/organ/external/BP = H.get_bodypart(attacker.get_targetzone())
			calc_power *= H.get_siemens_coefficient_organ(BP)
		L.visible_message("<span class='warning bold'>[L] has been touched with the gloves by [attacker]!</span>")
		L.log_combat(attacker, "stungloved with [name]")
		L.apply_damage(calc_power, HALLOSS)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
		s.set_up(3, 1, L)
		s.start()
	else if(selected_mode == GLOVES_MODE_KILL)
		cell.use(cell_use)
		var/mob/living/carbon/human/H = A
		var/attack_obj = attacker.get_unarmed_attack()
		var/damage = attack_obj["damage"] * 2.5
		if(!damage)
			playsound(src, 'sound/effects/mob/hits/miss_1.ogg', VOL_EFFECTS_MASTER)
			visible_message("<span class='warning'><B>[attacker] has attempted to punch [H]!</B></span>")
			return
		if(attacker.engage_combat(H, attacker.a_intent, damage)) // We did a combo-wombo of some sort.
			return TRUE
		playsound(H, pick(SOUNDIN_PUNCH_HEAVY), VOL_EFFECTS_MASTER)
		H.visible_message("<span class='warning'><B>[attacker] has punched [H]!</B></span>")
		var/obj/item/organ/external/BP = H.get_bodypart(ran_zone(attacker.get_targetzone()))
		var/armor_block = H.run_armor_check(BP, MELEE)
		H.apply_damages(damage, 15, 0, 0, 0, 10, BP, armor_block)
		if(prob(50))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
			s.set_up(3, 1, L)
			s.start()
	return TRUE
