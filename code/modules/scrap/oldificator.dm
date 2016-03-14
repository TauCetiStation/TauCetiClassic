/obj/item/proc/make_old()
	color = "#aaaa22"
	desc += " Warranty has expired."
	for(var/obj/item/sub_item in contents)
		sub_item.make_old()
	update_icon()

/obj/item/weapon/storage/make_old()
	var/del_count = rand(0,contents.len)
	for(var/i = 1 to del_count)
		var/removed_item = pick(contents)
		contents -= removed_item
		qdel(removed_item)
	..()

/obj/item/weapon/reagent_containers/make_old()
	for(var/datum/reagent/R in reagents.reagent_list)
		R.volume = rand(0,R.volume)
	reagents.add_reagent("toxin", rand(0,10))
	..()

/obj/item/ammo_box/make_old()
	var/del_count = rand(0,contents.len)
	for(var/i = 1 to del_count)
		var/removed_item = pick(stored_ammo)
		stored_ammo -= removed_item
		qdel(removed_item)
	..()

/obj/item/weapon/stock_parts/cell/make_old()
	if(prob(50))
		charge = 0
	else
		charge = rand(0, charge)
	if(prob(50))
		crit_fail = 1
	if(prob(25))
		rigged = 1
	..()

/obj/item/weapon/shard/make_old()
	return