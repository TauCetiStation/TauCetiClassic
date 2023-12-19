/* Tables and Racks
 * Contains:
 *		Tables
 *		Wooden tables
 *		Reinforced tables
 *		Racks
 */


/*
 * Tables
 */
/obj/structure/table
	name = "table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	icon = 'icons/obj/smooth_structures/table.dmi'
	icon_state = "box"
	density = TRUE
	anchored = TRUE
	layer = CONTAINER_STRUCTURE_LAYER
	throwpass = 1	//You can throw objects over this, despite it's density.")
	climbable = TRUE
	smooth = SMOOTH_TRUE

	max_integrity = 100
	resistance_flags = CAN_BE_HIT

	var/parts = /obj/item/weapon/table_parts
	var/flipped = 0
	var/flipable = TRUE
	var/canconnect = TRUE

/obj/structure/table/atom_init()
	. = ..()
	for(var/obj/structure/table/T in loc)
		if(T != src)
			warning("Found stacked table at [COORD(src)] while initializing map.")
			QDEL_IN(T, 0)

	if(flipable)
		verbs += /obj/structure/table/proc/do_flip

	if(flipped)
		update_icon()
		update_adjacent()

	AddComponent(/datum/component/clickplace)

/obj/structure/table/Destroy()
	if(flipped)
		update_adjacent()
	return ..()

/obj/structure/table/proc/update_adjacent()
	for(var/direction in alldirs)
		var/obj/structure/table/T = locate() in get_step(src, direction)
		if(T)
			T.update_icon()

/obj/structure/table/update_icon()
	if(flipped)
		smooth = SMOOTH_FALSE

		var/type = 0
		var/tabledirs = 0
		for(var/direction in list(turn(dir, 90), turn(dir, -90)) )
			var/obj/structure/table/T = locate() in get_step(src, direction)
			if (canconnect && !QDELETED(T) && T.flipped && src.type == T.type && T.canconnect && T.dir == dir)
				type++
				tabledirs |= direction

		var/base = "table"
		if (istype(src, /obj/structure/table/woodentable/poker))
			base = "poker"
		else if (istype(src, /obj/structure/table/woodentable))
			base = "wood"

		icon_state = "[base]flip[type]"
		if (type == 1)
			if (tabledirs & turn(dir, 90))
				icon_state = icon_state + "-"
			if (tabledirs & turn(dir, -90))
				icon_state = icon_state + "+"
	else
		smooth = initial(smooth)
		queue_smooth_neighbors(src)
		queue_smooth(src)

/obj/structure/table/airlock_crush_act()
	deconstruct(TRUE)

/obj/structure/table/attack_paw(mob/user)
	if(HULK in user.mutations)
		user.do_attack_animation(src)
		user.SetNextMove(CLICK_CD_MELEE)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		visible_message("<span class='danger'>[user] smashes the [src] apart!</span>")
		deconstruct(TRUE)

/obj/structure/table/attack_alien(mob/user)
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	visible_message("<span class='danger'>[user] slices [src] apart!</span>")
	if(istype(src, /obj/structure/table/glass))
		deconstruct(FALSE)
	else
		deconstruct(TRUE)

/obj/structure/table/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash)
		..()
		playsound(user, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		deconstruct(TRUE)

/obj/structure/table/attack_hand(mob/user)
	if(HULK in user.mutations)
		user.SetNextMove(CLICK_CD_MELEE)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		deconstruct(TRUE)

/obj/structure/table/attack_tk() // no telehulk sorry
	return FALSE

/obj/structure/table/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover,/obj/item/projectile))
		return (check_cover(mover,target))
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	if(iscarbon(mover) && mover.checkpass(PASSCRAWL))
		mover.layer = 2.7
		return 1
	if(istype(mover) && HAS_TRAIT(mover, TRAIT_ARIBORN))
		return 1
	if(locate(/obj/structure/table) in get_turf(mover))
		return 1
	if (flipped)
		if (get_dir(loc, target) == dir)
			return !density
		else
			return 1
	return 0

//checks if projectile 'P' from turf 'from' can hit whatever is behind the table. Returns 1 if it can, 0 if bullet stops.
/obj/structure/table/proc/check_cover(obj/item/projectile/P, turf/from)
	var/turf/cover = flipped ? get_turf(src) : get_step(loc, get_dir(from, loc))
	if (get_dist(P.starting, loc) <= 1) //Tables won't help you if people are THIS close
		return 1
	if (get_turf(P.original) == cover)
		var/chance = 20
		if (!flipable)
			chance += 20	//reinforced table covers legs so 20 common chance + lying 20 chance
		if (ismob(P.original))
			var/mob/M = P.original
			if (M.lying)
				if(!flipable)
					chance = 100				//reinforced table is REINFORCED so it cant be penetrated
				else
					chance += 20				//Lying down lets you catch less bullets
		if(flipped)
			if(get_dir(loc, from) == dir)	//Flipped tables catch mroe bullets
				chance += 20
			else
				return 1					//But only from one side
		if(prob(chance))
			return 0
	return 1

/obj/structure/table/CheckExit(atom/movable/O, target)
	if(istype(O) && O.checkpass(PASSTABLE))
		return 1
	if(istype(O) && O.checkpass(PASSCRAWL))
		O.layer = 4.0
		return 1
	if (flipped)
		if (get_dir(loc, target) == dir)
			return !density
		else
			return 1
	return 1

/obj/structure/table/proc/laser_cut(obj/item/I, mob/user)
	user.do_attack_animation(src)
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src.loc)
	spark_system.start()
	playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)
	playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
	visible_message("<span class='notice'>[src] was sliced apart by [user]!</span>", "<span class='notice'>You hear [src] coming apart.</span>")
	user.SetNextMove(CLICK_CD_MELEE)
	deconstruct(TRUE)

/obj/structure/table/reinforced/laser_cut(obj/item/I, mob/user)
	user.do_attack_animation(src)
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src.loc)
	spark_system.start()
	playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)
	playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
	to_chat(user, "<span class='notice'>You tried to slice through [src] but [I] is too weak.</span>")
	user.SetNextMove(CLICK_CD_MELEE)

// React to tools attacking src.
/obj/structure/table/proc/attack_tools(obj/item/I, mob/user)
	if(iswrenching(I))
		if(user.is_busy(src))
			return FALSE
		to_chat(user, "<span class='notice'>You are now disassembling \the [src].</span>")
		if(I.use_tool(src, user, 50, volume = 50))
			deconstruct(TRUE)
		return TRUE
	return FALSE

/obj/structure/table/attacked_by(obj/item/attacking_item, mob/living/user)
	if(istype(attacking_item, /obj/item/weapon/melee/energy) || istype(attacking_item, /obj/item/weapon/pen/edagger)  || istype(attacking_item,/obj/item/weapon/dualsaber))
		if(attacking_item.force > 3)
			laser_cut(attacking_item, user)
			return TRUE
	..()

/obj/structure/table/attackby(obj/item/W, mob/user, params)
	if(attack_tools(W, user))
		return TRUE

	return ..()

/obj/structure/table/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
			else
				playsound(loc, 'sound/weapons/tap.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 40, TRUE)

/obj/structure/table/deconstruct(disassembled = TRUE)
	if(flags & NODECONSTRUCT)
		return ..()
	var/obj/item/weapon/table_parts/t_parts = new parts(loc)
	if(disassembled)
		transfer_fingerprints_to(t_parts)
	else
		t_parts.deconstruct(FALSE)
	..()

/obj/structure/table/proc/straight_table_check(direction)
	var/obj/structure/table/T
	for(var/angle in list(-90,90))
		T = locate() in get_step(src.loc,turn(direction,angle))
		if(T && !T.flipped)
			return 0
	T = locate() in get_step(src.loc,direction)
	if (!T || T.flipped)
		return 1
	if (istype(T,/obj/structure/table/reinforced))
		var/obj/structure/table/reinforced/R = T
		if (R.status == 2)
			return 0
	return T.straight_table_check(direction)

/obj/structure/table/proc/do_flip()
	set name = "Flip table"
	set desc = "Flips a non-reinforced table."
	set category = "Object"
	set src in oview(1)

	if (!can_touch(usr) || ismouse(usr))
		return

	if(!flip(get_cardinal_dir(usr,src)))
		to_chat(usr, "<span class='notice'>It won't budge.</span>")
		return

	usr.visible_message("<span class='warning'>[usr] flips \the [src]!</span>")

	if(climbable)
		structure_shaken()

	return

/obj/structure/table/proc/unflipping_check(direction)
	for(var/mob/M in oview(src,0))
		return 0

	var/list/L = list()
	if(direction)
		L.Add(direction)
	else
		L.Add(turn(src.dir,-90))
		L.Add(turn(src.dir,90))
	for(var/new_dir in L)
		var/obj/structure/table/T = locate() in get_step(src.loc,new_dir)
		if(T)
			if(T.flipped && T.dir == src.dir && !T.unflipping_check(new_dir))
				return 0
	return 1

/obj/structure/table/proc/do_put()
	set name = "Put table back"
	set desc = "Puts flipped table back."
	set category = "Object"
	set src in oview(1)
	if(ismouse(usr))
		return
	if (!can_touch(usr))
		return

	if (!unflipping_check())
		to_chat(usr, "<span class='notice'>It won't budge.</span>")
		return
	unflip()

/obj/structure/table/proc/flip(direction)
	if( !straight_table_check(turn(direction,90)) || !straight_table_check(turn(direction,-90)) )
		return 0

	verbs -=/obj/structure/table/proc/do_flip
	verbs +=/obj/structure/table/proc/do_put

	var/list/targets = list(get_step(src,dir),get_step(src,turn(dir, 45)),get_step(src,turn(dir, -45)))
	for (var/atom/movable/A in get_turf(src))
		if (!A.anchored)
			A.throw_at(pick(targets),1,1)

	set_dir(direction)
	if(dir != NORTH)
		layer = 5
	flipped = 1
	flags |= ON_BORDER
	for(var/D in list(turn(direction, 90), turn(direction, -90)))
		var/obj/structure/table/T = locate() in get_step(src, D)
		if(T && !T.flipped && type == T.type)
			T.flip(direction)
	update_icon()
	update_adjacent()

	return 1

/obj/structure/table/proc/unflip()
	verbs -=/obj/structure/table/proc/do_put
	verbs +=/obj/structure/table/proc/do_flip

	layer = initial(layer)
	plane = initial(plane)
	flipped = 0
	flags &= ~ON_BORDER
	for(var/D in list(turn(dir, 90), turn(dir, -90)))
		var/obj/structure/table/T = locate() in get_step(loc, D)
		if(T && T.flipped && type == T.type && T.dir == dir)
			T.unflip()
	update_icon()
	update_adjacent()

	return 1

/*
 * Glass tables
 */
/obj/structure/table/glass
	name = "glass table"
	desc = "Looks fragile. You should totally flip it. It is begging for it."
	icon = 'icons/obj/smooth_structures/glass_table.dmi'
	parts = /obj/item/weapon/table_parts/glass
	max_integrity = 10

/obj/structure/table/glass/atom_init()
	. = ..()
	AddComponent(/datum/component/clickplace, , CALLBACK(src, PROC_REF(slam)))

/obj/structure/table/glass/flip(direction)
	if( !straight_table_check(turn(direction,90)) || !straight_table_check(turn(direction,-90)) )
		return 0

	set_dir(direction)
	if(dir != NORTH)
		layer = 5
	flipped = 1
	flags |= ON_BORDER
	for(var/D in list(turn(direction, 90), turn(direction, -90)))
		var/obj/structure/table/T = locate() in get_step(src,D)
		if(T && !T.flipped)
			T.flip(direction)

	shatter()

	return 1

/obj/structure/table/glass/proc/shatter()
	canconnect = FALSE
	update_adjacent()

	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	visible_message("<span class='warning'>[src] breaks!</span>", "<span class='danger'>You hear breaking glass.</span>")

	var/T = get_turf(src)
	new /obj/item/weapon/shard(T)
	qdel(src)

	var/list/targets = list(get_step(T, dir), get_step(T, turn(dir, 45)), get_step(T, turn(dir, -45)))
	for (var/atom/movable/A in T)
		if (!A.anchored)
			A.throw_at(pick(targets), 1, 1)

/obj/structure/table/glass/on_climb(mob/living/user)
	usr.forceMove(get_turf(src))
	if(check_break(user))
		usr.visible_message("<span class='warning'>[user] tries to climb onto \the [src], but breaks it!</span>")
	else
		..()

/obj/structure/table/glass/Crossed(atom/movable/AM)
	. = ..()
	check_break(AM)

/obj/structure/table/glass/proc/check_break(mob/living/M)
	if(istype(M) && (M.checkpass(PASSTABLE) || M.checkpass(PASSCRAWL)))
		return FALSE

	if(has_gravity(M) && ishuman(M))
		M.Stun(2)
		M.Weaken(5)
		shatter()
		return TRUE
	else
		return FALSE

/obj/structure/table/glass/proc/slam(obj/item/weapon/grab/G)
	var/mob/living/assailant = G.assailant
	var/mob/living/victim = G.affecting

	victim.Stun(2)
	victim.Weaken(5)
	visible_message("<span class='danger'>[assailant] slams [victim]'s face against \the [src], breaking it!</span>")
	playsound(src, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)

	victim.log_combat(assailant, "face-slammed against [name]")

	if(prob(30) && ishuman(victim))
		var/mob/living/carbon/human/H = victim
		var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
		var/obj/item/weapon/shard/S = new
		BP.embed(S)
		H.apply_damage(15, def_zone = BP_HEAD, damage_flags = DAM_SHARP|DAM_EDGE, used_weapon = S)
		H.emote("scream")
	else
		victim.apply_damage(15, def_zone = BP_HEAD)
	shatter()
	qdel(G)
	return TRUE

/obj/structure/table/glass/airlock_crush_act()
	shatter()

/obj/structure/table/glass/deconstruct(disassembled)
	if(flags & NODECONSTRUCT || disassembled)
		return ..()
	shatter()

/*
 * Wooden tables
 */
/obj/structure/table/woodentable
	name = "wooden table"
	desc = "Do not apply fire to this. Rumour says it burns easily."
	icon = 'icons/obj/smooth_structures/wooden_table.dmi'
	parts = /obj/item/weapon/table_parts/wood
	max_integrity = 50

/obj/structure/table/woodentable/poker //No specialties, Just a mapping object.
	name = "gambling table"
	desc = "A seedy table for seedy dealings in seedy places."
	icon = 'icons/obj/smooth_structures/poker_table.dmi'
	parts = /obj/item/weapon/table_parts/wood/poker
	max_integrity  = 50

/obj/structure/table/woodentable/fancy
	name = "fancy table"
	desc = "A standard metal table frame covered with an amazingly fancy, patterned cloth."
	icon = 'icons/obj/smooth_structures/fancy_table.dmi'
	canSmoothWith = list(/obj/structure/table/woodentable/fancy, /obj/structure/table/woodentable/fancy/black)
	parts = /obj/item/weapon/table_parts/wood/fancy
	flipable = FALSE

/obj/structure/table/woodentable/fancy/black
	icon = 'icons/obj/smooth_structures/fancy_black_table.dmi'
	parts = /obj/item/weapon/table_parts/wood/fancy/black

/*
 * Reinforced tables
 */
/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A version of the four legged table. It is stronger."
	icon = 'icons/obj/smooth_structures/reinforced_table.dmi'
	max_integrity = 200
	parts = /obj/item/weapon/table_parts/reinforced
	flipable = FALSE
	canSmoothWith = list(/obj/structure/table/reinforced, /obj/structure/table/reinforced/stall)

	var/status = 2

/obj/structure/table/reinforced/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover,/obj/item/projectile))
		return (check_cover(mover,target))
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	if(istype(mover) && HAS_TRAIT(mover, TRAIT_ARIBORN))
		return 1
	if(locate(/obj/structure/table) in get_turf(mover))
		return 1
	if (flipped)
		if (get_dir(loc, target) == dir)
			return !density
		else
			return 1
	return 0

/obj/structure/table/reinforced/flip(direction)
	if (status == 2)
		return 0
	else
		return ..()

/obj/structure/table/reinforced/attack_tools(obj/item/I, mob/user)
	if(iswelding(I))
		if(user.is_busy())
			return FALSE
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.use(0, user))
			if(status == 2)
				to_chat(user, "<span class='notice'>You are now strengthening \the [src].</span>")
				if(WT.use_tool(src, user, 50, volume = 50))
					to_chat(user, "<span class='notice'>You have weakened \the [src].</span>")
					src.status = 1
			else
				to_chat(user, "<span class='notice'>You are now strengthening \the [src].</span>")
				if(WT.use_tool(src, user, 50, volume = 50))
					to_chat(user, "<span class='notice'>You have strengthened \the [src].</span>")
					src.status = 2
			return TRUE
		return FALSE

	else if(status != 2 && iswrenching(I))
		if(user.is_busy(src))
			return FALSE
		to_chat(user, "<span class='notice'>You are now disassembling \the [src].</span>")
		if(I.use_tool(src, user, 50, volume = 50))
			deconstruct(TRUE)
		return TRUE

	return FALSE

/obj/structure/table/reinforced/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/door_control_frame))
		var/obj/item/door_control_frame/frame = W
		frame.try_build(src)
		return

	return ..()

/obj/lot_holder
	name = "lot holder"
	icon = 'icons/effects/32x32.dmi'
	icon_state = "blank"
	anchored = TRUE

	flags = ABSTRACT

	var/obj/structure/table/table_attached_to
	var/obj/item/held_Item

/obj/lot_holder/atom_init(mapload, obj/item/Item, obj/structure/table/Table)
	. = ..()

	table_attached_to = Table
	RegisterSignal(table_attached_to, list(COMSIG_PARENT_QDELETING), PROC_REF(destroy_lot_holder))
	RegisterSignal(held_Item, list(COMSIG_PARENT_QDELETING), PROC_REF(destroy_lot_holder))

	held_Item = Item
	Item.forceMove(src)

	add_overlay(Item)
	name = Item.name
	var/list/pricetag = Item.price_tag
	if(pricetag)
		name = "[name] ([pricetag["price"]]$)"

	var/old_invisibility = invisibility
	invisibility = INVISIBILITY_ABSTRACT
	VARSET_IN(src, invisibility, old_invisibility, PUTDOWN_ANIMATION_DURATION)

/obj/lot_holder/examine(mob/user)
	held_Item.examine(user)

/obj/lot_holder/Destroy()
	held_Item.forceMove(table_attached_to.loc)
	held_Item = null

	for(var/atom/movable/AM in contents)
		AM.forceMove(table_attached_to.loc)
	table_attached_to = null

	return ..()

/obj/lot_holder/proc/destroy_lot_holder()
	qdel(src)

/obj/lot_holder/container_resist()
	qdel(src)

/obj/lot_holder/attack_hand(mob/user)
	if(ishuman(user) && istype(held_Item, /obj/item/smallDelivery))
		var/mob/living/carbon/human/H = user
		var/obj/item/weapon/card/id/ID = H.get_idcard()
		if(ID && (global.access_cargo in ID.GetAccess()))
			var/obj/item/I = held_Item
			qdel(src)
			user.put_in_hands(I)
			return
	return ..()

/obj/lot_holder/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(held_Item, /obj/item/smallDelivery))
		return

	if(W.price_tag)
		var/list/item_click_params = params2list(params)
		if(!item_click_params || !item_click_params[ICON_X] || !item_click_params[ICON_Y])
			return
		item_click_params[ICON_X] = (pixel_x + world.icon_size * 0.5 + rand(-2, 2))
		item_click_params[ICON_Y] = (pixel_y + world.icon_size * 0.5 + rand(-2, 2))
		table_attached_to.attackby(W, user, list2params(item_click_params))
	else if(istype(W, /obj/item/weapon/card/id))
		table_attached_to.visible_message("<span class='info'>[user] прикладывает карту к столу.</span>")
		var/obj/item/weapon/card/id/Card = W
		scan_card(Card, user)
	else if(istype(W, /obj/item/device/pda) && W.GetID())
		table_attached_to.visible_message("<span class='info'>[user] прикладывает КПК к столу.</span>")
		var/obj/item/weapon/card/id/Card = W.GetID()
		scan_card(Card, user)
	else if(istype(W, /obj/item/weapon/ewallet))
		var/obj/item/weapon/ewallet/EW = W
		table_attached_to.visible_message("<span class='info'>[user] прикладывает чип к столу.</span>")
		scan_ewallet(EW, user)
	else
		return ..()


/obj/lot_holder/proc/pay_with_account(datum/money_account/Buyer, mob/user)
	if(!Buyer)
		return

	if(Buyer.suspended)
		table_attached_to.visible_message("[bicon(table_attached_to)]<span class='warning'>Оплачивающий аккаунт заблокирован.</span>")
		return

	var/datum/money_account/Seller = get_account(held_Item.price_tag["account"])
	var/cost = held_Item.price_tag["price"]

	if(cost > 0 && Seller && Buyer != Seller)
		if(Seller.suspended)
			table_attached_to.visible_message("[bicon(table_attached_to)]<span class='warning'>Подключённый аккаунт заблокирован.</span>")
			return

		if(cost <= Buyer.money)
			charge_to_account(Buyer.account_number, Seller.owner_name, "Покупка [held_Item.name]", "Прилавок", -cost)
			charge_to_account(Seller.account_number, Buyer.owner_name, "Прибыль за продажу [held_Item.name]", "Прилавок", cost)

		else
			table_attached_to.visible_message("[bicon(table_attached_to)]<span class='warning'>Недостаточно средств!</span>")
			return

	held_Item.remove_price_tag()
	qdel(src)

/obj/lot_holder/proc/scan_card(obj/item/weapon/card/id/Card, mob/user)
	var/datum/money_account/Buyer = attempt_account_access_with_user_input(Card.associated_account_number, ACCOUNT_SECURITY_LEVEL_MAXIMUM, user)
	if(user.incapacitated() || !Adjacent(user))
		return
	if(!Buyer)
		to_chat(user, "[bicon(table_attached_to)]<span class='warning'>Неверный ПИН-код!</span>")
		return
	pay_with_account(Buyer, user)

/obj/lot_holder/proc/scan_ewallet(obj/item/weapon/ewallet/EW, mob/user)
	pay_with_account(get_account(EW.account_number), user)

/obj/structure/table/reinforced/stall
	name = "stall table"
	desc = "A market stall table equipped with magnetic grip."
	icon = 'icons/obj/smooth_structures/stall_table.dmi'
	max_integrity = 200
	parts = /obj/item/weapon/table_parts/stall
	flipable = FALSE
	canSmoothWith = list(/obj/structure/table/reinforced, /obj/structure/table/reinforced/stall)

/obj/structure/table/reinforced/stall/atom_init()
	. = ..()
	AddComponent(/datum/component/clickplace, CALLBACK(src, PROC_REF(try_magnet)))

/obj/structure/table/reinforced/stall/proc/try_magnet(atom/A, obj/item/I, mob/user, params)
	if(I.price_tag || istype(I, /obj/item/smallDelivery))
		if(istype(I, /obj/item/smallDelivery))
			var/obj/item/smallDelivery/package = I
			if(!package.lot_lock_image)
				return
		magnet_item(I, params)

/obj/structure/table/reinforced/stall/proc/magnet_item(obj/item/I, list/params)
	if(I.loc != get_turf(src))
		return

	var/obj/lot_holder/LH = new(loc, I, src)

	var/list/click_params = params2list(params)
	//Center the icon where the user clicked.
	if(!click_params || !click_params[ICON_X] || !click_params[ICON_Y])
		return

	var/icon_size = world.icon_size
	var/half_icon_size = icon_size * 0.5

	var/p_x = text2num(click_params[ICON_X]) + pixel_x
	var/p_y = text2num(click_params[ICON_Y]) + pixel_y

	p_x = clamp(p_x, 0, icon_size) - half_icon_size - I.pixel_x
	p_y = clamp(p_y, 0, icon_size) - half_icon_size - I.pixel_y

	LH.pixel_x = p_x
	LH.pixel_y = p_y

/*
 * Racks
 */
/obj/structure/rack // TODO subtype of table?
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	density = TRUE
	anchored = TRUE
	layer = CONTAINER_STRUCTURE_LAYER
	throwpass = 1	//You can throw objects over this, despite it's density.
	climbable = TRUE
	var/parts = /obj/item/weapon/rack_parts

	max_integrity = 20
	resistance_flags = CAN_BE_HIT

/obj/structure/rack/atom_init()
	. = ..()
	AddComponent(/datum/component/clickplace)

/obj/structure/rack/airlock_crush_act()
	deconstruct(TRUE)

/obj/structure/rack/CanPass(atom/movable/mover, turf/target, height=0)
	if(src.density == 0) //Because broken racks -Agouri |TODO: SPRITE!|
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	if(istype(mover) && HAS_TRAIT(mover, TRAIT_ARIBORN))
		return 1
	else
		return 0

/obj/structure/rack/attackby(obj/item/weapon/W, mob/user)
	if (iswrenching(W))
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		deconstruct(TRUE)
		return

	. = ..()
	if(!.)
		return FALSE

	var/can_cut = FALSE
	if(istype(W, /obj/item/weapon/melee/energy))
		var/obj/item/weapon/melee/energy/E = W
		can_cut = E.active
	else if(istype(W, /obj/item/weapon/dualsaber))
		var/obj/item/weapon/dualsaber/D = W
		can_cut = HAS_TRAIT(D, TRAIT_DOUBLE_WIELDED)

	if(!can_cut)
		return ..()

	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)

	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, loc)
	spark_system.start()

	playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)
	playsound(src, "sparks", VOL_EFFECTS_MASTER)
	visible_message("<span class='notice'>[src] was sliced apart by [user]!</span>", "<span class='notice'> You hear [src] coming apart.</span>")
	deconstruct(TRUE)

/obj/structure/rack/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
			else
				playsound(loc, 'sound/weapons/tap.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 40, TRUE)

/obj/structure/rack/deconstruct(disassembled)
	if(flags & NODECONSTRUCT)
		return ..()
	var/obj/item/weapon/rack_parts/r_parts = new (loc)
	if(disassembled)
		transfer_fingerprints_to(r_parts)
	else
		r_parts.deconstruct(FALSE)
	..()

/obj/structure/rack/attack_hand(mob/user)
	if(HULK in user.mutations)
		user.SetNextMove(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		deconstruct(TRUE)

/obj/structure/rack/attack_paw(mob/user)
	if(HULK in user.mutations)
		user.SetNextMove(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		deconstruct(TRUE)

/obj/structure/rack/attack_alien(mob/user)
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	visible_message("<span class='danger'>[user] slices [src] apart!</span>")
	deconstruct(TRUE)

/obj/structure/rack/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash)
		..()
		playsound(user, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
		user.do_attack_animation(src)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		deconstruct(TRUE)

/obj/structure/rack/attack_tk() // no telehulk sorry
	return FALSE
