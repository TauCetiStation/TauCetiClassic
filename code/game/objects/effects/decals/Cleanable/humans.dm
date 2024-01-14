#define DRYING_TIME 5 MINUTES                        //for 1 unit of depth in puddle (amount var)

var/global/list/image/splatter_cache=list()

/obj/effect/decal/cleanable/blood
	name = "blood"
	desc = "It's thick and gooey. Perhaps it's the chef's cooking?"
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "mfloor1"
	random_icon_states = list("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7")
	var/base_icon = 'icons/effects/blood.dmi'
	blood_DNA = list()
	var/datum/dirt_cover/basedatum = /datum/dirt_cover/red_blood // Color when wet.
	var/list/datum/disease2/disease/virus2 = list()
	var/amount = 5
	var/drytime

	beauty = -100

/obj/effect/decal/cleanable/blood/atom_init()
	..()

	basedatum = new basedatum
	return INITIALIZE_HINT_LATELOAD

/obj/effect/decal/cleanable/blood/atom_init_late()
	remove_ex_blood()
	update_icon()

/obj/effect/decal/cleanable/blood/proc/remove_ex_blood() //removes existant blood on the turf
	if(istype(src, /obj/effect/decal/cleanable/blood/tracks))
		return // We handle our own drying.

	if(loc) // someone should make blood that drips thru closet or smth like that.
		for(var/obj/effect/decal/cleanable/blood/B in loc)
			if(B != src && B.type == type)
				if (B.blood_DNA)
					blood_DNA |= B.blood_DNA.Copy()
				qdel(B)

		drytime = world.time + DRYING_TIME * (amount + 1)
		addtimer(CALLBACK(src, PROC_REF(dry)), drytime)

/obj/effect/decal/cleanable/blood/update_icon()
	color = basedatum.color

/mob/living/carbon/proc/add_feet_dirt(datum/dirt_cover/dirt_cover, track_amount, blood = TRUE, list/dirt_DNA = list())
	var/hasfeet = TRUE
	var/skip = FALSE

	if (buckled)
		if (blood && istype(buckled, /obj/structure/stool/bed/chair/wheelchair)) // useless a bit because of unbuckling in relaymove
			var/obj/structure/stool/bed/chair/wheelchair/W = buckled
			W.bloodiness = 4
	else
		if (ishuman(src))
			var/mob/living/carbon/human/H = src
			var/obj/item/organ/external/l_foot = H.bodyparts_by_name[BP_L_LEG]
			var/obj/item/organ/external/r_foot = H.bodyparts_by_name[BP_R_LEG]

			if((!l_foot || l_foot.is_stump) && (!r_foot || r_foot.is_stump))
				hasfeet = FALSE
			else if(H.shoes) //Adding dirt to shoes
				var/obj/item/clothing/shoes/S = H.shoes
				if(istype(S))
					if(!S.dirt_overlay || (S.dirt_overlay.color != dirt_cover.color))
						S.cut_overlays()
						S.add_dirt_cover(dirt_cover)
					S.track_blood = max(track_amount, S.track_blood)
					if(S.blood_DNA)
						S.blood_DNA |= dirt_DNA
					else
						S.blood_DNA = dirt_DNA.Copy()
				skip = TRUE

		if (hasfeet && !skip) // Or feet
			if(feet_dirt_color)
				feet_dirt_color.add_dirt(dirt_cover)
			else
				feet_dirt_color = new/datum/dirt_cover(dirt_cover)
			track_blood = max(track_amount, track_blood)
			if(feet_blood_DNA)
				feet_blood_DNA |= dirt_DNA
			else
				feet_blood_DNA = dirt_DNA.Copy()

		update_inv_slot(SLOT_SHOES)
		if(blood && lying)
			crawl_in_blood(dirt_cover)

/obj/effect/decal/cleanable/blood/Crossed(atom/movable/AM)
	. = ..()
	if(!iscarbon(AM) || HAS_TRAIT(AM, TRAIT_LIGHT_STEP))
		return
	var/mob/living/carbon/perp = AM
	if(amount < 1)
		return
	if(!islist(blood_DNA))	//prevent from runtime errors connected with shitspawn
		blood_DNA = list()

	perp.add_feet_dirt(basedatum, amount, dirt_DNA=blood_DNA)
	amount--

/obj/effect/decal/cleanable/blood/proc/dry()
	name = "dried [src.name]"
	desc = "It's dry and crusty. Someone is not doing their job."
	color = adjust_brightness(color, -50)
	amount = 0

/obj/effect/decal/cleanable/blood/attack_hand(mob/living/carbon/human/user)
	..()
	if (amount && istype(user))
		user.SetNextMove(CLICK_CD_MELEE)
		add_fingerprint(user)
		if (user.gloves)
			return
		var/taken = rand(1,amount)
		amount -= taken
		to_chat(user, "<span class='notice'>You get some of \the [src] on your hands.</span>")
		if (!user.blood_DNA)
			user.blood_DNA = list()
		user.blood_DNA |= blood_DNA.Copy()
		user.bloody_hands += taken
		user.hand_dirt_datum = new(basedatum)
		user.update_inv_slot(SLOT_GLOVES)
		user.verbs += /mob/living/carbon/human/proc/bloody_doodle

/obj/effect/decal/cleanable/blood/splatter
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	amount = 2

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "It's red."
	gender = PLURAL
	icon = 'icons/effects/drip.dmi'
	icon_state = "1"
	random_icon_states = list("1","2","3","4","5")
	amount = 0
	var/list/drips = list()

/obj/effect/decal/cleanable/blood/drip/atom_init()
	. = ..()
	drips |= icon_state

/obj/effect/decal/cleanable/blood/splatter/over_window // special layer/plane set to appear on windows
	layer = ABOVE_WINDOW_LAYER
	plane = GAME_PLANE
	vis_flags = VIS_INHERIT_PLANE
	alpha = 180

/obj/effect/decal/cleanable/blood/writing
	icon_state = "tracks"
	desc = "It looks like a writing in blood."
	gender = NEUTER
	random_icon_states = list("writing1","writing2","writing3","writing4","writing5")
	amount = 0
	var/message

/obj/effect/decal/cleanable/blood/writing/atom_init()
	. = ..()
	if(random_icon_states.len)
		for(var/obj/effect/decal/cleanable/blood/writing/W in loc)
			random_icon_states.Remove(W.icon_state)
		icon_state = pick(random_icon_states)
	else
		icon_state = "writing1"

/obj/effect/decal/cleanable/blood/writing/examine(mob/user)
	..()
	to_chat(user, "It reads: <font color='[basedatum.color]'>\"[message]\"</font>")

/obj/effect/decal/cleanable/blood/trail_holder
	name = "blood"
	icon_state = "blank"
	desc = "Your instincts say you shouldn't be following these."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = 2
	random_icon_states = null
	amount = 3
	var/list/existing_dirs = list()
	blood_DNA = list()

	beauty = -50

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "gibbearcore"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")
	var/fleshcolor = "#ffffff"

/obj/effect/decal/cleanable/blood/gibs/remove_ex_blood()
	return

/obj/effect/decal/cleanable/blood/gibs/update_icon()
	var/image/giblets = new(base_icon, "[icon_state]_flesh", dir)
	giblets.color = fleshcolor
	var/icon/blood = new(base_icon,"[icon_state]",dir)
	blood.Blend(basedatum.color, ICON_MULTIPLY)

	icon = blood
	cut_overlays()
	add_overlay(giblets)

/obj/effect/decal/cleanable/blood/gibs/up
	icon_state = "gibup1" // for mapeditor
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibup1","gibup1","gibup1")

/obj/effect/decal/cleanable/blood/gibs/down
	icon_state = "gibdown1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibdown1","gibdown1","gibdown1")

/obj/effect/decal/cleanable/blood/gibs/body
	icon_state = "gibhead"
	random_icon_states = list("gibhead", "gibtorso")

/obj/effect/decal/cleanable/blood/gibs/limb
	icon_state = "gibleg"
	random_icon_states = list("gibleg", "gibarm")

/obj/effect/decal/cleanable/blood/gibs/core
	icon_state = "gibmid1"
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3", "gibbearcore")


/obj/effect/decal/cleanable/blood/gibs/proc/streak(list/directions)
	spawn(0)
		var/direction = pick(directions)
		for (var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
			sleep(3)
			if (i > 0)
				var/obj/effect/decal/cleanable/blood/b = new /obj/effect/decal/cleanable/blood/splatter(src.loc)
				b.basedatum = new/datum/dirt_cover(src.basedatum)
				b.update_icon()

				if (step_to(src, get_step(src, direction), 0))
					break

/obj/effect/decal/cleanable/blood/gibs/Crossed(atom/movable/AM)
	if(isliving(AM) && has_gravity(loc))
		playsound(src, 'sound/effects/gib_step.ogg', VOL_EFFECTS_MASTER)
	. = ..()


/obj/effect/decal/cleanable/mucus
	name = "mucus"
	desc = "Disgusting mucus."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "mucus"
	random_icon_states = list("mucus")

	var/list/datum/disease2/disease/virus2 = list()
	var/dry = 0 // Keeps the lag down

	beauty = -50

/obj/effect/decal/cleanable/mucus/atom_init()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(set_dry), 1), DRYING_TIME * 2)

/obj/effect/decal/cleanable/mucus/proc/set_dry(value) // just to change var using timer, we need a whole new proc :(
	dry = value

/obj/effect/decal/cleanable/blood/hitsplatter
	name = "blood splatter"
	pass_flags = PASSTABLE | PASSGRILLE
	icon_state = "hitsplatter1"
	random_icon_states = list("hitsplatter1", "hitsplatter2", "hitsplatter3")

	/// The turf we just came from, so we can back up when we hit a wall
	var/turf/prev_loc
	/// The saved ref to the owner of blood
	var/mob/living/carbon/blood_owner
	/// Skip making the final blood splatter when we're done, like if we're not in a turf
	var/skip = FALSE
	/// How many tiles/items/people we can paint red
	var/splatter_strength = 3
	/// Insurance so that we don't keep moving once we hit a stoppoint
	var/hit_endpoint = FALSE

/obj/effect/decal/cleanable/blood/hitsplatter/atom_init(mapload, splatter_strength)
	. = ..()
	prev_loc = loc //Just so we are sure prev_loc exists
	if(splatter_strength)
		src.splatter_strength = splatter_strength

/obj/effect/decal/cleanable/blood/hitsplatter/Destroy()
	if(isturf(loc) && !skip)
		playsound(src, 'sound/effects/splatter.ogg', 60, TRUE, -1)
		if(blood_owner)
			var/turf/T = loc
			T.add_blood_floor(blood_owner)
	return ..()

/// Set the splatter up to fly through the air until it rounds out of steam or hits something
/obj/effect/decal/cleanable/blood/hitsplatter/proc/fly_towards(turf/target_turf, range)
	var/delay = 0.8
	var/datum/forced_movement/move = new /datum/forced_movement(src, target_turf, delay, CALLBACK(src, PROC_REF(post_move)))
	RegisterSignal(move, COMSIG_PARENT_QDELETING, PROC_REF(loop_done))

/obj/effect/decal/cleanable/blood/hitsplatter/proc/post_move()
	SIGNAL_HANDLER
	prev_loc = loc
	for(var/atom/iter_atom in get_turf(src))
		if(hit_endpoint)
			return
		if(splatter_strength <= 0)
			break

		if(isitem(iter_atom))
			iter_atom.add_blood(blood_owner)
			splatter_strength--
		else if(ishuman(iter_atom))
			var/mob/living/carbon/human/splashed_human = iter_atom
			splashed_human.bloody_body(blood_owner)
			splashed_human.bloody_hands(blood_owner)
			splatter_strength--
	if(splatter_strength <= 0) // we used all the puff so we delete it.
		qdel(src)

/obj/effect/decal/cleanable/blood/hitsplatter/proc/loop_done(datum/source)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		qdel(src)

/obj/effect/decal/cleanable/blood/hitsplatter/Bump(atom/bumped_atom)
	if(!iswallturf(bumped_atom) && !istype(bumped_atom, /obj/structure/window))
		qdel(src)
		return

	if(istype(bumped_atom, /obj/structure/window))
		if(!istype(bumped_atom, /obj/structure/window/fulltile))
			hit_endpoint = TRUE
			qdel(src)
			return

	hit_endpoint = TRUE
	if(isturf(prev_loc))
		abstract_move(bumped_atom)
		skip = TRUE
		//Adjust pixel offset to make splatters appear on the wall
		if(istype(bumped_atom, /obj/structure/window))
			land_on_window(bumped_atom)
		else
			var/obj/effect/decal/cleanable/blood/splatter/over_window/final_splatter = new(prev_loc)
			final_splatter.pixel_x = (dir == EAST ? 32 : (dir == WEST ? -32 : 0))
			final_splatter.pixel_y = (dir == NORTH ? 32 : (dir == SOUTH ? -32 : 0))
	else // This will only happen if prev_loc is not even a turf, which is highly unlikely.
		abstract_move(bumped_atom)
		qdel(src)

/// A special case for hitsplatters hitting windows, since those can actually be moved around, store it in the window and slap it in the vis_contents
/obj/effect/decal/cleanable/blood/hitsplatter/proc/land_on_window(obj/structure/window/the_window)
	if(!istype(the_window, /obj/structure/window/fulltile))
		return
	var/obj/effect/decal/cleanable/blood/splatter/over_window/final_splatter = new
	final_splatter.forceMove(the_window)
	the_window.vis_contents += final_splatter
	qdel(src)
