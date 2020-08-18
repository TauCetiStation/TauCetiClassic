/obj/item/weapon/arrow

	name = "bolt"
	desc = "It's got a tip for you - get the point?"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bolt"
	item_state = "bolt"
	throwforce = 8
	w_class = ITEM_SIZE_NORMAL
	sharp = 1
	edge = 0

/obj/item/weapon/arrow/proc/removed() //Helper for metal rods falling apart.
	return

/obj/item/weapon/arrow/quill

	name = "vox quill"
	desc = "A wickedly barbed quill from some bizarre animal."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "quill"
	item_state = "quill"
	throwforce = 5

/obj/item/weapon/arrow/rod

	name = "metal rod"
	desc = "Don't cry for me, Orithena."
	icon_state = "metal-rod"

/obj/item/weapon/arrow/rod/removed(mob/user)
	if(throwforce == 15) // The rod has been superheated - we don't want it to be useable when removed from the bow.
		to_chat(user, "[src] shatters into a scattering of overstressed metal shards as it leaves the crossbow.")
		var/obj/item/weapon/shard/shrapnel/S = new()
		S.loc = get_turf(src)
		qdel(src)

/obj/item/weapon/crossbow

	name = "powered crossbow"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "crossbow"
	item_state = "crossbow-solid"
	w_class = ITEM_SIZE_HUGE
	flags =  CONDUCT
	slot_flags = SLOT_FLAGS_BELT | SLOT_FLAGS_BACK

	w_class = ITEM_SIZE_NORMAL

	var/tension = 0                       // Current draw on the bow.
	var/max_tension = 3                   // Highest possible tension.
	var/release_speed = 4                 // Speed per unit of tension.
	var/mob/living/current_user = null    // Used to see if the person drawing the bow started drawing it.
	var/obj/item/weapon/arrow = null      // Nocked arrow.
	var/obj/item/weapon/stock_parts/cell/cell = null  // Used for firing special projectiles like rods.

/obj/item/weapon/crossbow/atom_init()
	. = ..()
	desc = "A [gamestory_start_year+2]AD twist on an old classic. Pick up that can."

/obj/item/weapon/crossbow/attackby(obj/item/I, mob/user, params)
	if(!arrow)
		if(istype(I, /obj/item/weapon/arrow))
			user.drop_from_inventory(I, src)
			arrow = I
			user.visible_message("[user] slides [arrow] into [src].","You slide [arrow] into [src].")
			icon_state = "crossbow-nocked"
			return

		else if(istype(I, /obj/item/stack/rods))
			var/obj/item/stack/rods/R = I
			if(!R.use(1))
				return
			arrow = new /obj/item/weapon/arrow/rod(src)
			arrow.fingerprintslast = src.fingerprintslast
			arrow.forceMove(src)
			icon_state = "crossbow-nocked"
			user.visible_message("[user] haphazardly jams [arrow] into [src].","You jam [arrow] into [src].")
			if(cell)
				if(cell.charge >= 500)
					to_chat(user, "<span class='notice'>[arrow] plinks and crackles as it begins to glow red-hot.</span>")
					arrow.throwforce = 15
					arrow.icon_state = "metal-rod-superheated"
					cell.use(500)
			return

	if(istype(I, /obj/item/weapon/stock_parts/cell))
		if(!cell)
			user.drop_from_inventory(I, src)
			cell = I
			to_chat(user, "<span class='notice'>You jam [cell] into [src] and wire it to the firing coil.</span>")
			if(arrow)
				if(istype(arrow,/obj/item/weapon/arrow/rod) && arrow.throwforce < 15 && cell.charge >= 500)
					to_chat(user, "<span class='notice'>[arrow] plinks and crackles as it begins to glow red-hot.</span>")
					arrow.throwforce = 15
					arrow.icon_state = "metal-rod-superheated"
					cell.use(500)
		else
			to_chat(user, "<span class='notice'>[src] already has a cell installed.</span>")

	else if(isscrewdriver(I))
		if(cell)
			var/obj/item/C = cell
			C.forceMove(get_turf(user))
			cell = null
			to_chat(user, "<span class='notice'>You jimmy [cell] out of [src] with [I].</span>")
		else
			to_chat(user, "<span class='notice'>[src] doesn't have a cell installed.</span>")

	else
		return ..()

/obj/item/weapon/crossbow/attack_self(mob/living/user)
	if(tension)
		if(arrow)
			user.visible_message("[user] relaxes the tension on [src]'s string and removes [arrow].","You relax the tension on [src]'s string and remove [arrow].")
			var/obj/item/weapon/arrow/A = arrow
			A.loc = get_turf(src)
			A.removed(user)
			arrow = null
		else
			user.visible_message("[user] relaxes the tension on [src]'s string.","You relax the tension on [src]'s string.")
		tension = 0
		icon_state = "crossbow"
	else
		draw(user)

/obj/item/weapon/crossbow/proc/draw(mob/user)

	if(!arrow)
		to_chat(user, "You don't have anything nocked to [src].")
		return

	if(user.restrained())
		return

	current_user = user

	user.visible_message("[user] begins to draw back the string of [src].","You begin to draw back the string of [src].")
	tension = 1
	spawn(25) increase_tension(user)

/obj/item/weapon/crossbow/proc/increase_tension(mob/user)

	if(!arrow || !tension || current_user != user) //Arrow has been fired, bow has been relaxed or user has changed.
		return

	tension++
	icon_state = "crossbow-drawn"

	if(tension>=max_tension)
		tension = max_tension
		to_chat(usr, "[src] clunks as you draw the string to its maximum tension!")
	else
		user.visible_message("[usr] draws back the string of [src]!","You continue drawing back the string of [src]!")
		spawn(25) increase_tension(user)

/obj/item/weapon/crossbow/afterattack(atom/target, mob/user, proximity, params)
	if (target.loc == user.loc)
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	else if(target == user)
		return

	if(!tension)
		to_chat(user, "You haven't drawn back the bolt!")
		return 0

	if (!arrow)
		to_chat(user, "You have no arrow nocked to [src]!")
		return 0
	else
		spawn(0) Fire(target,user,params)

/obj/item/weapon/crossbow/proc/Fire(atom/target, mob/living/user, params, reflex = 0)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/V = H.wear_suit
			V.attack_reaction(H, REACTION_GUN_FIRE)

	add_fingerprint(user)

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	user.visible_message("<span class='danger'>[user] releases [src] and sends [arrow] streaking toward [target]!</span>","<span class='danger'>You release [src] and send [arrow] streaking toward [target]!</span>")

	var/obj/item/weapon/arrow/A = arrow
	A.loc = get_turf(user)
	A.throw_at(target, (tension * release_speed) + 1, tension * release_speed, user)
	arrow = null
	tension = 0
	icon_state = "crossbow"

/obj/item/weapon/crossbow/dropped(mob/user)
	if(arrow)
		var/obj/item/weapon/arrow/A = arrow
		A.loc = get_turf(src)
		A.removed(user)
		arrow = null
		tension = 0
		icon_state = "crossbow"

// *(CROSSBOW craft in recipes.dm)*

/obj/item/weapon/crossbowframe1
	name = "crossbow(1 stage)"
	desc = "To finish you need: add 3 rods; weld it all; add 5 cable coil; add 3 plastic; add 5 cable coil; tighten the bolts by screwdriver."
	icon_state = "crossbowframe1"
	item_state = "crossbow-solid"

/obj/item/weapon/crossbowframe2
	name = "crossbow(2 stage)"
	desc = "To finish you need: weld it all; add 5 cable coil; add 3 plastic; add 5 cable coil; tighten the bolts by screwdriver."
	icon_state = "crossbowframe2"
	item_state = "crossbow-solid"

/obj/item/weapon/crossbowframe3
	name = "crossbow(3 stage)"
	desc = "To finish you need: add 5 cable coil; add 3 plastic; add 5 cable coil; tighten the bolts by screwdriver."
	icon_state = "crossbowframe3"
	item_state = "crossbow-solid"

/obj/item/weapon/crossbowframe4
	name = "crossbow(4 stage)"
	desc = "To finish you need: add 3 plastic; add 5 cable coil; tighten the bolts by screwdriver."
	icon_state = "crossbowframe4"
	item_state = "crossbow-solid"

/obj/item/weapon/crossbowframe5
	name = "crossbow(5 stage)"
	desc = "To finish you need: add 5 cable coil; tighten the bolts by screwdriver."
	icon_state = "crossbowframe5"
	item_state = "crossbow-solid"

/obj/item/weapon/crossbowframe6
	name = "crossbow(6 stage)"
	desc = "To finish you need: tighten the bolts by screwdriver."
	icon_state = "crossbowframe6"
	item_state = "crossbow-solid"

/obj/item/weapon/crossbow/vox
	max_tension = 5
	release_speed = 5