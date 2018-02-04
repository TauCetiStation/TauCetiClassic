/obj/effect/proc_holder/changeling/weapon/whip
	name = "Organic Whip"
	desc = "We reform one of our arms into whip."
	helptext = "Can snatch, knock down, and damage in range depending on your intent, requires a lot of chemical for each use. Cannot be used while in lesser form."
	chemical_cost = 20
	genomecost = 4
	genetic_damage = 12
	req_human = 1
	max_genetic_damage = 10
	weapon_type = /obj/item/weapon/changeling_whip
	weapon_name_simple = "whip"

/obj/item/weapon/changeling_whip
	name = "Organic Whip"
	desc = "A mass of tough tissue that can be elastic"
	canremove = 0
	flags = ABSTRACT | DROPDEL
	icon = 'icons/obj/weapons.dmi'
	icon_state = "arm_whip"
	item_state = "arm_whip"
	var/next_click

/obj/item/weapon/changeling_whip/atom_init()
	. = ..()
	if(ismob(loc))
		loc.visible_message("<span class='warning'>A grotesque blade forms around [loc.name]\'s arm!</span>", "<span class='warning'>Our arm twists and mutates, transforming it into a deadly elastic whip.</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")

/obj/item/weapon/changeling_whip/dropped(mob/user)
	visible_message("<span class='warning'>With a sickening crunch, [user] reforms his whip into an arm!</span>", "<span class='notice'>We assimilate the Whip back into our body.</span>", "<span class='warning>You hear organic matter ripping and tearing!</span>")
	..()

/obj/item/weapon/changeling_whip/afterattack(atom/A, mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(user.incapacitated() || user.lying)
		return
	if(next_click > world.time)
		return
	if(!use_charge(user, 2))
		return
	next_click = world.time + 10
	var/obj/item/projectile/changeling_whip/LE = new (get_turf(src))
	if(user.a_intent == "grab")
		LE.grabber = 1
	else if(user.a_intent == "disarm" && prob(65))
		LE.weaken = 5
	else if(user.a_intent == "hurt")
		LE.damage = 30
	else
		LE.agony = 25
	LE.host = user
	LE.Fire(A, user)

/obj/item/projectile/changeling_whip
	name = "Whip"
	icon_state = "laser"
	pass_flags = PASSTABLE
	damage = 0
	kill_count = 7
	damage_type = BRUTE
	flag = "bullet"
	hitscan = 1
	var/grabber = 0
	var/mob/living/carbon/human/host

	muzzle_type = /obj/effect/projectile/laser/muzzle/changeling
	tracer_type = /obj/effect/projectile/laser/tracer/changeling
	impact_type = /obj/effect/projectile/laser/impact/changeling

/obj/item/projectile/changeling_whip/on_hit(atom/target, blocked = 0)
	..()
	var/atom/movable/T = target
	var/grab_chance = iscarbon(T) ? 50 : 90
	if(grabber && !T.anchored && prob(grab_chance))
		T.throw_at(host, get_dist(host, T) - 1, 1, spin = FALSE, callback = CALLBACK(src, .proc/end_whipping, T))

/obj/item/projectile/changeling_whip/proc/end_whipping(atom/movable/T)
	if(in_range(T, host) && !host.get_inactive_hand() && !host.lying)
		if(iscarbon(T))
			var/obj/item/weapon/grab/G = new(host,T)
			host.put_in_inactive_hand(G)
			G.state = GRAB_AGGRESSIVE
			G.icon_state = "grabbed1"
			G.synch()
		else if(istype(T, /obj/item))
			host.put_in_inactive_hand(T)

/obj/effect/projectile/laser/tracer/changeling
	icon_state = "changeling"
	light_range = 0
	light_power = 0
	light_color = ""

/obj/effect/projectile/laser/muzzle/changeling
	icon_state = "muzzle_changeling"

/obj/effect/projectile/laser/impact/changeling
	icon_state = "impact_changeling"
