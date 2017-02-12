/obj/effect/proc_holder/changeling/weapon/whip
	name = "Organic Whip"
	desc = "We reform one of our arms into whip."
	helptext = "...."
	chemical_cost = 20
	genomecost = 5
	genetic_damage = 12
	req_human = 1
	max_genetic_damage = 10
	weapon_type = /obj/item/weapon/changeling_whip
	weapon_name_simple = "whip"

/obj/item/weapon/changeling_whip
	name = "whip-like mass"
	desc = "A mass of tough, boney tissue. You can still see the fingers as a twisted pattern in the shield."
	canremove = 0
	icon = 'icons/obj/weapons.dmi'
	icon_state = "ling_shield"
	item_state = "ling_shield"
	var/next_click

/obj/item/weapon/changeling_whip/New()
	..()
	if(ismob(loc))
		loc.visible_message("<span class='warning'>A grotesque blade forms around [loc.name]\'s arm!</span>", "<span class='warning'>Our arm twists and mutates, transforming it into a deadly blade.</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")
		host = loc

/obj/item/weapon/changeling_whip/dropped(mob/user)
	visible_message("<span class='warning'>With a sickening crunch, [user] reforms his blade into an arm!</span>", "<span class='notice'>We assimilate the blade back into our body.</span>", "<span class='warning>You hear organic matter ripping and tearing!</span>")
	qdel(src)

/obj/item/weapon/changeling_whip/afterattack(atom/A, mob/user)
	if(next_click > world.time)
		return
	if(!use_charge(A,user, 1))
		return
	next_click = world.time + 10
	var/mob/living/carbon/H = user
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(A)
	var/obj/item/projectile/changeling_whip/LE = new /obj/item/projectile/changeling_whip(T)
	if(user.a_intent == "grab")
		LE.grabber = 1
	else if(user.a_intent == "disarm" && prob(50))
		LE.weaken = 5
	else if(user.a_intent == "hurt")
		LE.damage = 30
	LE.host = host
	LE.def_zone = check_zone(H.zone_sel.selecting)
	LE.starting = T
	LE.original = A
	LE.current = T
	LE.yo = U.y - T.y
	LE.xo = U.x - T.x
	spawn( 1 )
		LE.process()

/obj/item/projectile/changeling_whip
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE
	damage = 5
	kill_count = 7
	damage_type = BRUTE
	flag = "bullet"
	hitscan = 1
	var/grabber = 0
	var/mob/living/carbon/human/host

	muzzle_type = /obj/effect/projectile/laser/muzzle
	tracer_type = /obj/effect/projectile/laser/tracer
	impact_type = /obj/effect/projectile/laser/impact

/obj/item/projectile/changeling_whip/on_hit(atom/target, blocked = 0)
	..()
	var/atom/movable/T = target
	if(grabber && !T.anchored)
		spawn(1)
			T.throw_at(host, 7 - kill_count, 0.2)
			sleep(2)
			if(in_range(T, host) && !host.get_inactive_hand())
				if(istype(T, /mob/living/carbon))
					var/obj/item/weapon/grab/G = new(host,target)
					host.put_in_inactive_hand(G)
					G.state = GRAB_AGGRESSIVE
					G.icon_state = "grabbed1"
					G.synch()
				else if(istype(T, /obj/item))
					host.put_in_inactive_hand(T)
