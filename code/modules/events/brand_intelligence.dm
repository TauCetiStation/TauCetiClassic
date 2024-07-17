/datum/event/brand_intelligence
	announceWhen	= 21
	endWhen			= 1000	//Ends when all vending machines are subverted anyway.
	announcement = new /datum/announcement/centcomm/brand

	var/list/obj/machinery/vending/vendingMachines = list()
	var/list/obj/machinery/vending/infectedVendingMachines = list()
	var/obj/machinery/vending/originMachine
	var/static/list/rampant_speeches = list("Try our aggressive new marketing strategies!", \
											"You should buy products to feed your lifestyle obsession!", \
											"Consume!", \
											"Your money can buy happiness!", \
											"Engage direct marketing!", \
											"Advertising is legalized lying! But don't let that put you off our great deals!", \
											"You don't want to buy anything? Yeah, well, I didn't want to buy your mom either.")
	var/static/list/protected_from_malf = list(/obj/machinery/vending/wallmed1, /obj/machinery/vending/wallmed2)

/datum/event/brand_intelligence/start()
	for(var/obj/machinery/vending/V in machines)
		if(!is_station_level(V.z))
			continue
		if(is_type_in_list(V, protected_from_malf))
			continue
		vendingMachines.Add(V)

	if(!vendingMachines.len)
		kill()
		return

	originMachine = pick(vendingMachines)
	vendingMachines.Remove(originMachine)
	originMachine.shut_up = 0
	originMachine.shoot_inventory = 1


/datum/event/brand_intelligence/tick()
	//if every machine is infected, or if the original vending machine is missing or has it's voice switch flipped
	if(!vendingMachines.len || !originMachine || originMachine.shut_up)
		end()
		kill()
		return

	if(!IS_MULTIPLE(activeFor, 5))
		return
	if(!prob(15))
		return
	var/obj/machinery/vending/infectedMachine = pick(vendingMachines)
	vendingMachines.Remove(infectedMachine)
	infectedVendingMachines.Add(infectedMachine)
	infectedMachine.shut_up = 0
	infectedMachine.shoot_inventory = 1

	if(IS_MULTIPLE(activeFor, 12))
		originMachine.speak(pick(rampant_speeches))

/datum/event/brand_intelligence/end()
	for(var/obj/machinery/vending/infectedMachine in infectedVendingMachines)
		infectedMachine.shut_up = 1
		infectedMachine.shoot_inventory = 0

/datum/event/brand_intelligence/alive_vends/tick()
	//if the original vending machine is missing or has it's voice switch flipped
	if(!originMachine || originMachine.shut_up)
		end()
		kill()
		return
	//if not every machine is infected
	if(vendingMachines.len)
		var/obj/machinery/vending/infectedMachine = pick(vendingMachines)
		vendingMachines.Remove(infectedMachine)
		infectedVendingMachines.Add(infectedMachine)
		infectedMachine.shut_up = 0
		infectedMachine.shoot_inventory = 1

		if(IS_MULTIPLE(activeFor, 8))
			originMachine.speak(pick(rampant_speeches))
		return

	infectedVendingMachines.Add(originMachine)
	for(var/obj/machinery/vending/upriser in infectedVendingMachines)
		if(QDELETED(upriser))
			continue
		var/mob/living/simple_animal/hostile/mimic/copy/vending/M = new(upriser.loc, upriser, null) // it will delete upriser on creation and override any machine checks
		M.speak = rampant_speeches.Copy()
	kill()
