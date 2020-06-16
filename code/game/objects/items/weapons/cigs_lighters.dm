//cleansed 9/15/2012 17:48

/*
CONTAINS:
MATCHES
CIGARETTES
CIGARS
SMOKING PIPES
CHEAP LIGHTERS
ZIPPO

CIGARETTE PACKETS ARE IN FANCY.DM
*/

///////////
//MATCHES//
///////////
/obj/item/weapon/match
	name = "match"
	desc = "A simple match stick, used for lighting fine smokables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	var/lit = 0
	var/burnt = 0
	var/smoketime = 5
	w_class = ITEM_SIZE_TINY
	origin_tech = "materials=1"
	attack_verb = list("burnt", "singed")

/obj/item/weapon/match/get_current_temperature()
	if(lit)
		return 1000
	else
		return 0

/obj/item/weapon/match/extinguish()
	burn_out()

/obj/item/weapon/match/process()
	var/turf/location = get_turf(src)
	smoketime--
	if(smoketime < 1)
		burn_out()
		return
	if(location)
		location.hotspot_expose(700, 5, src)
		return

/obj/item/weapon/match/dropped(mob/user)
	if(lit)
		burn_out()
	return ..()

/obj/item/weapon/match/proc/burn_out()
	lit = 0
	burnt = 1
	damtype = "brute"
	icon_state = "match_burnt"
	item_state = "cigoff"
	name = "burnt match"
	desc = "A match. This one has seen better days."
	STOP_PROCESSING(SSobj, src)

//////////////////
//FINE SMOKABLES//
//////////////////
/obj/item/clothing/mask/cigarette
	name = "cigarette"
	desc = "A roll of tobacco and nicotine."
	icon_state = "cigoff"
	throw_speed = 0.5
	item_state = "cigoff"
	w_class = ITEM_SIZE_TINY
	body_parts_covered = 0
	attack_verb = list("burnt", "singed")
	var/lit = 0
	var/icon_on = "cigon"  //Note - these are in masks.dmi not in cigarette.dmi
	var/icon_off = "cigoff"
	var/type_butt = /obj/item/weapon/cigbutt
	var/lastHolder = null
	var/smoketime = 300
	var/chem_volume = 15
	var/nicotine_per_smoketime = 0.006

/obj/item/clothing/mask/cigarette/atom_init()
	. = ..()
	flags |= NOREACT // so it doesn't react until you light it
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of 15

/obj/item/clothing/mask/cigarette/get_current_temperature()
	if(lit)
		return 1000
	else
		return 0

/obj/item/clothing/mask/cigarette/attackby(obj/item/I, mob/user, params)
	// FML. this copypasta is everywhere somebody call the fucking police please. ~Luduk
	if(iswelder(I))
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.isOn())//Badasses dont get blinded while lighting their cig with a welding tool
			light("<span class='notice'>[user] casually lights the [name] with [WT].</span>")

	else if(istype(I, /obj/item/weapon/lighter/zippo))
		var/obj/item/weapon/lighter/zippo/Z = I
		if(Z.lit)
			light("<span class='rose'>With a flick of their wrist, [user] lights their [name] with their [Z].</span>")

	else if(istype(I, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/L = I
		if(L.lit)
			light("<span class='notice'>[user] manages to light their [name] with [L].</span>")

	else if(istype(I, /obj/item/weapon/match))
		var/obj/item/weapon/match/M = I
		if(M.lit)
			light("<span class='notice'>[user] lights their [name] with their [M].</span>")

	else if(istype(I, /obj/item/weapon/melee/energy/sword))
		var/obj/item/weapon/melee/energy/sword/S = I
		if(S.active)
			light("<span class='warning'>[user] swings their [S], barely missing their nose. They light their [name] in the process.</span>")

	else if(istype(I, /obj/item/device/assembly/igniter))
		light("<span class='notice'>[user] fiddles with [I], and manages to light their [name].</span>")

	else if(istype(I, /obj/item/weapon/pen/edagger))
		var/obj/item/weapon/pen/edagger/E = I
		if(E.on)
			light("<span class='warning'>[user] swings their [E], barely missing their nose. They light their [name] in the process.</span>")

	else
		return ..()

/obj/item/clothing/mask/cigarette/afterattack(atom/target, mob/user, proximity, params)
	..()
	if(!proximity) return
	if(!istype(target, /obj/item/weapon/reagent_containers/glass))
		return
	var/obj/item/weapon/reagent_containers/glass/glass = target
	if(istype(glass))	//you can dip cigarettes into beakers
		var/transfered = glass.reagents.trans_to(src, chem_volume)
		if(transfered)	//if reagents were transfered, show the message
			to_chat(user, "<span class='notice'>You dip \the [src] into \the [glass].</span>")
		else			//if not, either the beaker was empty, or the cigarette was full
			if(!glass.reagents.total_volume)
				to_chat(user, "<span class='notice'>[glass] is empty.</span>")
			else
				to_chat(user, "<span class='notice'>[src] is full.</span>")


/obj/item/clothing/mask/cigarette/proc/light(flavor_text = "[usr] lights the [name].")
	if(!src.lit)
		src.lit = 1
		damtype = "fire"

		if(reagents.get_reagent_amount("phoron") || reagents.get_reagent_amount("fuel")) // the phoron (fuel also) explodes when exposed to fire
			var/datum/effect/effect/system/reagents_explosion/e = new()
			var/exploding_reagents = round(reagents.get_reagent_amount("phoron") / 2.5 + reagents.get_reagent_amount("fuel") / 5, 1)
			e.set_up(exploding_reagents, get_turf(src), 0, 0)
			e.start()
			if(ishuman(loc))
				var/mob/living/carbon/human/H = loc
				if(H.wear_mask == src)
					var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
					if(BP)
						BP.take_damage(10 * exploding_reagents)
			qdel(src)
			return
		flags &= ~NOREACT // allowing reagents to react after being lit
		reagents.handle_reactions()
		icon_state = icon_on
		item_state = icon_on
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)
		START_PROCESSING(SSobj, src)

		if(ismob(loc))
			var/mob/M = loc
			M.update_inv_item(src)


/obj/item/clothing/mask/cigarette/process()
	var/turf/location = get_turf(src)
	var/mob/living/M = loc
	if(isliving(loc))
		M.IgniteMob()	//Cigs can ignite mobs splashed with fuel
	smoketime--
	smoking_reagents()
	if(smoketime < 1)
		die()
		return
	if(location)
		location.hotspot_expose(700, 5, src)
	return


/obj/item/clothing/mask/cigarette/proc/smoking_reagents()
	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		if(src == C.wear_mask)
			if(C.incapacitated())
				if(prob(5))
					C.drop_from_inventory(src, get_turf(C))
					to_chat(C, "<span class='notice'>Your [name] fell out from your mouth.</span>")
			if (C.stat != DEAD)
				if(istype(loc, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = loc
					if(H.species.flags[NO_BREATHE])
						return
				if(C.reagents.has_reagent("nicotine"))
					C.reagents.add_reagent("nicotine", nicotine_per_smoketime)
				else
					C.reagents.add_reagent("nicotine", 0.2)
				if(reagents.total_volume)
					if(prob(15)) // so it's not an instarape in case of acid
						reagents.reaction(C, INGEST)
					reagents.trans_to(C, REAGENTS_METABOLISM)
				return
	if(reagents.total_volume)
		reagents.remove_any(REAGENTS_METABOLISM)

/obj/item/clothing/mask/cigarette/attack_self(mob/user)
	if(lit == 1)
		user.visible_message("<span class='notice'>[user] calmly drops and treads on the lit [src], putting it out instantly.</span>")
		die()
	return ..()


/obj/item/clothing/mask/cigarette/proc/die()
	var/turf/T = get_turf(src)
	var/obj/item/butt = new type_butt(T)
	transfer_fingerprints_to(butt)
	if(ismob(loc))
		var/mob/living/M = loc
		to_chat(M, "<span class='notice'>Your [name] goes out.</span>")
		M.remove_from_mob(src)	//un-equip it so the overlays can update
		M.update_inv_wear_mask(0)
	STOP_PROCESSING(SSobj, src)
	qdel(src)

////////////
// CIGARS //
////////////
/obj/item/clothing/mask/cigarette/cigar
	name = "premium cigar"
	desc = "A brown roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	type_butt = /obj/item/weapon/cigbutt/cigarbutt
	throw_speed = 0.5
	item_state = "cigaroff"
	smoketime = 1500
	chem_volume = 20

/obj/item/clothing/mask/cigarette/cigar/cohiba
	name = "Cohiba Robusto cigar"
	desc = "There's little more you could want from a cigar."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"

/obj/item/clothing/mask/cigarette/cigar/havana
	name = "premium Havanian cigar"
	desc = "A cigar fit for only the best of the best."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	smoketime = 7200
	chem_volume = 30

/obj/item/weapon/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cigbutt"
	w_class = ITEM_SIZE_TINY
	throwforce = 1

/obj/item/weapon/cigbutt/atom_init()
	. = ..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	transform = turn(transform,rand(0,360))

/obj/item/weapon/cigbutt/cigarbutt
	name = "cigar butt"
	desc = "A manky old cigar butt."
	icon_state = "cigarbutt"


/obj/item/clothing/mask/cigarette/cigar/attackby(obj/item/I, mob/user, params)
	if(iswelder(I))
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.isOn())
			light("<span class='notice'>[user] insults [name] by lighting it with [I].</span>")

	else if(istype(I, /obj/item/weapon/lighter/zippo))
		var/obj/item/weapon/lighter/zippo/Z = I
		if(Z.lit)
			light("<span class='rose'>With a flick of their wrist, [user] lights their [name] with their [I].</span>")

	else if(istype(I, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/L = I
		if(L.lit)
			light("<span class='notice'>[user] manages to offend their [name] by lighting it with [I].</span>")

	else if(istype(I, /obj/item/weapon/match))
		var/obj/item/weapon/match/M = I
		if(M.lit)
			light("<span class='notice'>[user] lights their [name] with their [I].</span>")

	else if(istype(I, /obj/item/weapon/melee/energy/sword))
		var/obj/item/weapon/melee/energy/sword/S = I
		if(S.active)
			light("<span class='warning'>[user] swings their [I], barely missing their nose. They light their [name] in the process.</span>")

	else if(istype(I, /obj/item/device/assembly/igniter))
		light("<span class='notice'>[user] fiddles with [I], and manages to light their [name] with the power of science.</span>")

	else if(istype(I, /obj/item/weapon/pen/edagger))
		var/obj/item/weapon/pen/edagger/E = I
		if(E.on)
			light("<span class='warning'>[user] swings their [I], barely missing their nose. They light their [name] in the process.</span>")

	else
		return ..()

/////////////////
//SMOKING PIPES//
/////////////////
/obj/item/clothing/mask/cigarette/pipe
	name = "smoking pipe"
	desc = "A pipe, for smoking. Probably made of meershaum or something."
	icon_state = "pipeoff"
	item_state = "pipeoff"
	icon_on = "pipeon"  //Note - these are in masks.dmi
	icon_off = "pipeoff"
	smoketime = 100
	nicotine_per_smoketime = 0.008

/obj/item/clothing/mask/cigarette/pipe/light(flavor_text = "[usr] lights the [name].")
	if(!src.lit)
		src.lit = 1
		damtype = "fire"
		icon_state = icon_on
		item_state = icon_on
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)
		START_PROCESSING(SSobj, src)
		if(ismob(loc))
			var/mob/M = loc
			M.update_inv_wear_mask()

/obj/item/clothing/mask/cigarette/pipe/process()
	var/turf/location = get_turf(src)
	smoketime--
	smoking_reagents()
	if(smoketime < 1)
		new /obj/effect/decal/cleanable/ash(location)
		if(ismob(loc))
			var/mob/living/M = loc
			to_chat(M, "<span class='notice'>Your [name] goes out, and you empty the ash.</span>")
			lit = 0
			icon_state = icon_off
			item_state = icon_off
			M.update_inv_wear_mask(0)
		STOP_PROCESSING(SSobj, src)
		return
	if(location)
		location.hotspot_expose(700, 5)
	return

/obj/item/clothing/mask/cigarette/pipe/attack_self(mob/user) //Refills the pipe. Can be changed to an attackby later, if loose tobacco is added to vendors or something.
	if(lit == 1)
		user.visible_message("<span class='notice'>[user] puts out [src].</span>")
		lit = 0
		icon_state = icon_off
		item_state = icon_off
		STOP_PROCESSING(SSobj, src)
		return
	if(smoketime <= 0)
		to_chat(user, "<span class='notice'>You refill the pipe with tobacco.</span>")
		smoketime = initial(smoketime)
	return

/obj/item/clothing/mask/cigarette/pipe/attackby(obj/item/I, mob/user, params)
	if(iswelder(I))
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.isOn())//
			light("<span class='notice'>[user] recklessly lights [name] with [WT].</span>")

	else if(istype(I, /obj/item/weapon/lighter/zippo))
		var/obj/item/weapon/lighter/zippo/Z = I
		if(Z.lit)
			light("<span class='rose'>With much care, [user] lights their [name] with their [Z].</span>")

	else if(istype(I, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/L = I
		if(L.lit)
			light("<span class='notice'>[user] manages to light their [name] with [L].</span>")

	else if(istype(I, /obj/item/weapon/match))
		var/obj/item/weapon/match/M = I
		if(M.lit)
			light("<span class='notice'>[user] lights their [name] with their [M].</span>")

	else if(istype(I, /obj/item/device/assembly/igniter))
		light("<span class='notice'>[user] fiddles with [I], and manages to light their [name] with the power of science.</span>")

	else
		return ..()

/obj/item/clothing/mask/cigarette/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen, kept popular in the modern age and beyond by space hipsters."
	icon_state = "cobpipeoff"
	item_state = "cobpipeoff"
	icon_on = "cobpipeon"  //Note - these are in masks.dmi
	icon_off = "cobpipeoff"
	smoketime = 400



/////////
//ZIPPO//
/////////
/obj/item/weapon/lighter
	name = "cheap lighter"
	desc = "A cheap-as-free lighter."
	icon = 'icons/obj/items.dmi'
	icon_state = "lighter-g"
	item_state = "lighter-g"
	var/icon_on = "lighter-g-on"
	var/icon_off = "lighter-g"
	w_class = ITEM_SIZE_TINY
	throwforce = 4
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	attack_verb = list("burnt", "singed")
	var/lit = 0

	action_button_name = "Toggle Lighter"

/obj/item/weapon/lighter/zippo
	name = "Zippo lighter"
	desc = "The zippo."
	icon_state = "zippo"
	item_state = "zippo"
	icon_on = "zippoon"
	icon_off = "zippo"

/obj/item/weapon/lighter/random

/obj/item/weapon/lighter/random/atom_init()
	. = ..()
	var/color = pick("r","c","y","g")
	icon_on = "lighter-[color]-on"
	icon_off = "lighter-[color]"
	icon_state = icon_off

/obj/item/weapon/lighter/get_current_temperature()
	if(lit)
		return 1500
	else
		return 0

/obj/item/weapon/lighter/attack_self(mob/living/user)
	if(user.r_hand == src || user.l_hand == src)
		user.SetNextMove(CLICK_CD_MELEE)
		if(!lit)
			lit = 1
			icon_state = icon_on
			item_state = icon_on
			if(istype(src, /obj/item/weapon/lighter/zippo) )
				playsound(src, 'sound/items/zippo.ogg', VOL_EFFECTS_MASTER, 25)
				user.visible_message("<span class='notice'>Without even breaking stride, [user] flips open and lights [src] in one smooth movement.</span>")
			else
				playsound(src, 'sound/items/lighter.ogg', VOL_EFFECTS_MASTER, 25)
				if(prob(95))
					user.visible_message("<span class='notice'>After a few attempts, [user] manages to light the [src].</span>")
				else
					to_chat(user, "<span class='warning'>You burn yourself while lighting the lighter.</span>")
					if (user.l_hand == src)
						user.apply_damage(2, BURN, BP_L_ARM)
					else
						user.apply_damage(2, BURN, BP_R_ARM)
					user.visible_message("<span class='warning'>After a few attempts, [user] manages to light the [src], they however burn their finger in the process.</span>")

			set_light(2)
			START_PROCESSING(SSobj, src)
		else
			lit = 0
			icon_state = icon_off
			item_state = icon_off
			if(istype(src, /obj/item/weapon/lighter/zippo) )
				playsound(src, 'sound/items/zippo.ogg', VOL_EFFECTS_MASTER, 25)
				user.visible_message("<span class='notice'>You hear a quiet click, as [user] shuts off [src] without even looking at what they're doing.</span>")
			else
				user.visible_message("<span class='notice'>[user] quietly shuts off the [src].</span>")
				playsound(src, 'sound/items/lighter.ogg', VOL_EFFECTS_MASTER, 25)

			set_light(0)
			STOP_PROCESSING(SSobj, src)
	else
		return ..()
	return


/obj/item/weapon/lighter/attack(mob/living/carbon/M, mob/living/carbon/user, def_zone)
	if(!istype(M, /mob))
		return
	M.IgniteMob()	//Lighters can ignite mobs splashed with fuel
	if(istype(M.wear_mask, /obj/item/clothing/mask/cigarette) && def_zone == O_MOUTH && lit)
		var/obj/item/clothing/mask/cigarette/cig = M.wear_mask
		if(M == user)
			cig.attackby(src, user)
		else
			if(istype(src, /obj/item/weapon/lighter/zippo))
				cig.light("<span class='rose'>[user] whips the [name] out and holds it for [M].</span>")
			else
				cig.light("<span class='notice'>[user] holds the [name] out for [M], and lights the [cig.name].</span>")
	else
		..()

/obj/item/weapon/lighter/process()
	var/turf/location = get_turf(src)
	if(location)
		location.hotspot_expose(700, 5, src)
	return
