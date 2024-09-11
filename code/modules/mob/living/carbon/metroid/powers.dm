
/datum/action/innate/slime
	var/needs_growth = FALSE

/datum/action/innate/slime/IsAvailable()
	if(!..())
		return
	var/mob/living/carbon/slime/S = owner
	if(needs_growth && S.amount_grown < 10)
		return FALSE
	if(S.incapacitated())
		return FALSE
	return TRUE

/datum/action/innate/slime/feed
	name = "Feed"
	button_icon_state = "slimeeat"

/datum/action/innate/slime/feed/Activate()
	var/mob/living/carbon/slime/S = owner
	S.Feed()

/datum/action/innate/slime/evolve
	name = "Evolve"
	button_icon_state = "slimegrow"
	needs_growth = TRUE

/datum/action/innate/slime/evolve/Activate()
	var/mob/living/carbon/slime/S = owner
	S.Evolve()

/datum/action/innate/slime/reproduce
	name = "Reproduce"
	button_icon_state = "slimesplit"
	needs_growth = TRUE

/datum/action/innate/slime/reproduce/Activate()
	var/mob/living/carbon/slime/S = owner
	S.Reproduce()

/mob/living/carbon/slime/verb/Feed()
	set category = "Slime"
	set desc = "This will let you feed on any valid creature in the surrounding area. This should also be used to halt the feeding process."

	if(incapacitated())
		to_chat(src, "<i>I must be conscious to do this...</i>")
		return

	if(Victim)
		Feedstop()
		return

	var/list/choices = list()
	for(var/mob/living/nearby_mob in view(1,src))
		if(nearby_mob != src && !isslime(nearby_mob))
			choices += nearby_mob

	var/choice = tgui_input_list(src, "Who do you wish to feed on?", "Slime Feed", sortTim(choices, GLOBAL_PROC_REF(cmp_name_asc)))
	if(!isliving(choice))
		return

	var/mob/living/victim = choice

	if(isbrain(victim) || issilicon(victim))
		to_chat(src, "<i>This subject does not have an edible life energy...</i>")
		return

	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		if(H.species.name in list(IPC, DIONA, GOLEM))
			to_chat(src, "<i>This subject does not have an edible life energy...</i>")
			return

	if(victim.stat == DEAD || victim.health < -70 )
		to_chat(src, "<i>This subject does not have a strong enough life energy...</i>")
		return

	if(!Adjacent(victim))
		return

	for(var/mob/living/carbon/slime/S in view(1, Victim))
		if(S.Victim == victim)
			to_chat(src, "<i>Another slime is already feeding on this subject...</i>")
			return

	to_chat(src, "<span class='notice'><i>I have latched onto the subject and begun feeding...</i></span>")
	to_chat(victim, "<span class='warning'><b>The [src.name] has latched onto your head!</b></span>")
	Feedon(victim)

/mob/living/carbon/slime/proc/Feedon(mob/living/carbon/M)
	Victim = M
	src.loc = M.loc
	canmove = 0
	anchored = TRUE
	var/lastnut = nutrition
	if(isslimeadult(src))
		icon_state = "[colour] adult slime eat"
	else
		icon_state = "[colour] baby slime eat"

	while(Victim && M.health > -70 && stat != DEAD)
		canmove = 0

		if(M in view(1, src))
			loc = M.loc

			if(prob(15) && M.client && iscarbon(M))
				to_chat(M, "<span class='warning'>[pick("You can feel your body becoming weak!", \
				"You feel like you're about to die!", \
				"You feel every part of your body screaming in agony!", \
				"A low, rolling pain passes through your body!", \
				"Your body feels as if it's falling apart!", \
				"You feel extremely weak!", \
				"A sharp, deep pain bathes every inch of your body!")]</span>")

			if(iscarbon(M))
				Victim.adjustCloneLoss(rand(1,10))
				Victim.adjustToxLoss(rand(1,2))
				if(Victim.health <= 0)
					Victim.adjustToxLoss(rand(2,4))

				// Heal yourself
				adjustToxLoss(-10)
				adjustOxyLoss(-10)
				adjustBruteLoss(-10)
				adjustFireLoss(-10)
				adjustCloneLoss(-10)

				if(Victim)
					for(var/mob/living/carbon/slime/slime in view(1,M))
						if(slime.Victim == M && slime != src)
							slime.Feedstop()

				nutrition += rand(10,25)
				if(nutrition >= lastnut + 50)
					if(prob(80))
						lastnut = nutrition
						powerlevel++
						if(powerlevel > 10)
							powerlevel = 10

				if(isslimeadult(src))
					if(nutrition > 1200)
						nutrition = 1200
				else
					if(nutrition > 1000)
						nutrition = 1000

				Victim.updatehealth()
				updatehealth()

			else
				if(prob(25))
					to_chat(src, "<span class='warning'><i>[pick("This subject is incompatable", \
					"This subject does not have a life energy", "This subject is empty", \
					"I am not satisified", "I can not feed from this subject", \
					"I do not feel nourished", "This subject is not food")]...</i></span>")

			sleep(rand(15,45))

		else
			break

	if(stat == DEAD)
		if(!isslimeadult(src))
			icon_state = "[colour] baby slime dead"

	else
		if(isslimeadult(src))
			icon_state = "[colour] adult slime"
		else
			icon_state = "[colour] baby slime"

	canmove = 1
	anchored = FALSE

	if(M)
		if(M.health <= -70)
			M.canmove = 0
			if(!client)
				if(Victim && !rabid && !attacked)
					if(Victim.LAssailant && Victim.LAssailant != Victim)
						if(prob(50))
							if(!(Victim.LAssailant in Friends))
								Friends[Victim.LAssailant] = 1
							else
								++Friends[Victim.LAssailant]
			if(M.client && ishuman(src))
				if(prob(85))
					rabid = 1 // UUUNNBGHHHH GONNA EAT JUUUUUU

			if(client)
				to_chat(src, "<i>This subject does not have a strong enough life energy anymore...</i>")
		else
			M.canmove = 1

			if(client)
				to_chat(src, "<i>I have stopped feeding...</i>")
	else
		if(client)
			to_chat(src, "<i>I have stopped feeding...</i>")

	Victim = null

/mob/living/carbon/slime/proc/Feedstop()
	if(Victim)
		if(Victim.client)
			to_chat(Victim, "[src] has let go of your head!")
		Victim = null

/mob/living/carbon/slime/proc/UpdateFeed(mob/M)
	if(Victim)
		if(Victim == M)
			loc = M.loc // simple "attach to head" effect!


/mob/living/carbon/slime/verb/Evolve()
	set category = "Slime"
	set desc = "This will let you evolve from baby to adult slime."

	if(incapacitated())
		to_chat(src, "<i>I must be conscious to do this...</i>")
		return
	if(!isslimeadult(src))
		if(amount_grown >= max_grown)
			var/mob/living/carbon/slime/adult/new_slime = new adulttype(loc)
			new_slime.nutrition = nutrition
			new_slime.powerlevel = max(0, powerlevel-1)
			new_slime.set_a_intent(INTENT_HARM)
			new_slime.key = key
			new_slime.universal_speak = universal_speak
			to_chat(new_slime, "<B>You are now an adult slime.</B>")
			qdel(src)
		else
			to_chat(src, "<i>I am not ready to evolve yet...</i>")
	else
		to_chat(src, "<i>I have already evolved...</i>")

/mob/living/carbon/slime/verb/Reproduce()
	set category = "Slime"
	set desc = "This will make you split into four Slimes. NOTE: this will KILL you, but you will be transferred into one of the babies."

	if(incapacitated())
		to_chat(src, "<i>I must be conscious to do this...</i>")
		return

	if(isslimeadult(src))
		if(amount_grown >= max_grown)
			var/list/babies = list()
			var/new_nutrition = round(nutrition * 0.9)
			var/new_powerlevel = round(powerlevel / 4)
			for(var/i=1,i<=4,i++)
				if(prob(80))
					var/mob/living/carbon/slime/M = new primarytype(loc)
					M.nutrition = new_nutrition
					M.powerlevel = new_powerlevel
					if(i != 1) step_away(M,src)
					babies += M
				else
					var/mutations = pick("one","two","three","four")
					switch(mutations)
						if("one")
							var/mob/living/carbon/slime/M = new mutationone(loc)
							M.nutrition = new_nutrition
							M.powerlevel = new_powerlevel
							if(i != 1) step_away(M,src)
							babies += M
						if("two")
							var/mob/living/carbon/slime/M = new mutationtwo(loc)
							M.nutrition = new_nutrition
							M.powerlevel = new_powerlevel
							if(i != 1) step_away(M,src)
							babies += M
						if("three")
							var/mob/living/carbon/slime/M = new mutationthree(loc)
							M.nutrition = new_nutrition
							M.powerlevel = new_powerlevel
							if(i != 1) step_away(M,src)
							babies += M
						if("four")
							var/mob/living/carbon/slime/M = new mutationfour(loc)
							M.nutrition = new_nutrition
							M.powerlevel = new_powerlevel
							if(i != 1) step_away(M,src)
							babies += M

			var/mob/living/carbon/slime/new_slime = pick(babies)
			new_slime.set_a_intent(INTENT_HARM)
			new_slime.universal_speak = universal_speak
			new_slime.key = key

			to_chat(new_slime, "<B>You are now a slime!</B>")
			qdel(src)
		else
			to_chat(src, "<i>I am not ready to reproduce yet...</i>")
	else
		to_chat(src, "<i>I am not old enough to reproduce yet...</i>")
