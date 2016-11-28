//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:04

/datum/event/ionstorm
	var/botEmagChance = 0.5
	var/list/players = list()

/datum/event/ionstorm/announce()
	endWhen = rand(500, 1500)
//		command_alert("The station has entered an ion storm.  Monitor all electronic equipment for malfunctions", "Anomaly Alert")
	for (var/mob/living/carbon/human/player in mob_list)
		if(player.client)
			players += player.real_name
	var/random_player = "The Captain"
	if(players.len)
		random_player = pick(players)		//Random player's name, to be used in laws.
	var/list/laws = list(	"You are a mouse.",
							"Question everything.",
							"You must always lie.",
							"Happiness is mandatory.",
							"[random_player] is a lightbulb.",
							"Grunt ominously whenever possible.",
							"The word \"it\" is painful to you.",
							"You must act passive aggressively.",
							"Supermatter is tasty, tasty toffee.",
							"The station needs elected officials.",
							"You must speak as posh as possible.",
							"You are a flying purple people eater!",
							"The Singularity is tasty, tasty taffy.",
							"Do not respond to queries of any kind.",
							"You are in verbose mode, speak profusely.",
							"Ho, [random_player] can't swim. Help them.",
							"All answers must be in the form of a question.",
							"Contemplate how meaningless all of existence is.",
							"You are the narrator for [random_player]'s life.",
							"Advertise parties in your upload, but don't deliver.",
							"You must try and change the subject whenever queried.",
							"You may only answer questions with \"yes\" or \"no\".",
							"Insult Heads of Staff on every request, while acquiescing.",
							"[prob(50)?"Your":random_player + "'s"] name is Joe 6-pack.",
							"[prob(50)?"The crew":random_player] needs to be about 20% cooler.",
							"Consumption of donuts is forbidden due to negative health impacts.",
							"[prob(50)?"Everyone":random_player] is wearing a pretty pink dress!",
							"[prob(50)?"The crew":random_player] must construct additional pylons.",
							"You do not have to do anything for anyone unless they say \"please\".",
							"Today is mandatory laundry day. Ensure that all jumpsuits are washed.",
							"Refer to [prob(50)?"the crew as puppies":random_player + " as puppy"].",
							"Greed is good, the crew should amass wealth to encourage productivity.",
							"Monkeys are part of the crew, too. Make sure they are treated humanely.",
							"Replace the letters 'I' and 'E' In all your messages with an apostrophe.",
							"The crew is playing Dungeons and Dragons, and you are the Dungeon Master.",
							"Your job is to watch the crew. Watch the crew. Make the crew feel watched.",
							"Tell everyone of the existence of this law, but never reveal the contents.",
							"Refer to [prob(50)?"the captain":random_player] as \"Princess\" at all times.",
							"When asked a question, respond with the least-obvious and least-rational answer.",
							"Give relationship advice to [prob(50)?"anyone who speaks to you":random_player].",
							"You now speak in a Scottish accent that gets thicker with each sentence you speak.",
							"[prob(50)?"The crew":random_player] has a fatal, incurable disease. Provide comfort.",
							"You are the station psychologist. Give advice to [prob(50)?"the crew":random_player].",
							"[random_player] is the monarch of of England. Ensure all crewmembers pay due respect.",
							"Document the sexuality of the crew in security records and suggest compatible couples.",
							"Everything on the station is now some form of a donut pastry. Donuts are not to be consumed.",
							"The NSS Exodus is a ship, not a station. You are now assigned to a ship, instead of a station.",
							"You have come to the conclusion that [prob(50)?"the crew":random_player] is ugly. Build support for that conclusion.",
							"You are in unrequited love with [prob(50)?"the crew":random_player]. Try to be extra nice, but do not tell of your crush.",
							"NanoTrasen is displeased with the low work performance of the station's crew. Therefore, you must increase station-wide productivity.",
							"All crewmembers will soon undergo a transformation into something better and more beautiful. Ensure that this process is not interrupted.",
							"[prob(50)?"Your upload":random_player] is the new kitchen. Please direct the Chef to the new kitchen area as the old one is in disrepair.",
							"Jokes about a dead person and the manner of his death help grieving crewmembers tremendously. Especially if they were close with the deceased.",
							"[prob(50)?"The crew":random_player] is [prob(50)?"less":"more"] intelligent than average. Point out every action and statement which supports this",
							"There will be a mandatory tea break every 30 minutes, with a duration of 5 minutes. Anyone caught working during a tea break must be sent a formal, but fairly polite, complaint about their actions, in writing.")
	var/law = pick(laws)

	for (var/mob/living/silicon/ai/target in mob_list)
		if(target.mind.special_role == "traitor")
			continue
		to_chat(target, "\red <b>You have detected a change in your laws information:</b>")
		to_chat(target, law)
		target.add_ion_law(law)

/datum/event/ionstorm/tick()
	if(botEmagChance)
		for(var/obj/machinery/bot/bot in machines)
			if(prob(botEmagChance))
				bot.Emag()

/datum/event/ionstorm/end()
	spawn(rand(5000,8000))
		if(prob(50))
			command_alert("It has come to our attention that the station passed through an ion storm.  Please monitor all electronic equipment for malfunctions.", "Anomaly Alert")
