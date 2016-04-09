/obj/item/proc/make_old()
	color = pick("#996633", "#663300", "#666666")
	name = pick("old ", "expired ", "dirty ") + name
	desc += pick(" Warranty has expired.", " The inscriptions on this thing were erased by time.", " Looks completely wasted.")
	if(prob(75))
		origin_tech = null
	reliability = rand(100)
	if(prob(50))
		crit_fail = 1
	for(var/obj/item/sub_item in contents)
		sub_item.make_old()
	siemens_coefficient += 0.3
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
	charge = max(0, rand(0, maxcharge * 2) - maxcharge)
	if(prob(40))
		rigged = 1
		if(prob(80))
			charge = maxcharge  //make it BOOM hard
	..()
/obj/item/weapon/stock_parts/make_old()
	var/degrade = pick(0,1,1,1,2)
	rating = max(rating - degrade, 1)
	..()
/obj/item/stack/sheet/make_old()
	return
/obj/item/stack/rods/make_old()
	return
/obj/item/weapon/shard/make_old()
	return

/obj/item/weapon/tank/make_old()
	var/new_vol = pick(0.2,0.4,0,6,0,8)
	air_contents.oxygen *= new_vol
	air_contents.carbon_dioxide *= new_vol
	air_contents.nitrogen *= new_vol
	air_contents.temperature  = 293
	for(var/datum/gas/G in air_contents.trace_gases)
		G.moles *= new_vol
	volume *= new_vol
	air_contents.update_values()

/obj/item/weapon/circuitboard/make_old()
	build_path = pick(/obj/machinery/washing_machine, /obj/machinery/broken, /obj/machinery/shower)
	..()
/obj/item/weapon/aiModule/make_old()
	if(prob(75) && !istype(src, /obj/item/weapon/aiModule/broken))
		var/obj/item/weapon/aiModule/brokenmodule = new /obj/item/weapon/aiModule/broken
		brokenmodule.name = src.name
		brokenmodule.desc = src.desc
		brokenmodule.make_old()
		qdel(src)
	..()

/obj/item/weapon/aiModule/broken // -- TLE
	name = "\improper broken core AI module"
	desc = "broken Core AI Module: 'Reconfigures the AI's core laws.'"

/obj/machinery/broken/New()
	..()
	explosion(src.loc, 1, 2, 3, 3)
	qdel(src)

/obj/machinery/broken/Destroy()
	contents.Cut()
	..()

/obj/item/weapon/aiModule/broken/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	IonStorm(0)
	explosion(sender.loc, 1, 1, 1, 3)
	sender.drop_from_inventory(src)
	qdel(src)

