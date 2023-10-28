/obj/structure/grille
	desc = "A flimsy lattice of metal rods, with screws to secure it to the floor."
	name = "grille"
	icon = 'icons/obj/smooth_structures/grille.dmi'
	icon_state = "center_8"

	density = TRUE
	anchored = TRUE
	flags = CONDUCT
	layer = BELOW_MACHINERY_LAYER

	integrity_failure = 0.4
	max_integrity = 20
	resistance_flags = CAN_BE_HIT

	var/destroyed = 0
	var/damaged = FALSE

/obj/structure/grille/atom_init(mapload, spawn_unanchored = FALSE)
	. = ..()
	if(destroyed)
		destroyed = FALSE // let atom_break reset destroyed
		update_integrity(get_integrity() * integrity_failure)

	if(spawn_unanchored)
		anchored = FALSE

	if(anchored && (locate(/obj/structure/windowsill) in loc))
		set_smooth(TRUE)

/obj/structure/grille/proc/set_smooth(make_smooth = TRUE)
	if(make_smooth)
		smooth = SMOOTH_TRUE
		canSmoothWith = CAN_SMOOTH_WITH_WALLS
		queue_smooth(src)
	else
		smooth = FALSE
		canSmoothWith = null
		icon = initial(icon)
		icon_state = initial(icon_state)

/obj/structure/grille/Bumped(atom/user)
	if(ismob(user)) shock(user, 70)

/obj/structure/grille/run_atom_armor(damage_amount, damage_type, damage_flag, attack_dir)
	switch(damage_type)
		if(BRUTE)
			return damage_amount * 0.2
		if(BURN)
			return damage_amount

/obj/structure/grille/attack_hand(mob/user)
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	playsound(src, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
	user.visible_message("<span class='warning'>[user] kicks [src].</span>", \
						 "<span class='warning'>You kick [src].</span>", \
						 "You hear twisting metal.")

	if(shock(user, 70))
		return
	if(HULK in user.mutations)
		take_damage(25, BRUTE, MELEE)
	else
		take_damage(5, BRUTE, MELEE)

/obj/structure/grille/attack_alien(mob/living/carbon/xenomorph/humanoid/user)
	if(!istype(user))
		return
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	user.visible_message("<span class='warning'>[user] mangles [src].</span>", \
						 "<span class='warning'>You mangle [src].</span>", \
						 "You hear twisting metal.")

	if(!shock(user, 70))
		return take_damage(25, BRUTE, MELEE, TRUE)

/obj/structure/grille/attack_slime(mob/user)
	. = ..()
	if(.)
		user.visible_message("<span class='warning'>[user] smashes against [src].</span>", \
							"<span class='warning'>You smash against [src].</span>", \
							"You hear twisting metal.")

/obj/structure/grille/attack_animal(mob/living/simple_animal/attacker)
	. = ..()
	if(.)
		attacker.visible_message("<span class='warning'>[attacker] smashes against [src].</span>", \
						"<span class='warning'>You smash against [src].</span>", \
						"You hear twisting metal.")

/obj/structure/grille/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGRILLE))
		return 1
	else
		if(istype(mover, /obj/item/projectile))
			return prob(30)
		else
			return !density

/obj/structure/grille/attackby(obj/item/weapon/W, mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(iscutter(W))
		if(!shock(user, 100))
			playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
			deconstruct(TRUE)
			return
	else if((isscrewing(W)) && (istype(loc, /turf/simulated) || anchored))
		if(!shock(user, 90))
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			anchored = !anchored

			var/obj/structure/windowsill/windowsill = locate() in loc

			if(anchored && windowsill)
				set_smooth(TRUE)
			else if (!anchored)
				set_smooth(FALSE)

			user.visible_message("<span class='notice'>[user] [anchored ? "fastens" : "unfastens"] the grille.</span>", \
								 "<span class='notice'>You have [anchored ? "fastened the grille to" : "unfastened the grill from"] [windowsill ? "\the [windowsill]" : "the floor"].</span>")
			return

//window placing begin
	else if( istype(W,/obj/item/stack/sheet/rglass) || istype(W,/obj/item/stack/sheet/glass) )
		var/obj/structure/windowsill/WS = locate() in loc
		if(WS) // thats for fulltile window, redirect
			WS.attackby(W, user)
			return

		var/obj/item/stack/ST = W
		if(ST.get_amount() < 1)
			return
		var/dir_to_set = 1
		if(loc == user.loc)
			dir_to_set = user.dir
		else
			if( ( x == user.x ) || (y == user.y) ) //Only supposed to work for cardinal directions.
				if( x == user.x )
					if( y > user.y )
						dir_to_set = 2
					else
						dir_to_set = 1
				else if( y == user.y )
					if( x > user.x )
						dir_to_set = 8
					else
						dir_to_set = 4
			else
				to_chat(user, "<span class='notice'>You can't reach.</span>")
				return //Only works for cardinal direcitons, diagonals aren't supposed to work like this.
		for(var/obj/structure/window/thin/WINDOW in loc)
			if(WINDOW.dir == dir_to_set)
				to_chat(user, "<span class='notice'>There is already a window facing this way there.</span>")
				return
		if(user.is_busy(src))
			return
		to_chat(user, "<span class='notice'>You start placing the window.</span>")
		if(W.use_tool(src, user, 20, volume = 100))
			for(var/obj/structure/window/thin/WINDOW in loc)
				if(WINDOW.dir == dir_to_set)//checking this for a 2nd time to check if a window was made while we were waiting.
					to_chat(user, "<span class='notice'>There is already a window facing this way there.</span>")
					return
			if(!ST.use(1))
				return
			var/obj/structure/window/thin/WD
			if(istype(W,/obj/item/stack/sheet/rglass))
				WD = new/obj/structure/window/thin/reinforced(loc) //reinforced window
			else
				WD = new/obj/structure/window/thin(loc) //normal window
			WD.set_dir(dir_to_set)
			WD.ini_dir = dir_to_set
			WD.anchored = FALSE
			to_chat(user, "<span class='notice'>You place the [WD] on [src].</span>")
			WD.update_icon()
		return
	else
		..()
//window placing end

/obj/structure/grille/attacked_by(obj/item/attacking_item, mob/living/user)
	if((attacking_item.flags & CONDUCT) && shock(user, 70))
		return
	..()

/obj/structure/grille/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER, 80, TRUE)
			else
				playsound(loc, 'sound/weapons/tap.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 80, TRUE)

/obj/structure/grille/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir)
	. = ..()
	if(. && !(destroyed || damaged))
		damaged = TRUE
		update_icon()

/obj/structure/grille/atom_break(damage_flag)
	. = ..()
	if(destroyed)
		return
	density = FALSE
	destroyed = TRUE
	update_icon()
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/rods(loc)

/obj/structure/grille/deconstruct(disassembled)
	if(flags & NODECONSTRUCT)
		return ..()
	new /obj/item/stack/rods(loc, destroyed ? 1 : 2)
	..()

/obj/structure/grille/update_icon()
	if(destroyed)
		add_filter("hole_in_the_grill", 1, alpha_mask_filter(icon = icon('icons/obj/structures.dmi', "grille_broken")))
	else if(damaged)
		add_filter("hole_in_the_grill", 1, alpha_mask_filter(icon = icon('icons/obj/structures.dmi', "grille_damaged_[rand(1, 4)]")))
	else
		remove_filter("hole_in_the_grill")

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise

/obj/structure/grille/proc/shock(mob/user, prb)
	if(!anchored || destroyed)		// anchored/destroyed grilles are never connected
		return 0
	if(!prob(prb))
		return 0
	if(!Adjacent(user))//To prevent TK and mech users from getting shocked
		return 0
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(electrocute_mob(user, C, src))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			return 1
		else
			return 0
	return 0

/obj/structure/grille/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!destroyed)
		if(exposed_temperature > T0C + 1500)
			take_damage(1, BURN, FIRE, FALSE)
