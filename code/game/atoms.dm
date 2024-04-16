/atom
	layer = TURF_LAYER
	plane = GAME_PLANE

	var/flags = 0
	var/flags_2 = 0
	var/list/fingerprints
	var/list/fingerprintshidden
	var/fingerprintslast = null

	var/list/blood_DNA      //forensic reasons
	var/datum/dirt_cover/dirt_overlay  //style reasons

	var/uncleanable = 0

	var/last_bumped = 0
	var/pass_flags = NONE
	var/throwpass = 0
	var/germ_level = GERM_LEVEL_AMBIENT // The higher the germ level, the more germ on the atom.
	var/simulated = 1 //filter for actions - used by lighting overlays

	var/resize = 1		//don't abuse this shit
	var/resize_rev = 1	//helps to restore default size

	var/initialized = FALSE

	/// a very temporary list of overlays to remove
	var/list/remove_overlays
	/// a very temporary list of overlays to add
	var/list/add_overlays

	/// parallax thing
	var/list/clients_in_contents

	///This atom's HUD (med/sec, etc) images. Associative list.
	var/list/image/hud_list = null
	///HUD images that this atom can provide.
	var/list/hud_possible
	///Current alternate_apperances on atom
	var/list/datum/atom_hud/alternate_appearance/alternate_appearances

	///Chemistry.
	var/datum/reagents/reagents = null

	//var/chem_is_open_container = 0
	// replaced by OPENCONTAINER flags and atom/proc/is_open_container()
	///Chemistry.

	//Detective Work, used for the duplicate data points kept in the scanners
	var/list/original_atom

	var/in_use_action = FALSE // do_after sets this to TRUE and is_busy() can check for that to disallow multiple users to interact with this at the same time.

	/// Last name used to calculate a color for the chatmessage overlays
	var/chat_color_name
	/// Last color calculated for the the chatmessage overlays
	var/chat_color
	/// A luminescence-shifted value of the last color calculated for chatmessage overlays
	var/chat_color_darkened

	///any atom that uses integrity and can be damaged must set this to true, otherwise the integrity procs will throw an error
	var/uses_integrity = FALSE

	var/list/armor // TODO armor gatum?
	VAR_PRIVATE/atom_integrity //defaults to max_integrity
	var/max_integrity = 500
	var/integrity_failure = 0 //0 if we have no special broken behavior, otherwise is a percentage of at what point the atom breaks. 0.5 being 50%
	///Damage under this value will be completely ignored
	var/damage_deflection = 0

	///How much this atom resists explosions by, in the end
	///In terms of explosion, you can read it as additional distance for explosion to spend on this turf
	var/explosive_resistance = 0

	var/resistance_flags = FULL_INDESTRUCTIBLE // INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ON_FIRE | UNACIDABLE | ACID_PROOF

	var/can_block_air = FALSE // shared flag between /turf/s and /movable/s, you should use it only for movables
	                          // if you want to set it true for object then remember to create CanPass or c_airblock methods or it will do nothing (pls refactor it)

/atom/New(loc, ...)
	if(use_preloader && (src.type == _preloader.target_path))//in case the instanciated atom is creating other atoms in New()
		_preloader.load(src)

	//. = ..() //uncomment if you are dumb enough to add a /datum/New() proc

	var/do_initialize = SSatoms.initialized
	if(do_initialize > INITIALIZATION_INSSATOMS)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, args))
			//we were deleted
			return
	SSdemo.mark_new(src)

	var/list/created = SSatoms.created_atoms
	if(created)
		created += src

// Called after New if the map is being loaded. mapload = TRUE
// Called from base of New if the map is being loaded. mapload = FALSE
// This base must be called or derivatives must set initialized to TRUE
// must not sleep
// Other parameters are passed from New (excluding loc), this does not happen if mapload is TRUE
// Must return an Initialize hint. Defined in __DEFINES/subsystems.dm

//Note: the following functions don't call the base for optimization and must copypasta:
// /turf/atom_init
// /turf/environment/space/atom_init
// /mob/dead/atom_init
// /obj/item

// Read commentary above if you want to create:
// /atom/movable/atom_init

/atom/proc/atom_init(mapload, ...)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	if(light_power && light_range)
		update_light()

	if(opacity && isturf(loc))
		var/turf/T = loc
		T.has_opaque_atom = TRUE // No need to recalculate it in this case, it's guaranteed to be on afterwards anyways.

	if(can_block_air && isturf(loc))
		var/turf/T = loc
		if(!T.can_block_air)
			T.can_block_air = TRUE

	if(uses_integrity)
		if (!armor)
			armor = list()
		atom_integrity = max_integrity

	return INITIALIZE_HINT_NORMAL

//called if atom_init returns INITIALIZE_HINT_LATELOAD
/atom/proc/atom_init_late()
	return

/atom/Destroy()
	if(alternate_appearances)
		var/prev_key // There is a runtime when the index remains in list, but the type or other devilry disappears
		for(var/K in alternate_appearances)
			// ghost apperance qdeling in main apperance
			if(K == "[prev_key]_observer")
				continue
			prev_key = K
			var/datum/atom_hud/alternate_appearance/AA = alternate_appearances[K]
			AA.remove_from_hud(src)

	QDEL_NULL(reagents)

	LAZYCLEARLIST(overlays)

	QDEL_NULL(light)

	var/area/A = get_area(src)
	A?.Exited(src, null)

	return ..()

///This atom has been hit by hulk (TODO a hulkified mob in hulk mode (user))
/atom/proc/attack_hulk(mob/living/user)
	return

/atom/proc/CheckParts(list/parts_list)
	for(var/A in parts_list)
		if(istype(A, /datum/reagent))
			if(!reagents)
				reagents = new()
			reagents.reagent_list.Add(A)
			reagents.conditional_update()
		else if(ismovable(A))
			var/atom/movable/M = A
			if(isliving(M.loc))
				var/mob/living/L = M.loc
				L.drop_from_inventory(M, src)
			else
				M.forceMove(src)

/atom/proc/assume_air(datum/gas_mixture/giver)
	return null

/atom/proc/remove_air(amount)
	return null

/atom/proc/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/atom/proc/check_eye(user)
	if (isAI(user)) // WHYYYY
		return 1
	return

/atom/proc/on_reagent_change()
	return

/atom/proc/Bumped(AM)
	return

// Convenience proc to see if a container is open for chemistry handling
// returns true if open
// false if closed
/atom/proc/is_open_container()
	return flags & OPENCONTAINER

/*//Convenience proc to see whether a container can be accessed in a certain way.

/atom/proc/can_subract_container()
	return flags & EXTRACT_CONTAINER

/atom/proc/can_add_container()
	return flags & INSERT_CONTAINER
*/

/atom/proc/allow_drop()
	return 1

/atom/proc/CheckExit()
	return 1

/atom/proc/HasProximity(atom/movable/AM)
	return

/atom/proc/emplode(severity)
	if(SEND_SIGNAL(src, COMSIG_ATOM_EMP_ACT, severity) & COMPONENT_PREVENT_EMP)
		return FALSE
	return emp_act(severity)

/atom/proc/emp_act(severity)
	return

/atom/proc/emag_act()
	return FALSE


/atom/proc/bullet_act(obj/item/projectile/P, def_zone)
	P.on_hit(src, def_zone, 0)
	return PROJECTILE_ACTED

/atom/proc/in_contents_of(container)//can take class or object instance as argument
	if(ispath(container))
		return istype(src.loc, container)
	return src in container

/*
 *	atom/proc/search_contents_for(path,list/filter_path=null)
 * Recursevly searches all atom contens (including contents contents and so on).
 *
 * ARGS: path - search atom contents for atoms of this type
 *	   list/filter_path - if set, contents of atoms not of types in this list are excluded from search.
 *
 * RETURNS: list of found atoms
 */

/atom/proc/search_contents_for(path,list/filter_path=null)
	var/list/found = list()
	for(var/atom/A in src)
		if(istype(A, path))
			found += A
		if(filter_path)
			var/pass = 0
			for(var/type in filter_path)
				pass |= istype(A, type)
			if(!pass)
				continue
		if(A.contents.len)
			found += A.search_contents_for(path,filter_path)
	return found


/**
  * Get the name of this object for examine
  *
  * You can override what is returned from this proc by registering to listen for the
  * [COMSIG_ATOM_GET_EXAMINE_NAME] signal
  */
/atom/proc/get_examine_name(mob/user, atom/alt_obj)
	var/list/override
	if(!dirt_overlay)
		. = "\a [alt_obj ? alt_obj.name : src]."
		override = list("", gender == PLURAL ? "some" : "a", " ", "[alt_obj ? alt_obj.name : name]", ".")
	else
		. = "<span class='danger'> \a [dirt_description()]!</span>"
		override = list("<span class='danger'>", gender == PLURAL ? "some" : "a", " ", "[dirt_description(alt_obj)]", "!</span>")

	if(SEND_SIGNAL(src, COMSIG_ATOM_GET_EXAMINE_NAME, user, override) & COMPONENT_EXNAME_CHANGED)
		. = override.Join("")

///Generate the full examine string of this atom (including icon for goonchat)
/atom/proc/get_examine_string(mob/user, thats = FALSE, atom/alt_obj)
	return "[bicon(alt_obj ? alt_obj : src)] [thats ? "That's ": ""][get_examine_name(user, alt_obj)]"

/atom/proc/examine(mob/user, distance = -1)
	var/atom/alt_obj

	if(alternate_appearances)
		for(var/key in alternate_appearances)
			var/datum/atom_hud/alternate_appearance/AA = alternate_appearances[key]
			if(!AA.alternate_obj || !(user in AA.hudusers))
				continue
			alt_obj = AA.alternate_obj
			break

	var/msg = get_examine_string(user, TRUE, alt_obj)

	var/visible_desc = alt_obj?.desc || desc
	if(visible_desc)
		msg += "<br>[visible_desc]"

	// *****RM
	if(reagents && is_open_container()) //is_open_container() isn't really the right proc for this, but w/e
		msg += "<br>It contains:"
		if(reagents.reagent_list.len)
			if(istype(src, /obj/structure/reagent_dispensers)) //watertanks, fueltanks
				for(var/datum/reagent/R in reagents.reagent_list)
					msg += "<br><span class='info'>[R.volume] units of [R.name]</span>"
			else if (is_skill_competent(user, list(/datum/skill/chemistry = SKILL_LEVEL_MASTER)))
				if(length(reagents.reagent_list) == 1)
					msg += "<br><span class='info'>[reagents.reagent_list[1].volume] units of [reagents.reagent_list[1].name]</span>"
				else
					for(var/datum/reagent/R in reagents.reagent_list)
						msg += "<br><span class='info'>[R.volume + R.volume * rand(-25,25) / 100] units of [R.name]</span>"
			else
				msg += "<br><span class='info'>[reagents.total_volume] units of liquid.</span>"
		else
			msg += "<br>Nothing."

	to_chat(user, msg)

	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user)
	return distance == -1 || isobserver(user) || (get_dist(src, user) <= distance)

/atom/proc/dirt_description(atom/alt_obj)
	if(dirt_overlay)
		return "[dirt_overlay.name]-covered [alt_obj ? alt_obj.name : name]"
	else
		return "[alt_obj ? alt_obj.name : name]"

//called to set the atom's dir and used to add behaviour to dir-changes
/atom/proc/set_dir(new_dir)
	. = new_dir != dir
	dir = new_dir
	if(.)
		SEND_SIGNAL(src, COMSIG_ATOM_CHANGE_DIR, dir)

/atom/proc/relaymove()
	return

/atom/proc/ex_act()
	//SHOULD_NOT_SLEEP(TRUE) // todo
	set waitfor = FALSE
	return

/atom/proc/blob_act()
	return

/atom/proc/airlock_crush_act()
	return

// todo: exposed_temperature is only arg currently used, rest is some legacy (idk what they should do anyway)
/atom/proc/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/atom/proc/singularity_act()
	return

/atom/proc/singularity_pull()
	return

/atom/proc/hitby(atom/movable/AM, datum/thrownthing/throwingdatum)
	return

/atom/proc/add_hiddenprint(mob/living/M)
	if(!M || !M.key)
		return
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if (!istype(H.dna, /datum/dna))
			return 0
		if (H.gloves)
			if(src.fingerprintslast != H.key)
				src.fingerprintshidden += text("\[[time_stamp()]\] (Wearing gloves). Real name: [], Key: []",H.real_name, H.key)
				src.fingerprintslast = H.key
			return 0
		if (!( src.fingerprints ))
			if(src.fingerprintslast != H.key)
				src.fingerprintshidden += text("\[[time_stamp()]\] Real name: [], Key: []",H.real_name, H.key)
				src.fingerprintslast = H.key
			return 1
	else
		if(src.fingerprintslast != M.key)
			src.fingerprintshidden += text("\[[time_stamp()]\] Real name: [], Key: []",M.real_name, M.key)
			src.fingerprintslast = M.key
	return

/atom/proc/add_fingerprint(mob/M, ignoregloves = 0)
	if(!M || !M.key || isAI(M)) //AI's clicks already calls add_hiddenprint from ClickOn() proc
		return
	if (ishuman(M))
		//Add the list if it does not exist.
		if(!fingerprintshidden)
			fingerprintshidden = list()

		//Fibers~
		add_fibers(M)

		//He has no prints!
		if (FINGERPRINTS in M.mutations)
			if(fingerprintslast != M.key)
				fingerprintshidden += "(Has no fingerprints) Real name: [M.real_name], Key: [M.key]"
				fingerprintslast = M.key
			return 0		//Now, lets get to the dirty work.
		//First, make sure their DNA makes sense.
		var/mob/living/carbon/human/H = M

		if(H.species.flags[NO_FINGERPRINT]) // They don't leave readable fingerprints, but admins gotta know.
			fingerprintshidden += "(Specie has no fingerprints) Real name: [H.real_name], Key: [H.key]"
			fingerprintslast = H.key
			return 0

		if (!istype(H.dna, /datum/dna) || !H.dna.uni_identity || (length(H.dna.uni_identity) != 32))
			if(!istype(H.dna, /datum/dna))
				H.dna = new /datum/dna(null)
				H.dna.real_name = H.real_name
		H.check_dna()

		//Now, deal with gloves.
		if (H.gloves && H.gloves != src)
			if(fingerprintslast != H.key)
				fingerprintshidden += text("\[[]\](Wearing gloves). Real name: [], Key: []",time_stamp(), H.real_name, H.key)
				fingerprintslast = H.key
			H.gloves.add_fingerprint(M)

		//Deal with gloves the pass finger/palm prints.
		if(!ignoregloves)
			if(H.gloves != src)
				if(prob(75) && istype(H.gloves, /obj/item/clothing/gloves/latex))
					return 0
				else if(H.gloves && !istype(H.gloves, /obj/item/clothing/gloves/latex))
					return 0

		//More adminstuffz
		if(fingerprintslast != H.key)
			fingerprintshidden += text("\[[]\]Real name: [], Key: []",time_stamp(), H.real_name, H.key)
			fingerprintslast = H.key

		//Make the list if it does not exist.
		if(!fingerprints)
			fingerprints = list()

		//Hash this shit.
		var/full_print = md5(H.dna.uni_identity)

		// Add the fingerprints
		//
		if(fingerprints[full_print])
			switch(stringpercent_ascii(fingerprints[full_print]))		//tells us how many stars are in the current prints.

				if(28 to 32)
					if(prob(1))
						fingerprints[full_print] = full_print 		// You rolled a one buddy.
					else
						fingerprints[full_print] = stars(full_print, rand(0,40)) // 24 to 32

				if(24 to 27)
					if(prob(3))
						fingerprints[full_print] = full_print     	//Sucks to be you.
					else
						fingerprints[full_print] = stars(full_print, rand(15, 55)) // 20 to 29

				if(20 to 23)
					if(prob(5))
						fingerprints[full_print] = full_print		//Had a good run didn't ya.
					else
						fingerprints[full_print] = stars(full_print, rand(30, 70)) // 15 to 25

				if(16 to 19)
					if(prob(5))
						fingerprints[full_print] = full_print		//Welp.
					else
						fingerprints[full_print]  = stars(full_print, rand(40, 100))  // 0 to 21

				if(0 to 15)
					if(prob(5))
						fingerprints[full_print] = stars(full_print, rand(0,50)) 	// small chance you can smudge.
					else
						fingerprints[full_print] = full_print

		else
			fingerprints[full_print] = stars(full_print, rand(0, 20))	//Initial touch, not leaving much evidence the first time.


		return 1
	else
		//Smudge up dem prints some
		if(fingerprintslast != M.key)
			fingerprintshidden += text("\[[]\]Real name: [], Key: []", time_stamp(), M.real_name, M.key)
			fingerprintslast = M.key

	//Cleaning up shit.
	if(fingerprints && !fingerprints.len)
		fingerprints = null
	return


/atom/proc/transfer_fingerprints_to(atom/A)

	if(!istype(A.fingerprints,/list))
		A.fingerprints = list()

	if(!istype(A.fingerprintshidden,/list))
		A.fingerprintshidden = list()

	if(!istype(fingerprintshidden, /list))
		fingerprintshidden = list()

	//skytodo
	//A.fingerprints |= fingerprints            //detective
	//A.fingerprintshidden |= fingerprintshidden    //admin
	if(A.fingerprints && fingerprints)
		A.fingerprints |= fingerprints.Copy()            //detective
	if(A.fingerprintshidden && fingerprintshidden)
		A.fingerprintshidden |= fingerprintshidden.Copy()    //admin	A.fingerprintslast = fingerprintslast


//returns 1 if made bloody, returns 0 otherwise
/atom/proc/add_blood(mob/living/carbon/human/M)
	if(flags & NOBLOODY) return FALSE
	. = TRUE
	if (!istype(M))
		return FALSE

	if(M.species.flags[NO_BLOOD_TRAILS])
		return FALSE

	if(M.reagents.has_reagent("metatrombine"))
		return FALSE

	if (!istype(M.dna, /datum/dna))
		M.dna = new /datum/dna(null)
		M.dna.real_name = M.real_name
	M.check_dna()
	if(!blood_DNA || !istype(blood_DNA, /list))	//if our list of DNA doesn't exist yet (or isn't a list) initialise it.
		blood_DNA = list()
	add_dirt_cover(M.species.blood_datum, FALSE) // FALSE - dont call update_inv_slot in add_dirt_cover as it will be handled in human/add_blood or it will be double call and runtime

/atom/proc/add_dirt_cover(dirt_datum)
	SHOULD_CALL_PARENT(TRUE)

	if(flags & NOBLOODY)
		return FALSE
	if(!dirt_datum)
		return FALSE
	if(!dirt_overlay)
		dirt_overlay = new/datum/dirt_cover(dirt_datum)
	else
		dirt_overlay.add_dirt(dirt_datum)
	SEND_SIGNAL(src, COMSIG_ATOM_ADD_DIRT, dirt_datum)
	return TRUE

/atom/proc/clean_blood()
	SHOULD_CALL_PARENT(TRUE)

	if(uncleanable)
		return 0
	SEND_SIGNAL(src, COMSIG_ATOM_CLEAN_BLOOD)
	src.germ_level = 0
	if(dirt_overlay)
		dirt_overlay = null
	if(istype(blood_DNA, /list))
		blood_DNA = null
		return 1
	return 0

/atom/proc/get_global_map_pos()
	if(!islist(global_map) || isemptylist(global_map)) return
	var/cur_x = null
	var/cur_y = null
	var/list/y_arr = null
	for(cur_x=1,cur_x<=global_map.len,cur_x++)
		y_arr = global_map[cur_x]
		cur_y = y_arr.Find(src.z)
		if(cur_y)
			break
//	world << "X = [cur_x]; Y = [cur_y]"
	if(cur_x && cur_y)
		return list("x"=cur_x,"y"=cur_y)
	else
		return 0

/atom/proc/isinspace()
	return isspaceturf(get_turf(src))

/atom/proc/checkpass(passflag) // todo: define as macro
	return pass_flags&passflag

//This proc is called on the location of an atom when the atom is Destroy()'d
/atom/proc/handle_atom_del(atom/A)

/atom/Entered(atom/movable/AM, atom/oldLoc)
	SEND_SIGNAL(src, COMSIG_ATOM_ENTERED, AM, oldLoc)

/atom/Exited(atom/movable/AM, atom/newLoc)
	SEND_SIGNAL(src, COMSIG_ATOM_EXITED, AM, newLoc)

/atom/proc/update_transform()
	var/matrix/ntransform = matrix(transform)
	var/changed = 0

	if(resize != RESIZE_DEFAULT_SIZE)
		resize_rev *= 1/resize	//saving revert parameter for restoring size
		changed++
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = 2, easing = EASE_IN|EASE_OUT)

/atom/proc/handle_slip(mob/living/carbon/C, weaken_amount, obj/O, lube)
	return

/turf/simulated/handle_slip(mob/living/carbon/C, weaken_amount, obj/O, lube)
	if(has_gravity(src))
		var/obj/buckled_obj
		if(C.buckled)
			buckled_obj = C.buckled
			if(!(lube & GALOSHES_DONT_HELP)) //can't slip while buckled unless it's lube.
				return FALSE
		else
			if((C.lying && !C.crawling) || !(C.status_flags & CANWEAKEN)) // can't slip unbuckled mob if they're lying or can't fall.
				return FALSE
			if(C.m_intent == MOVE_INTENT_WALK && (lube & NO_SLIP_WHEN_WALKING))
				return FALSE
		if(!(lube & SLIDE_ICE))
			to_chat(C, "<span class='notice'>You slipped[ O ? " on the [O.name]" : ""]!</span>")
			playsound(src, 'sound/misc/slip.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -3)

		var/olddir = C.dir

		if(!(lube & SLIDE_ICE))
			C.Weaken(weaken_amount)
			C.stop_pulling()
		else
			C.Weaken(2)

		if(buckled_obj)
			buckled_obj.unbuckle_mob(C)
			lube |= SLIDE_ICE

		if(lube & SLIDE)
			new /datum/forced_movement(C, get_ranged_target_turf(C, olddir, 4), 1, FALSE, CALLBACK(C, TYPE_PROC_REF(/mob/living/carbon, spin), 1, 1))
			C.take_bodypart_damage(2) // Was 5 -- TLE
		else if(lube & SLIDE_ICE)
			var/has_NOSLIP = FALSE
			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				if((istype(H.shoes, /obj/item/clothing/shoes) && H.shoes.flags & NOSLIP) || (istype(H.wear_suit, /obj/item/clothing/suit/space/rig) && H.wear_suit.flags & NOSLIP))
					has_NOSLIP = TRUE
			if (C.m_intent == MOVE_INTENT_RUN && !has_NOSLIP && prob(30))
				if(C.force_moving) //If we're already slipping extend it
					qdel(C.force_moving)
				new /datum/forced_movement(C, get_ranged_target_turf(C, olddir, 1), 1, FALSE)	//spinning would be bad for ice, fucks up the next dir
			else
				C.inertia_dir = 0
		return TRUE

/turf/environment/space/handle_slip()
	return

// Recursive function to find everything this atom is holding.
/atom/proc/get_contents(obj/item/weapon/storage/Storage = null)
	var/list/L = list()

	if(Storage) //If it called itself
		L += Storage.return_inv()

		//Leave this commented out, it will cause storage items to exponentially add duplicate to the list
		//for(var/obj/item/weapon/storage/S in Storage.return_inv()) //Check for storage items
		//	L += get_contents(S)

		for(var/obj/item/weapon/gift/G in Storage.return_inv()) //Check for gift-wrapped items
			var/atom/movable/AM = locate() in G.contents
			if(AM)
				L += AM
				if(istype(AM, /obj/item/weapon/storage))
					L += get_contents(AM)

		for(var/obj/item/smallDelivery/D in Storage.return_inv()) //Check for package wrapped items
			var/atom/movable/AM = locate() in D.contents
			if(AM)
				L += AM
				if(istype(AM, /obj/item/weapon/storage)) //this should never happen
					L += get_contents(AM)
		return L

	else

		L += src.contents
		for(var/obj/item/weapon/storage/S in src.contents)	//Check for storage items
			L += get_contents(S)

		for(var/obj/item/weapon/gift/G in src.contents) //Check for gift-wrapped items
			var/atom/movable/AM = locate() in G.contents
			if(AM)
				L += AM
				if(istype(AM, /obj/item/weapon/storage))
					L += get_contents(AM)

		for(var/obj/item/smallDelivery/D in src.contents) //Check for package wrapped items
			var/atom/movable/AM = locate() in D.contents
			if(AM)
				L += AM
				if(istype(AM, /obj/item/weapon/storage)) //this should never happen
					L += get_contents(AM)
		return L

// Called after we wrench/unwrench this object
/obj/proc/wrenched_change()
	return

/atom/proc/shake_act(severity, recursive = TRUE)
	if(isturf(loc))
		INVOKE_ASYNC(src, TYPE_PROC_REF(/atom, do_shake_animation), severity, 1 SECOND)

/turf/shake_act(severity, recursive = TRUE)
	for(var/atom/A in contents)
		A.shake_act(severity - 1)
	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom, do_shake_animation), severity, 1 SECOND)

	if(severity >= 3)
		for(var/dir_ in cardinal)
			var/turf/T = get_step(src, dir_)
			T.shake_act(severity - 1, recursive = FALSE)

/mob/shake_act(severity, recursive = TRUE)
	..()
	shake_camera(src, 0.5 SECONDS, severity)

/atom/proc/get_name(mob/user)
	if(alternate_appearances)
		for(var/key in alternate_appearances)
			var/datum/atom_hud/alternate_appearance/basic/AA = alternate_appearances[key]
			if(!AA.alternate_obj || !(user in AA.hudusers))
				continue
			return AA.alternate_obj.name
	return name

/*
 * Returns:
 * An assoc list of kind image = list(viewers)
 */
/atom/proc/get_perceived_images(list/viewers)
	var/list/imgs = list()

	for(var/key in alternate_appearances)
		var/datum/atom_hud/alternate_appearance/basic/AA = alternate_appearances[key]

		var/image/I = image(AA.theImage.icon, AA.theImage.icon_state)
		I.appearance = AA.theImage
		I.dir = AA.theImage.dir

		var/list/img_viewers = list()
		for(var/v in viewers)
			if(v in AA.hudusers)
				img_viewers += v

		imgs[I] = img_viewers

		if(AA.theImage.override)
			for(var/v in img_viewers)
				viewers -= v

	var/image/I = image(icon, icon_state)
	I.appearance = src
	I.dir = dir

	imgs[I] = viewers

	return imgs

/atom/proc/update_icon()
	return

/**
 * Point at an atom
 *
 * Intended to enable and standardise the pointing animation for all atoms
 *
 * Not intended as a replacement for the mob verb
 */
/atom/proc/point_at(atom/pointed_atom, arrow_type = /obj/effect/decal/point)
	if (!isturf(loc))
		return FALSE

	var/turf/tile = get_turf(pointed_atom)
	if (!tile)
		return FALSE

	var/turf/our_tile = get_turf(src)
	var/obj/visual = new arrow_type(our_tile, invisibility)
	QDEL_IN(visual, 20)

	animate(visual, pixel_x = (tile.x - our_tile.x) * world.icon_size + pointed_atom.pixel_x, pixel_y = (tile.y - our_tile.y) * world.icon_size + pointed_atom.pixel_y, time = 1.7, easing = EASE_OUT)

	return TRUE
