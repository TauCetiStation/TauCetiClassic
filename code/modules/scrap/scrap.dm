/obj/structure/scrap
	name = "scrap pile"
	desc = "Someone met an unfortunate fate. Better see what's left."
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
		/obj/item/weapon/shard,
		/obj/random/tech_supply/,
		/obj/random/tech_supply/,
		)
	var/dig_amount = 7
	var/parts_icon = 'icons/obj/structures/scrap/trash.dmi'
	var/base_min = 4	//min and max number of random pieces of base icon
	var/base_max = 7
	var/base_spread = 8 //limits on pixel offsets of base pieces

/obj/structure/scrap/New()
	var/amt = rand(loot_min, loot_max)
	for(var/x = 1 to amt)
		var/loot_path = pick(loot_list)
		new loot_path(src)
	loot = new(src)
	loot.max_w_class = 5
	shuffle_loot()
	update_icon(1)
	..()

/obj/structure/scrap/Destroy()
	for (var/obj/item in loot)
		qdel(item)
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
			overlays |= randomize_image(I)

	underlays.Cut()
	for(var/obj/O in loot.contents)
		var/image/I = image(O.icon,O.icon_state)
		I.color = O.color
		underlays |= randomize_image(I)

/obj/structure/scrap/attack_hand(mob/user)
	loot.open(user)
	..(user)

/obj/structure/scrap/MouseDrop(obj/over_object)
	..(over_object)

/obj/structure/scrap/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/weapon/shovel))
		var/list/ways = list("pokes around", "digs through", "rummages through", "goes through","picks through")
		visible_message("<span class='notice'>\The [user] [pick(ways)] \the [src].</span>")
		if(--dig_amount <= 0)
			user << "<span class='notice'>You cleared out  \the [src]...</span>"
			Destroy()
		shuffle_loot()
		if(!(loot.contents.len || contents.len > 1))
			user << "<span class='notice'>There doesn't seem to be anything of interest left in \the [src]...</span>"
	..()

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


/obj/structure/scrap/vehicle
	name = "debris pile"
	parts_icon = 'icons/obj/structures/scrap/vehicle.dmi'
	loot_list = list(
		/obj/random/tech_supply/,
		/obj/random/tech_supply/,
		/obj/random/tech_supply/,
		/obj/random/tech_supply/,
		/obj/item/stack/rods/scrap,
		/obj/item/stack/sheet/mineral/plastic/scrap,
		/obj/item/stack/sheet/metal/scrap,
		/obj/item/weapon/shard
		)

/obj/structure/scrap/food
	name = "trash pile"
	parts_icon = 'icons/obj/structures/scrap/food_trash.dmi'
	loot_list = list(
		/obj/random/food_with_garbage,
		/obj/random/food_with_garbage,
		/obj/random/food_with_garbage,
		/obj/random/food_with_garbage,
		/obj/random/food_with_garbage,
		/obj/random/food_with_garbage,
		/obj/random/food_with_garbage,
		/obj/item/weapon/shard,
		/obj/item/stack/rods/scrap,
		/obj/item/stack/sheet/mineral/plastic/scrap
		)

/obj/structure/scrap/vehicle/large
	name = "large debris pile"
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
	name = "large trash pile"
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