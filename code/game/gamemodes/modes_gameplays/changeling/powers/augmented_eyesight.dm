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
	var/obj/item/organ/internal/cyberimp/eyes/thermals/ling/IO = user.get_organ_slot("eye_ling")
	if(!IO)
		var/obj/item/organ/internal/cyberimp/eyes/O = new /obj/item/organ/internal/cyberimp/eyes/thermals/ling
		O.insert_organ(user)
		to_chat(user, "<span class='notice'>We feel a minute twitch in our eyes, and darkness creeps away.</span>")
	else
		var/obj/item/organ/internal/cyberimp/eyes/thermals/ling/ling = user.get_organ_slot("eye_ling")
		ling.remove(user)
		ling.loc = null
		to_chat(user, "<span class='notice'>Our vision dulls. Shadows gather.</span>")
	return TRUE

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
