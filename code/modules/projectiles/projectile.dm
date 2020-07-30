/*
#define BRUTE "brute"
#define BURN "burn"
#define TOX "tox"
#define OXY "oxy"
#define CLONE "clone"

#define ADD "add"
#define SET "set"
*/

/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bullet"
	density = 1
	unacidable = 1
	anchored = 1 //There's a reason this is here, Mport. God fucking damn it -Agouri. Find&Fix by Pete. The reason this is here is to stop the curving of emitter shots.
	pass_flags = PASSTABLE
	mouse_opacity = 0
	appearance_flags = 0
	var/bumped = 0		//Prevents it from hitting more than one guy at once
	var/def_zone = ""	//Aiming at
	var/mob/firer = null//Who shot it
	var/silenced = 0	//Attack message
	var/yo = null
	var/xo = null
	var/current = null
	var/obj/shot_from = null // the object which shot us
	var/atom/original = null // the original target clicked
	var/turf/starting = null // the projectile's starting turf
	var/list/permutated = list() // we've passed through these atoms, don't try to hit them again

	var/p_x = 16
	var/p_y = 16 // the pixel location of the tile that the player clicked. Default is the center

	var/dispersion = 0.0

	var/damage = 10
	var/damage_type = BRUTE //BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
	var/nodamage = 0 //Determines if the projectile will skip any damage inflictions
	var/fake = 0 //Fake projectile won't spam chat for admins with useless logs
	var/flag = "bullet" //Defines what armor to use when it hits things.  Must be set to bullet, laser, energy,or bomb	//Cael - bio and rad are also valid
	var/projectile_type = "/obj/item/projectile"
	var/kill_count = 50 //This will de-increment every process(). When 0, it will delete the projectile.
	var/paused = FALSE //for suspending the projectile midair
		//Effects
	var/stun = 0
	var/weaken = 0
	var/paralyze = 0
	var/irradiate = 0
	var/stutter = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/agony = 0
	var/embed = 0 // whether or not the projectile can embed itself in the mob
	var/impact_force = 0

	var/hitscan = 0	// whether the projectile should be hitscan
	var/step_delay = 1	// the delay between iterations if not a hitscan projectile

	// effect types to be used
	var/list/tracer_list = null // if set to list, it will be gathering all projectile effects into list and delete them after impact(unless they ask to not be deleted)
	var/muzzle_type
	var/tracer_type
	var/impact_type

	var/datum/plot_vector/trajectory	// used to plot the path of the projectile
	var/datum/vector_loc/location		// current location of the projectile in pixel space
	var/matrix/effect_transform			// matrix to rotate and scale projectile effects - putting it here so it doesn't
										//  have to be recreated multiple times

	var/list/proj_act_sound = null // this probably could be merged into the one below, because bullet_act is too specific, while on_impact (Bump) handles bullet_act too.
	// ^ the one above used in bullet_act for mobs, while this one below used in on_impact() which happens after Bump() or killed by process. v
	var/proj_impact_sound = null // originally made for big plasma ball hit sound, and its okay when both proj_act_sound and this one plays at the same time.

/obj/item/projectile/atom_init()
	damtype = damage_type // TODO unify these vars properly (Bay12)
	if(timestop_count)
		var/obj/effect/timestop/T = locate() in loc
		if(T)
			T.timestop(src)
	. = ..()
	if(light_color)
		set_light(light_range,light_power,light_color)

/obj/item/projectile/Destroy()
	for(var/obj/effect/projectile/P in tracer_list)
		if(!P.deletes_itself)
			qdel(P)
	tracer_list = null
	firer = null
	starting = null
	original = null
	shot_from = null
	return ..()


/obj/item/projectile/proc/check_living_shield(mob/living/carbon/human/H)
	var/obj/item/weapon/grab/grab = null
	if(istype(H.r_hand,/obj/item/weapon/grab))
		grab = H.r_hand
	else if(istype(H.l_hand,/obj/item/weapon/grab))
		grab = H.l_hand
	if(!grab)
		return H
	if(grab.state >= GRAB_NECK && !grab.affecting.lying)
		if(is_the_opposite_dir(H.dir, dir))
			return grab.affecting
	return H

/obj/item/projectile/proc/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	if(!isliving(target))	return 0
	if(isanimal(target))	return 0
	var/mob/living/L = target
	return L.apply_effects(stun, weaken, paralyze, irradiate, stutter, eyeblur, drowsy, agony, blocked) // add in AGONY!

	//called when the projectile stops flying because it collided with something
/obj/item/projectile/proc/on_impact(atom/A)
	impact_effect(effect_transform)		// generate impact effect
	if(proj_impact_sound)
		playsound(src, proj_impact_sound, VOL_EFFECTS_MASTER)

/obj/item/projectile/proc/check_fire(mob/living/target, mob/living/user)  //Checks if you can hit them or not.
	if(!istype(target) || !istype(user))
		return 0
	var/obj/item/projectile/test/in_chamber = new /obj/item/projectile/test(get_step_to(user,target)) //Making the test....
	in_chamber.target = target
	in_chamber.flags = flags //Set the flags...
	in_chamber.pass_flags = pass_flags //And the pass flags to that of the real projectile...
	in_chamber.firer = user
	var/output = in_chamber.process() //Test it!
	qdel(in_chamber) //No need for it anymore
	return output //Send it back to the gun!

/proc/check_trajectory(atom/target, atom/firer, pass_flags = PASSTABLE|PASSGLASS|PASSGRILLE, flags = null) //Spherical test in vacuum
	if(!istype(target) || !istype(firer))
		return 0

	var/obj/item/projectile/test/dummy/trace = new /obj/item/projectile/test/dummy(get_turf(firer)) //Making the test....

	//Set the flags and pass flags to that of the real projectile...
	if(!isnull(flags))
		trace.flags = flags
	trace.target = target
	trace.pass_flags = pass_flags

	var/output = trace.process() //Test it!
	qdel(trace) //No need for it anymore
	return output //Send it back to the gun!

//Used to change the direction of the projectile in flight.
/obj/item/projectile/proc/redirect(new_x, new_y, atom/starting_loc, mob/new_firer=null)
	original = locate(new_x, new_y, src.z)
	starting = starting_loc
	current = starting_loc
	if(new_firer)
		firer = new_firer

	yo = new_y - starting_loc.y
	xo = new_x - starting_loc.x
	setup_trajectory()

/obj/item/projectile/proc/After_hit()
	return

/obj/item/projectile/Bump(atom/A, forced=0)
	if(A == src)
		return 0 //no

	if(A == firer)
		loc = A.loc
		return 0 //cannot shoot yourself

	if((bumped && !forced) || (A in permutated))
		return 0

	var/forcedodge = 0 // force the projectile to pass
	var/mob/living/M = isliving(A) ? A : null
	var/mob/old_firer = firer
	bumped = 1
	if(firer && M)
		if(!istype(A, /mob/living))
			loc = A.loc
			return 0// nope.avi
		var/distance = get_dist(starting,loc) //More distance = less damage, except for high fire power weapons.
		var/miss_modifier = 0
		if(damage && (distance > 7))
			if(damage < 55)
				damage = max(1, damage - round(damage * (((distance-6)*3)/100)))
				miss_modifier = - 100 // so sniper rifle and PTR-rifle projectiles cannot miss
		if (istype(shot_from,/obj/item/weapon/gun))	//If you aim at someone beforehead, it'll hit more often.
			var/obj/item/weapon/gun/daddy = shot_from //Kinda balanced by fact you need like 2 seconds to aim
			if (daddy.target && (original in daddy.target)) //As opposed to no-delay pew pew
				miss_modifier -= 60
		if(distance > 1)
			def_zone = get_zone_with_miss_chance(def_zone, M, miss_modifier)

		if(!def_zone)
			forcedodge = PROJECTILE_FORCE_MISS

	if(!forcedodge)
		if(M && ishuman(M))
			M = check_living_shield(A)
			A = M

		forcedodge = A.bullet_act(src, def_zone) // searches for return value

	if(forcedodge == PROJECTILE_FORCE_MISS) // the bullet passes through a dense object!
		if(M)
			visible_message("<span class = 'notice'>\The [src] misses [M] narrowly!</span>")
			playsound(M.loc, pick(SOUNDIN_BULLETMISSACT), VOL_EFFECTS_MASTER)

		if(istype(A, /turf))
			loc = A
		else
			loc = A.loc
		bumped = FALSE // reset bumped variable!
		permutated.Add(A)

		return FALSE

	else if(M)
		if(silenced)
			to_chat(M, "<span class='userdanger'>You've been shot in the [parse_zone(def_zone)] by the [src.name]!</span>")
		else if(!fake)
			M.visible_message("<span class='userdanger'>[M.name] is hit by the [src.name] in the [parse_zone(def_zone)]!</span>")
			//X has fired Y is now given by the guns so you cant tell who shot you if you could not see the shooter
		if(old_firer)
			M.log_combat(old_firer, "shot with <b>[type]</b>", alert_admins = !fake)
		else
			M.attack_log += "\[[time_stamp()]\] <b>UNKNOWN SUBJECT</b> shot <b>[M]/[M.ckey]</b> with a <b>[src]</b>"
			if(!fake)
				msg_admin_attack("UNKNOWN shot [M.name] ([M.ckey]) with a [src]", M) //BS12 EDIT ALG


	if(istype(A,/turf))
		for(var/obj/O in A)
			O.bullet_act(src)
		for(var/mob/Mob in A)
			Mob.bullet_act(src, def_zone)

	//stop flying
	on_impact(A)

	density = 0
	invisibility = 101
	qdel(src)
	return 1


/obj/item/projectile/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(istype(mover, /obj/item/projectile))
		return prob(95)
	else
		return 1


/obj/item/projectile/process(boolet_number = 1) // we add default arg value, because there is alot of uses of projectiles without guns (e.g turrets).
	var/first_step = 1

	//plot the initial trajectory
	setup_trajectory()

	spawn while(src && src.loc)
		if(paused)
			stoplag(1)
			continue
		if(kill_count-- < 1)
			on_impact(src.loc) //for any final impact behaviours
			qdel(src)
			return
		if((!( current ) || loc == current))
			current = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z)
		if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
			qdel(src)
			return
		trajectory.increment()	// increment the current location
		location = trajectory.return_location(location)		// update the locally stored location data

		if(!location)
			qdel(src)	// if it's left the world... kill it
			return

		before_move()
		Move(location.return_turf())

		if(!bumped && !isturf(original))
			if(loc == get_turf(original))
				if(isturf(original.loc))
					if(!(original in permutated))
						if(Bump(original))
							return
				else//if target is in mecha/crate/MULE/etc
					if(!(original.loc in permutated))
						if(Bump(original.loc))
							return

		if(first_step)
			if(boolet_number == 1) // so that it won't spam with muzzle effects incase of multiple pellets.
				muzzle_effect(effect_transform)
			first_step = 0
		else if(!bumped)
			tracer_effect(effect_transform)

		Range()

		if(!hitscan)
			sleep(step_delay)	//add delay between movement iterations if it's not a hitscan weapon

/obj/item/projectile/proc/before_move()
	return

/obj/item/projectile/proc/setup_trajectory()
	var/offset = 0

	if(dispersion)
		var/radius = round(dispersion * 9, 1)
		offset = rand(-radius, radius)

	// plot the initial trajectory
	trajectory = new()
	trajectory.setup(starting, original, pixel_x, pixel_y, angle_offset=offset)

	// generate this now since all visual effects the projectile makes can use it
	effect_transform = new()
	effect_transform.Scale(trajectory.return_hypotenuse(), 1)
	effect_transform.Turn(-trajectory.return_angle())		//no idea why this has to be inverted, but it works

/obj/item/projectile/proc/muzzle_effect(var/matrix/T)
	if(silenced)
		return

	if(ispath(muzzle_type))
		var/obj/effect/projectile/M = new muzzle_type(get_turf(src))

		if(istype(M))
			if(tracer_list)
				tracer_list += M
			M.set_transform(T)
			M.pixel_x = location.pixel_x
			M.pixel_y = location.pixel_y
			M.activate()

/obj/item/projectile/proc/tracer_effect(matrix/M)
	if(ispath(tracer_type))
		var/obj/effect/projectile/P = new tracer_type(location.loc)

		if(istype(P))
			if(tracer_list)
				tracer_list += P
			P.set_transform(M)
			P.pixel_x = location.pixel_x
			P.pixel_y = location.pixel_y
			P.activate()

/obj/item/projectile/proc/impact_effect(matrix/M)
	if(ispath(impact_type) && location)
		var/obj/effect/projectile/P = new impact_type(location.loc)

		if(istype(P))
			if(tracer_list)
				tracer_list += P
			P.set_transform(M)
			P.pixel_x = location.pixel_x
			P.pixel_y = location.pixel_y
			P.activate()

/obj/item/projectile/proc/Fire(atom/A, mob/living/user)
	var/turf/T = get_turf(user)
	var/turf/U = get_turf(A)
	firer = user
	def_zone = check_zone(user.zone_sel.selecting)
	starting = T
	original = A
	current = T
	yo = U.y - T.y
	xo = U.x - T.x
	process()

/obj/item/projectile/test //Used to see if you can hit them.
	invisibility = 101 //Nope!  Can't see me!
	yo = null
	xo = null
	var/target = null
	var/result = 0 //To pass the message back to the gun.

/obj/item/projectile/test/Bump(atom/A)
	if(A == firer)
		loc = A.loc
		return //cannot shoot yourself
	if(istype(A, /obj/item/projectile))
		return
	if(istype(A, /mob/living))
		result = 2 //We hit someone, return 1 (in process() 2 will be decremented to 1)!
		bumped = TRUE
		return
	if(checkpass(PASSGLASS) && istype(A, /obj/structure/window))
		return
	if(checkpass(PASSGRILLE) && istype(A, /obj/structure/grille))
		return
	result = 1
	bumped = TRUE

/obj/item/projectile/test/process()
	var/turf/curloc = get_turf(src)
	var/turf/targloc = get_turf(target)
	if(!curloc || !targloc)
		return 0
	yo = targloc.y - curloc.y
	xo = targloc.x - curloc.x
	original = target
	target = targloc
	starting = curloc

	//plot the initial trajectory
	setup_trajectory()

	while(src) //Loop on through!
		if(result)
			return (result - 1)
		if(!target || loc == target)
			target = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z) //Finding the target turf at map edge
		if(x == 1 || x == world.maxx || y == 1 || y == world.maxy || kill_count-- < 1)
			qdel(src)
			return 0

		trajectory.increment()	// increment the current location
		location = trajectory.return_location(location)		// update the locally stored location data
		if(!location)
			qdel(src)
			return 0

		Move(location.return_turf())

		if(!bumped && !isturf(original) && loc == get_turf(original))
			if(isturf(original.loc))
				Bump(original)
			else
				Bump(original.loc) //if target is in mecha/crate/MULE/etc

/obj/item/projectile/test/dummy/Bump(atom/A) //Another test projectile with increased checklist
	..()
	if(result != 1)
		return
	//bumped is already set to TRUE
	if(is_type_in_list(A, list(/obj/structure/closet, /obj/mecha, /obj/machinery/bot/mulebot)))
		result = 2
	return

/obj/item/projectile/proc/Range() ///tg/
	return

/obj/item/projectile/Process_Spacemove(movement_dir = 0)
	return 1 //Bullets don't drift in space

var/static/list/taser_projectiles = list(
	/obj/item/projectile/beam/stun,
	/obj/item/ammo_casing/energy/electrode
)
