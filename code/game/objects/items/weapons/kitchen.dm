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

/obj/item/weapon/tray
	name = "tray"
	icon = 'icons/obj/food.dmi'
	icon_state = "tray"
	desc = "A metal tray to lay food on."
	force = 5
	throwforce = 12.0
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	flags = CONDUCT
	m_amt = 3000
	var/gathering_mode = TRUE
	var/cooldown = 0 //shield bash cooldown. based on world.time
	var/list/carrying = list()
	var/holding_weight = 0
	var/static/list/tray_whitelisted_items = typecacheof(list(
		/obj/item/weapon/reagent_containers/food,
		/obj/item/weapon/reagent_containers/glass,
		/obj/item/weapon/reagent_containers/food,
		/obj/item/weapon/kitchenknife,
		/obj/item/weapon/kitchen/rollingpin,
		/obj/item/weapon/kitchen/utensil,
		)) //Should cover: Bottles, Beakers, Bowls, Booze, Glasses, Food, and Kitchen Tools.
	var/max_carry = 7 // w_class = ITEM_SIZE_TINY -- takes up 1
					   // w_class = ITEM_SIZE_SMALL -- takes up 2
					   // w_class = ITEM_SIZE_NORMAL -- takes up 3

/obj/item/weapon/tray/attack(mob/living/carbon/M, mob/living/carbon/user, def_zone)
	var/list/obj/item/oldContents = carrying.Copy() //copy so if somebody picks the tray up while do_scatter is still playing items wont get moved back
	for(var/obj/item/I in oldContents)
		INVOKE_ASYNC(src, .proc/do_scatter, I)
		cut_overlay(image("icon" = I.icon, "icon_state" = I.icon_state, "layer" = 30 + I.layer))
		carrying.Remove(I)
	playsound(M, pick('sound/items/trayhit1.ogg', 'sound/items/trayhit2.ogg'), VOL_EFFECTS_MASTER)
	return ..()

/obj/item/weapon/tray/attack_self(mob/user)
	gathering_mode = !gathering_mode
	to_chat(user, "<span class='notice'>You change gathering mode to [gathering_mode?"load":"unload"]</span>")
	return

/obj/item/weapon/tray/afterattack(atom/target, mob/user, proximity, params)
	if(!target)
		return
	if(gathering_mode)
		pickupitems(user, target)
	else
		dropitems(user, target)
	return

/**
 * Causes items to scatter
 *
 * Arguments:
 * * I - Item to scatter
 */
/obj/item/weapon/tray/proc/do_scatter(obj/item/I)
	for(var/i in 1 to rand(1,2))
		if(I)
			step(I, pick(NORTH,SOUTH,EAST,WEST))
			sleep(rand(2,4))

/obj/item/weapon/tray/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/kitchen/rollingpin))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [I]!</span>")
			playsound(user, 'sound/effects/shieldbash.ogg', VOL_EFFECTS_MASTER)
			cooldown = world.time
	else
		return ..()

/obj/item/weapon/tray/pickup(mob/living/user)
	pickupitems(user, loc)

/**
 * Moves items from a turf to a tray
 *
  * Arguments:
 * * user - The mob that picks up items
 * * target - Target turf from which items are gonna be taken
 */
/obj/item/weapon/tray/proc/pickupitems(mob/living/user, atom/target)
	var/turf/T = get_turf(target)
	if(T.density || !user.Adjacent(T))
		return
	for(var/obj/item/I in T)
		if(I != src && !I.anchored && is_type_in_typecache(I, tray_whitelisted_items))
			if(holding_weight + I.w_class >= max_carry)
				break
			I.loc = src
			carrying.Add(I)
			add_overlay(image("icon" = I.icon, "icon_state" = I.icon_state, "layer" = 30 + I.layer))

/obj/item/weapon/tray/dropped(mob/user)
	set waitfor = FALSE
	..()
	sleep(1) // so the items would actually move to the new tray loc instead of under player
	if(slot_equipped) //to handle slot switching
		return
	if(!isturf(loc)) //to stop items from dropping when tray dropped inside of a storage
		return
	dropitems(user, loc)

/**
 * Moves items from a turf to a tray
 *
  * Arguments:
 * * user - The mob that drops items
 * * target - Target turf on which items are gonna be dropped
 */
/obj/item/weapon/tray/proc/dropitems(mob/living/user, atom/target)
	var/turf/T = get_turf(target)
	if(T.density || !user.Adjacent(T))
		return
	for(var/obj/item/I in carrying)
		holding_weight -= I.w_class
		I.forceMove(T)
		cut_overlay(image("icon" = I.icon, "icon_state" = I.icon_state, "layer" = 30 + I.layer))
		carrying.Remove(I)

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
