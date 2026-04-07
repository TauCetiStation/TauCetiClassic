/obj/effect/proc_holder/changeling/weapon/hammer
	name = "Organic Hammer"
	desc = "We reform one of our arms into hammer."
	helptext = "Can break walls, airlocks, windows and humans, requires a lot of chemical for each use. Cannot be used while in lesser form."
	button_icon_state = "arm_hammer"
	chemical_cost = 20
	genomecost = 2
	genetic_damage = 12
	req_human = 1
	max_genetic_damage = 10
	weapon_type = /obj/item/weapon/melee/changeling_hammer
	weapon_name_simple = "hammer"

/obj/item/weapon/melee/changeling_hammer
	name = "organic hammer"
	desc = "A mass of tough, boney tissue,reminiscent of hammer."
	canremove = 0
	force = 15
	flags = ABSTRACT | DROPDEL
	icon = 'icons/obj/weapons.dmi'
	icon_state = "arm_hammer"
	item_state = "arm_hammer"
	hitsound = list('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg')

/obj/item/weapon/melee/changeling_hammer/atom_init()
	. = ..()
	if(ismob(loc))
		loc.visible_message("<span class='warning'>A grotesque blade forms around [loc.name]\'s arm!</span>", "<span class='warning'>Our arm twists and mutates, transforming it into a deadly hammer.</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")

/obj/item/weapon/melee/changeling_hammer/dropped(mob/user)
	user.visible_message("<span class='warning'>With a sickening crunch, [user] reforms his hammer into an arm!</span>", "<span class='notice'>We assimilate the hammer back into our body.</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")
	..()

/obj/item/weapon/melee/changeling_hammer/proc/get_object_damage()
	return initial(force) * 5

/obj/item/weapon/melee/changeling_hammer/attack(atom/target, mob/living/carbon/human/user, def_zone)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/armor_coef = H.getarmor(def_zone, MELEE) / 100
		if(armor_coef > 0 && armor_coef < 100)
			//25 damage to armored bodypart
			var/net_damage = 25 - (force - (force * armor_coef))
			//if force or armor_coef was really big - no net damage
			if(net_damage > 0)
				H.apply_damage(net_damage, BRUTE, def_zone, blocked = 0)	//damage through armor

/obj/item/weapon/melee/changeling_hammer/melee_attack_chain(atom/target, mob/user, params)
	if(!isliving(target))
		force = get_object_damage()
	else
		force = initial(force)
	return ..()
