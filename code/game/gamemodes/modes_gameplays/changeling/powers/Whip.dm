/obj/effect/proc_holder/changeling/weapon/whip
	name = "Organic Whip"
	desc = "We reform one of our arms into whip."
	helptext = "Can snatch, knock down, and damage in range depending on your intent, requires a lot of chemical for each use. Cannot be used while in lesser form."
	button_icon_state = "arm_whip"
	chemical_cost = 20
	genomecost = 2
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

/obj/item/weapon/changeling_whip/atom_init()
	. = ..()
	if(ismob(loc))
		loc.visible_message("<span class='warning'>A grotesque blade forms around [loc.name]\'s arm!</span>", "<span class='warning'>Our arm twists and mutates, transforming it into a deadly elastic whip.</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")

/obj/item/weapon/changeling_whip/dropped(mob/user)
	user.visible_message("<span class='warning'>With a sickening crunch, [user] reforms his whip into an arm!</span>", "<span class='notice'>We assimilate the Whip back into our body.</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")
	..()

/obj/item/weapon/changeling_whip/afterattack(atom/target, mob/user, proximity, params)
	if(!istype(user))
		return
	if(user.incapacitated())
		return
	user.SetNextMove(CLICK_CD_MELEE)
	var/obj/item/projectile/changeling_whip/LE = new (get_turf(src))
	switch(user.a_intent)
		if(INTENT_GRAB)
			LE.grabber = TRUE
		if(INTENT_PUSH)
			LE.weaken = 1
		if(INTENT_HARM)
			LE.damage = 15
		else
			LE.agony = 15
	LE.host = user
	LE.Fire(target, user)

/obj/item/projectile/changeling_whip
	name = "Whip"
	icon_state = null
	pass_flags = PASSTABLE
	damage = 0
	kill_count = 7
	damage_type = BRUTE
	flag = BULLET
	var/grabber = FALSE
	var/mob/living/carbon/human/host
	tracer_list = list()
	muzzle_type = /obj/effect/projectile/changeling/muzzle
	tracer_type = /obj/effect/projectile/changeling/tracer
	impact_type = /obj/effect/projectile/changeling/impact

/obj/item/projectile/changeling_whip/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	if(isturf(target))
		return
	var/atom/movable/T = target
	if(grabber)
		var/grab_chance = 100
		if(iscarbon(T))
			var/mob/living/carbon/C = T
			grab_chance -= C.run_armor_check(def_zone, absorb_text = TRUE)
			if(def_zone == BP_CHEST || def_zone == BP_GROIN)	//limbs are easier to catch with a tentacle
				grab_chance -= 20
		if(!T.anchored && prob(grab_chance))
			T.throw_at(host, get_dist(host, T) - 1, 1, spin = FALSE, callback = CALLBACK(src, PROC_REF(end_whipping), T))
	return ..()

/obj/item/projectile/changeling_whip/proc/end_whipping(atom/movable/T)
	if(T.Adjacent(host) && !host.get_inactive_hand())
		if(iscarbon(T))
			host.Grab(T, GRAB_AGGRESSIVE, FALSE)
		else if(isitem(T))
			host.put_in_inactive_hand(T)

/obj/item/projectile/changeling_whip/process()
	spawn while(src && loc)
		if(paused)
			host.Stun(2, TRUE)
		sleep(1)
	..()

/obj/effect/projectile/changeling
	time_to_live = 0

/obj/effect/projectile/changeling/tracer
	icon_state = "changeling"

/obj/effect/projectile/changeling/muzzle
	icon_state = "muzzle_changeling"

/obj/effect/projectile/changeling/impact
	time_to_live = 2
	icon_state = "impact_changeling"
