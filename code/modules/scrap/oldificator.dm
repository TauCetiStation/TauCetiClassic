/obj/item/proc/make_old()
	color = pick("#996633", "#663300", "#666666")
	name = pick("old ", "expired ", "dirty ") + initial(name)
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
	..()

/obj/item/weapon/circuitboard/make_old()
	if(prob(75))
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

/obj/item/clothing/suit/space/make_old()
	if(prob(75))
		var/datum/breach/B = new()
		breaches += B
		B.class = pick(25,50,75)
		B.damtype = pick(BRUTE, BURN)
		B.update_descriptor()
		B.holder = src
	..()

/obj/item/clothing/make_old()
	if(prob(50))
		slowdown += pick(0.5, 0.5, 1, 1.5)
	if(prob(75))
		armor["melee"] = armor["melee"] / 2
		armor["bullet"] = armor["bullet"] / 2
		armor["laser"] = armor["laser"] / 2
		armor["energy"] = armor["energy"] / 2
		armor["bomb"] = armor["bomb"] / 2
		armor["bio"] = armor["bio"] / 2
		armor["rad"] = armor["rad"] / 2
	if(prob(50))
		uncleanable = 1
	if(prob(25))
		flags_pressure = 0
	if(prob(25))
		heat_protection = 0
	if(prob(25))
		cold_protection = 0
	if(prob(35))
		contaminate()
	if(prob(75))
		generate_blood_overlay()
		blood_overlay.color = pick("#030303", "#aa0000")
		blood_color = blood_overlay.color
		overlays += blood_overlay
		blood_DNA = list()
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
	return ..()

/obj/item/weapon/aiModule/broken/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	IonStorm(0)
	explosion(sender.loc, 1, 1, 1, 3)
	sender.drop_from_inventory(src)
	qdel(src)

/obj/item/weapon/dnainjector/make_old()
	if(prob(75))
		name = "DNA-Injector (unknown)"
		desc = pick("1mm0r74l17y 53rum", "1ncr3d1bl3 73l3p47y hNlk", "5up3rhum4n m16h7")
		value = 0xFFF
	if(prob(75))
		block = pick(MONKEYBLOCK, HALLUCINATIONBLOCK, DEAFBLOCK, BLINDBLOCK, NERVOUSBLOCK, TWITCHBLOCK, CLUMSYBLOCK, COUGHBLOCK, HEADACHEBLOCK, GLASSESBLOCK)
	..()

/obj/item/clothing/glasses/hud/make_old()
	if(prob(75) && !istype(src, /obj/item/clothing/glasses/hud/broken))
		var/obj/item/clothing/glasses/hud/broken/brokenhud= new /obj/item/clothing/glasses/hud/broken
		brokenhud.name = src.name
		brokenhud.desc = src.desc
		brokenhud.icon = src.icon
		brokenhud.icon_state = src.icon_state
		brokenhud.item_state = src.item_state
		brokenhud.make_old()
		qdel(src)
	..()

/obj/item/clothing/glasses/make_old()
	..()
	if(prob(75))
		vision_flags = 0
	if(prob(75))
		darkness_view = -1

/obj/item/clothing/glasses/sunglasses/sechud/make_old()
	..()
	if(hud && prob(75))
		hud = new /obj/item/clothing/glasses/hud/broken
