/**
 * Base window structure
 */

/obj/structure/window // should not be used by itself
	name = "window"
	desc = "A window you should not see. Contact coders about this anomaly."
	icon = 'icons/obj/window.dmi' // has many legacy icons
	density = TRUE
	layer = WINDOWS_LAYER
	anchored = TRUE

	max_integrity = 14
	integrity_failure = 0.75
	resistance_flags = CAN_BE_HIT

	can_block_air = TRUE

	var/list/drops = list(/obj/item/weapon/shard)

/obj/structure/window/atom_init()
	update_nearby_tiles()
	return ..()

/obj/structure/window/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER, 90)
			else
				playsound(loc, 'sound/weapons/tap.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/structure/window/deconstruct(disassembled)
	if(flags & NODECONSTRUCT)
		return ..()

	if(!disassembled) // disassembled == true is handled by tools in /thin/ and own deconstruct in /fulltile/
		playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
		visible_message("[src] shatters!")

		for(var/path in drops)
			new path(loc)

	return ..()

/obj/structure/window/Destroy()
	update_nearby_tiles()
	return ..()

/obj/structure/window/atom_break(damage_flag)
	. = ..()

	var/ratio = get_integrity() / max_integrity

	// we owerwrite integrity_failure because we have multiple break stages and need to trigger atom_break() multiple times to use them
	switch(ratio)
		if(0 to 0.25)
			if(!istype(src, /obj/structure/window/fulltile))
				visible_message("[src] looks like it's about to shatter!" )
			integrity_failure = 0
		if(0.25 to 0.5)
			if(!istype(src, /obj/structure/window/fulltile))
				visible_message("[src] looks seriously damaged!" )
			integrity_failure = 0.25
		if(0.5 to 0.75)
			if(!istype(src, /obj/structure/window/fulltile))
				visible_message("Cracks begin to appear in [src]!" )
			integrity_failure = 0.5
	update_icon()

/obj/structure/window/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return TRUE
	return !density

/obj/structure/window/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/airlock_painter))
		change_paintjob(W, user)
		return

	if(istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if (isliving(G.affecting))
			user.SetNextMove(CLICK_CD_MELEE)
			var/mob/living/M = G.affecting
			var/mob/living/A = G.assailant
			var/state = G.state
			qdel(W)	//gotta delete it here because if window breaks, it won't get deleted
			switch (state)
				if(1)
					M.apply_damage(7)
					take_damage(7, BRUTE, MELEE)
					visible_message("<span class='danger'>[A] slams [M] against \the [src]!</span>")

					M.log_combat(user, "slammed against [name]")
				if(2)
					if (prob(50))
						M.Stun(1)
						M.Weaken(1)
					M.apply_damage(8)
					take_damage(9, BRUTE, MELEE)
					visible_message("<span class='danger'>[A] bashes [M] against \the [src]!</span>")
					M.log_combat(user, "bashed against [name]")
				if(3)
					M.Stun(5)
					M.Weaken(5)
					M.apply_damage(20)
					take_damage(12, BRUTE, MELEE)
					visible_message("<span class='danger'><big>[A] crushes [M] against \the [src]!</big></span>")
					M.log_combat(user, "crushed against [name]")
		return

	return ..()

// almost same take_damage values as for turf/walls and /obj
// need to reload because for some reason we have stupid parent /obj/structure/ex_act doing nothing
/obj/structure/window/ex_act(severity)
	if(resistance_flags & INDESTRUCTIBLE)
		return
	if(QDELETED(src))
		return
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			take_damage(rand(150, 250), BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(rand(0, 55), BRUTE, BOMB)

/obj/structure/window/airlock_crush_act()
	take_damage(DOOR_CRUSH_DAMAGE * 2, BRUTE, MELEE)
	..()

/obj/structure/window/blob_act()
	take_damage(rand(30, 50), BRUTE, MELEE)

/obj/structure/window/attack_hand(mob/user)	//specflags please!!
	user.SetNextMove(CLICK_CD_MELEE)
	if(HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		attack_generic(user, rand(15, 25), BRUTE, MELEE)
	else if(user.get_species() == GOLEM || user.get_species() == ABOMINATION)
		attack_generic(user, rand(15, 25), BRUTE, MELEE)
	else if (user.a_intent == INTENT_HARM)
		playsound(src, 'sound/effects/glassknock.ogg', VOL_EFFECTS_MASTER)
		user.visible_message("<span class='danger'>[usr.name] bangs against the [src.name]!</span>", \
							"<span class='danger'>You bang against the [src.name]!</span>", \
							"You hear a banging sound.")
	else
		playsound(src, 'sound/effects/glassknock.ogg', VOL_EFFECTS_MASTER)
		user.visible_message("[usr.name] knocks on the [src.name].", \
							"You knock on the [src.name].", \
							"You hear a knocking sound.")

/obj/structure/window/attack_tk(mob/user)
	user.visible_message("<span class='notice'>Something knocks on [src].</span>")
	playsound(src, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER)
	return TRUE

/obj/structure/window/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/window/attack_slime(mob/user)
	if(!isslimeadult(user))
		return
	user.SetNextMove(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	attack_generic(user, rand(10, 15))

/obj/structure/window/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 800)
		take_damage(round(exposed_volume / 100), BURN, FIRE, FALSE)

/obj/structure/window/proc/change_color(new_color)
	color = new_color

/obj/structure/window/proc/change_paintjob(obj/item/weapon/airlock_painter/W, mob/user)
	if(!istype(W))
		return

	if(!W.can_use(user, 1))
		return

	var/new_color = input(user, "Choose color!") as color|null

	if(!new_color)
		return

	if(W.use_tool(src, user, 50, 1))
		change_color(new_color)
