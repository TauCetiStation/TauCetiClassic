/obj/structure/grille
	desc = "A flimsy lattice of metal rods, with screws to secure it to the floor."
	name = "grille"
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"
	density = 1
	anchored = 1
	flags = CONDUCT
	layer = BELOW_MACHINERY_LAYER
	explosion_resistance = 5
	var/health = 10
	var/destroyed = 0
	var/damaged = FALSE

/obj/structure/grille/atom_init()
	. = ..()
	if(destroyed)
		icon_state = "brokengrille"
		density = FALSE
		health = 0

/obj/structure/grille/ex_act(severity)
	switch(severity)
		if(1)
			health -= rand(30, 50)
		if(2)
			health -= rand(15, 30)
		if(3)
			health -= rand(5, 15)
	healthcheck()
	return

/obj/structure/grille/blob_act()
	health -= rand(initial(health)*0.8, initial(health)*3) //Grille will always be blasted, but chances of leaving things over
	healthcheck()

/obj/structure/grille/Bumped(atom/user)
	if(ismob(user)) shock(user, 70)


/obj/structure/grille/attack_paw(mob/user)
	attack_hand(user)

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
		health -= 5
	else
		health -= 1
	healthcheck()

/obj/structure/grille/attack_alien(mob/user)
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	if(istype(user, /mob/living/carbon/xenomorph/larva))	return

	playsound(src, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
	user.visible_message("<span class='warning'>[user] mangles [src].</span>", \
						 "<span class='warning'>You mangle [src].</span>", \
						 "You hear twisting metal.")

	if(!shock(user, 70))
		health -= 5
		healthcheck()
		return

/obj/structure/grille/attack_slime(mob/user)
	if(!istype(user, /mob/living/carbon/slime/adult))	return
	user.SetNextMove(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	playsound(src, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
	user.visible_message("<span class='warning'>[user] smashes against [src].</span>", \
						 "<span class='warning'>You smash against [src].</span>", \
						 "You hear twisting metal.")

	health -= rand(2,3)
	healthcheck()
	return

/obj/structure/grille/attack_animal(mob/living/simple_animal/attacker)
	if(attacker.melee_damage == 0)
		return
	..()
	playsound(src, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
	attacker.visible_message("<span class='warning'>[attacker] smashes against [src].</span>", \
					  "<span class='warning'>You smash against [src].</span>", \
					  "You hear twisting metal.")
	health -= attacker.melee_damage
	healthcheck()
	return


/obj/structure/grille/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(istype(mover) && mover.checkpass(PASSGRILLE))
		return 1
	else
		if(istype(mover, /obj/item/projectile))
			return prob(30)
		else
			return !density

/obj/structure/grille/bullet_act(obj/item/projectile/Proj)

	if(!Proj)	return

	//Tasers and the like should not damage grilles.
	if(Proj.damage_type == HALLOSS)
		return

	src.health -= Proj.damage*0.2
	healthcheck()
	return 0

/obj/structure/grille/attackby(obj/item/weapon/W, mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(iswirecutter(W))
		if(!shock(user, 100))
			playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
			if(destroyed)
				new /obj/item/stack/rods(get_turf(src), 1)
			else
				new /obj/item/stack/rods(get_turf(src), 2)
			qdel(src)
	else if((isscrewdriver(W)) && (istype(loc, /turf/simulated) || anchored))
		if(!shock(user, 90))
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			anchored = !anchored
			user.visible_message("<span class='notice'>[user] [anchored ? "fastens" : "unfastens"] the grille.</span>", \
								 "<span class='notice'>You have [anchored ? "fastened the grille to" : "unfastened the grill from"] the floor.</span>")
			return

//window placing begin
	else if( istype(W,/obj/item/stack/sheet/rglass) || istype(W,/obj/item/stack/sheet/glass) )
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
		for(var/obj/structure/window/WINDOW in loc)
			if(WINDOW.dir == dir_to_set)
				to_chat(user, "<span class='notice'>There is already a window facing this way there.</span>")
				return
		if(user.is_busy(src))
			return
		to_chat(user, "<span class='notice'>You start placing the window.</span>")
		if(W.use_tool(src, user, 20, volume = 100))
			for(var/obj/structure/window/WINDOW in loc)
				if(WINDOW.dir == dir_to_set)//checking this for a 2nd time to check if a window was made while we were waiting.
					to_chat(user, "<span class='notice'>There is already a window facing this way there.</span>")
					return
			if(!ST.use(1))
				return
			var/obj/structure/window/WD
			if(istype(W,/obj/item/stack/sheet/rglass))
				WD = new/obj/structure/window/reinforced(loc) //reinforced window
			else
				WD = new/obj/structure/window/basic(loc) //normal window
			WD.dir = dir_to_set
			WD.ini_dir = dir_to_set
			WD.anchored = 0
			WD.state = 0
			to_chat(user, "<span class='notice'>You place the [WD] on [src].</span>")
			WD.update_icon()
		return
//window placing end

	if(user.a_intent != INTENT_HARM)
		return

	. = ..()
	if((W.flags & CONDUCT) && shock(user, 70))
		return

	playsound(src, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
	switch(W.damtype)
		if("fire")
			health -= W.force
		if("brute")
			health -= W.force * 0.1

	healthcheck()

/obj/structure/grille/proc/healthcheck()
	if(health <= 5)
		if(!destroyed && !damaged)
			icon_state = "grille_damaged_[rand(1, 4)]"
			damaged = 1
	if(health <= 0)
		if(!destroyed)
			icon_state = "brokengrille"
			density = 0
			destroyed = 1
			new /obj/item/stack/rods(get_turf(src))

		else
			if(health <= -6)
				new /obj/item/stack/rods(get_turf(src))
				qdel(src)
				return
	return

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise

/obj/structure/grille/proc/shock(mob/user, prb)
	if(!anchored || destroyed)		// anchored/destroyed grilles are never connected
		return 0
	if(!prob(prb))
		return 0
	if(!in_range(src, user))//To prevent TK and mech users from getting shocked
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
			health -= 1
			healthcheck()
	..()
