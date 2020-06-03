var/global/list/scrap_base_cache = list()


/obj/structure/scrap
	name = "scrap pile"
	desc = "Pile of industrial debris. It could use a shovel and pair of hands in gloves. "
	appearance_flags = TILE_BOUND
	anchored = 1
	opacity = 0
	density = 0
	var/loot_generated = 0
	var/icontype = "general"
	icon_state = "small"
	icon = 'icons/obj/structures/scrap/base.dmi'
	var/obj/item/weapon/storage/internal/updating/loot	//the visible loot
	var/loot_min = 3
	var/loot_max = 5
	var/list/loot_list = list(
		/obj/random/materials/rods_scrap,
		/obj/random/materials/plastic_scrap,
		/obj/random/materials/metal_scrap,
		/obj/random/materials/glass_scrap,
		/obj/random/materials/plasteel_scrap,
		/obj/random/materials/wood_scrap,
		/obj/item/weapon/shard
	)
	var/dig_amount = 7
	var/parts_icon = 'icons/obj/structures/scrap/trash.dmi'
	var/base_min = 5	//min and max number of random pieces of base icon
	var/base_max = 8
	var/base_spread = 12 //limits on pixel offsets of base pieces
	var/big_item_chance = 0
	var/obj/big_item
	var/list/ways = list("pokes around", "digs through", "rummages through", "goes through","picks through")





/obj/structure/scrap/proc/make_cube()
	var/obj/container = new /obj/structure/scrap_cube(loc, loot_max)
	forceMove(container)

/obj/structure/scrap/atom_init()
	. = ..()
	update_icon(1)


/obj/effect/scrapshot
	name = "This thins shoots scrap everywhere with a delay"
	desc = "no data"
	invisibility = 101
	anchored = 1
	density = 0

/obj/effect/scrapshot/atom_init(mapload, severity = 1)
	..()
	switch(severity)
		if(1)
			for(var/i in 1 to 12)
				var/projtype = pick(/obj/item/stack/rods, /obj/item/weapon/shard)
				var/obj/item/projectile = new projtype(loc)
				projectile.throw_at(locate(loc.x + rand(40) - 20, loc.y + rand(40) - 20, loc.z), 81, pick(1,3,80,80))
		if(2)
			for(var/i in 1 to 4)
				var/projtype = pick(subtypesof(/obj/item/trash))
				var/obj/item/projectile = new projtype(loc)
				projectile.throw_at(locate(loc.x + rand(10) - 5, loc.y + rand(10) - 5, loc.z), 3, 1)
	return INITIALIZE_HINT_QDEL


/obj/structure/scrap/ex_act(severity)
	set waitfor = FALSE
	if (prob(25))
		new /obj/effect/effect/smoke(src.loc)
	switch(severity)
		if(1)
			new /obj/effect/scrapshot(src.loc, 1)
			dig_amount = 0
		if(2)
			new /obj/effect/scrapshot(src.loc, 2)
			dig_amount = dig_amount / 3
		if(3)
			dig_amount = dig_amount / 2
	if(dig_amount < 4)
		qdel(src)
	else
		update_icon(1)

/obj/structure/scrap/proc/make_big_loot()
	if(prob(big_item_chance))
		var/obj/randomcatcher/CATCH = new /obj/randomcatcher(src)
		big_item = CATCH.get_item(/obj/random/structures/structure_pack)
		if(big_item)
			big_item.forceMove(src)
			if(prob(66))
				big_item.make_old()
		qdel(CATCH)


/obj/structure/scrap/proc/try_make_loot()
	if(loot_generated)
		return
	loot_generated = 1
	if(!big_item)
		make_big_loot()
	var/amt = rand(loot_min, loot_max)
	for(var/x = 1 to amt)
		var/loot_path = pick(loot_list)
		new loot_path(src)
	for(var/obj/item/I in contents)
		if(prob(66))
			I.make_old()
	loot = new(src)
	loot.set_slots(slots = 7, slot_size = ITEM_SIZE_HUGE)
	shuffle_loot()

/obj/structure/scrap/Destroy()
	for (var/obj/item in loot)
		qdel(item)
	if(big_item)
		qdel(big_item)
	return ..()

//stupid shard copypaste
/obj/structure/scrap/Crossed(atom/movable/AM)
	if(ismob(AM) &&  !HAS_TRAIT(AM, TRAIT_LIGHT_STEP))
		var/mob/M = AM
		playsound(src, 'sound/effects/glass_step.ogg', VOL_EFFECTS_MASTER)
		if(ishuman(M) && !M.buckled)
			var/mob/living/carbon/human/H = M
			if(H.species.flags[IS_SYNTHETIC])
				return
			if( !H.shoes && ( !H.wear_suit || !(H.wear_suit.body_parts_covered & LEGS) ) )
				var/obj/item/organ/external/BP = H.bodyparts_by_name[pick(BP_L_LEG , BP_R_LEG)]
				if(BP.is_robotic())
					return
				to_chat(M, "<span class='danger'>You step on the sharp debris!</span>")
				H.Weaken(3)
				BP.take_damage(5, 0)
				H.reagents.add_reagent("toxin", pick(prob(50);0,prob(50);5,prob(10);10,prob(1);25))
				H.updatehealth()
	. = ..()

/obj/structure/scrap/proc/shuffle_loot()
	try_make_loot()
	loot.close_all()
	for(var/A in loot)
		loot.remove_from_storage(A,src)
	if(contents.len)
		contents = shuffle(contents)
		var/num = rand(1,loot_min)
		for(var/obj/item/O in contents)
			if(O == loot || O == big_item)
				continue
			if(num == 0)
				break
			O.forceMove(loot)
			num--
	update_icon()

/obj/structure/scrap/proc/randomize_image(image/I)
	I.pixel_x = rand(-base_spread,base_spread)
	I.pixel_y = rand(-base_spread,base_spread)
	var/matrix/M = matrix()
	M.Turn(pick(0,90.180,270))
	I.transform = M
	return I

/obj/structure/scrap/update_icon(rebuild_base=0)
	if(rebuild_base)
		var/ID = rand(40)
		if(!scrap_base_cache["[icontype][icon_state][ID]"])
			var/num = rand(base_min,base_max)
			var/image/base_icon = image(icon, icon_state = icon_state)
			for(var/i=1 to num)
				var/image/I = image(parts_icon,pick(icon_states(parts_icon)))
				I.color = pick("#996633", "#663300", "#666666", "")
				base_icon.add_overlay(randomize_image(I))
			scrap_base_cache["[icontype][icon_state][ID]"] = base_icon
		add_overlay(scrap_base_cache["[icontype][icon_state][ID]"])
	if(loot_generated)
		underlays.Cut()
		for(var/obj/O in loot.contents)
			var/image/I = image(O.icon,O.icon_state)
			I.color = O.color
			underlays |= randomize_image(I)
	if(big_item)
		var/image/I = image(big_item.icon,big_item.icon_state)
		I.color = big_item.color
		underlays |= I

/obj/structure/scrap/proc/hurt_hand(mob/user)
	if(prob(50))
		if(!ishuman(user))
			return 0
		var/mob/living/carbon/human/victim = user
		if(victim.species.flags[IS_SYNTHETIC])
			return 0
		if(victim.gloves)
			if(istype(victim.gloves, /obj/item/clothing/gloves))
				var/obj/item/clothing/gloves/G = victim.gloves
				if(G.protect_fingers)
					return
		var/obj/item/organ/external/BP = victim.bodyparts_by_name[pick(BP_L_ARM , BP_R_ARM)]
		if(!BP)
			return 0
		if(BP.is_robotic())
			return 0
		if(victim.species.flags[NO_MINORCUTS])
			return 0
		to_chat(user, "<span class='danger'>Ouch! You cut yourself while picking through \the [src].</span>")
		BP.take_damage(5, null, DAM_SHARP | DAM_EDGE, "Sharp debris")
		victim.reagents.add_reagent("toxin", pick(prob(50);0,prob(50);5,prob(10);10,prob(1);25))
		if(victim.species.flags[NO_PAIN]) // So we still take damage, but actually dig through.
			return 0
		return 1
	return 0

/obj/structure/scrap/attack_hand(mob/user)
	user.SetNextMove(CLICK_CD_MELEE)
	if(hurt_hand(user))
		return
	try_make_loot()
	loot.open(user)
	..()

/obj/structure/scrap/attack_paw(mob/user)
	loot.open(user)
	..(user)

/obj/structure/scrap/MouseDrop(obj/over_object)
	..(over_object)

/obj/structure/scrap/proc/dig_out_lump(newloc = loc, var/hard_dig = 0)
	src.dig_amount--
	if(src.dig_amount <= 0)
		visible_message("<span class='notice'>\The [src] is cleared out!</span>")
		if(!hard_dig && big_item)
			big_item.forceMove(get_turf(src))
			big_item = null
		qdel(src)
		return 0
	else
		new /obj/item/weapon/scrap_lump(newloc)
		return 1

/obj/structure/scrap/attackby(obj/item/W, mob/user)
	var/do_dig = 0
	user.SetNextMove(CLICK_CD_INTERACT)
	if(istype(W,/obj/item/weapon/shovel))
		do_dig = 30
	if(istype(W,/obj/item/stack/rods))
		do_dig = 50
	if(do_dig  && !user.is_busy())
		user.do_attack_animation(src)
		if(W.use_tool(src, user, do_dig))
			visible_message("<span class='notice'>\The [user] [pick(ways)] \the [src].</span>")
			shuffle_loot()
			dig_out_lump(user.loc, 0)


/obj/structure/scrap/large
	name = "large scrap pile"
	opacity = 1
	density = 1
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16

//todo: icon?
/obj/structure/scrap/newyear
	loot_list = list(
		/obj/random/plushie,
		/obj/random/plushie,
		/obj/random/randomfigure,
		/obj/random/randomfigure,
		/obj/random/randomfigure,
		/obj/random/randomtoy,
		/obj/random/randomtoy,
		/obj/random/randomtoy,
		/obj/random/cloth/ny_random_cloth,
		/obj/random/cloth/ny_random_cloth,
	)

/obj/structure/scrap/medical
	icontype = "medical"
	name = "medical refuse pile"
	desc = "Pile of medical refuse. They sure don't cut expenses on these. "
	parts_icon = 'icons/obj/structures/scrap/medical_trash.dmi'
	loot_list = list(
		/obj/random/meds/medical_supply,
		/obj/random/meds/medical_supply,
		/obj/random/meds/medical_supply,
		/obj/random/meds/medical_supply,
		/obj/random/materials/rods_scrap,
		/obj/item/weapon/shard
	)

/obj/structure/scrap/vehicle
	icontype = "vehicle"
	name = "industrial debris pile"
	desc = "Pile of used machinery. You could use tools from this to build something."
	parts_icon = 'icons/obj/structures/scrap/vehicle.dmi'
	loot_list = list(
		/obj/random/tools/tech_supply/guaranteed,
		/obj/random/tools/tech_supply/guaranteed,
		/obj/random/tools/tech_supply/guaranteed,
		/obj/random/tools/tech_supply/guaranteed,
		/obj/random/tools/tech_supply/guaranteed,
		/obj/random/materials/rods_scrap,
		/obj/random/materials/metal_scrap,
		/obj/item/weapon/shard
	)

/obj/structure/scrap/food
	icontype = "food"
	name = "food trash pile"
	desc = "Pile of thrown away food. Someone sure have lots of spare food while children on Mars are starving."
	parts_icon = 'icons/obj/structures/scrap/food_trash.dmi'
	loot_list = list(
		/obj/random/foods/food_without_garbage,
		/obj/random/foods/food_without_garbage,
		/obj/random/foods/food_without_garbage,
		/obj/random/foods/food_without_garbage,
		/obj/random/foods/food_without_garbage,
		/obj/item/weapon/shard,
		/obj/random/materials/rods_scrap
	)

/obj/structure/scrap/guns
	icontype = "guns"
	name = "gun refuse pile"
	desc = "Pile of military supply refuse. Who thought it was a clever idea to throw that out?"
	parts_icon = 'icons/obj/structures/scrap/guns_trash.dmi'
	loot_list = list(
		/obj/preset/storage/weapons/random,
		/obj/preset/storage/weapons/random,
		/obj/random/tools/powercell,
		/obj/random/guns/energy_weapon,
		/obj/item/toy/gun,
		/obj/item/toy/crossbow,
		/obj/item/weapon/shard,
		/obj/random/materials/metal_scrap,
		/obj/random/materials/rods_scrap
	)

/obj/structure/scrap/science
	icontype = "science"
	name = "scientific trash pile"
	desc = "Pile of refuse from research department."
	parts_icon = 'icons/obj/structures/scrap/science.dmi'
	loot_list = list(
		/obj/random/science/science_supply
	)

/obj/structure/scrap/cloth
	icontype = "cloth"
	name = "cloth pile"
	desc = "Pile of second hand clothing for charity."
	parts_icon = 'icons/obj/structures/scrap/cloth.dmi'
	loot_list = list(
		/obj/random/cloth/random_cloth
	)

/obj/structure/scrap/syndie
	icontype = "syndie"
	name = "strange pile"
	desc = "Pile of left magbots, broken teleports and phoron tanks, jetpacks, random stations blueprints, soap, burned rcds, and meat with orange fur?"
	parts_icon = 'icons/obj/structures/scrap/syndie.dmi'
	loot_min = 2
	loot_max = 4
	loot_list = list(
		/obj/random/syndie/fullhouse,
		/obj/random/syndie/fullhouse,
		/obj/random/syndie/fullhouse,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat/corgi,
		/obj/item/brain,
		/obj/item/weapon/tank/phoron
	)


/obj/structure/scrap/poor
	icontype = "poor"
	name = "mixed rubbish"
	desc = "Pile of mixed rubbish. Useless and rotten, mostly."
	parts_icon = 'icons/obj/structures/scrap/all_mixed.dmi'
	loot_list = list(
		/obj/random/misc/all,
		/obj/random/misc/all,
		/obj/random/misc/pack,
		/obj/random/misc/pack,
		/obj/item/weapon/shard,
		/obj/random/materials/rods_scrap
	)

/obj/structure/scrap/poor/large
	name = "large mixed rubbish"
	opacity = 1
	density = 1
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	big_item_chance = 40

/obj/structure/scrap/vehicle/large
	name = "large industrial debris pile"
	opacity = 1
	density = 1
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/food/large
	name = "large food trash pile"
	opacity = 1
	density = 1
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/medical/large
	name = "large medical refuse pile"
	opacity = 1
	density = 1
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/guns/large
	name = "large gun refuse pile"
	opacity = 1
	density = 1
	icon_state = "big"
	loot_min = 10
	loot_max = 15
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/science/large
	name = "large scientific trash pile"
	opacity = 1
	density = 1
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/cloth/large
	name = "large cloth pile"
	opacity = 1
	density = 1
	icon_state = "big"
	loot_min = 8
	loot_max = 14
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/syndie/large
	name = "large strange pile"
	opacity = 1
	density = 1
	icon_state = "big"
	loot_min = 4
	loot_max = 12
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/poor/structure
	name = "large mixed rubbish"
	opacity = 1
	density = 1
	icon_state = "med"
	loot_min = 3
	loot_max = 6
	dig_amount = 3
	base_min = 3
	base_max = 6
	big_item_chance = 100

//obj/structure/scrap/poor/structure/atom_init() //removed big loot generation from structure scrap
//	make_big_loot()
//	..()
//	return INITIALIZE_HINT_LATELOAD
//
//obj/structure/scrap/poor/structure/atom_init_late()
//	make_big_loot()

/obj/structure/scrap/poor/structure/update_icon() //make big trash icon for this
	..()
	if(!loot_generated)
		underlays += image(icon, icon_state = "underlay_big")

/obj/structure/scrap/poor/structure/make_big_loot()
	..()
	if(big_item)
		visible_message("<span class='notice'>\The [src] reveals [big_item] underneath the trash!</span>")

/obj/item/weapon/storage/internal/updating/update_icon()
	if(master_item)
		master_item.update_icon()

/obj/item/weapon/storage/internal/updating/remove_from_storage(obj/item/W, atom/new_location, NoUpdate = FALSE)
	if(..())
		SSjunkyard.add_junk_to_stats("[W.type]")
