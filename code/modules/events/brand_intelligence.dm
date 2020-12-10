/datum/event/brand_intelligence
	announceWhen	= 21
	endWhen			= 1000	//Ends when all vending machines are subverted anyway.

	var/list/obj/machinery/vending/vendingMachines = list()
	var/list/obj/machinery/vending/infectedVendingMachines = list()
	var/obj/machinery/vending/originMachine


/datum/event/brand_intelligence/announce()
	command_alert("На борту [station_name()] обнаружена аномальная активность торговых автоматов. Пожалуйста, ожидайте", "Машинное Обучение", "rampbrand")


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
	if(!vendingMachines.len || !originMachine || originMachine.shut_up)	//if every machine is infected, or if the original vending machine is missing or has it's voice switch flipped
		end()
		kill()
		return

	if(IS_MULTIPLE(activeFor, 5))
		if(prob(15))
			var/obj/machinery/vending/infectedMachine = pick(vendingMachines)
			vendingMachines.Remove(infectedMachine)
			infectedVendingMachines.Add(infectedMachine)
			infectedMachine.shut_up = 0
			infectedMachine.shoot_inventory = 1

			if(IS_MULTIPLE(activeFor, 12))
				originMachine.speak(pick("Попробуйте наши новые агрессивные маркетинговые стратегии!", \
										 "Вы должны покупать наши продукты, чтобы питать свою навязчивую идею образа жизни!", \
										 "Жрать!", \
										 "За ваши деньги можно купить много счастья!", \
										 "Занимайтесь прямым маркетингом!", \
										 "Реклама легализована ложью! Но не позволяйте этому оттолкнуть вас от наших выгодных сделок!", \
										 "Ты не будешь ничего покупать? Да, я тоже сначала не хотел покупать твою маму."))

/datum/event/brand_intelligence/end()
	for(var/obj/machinery/vending/infectedMachine in infectedVendingMachines)
		infectedMachine.shut_up = 1
		infectedMachine.shoot_inventory = 0
