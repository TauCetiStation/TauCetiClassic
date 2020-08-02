/**********************Ore Redemption Unit**************************/
//Turns all the various mining machines into a single unit to speed up mining and establish a point system

/obj/machinery/mineral/ore_redemption
	name = "ore redemption machine"
	desc = "A machine that accepts ore and instantly transforms it into workable material sheets, but cannot produce alloys such as Plasteel. Points for ore are generated based on type and can be redeemed at a mining equipment locker."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	density = 1
	anchored = 1.0
	input_dir = NORTH
	output_dir = SOUTH
	req_one_access = list(access_mining_station, access_chemistry, access_bar, access_research, access_ce, access_virology)
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/stk_types = list()
	var/stk_amt   = list()
	var/stack_list[0] //Key: Type.  Value: Instance of type.
	var/obj/item/weapon/card/id/inserted_id
	var/points = 0
	var/ore_pickup_rate = 15
	var/sheet_per_ore = 1
	var/point_upgrade = 1
	var/list/ore_values = list(
								"sand" = 	1,
								"iron" = 	1,
								"coal" = 	1,
								"hydrogen"=	10,
								"gold" = 	20,
								"silver" = 	10,
								"uranium" = 20,
								"osmium" = 	40)

/obj/machinery/mineral/ore_redemption/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/ore_redemption(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/device/assembly/igniter(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()

/obj/machinery/mineral/ore_redemption/RefreshParts()
	var/ore_pickup_rate_temp = 15
	var/point_upgrade_temp = 1
	var/sheet_per_ore_temp = 1
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		sheet_per_ore_temp = B.rating
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		ore_pickup_rate_temp = 15 * M.rating
	for(var/obj/item/weapon/stock_parts/micro_laser/L in component_parts)
		point_upgrade_temp = L.rating
	ore_pickup_rate = ore_pickup_rate_temp
	point_upgrade = point_upgrade_temp
	sheet_per_ore = sheet_per_ore_temp

/obj/machinery/mineral/ore_redemption/proc/process_sheet(obj/item/weapon/ore/O)
	var/obj/item/stack/sheet/mineral/processed_sheet = SmeltMineral(O)
	if(processed_sheet)
		if(!(processed_sheet in stack_list)) //It's the first of this sheet added
			var/obj/item/stack/sheet/mineral/s = new processed_sheet(src)
			s.amount = 0
			stack_list[processed_sheet] = s
		var/obj/item/stack/sheet/mineral/storage = stack_list[processed_sheet]
		storage.add(sheet_per_ore) //Stack the sheets
		qdel(O) //... garbage collect

/obj/machinery/mineral/ore_redemption/process()
	var/turf/T = get_turf(get_step(src, input_dir))
	var/i
	if(T)
		if(locate(/obj/item/weapon/ore) in T)
			for (i = 0; i < ore_pickup_rate; i++)
				var/obj/item/weapon/ore/O = locate() in T
				if(O)
					process_sheet(O)
				else
					break
		else
			var/obj/structure/ore_box/B = locate() in T
			if(B)
				for (i = 0; i < ore_pickup_rate; i++)
					var/obj/item/weapon/ore/O = locate() in B.contents
					if(O)
						process_sheet(O)
					else
						break

/obj/machinery/mineral/ore_redemption/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W,/obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I = usr.get_active_hand()
		if(istype(I) && !istype(inserted_id))
			if(!user.drop_item())
				return
			I.loc = src
			inserted_id = I
			updateUsrDialog()
		return
	if(exchange_parts(user, W))
		return

	if(default_pry_open(W))
		return

	if(default_unfasten_wrench(user, W))
		return
	if(default_deconstruction_screwdriver(user, "ore_redemption-open", "ore_redemption", W))
		updateUsrDialog()
		return
	if(panel_open)
		if(iscrowbar(W))
			empty_content()
			default_deconstruction_crowbar(W)
		return 1
	..()

/obj/machinery/mineral/ore_redemption/proc/SmeltMineral(obj/item/weapon/ore/O)
	if(O.refined_type)
		var/obj/item/stack/sheet/mineral/M = O.refined_type
		points += O.points * point_upgrade
		return M
	qdel(O)//No refined type? Purge it.
	return

/obj/machinery/mineral/ore_redemption/ui_interact(mob/user)
	var/obj/item/stack/sheet/mineral/s
	var/dat

	dat += text("This machine only accepts ore. Diamonds, Phoron and Slag are not accepted.<br><br>")
	dat += text("Current unclaimed points: [points]<br>")

	if(istype(inserted_id))
		dat += text("You have [inserted_id.mining_points] mining points collected. <A href='?src=\ref[src];choice=eject'>Eject ID.</A><br>")
		dat += text("<A href='?src=\ref[src];choice=claim'>Claim points.</A><br>")
	else
		dat += text("No ID inserted.  <A href='?src=\ref[src];choice=insert'>Insert ID.</A><br>")

	for(var/O in stack_list)
		s = stack_list[O]
		if(s.get_amount() > 0)
			if(O == stack_list[1])
				dat += "<br>"		//just looks nicer
			dat += text("[capitalize(s.name)]: [s.get_amount()] <A href='?src=\ref[src];release=[s.type]'>Release</A><br>")

	dat += text("<br><div class='statusDisplay'><b>Mineral Value List:</b><BR>[get_ore_values()]</div>")

	var/datum/browser/popup = new(user, "console_stacking_machine", "Ore Redemption Machine", 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/mineral/ore_redemption/proc/get_ore_values()
	var/dat = "<table border='0' width='300'>"
	for(var/ore in ore_values)
		var/value = ore_values[ore]
		dat += "<tr><td>[capitalize(ore)]</td><td>[value * point_upgrade]</td></tr>"
	dat += "</table>"
	return dat

/obj/machinery/mineral/ore_redemption/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["choice"])
		if(istype(inserted_id))
			if(href_list["choice"] == "eject")
				inserted_id.loc = loc
				inserted_id.verb_pickup()
				inserted_id = null
			if(href_list["choice"] == "claim")
				if(access_mining_station in inserted_id.access)
					inserted_id.mining_points += points
					points = 0
				else
					to_chat(usr, "<span class='warning'>Required access not found.</span>")
		else if(href_list["choice"] == "insert")
			var/obj/item/weapon/card/id/I = usr.get_active_hand()
			if(istype(I))
				if(!usr.drop_item())
					return
				I.loc = src
				inserted_id = I
			else
				to_chat(usr, "<span class='warning'>No valid ID.</span>")

	if(href_list["release"])
		if(check_access(inserted_id) || allowed(usr)) //Check the ID inside, otherwise check the user.
			if(!(text2path(href_list["release"]) in stack_list)) return
			var/obj/item/stack/sheet/mineral/inp = stack_list[text2path(href_list["release"])]
			var/obj/item/stack/sheet/mineral/out = new inp.type()
			var/desired = input("How much?", "How much to eject?", 1) as num
			out.set_amount(min(desired, 50, inp.get_amount()))
			if(out.get_amount() >= 1)
				inp.use(out.get_amount())
				unload_mineral(out)
			if(inp.get_amount() < 1)
				stack_list -= text2path(href_list["release"])
		else
			to_chat(usr, "<span class='warning'>Required access not found.</span>")

	src.updateUsrDialog()


/obj/machinery/mineral/ore_redemption/ex_act(severity, target)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if(severity == 1)
		if(prob(50))
			empty_content()
			qdel(src)
	else if(severity == 2)
		if(prob(25))
			empty_content()
			qdel(src)

//empty the redemption machine by stacks of at most max_amount (50 at this time) size
/obj/machinery/mineral/ore_redemption/proc/empty_content()
	var/obj/item/stack/sheet/mineral/s

	for(var/O in stack_list)
		s = stack_list[O]
		while(s.get_amount() > s.max_amount)
			new s.type(loc, s.max_amount)
			s.use(s.max_amount)
		s.loc = loc
		s.layer = initial(s.layer)
		s.plane = initial(s.plane)


/**********************Mining Equipment Locker**************************/

/obj/machinery/mineral/equipment_locker
	name = "mining equipment locker"
	desc = "An equipment locker for miners, points collected at an ore redemption machine can be spent here."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "mining"
	density = 1
	anchored = 1.0
	var/static/list/selection_items
	var/obj/item/weapon/card/id/inserted_id
	var/list/prize_list = list(
		new /datum/data/mining_equipment("Stimpack",			     /obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack,   100),
		new /datum/data/mining_equipment("Chili",                    /obj/item/weapon/reagent_containers/food/snacks/hotchili,              100),
		new /datum/data/mining_equipment("Cigar",                    /obj/item/clothing/mask/cigarette/cigar/havana,                        100),
		new /datum/data/mining_equipment("Vodka",                    /obj/item/weapon/reagent_containers/food/drinks/bottle/vodka,          150),
		new /datum/data/mining_equipment("Soap",                     /obj/item/weapon/soap/nanotrasen, 						                150),
		new /datum/data/mining_equipment("lipozine pill",            /obj/item/weapon/reagent_containers/pill/lipozine,                     200),
		new /datum/data/mining_equipment("leporazine autoinjector",  /obj/item/weapon/reagent_containers/hypospray/autoinjector/leporazine, 300),
		new /datum/data/mining_equipment("Alien toy",                /obj/item/clothing/mask/facehugger_toy, 		                        250),
		new /datum/data/mining_equipment("Stimpack Bundle",	         /obj/item/weapon/storage/box/autoinjector/stimpack,				    400),
		new /datum/data/mining_equipment("Point card",    	         /obj/item/weapon/card/mining_point_card,               			    500),
		new /datum/data/mining_equipment("Space first-aid kit",      /obj/item/weapon/storage/firstaid/small_firstaid_kit/space,            1000),
		new /datum/data/mining_equipment("Accelerator upgrade",      /obj/item/kinetic_upgrade/speed,										2500),
		new /datum/data/mining_equipment("Space cash",    	         /obj/item/weapon/spacecash/c1000,                    			        5000),
		new /datum/data/mining_equipment("Mining voucher",    	     /obj/item/weapon/mining_voucher,                    			        10000)
		)

/datum/data/mining_equipment
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0

/datum/data/mining_equipment/New(name, path, cost)
	src.equipment_name = name
	src.equipment_path = path
	src.cost = cost

/obj/machinery/mineral/equipment_vendor/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/mining_equipment_vendor(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()

/obj/machinery/mineral/equipment_vendor/power_change()
	..()
	update_icon()

/obj/machinery/mineral/equipment_vendor/update_icon()
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"
	return

/obj/machinery/mineral/equipment_locker/ui_interact(mob/user)
	var/dat
	dat +="<div class='statusDisplay'>"
	if(istype(inserted_id))
		dat += "You have [inserted_id.mining_points] mining points collected. <A href='?src=\ref[src];choice=eject'>Eject ID.</A><br>"
	else
		dat += "No ID inserted.  <A href='?src=\ref[src];choice=insert'>Insert ID.</A><br>"
	dat += "</div>"
	dat += "<br><b>Equipment point cost list:</b><BR><table border='0' width='200'>"
	for(var/datum/data/mining_equipment/prize in prize_list)
		dat += "<tr><td>[prize.equipment_name]</td><td>[prize.cost]</td><td><A href='?src=\ref[src];purchase=\ref[prize]'>Purchase</A></td></tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "miningvendor", "Mining Equipment Vendor", 400, 680)
	popup.set_content(dat)
	popup.open()

/obj/machinery/mineral/equipment_locker/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["choice"])
		if(istype(inserted_id))
			if(href_list["choice"] == "eject")
				inserted_id.loc = loc
				inserted_id.verb_pickup()
				inserted_id = null
		else if(href_list["choice"] == "insert")
			var/obj/item/weapon/card/id/I = usr.get_active_hand()
			if(istype(I))
				if(!usr.drop_item())
					return
				I.loc = src
				inserted_id = I
			else
				to_chat(usr, "<span class='danger'>No valid ID.</span>")
	if(href_list["purchase"])
		if(istype(inserted_id))
			var/datum/data/mining_equipment/prize = locate(href_list["purchase"])
			if (!prize || !(prize in prize_list))
				return
			if(prize.cost > inserted_id.mining_points)
			else
				inserted_id.mining_points -= prize.cost
				new prize.equipment_path(src.loc)

	src.updateUsrDialog()

/obj/machinery/mineral/equipment_locker/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/mining_voucher))
		RedeemVoucher(I, user)
		return
	if(istype(I,/obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/C = usr.get_active_hand()
		if(istype(C) && !istype(inserted_id))
			usr.drop_item()
			C.loc = src
			inserted_id = C
			updateUsrDialog()
		return
	if(default_deconstruction_screwdriver(user, "mining-open", "mining", I))
		updateUsrDialog()
		return
	if(panel_open)
		if(iscrowbar(I))
			default_deconstruction_crowbar(I)
		return 1
	..()

/obj/machinery/mineral/equipment_locker/proc/populate_selection()
	selection_items = list(
	"Resonator kit" = image(icon = 'icons/obj/mining.dmi', icon_state = "resonator"),
	"Kinetic Accelerator" = image(icon = 'icons/obj/mining/hand_tools.dmi', icon_state = "kineticgun100"),
	"Mining Drone" = image(icon = 'icons/obj/aibots.dmi', icon_state = "mining_drone"),
	"Special Mining Rig" = image(icon = 'icons/obj/clothing/suits.dmi', icon_state = "rig-mining")
	)

/obj/machinery/mineral/equipment_locker/proc/RedeemVoucher(obj/voucher, redeemer)
	if(voucher.in_use)
		return
	voucher.in_use = 1
	if(!selection_items)
		populate_selection()
	var/selection = show_radial_menu(redeemer, src, selection_items, require_near = TRUE, tooltips = TRUE)
	if(!selection || !Adjacent(redeemer))
		voucher.in_use = 0
		return
	switch(selection)
		if("Resonator kit")
			new /obj/item/weapon/resonator(src.loc)
		if("Kinetic Accelerator")
			new /obj/item/weapon/gun/energy/kinetic_accelerator(src.loc)
		if("Mining Drone")
			new /mob/living/simple_animal/hostile/mining_drone(src.loc)
		if("Special Mining Rig")
			new /obj/item/mining_rig_pack(src.loc)
		if("Cancel")
			voucher.in_use = 0
			return
	qdel(voucher)

/obj/machinery/mineral/equipment_locker/ex_act()
	return


/**********************Mining Equipment Locker Items**************************/
/**********************Mining Rig Pack**********************/

/obj/item/mining_rig_pack/atom_init()
	..()
	new /obj/item/clothing/head/helmet/space/rig/mining(src.loc)
	new	/obj/item/clothing/suit/space/rig/mining(src.loc)
	return INITIALIZE_HINT_QDEL

/**********************Mining Equipment Voucher**********************/

/obj/item/weapon/mining_voucher
	name = "mining voucher"
	desc = "A token to redeem a piece of equipment. Use it on a mining equipment locker."
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_voucher"
	w_class = ITEM_SIZE_TINY


/**********************Mining Point Card**********************/

/obj/item/weapon/card/mining_point_card
	name = "mining point card"
	desc = "A small card preloaded with mining points. Swipe your ID card over it to transfer the points, then discard."
	icon_state = "data"
	var/points = 500

/obj/item/weapon/card/mining_point_card/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/card/id))
		if(points)
			var/obj/item/weapon/card/id/C = I
			C.mining_points += points
			to_chat(user, "<span class='info'>You transfer [points] points to [C].</span>")
			points = 0
		else
			to_chat(user, "<span class='info'>There's no points left on [src].</span>")
		return
	return ..()

/obj/item/weapon/card/mining_point_card/examine(mob/user)
	..()
	to_chat(user, "There's [points] points on the card.")


/**********************Jaunter**********************/

/obj/item/device/wormhole_jaunter
	name = "wormhole jaunter"
	desc = "A single use device harnessing outdated wormhole technology, Nanotrasen has since turned its eyes to blue space for more accurate teleportation. The wormholes it creates are unpleasant to travel through, to say the least."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Jaunter"
	item_state = "electronic"
	throwforce = 0
	w_class = ITEM_SIZE_SMALL
	throw_speed = 3
	throw_range = 5
	origin_tech = "bluespace=2"

	var/chosen_beacon = null	//Let's do some targeting

/obj/item/device/wormhole_jaunter/attack_self(mob/user)
	var/turf/device_turf = get_turf(user)
	if(!device_turf||device_turf.z==2||device_turf.z>=7)
		to_chat(user, "<span class='notice'>You're having difficulties getting the [src.name] to work.</span>")
		return
	else
		user.visible_message("<span class='notice'>[user.name] activates the [src.name]!</span>")
		var/list/L = list()
		for(var/obj/item/device/radio/beacon/B in radio_beacon_list)
			var/turf/T = get_turf(B)
			if(is_station_level(T.z))
				L += B
		if(!L.len)
			to_chat(user, "<span class='notice'>The [src.name] failed to create a wormhole.</span>")
			return
		if(!chosen_beacon)
			chosen_beacon = pick(L)
		var/obj/effect/portal/jaunt_tunnel/J = new /obj/effect/portal/jaunt_tunnel(get_turf(src), chosen_beacon)
		spawn(100) qdel(J)	//Portal will disappear after 10 sec
		J.target = chosen_beacon
		try_move_adjacent(J)
		playsound(src, 'sound/effects/sparks4.ogg', VOL_EFFECTS_MASTER)
		qdel(src)

/obj/item/device/wormhole_jaunter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/radio/beacon))
		user.SetNextMove(CLICK_CD_INTERACT)
		user.visible_message("<span class='notice'>[user.name] spent [I.name] above [name], scanning the serial code.</span>",
							"<span class='notice'>You scanned serial code of [I.name], now [name] is locked.</span>")
		chosen_beacon = I
		icon_state = "Jaunter_locked"
	else
		return ..()

/obj/effect/portal/jaunt_tunnel
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = "A stable hole in the universe made by a wormhole jaunter. Turbulent doesn't even begin to describe how rough passage through one of these is, but at least it will always get you somewhere near a beacon."

/obj/effect/portal/jaunt_tunnel/teleport(atom/movable/M)
	if(istype(M, /obj/effect))
		return
	if(istype(M, /atom/movable))
		if(do_teleport(M, target, 3))
			if(isliving(M))
				var/mob/living/L = M
				L.Weaken(3)
				shake_camera(L, 20, 1)
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					H.invoke_vomit_async()


/**********************Resonator**********************/

/obj/item/weapon/resonator
	name = "resonator"
	icon = 'icons/obj/mining.dmi'
	icon_state = "resonator"
	item_state = "resonator"
	desc = "A handheld device that creates small fields of energy that resonate until they detonate, crushing rock. It can also be activated without a target to create a field at the user's location, to act as a delayed time trap. It's more effective in a vaccuum."
	w_class = ITEM_SIZE_NORMAL
	force = 10
	throwforce = 10
	var/cooldown = 0

/obj/item/weapon/resonator/proc/CreateResonance(target, creator)
	if(cooldown <= 0)
		playsound(src, 'sound/effects/stealthoff.ogg', VOL_EFFECTS_MASTER)
		var/obj/effect/resonance/R = new /obj/effect/resonance(get_turf(target))
		R.creator = creator
		cooldown = 1
		spawn(20)
			cooldown = 0

/obj/item/weapon/resonator/attack_self(mob/user)
	CreateResonance(src, user)
	..()

/obj/item/weapon/resonator/afterattack(atom/target, mob/user, proximity, params)
	if(target in user.contents)
		return
	if(proximity)
		CreateResonance(target, user)

/obj/effect/resonance
	name = "resonance field"
	desc = "A resonating field that significantly damages anything inside of it when the field eventually ruptures."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield1"
	layer = 4.1
	mouse_opacity = 0
	var/resonance_damage = 30
	var/creator = null

/obj/effect/resonance/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/resonance/atom_init_late()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf))
		return
	if(istype(proj_turf, /turf/simulated/mineral))
		var/turf/simulated/mineral/M = proj_turf
		playsound(src, 'sound/effects/sparks4.ogg', VOL_EFFECTS_MASTER)
		M.GetDrilled()
		spawn(5)
			qdel(src)
	else
		var/datum/gas_mixture/environment = proj_turf.return_air()
		var/pressure = environment.return_pressure()
		if(pressure < 50)
			name = "strong resonance field"
			resonance_damage = 60
		spawn(50)
			playsound(src, 'sound/effects/sparks4.ogg', VOL_EFFECTS_MASTER)
			if(creator)
				for(var/mob/living/L in src.loc)
					usr.attack_log += text("\[[time_stamp()]\] used a resonator field on [L.name] ([L.ckey])")
					to_chat(L, "<span class='danger'>The [src.name] ruptured with you in it!</span>")
					L.adjustBruteLoss(resonance_damage)
			else
				for(var/mob/living/L in src.loc)
					to_chat(L, "<span class='danger'>The [src.name] ruptured with you in it!</span>")
					L.adjustBruteLoss(resonance_damage)
			qdel(src)


/**********************Facehugger toy**********************/

/obj/item/clothing/mask/facehugger_toy
	name = "alien"
	desc = "A toy often used to play pranks on other miners by putting it in their beds. It takes a bit to recharge after latching onto something."
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	layer = ABOVE_WINDOW_LAYER
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES
	body_parts_covered = FACE | EYES
	var/next_leap = 0

/obj/item/clothing/mask/facehugger_toy/HasProximity(mob/living/carbon/human/H)
	if(!ishuman(H))
		return
	if(loc == H)
		return
	if(next_leap > world.time)
		return
	if(H.head && H.head.flags & HEADCOVERSMOUTH)
		return
	if(H.equip_to_slot_if_possible(src, SLOT_WEAR_MASK, disable_warning = TRUE))
		H.visible_message("<span class='danger'>[src] leaps at [H]'s face!</span>")
		next_leap = world.time + 10 SECONDS

/**********************Mining drone**********************/

/mob/living/simple_animal/hostile/mining_drone
	name = "nanotrasen minebot"
	desc = "Robot used to support the miners can be configured to search and collect ore or destroy monsters."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "mining_drone"
	icon_living = "mining_drone"
	status_flags = CANSTUN|CANWEAKEN|CANPUSH
	mouse_opacity = 1
	faction = "neutral"
	var/emagged = 0
	light_power = 2
	light_range = 4
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	wander = 0
	idle_vision_range = 6
	move_to_delay = 7
	retreat_distance = 2
	minimum_distance = 3
	health = 140
	maxHealth = 140
	melee_damage = 18
	environment_smash = 0
	attacktext = "drill"
	attack_sound = list('sound/weapons/circsawhit.ogg')
	ranged = 1
	ranged_message = "shoots"
	ranged_cooldown_cap = 2
	projectiletype = /obj/item/projectile/kinetic
	projectilesound = 'sound/weapons/guns/kenetic_accel.ogg'
	wanted_objects = list(/obj/item/weapon/ore/diamond,
						  /obj/item/weapon/ore/glass,
						  /obj/item/weapon/ore/gold,
						  /obj/item/weapon/ore/iron,
						  /obj/item/weapon/ore/phoron,
						  /obj/item/weapon/ore/silver,
						  /obj/item/weapon/ore/uranium,
						  /obj/item/weapon/ore/coal,
						  /obj/item/weapon/ore/osmium,
						  /obj/item/weapon/ore/hydrogen,
						  /obj/item/weapon/ore/clown)

/mob/living/simple_animal/hostile/mining_drone/attackby(obj/item/I, mob/user)
	if(iswelder(I))
		var/obj/item/weapon/weldingtool/W = I
		user.SetNextMove(CLICK_CD_INTERACT)
		if(W.use(0, user) && !stat)
			if(stance != HOSTILE_STANCE_IDLE)
				to_chat(user, "<span class='info'>[src] is moving around too much to repair!</span>")
				return
			if(maxHealth == health)
				to_chat(user, "<span class='info'>[src] is at full integrity.</span>")
			else
				to_chat(user, "<span class='info'>You start repair some of the armor on [src].</span>")
				if(W.use_tool(src, user, 20, volume = 50))
					health += 15
					to_chat(user, "<span class='info'>You repaired some of the armor on [src].</span>")
			return
	..()

/mob/living/simple_animal/hostile/mining_drone/death()
	..()
	visible_message("<span class='danger'>[src] is destroyed!</span>")
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	new /obj/effect/decal/remains/robot(src.loc)
	DropOre()
	qdel(src)
	return

/mob/living/simple_animal/hostile/mining_drone/atom_init()
	. = ..()
	SetCollectBehavior()

/mob/living/simple_animal/hostile/mining_drone/helpReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	switch(search_objects)
		if(0)
			SetCollectBehavior()
			to_chat(attacker, "<span class='info'>[src] has been set to search and store loose ore.</span>")
		if(2)
			SetOffenseBehavior()
			to_chat(attacker, "<span class='info'>[src] has been set to attack hostile wildlife.</span>")

/mob/living/simple_animal/hostile/mining_drone/proc/SetCollectBehavior()
	stop_automated_movement_when_pulled = 1
	idle_vision_range = 9
	search_objects = 2
	wander = 1
	ranged = 0
	minimum_distance = 1
	retreat_distance = null
	icon_state = "mining_drone"

/mob/living/simple_animal/hostile/mining_drone/proc/SetOffenseBehavior()
	stop_automated_movement_when_pulled = 0
	idle_vision_range = 6
	search_objects = 0
	wander = 0
	ranged = 1
	retreat_distance = 2
	minimum_distance = 3
	icon_state = "mining_drone_offense"

/mob/living/simple_animal/hostile/mining_drone/AttackingTarget()
	if(istype(target, /obj/item/weapon/ore))
		CollectOre()
		return
	..()

/mob/living/simple_animal/hostile/mining_drone/proc/CollectOre()
	var/obj/item/weapon/ore/O
	for(O in src.loc)
		O.loc = src
	for(var/dir in alldirs)
		var/turf/T = get_step(src,dir)
		for(O in T)
			O.loc = src
	return

/mob/living/simple_animal/hostile/mining_drone/proc/DropOre()
	if(!contents.len)
		return
	for(var/obj/item/weapon/ore/O in contents)
		contents -= O
		O.loc = src.loc
	return

/mob/living/simple_animal/hostile/mining_drone/adjustBruteLoss()
	if(search_objects)
		SetOffenseBehavior()
	..()

/mob/living/simple_animal/hostile/mining_drone/verb/drop_ore()
	set name = "Drop Ore"
	set category = "Object"
	set src in oview(1)

	to_chat(usr, "<span class='info'>You instruct [src] to drop any collected ore.</span>")
	DropOre()

/mob/living/simple_animal/hostile/mining_drone/AltClick(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return
	if(in_range(user, src))
		to_chat(user, "<span class='notice'>You unloaded ore to the floor.</span>")
		DropOre()

/mob/living/simple_animal/hostile/mining_drone/examine(mob/user)
	..()
	var/msg = null
	if (src.health < src.maxHealth)
		if (src.health >= src.maxHealth * 0.7)
			msg += "<span class='warning'>It looks slightly dented.</span>\n"
		else if (src.health <= src.maxHealth * 0.3)
			msg += "<span class='warning'><B>IT IS FALLING APART!</B></span>\n"
		else
			msg += "<span class='warning'><B>It looks severely dented!</B></span>\n"
	else
		msg += "<span class='notice'>It looks without dents.</span>\n"
	to_chat(user, msg)

/mob/living/simple_animal/hostile/mining_drone/emag_act(mob/user)
	if(emagged)
		to_chat(user, "Already hacked.")
		return FALSE
	else
		to_chat(user, "You hack the NT mining drone, his gun clicked.")
		emagged = 1
		projectiletype = /obj/item/projectile/beam/xray
		projectilesound = 'sound/weapons/guns/gunpulse_laser3.ogg'
		ranged_cooldown_cap = 1
		minimum_distance = 4
		retreat_distance = 3
		return TRUE

/**********************Lazarus Injector**********************/

/obj/item/weapon/lazarus_injector
	name = "lazarus injector"
	desc = "An injector with a cocktail of nanomachines and chemicals, this device can seemingly raise animals from the dead, making them become friendly to the user. Unfortunately, the process is useless on higher forms of life and incredibly costly, so these were hidden in storage until an executive thought they'd be great motivation for some of their employees."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "lazarus_hypo"
	item_state = "hypo"
	throwforce = 0
	w_class = ITEM_SIZE_SMALL
	throw_speed = 3
	throw_range = 5
	var/loaded = 1

/obj/item/weapon/lazarus_injector/attack(mob/living/M, mob/living/user, def_zone)
	if(!..())
		return TRUE

/obj/item/weapon/lazarus_injector/afterattack(atom/target, mob/user, proximity, params)
	if(!loaded)
		return
	if(istype(target, /mob/living) && proximity)
		if(istype(target, /mob/living/simple_animal))
			var/mob/living/simple_animal/M = target
			if(M.stat == DEAD)
				M.faction = "lazarus"
				M.revive()
				if(istype(target, /mob/living/simple_animal/hostile))
					var/mob/living/simple_animal/hostile/H = M
					H.friends += user
					log_game("[key_name(user)] has revived hostile mob [target] with a lazarus injector")
				loaded = 0
				user.visible_message("<span class='notice'>[user] injects [M] with [src], reviving it.</span>")
				playsound(src, 'sound/effects/refill.ogg', VOL_EFFECTS_MASTER)
				icon_state = "lazarus_empty"
				return
			else
				to_chat(user, "<span class='info'>[src] is only effective on the dead.</span>")
				return
		else
			to_chat(user, "<span class='info'>[src] is only effective on lesser beings.</span>")
			return

/obj/item/weapon/lazarus_injector/examine(mob/user)
	..()
	if(!loaded)
		to_chat(user, "<span class='info'>[src] is empty.</span>")

/**********************Patcher**********************/

/obj/item/weapon/patcher
	name = "suit patcher"
	desc = "Suit patcher will recover your space rig from breaches. It is for one use only."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "patcher"
	item_state = "patcher"
	throwforce = 0
	w_class = ITEM_SIZE_SMALL
	throw_speed = 3
	throw_range = 5
	var/loaded = 1

/obj/item/weapon/patcher/afterattack(atom/target, mob/user, proximity, params)
	if(!loaded)
		return
	if(istype(target, /obj/item/clothing/suit/space))
		var/obj/item/clothing/suit/space/C = target
		fix_spacesuit(C, user)
	else
		..()

/obj/item/weapon/patcher/attack(mob/living/M, mob/living/user)
	if(!loaded)
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(istype(H.wear_suit, /obj/item/clothing/suit/space))
			var/obj/item/clothing/suit/space/C = H.wear_suit
			fix_spacesuit(C, user)

/obj/item/weapon/patcher/proc/fix_spacesuit(obj/item/clothing/suit/space/C, mob/living/user)
	if(C.breaches.len)
		C.breaches.Cut()
		C.damage = 0
		C.brute_damage = 0
		C.burn_damage = 0
		C.name = C.base_name
		loaded = 0
		user.visible_message("<span class='notice'>[user] fixes [C] with [src].</span>")
		playsound(src, 'sound/effects/refill.ogg', VOL_EFFECTS_MASTER)
		icon_state = "patcher_empty"
		return TRUE
	else
		to_chat(user, "<span class='info'>[C] is absolutely intact.</span>")
		return FALSE

/obj/item/weapon/patcher/examine(mob/user)
	..()
	if(!loaded)
		to_chat(user, "<span class='info'>[src] is already used.</span>")

/**********************Xeno Warning Sign**********************/

/obj/structure/sign/xeno_warning_mining
	name = "DANGEROUS ALIEN LIFE"
	desc = "A sign that warns would be travellers of hostile alien life in the vicinity."
	icon = 'icons/obj/decals.dmi'
	icon_state = "xeno_warning"
