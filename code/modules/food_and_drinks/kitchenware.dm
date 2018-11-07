/* Kitchenware
 * Contains:
 *		Utensils
 *		Spoons
 *		Forks
 *		Knives
 *		Kitchen knives
 *		Butcher's cleaver
 *		Rolling Pins
 *		Trays
 *		Pots and Pans
 *		Plates
 *		Wooden Spoon
 *		Bowl
 *		Pizzabox
 */

/obj/item/weapon/kitchen
	name = "kitchen tool"
	icon = 'icons/obj/food_and_drinks/kitchenware.dmi'

/*
 * Utensils
 */
/obj/item/weapon/kitchen/utensil
	force = 0
	w_class = 1.0
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

	if(user.a_intent != "help")
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
				overlays.Cut()
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
	icon_state = "fork"

/obj/item/weapon/kitchen/utensil/fork/afterattack(atom/target, mob/user, proximity)
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


/obj/item/weapon/kitchen/utensil/pfork/afterattack(atom/target, mob/user, proximity)  //make them useful or some slow soap for plastic. Just copy-paste from usual fork
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
	icon = 'icons/obj/food_and_drinks/kitchenware.dmi'
	icon_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	flags = CONDUCT
	sharp = 1
	edge = 1
	force = 10.0
	w_class = 2.0
	throwforce = 6.0
	throw_speed = 3
	throw_range = 6
	m_amt = 12000
	origin_tech = "materials=1"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	suicide_act(mob/user)
		to_chat(viewers(user), pick("\red <b>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</b>", \
							"\red <b>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</b>", \
							"\red <b>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</b>"))
		return (BRUTELOSS)

/obj/item/weapon/kitchenknife/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(user.a_intent == "help" && M.attempt_harvest(src, user))
		return
	return ..()

/obj/item/weapon/kitchenknife/plastic
	name = "plastic knife"
	desc = "The bluntest of blades."
	icon_state = "pknife"
	force = 0
	w_class = 2.0
	throwforce = 0

/obj/item/weapon/kitchenknife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"

/*
 * Bucher's cleaver
 */
/obj/item/weapon/butch
	name = "butcher's cleaver"
	icon = 'icons/obj/food_and_drinks/kitchenware.dmi'
	icon_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products."
	flags = CONDUCT
	force = 15.0
	w_class = 3.0
	throwforce = 8.0
	throw_speed = 3
	throw_range = 6
	m_amt = 12000
	origin_tech = "materials=1"
	attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = 1
	edge = 1

/obj/item/weapon/butch/attack(mob/living/M, mob/living/user)
	if(user.a_intent == I_HELP && M.attempt_harvest(src, user))
		return
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/*
 * Rolling Pins
 */

/obj/item/weapon/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon_state = "rolling_pin"
	force = 8.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 7
	w_class = 3.0
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked") //I think the rollingpin attackby will end up ignoring this anyway.

/obj/item/weapon/kitchen/rollingpin/attack(mob/living/M, mob/living/user)
	if ((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "\red The [src] slips out of your hand and hits your head.")
		user.take_bodypart_damage(10)
		user.Paralyse(2)
		return

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) used the [src.name] to attack [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	var/t = user:zone_sel.selecting
	if (t == BP_HEAD)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.stat < 2 && H.health < 50 && prob(90))
				// ******* Check
				if (istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80))
					to_chat(H, "\red The helmet protects you from being hit hard in the head!")
					return
				var/time = rand(2, 6)
				if (prob(75))
					H.Paralyse(time)
				else
					H.Stun(time)
				if(H.stat != DEAD)	H.stat = UNCONSCIOUS
				user.visible_message("\red <B>[H] has been knocked unconscious!</B>", "\red <B>You knock [H] unconscious!</B>")
				return
			else
				H.visible_message("\red [user] tried to knock [H] unconscious!", "\red [user] tried to knock you unconscious!")
				H.eye_blurry += 3
	return ..()

/*
 * Trays - Agouri
 */
/obj/item/weapon/tray
	name = "tray"
	icon = 'icons/obj/food_and_drinks/kitchenware.dmi'
	icon_state = "tray"
	desc = "A metal tray to lay food on."
	throwforce = 12.0
	throw_range = 5
	w_class = 3.0
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
	var/max_carry = 10 // w_class = 1 -- takes up 1
					   // w_class = 2 -- takes up 3
					   // w_class = 3 -- takes up 5

/obj/item/weapon/tray/attack(mob/living/carbon/M, mob/living/carbon/user, def_zone)

	// Drop all the things. All of them.
	overlays.Cut()
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
		to_chat(M, "\red You accidentally slam yourself with the [src]!")
		M.Weaken(1)
		user.take_bodypart_damage(2)
		if(prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', 50, 1)
			return
		else
			playsound(M, 'sound/items/trayhit2.ogg', 50, 1) //sound playin'
			return //it always returns, but I feel like adding an extra return just for safety's sakes. EDIT; Oh well I won't :3

	var/mob/living/carbon/human/H = M      ///////////////////////////////////// /Let's have this ready for later.


	if(!(def_zone == O_EYES || def_zone == BP_HEAD)) //////////////hitting anything else other than the eyes
		if(prob(33))
			src.add_blood(H)
			var/turf/location = H.loc
			if (istype(location, /turf/simulated))
				location.add_blood(H)     ///Plik plik, the sound of blood

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")
		msg_admin_attack("[user.name] ([user.ckey]) used the [src.name] to attack [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		if(prob(15))
			M.Weaken(3)
			M.take_bodypart_damage(3)
		else
			M.take_bodypart_damage(5)
		if(prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', 50, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] slams [] with the tray!</B>", user, M), 1)
			return
		else
			playsound(M, 'sound/items/trayhit2.ogg', 50, 1)  //we applied the damage, we played the sound, we showed the appropriate messages. Time to return and stop the proc
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] slams [] with the tray!</B>", user, M), 1)
			return




	if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
		to_chat(M, "\red You get slammed in the face with the tray, against your mask!")
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
			playsound(M, 'sound/items/trayhit1.ogg', 50, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] slams [] with the tray!</B>", user, M), 1)
		else
			playsound(M, 'sound/items/trayhit2.ogg', 50, 1)  //sound playin'
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] slams [] with the tray!</B>", user, M), 1)
		if(prob(10))
			M.Stun(rand(1,3))
			M.take_bodypart_damage(3)
			return
		else
			M.take_bodypart_damage(5)
			return

	else //No eye or head protection, tough luck!
		to_chat(M, "\red You get slammed in the face with the tray!")
		if(prob(33))
			src.add_blood(M)
			var/turf/location = H.loc
			if (istype(location, /turf/simulated))
				location.add_blood(H)

		if(prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', 50, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] slams [] in the face with the tray!</B>", user, M), 1)
		else
			playsound(M, 'sound/items/trayhit2.ogg', 50, 1)  //sound playin' again
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] slams [] in the face with the tray!</B>", user, M), 1)
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

/obj/item/weapon/tray/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/kitchen/rollingpin))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
			cooldown = world.time
	else
		..()

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

/obj/item/weapon/tray/pickup(mob/user)

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
			overlays += image("icon" = I.icon, "icon_state" = I.icon_state, "layer" = 30 + I.layer)

/obj/item/weapon/tray/dropped(mob/user)

	var/mob/living/M
	for(M in src.loc) //to handle hand switching
		return

	var/foundtable = 0
	for(var/obj/structure/table/T in loc)
		foundtable = 1
		break

	overlays.Cut()

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

///////////////////moulds//////////////////////

/obj/item/weapon/kitchen/mould
	name = "generic candy mould"
	desc = "You aren't sure what it's supposed to be."
	icon_state = "mould"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = 2
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

/////////////////////////////////////////////////////////////////////////////////////////
//Enough with the violent stuff, here's what happens if you try putting food on it
/////////////////////////////////////////////////////////////////////////////////////////////

/*/obj/item/weapon/tray/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/kitchen/utensil/fork))
		if (W.icon_state == "forkloaded")
			to_chat(user, "\red You already have omelette on your fork.")
			return
		W.icon = 'icons/obj/kitchen.dmi'
		W.icon_state = "forkloaded"
		to_chat(viewers(3,user), "[user] takes a piece of omelette with his fork!")
		reagents.remove_reagent("nutriment", 1)
		if (reagents.total_volume <= 0)
			qdel(src)*/


/*			if (prob(33))
						var/turf/location = H.loc
						if (istype(location, /turf/simulated))
							location.add_blood(H)
					if (H.wear_mask)
						H.wear_mask.add_blood(H)
					if (H.head)
						H.head.add_blood(H)
					if (H.glasses && prob(33))
						H.glasses.add_blood(H)
					if (istype(user, /mob/living/carbon/human))
						var/mob/living/carbon/human/user2 = user
						if (user2.gloves)
							user2.gloves.add_blood(H)
						else
							user2.add_blood(H)
						if (prob(15))
							if (user2.wear_suit)
								user2.wear_suit.add_blood(H)
							else if (user2.w_uniform)
								user2.w_uniform.add_blood(H)*/



///-----------------------------------------------------//
///														//
///						Pot and pan						//
///						Used by Stove.					//
///-----------------------------------------------------//

/obj/item/weapon/kitchenware
	icon = 'icons/obj/food_and_drinks/kitchenware.dmi'
	w_class = 3
	throw_speed = 3
	throw_range = 4

/obj/item/weapon/kitchenware/pot
	name = "pot"
	desc = "Just a metal cooking pot. Suddenly, you can't fit it on your head."
	icon_state = "empty_pot"

/obj/item/weapon/kitchenware/pan
	name = "frying pan"
	desc = "Stainless frying pan, good for beating a clown and frying mice.
	icon_state = "empty_pan"
	force = 10
	throwforce = 10

/obj/item/weapon/kitchenware/filled
	throw_speed = 1
	throw_range = 2

/obj/item/weapon/kitchenware/filled/attack(mob/M, mob/user, def_zone)
	.=..()
	if(istype(M, /mob/living/carbon))
		if(M == user)
			to_chat(user, "<span class='rose'>Are you going to eat right from the [src]? How indecent!</span>")

/obj/item/weapon/kitchenware/filled/proc/update_state()
	if(contents.len == 0)
		to_chat(user, "<span class='notice'>[src] is empty.</span>")
		if(istype(src, /obj/item/weapon/kitchenware/filled/pot))
			var/obj/item/weapon/kitchenware/pot/K = new /obj/item/weapon/kitchenware/pot(src)
		if(istype(src, /obj/item/weapon/kitchenware/filled/pan))
			var/obj/item/weapon/kitchenware/pan/K = new /obj/item/weapon/kitchenware/pan(src)
		if(user.l_hand == src || user.r_hand == src)
			qdel(src)
			user.put_in_hands(K)
		else
			qdel(src)
	else
		overlays.Cut()
		for(var/obj/item/F in contents)
			if(istype(src, /obj/item/weapon/kitchenware/filled/pot))
				var/container = "pot"
				src.desc = "Just a metal cooking pot. Its filled with /the [F.name]."
			if(istype(src, /obj/item/weapon/kitchenware/filled/pan))
				var/container = "pan"
				src.desc = "Stainless frying pan. Its filled with /the [F.name]."
			var/image/I = new(icon, "[container]_filling")
			if(istype(F, /obj/item/reagent_containers/food/snacks))
				var/obj/item/reagent_containers/food/snacks/food = F
				if(!food.filling_color == "#FFFFFF")
					I.color = food.filling_color
				else
					I.color = pick("#FF0000","#0000FF","#008000","#FFFF00")
			else
				I.color = pick("#FF0000","#0000FF","#008000","#FFFF00")
			overlays += I

/obj/item/weapon/kitchenware/filled/pot
	name = "pot"
	desc = "Just a metal cooking pot. Its filled with something."
	icon_state = "empty_pot"

/obj/item/weapon/kitchenware/filled/pan
	name = "frying pan"
	desc = "Stainless frying pan. Its filled with something."
	icon_state = "empty_pan"

///-----------------------------------------------------//
///														//
///						Plate							//
///	For every snack that has cant_be_put_on_plate = 0.	//
///-----------------------------------------------------//

/obj/item/weapon/kitchen/plate
	name = "plate"
	desc = "It's a shiny clean plate, good for placing food on it."
	icon_state = "plate"
	force = 2
	w_class = 2
	throwforce = 2
	throw_speed = 3
	throw_range = 4

/obj/item/weapon/kitchen/plate/attackby(obj/item/weapon/W, mob/user)
	.=..()
	if(istype(W, /obj/item/weapon/kitchenware/filled))
		for(var/obj/item/reagent_containers/food/snacks/F in W.contents)
			if(F.cant_be_put_on_plate == 1)
				to_chat(user, "<span class='rose'>You can't put this [F] on the plate.</span>")
				return
			F.loc = get_turf(src)
			var/image/plate_image = new(icon, "plate")
			F.underlays += plate_image
			F.trash = /obj/item/weapon/kitchen/dirty_plate
			qdel(src)
			if(istype(user, /mob/living))
				var/mob/living/target = user
				target.visible_message("<span class='notice'>[target] puts [F] from the [W.name] on the plate</span>", \
				"<span class='notice'>You put [F] from the [W.name] on the plate</span>")
		W.update_state()
		return
	if(istype(W, /obj/item/reagent_containers/food/snacks))
		if(!(W.trash == /obj/item/weapon/kitchen/dirty_plate))
			if(W.cant_be_put_on_plate == 1)
				to_chat(user, "<span class='rose'>You can't put this [W] on the plate.</span>")
				return
			W.loc = get_turf(src)
			var/image/plate_image = new(icon, "plate")
			W.underlays += plate_image
			W.trash = /obj/item/weapon/kitchen/dirty_plate
			qdel(src)
			if(istype(user, /mob/living))
				var/mob/living/target = user
				target.visible_message("<span class='notice'>[target] puts [W] on the plate</span>", \
				"<span class='notice'>You put [W] on the plate</span>")
			return
		else
			to_chat(user, "<span class='rose'>This [W] is already on the plate.</span>")
			return

/obj/item/weapon/kitchen/plate/attack(obj/item/weapon/W, mob/user)
	.=..()
	if(istype(W, /obj/item/weapon/kitchenware/filled))
		for(var/obj/item/reagent_containers/food/snacks/F in W.contents)
			if(F.cant_be_put_on_plate == 1)
				to_chat(user, "<span class='rose'>You can't put this [F] on the plate.</span>")
				return
			F.loc = get_turf(src)
			var/image/plate_image = new(icon, "plate")
			F.underlays += plate_image
			F.trash = /obj/item/weapon/kitchen/dirty_plate
			if(user.l_hand == src || user.r_hand == src)
				qdel(src)
				user.put_in_hands(F)
			else
				qdel(src)
			if(istype(user, /mob/living))
				var/mob/living/target = user
				target.visible_message("<span class='notice'>[target] puts [F] from the [W.name] on the plate</span>", \
				"<span class='notice'>You put [F] from the [W.name] on the plate</span>")
		W.update_state()
		return
	if(istype(W, /obj/item/reagent_containers/food/snacks))
		if(!(W.trash == /obj/item/weapon/kitchen/dirty_plate))
			if(W.cant_be_put_on_plate == 1)
				to_chat(user, "<span class='rose'>You can't put this [W] on the plate.</span>")
				return
			W.loc = get_turf(src)
			var/image/plate_image = new(icon, "plate")
			W.underlays += plate_image
			W.trash = /obj/item/weapon/kitchen/dirty_plate
			if(user.l_hand == src || user.r_hand == src)
				qdel(src)
				user.put_in_hands(W)
			else
				qdel(src)
			if(istype(user, /mob/living))
				var/mob/living/target = user
				target.visible_message("<span class='notice'>[target] puts [W] on the plate</span>", \
				"<span class='notice'>You put [W] on the plate</span>")
			return
		else
			to_chat(user, "<span class='rose'>This [W] is already on the plate.</span>")
			return


/obj/item/weapon/kitchen/dirty_plate
	name = "dirty plate"
	desc = "It's a dirty damn plate, you better clean it up, Chef."
	icon_state = "dirty_plate"
	force = 2
	w_class = 2
	throwforce = 2
	throw_speed = 3
	throw_range = 4

/obj/item/weapon/kitchen/dirty_plate/attackby(obj/item/weapon/W, mob/user)
	.=..()
	if(istype(W, /obj/item/weapon/kitchenware/filled))
		to_chat(user, "<span class='notice'>This plate is too dirty! You better clean it up!</span>")
		return
	if(istype(W, /obj/item/reagent_containers/food/snacks))
		to_chat(user, "<span class='notice'>This plate is too dirty! You better clean it up!</span>")
		return
	if(istype(W, /obj/item/weapon/soap))
		if(do_after(user, 10, target = src) && W)
			for(var/mob/V in viewers(user, null))
				V.show_message("\blue [user] washes [src] using the soap.")
			var/obj/item/weapon/kitchen/plate/B = new /obj/item/weapon/kitchen/plate(src)
			if(user.l_hand == src || user.r_hand == src)
				qdel(src)
				user.put_in_hands(B)
			else
				qdel(src)
			return
///-----------------------------------------------------//
///														//
///					Wooden spoon						//
///					Used by bowls.						//
///-----------------------------------------------------//
/obj/item/weapon/kitchen/utensil/woodenspoon
	name = "wooden spoon"
	desc = "No, Deda! Not in the head!"
	icon_state = "woodenspoon"

///-----------------------------------------------------//
///														//
///						Bowl							//
///				For soups and salads.					//
///-----------------------------------------------------//

/obj/item/weapon/kitchen/bowl
	name = "kitchen bowl"
	desc = "It's a large deep pot, usually is used to make salads.
	icon_state = "bowl"
	w_class = 3
	throw_speed = 1
	throw_range = 3
	var/new_ingridient = null
	var/list/datum/recipe/available_recipes // List of the recipes you can use
	var/list/acceptable_items // List of the items you can put in
	var/list/acceptable_reagents // List of the reagents you can put in

/obj/item/weapon/kitchen/bowl/atom_init()
	..()
	reagents = new/datum/reagents(100)
	reagents.my_atom = src
	if(!available_recipes)
		available_recipes = new
		acceptable_items = new
		acceptable_reagents = new
	return INITIALIZE_HINT_LATELOAD

/obj/item/weapon/kitchen/bowl/atom_init_late()
	for(var/type in subtypesof(/datum/recipe/bowl))
		var/datum/recipe/recipe = new type
		if(recipe.result) // Ignore recipe subtypes that lack a result
			available_recipes += recipe
			for(var/item in recipe.items)
				acceptable_items |= item
			for(var/reagent in recipe.reagents)
				acceptable_reagents |= reagent
		else
			qdel(recipe)
	acceptable_items |= /obj/item/weapon/reagent_containers/food/snacks/grown

/obj/item/weapon/kitchen/bowl/attackby(obj/O, mob/user)
	.=..()
	if(is_type_in_list(O, acceptable_items))
		if(contents.len >= 10)
			to_chat(user, "<span class='danger'>This [src] is full of ingredients, you cannot put more.</span>")
			return
		var/obj/item/stack/S = O
		if (istype(S) && S.get_amount() > 1)
			new O.type (src)
			O.loc = src
			S.use(1)
			user.visible_message( \
				"<span class='notice'>[user] has added one of [O] to \the [src].</span>", \
				"<span class='notice'>You add one of [O] to \the [src].</span>")
		else
			user.drop_item()
			O.loc = src
			user.visible_message( \
				"<span class='notice'>[user] has added \the [O] to \the [src].</span>", \
				"<span class='notice'>You add \the [O] to \the [src].</span>")
		new_ingridient = O
		update_icon()
		return
	if(istype(O, /obj/item/weapon/kitchen/utensil/woodenspoon))
		if (reagents.total_volume==0 && !(locate(/obj) in contents)) //dry run
			return

		var/datum/recipe/recipe = select_recipe(available_recipes, src)
		var/obj/new_dish
		var/obj/byproduct
		if (!recipe)
			to_chat(user, "<span class='danger'>You can't remember any recipe out of these ingridients</span>")
			return
		else
			user.visible_message( \
			"<span class='notice'>[user] starts stirring \the [src] with a [O].</span>", \
			"<span class='notice'>You start stirring [src] using a [O].</span>")
			if(do_after(user, 10, target = src) && O)
				new_dish = recipe.make_food(src)
				byproduct = recipe.get_byproduct()
				if(new_dish)
					new_dish.loc = get_turf(src)
				if(byproduct)
					new byproduct(src)
				user.visible_message( \
				"<span class='notice'>[user] made a [new_dish].</span>", \
				"<span class='notice'>You made a [new_dish].</span>")
				score["meals"]++
				return
			else
				return

/obj/item/weapon/bowl/attack_hand(mob/user)
	.=..()
	if(contents.len)
		var/choice_where = alert("Do you want to take out any ingridient?","Yes","No")
		if(choice_where == "Yes")
			var/obj/item/weapon/reagent_containers/food/snacks/choice = input("Which ingridient would you like to remove from the bowl?") in contents as obj|null
			if(choice)
				if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
					return
				if(ishuman(user))
					if(!user.get_active_hand())
						user.put_in_hands(choice)
				else
					choice.loc = get_turf(src)
				update_icon()
				return

/obj/item/weapon/bowl/update_icon()
	if(contents.len == 0)
		overlays.cut()
		icon_state = "bowl"
	else
		var/image/I = new(icon, "bowl_filling")
		if(istype(new_ingridient, /obj/item/reagent_containers/food/snacks))
			var/obj/item/reagent_containers/food/snacks/food = new_ingridient
			if(!food.filling_color == "#FFFFFF")
				I.color = food.filling_color
			else
				I.color = pick("#FF0000","#0000FF","#008000","#FFFF00")
		else
			I.color = pick("#FF0000","#0000FF","#008000","#FFFF00")
		overlays += I
//		var/image/bowl_overlay = new(icon, "bowl_overlay")//Cause we may use actual new_ingridient's icon_state in the future
//		overlays += bowl_overlay

//Dirty bowl
/obj/item/weapon/kitchen/dirty_bowl
	name = "dirty bowl"
	desc = "You gotta clean it up if you want to continue working with it."
	icon_state = "dirty_bowl"
	w_class = 3
	throw_speed = 3
	throw_range = 3

/obj/item/weapon/dirty_bowl/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/weapon/soap))
		if(do_after(user, 10, target = src) && O)
			for(var/mob/V in viewers(user, null))
				V.show_message("\blue [user] washes [src] using the soap.")
			var/obj/item/weapon/bowl/B = new /obj/item/weapon/bowl
			if(user.l_hand == src || user.r_hand == src)
				qdel(src)
				user.put_in_hands(B)
			else
				qdel(src)
	else
		..()

///-----------------------------------------------------//
///														//
///						Pizzabox						//
///														//
///-----------------------------------------------------//
/obj/item/pizzabox
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food_and_drinks/snacks.dmi'
	icon_state = "pizzabox1"
	item_state = "pizzabox"
	var/open = 0 // Is the box open?
	var/ismessy = 0 // Fancy mess on the lid
	var/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/pizza // Content pizza
	var/list/boxes = list() // If the boxes are stacked, they come here
	var/boxtag = ""

/obj/item/pizzabox/update_icon()

	overlays = list()

	// Set appropriate description
	if( open && pizza )
		desc = "A box suited for pizzas. It appears to have a [pizza.name] inside."
	else if( boxes.len > 0 )
		desc = "A pile of boxes suited for pizzas. There appears to be [boxes.len + 1] boxes in the pile."

		var/obj/item/pizzabox/topbox = boxes[boxes.len]
		var/toptag = topbox.boxtag
		if( toptag != "" )
			desc = "[desc] The box on top has a tag, it reads: '[toptag]'."
	else
		desc = "A box suited for pizzas."

		if( boxtag != "" )
			desc = "[desc] The box has a tag, it reads: '[boxtag]'."

	// Icon states and overlays
	if( open )
		if( ismessy )
			icon_state = "pizzabox_messy"
		else
			icon_state = "pizzabox_open"

		if( pizza )
			var/image/pizzaimg = image(icon, pizza.icon_state)
			pizzaimg.pixel_y = -3
			overlays += pizzaimg

		return
	else
		// Stupid code because byondcode sucks
		var/doimgtag = 0
		if( boxes.len > 0 )
			var/obj/item/pizzabox/topbox = boxes[boxes.len]
			if( topbox.boxtag != "" )
				doimgtag = 1
		else
			if( boxtag != "" )
				doimgtag = 1

		if( doimgtag )
			var/image/tagimg = image(icon, icon_state = "pizzabox_tag")
			tagimg.pixel_y = boxes.len * 3
			overlays += tagimg

	icon_state = "pizzabox[boxes.len+1]"

/obj/item/pizzabox/attack_hand( mob/user )

	if( open && pizza )
		user.put_in_hands( pizza )

		to_chat(user, "<span class='notice'>You take the [src.pizza] out of the [src].</span>")
		src.pizza = null
		update_icon()
		return

	if( boxes.len > 0 )
		if( user.get_inactive_hand() != src )
			..()
			return

		var/obj/item/pizzabox/box = boxes[boxes.len]
		boxes -= box

		user.put_in_hands( box )
		to_chat(user, "<span class='notice'>You remove the topmost [src] from your hand.</span>")
		box.update_icon()
		update_icon()
		return
	..()

/obj/item/pizzabox/attack_self( mob/user )

	if( boxes.len > 0 )
		return

	open = !open

	if( open && pizza )
		ismessy = 1

	update_icon()

/obj/item/pizzabox/attackby( obj/item/I, mob/user )
	if( istype(I, /obj/item/pizzabox/) )
		var/obj/item/pizzabox/box = I

		if( !box.open && !src.open )
			// Make a list of all boxes to be added
			var/list/boxestoadd = list()
			boxestoadd += box
			for(var/obj/item/pizzabox/i in box.boxes)
				boxestoadd += i

			if( (boxes.len+1) + boxestoadd.len <= 5 )
				user.drop_item()

				box.loc = src
				box.boxes = list() // Clear the box boxes so we don't have boxes inside boxes. - Xzibit
				src.boxes.Add( boxestoadd )

				box.update_icon()
				update_icon()

				to_chat(user, "<span class='notice'>You put the [box] ontop of the [src]!</span>")
			else
				to_chat(user, "<span class='rose'>The stack is too high!</span>")
		else
			to_chat(user, "<span class='rose'>Close the [box] first!</span>")

		return

	if( istype(I, /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/) ) // Long ass fucking object name

		if( src.open )
			user.drop_item()
			I.loc = src
			src.pizza = I

			update_icon()

			to_chat(user, "<span class='notice'>You put the [I] in the [src]!</span>")
		else
			to_chat(user, "<span class='rose'>You try to push the [I] through the lid but it doesn't work!</span>")
		return

	if( istype(I, /obj/item/weapon/pen/) )

		if( src.open )
			return

		var/t = sanitize_safe(input("Enter what you want to add to the tag:", "Write", null, null) as text, MAX_LNAME_LEN)

		var/obj/item/pizzabox/boxtotagto = src
		if( boxes.len > 0 )
			boxtotagto = boxes[boxes.len]

		boxtotagto.boxtag = copytext("[boxtotagto.boxtag][t]", 1, 30)

		update_icon()
		return
	..()

/obj/item/pizzabox/margherita/atom_init()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita(src)
	boxtag = "Margherita Deluxe"

/obj/item/pizzabox/vegetable/atom_init()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza(src)
	boxtag = "Gourmet Vegatable"

/obj/item/pizzabox/mushroom/atom_init()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroompizza(src)
	boxtag = "Mushroom Special"

/obj/item/pizzabox/meat/atom_init()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza(src)
	boxtag = "Meatlover's Supreme"