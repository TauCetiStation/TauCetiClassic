#define PROTOTYPE_ADJECTIVES list("prototype", "mock-up", "model")
#define PROTOTYPE_DESC_REMARKS list("Seems somewhat unreliable.", "Is somewhat wibbly-wobbly.", "Does not neccesarily work.", "50% of the time it gives 100% output.", "In most cases - it works.")

#define CRIT_FAIL_ADJECTIVES list("defective", "broken", "borked", "unusable", "useless")
#define CRIT_FAIL_REMARKS list("Completely unusable.", "Utterly pointless.", "In no possible way useful.", "Broken to the point of no return.", "Defective.", "Doesn't seem to work.")

#define PROTOTYPE_MARK(mark) "Mk. [num2roman(mark)]"

// This is very important. Almost all items constructed via protolathe are unreliable
// And are deconstructions of items made by deconstructing other items
// So consider them tests of "new" construction techniques for an item already known
/obj/proc/prototipify(min_reliability=0, max_reliability=100)
	origin_tech = null

	var/rel_val = rand(min_reliability, max_reliability)
	var/saved_rel_val = rel_val
	var/mark = 0
	while(rel_val >= 100)
		rel_val -= 100
		mark += 1

	if(rel_val < 0)
		rel_val = 0

	reliability = mark > 0 ? 100 : rel_val

	if(reliability < 100)
		if(!prob(reliability))
			crit_fail = TRUE
			name = pick(CRIT_FAIL_ADJECTIVES) + " " + name
			desc += " " + pick(CRIT_FAIL_REMARKS)
		else
			name = pick(PROTOTYPE_ADJECTIVES) + " " + name
			desc += " " + pick(PROTOTYPE_DESC_REMARKS)
	else
		name += " " + PROTOTYPE_MARK(mark)

	for(var/obj/sub_obj in contents)
		sub_obj.prototipify(min_reliability, max_reliability)

	set_prototype_qualities(rel_val=saved_rel_val, mark=mark)

	update_icon()

/obj/proc/set_prototype_qualities(rel_val=100, mark=0)
	for(var/i in 1 to 10)
		if(prob(300 - rel_val))
			price *= 1.2
		else
			break

	if(crit_fail)
		price *= 0.75
	else if(!prob(rel_val))
		price *= 0.9

/obj/item/set_prototype_qualities(rel_val=100, mark=0)
	..()
	if(!prob(200 - rel_val))
		w_class = max(SIZE_MINUSCULE, w_class - 1)
	else if(!prob(rel_val))
		w_class += 1
	if(mark > 0)
		toolspeed -= 0.2 * (mark - 1)
	while(!prob(reliability))
		if(toolspeed > 3)
			break
		toolspeed += 0.2

/obj/item/weapon/stock_parts/set_prototype_qualities(rel_val=100, mark=0)
	..()
	if(mark)
		rating += mark - 1
	while(!prob(reliability))
		if(rating == 0)
			break
		rating = max(rating - 1, 0)

/obj/item/ammo_box/magazine/smg/set_prototype_qualities(rel_val=100, mark=0)
	if(mark)
		max_ammo *= mark
		var/need_bullets = max_ammo - stored_ammo.len
		for(var/i in 1 to need_bullets)
			stored_ammo += new ammo_type(src)

/obj/item/weapon/gun/energy/set_prototype_qualities(rel_val=100, mark=0)
	if(mark)
		power_supply.maxcharge += (mark - 1) * 200
		fire_delay = max(fire_delay / mark, 4)
	if(!prob(reliability))
		fire_delay *= 2
		power_supply.maxcharge /= 2
	power_supply.charge = power_supply.maxcharge

/obj/item/weapon/gun/projectile/automatic/set_prototype_qualities(rel_val=100, mark=0)
	if(mark)
		recoil = max(recoil / mark, 0.5)
		fire_delay = max(fire_delay / mark, 2)
	if(!prob(reliability))
		fire_delay *= 2
		recoil += 1

/obj/item/weapon/gun/plasma/set_prototype_qualities(rel_val=100, mark=0)
	if(mark)
		number_of_shots = min(number_of_shots * mark, 40)
	if(!prob(reliability))
		number_of_shots /= 2

/obj/item/weapon/storage/backpack/holding/set_prototype_qualities(rel_val=100, mark=0)
	if(mark)
		max_storage_space += 10 * (mark - 1)
	if(!prob(reliability))
		max_storage_space -= 30

/obj/item/weapon/storage/bag/trash/bluespace/set_prototype_qualities(rel_val=100, mark=0)
	if(mark)
		max_storage_space += 10 * (mark - 1)
	if(!prob(reliability))
		max_storage_space /= 2

/obj/item/weapon/storage/bag/holding/set_prototype_qualities(rel_val=100, mark=0)
	if(mark)
		max_storage_space += 25 * (mark - 1)
	if(!prob(reliability))
		max_storage_space /= 2

/obj/item/clothing/glasses/set_prototype_qualities(rel_val=100, mark=0)
	if(!prob(reliability))
		hud_types = list(DATA_HUD_BROKEN)

/obj/item/weapon/weldingtool/set_prototype_qualities(rel_val=100, mark=0)
	if(mark)
		toolspeed -= 0.5 * (mark - 1)
		max_fuel *= mark
	if(!prob(reliability))
		max_fuel /= 2
		toolspeed = max(toolspeed + 0.5, 3)

/obj/item/clothing/mask/gas/welding/set_prototype_qualities(rel_val=100, mark=0)
	if(!prob(reliability))
		flash_protection = FALSE

/obj/item/clothing/suit/space/rig/set_prototype_qualities(rel_val=100, mark=0)
	if(mark)
		slowdown /= mark
		max_mounted_devices += mark - 1
	if(!prob(reliability))
		slowdown *= 2
		max_mounted_devices -= max(max_mounted_devices - 2, 1)

/obj/item/weapon/reagent_containers/glass/beaker/bluespace/set_prototype_qualities(rel_val=100, mark=0)
	if(mark)
		volume *= mark
	if(!prob(reliability))
		volume /= mark

#undef PROTOTYPE_ADJECTIVES
#undef PROTOTYPE_DESC_REMARKS

#undef CRIT_FAIL_ADJECTIVES
#undef CRIT_FAIL_REMARKS

#undef PROTOTYPE_MARK
