/obj/effect/proc_holder/changeling/weapon/hammer
	name = "Organic Hammer"
	desc = "We reform one of our arms into hammer."
	helptext = "Can break walls, airlocks, windows and humans, requires a lot of chemical for each use. Cannot be used while in lesser form."
	chemical_cost = 20
	genomecost = 5
	genetic_damage = 12
	req_human = 1
	max_genetic_damage = 10
	weapon_type = /obj/item/weapon/changeling_hammer
	weapon_name_simple = "hammer"

/obj/item/weapon/changeling_hammer
	name = "oganic hammer"
	desc = "A mass of tough, boney tissue,reminiscent of hammer."
	canremove = 0
	force = 15
	flags = ABSTRACT | DROPDEL
	icon = 'icons/obj/weapons.dmi'
	icon_state = "arm_hammer"
	item_state = "arm_hammer"

/obj/item/weapon/changeling_hammer/atom_init()
	. = ..()
	if(ismob(loc))
		loc.visible_message("<span class='warning'>A grotesque blade forms around [loc.name]\'s arm!</span>", "<span class='warning'>Our arm twists and mutates, transforming it into a deadly hammer.</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")

/obj/item/weapon/changeling_hammer/dropped(mob/user)
	user.visible_message("<span class='warning'>With a sickening crunch, [user] reforms his hammer into an arm!</span>", "<span class='notice'>We assimilate the hammer back into our body.</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")
	..()


/obj/item/weapon/proc/use_charge(mob/living/carbon/human/user, req_chem = 3)
	if(!user.mind || !user.mind.changeling)
		return 0
	if(user.mind.changeling.chem_charges < req_chem)
		to_chat(user, "<span class='warning'>We require at least [req_chem] units of chemicals to do that!</span>")
		return 0
	user.mind.changeling.chem_charges -= req_chem
	return 1

/obj/item/weapon/changeling_hammer/attack(atom/target, mob/living/carbon/human/user, def_zone)
	if(user.a_intent == INTENT_HARM && use_charge(user, 4))
		playsound(user, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), VOL_EFFECTS_MASTER)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/obj/item/organ/external/BP = H.get_bodypart(def_zone)
			for(var/obj/item/organ/external/BP_CHILD in BP.children)
				H.apply_damage(force / 2, BRUTE, BP_CHILD.body_zone, H.getarmor(BP_CHILD.body_zone, "melee"))
			if(BP.parent)
				H.apply_damage(force / 2, BRUTE, BP.parent.body_zone, H.getarmor(BP.parent.body_zone, "melee"))
		return..()
