/obj/effect/proc_holder/changeling/weapon/hammer
	name = "Organic hammer"
	desc = "We reform one of our arms into hammer."
	helptext = "...."
	chemical_cost = 20
	genomecost = 5
	genetic_damage = 12
	req_human = 1
	max_genetic_damage = 10
	weapon_type = /obj/item/weapon/changeling_hammer
	weapon_name_simple = "hammer"

/obj/item/weapon/changeling_hammer
	name = "whip-like mass"
	desc = "A mass of tough, boney tissue. You can still see the fingers as a twisted pattern in the shield."
	canremove = 0
	force = 20
	icon = 'icons/obj/weapons.dmi'
	icon_state = "ling_shield"
	item_state = "ling_shield"

/obj/item/weapon/changeling_hammer/New()
	..()
	if(ismob(loc))
		loc.visible_message("<span class='warning'>A grotesque blade forms around [loc.name]\'s arm!</span>", "<span class='warning'>Our arm twists and mutates, transforming it into a deadly blade.</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")

/obj/item/weapon/changeling_hammer/dropped(mob/user)
	visible_message("<span class='warning'>With a sickening crunch, [user] reforms his blade into an arm!</span>", "<span class='notice'>We assimilate the blade back into our body.</span>", "<span class='warning>You hear organic matter ripping and tearing!</span>")
	qdel(src)


/obj/item/weapon/proc/use_charge(atom/movable/O, mob/living/carbon/user, req_chem = 3)
	var/mob/living/carbon/H = loc
	if(!H.mind || !H.mind.changeling)
		return 0
	if(H.mind.changeling.chem_charges < req_chem)
		to_chat(src, "<span class='warning'>We require at least [req_chem] units of chemicals to do that!</span>")
		return 0
	H.mind.changeling.chem_charges -= req_chem
	return 1

/obj/item/weapon/changeling_hammer/attack(atom/target, mob/user, proximity)
	if(use_charge(target,user,2))
		playsound(user.loc, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), 50, 1)
		return ..(target,user)