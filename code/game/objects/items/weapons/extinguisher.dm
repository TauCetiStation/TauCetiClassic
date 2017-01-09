/obj/item/weapon/extinguisher
	name = "fire extinguisher"
	desc = "A traditional red fire extinguisher."
	icon = 'icons/obj/items.dmi'
	icon_state = "fire_extinguisher0"
	item_state = "fire_extinguisher"
	hitsound = 'sound/weapons/smash.ogg'
	flags = CONDUCT
	throwforce = 10
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 10.0
	m_amt = 90
	attack_verb = list("slammed", "whacked", "bashed", "thunked", "battered", "bludgeoned", "thrashed")
	var/max_water = 50
	var/last_use = 1.0
	var/safety = 1
	var/sprite_name = "fire_extinguisher"
	var/spray_amount = 1	//units of liquid per particle
	var/spray_range = 4

/obj/item/weapon/extinguisher/mini
	name = "fire extinguisher"
	desc = "A light and compact fibreglass-framed model fire extinguisher."
	icon_state = "miniFE0"
	item_state = "miniFE"
	hitsound = null	//it is much lighter, after all.
	throwforce = 2
	w_class = 2.0
	force = 3.0
	m_amt = 0
	max_water = 30
	sprite_name = "miniFE"

/obj/item/weapon/extinguisher/New()
	var/datum/reagents/R = new/datum/reagents(max_water)
	reagents = R
	R.my_atom = src
	R.add_reagent("water", max_water)

/obj/item/weapon/extinguisher/examine(mob/user)
	..()
	if(src in user)
		to_chat(user, "[reagents.total_volume] units of water left!")

/obj/item/weapon/extinguisher/attack_self(mob/user)
	safety = !safety
	src.icon_state = "[sprite_name][!safety]"
	src.desc = "The safety is [safety ? "on" : "off"]."
	to_chat(user, "<span class='notice'>The safety is [safety ? "on" : "off"].</span>")
	return

/obj/item/weapon/extinguisher/afterattack(atom/target, mob/user , flag)
	//TODO; Add support for reagents in water.

	if( istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(src,target) <= 1)
		var/obj/O = target
		O.reagents.trans_to(src, 50)
		to_chat(user, "<span class='notice'>[src] is now refilled.</span>")
		playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
		return

	if (!safety)
		if (src.reagents.total_volume < 1)
			to_chat(usr, "<span class='rose'>[src] is empty.</span>")
			return

		if (world.time < src.last_use + 20)
			return

		src.last_use = world.time

		playsound(src.loc, 'sound/effects/extinguish.ogg', 75, 1, -3)

		var/direction = get_dir(src,target)

		if(usr.buckled && isobj(usr.buckled) && !usr.buckled.anchored )
			spawn(0)
				var/obj/structure/stool/bed/chair/C = null
				if(istype(usr.buckled, /obj/structure/stool/bed/chair))
					C = usr.buckled
				var/obj/B = usr.buckled
				var/movementdirection = turn(direction,180)
				if(C)	C.propelled = 4
				step(B, movementdirection)
				sleep(1)
				step(B, movementdirection)
				if(C)	C.propelled = 3
				sleep(1)
				step(B, movementdirection)
				sleep(1)
				step(B, movementdirection)
				if(C)	C.propelled = 2
				sleep(2)
				step(B, movementdirection)
				if(C)	C.propelled = 1
				sleep(2)
				step(B, movementdirection)
				if(C)	C.propelled = 0
				sleep(3)
				step(B, movementdirection)
				sleep(3)
				step(B, movementdirection)
				sleep(3)
				step(B, movementdirection)
		else
			user.newtonian_move(turn(direction, 180))

		var/turf/T = get_turf(target)
		var/turf/T1 = get_step(T,turn(direction, 90))
		var/turf/T2 = get_step(T,turn(direction, -90))

		var/list/the_targets = list(T,T1,T2)

		for(var/a in 0 to spray_range)
			spawn(0)
				var/obj/effect/effect/water/W = PoolOrNew(/obj/effect/effect/water, get_turf(src))
				var/turf/my_target = pick(the_targets)
				var/datum/reagents/R = new/datum/reagents(spray_amount)
				if(!W) return
				W.reagents = R
				R.my_atom = W
				if(!W || !src) return
				src.reagents.trans_to(W, spray_amount)

				for(var/b in 0 to spray_range)
					step_towards(W,my_target)
					if(!W) return
					if(!W.reagents) break
					W.reagents.reaction(get_turf(W))
					for(var/atom/atm in get_turf(W))
						if(!W) return
						if(!W.reagents) break
						W.reagents.reaction(atm)
						if(isliving(atm)) //For extinguishing mobs on fire
							var/mob/living/M = atm
							M.ExtinguishMob()
					if(W.loc == my_target) break
					sleep(2)
				qdel(W)
	else
		return ..()
	return
