#define DRYING_TIME 5 MINUTES                        //for 1 unit of depth in puddle (amount var)

var/global/list/image/splatter_cache=list()

/obj/effect/decal/cleanable/blood
	name = "blood"
	desc = "It's thick and gooey. Perhaps it's the chef's cooking?"
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "mfloor1"
	random_icon_states = list("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7")
	var/base_icon = 'icons/effects/blood.dmi'
	var/list/viruses = list()
	blood_DNA = list()
	var/datum/dirt_cover/basedatum = /datum/dirt_cover/red_blood // Color when wet.
	var/list/datum/disease2/disease/virus2 = list()
	var/amount = 5
	var/drytime

/obj/effect/decal/cleanable/blood/Destroy()
	for(var/datum/disease/D in viruses)
		D.cure(0)
	return ..()

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
		addtimer(CALLBACK(src, .proc/dry), drytime)

/obj/effect/decal/cleanable/blood/update_icon()
	color = basedatum.color

/obj/effect/decal/cleanable/blood/Crossed(atom/movable/AM)
	. = ..()
	if(!iscarbon(AM) || HAS_TRAIT(AM, TRAIT_LIGHT_STEP))
		return
	var/mob/living/carbon/perp = AM
	if(amount < 1)
		return
	if(!islist(blood_DNA))	//prevent from runtime errors connected with shitspawn
		blood_DNA = list()

	var/hasfeet = TRUE
	var/skip = FALSE
	if (ishuman(perp))
		var/mob/living/carbon/human/H = perp
		var/obj/item/organ/external/l_foot = H.bodyparts_by_name[BP_L_LEG]
		var/obj/item/organ/external/r_foot = H.bodyparts_by_name[BP_R_LEG]
		if((!l_foot || l_foot.is_stump) && (!r_foot || r_foot.is_stump))
			hasfeet = FALSE
		if(perp.shoes && !perp.buckled)//Adding blood to shoes
			var/obj/item/clothing/shoes/S = perp.shoes
			if(istype(S))
				if((dirt_overlay && dirt_overlay.color != basedatum.color) || (!dirt_overlay))
					S.cut_overlays()
					S.add_dirt_cover(basedatum)
				S.track_blood = max(amount,S.track_blood)
				if(!S.blood_DNA)
					S.blood_DNA = list()
				if(blood_DNA.len)
					S.blood_DNA |= blood_DNA.Copy()
			skip = TRUE

	if (hasfeet && !skip) // Or feet
		if(perp.feet_dirt_color)
			perp.feet_dirt_color.add_dirt(basedatum)
		else
			perp.feet_dirt_color = new/datum/dirt_cover(basedatum)
		perp.track_blood = max(amount,perp.track_blood)
		if(!perp.feet_blood_DNA)
			perp.feet_blood_DNA = list()
		perp.feet_blood_DNA |= blood_DNA.Copy()
	else if (perp.buckled && istype(perp.buckled, /obj/structure/stool/bed/chair/wheelchair))
		var/obj/structure/stool/bed/chair/wheelchair/W = perp.buckled
		W.bloodiness = 4

	perp.update_inv_shoes()
	if(perp.lying)
		perp.crawl_in_blood(src)
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
		user.update_inv_gloves()
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
	density = 0
	anchored = 1
	layer = 2
	random_icon_states = null
	amount = 3
	var/list/existing_dirs = list()
	blood_DNA = list()

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "gibbl5"
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
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibup1","gibup1","gibup1")

/obj/effect/decal/cleanable/blood/gibs/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibdown1","gibdown1","gibdown1")

/obj/effect/decal/cleanable/blood/gibs/body
	random_icon_states = list("gibhead", "gibtorso")

/obj/effect/decal/cleanable/blood/gibs/limb
	random_icon_states = list("gibleg", "gibarm")

/obj/effect/decal/cleanable/blood/gibs/core
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")


/obj/effect/decal/cleanable/blood/gibs/proc/streak(list/directions)
	spawn(0)
		var/direction = pick(directions)
		for (var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
			sleep(3)
			if (i > 0)
				var/obj/effect/decal/cleanable/blood/b = new /obj/effect/decal/cleanable/blood/splatter(src.loc)
				b.basedatum = new/datum/dirt_cover(src.basedatum)
				b.update_icon()
				for(var/datum/disease/D in src.viruses)
					var/datum/disease/ND = D.Copy(1)
					b.viruses += ND
					ND.holder = b

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
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "mucus"
	random_icon_states = list("mucus")

	var/list/datum/disease2/disease/virus2 = list()
	var/dry = 0 // Keeps the lag down

/obj/effect/decal/cleanable/mucus/atom_init()
	. = ..()
	addtimer(CALLBACK(src, .proc/set_dry, 1), DRYING_TIME * 2)

/obj/effect/decal/cleanable/mucus/proc/set_dry(value) // just to change var using timer, we need a whole new proc :(
	dry = value
