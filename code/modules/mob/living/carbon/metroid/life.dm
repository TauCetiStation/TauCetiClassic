/mob/living/carbon/slime/Life()
	set invisibility = 0
	//set background = 1

	if (notransform)
		return
	if(!loc)
		return

	..()

	if(stat != DEAD)
		//Chemicals in the body
		handle_chemicals_in_body()

		handle_targets()

		if (!ckey)
			handle_mood()
			handle_speech()
			handle_attack()


	var/datum/gas_mixture/environment // Added to prevent null location errors-- TLE
	if(src.loc)
		environment = loc.return_air()


	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	src.blinded = null

	//Handle temperature/pressure differences between body and environment
	if(environment)
		handle_environment(environment)

	//Status updates, death etc.
	handle_regular_status_updates()

/mob/living/carbon/slime
	var/AIproc = 0 // determines if the AI loop is activated
	var/Atkcool = 0 // attack cooldown
	var/Tempstun = 0 // temporary temperature stuns
	var/Discipline = 0 // if a slime has been hit with a freeze gun, or wrestled/attacked off a human, they become disciplined and don't attack anymore for a while
	var/SStun = 0 // stun variable

/mob/living/carbon/slime/proc/TargetAttack()
	if(!isliving(ATarget))
		return
	if(!ATarget || Victim == ATarget)
		return
	if(ATarget.stat == DEAD || ATarget.stat == UNCONSCIOUS)
		if(ATarget == last_pointed)
			last_pointed = null
			ATarget = null
		return
	else if(ATarget in view(1, src))
		if(prob(25) && (iscarbon(ATarget) && !isslime(ATarget)))
			var/mob/living/carbon/C = ATarget
			Feedon(C)
		else
			ATarget.attack_slime(src)
	else if(ATarget in view(7, src))
		if(!ATarget.Adjacent(src))
			step_to(src, ATarget)
	else
		ATarget = null
	return


/mob/living/carbon/slime/proc/AIprocess()  // the master AI process

	if(AIproc || stat == DEAD || client) return

	var/hungry = 0
	if (nutrition < get_starve_nutrition())
		hungry = 2
	else if (nutrition < get_grow_nutrition() && prob(25) || nutrition < get_hunger_nutrition())
		hungry = 1

	AIproc = 1

	while(AIproc && stat != DEAD && (attacked || hungry || rabid || Victim))
		if(Victim) // can't eat AND have this little process at the same time
			break

		if(!Target || client)
			break

		if(Target.health <= -70 || Target.stat == DEAD)
			Target = null
			AIproc = 0
			break

		if(Target)
			for(var/mob/living/carbon/slime/M in view(1,Target))
				if(M.Victim == Target)
					Target = null
					AIproc = 0
					break
			if(!AIproc)
				break

			if(Target in view(1,src))
				if(issilicon(Target))
					if(!Atkcool)
						Atkcool = 1
						spawn(45)
							Atkcool = 0

						if(Target.Adjacent(src))
							Target.attack_slime(src)
					return
				if(!Target.lying && prob(80))

					if(Target.client && Target.health >= 20)
						if(!Atkcool)
							Atkcool = 1
							spawn(45)
								Atkcool = 0

							if(Target.Adjacent(src))
								Target.attack_slime(src)

					else
						if(!Atkcool && Target.Adjacent(src))
							Feedon(Target)

				else
					if(!Atkcool && Target.Adjacent(src))
						Feedon(Target)

			else
				if(Target in view(7, src))
					if(!Target.Adjacent(src)) // Bug of the month candidate: slimes were attempting to move to target only if it was directly next to them, which caused them to target things, but not approach them
						step_to(src, Target)

				else
					Target = null
					AIproc = 0
					break

		var/sleeptime = movement_delay()
		if(sleeptime <= 0) sleeptime = 1

		sleep(sleeptime + 2) // this is about as fast as a player slime can go

	AIproc = 0

/mob/living/carbon/slime/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		adjustToxLoss(rand(10,20))
		return

	var/loc_temp = get_temperature(environment)
	var/divisitor = 10

	var/temp_delta = loc_temp - bodytemperature

	if(abs(temp_delta) > 50) // If the difference is great, reduce the divisor for faster stabilization
		divisitor = 5

	if(!on_fire)
		adjust_bodytemperature(temp_delta / divisitor)

	//Account for massive pressure differences

	if(bodytemperature < (T0C + 5)) // start calculating temperature damage etc
		if(bodytemperature <= (T0C - 40)) // stun temperature
			Tempstun = 1

		if(bodytemperature <= (T0C - 45)) // hurt temperature
			if(bodytemperature <= 50) // sqrting negative numbers is bad
				adjustToxLoss(200)
			else
				adjustToxLoss(round(sqrt(bodytemperature)) * 2)

	else
		Tempstun = 0

	updatehealth()

	return //TODO: DEFERRED

/mob/living/carbon/slime/proc/handle_chemicals_in_body()
	if(reagents)
		reagents.metabolize(src)

	updatehealth()

	return //TODO: DEFERRED


/mob/living/carbon/slime/proc/handle_regular_status_updates()

	if(isslimeadult(src))
		health = 200 - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())
	else
		health = 150 - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())

	if(health < config.health_threshold_dead && stat != DEAD)
		death()
		return

	else if(src.health < config.health_threshold_crit)
		// if(src.health <= 20 && prob(1)) spawn(0) emote("gasp")

		//if(!src.rejuv) src.oxyloss++
		if(!reagents.has_reagent("inaprovaline")) adjustOxyLoss(10)

		if(src.stat != DEAD)	src.stat = UNCONSCIOUS

	if(prob(30))
		adjustOxyLoss(-1)
		adjustToxLoss(-1)
		adjustFireLoss(-1)
		adjustCloneLoss(-1)
		adjustBruteLoss(-1)


	if (src.stat == DEAD)

		src.lying = 1
		src.blinded = 1

	else
		if (src.paralysis || src.stunned || src.weakened || (status_flags && FAKEDEATH)) //Stunned etc.
			if (src.stunned)
				src.stat = CONSCIOUS
			if (src.weakened)
				src.lying = 0
				src.stat = CONSCIOUS
			if (src.paralysis)
				src.blinded = 0
				src.lying = 0
				src.stat = CONSCIOUS

		else
			src.lying = 0
			src.stat = CONSCIOUS

	if (src.stuttering > 0)
		setStuttering(0)

	if (src.eye_blind)
		src.eye_blind = 0
		src.blinded = 1

	if (src.ear_deaf > 0) src.ear_deaf = 0
	if (src.ear_damage < 25)
		src.ear_damage = 0

	src.density = !( src.lying )

	if (src.sdisabilities & BLIND)
		src.blinded = 1
	if (src.sdisabilities & DEAF)
		src.ear_deaf = 1

	if (src.eye_blurry > 0)
		setBlurriness(0)

	if (src.druggy > 0)
		setDrugginess(0)

	return 1

/mob/living/carbon/slime/proc/handle_attack()
	if(!ATarget)
		return
	if(Victim && Victim != ATarget)
		Feedstop()
	TargetAttack()
	return
/mob/living/carbon/slime/handle_nutrition()
	if(prob(20))
		if(isslimeadult(src)) nutrition-=rand(4,6)
		else nutrition-=rand(2,3)

	if(nutrition <= 0)
		nutrition = 0
		if(prob(75))

			adjustToxLoss(rand(0,5))

	else
		if(isslimeadult(src))
			if(nutrition >= 1000)
				if(prob(40)) amount_grown++

		else
			if(nutrition >= 800)
				if(prob(40)) amount_grown++

	if(amount_grown >= max_grown && !Victim && !Target)
		if(isslimeadult(src))
			if(!client)
				for(var/i=1,i<=4,i++)
					if(prob(70))
						var/mob/living/carbon/slime/M = new primarytype(loc)
						M.powerlevel = round(powerlevel/4)
						M.Friends = Friends.Copy()
						M.tame = tame
						M.rabid = rabid
						M.Discipline = Discipline
						if(i != 1) step_away(M,src)
					else
						var/mutations = pick("one","two","three","four")
						switch(mutations)
							if("one")
								var/mob/living/carbon/slime/M = new mutationone(loc)
								M.powerlevel = round(powerlevel/4)
								M.Friends = Friends.Copy()
								M.tame = tame
								M.rabid = rabid
								M.Discipline = Discipline
								if(i != 1) step_away(M,src)
							if("two")
								var/mob/living/carbon/slime/M = new mutationtwo(loc)
								M.powerlevel = round(powerlevel/4)
								M.Friends = Friends.Copy()
								M.tame = tame
								M.rabid = rabid
								M.Discipline = Discipline
								if(i != 1) step_away(M,src)
							if("three")
								var/mob/living/carbon/slime/M = new mutationthree(loc)
								M.powerlevel = round(powerlevel/4)
								M.Friends = Friends.Copy()
								M.tame = tame
								M.rabid = rabid
								M.Discipline = Discipline
								if(i != 1) step_away(M,src)
							if("four")
								var/mob/living/carbon/slime/M = new mutationfour(loc)
								M.powerlevel = round(powerlevel/4)
								M.Friends = Friends.Copy()
								M.tame = tame
								M.rabid = rabid
								M.Discipline = Discipline
								if(i != 1) step_away(M,src)

				qdel(src)

		else
			if(!client)
				var/mob/living/carbon/slime/adult/A = new adulttype(src.loc)
				A.nutrition = nutrition
//				A.nutrition += 100
				A.powerlevel = max(0, powerlevel-1)
				A.Friends = Friends.Copy()
				A.tame = tame
				A.rabid = rabid
				qdel(src)


/mob/living/carbon/slime/proc/handle_targets()
	if(Tempstun)
		if(!Victim) // not while they're eating!
			canmove = 0
	else
		canmove = 1

	if(attacked > 50) attacked = 50

	if(attacked > 0)
		attacked--

	if(Discipline > 0)

		if(Discipline >= 5 && rabid)
			if(prob(60)) rabid = 0

		if(prob(10))
			Discipline--

	if(!client)
		if(!canmove) return

		if(Victim) return // if it's eating someone already, continue eating!

		if(Target)
			--target_patience
			if (target_patience <= 0 || SStun || Discipline || attacked) // Tired of chasing or something draws out attention
				target_patience = 0
				Target = null

		if(AIproc && SStun) return

		var/hungry = 0 // determines if the slime is hungry

		if (nutrition < get_starve_nutrition())
			hungry = 2
		else if (nutrition < get_grow_nutrition() && prob(25) || nutrition < get_hunger_nutrition())
			hungry = 1

		if(hungry == 2 && !client) // if a slime is starving, it starts losing its friends
			if(Friends.len > 0 && prob(1))
				var/list/BFriends = list()
				for(var/mob/M in Friends)
					if(Friends[M] < 10)
						BFriends.Add(M)
				if(BFriends.len > 0)
					var/mob/nofriend = pick(BFriends)
					--Friends[nofriend]

		if(!Target)
			if(will_hunt() && hungry || attacked || rabid) // Only add to the list if we need to
				var/list/targets = list()

				for(var/mob/living/L in view(7,src))
					if(L.get_species() == IPC) //Ignore IPC
						continue

					if(L.get_species() == SLIME || L.stat == DEAD) // Ignore other slimes and dead mobs
						continue

					if(HAS_TRAIT(L, TRAIT_NATURECHILD) && L.naturechild_check())
						continue

					if(L in Friends) // No eating friends!
						continue

					if(issilicon(L) && (rabid || attacked)) // They can't eat silicons, but they can glomp them in defence
						targets += L // Possible target found!

					if(!L.canmove) // Only one slime can latch on at a time.
						var/notarget = 0
						for(var/mob/living/carbon/slime/M in view(1,L))
							if(M.Victim == L)
								notarget = 1
						if(notarget)
							continue

					targets += L // Possible target found!

				if(targets.len > 0)
					if(attacked || rabid || hungry == 2)
						Target = targets[1] // I am attacked and am fighting back or so hungry I don't even care
					else
						for(var/mob/living/carbon/C in targets)
							if(!Discipline && prob(5))
								if(ishuman(C) || isxenoadult(C))
									Target = C
									break

							if(isxenolarva(C) || isfacehugger(C) || ismonkey(C))
								Target = C
								break

			if (Target)
				target_patience = rand(5,7)
				if (isslimeadult(src))
					target_patience += 3

		if(!Target) // If we have no target, we are wandering or following orders
			if (Leader)
				if(holding_still)
					holding_still = max(holding_still - 1, 0)
				else if(canmove && isturf(loc))
					step_to(src, Leader)

			else if(hungry)
				if (holding_still)
					holding_still = max(holding_still - hungry, 0)
				else if(canmove && isturf(loc) && prob(50))
					step(src, pick(cardinal))

			else
				if(holding_still)
					holding_still = max(holding_still - 1, 0)
				else if(canmove && isturf(loc) && prob(33))
					step(src, pick(cardinal))
		else if(!AIproc)
			spawn()
				AIprocess()

//TG slime speech & mood port.
/mob/living/carbon/slime/proc/handle_mood()
	var/newmood = ""
	if (rabid || attacked)
		newmood = "angry"
	//else if (docile)
	//	newmood = ":3"
	else if (Target)
		newmood = "mischevous"

	if (!newmood)
		if (Discipline && prob(25))
			newmood = "pout"
		else if (prob(1))
			newmood = pick("sad", ":3", "pout")

	if ((mood == "sad" || mood == ":3" || mood == "pout") && !newmood)
		if(prob(75))
			newmood = mood

	if (newmood != mood) // This is so we don't redraw them every time
		mood = newmood
		regenerate_icons()

/mob/living/carbon/slime/proc/handle_speech()
	//Speech understanding starts here
	var/to_say
	if (speech_buffer.len > 0)
		var/who = speech_buffer[1] // Who said it?
		var/phrase = lowertext(speech_buffer[2]) // What did they say?
		if ((findtext(phrase, num2text(number)) || findtext(phrase, "слайм") || findtext(phrase, "легион"))) // Talking to us
			if (                                                                  \
				findtext(phrase, "здравствуй") || findtext(phrase, "привет")    \
			)
				to_say = pick("Здравствуй...", "Привет...")
			else if (                                                             \
				findtext(phrase, "убить") || findtext(phrase, "уничтожить") ||    \
				findtext(phrase, "атак")                                          \
			)
				if(Friends[who] > 4)
					if(last_pointed)
						if(!(Friends[last_pointed] >=2) && !(isslime(last_pointed) && Friends[who] > 6))
							if(holding_still)
								holding_still = 0
							if(last_pointed != src)
								to_say = pick("Я уничтожу [last_pointed]...", "Убить [last_pointed]...", "[last_pointed]... злодей...")
								ATarget = last_pointed
								last_pointed = null
							else
								to_say = pick("Пожалуйста... Нет....", "Нее...", "Не нужно...")
								Friends.Remove(who) // TRAITOR!
								last_pointed = null
						else
							to_say = pick("Я не хочу убивать друзей...", "Это мой друг...", "Друг...", "Это не враг...")
							last_pointed = null
					else
						to_say = pick("Кто...", "Кого...")
				else
					to_say = pick("Я не хочу...", "Нет...", "Не хочу...", "Неее...")
			else if (                                                             \
				findtext(phrase, "ко мне") ||                                     \
				findtext(phrase, "за мной")                                       \
			)
				if (Leader)
					if (holding_still)
						holding_still = 0
					if (Leader == who) // Already following him
						to_say = pick("Да...", "Иду...", "Следую...", "За тобой...")
					else if (Friends[who] > Friends[Leader]) // VIVA
						Leader = who
						to_say = "Да... Я иду за [who]..."
					else
						to_say = "Нет... Я иду за [Leader]..."
				else
					if (Friends[who] > 2)
						if (holding_still)
							holding_still = 0
						Leader = who
						to_say = pick("Следую...", "Иду...", "Да...")
					else // Not friendly enough
						to_say = pick("Нет...", "Не хочу...", "Не верю...")
			else if (                                                            \
				findtext(phrase, "перестань") ||                                 \
				findtext(phrase, "хватит") || findtext(phrase, "стоп")           \
			)
				if (Victim) // We are asked to stop feeding
					if (Friends[who] > 4)
						Victim = null
						Target = null
						if (Friends[who] < 7 && (Victim != ATarget))
							--Friends[who]
							to_say = "Гррр..." // I'm angry but I do it
						else
							if(Victim == ATarget)
								ATarget = null
							to_say = "Ладно..."
					else
						to_say = "Нет..."
				else if (Target) // We are asked to stop chasing
					if (Friends[who] > 3)
						Target = null
						if (Friends[who] < 6)
							--Friends[who]
							to_say = "Гррр..." // I'm angry but I do it
						else
							to_say = "Ладно..."
				else if (Leader) // We are asked to stop following
					if (Leader == who)
						to_say = "Ладно... Жду..."
						Leader = null
					else
						if (Friends[who] > Friends[Leader])
							Leader = null
							to_say = "Да... Я подожду..."
						else
							to_say = "Нет... Я хочу за другом..."
				else if (holding_still)
					if(Friends[who] > 2)
						to_say = "Ладно..."
						holding_still = 0
					else
						to_say = "Нет..."
				else if (ATarget)
					if(Friends[who] > 4)
						last_pointed = null
						ATarget = null
						to_say = "Хорошо..."
					else
						to_say = "Нее..."

			else if (                                                           \
				findtext(phrase, "остановитесь") ||                             \
				findtext(phrase, "стой") || findtext(phrase, "не двигайся")     \
			)
				if (Leader)
					if (Leader == who)
						Leader = null
						holding_still = Friends[who] * 10
						to_say = "Ладно... Жду..."
					else if (Friends[who] > Friends[Leader])
						Leader = null
						holding_still = (Friends[who] - Friends[Leader]) * 10
						to_say = "Да... Стою..."
					else
						to_say = "Нет... Пойду за другом..."
				else
					if (Friends[who] > 2)
						holding_still = Friends[who] * 10
						to_say = "Хорошо... Подожду..."
					else
						to_say = "Нет... Я не хочу..."
		speech_buffer = list()

	//Speech starts here
	if (to_say)
		say (to_say)
	else if(prob(1))
		var/list/rand_emote = list(
			"подпрыгивает на месте.",
			"раскачивается.",
			"загорается, затем тухнет.",
			"вибрирует.",
			"покачивается.",
		)
		me_emote(pick(rand_emote))
	else
		var/t = 10
		var/slimes_near = 0
		var/dead_slimes = 0
		var/friends_near = list()
		for (var/mob/living/L in view(7,src))
			if(isslime(L) && L != src)
				++slimes_near
				if (L.stat == DEAD)
					++dead_slimes
			if (L in Friends)
				t += 20
				friends_near += L
		if (nutrition < get_hunger_nutrition()) t += 10
		if (nutrition < get_starve_nutrition()) t += 10
		if (prob(2) && prob(t))
			var/phrases = list()
			if (Target) phrases += "[Target]... выглядит вкусно..."
			if (nutrition < get_starve_nutrition())
				phrases += "Так... голоден..."
				phrases += "Очень... голоден..."
				phrases += "Хочу... есть..."
				phrases += "Должен... есть..."
			else if (nutrition < get_hunger_nutrition())
				phrases += "Голоден..."
				phrases += "Где еда..?"
				phrases += "Хочу есть..."
			phrases += "Ррра..."
			phrases += "Блюп..."
			phrases += "Блорь..."
			if (rabid || attacked)
				phrases += "Хрр..."
				phrases += "Нээ..."
				phrases += "Упп..."
			if (mood == ":3")
				phrases += "Мурр..."
			if (attacked)
				phrases += "Грр..."
			if (bodytemperature < T0C)
				phrases += "Холодно..."
			if (bodytemperature < T0C - 30)
				phrases += "Так... холодно..."
				phrases += "Очень... холодно..."
			if (bodytemperature < T0C - 50)
				phrases += "..."
				phrases += "Хол...лодно..."
			if (Victim)
				phrases += "Ном..."
				phrases += "Вкусно..."
			if (powerlevel > 3) phrases += "Бззз..."
			if (powerlevel > 5) phrases += "Зап..."
			if (powerlevel > 8) phrases += "Зап... Бзз..."
			if (mood == "sad") phrases += "Скучно..."
			if (slimes_near) phrases += "Брат..."
			if (slimes_near > 1) phrases += "Братья..."
			if (dead_slimes) phrases += "Что происходит..?"
			if (!slimes_near)
				phrases += "Одиноко..."
			for (var/M in friends_near)
				phrases += "[M]... друг..."
				if (nutrition < get_hunger_nutrition())
					phrases += "[M]... покорми..."
			say (pick(phrases))

/mob/living/carbon/slime/count_pull_debuff()
	return pulling ? ..() + 1.5 : 0

/mob/living/carbon/slime/proc/will_hunt(hunger = -1) // Check for being stopped from feeding and chasing
	//if (docile)	return 0
	if (hunger == 2 || rabid || attacked) return 1
	if (Leader) return 0
	if (holding_still) return 0
	return 1

/mob/living/carbon/slime/proc/get_max_nutrition() // Can't go above it
	if (isslimeadult(src)) return 1200
	else return 1000

/mob/living/carbon/slime/proc/get_grow_nutrition() // Above it we grow, below it we can eat
	if (isslimeadult(src)) return 1000
	else return 800

/mob/living/carbon/slime/proc/get_hunger_nutrition() // Below it we will always eat
	if (isslimeadult(src)) return 600
	else return 500

/mob/living/carbon/slime/proc/get_starve_nutrition() // Below it we will eat before everything else
	if(isslimeadult(src)) return 300
	else return 200
