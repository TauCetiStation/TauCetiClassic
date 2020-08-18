/* Kitchen tools
 * Contains:
 *		Utensils
 *		Spoons
 *		Forks
 *		Knives
 *		Kitchen knives
 *		Butcher's cleaver
 *		Rolling Pins
 *		Trays
 */

/obj/item/weapon/kitchen
	icon = 'icons/obj/kitchen.dmi'

/*
 * Utensils
 */
/obj/item/weapon/kitchen/utensil
	force = 0
	w_class = ITEM_SIZE_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	flags = CONDUCT
	origin_tech = "materials=1"
	attack_verb = list("attacked", "stabbed", "poked")
	var/max_contents = 1

/obj/item/weapon/kitchen/utensil/atom_init()
	. = ..()
	if (prob(60))
		pixel_y = rand(0, 4)

/obj/item/weapon/kitchen/utensil/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M))
		return ..()

	if(user.a_intent != INTENT_HELP)
		if(user.zone_sel.selecting == "head" || user.zone_sel.selecting == "eyes")
			if((CLUMSY in user.mutations) && prob(50))
				M = user
			return eyestab(M,user)
		else
			return ..()

	if(contents.len)
		var/obj/item/weapon/reagent_containers/food/snacks/toEat = contents[1]
		if(istype(toEat))
			if(CanEat(user, M, toEat, "eat"))
				toEat.On_Consume(M, user)
				if(toEat)
					qdel(toEat)
				cut_overlays()
				return

/*
 * Spoons
 */
/obj/item/weapon/kitchen/utensil/spoon
	name = "spoon"
	desc = "SPOON!"
	icon_state = "spoon"
	attack_verb = list("attacked", "poked")

/obj/item/weapon/kitchen/utensil/pspoon
	name = "plastic spoon"
	desc = "Super dull action!"
	icon_state = "pspoon"
	attack_verb = list("attacked", "poked")

/*
 * Forks
 */
/obj/item/weapon/kitchen/utensil/fork
	name = "fork"
	desc = "Pointy."
	force = 3
	hitsound = list('sound/items/tools/screwdriver-stab.ogg')
	icon_state = "fork"

/obj/item/weapon/kitchen/utensil/fork/afterattack(atom/target, mob/user, proximity, params)
	if(istype(target,/obj/item/weapon/reagent_containers/food/snacks))	return // fork is not only for cleanning
	if(!proximity) return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(istype(target,/obj/effect/decal/cleanable) && !user.is_busy(target))
		user.visible_message("<span class='warning'>[user] begins to clean \the [target.name].</span>","<span class='notice'>You begin to clean \the [target.name].</span>")
		if(do_after(user, 60, target = target))
			user.visible_message("<span class='warning'>[user] scrub \the [target.name] out.</span>","<span class='notice'>You scrub \the [target.name] out.</span>")
			qdel(target)

/obj/item/weapon/kitchen/utensil/fork/sticks
	name = "wooden chopsticks"
	desc = "How do people even hold this?"
	force = 2
	icon_state = "sticks"

/obj/item/weapon/kitchen/utensil/pfork
	name = "plastic fork"
	desc = "Yay, no washing up to do."
	icon_state = "pfork"
	force = 0


/obj/item/weapon/kitchen/utensil/pfork/afterattack(atom/target, mob/user, proximity, params)  //make them useful or some slow soap for plastic. Just copy-paste from usual fork
	if(istype(target,/obj/item/weapon/reagent_containers/food/snacks))	return // fork is not only for cleanning
	if(!proximity) return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(istype(target,/obj/effect/decal/cleanable) && !user.is_busy(target))
		user.visible_message("<span class='warning'>[user] begins to clean \the [target.name].</span>","<span class='notice'>You begin to clean \the [target.name].</span>")
		if(do_after(user, 60, target = target))
			user.visible_message("<span class='warning'>[user] scrub \the [target.name] out.</span>","<span class='notice'>You scrub \the [target.name] out.</span>")
			qdel(target)

/*
 * Kitchen knives
 */
/obj/item/weapon/kitchenknife
	name = "kitchen knife"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	flags = CONDUCT
	sharp = 1
	edge = 1
	force = 10.0
	w_class = ITEM_SIZE_SMALL
	throwforce = 6.0
	throw_speed = 3
	throw_range = 6
	m_amt = 12000
	origin_tech = "materials=1"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	tools = list(
		TOOL_KNIFE = 1
		)
	sweep_step = 2

/obj/item/weapon/kitchenknife/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list(/turf, /obj/effect/effect/weapon_sweep)
	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE
	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/kitchenknife/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='warning'><b>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</b></span>", \
						"<span class='warning'><b>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</b></span>", \
						"<span class='warning'><b>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</b></span>"))
	return (BRUTELOSS)

/obj/item/weapon/kitchenknife/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(user.a_intent == INTENT_HELP && M.attempt_harvest(src, user))
		return
	return ..()

/obj/item/weapon/kitchenknife/plastic
	name = "plastic knife"
	desc = "The bluntest of blades."
	icon_state = "pknife"
	force = 0
	throwforce = 0

/obj/item/weapon/kitchenknife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"

/obj/item/weapon/kitchenknife/combat
	name = "combat knife"
	desc = "It's a combat knife, used galaxywide by military, mercenaries and wannabe survivialists."
	force = 13
	throwforce = 10
	icon = 'icons/obj/weapons.dmi'
	icon_state = "combat_knife"
	origin_tech = "materials=1;combat=1"
/*
 * Bucher's cleaver
 */
/obj/item/weapon/kitchenknife/butch
	name = "butcher's cleaver"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products."
	force = 15.0
	w_class = ITEM_SIZE_NORMAL
	throwforce = 8.0
	throw_speed = 3
	throw_range = 6
	m_amt = 12000
	sweep_step = 2




/*
 * Rolling Pins
 */

/obj/item/weapon/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon_state = "rolling_pin"
	force = 8.0
	hitsound = list('sound/effects/woodhit.ogg')
	throwforce = 10.0
	throw_speed = 2
	throw_range = 7
	w_class = ITEM_SIZE_NORMAL
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked") //I think the rollingpin attackby will end up ignoring this anyway.

/obj/item/weapon/kitchen/rollingpin/attack(mob/living/M, mob/living/user)
	if ((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>The [src] slips out of your hand and hits your head.</span>")
		user.take_bodypart_damage(10)
		user.Paralyse(2)
		return

	M.log_combat(user, "attacked with [name]")

	var/t = user.zone_sel.selecting
	if (t == BP_HEAD)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.stat < 2 && H.health < 50 && prob(90))
				// ******* Check
				if (istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80))
					to_chat(H, "<span class='warning'>The helmet protects you from being hit hard in the head!</span>")
					return
				var/time = rand(2, 6)
				if (prob(75))
					H.Paralyse(time)
				else
					H.Stun(time)
				if(H.stat != DEAD)	H.stat = UNCONSCIOUS
				user.visible_message("<span class='warning'><B>[H] has been knocked unconscious!</B></span>", "<span class='warning'><B>You knock [H] unconscious!</B></span>")
				return
			else
				H.visible_message("<span class='warning'>[user] tried to knock [H] unconscious!</span>", "<span class='warning'>[user] tried to knock you unconscious!</span>")
				H.eye_blurry += 3
	return ..()

/*
 * Trays - Agouri
 */
/obj/item/weapon/tray
	name = "tray"
	icon = 'icons/obj/food.dmi'
	icon_state = "tray"
	desc = "A metal tray to lay food on."
	throwforce = 12.0
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	flags = CONDUCT
	m_amt = 3000
	/* // NOPE
	var/food_total= 0
	var/burger_amt = 0
	var/cheese_amt = 0
	var/fries_amt = 0
	var/classyalcdrink_amt = 0
	var/alcdrink_amt = 0
	var/bottle_amt = 0
	var/soda_amt = 0
	var/carton_amt = 0
	var/pie_amt = 0
	var/meatbreadslice_amt = 0
	var/salad_amt = 0
	var/miscfood_amt = 0
	*/
	var/list/carrying = list() // List of things on the tray. - Doohl
	var/max_carry = 10 // w_class = ITEM_SIZE_TINY -- takes up 1
					   // w_class = ITEM_SIZE_SMALL -- takes up 3
					   // w_class = ITEM_SIZE_NORMAL -- takes up 5

/obj/item/weapon/tray/attack(mob/living/carbon/M, mob/living/carbon/user, def_zone)

	// Drop all the things. All of them.
	cut_overlays()
	for(var/obj/item/I in carrying)
		I.loc = M.loc
		carrying.Remove(I)
		if(isturf(I.loc))
			spawn()
				for(var/i = 1, i <= rand(1,2), i++)
					if(I)
						step(I, pick(NORTH,SOUTH,EAST,WEST))
						sleep(rand(2,4))


	if((CLUMSY in user.mutations) && prob(50))              //What if he's a clown?
		to_chat(M, "<span class='warning'>You accidentally slam yourself with the [src]!</span>")
		M.Weaken(1)
		user.take_bodypart_damage(2)
		if(prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', VOL_EFFECTS_MASTER)
			return
		else
			playsound(M, 'sound/items/trayhit2.ogg', VOL_EFFECTS_MASTER) //sound playin'
			return //it always returns, but I feel like adding an extra return just for safety's sakes. EDIT; Oh well I won't :3

	var/mob/living/carbon/human/H = M      ///////////////////////////////////// /Let's have this ready for later.


	if(!(def_zone == O_EYES || def_zone == BP_HEAD)) //////////////hitting anything else other than the eyes
		if(prob(33))
			src.add_blood(H)
			var/turf/location = H.loc
			if (istype(location, /turf/simulated))
				location.add_blood(H)     ///Plik plik, the sound of blood

		M.log_combat(user, "attacked with [name]")

		if(prob(15))
			M.Weaken(3)
			M.take_bodypart_damage(3)
		else
			M.take_bodypart_damage(5)
		if(prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', VOL_EFFECTS_MASTER)
			M.visible_message("<span class='warning'><B>[user] slams [M] with the tray!</B></span>")
			return
		else
			playsound(M, 'sound/items/trayhit2.ogg', VOL_EFFECTS_MASTER)  //we applied the damage, we played the sound, we showed the appropriate messages. Time to return and stop the proc
			M.visible_message("<span class='warning'><B>[user] slams [M] with the tray!</B></span>")
			return




	if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
		to_chat(M, "<span class='warning'>You get slammed in the face with the tray, against your mask!</span>")
		if(prob(33))
			src.add_blood(H)
			if (H.wear_mask)
				H.wear_mask.add_blood(H)
			if (H.head)
				H.head.add_blood(H)
			if (H.glasses && prob(33))
				H.glasses.add_blood(H)
			var/turf/location = H.loc
			if (istype(location, /turf/simulated))     //Addin' blood! At least on the floor and item :v
				location.add_blood(H)

		if(prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', VOL_EFFECTS_MASTER)
		else
			playsound(M, 'sound/items/trayhit2.ogg', VOL_EFFECTS_MASTER)  //sound playin'
		M.visible_message("<span class='warning'><B>[user] slams [M] with the tray!</B></span>")
		if(prob(10))
			M.Stun(rand(1,3))
			M.take_bodypart_damage(3)
			return
		else
			M.take_bodypart_damage(5)
			return

	else //No eye or head protection, tough luck!
		to_chat(M, "<span class='warning'>You get slammed in the face with the tray!</span>")
		if(prob(33))
			src.add_blood(M)
			var/turf/location = H.loc
			if (istype(location, /turf/simulated))
				location.add_blood(H)

		if(prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', VOL_EFFECTS_MASTER)
		else
			playsound(M, 'sound/items/trayhit2.ogg', VOL_EFFECTS_MASTER)  //sound playin' again
		M.visible_message("<span class='warning'><B>[user] slams [M] in the face with the tray!</B></span>")

		if(prob(30))
			M.Stun(rand(2,4))
			M.take_bodypart_damage(4)
			return
		else
			M.take_bodypart_damage(8)
			if(prob(30))
				M.Weaken(2)
				return
			return

/obj/item/weapon/tray/var/cooldown = 0	//shield bash cooldown. based on world.time

/obj/item/weapon/tray/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/kitchen/rollingpin))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [I]!</span>")
			playsound(user, 'sound/effects/shieldbash.ogg', VOL_EFFECTS_MASTER)
			cooldown = world.time
	else
		return ..()

/*
===============~~~~~================================~~~~~====================
=																			=
=  Code for trays carrying things. By Doohl for Doohl erryday Doohl Doohl~  =
=																			=
===============~~~~~================================~~~~~====================
*/
/obj/item/weapon/tray/proc/calc_carry()
	// calculate the weight of the items on the tray
	var/val = 0 // value to return

	for(var/obj/item/I in carrying)
		if(I.w_class == 1.0)
			val ++
		else if(I.w_class == 2.0)
			val += 3
		else
			val += 5

	return val

/obj/item/weapon/tray/pickup(mob/living/user)

	if(!isturf(loc))
		return

	for(var/obj/item/I in loc)
		if( I != src && !I.anchored && !istype(I, /obj/item/clothing/under) && !istype(I, /obj/item/clothing/suit) && !istype(I, /obj/item/projectile) )
			var/add = 0
			if(I.w_class == 1.0)
				add = 1
			else if(I.w_class == 2.0)
				add = 3
			else
				add = 5
			if(calc_carry() + add >= max_carry)
				break

			I.loc = src
			carrying.Add(I)
			add_overlay(image("icon" = I.icon, "icon_state" = I.icon_state, "layer" = 30 + I.layer))

/obj/item/weapon/tray/dropped(mob/user)

	var/mob/living/M
	for(M in src.loc) //to handle hand switching
		return

	var/foundtable = 0
	for(var/obj/structure/table/T in loc)
		foundtable = 1
		break

	cut_overlays()

	for(var/obj/item/I in carrying)
		I.loc = loc
		carrying.Remove(I)
		if(!foundtable && isturf(loc))
			// if no table, presume that the person just shittily dropped the tray on the ground and made a mess everywhere!
			spawn()
				for(var/i = 1, i <= rand(1,2), i++)
					if(I)
						step(I, pick(NORTH,SOUTH,EAST,WEST))
						sleep(rand(2,4))

///////////////////NEW//////////////////////

/obj/item/weapon/kitchen/mould
	name = "generic candy mould"
	desc = "You aren't sure what it's supposed to be."
	icon_state = "mould"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")

/obj/item/weapon/kitchen/mould/bear
	name = "bear-shaped candy mould"
	desc = "It has the shape of a small bear imprinted into it."
	icon_state = "mould_bear"

/obj/item/weapon/kitchen/mould/worm
	name = "worm-shaped candy mould"
	desc = "It has the shape of a worm imprinted into it."
	icon_state = "mould_worm"

/obj/item/weapon/kitchen/mould/bean
	name = "bean-shaped candy mould"
	desc = "It has the shape of a bean imprinted into it."
	icon_state = "mould_bean"

/obj/item/weapon/kitchen/mould/ball
	name = "ball-shaped candy mould"
	desc = "It has a small sphere imprinted into it."
	icon_state = "mould_ball"

/obj/item/weapon/kitchen/mould/cane
	name = "cane-shaped candy mould"
	desc = "It has the shape of a cane imprinted into it."
	icon_state = "mould_cane"

/obj/item/weapon/kitchen/mould/cash
	name = "cash-shaped candy mould"
	desc = "It has the shape and design of fake money imprinted into it."
	icon_state = "mould_cash"

/obj/item/weapon/kitchen/mould/coin
	name = "coin-shaped candy mould"
	desc = "It has the shape of a coin imprinted into it."
	icon_state = "mould_coin"

/obj/item/weapon/kitchen/mould/loli
	name = "sucker mould"
	desc = "It has the shape of a sucker imprinted into it."
	icon_state = "mould_loli"
