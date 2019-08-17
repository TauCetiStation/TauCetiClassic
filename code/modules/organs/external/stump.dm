// Appears when you cut away limbs non-cleany, causes pain
/obj/item/organ/external/stump
	name = "limb stump"
	icon_state = ""
	is_stump = TRUE

/obj/item/organ/external/stump/atom_init(mapload, mob/living/carbon/human/H, obj/item/organ/external/limb)
	if(istype(limb))
		name = "[limb.is_robotic()?"mechanical ":""]stump of \a [limb.name]"
		limb_layer = limb.limb_layer
		body_part = limb.body_part
		body_zone = limb.body_zone
		parent_bodypart = limb.parent_bodypart
		artery_name = "mangled [limb.artery_name]"
		arterial_bleed_severity = limb.arterial_bleed_severity
		regen_bodypart_penalty = limb.regen_bodypart_penalty
	. = ..(mapload, H)

/obj/item/organ/external/stump/update_sprite()
	return

/obj/item/organ/external/stump/droplimb(no_explode = FALSE, clean = FALSE, disintegrate = DROPLIMB_EDGE)
	owner.bodyparts -= src
	owner.bodyparts_by_name -= body_zone
	owner.bad_bodyparts -= src
	if(parent)
		parent.children -= src
	parent = null
	owner = null
	qdel(src)

/obj/item/organ/external/stump/is_usable()
	return FALSE

/obj/item/organ/external/stump/process()
	return

/obj/item/organ/external/stump/createwound(type = CUT, damage)
	return

/obj/item/organ/external/stump/is_damageable(additional_damage = 0)
	return FALSE

/obj/item/organ/external/stump/emp_act(severity)
	return

/obj/item/organ/external/stump/take_damage(brute = 0, burn = 0, damage_flags = 0, used_weapon = null)
	return

/obj/item/organ/external/stump/heal_damage(brute, burn, internal = 0, robo_repair = 0)
	return

/obj/item/organ/external/stump/damage_state_text()
	return "--"

/obj/item/organ/external/stump/rejuvenate()
	if(owner)
		var/bodypart_type = owner.species.has_bodypart[body_zone]
		qdel(src)
		if(bodypart_type)
			new bodypart_type(null, owner)