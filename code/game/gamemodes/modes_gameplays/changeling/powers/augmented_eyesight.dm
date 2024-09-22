/obj/effect/proc_holder/changeling/augmented_eyesight
	name = "Augmented Eyesight"
	desc = "Creates heat receptors in our eyes and dramatically increases light sensing ability."
	helptext = "Grants us night vision and thermal vision. It may be toggled on or off."
	button_icon_state = "augmented_eyesight"
	chemical_cost = 0
	genomecost = 1
	var/active = 0 //Whether or not vision is enhanced
	req_stat = UNCONSCIOUS

/obj/effect/proc_holder/changeling/augmented_eyesight/sting_action(mob/living/carbon/human/user)
	if(!istype(user))
		return
	var/obj/item/organ/internal/cyberimp/eyes/thermals/ling/IO = user.get_int_organ(/obj/item/organ/internal/cyberimp/eyes/thermals/ling)
	if(!IO)
		var/obj/item/organ/internal/cyberimp/eyes/O = new /obj/item/organ/internal/cyberimp/eyes/thermals/ling()
		O.insert_organ(user)
	return TRUE

/*
	active = !active
	user.changeling_aug = !user.changeling_aug
	if(active)
		to_chat(user, "<span class='notice'>We feel a minute twitch in our eyes, and darkness creeps away.</span>")
	else
		to_chat(user, "<span class='notice'>Our vision dulls. Shadows gather.</span>")

	user.update_sight()
	return TRUE

/mob/living
	var/changeling_aug = 0
*/

/obj/item/organ/internal/cyberimp/eyes/shield/ling
	name = "protective membranes"
	desc = "These variable transparency organic membranes will protect you from welders and flashes and heal your eye damage."
	icon_state = "ling_eyeshield"
	eye_colour = null
	implant_overlay = null
	origin_tech = "biotech=4"
	slot = "eye_ling"
	status = 0

/obj/item/organ/internal/cyberimp/eyes/shield/ling/on_life()
	..()
	var/obj/item/organ/internal/eyes/E = owner.get_int_organ(/obj/item/organ/internal/eyes)
	if(owner.eye_blind || owner.eye_blurry || (owner.sdisabilities & BLIND) || (owner.disabilities & NEARSIGHTED) || (E.damage > 0))
		owner.reagents.add_reagent("imidazoline", 1)


/obj/item/organ/internal/cyberimp/eyes/thermals/ling
	name = "heat receptors"
	desc = "These heat receptors dramatically increases eyes light sensing ability."
	icon_state = "ling_thermal"
	eye_colour = null
	implant_overlay = null
	origin_tech = "biotech=5;magnets=5"
	slot = "eye_ling"
	status = 0
	vision_flags = SEE_MOBS
	aug_message = "We feel a minute twitch in our eyes, and darkness creeps away."

/obj/item/organ/internal/cyberimp/eyes/thermals/ling/emp_act(severity)
	return

/obj/item/organ/internal/cyberimp/eyes/thermals/ling/insert_organ(mob/living/carbon/human/M, special = 0)
	..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.weakeyes = 1

/obj/item/organ/internal/cyberimp/eyes/thermals/ling/remove(mob/living/carbon/M, special = 0)
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.weakeyes = 0
	..()
