//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/constructable_frame //Made into a seperate type to make future revisions easier.
	name = "machine frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = 1
	anchored = 1
	use_power = NO_POWER_USE
	var/obj/item/weapon/circuitboard/circuit = null
	var/list/components = null
	var/list/req_components = null
	var/list/req_component_names = null // user-friendly names of components
	var/state = 1

// unfortunately, we have to instance the objects really quickly to get the names
// fortunately, this is only called once when the board is added and the items are immediately GC'd
// and none of the parts do much in their constructors
/obj/machinery/constructable_frame/proc/update_namelist()
	if(!req_components)
		return

	req_component_names = new()
	for(var/tname in req_components)
		var/path = tname
		var/obj/O = new path()
		req_component_names[tname] = O.name

/obj/machinery/constructable_frame/proc/get_req_components_amt()
	var/amt = 0
	for(var/path in req_components)
		amt += req_components[path]
	return amt

// update description of required components remaining
/obj/machinery/constructable_frame/proc/update_req_desc()
	if(!req_components || !req_component_names)
		return

	var/hasContent = 0
	desc = "Requires"
	for(var/i = 1 to req_components.len)
		var/tname = req_components[i]
		var/amt = req_components[tname]
		if(amt == 0)
			continue
		var/use_and = i == req_components.len
		desc += "[(hasContent ? (use_and ? ", and" : ",") : "")] [amt] [amt == 1 ? req_component_names[tname] : "[req_component_names[tname]]\s"]"
		hasContent = 1

	if(!hasContent)
		desc = "Does not require any more components."
	else
		desc += "."

/obj/machinery/constructable_frame/machine_frame/attackby(obj/item/P, mob/user)
	if(P.crit_fail)
		to_chat(user, "<span class='danger'>This part is faulty, you cannot add this to the machine!</span>")
		return
	switch(state)
		if(1)
			if(istype(P, /obj/item/weapon/circuitboard))
				to_chat(user, "<span class='warning'>The frame needs wiring first!</span>")
				return

			else if(iscoil(P))
				var/obj/item/stack/cable_coil/C = P
				if(C.get_amount() < 5)
					to_chat(user, "<span class='warning'>You need five length of cable to wire the frame!</span>")
					return
				if(user.is_busy(src))
					return
				to_chat(user, "<span class='notice'>You start to add cables to the frame.</span>")
				if(P.use_tool(src, user, 20, target = src, volume = 50))
					if(state == 1)
						if(!C.use(5))
							return

						to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
						state = 2
						icon_state = "box_1"

			else if(isscrewdriver(P) && !anchored)
				if(user.is_busy(src))
					return
				user.visible_message("<span class='warning'>[user] disassembles the frame.</span>", \
									"<span class='notice'>You start to disassemble the frame...</span>", "You hear banging and clanking.")
				if(P.use_tool(src, user, 40, volume = 50))
					if(state == 1)
						to_chat(user, "<span class='notice'>You disassemble the frame.</span>")
						var/obj/item/stack/sheet/metal/M = new (loc, 5)
						M.add_fingerprint(user)
						qdel(src)

			else if(iswrench(P))
				if(user.is_busy())
					return
				to_chat(user, "<span class='notice'>You start [anchored ? "un" : ""]securing [name]...</span>")
				if(P.use_tool(src, user, 40, volume = 75))
					if(state == 1)
						to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure [name].</span>")
						anchored = !anchored
		if(2)
			if(iswrench(P))
				if(user.is_busy())
					return
				to_chat(user, "<span class='notice'>You start [anchored ? "un" : ""]securing [name]...</span>")
				if(P.use_tool(src, user, 40, volume = 75))
					to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure [name].</span>")
					anchored = !anchored

			if(istype(P, /obj/item/weapon/circuitboard))
				if(!anchored)
					to_chat(user, "<span class='warning'>The frame needs to be secured first!</span>")
					return
				var/obj/item/weapon/circuitboard/B = P
				if(B.board_type == "machine")
					if(!user.drop_item())
						return
					playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
					to_chat(user, "<span class='notice'>You add the circuit board to the frame.</span>")
					circuit = P
					P.loc = src
					icon_state = "box_2"
					state = 3
					components = list()
					req_components = circuit.req_components.Copy()
					update_namelist()
					update_req_desc()
				else
					to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
			if(iswirecutter(P))
				playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You remove the cables.</span>")
				state = 1
				icon_state = "box_0"
				new /obj/item/stack/cable_coil/red(loc, 5)

		if(3)
			if(iscrowbar(P))
				playsound(src, 'sound/items/Crowbar.ogg', VOL_EFFECTS_MASTER)
				state = 2
				circuit.loc = src.loc
				components.Remove(circuit)
				circuit = null
				if(components.len == 0)
					to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
				else
					to_chat(user, "<span class='notice'>You remove the circuit board and other components.</span>")
					for(var/obj/item/weapon/W in components)
						W.loc = src.loc
				desc = initial(desc)
				req_components = null
				components = null
				icon_state = "box_1"

			if(isscrewdriver(P))
				var/component_check = 1
				for(var/R in req_components)
					if(req_components[R] > 0)
						component_check = 0
						break
				if(component_check)
					playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
					var/obj/machinery/new_machine = new src.circuit.build_path(src.loc)
					transfer_fingerprints_to(new_machine)
					new_machine.construction()
					for(var/obj/O in new_machine.component_parts)
						qdel(O)
					new_machine.component_parts = list()
					for(var/obj/O in src)
						O.loc = null
						new_machine.component_parts += O
					circuit.loc = null
					new_machine.RefreshParts()
					qdel(src)

			if(istype(P, /obj/item/weapon/storage/part_replacer) && P.contents.len && get_req_components_amt())
				var/obj/item/weapon/storage/part_replacer/replacer = P
				var/list/added_components = list()
				var/list/part_list = list()

				//Assemble a list of current parts, then sort them by their rating!
				for(var/obj/item/weapon/stock_parts/co in replacer)
					if(!co.crit_fail)
						part_list += co
				//Sort the parts. This ensures that higher tier items are applied first.
				part_list = sortTim(part_list, /proc/cmp_rped_sort)

				for(var/path in req_components)
					while(req_components[path] > 0 && (locate(path) in part_list))
						var/obj/item/part = (locate(path) in part_list)
						added_components[part] = path
						replacer.remove_from_storage(part, src)
						req_components[path]--
						part_list -= part

				for(var/obj/item/weapon/stock_parts/part in added_components)
					components += part
					to_chat(user, "<span class='notice'>[part.name] applied.</span>")
				replacer.play_rped_sound()

				update_req_desc()
				return

			if(istype(P, /obj/item) && get_req_components_amt())
				for(var/I in req_components)
					if(istype(P, I) && (req_components[I] > 0))
						if(iscoil(P))
							var/obj/item/stack/cable_coil/CP = P
							var/cable_color = CP.item_color
							if(CP.use(1))
								var/obj/item/stack/cable_coil/CC = new(src, 1, cable_color)
								components += CC
								req_components[I]--
								update_req_desc()
							else
								to_chat(user, "<span class='warning'>You need more cable!</span>")
							return
						if(!user.drop_item())
							break
						P.loc = src
						components += P
						req_components[I]--
						update_req_desc()
						return 1
				to_chat(user, "<span class='warning'>You cannot add that to the machine!</span>")
				return 0


//Machine Frame Circuit Boards
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, console screen, beaker, Microlaser, matter bin, power cells.
Note: Once everything is added to the public areas, will add m_amt and g_amt to circuit boards since autolathe won't be able
to destroy them and players will be able to make replacements.
*/

/obj/item/weapon/circuitboard/vendor
	name = "circuit board (Booze-O-Mat Vendor)"
	build_path = /obj/machinery/vending/boozeomat
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/vending_refill/boozeomat = 3)

/obj/item/weapon/circuitboard/vendor/attackby(obj/item/I, mob/user, params)
	if(isscrewdriver(I))
		var/list/names = list(/obj/machinery/vending/boozeomat = "Booze-O-Mat",
							/obj/machinery/vending/snack = "Getmore Chocolate Corp (Red)",
							/obj/machinery/vending/snack/blue = "Getmore Chocolate Corp (Blue)",
							/obj/machinery/vending/snack/orange = "Getmore Chocolate Corp (Orange)",
							/obj/machinery/vending/snack/green = "Getmore Chocolate Corp (Green)",
							/obj/machinery/vending/snack/teal = "Getmore Chocolate Corp (Teal)",
							/obj/machinery/vending/coffee = "Hot Drinks",
							/obj/machinery/vending/cola = "Robust Softdrinks (Blue)",
							/obj/machinery/vending/cola/black = "Robust Softdrinks (Black)",
							/obj/machinery/vending/cola/red = "Robust Softdrinks (Red)",
							/obj/machinery/vending/cola/spaceup = "Robust Softdrinks (Space-Up!)",
							/obj/machinery/vending/cola/starkist = "Robust Softdrinks (Starkist)",
							/obj/machinery/vending/cola/soda = "Robust Softdrinks (Soda)",
							/obj/machinery/vending/cola/gib = "Robust Softdrinks (Dr. Gibb)",
							/obj/machinery/vending/cigarette = "Cigarette",
							/obj/machinery/vending/barbervend = "Fab-O-Vend",
							/obj/machinery/vending/chinese = "Mr. Chang",
							/obj/machinery/vending/medical = "NanoMed Plus",
							/obj/machinery/vending/hydronutrients = "NutriMax",
							/obj/machinery/vending/hydroseeds = "MegaSeed Servitor",
							/obj/machinery/vending/dinnerware = "Dinnerware",
							/obj/machinery/vending/tool = "YouTool",
							/obj/machinery/vending/engivend = "Engi-Vend",
							/obj/machinery/vending/clothing = "ClothesMate",
							/obj/machinery/vending/blood = "Blood'O'Matic",
							/obj/machinery/vending/junkfood = "McNuffin's Fast Food")
//							/obj/machinery/vending/autodrobe = "AutoDrobe")

		build_path = pick(names)
		name = "circuit board ([names[build_path]] Vendor)"
		to_chat(user, "<span class='notice'>You set the board to [names[build_path]].</span>")
		req_components = list(text2path("/obj/item/weapon/vending_refill/[copytext("[build_path]", 24)]") = 3)       //Never before has i used a method as horrible as this one, im so sorry
		return
	return ..()

/obj/item/weapon/circuitboard/smes
	name = "circuit board (SMES)"
	build_path = /obj/machinery/power/smes
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=5;engineering=5"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/weapon/stock_parts/cell = 5,
							/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/emitter
	name = "circuit board (Emitter)"
	build_path = /obj/machinery/power/emitter
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=5;engineering=5"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/power_compressor
	name = "circuit board (Power Compressor)"
	build_path = /obj/machinery/compressor
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=5;engineering=4"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/weapon/stock_parts/manipulator = 6)

/obj/item/weapon/circuitboard/power_turbine
	name = "circuit board (Power Turbine)"
	build_path = /obj/machinery/power/turbine
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=4;engineering=5"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/weapon/stock_parts/capacitor = 6)

/obj/item/weapon/circuitboard/mech_recharger
	name = "circuit board (Mechbay Recharger)"
	build_path = /obj/machinery/mech_bay_recharge_port
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=4;engineering=4"
	req_components = list(
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/capacitor = 5)

/obj/item/weapon/circuitboard/teleporter_hub
	name = "circuit board (Teleporter Hub)"
	build_path = /obj/machinery/teleport/hub
	board_type = "machine"
	origin_tech = "programming=3;engineering=5;bluespace=5;materials=4"
	req_components = list(
							/obj/item/bluespace_crystal = 3,
							/obj/item/weapon/stock_parts/matter_bin = 1)

/obj/item/weapon/circuitboard/teleporter_station
	name = "circuit board (Teleporter Station)"
	build_path = /obj/machinery/teleport/station
	board_type = "machine"
	origin_tech = "programming=4;engineering=4;bluespace=4"
	req_components = list(
							/obj/item/bluespace_crystal = 2,
							/obj/item/weapon/stock_parts/capacitor = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/telesci_pad
	name = "circuit board (Telepad)"
	build_path = /obj/machinery/telepad
	board_type = "machine"
	origin_tech = "programming=4;engineering=3;materials=3;bluespace=4"
	req_components = list(
							/obj/item/bluespace_crystal = 2,
							/obj/item/weapon/stock_parts/capacitor = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/sleeper
	name = "circuit board (Sleeper)"
	build_path = /obj/machinery/sleeper
	board_type = "machine"
	origin_tech = "programming=3;biotech=2;engineering=3;materials=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 2)

/obj/item/weapon/circuitboard/cryo_tube
	name = "circuit board (Cryotube)"
	build_path = /obj/machinery/atmospherics/components/unary/cryo_cell
	board_type = "machine"
	origin_tech = "programming=4;biotech=3;engineering=4"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 4)

/obj/item/weapon/circuitboard/heater
	name = "circuit board (Heater)"
	build_path = /obj/machinery/atmospherics/components/unary/thermomachine/heater
	board_type = "machine"
	origin_tech = "powerstorage=2;engineering=1)"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/capacitor = 2)

/obj/item/weapon/circuitboard/cooler
	name = "circuit board (Cooler)"
	build_path = /obj/machinery/atmospherics/components/unary/thermomachine/freezer
	board_type = "machine"
	origin_tech = "magnets=2;engineering=2"
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/capacitor = 2,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/space_heater
	name = "circuit board (Space Heater)"
	build_path = /obj/machinery/space_heater
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/capacitor = 1,
							/obj/item/stack/cable_coil = 3)

/obj/item/weapon/circuitboard/color_mixer
	name = "circuit board (Color Mixer)"
	build_path = /obj/machinery/color_mixer
	origin_tech = "programming=2;materials=2"
	board_type = "machine"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 1)


/obj/item/weapon/circuitboard/biogenerator
	name = "circuit board (Biogenerator)"
	build_path = /obj/machinery/biogenerator
	board_type = "machine"
	origin_tech = "programming=3;biotech=2;materials=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/hydroponics
	name = "circuit board (Hydroponics Tray)"
	build_path = /obj/machinery/hydroponics/constructable
	board_type = "machine"
	origin_tech = "programming=1;biotech=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/deepfryer
	name = "circuit board (Deep Fryer)"
	build_path = /obj/machinery/deepfryer
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/microwave
	name = "circuit board (Microwave)"
	build_path = /obj/machinery/kitchen_machine/microwave
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/oven
	name = "circuit board (Oven)"
	build_path = /obj/machinery/kitchen_machine/oven
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/grill
	name = "circuit board (Grill)"
	build_path = /obj/machinery/kitchen_machine/grill
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/candymaker
	name = "circuit board (Candy)"
	build_path = /obj/machinery/kitchen_machine/candymaker
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/gibber
	name = "circuit board (Gibber)"
	build_path = /obj/machinery/gibber
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/processor
	name = "circuit board (Food processor)"
	build_path = /obj/machinery/processor
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

//obj/item/weapon/circuitboard/recycler
//	name = "circuit board (Recycler)"
//	build_path = /obj/machinery/recycler
//	board_type = "machine"
//	origin_tech = "programming=1"
//	req_components = list(
//							/obj/item/weapon/stock_parts/matter_bin = 1,
//							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/seed_extractor
	name = "circuit board (Seed Extractor)"
	build_path = /obj/machinery/seed_extractor
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/smartfridge
	name = "circuit board (Smartfridge)"
	build_path = /obj/machinery/smartfridge
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1)

/obj/item/weapon/circuitboard/monkey_recycler
	name = "circuit board (Monkey Recycler)"
	build_path = /obj/machinery/monkey_recycler
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/holopad
	name = "circuit board (AI Holopad)"
	build_path = /obj/machinery/hologram/holopad
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/chem_dispenser
	name = "circuit board (Portable Chem Dispenser)"
	build_path = /obj/machinery/chem_dispenser/constructable
	board_type = "machine"
	origin_tech = "materials=4;engineering=4;programming=4;phorontech=3;biotech=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/capacitor = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/weapon/stock_parts/cell = 1)

/obj/item/weapon/circuitboard/chem_master
	name = "circuit board (Chem Master 2999)"
	build_path = /obj/machinery/chem_master/constructable
	board_type = "machine"
	origin_tech = "materials=2;programming=2;biotech=1"
	req_components = list(
							/obj/item/weapon/reagent_containers/glass/beaker = 2,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/destructive_analyzer
	name = "Circuit board (Destructive Analyzer)"
	build_path = /obj/machinery/r_n_d/destructive_analyzer
	board_type = "machine"
	origin_tech = "magnets=2;engineering=2;programming=2"
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1)

/obj/item/weapon/circuitboard/autolathe
	name = "Circuit board (Autolathe)"
	build_path = /obj/machinery/autolathe
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 3,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/protolathe
	name = "Circuit board (Protolathe)"
	build_path = /obj/machinery/r_n_d/protolathe
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/reagent_containers/glass/beaker = 2)


/obj/item/weapon/circuitboard/circuit_imprinter
	name = "Circuit board (Circuit Imprinter)"
	build_path = /obj/machinery/r_n_d/circuit_imprinter
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/reagent_containers/glass/beaker = 2)

/obj/item/weapon/circuitboard/pacman
	name = "Circuit Board (PACMAN-type Generator)"
	build_path = /obj/machinery/power/port_gen/pacman
	board_type = "machine"
	origin_tech = "programming=3:powerstorage=3;phorontech=3;engineering=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/pacman/super
	name = "Circuit Board (SUPERPACMAN-type Generator)"
	build_path = /obj/machinery/power/port_gen/pacman/super
	origin_tech = "programming=3;powerstorage=4;engineering=4"

/obj/item/weapon/circuitboard/pacman/mrs
	name = "Circuit Board (MRSPACMAN-type Generator)"
	build_path = /obj/machinery/power/port_gen/pacman/mrs
	origin_tech = "programming=3;powerstorage=5;engineering=5"

/obj/item/weapon/circuitboard/rdserver
	name = "Circuit Board (R&D Server)"
	build_path = /obj/machinery/r_n_d/server
	board_type = "machine"
	origin_tech = "programming=3"
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/scanning_module = 1)

/obj/item/weapon/circuitboard/mechfab
	name = "Circuit board (Exosuit Fabricator)"
	build_path = /obj/machinery/mecha_part_fabricator
	board_type = "machine"
	origin_tech = "programming=3;engineering=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/minefab
	name = "Circuit board (Mining Fabricator)"
	build_path = /obj/machinery/mecha_part_fabricator/mining_fabricator
	board_type = "machine"
	origin_tech = "powerstorage=3;programming=3;engineering=4;magnets=4;materials=4"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)


/obj/item/weapon/circuitboard/clonepod
	name = "Circuit board (Clone Pod)"
	build_path = /obj/machinery/clonepod
	board_type = "machine"
	origin_tech = "programming=3;biotech=3"
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/scanning_module = 2,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/clonescanner
	name = "Circuit board (Cloning Scanner)"
	build_path = /obj/machinery/dna_scannernew
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/stack/cable_coil = 2)

/obj/item/weapon/circuitboard/cyborgrecharger
	name = "Circuit board (Cyborg Recharger)"
	build_path = /obj/machinery/recharge_station
	board_type = "machine"
	origin_tech = "powerstorage=3;engineering=3"
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor = 2,
							/obj/item/weapon/stock_parts/cell = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/recharger
	name = "circuit board (Weapon Recharger)"
	build_path = /obj/machinery/recharger
	board_type = "machine"
	origin_tech = "powerstorage=3;engineering=3;materials=4"
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor = 1,)

// Telecomms circuit boards:
/obj/item/weapon/circuitboard/telecomms/receiver
	name = "Circuit Board (Subspace Receiver)"
	build_path = /obj/machinery/telecomms/receiver
	board_type = "machine"
	origin_tech = "programming=4;engineering=3;bluespace=2"
	req_components = list(
							/obj/item/weapon/stock_parts/subspace/ansible = 1,
							/obj/item/weapon/stock_parts/subspace/filter = 1,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/stock_parts/micro_laser = 1)

/obj/item/weapon/circuitboard/telecomms/hub
	name = "Circuit Board (Hub Mainframe)"
	build_path = /obj/machinery/telecomms/hub
	board_type = "machine"
	origin_tech = "programming=4;engineering=4"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/subspace/filter = 2)

/obj/item/weapon/circuitboard/telecomms/relay
	name = "Circuit Board (Relay Mainframe)"
	build_path = /obj/machinery/telecomms/relay
	board_type = "machine"
	origin_tech = "programming=3;engineering=4;bluespace=3"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/subspace/filter = 2)

/obj/item/weapon/circuitboard/telecomms/bus
	name = "Circuit Board (Bus Mainframe)"
	build_path = /obj/machinery/telecomms/bus
	board_type = "machine"
	origin_tech = "programming=4;engineering=4"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/subspace/filter = 1)

/obj/item/weapon/circuitboard/tesla_coil
	name = "circuit board (Tesla Coil)"
	build_path = /obj/machinery/power/tesla_coil
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/grounding_rod
	name = "circuit board (Grounding Rod)"
	build_path = /obj/machinery/power/grounding_rod
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/telecomms/processor
	name = "Circuit Board (Processor Unit)"
	build_path = /obj/machinery/telecomms/processor
	board_type = "machine"
	origin_tech = "programming=4;engineering=4"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 3,
							/obj/item/weapon/stock_parts/subspace/filter = 1,
							/obj/item/weapon/stock_parts/subspace/treatment = 2,
							/obj/item/weapon/stock_parts/subspace/analyzer = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/subspace/amplifier = 1)

/obj/item/weapon/circuitboard/telecomms/server
	name = "Circuit Board (Telecommunication Server)"
	build_path = /obj/machinery/telecomms/server
	board_type = "machine"
	origin_tech = "programming=4;engineering=4"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/subspace/filter = 1)

/obj/item/weapon/circuitboard/telecomms/broadcaster
	name = "Circuit Board (Subspace Broadcaster)"
	build_path = /obj/machinery/telecomms/broadcaster
	board_type = "machine"
	origin_tech = "programming=4;engineering=4;bluespace=2"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/subspace/filter = 1,
							/obj/item/weapon/stock_parts/subspace/crystal = 1,
							/obj/item/weapon/stock_parts/micro_laser/high = 2)

/obj/item/weapon/circuitboard/ore_redemption
	name = "circuit board (Ore Redemption)"
	build_path = /obj/machinery/mineral/ore_redemption
	board_type = "machine"
	origin_tech = "programming=1;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/device/assembly/igniter = 1)

/obj/item/weapon/circuitboard/mining_equipment_vendor
	name = "circuit board (Mining Equipment Vendor)"
	build_path = /obj/machinery/mineral/equipment_vendor
	board_type = "machine"
	origin_tech = "programming=1;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/weapon/stock_parts/matter_bin = 3)
