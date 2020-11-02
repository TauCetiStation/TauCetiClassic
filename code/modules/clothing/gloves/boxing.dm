/obj/item/clothing/gloves/boxing
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxing"
	item_state = "boxing"

	species_restricted = null

/obj/item/clothing/gloves/boxing/Touch(mob/living/carbon/human/attacker, atom/A, proximity)
	. = ..()
	if(!. && ishuman(A))
		var/mob/living/carbon/human/H = A
		var/attack_obj = attacker.get_unarmed_attack()
		var/damage = attack_obj["damage"] * 2
		if(!damage)
			playsound(src, 'sound/weapons/punchmiss.ogg', VOL_EFFECTS_MASTER)
			visible_message("<span class='warning'><B>[attacker] has attempted to punch [H]!</B></span>")
			return TRUE

		if(attacker.engage_combat(H, attacker.a_intent, damage)) // We did a combo-wombo of some sort.
			return TRUE

		playsound(H, pick(SOUNDIN_PUNCH), VOL_EFFECTS_MASTER)

		H.visible_message("<span class='warning'><B>[attacker] has punched [H]!</B></span>")

		var/obj/item/organ/external/BP = H.get_bodypart(ran_zone(attacker.zone_sel.selecting))
		var/armor_block = H.run_armor_check(BP, "melee")

		H.apply_damage(damage, HALLOSS, BP, armor_block)
		return TRUE

/obj/item/clothing/gloves/boxing/green
	icon_state = "boxinggreen"
	item_state = "boxinggreen"

/obj/item/clothing/gloves/boxing/blue
	icon_state = "boxingblue"
	item_state = "boxingblue"

/obj/item/clothing/gloves/boxing/yellow
	icon_state = "boxingyellow"
	item_state = "boxingyellow"

/obj/item/clothing/gloves/white
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "latex"
	item_state = "lgloves"
	item_color="mime"

/obj/item/clothing/gloves/white/redcoat
	item_color = "redcoat"		//Exists for washing machines. Is not different from white gloves in any way.
