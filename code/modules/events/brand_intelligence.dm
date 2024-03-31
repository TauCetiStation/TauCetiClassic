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


/datum/event/brand_intelligence/start()
	for(var/obj/machinery/vending/V in machines)
		if(!is_station_level(V.z))
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
	if(!originMachine || originMachine.shut_up)	//if every machine is infected, or if the original vending machine is missing or has it's voice switch flipped
		end()
		kill()
		return

	if(!vendingMachines.len)	//if every machine is infected
		infectedVendingMachines.Add(originMachine)
		for(var/obj/machinery/vending/upriser in infectedVendingMachines)
			if(QDELETED(upriser))
				continue
			var/mob/living/simple_animal/hostile/mimic/copy/M = new(upriser.loc, upriser, null) // it will delete upriser on creation and override any machine checks
			M.faction = "profit"
			M.speak = rampant_speeches.Copy()
			M.speak_chance = 7

			switch(rand(1, 100)) // for 30% chance, they're stronger
				if(1 to 70) // these are usually weak
					var/adjusted_health = max(M.health-20, 20) // don't make it negative-health
					M.health = adjusted_health
					M.maxHealth = adjusted_health
				if(71 to 80) // has more health
					var/bonus_health = 15+rand(1, 7)*5
					M.health += bonus_health
					M.maxHealth += bonus_health
					M.desc += " This one seems extra robust..."
				if(81 to 90) // does stronger damage
					M.melee_damage += 2+rand(1, 6) // 3~8
					M.desc += " This one seems extra painful..."
				if(91 to 100) // moves faster
					M.move_to_delay /= 2 // just half
					M.desc += " This one seems more agile..."
		kill()
		return
	var/obj/machinery/vending/infectedMachine = pick(vendingMachines)
	vendingMachines.Remove(infectedMachine)
	infectedVendingMachines.Add(infectedMachine)
	infectedMachine.shut_up = 0
	infectedMachine.shoot_inventory = 1

	if(IS_MULTIPLE(activeFor, 8))
		originMachine.speak(pick("Try our aggressive new marketing strategies!", \
									"You should buy products to feed your lifestyle obsession!", \
									"Consume!", \
									"Your money can buy happiness!", \
									"Engage direct marketing!", \
									"Advertising is legalized lying! But don't let that put you off our great deals!", \
									"You don't want to buy anything? Yeah, well I didn't want to buy your mom either."))

/datum/event/brand_intelligence/end()
	for(var/obj/machinery/vending/infectedMachine in infectedVendingMachines)
		infectedMachine.shut_up = 1
		infectedMachine.shoot_inventory = 0
