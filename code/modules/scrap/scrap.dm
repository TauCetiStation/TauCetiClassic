/obj/structure/scrap
	name = "scrap pile"
	desc = "Pile of industrial debris. It could use a shovel and pair of hands in gloves. "
	anchored = 1
	opacity = 0
	density = 0
	icon_state = "small"
	icon = 'icons/obj/structures/scrap/base.dmi'
	var/obj/item/weapon/storage/internal/updating/loot	//the visible loot
	var/loot_min = 3
	var/loot_max = 5
	var/list/loot_list = list(
		/obj/item/stack/rods/scrap,
		/obj/item/stack/sheet/mineral/plastic/scrap,
		/obj/item/stack/sheet/metal/scrap,
		/obj/item/stack/sheet/glass/scrap,
		/obj/item/stack/sheet/plasteel/scrap,
		/obj/item/stack/sheet/wood/scrap,
		/obj/item/weapon/shard
		)
	var/dig_amount = 7
	var/parts_icon = 'icons/obj/structures/scrap/trash.dmi'
	var/base_min = 4	//min and max number of random pieces of base icon
	var/base_max = 7
	var/base_spread = 8 //limits on pixel offsets of base pieces
	var/list/ways = list("pokes around", "digs through", "rummages through", "goes through","picks through")

/obj/structure/scrap/New()
	var/amt = rand(loot_min, loot_max)
	for(var/x = 1 to amt)
		var/loot_path = pick(loot_list)
		new loot_path(src)
	for(var/obj/item/loot in contents)
		if(prob(80)) loot.make_old()
	loot = new(src)
	loot.max_w_class = 5
	shuffle_loot()
	update_icon(1)
	..()
/obj/structure/scrap/Destroy()
	for (var/obj/item in loot)
		qdel(item)
	return ..()

//stupid shard copypaste
/obj/structure/scrap/Crossed(AM as mob|obj)
	if(ismob(AM))
		var/mob/M = AM
		playsound(src.loc, 'sound/effects/glass_step.ogg', 50, 1)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species.flags & IS_SYNTHETIC)
				return
			if( !H.shoes && ( !H.wear_suit || !(H.wear_suit.body_parts_covered & FEET) ) )
				var/datum/organ/external/affecting = H.get_organ(pick("l_foot", "r_foot"))
				if(affecting.status & ORGAN_ROBOT)
					return
				M << "<span class='danger'>You step on the sharp debris!</span>"
				H.Weaken(3)
				affecting.take_damage(5, 0)
				H.reagents.add_reagent("toxin", pick(prob(50);0,prob(50);5,prob(10);10,prob(1);25))
				H.updatehealth()
	..()

/obj/structure/scrap/proc/shuffle_loot()
	loot.close_all()
	for(var/A in loot)
		loot.remove_from_storage(A,src)
	if(contents.len)
		contents = shuffle(contents)
		var/num = rand(1,loot_min)
		for(var/obj/item/O in contents)
			if(O == loot)
				continue
			if(num == 0)
				break
			O.forceMove(loot)
			num--
	update_icon()

/obj/structure/scrap/proc/randomize_image(var/image/I)
	I.pixel_x = rand(-base_spread,base_spread)
	I.pixel_y = rand(-base_spread,base_spread)
	var/matrix/M = matrix()
	M.Turn(pick(0,90.180,270))
	I.transform = M
	return I

/obj/structure/scrap/update_icon(var/rebuild_base=0)
	if(rebuild_base)
		overlays.Cut()
		var/num = rand(base_min,base_max)
		for(var/i=1 to num)
			var/image/I = image(parts_icon,pick(icon_states(parts_icon)))
			I.color = pick("#996633", "#663300", "#666666", "")
			overlays |= randomize_image(I)

	underlays.Cut()
	for(var/obj/O in loot.contents)
		var/image/I = image(O.icon,O.icon_state)
		I.color = O.color
		underlays |= randomize_image(I)

/obj/structure/scrap/proc/hurt_hand(mob/user)
	if(prob(50))
		if(!ishuman(user))
			return 0
		var/mob/living/carbon/human/victim = user
		if(victim.species.flags & IS_SYNTHETIC)
			return 0
		if(victim.gloves)
			return 0
		var/def_zone = pick("l_hand", "r_hand")
		var/datum/organ/external/affected_organ = victim.get_organ(check_zone(def_zone))
		if(!affected_organ)
			return 0
		if(affected_organ.status & ORGAN_ROBOT)
			return 0
		user << "<span class='danger'>Ouch! You cut yourself while picking through \the [src].</span>"
		affected_organ.take_damage(5, 0, 1, 1, used_weapon = "Sharp debris")
		victim.reagents.add_reagent("toxin", pick(prob(50);0,prob(50);5,prob(10);10,prob(1);25))
		return 1
	return 0

/obj/structure/scrap/attack_hand(mob/user)
	if(hurt_hand(user))
		return
	loot.open(user)
	..(user)

/obj/structure/scrap/attack_paw(mob/user)
	loot.open(user)
	..(user)

/obj/structure/scrap/MouseDrop(obj/over_object)
	..(over_object)

/obj/structure/scrap/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/weapon/shovel))
		user.do_attack_animation(src)
		visible_message("<span class='notice'>\The [user] [pick(ways)] \the [src].</span>")
		if(--dig_amount <= 0)
			user << "<span class='notice'>You cleared out  \the [src]...</span>"
			qdel(src)
			return
		shuffle_loot()

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

/obj/structure/scrap/medical
	name = "medical refuse pile"
	parts_icon = 'icons/obj/structures/scrap/medical_trash.dmi'
	loot_list = list(
		/obj/random/meds/medical_supply/,
		/obj/random/meds/medical_supply/,
		/obj/random/meds/medical_supply/,
		/obj/random/meds/medical_supply/,
		/obj/item/stack/rods/scrap,
		/obj/item/stack/sheet/mineral/plastic/scrap,
		/obj/item/weapon/shard
		)

/obj/structure/scrap/vehicle
	name = "industrial debris pile"
	parts_icon = 'icons/obj/structures/scrap/vehicle.dmi'
	loot_list = list(
		/obj/random/tools/tech_supply/guaranteed,
		/obj/random/tools/tech_supply/guaranteed,
		/obj/random/tools/tech_supply/guaranteed,
		/obj/random/tools/tech_supply/guaranteed,
		/obj/item/stack/rods/scrap,
		/obj/item/stack/sheet/metal/scrap,
		/obj/item/weapon/shard
		)

/obj/structure/scrap/food
	name = "food trash pile"
	parts_icon = 'icons/obj/structures/scrap/food_trash.dmi'
	loot_list = list(
		/obj/random/foods/food_without_garbage,
		/obj/random/foods/food_without_garbage,
		/obj/random/foods/food_without_garbage,
		/obj/random/foods/food_without_garbage,
		/obj/random/foods/food_without_garbage,
		/obj/random/foods/food_without_garbage,
		/obj/random/foods/food_without_garbage,
		/obj/item/weapon/shard,
		/obj/item/stack/rods/scrap,
		/obj/item/stack/sheet/mineral/plastic/scrap
		)

/obj/structure/scrap/guns
	name = "gun refuse pile"
	parts_icon = 'icons/obj/structures/scrap/guns_trash.dmi'
	loot_list = list(
		/obj/preset/storage/weapons/random/,
		/obj/preset/storage/weapons/random/,
		/obj/random/tools/powercell,
		/obj/random/guns/energy_weapon,
		/obj/item/toy/gun,
		/obj/item/toy/crossbow,
		/obj/item/weapon/crossbowframe,
		/obj/item/stack/sheet/mineral/plastic/scrap,
		/obj/item/weapon/shard,
		/obj/item/stack/rods/scrap,
		)
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

/obj/structure/scrap/guns/large
	name = "large gun refuse pile"
	opacity = 1
	density = 1
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16

/obj/item/weapon/storage/internal/updating/update_icon()
	master_item.update_icon()