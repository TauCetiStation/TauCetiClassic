#define BRAINSWAP_TIME 50

var/list/cult_runes = list()

/datum/cult
	var/obj/holder
	var/word1
	var/word2
	var/word3
	var/only_rune = FALSE

/datum/cult/New(holder)
	if(!holder)
		qdel(src)
		CRASH("someone stupid tried to create datum without holder")
	src.holder = holder

/datum/cult/Destroy()
	holder = null
	return ..()

/datum/cult/proc/action(mob/living/carbon/user)
	return

/datum/cult/proc/holder_reaction(mob/living/carbon/user)
	if(istype(holder, /obj/effect/rune))
		return rune_reaction(user)
	return talisman_reaction(user)

/datum/cult/proc/rune_reaction(mob/living/carbon/user)
	return

/datum/cult/proc/talisman_reaction(mob/living/carbon/user)
	return

/datum/cult/proc/nearest_cultists(range = 1, message)
	var/list/acolytes = list()
	var/turf/center = get_turf(holder)
	for(var/mob/living/carbon/C in range(range, center))
		if(iscultist(C) && !C.stat)
			acolytes += C
			if(message)
				C.say(message)
	return acolytes

/datum/cult/proc/nearest_heretics(range = 7, ignore_nullrod = FALSE)
	var/list/heretics = list()
	var/turf/center = get_turf(holder)
	for(var/mob/living/heretic in view(range, center))
		if(iscultist(heretic))
			continue
		if(!ignore_nullrod)
			var/obj/item/weapon/nullrod/N = locate() in heretic
			if(N)
				continue
		heretics += heretic
	return heretics

/datum/cult/proc/fizzle(mob/living/user)
	if(istype(holder, /obj/effect/rune))
		user.say(pick("Hakkrutju gopoenjim.", "Nherasai pivroiashan.", "Firjji prhiv mazenhor.", "Tanah eh wakantahe.", "Obliyae na oraie.", "Miyf hon vnor'c.", "Wakabai hij fen juswix."))
	else
		user.whisper(pick("Hakkrutju gopoenjim.", "Nherasai pivroiashan.", "Firjji prhiv mazenhor.",\
			"Tanah eh wakantahe.", "Obliyae na oraie.", "Miyf hon vnor'c.", "Wakabai hij fen juswix."))
	holder.visible_message("<span class='danger'>The markings pulse with a small burst of light, \
		then fall dark.</span>","<span class='danger'>You hear a faint fizzle.</span>")


/datum/cult/teleport
	word1 = "travel"
	word2 = "self"

/datum/cult/teleport/New(holder, word3)
	..()
	src.word3 = word3

/datum/cult/teleport/rune_reaction(mob/living/carbon/user)
	user.say("Sas[pick("'","`")]so c'arta forbici!")

/datum/cult/teleport/talisman_reaction(mob/living/carbon/user)
	user.whisper("Sas[pick("'","`")]so c'arta forbici!")
	qdel(holder)

/datum/cult/teleport/action(mob/living/carbon/user)
	var/list/allrunes = list()
	for(var/obj/effect/rune/R in cult_runes)
		if(!istype(R.power, type) || R.power == src)
			continue
		if(R.power.word3 == src.word3 && !is_centcom_level(R.loc.z))
			allrunes += R

	var/length = length(allrunes)
	if(length >= 5)
		to_chat(user, "<span class='userdanger'>You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric.</span>")
		user.take_overall_damage(5, 0)
		qdel(holder)
		return FALSE
	else if(length)
		user.visible_message("<span class='userdanger'>[user] disappears in a flash of red light!</span>", \
			"<span class='cult'>You feel as your body gets dragged through the dimension of Nar-Sie!</span>", \
			"<span class='userdanger'>You hear a sickening crunch and sloshing of viscera.</span>")
		playsound(user, 'sound/magic/Teleport_diss.ogg', VOL_EFFECTS_MASTER)
		user.forceMove(get_turf(pick(allrunes)))
		playsound(user, 'sound/magic/Teleport_app.ogg', VOL_EFFECTS_MASTER)
		return holder_reaction(user)
	fizzle(user)

/datum/cult/item_port
	word1 = "travel"
	word2 = "other"
	only_rune = TRUE

/datum/cult/item_port/New(holder, word3)
	..()
	src.word3 = word3

/datum/cult/item_port/action(mob/living/carbon/user)
	var/list/allrunes = list()
	var/list/acolytes = nearest_cultists(1, "Sas[pick("'","`")]so c'arta forbici tarem!")
	if(length(acolytes) < 3)
		return fizzle(user)
	for(var/obj/effect/rune/R in cult_runes)
		if(!istype(R.power, type) || R.power == src)
			continue
		if(!is_centcom_level(R.loc.z) && R.power.word3 == src.word3)
			allrunes += R
	var/length = length(allrunes)
	if(length >= 5)
		to_chat(user, "<span class='cult'>You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric.</span>")
		user.take_overall_damage(5, 0)
		qdel(holder)
		return
	else if(length)
		var/obj/teleport_holder = pick(allrunes)
		var/passed = FALSE
		for(var/obj/O in holder.loc)
			var/with_mob = FALSE
			passed = TRUE
			for(var/mob/living/L in O.contents)
				with_mob = TRUE
				break
			if(!with_mob && !O.anchored && !O.freeze_movement)
				O.visible_message("<span class='danger'>The [O] suddenly disappears!</span>")
				O.forceMove(teleport_holder.loc)
				O.visible_message("<span class='danger'>The [O] suddenly appears!</span>")
		if(passed)
			playsound(holder, 'sound/magic/SummonItems_generic.ogg', VOL_EFFECTS_MASTER)
			playsound(teleport_holder, 'sound/magic/SummonItems_generic.ogg', VOL_EFFECTS_MASTER)
			user.visible_message("<span class='userdanger'>You feel air moving from the rune - like as it was swapped with somewhere else.</span>", \
				"<span class='cult'>You feel air moving from the rune - like as it was swapped with somewhere else.</span>", \
				"<span class='userdanger'>You smell ozone.</span>")

/datum/cult/tome_summon
	word1 = "see"
	word2 = "blood"
	word3 = "hell"

/datum/cult/tome_summon/rune_reaction(mob/living/carbon/user)
	user.say("N[pick("'","`")]ath reth sh'yro eth d'raggathnor!")

/datum/cult/tome_summon/talisman_reaction(mob/living/carbon/user)
	user.whisper("N[pick("'","`")]ath reth sh'yro eth d'raggathnor!")

/datum/cult/tome_summon/action(mob/living/carbon/user)
	holder_reaction(user)
	user.visible_message("<span class='userdanger'>Rune disappears with a flash of red light, and in its place now a book lies.</span>", \
		"<span class='userdanger'>You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a book.</span>", \
		"<span class='userdanger'>You hear a pop and smell ozone.</span>")
	new /obj/item/weapon/book/tome(get_turf(holder))
	qdel(holder)

/datum/cult/convert
	word1 = "join"
	word2 = "blood"
	word3 = "self"
	only_rune = TRUE
	var/in_use = FALSE

/datum/cult/convert/action(mob/living/carbon/user)
	if(in_use)
		to_chat(user, "<span class='cult'>This Rune is in use now!</span>")
		return fizzle(user)
	for(var/mob/living/carbon/M in get_turf(holder))
		if(iscultist(M) || M.stat == DEAD)
			continue
		user.say("Mah[pick("'","`")]weyh pleggh at e'ntrath!")
		M.visible_message("<span class='userdanger'>[M] writhes in pain as the markings below him glow a bloody red.</span>", \
			"<span class='cult'>AAAAAAHHHH!</span>", \
			"<span class='userdanger'>You hear an anguished scream.</span>")
		in_use = TRUE
		if(alert(M, "Do you wanna to gave your soul to the Geometr?",,"Yes", "No") == "Yes")
			to_chat(M, "<span class='cult'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth.\
				The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</span>")

			var/passed = TRUE
			if(!is_convertable_to_cult(M.mind))
				passed = FALSE
				to_chat(user, "<span class='cult'The mind of [M] Resists!</span>")
				to_chat(M, "<span class='userdanger'Your Mind Resists!</span>")
			else if(jobban_isbanned(M, ROLE_CULTIST) || jobban_isbanned(M, "Syndicate"))
				passed = FALSE
				to_chat(user, "<span class='cult'Your god forbade recruitment of [M]!</span>")

			else if(role_available_in_minutes(M, ROLE_CULTIST))
				passed = FALSE
				to_chat(user, "<span class='cult'This soul is too young for your God!</span>")

			if(passed)
				SSticker.mode.add_cultist(M.mind)
				M.mind.special_role = "Cultist"
				to_chat(M, "<span class='cult'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark \
					One above all else. Bring It back.</span>")
			else
				to_chat(M, "<span class='userdanger'>And you were able to force it out of your mind. You now know the truth, there's something horrible out there, \
					stop it and its minions at all costs.</span>")
		else
			to_chat(user, "<span class='userdanger'>Filthy heretic has rejected your gift!</span>")
		break
	in_use = FALSE
	return fizzle(user)

/datum/cult/tearreality
	word1 = "hell"
	word2 = "join"
	word3 = "self"
	only_rune = TRUE

/datum/cult/tearreality/action(mob/living/carbon/user)
	var/acolytes = nearest_cultists(1, "Tok-lyr rqa'nap g[pick("'","`")]lt-ulotf!")
	if(length(acolytes) < 9)
		return fizzle(user)

	if(SSticker.mode.nar_sie_has_risen)
		for(var/mob/living/carbon/C in acolytes)
			to_chat(C, "<font size='4'><span class='danger'>I am already here!</span></font>")
			return
	if(!istype(SSticker.mode, /datum/game_mode/cult))
		return
	var/datum/game_mode/cult/cur_mode = SSticker.mode
	for(var/objective in cur_mode.objectives)
		if(objective == "eldergod")
			SSticker.mode.nar_sie_has_risen = TRUE
			cur_mode.eldergod = FALSE
			new /obj/singularity/narsie/large(get_turf(holder))
			return
	cur_mode.eldertry += 1
	switch(cur_mode.eldertry)
		if(1)
			for(var/mob/living/carbon/C in acolytes)
				to_chat(C, "<font size='3'><span class='danger'>I have no interest in coming to your world.</span></font>")
		if(5)
			for(var/mob/living/carbon/C in acolytes)
				C.apply_effect(80, AGONY, 0)
				to_chat(C, "<font size='4'><span class='danger'>I SAID NO!!</span></font>")
		if(10)
			for(var/mob/living/carbon/C in acolytes)
				C.apply_effect(80, AGONY, 0)
				to_chat(C, "<font size='5'><span class='danger'>LAST WARNING.</span></font>")
		if(15 to 100)
			for(var/mob/living/carbon/C in acolytes)
				C.gib()
			to_chat(world, "<font size='15'><span class='danger'>FUCK YOU!!!</span></font>")
			cur_mode.eldertry = 0


/datum/cult/emp
	word1 = "destroy"
	word2 = "see"
	word3 = "technology"

/datum/cult/emp/rune_reaction(mob/living/carbon/user)
	user.say("Ta'gh fara[pick("'","`")]qha fel d'amar det!")
	return 3

/datum/cult/emp/talisman_reaction(mob/living/carbon/user)
	user.whisper("Ta'gh fara[pick("'","`")]qha fel d'amar det!")
	return 5

/datum/cult/emp/action(mob/living/carbon/user)
	var/emp_power = holder_reaction(user)
	var/turf/turf = get_turf(holder)
	playsound(holder, 'sound/items/Welder2.ogg', VOL_EFFECTS_MASTER, 25)
	turf.hotspot_expose(700,125)
	empulse(turf, (emp_power - 2), emp_power)
	qdel(holder)

/datum/cult/drain
	word1 = "travel"
	word2 = "blood"
	word3 = "self"
	only_rune = TRUE

/mob/living/carbon/proc/drain_dot(loop_value) //recursive proc to Imitate "damage over time" mechanics
	if(loop_value > 0 && src && stat != DEAD)
		take_overall_damage(3, 0)
		addtimer(CALLBACK(src, .proc/drain_dot, --loop_value), 20)

/datum/cult/drain/action(mob/living/carbon/user)
	var/drain = 0
	for(var/obj/effect/rune/R in cult_runes)
		if(!istype(R.power, type))
			continue
		for(var/mob/living/carbon/C in R.loc)
			if(C.stat != DEAD && C != user)
				var/bdrain = rand(1, 25)
				to_chat(C, "<span class='userdanger'>You feel weakened.</span>")
				C.take_overall_damage(bdrain, 0)
				playsound(R, 'sound/magic/transfer_blood.ogg', VOL_EFFECTS_MASTER)
				drain += bdrain
	if(!drain)
		return fizzle(user)
	user.say ("Yu[pick("'","`")]gular faras desdae. Havas mithum javara. Umathar uf'kal thenar!")
	user.visible_message("<span class='userdanger'>Blood flows from the rune into [user]!</span>", \
		"<span class='cult'>The blood starts flowing from the rune and into your frail mortal body. You feel... empowered.</span>", \
		"<span class='userdanger'>You hear a liquid flowing.</span>")
	if(drain >= 40)
		user.visible_message("<span class='userdanger'>[user]'s eyes give off eerie red glow!</span>", \
			"<span class='cult'>...but it wasn't nearly enough. You crave, crave for more. The hunger consumes you from within.</span>", \
			"<span class='userdanger'>You hear a heartbeat.</span>")
		user.drain_dot(drain)
		return
	if(prob(drain * 1.5) && ishuman(user))
		var/mob/living/carbon/human/H = user
		for(var/obj/item/organ/external/BP in H.bodyparts)
			if(BP.is_stump || BP.status & (ORGAN_BROKEN | ORGAN_SPLINTED | ORGAN_DEAD | ORGAN_ARTERY_CUT))
				BP.rejuvenate()
				to_chat(user, "<span class='cult'>You were honored by Nar-Sie. You can feel his power in your [BP]</span>")
				break
	user.heal_overall_damage(1.2 * drain, drain)

/datum/cult/seer
	word1 = "see"
	word2 = "hell"
	word3 = "join"
	only_rune = TRUE

/datum/cult/seer/action(mob/living/carbon/human/user)
	if(!istype(user)) // until only human life proc supporting seer
		return
	if(user.loc != holder.loc)
		return fizzle(user)

	if(user.seer)
		user.say("Rash'tla sektath mal[pick("'","`")]zua. Zasan therium viortia.")
		to_chat(user, "<span class='cult'>The world beyond fades from your vision.</span>")
		user.see_invisible = SEE_INVISIBLE_LIVING
		user.seer = FALSE
	else if(user.see_invisible != SEE_INVISIBLE_LIVING)
		to_chat(user, "<span class='cult'>The world beyond flashes your eyes but disappears quickly, as if something is disrupting your vision.</span>")
		user.see_invisible = SEE_INVISIBLE_CULT
	else
		user.say("Rash'tla sektath mal[pick("'","`")]zua. Zasan therium vivira. Itonis al'ra matum!")
		to_chat(user, "<span class='cult'>The world beyond opens to your eyes.</span>")
		user.see_invisible = SEE_INVISIBLE_CULT
		user.seer = TRUE

/datum/cult/raise
	word1 = "blood"
	word2 = "join"
	word3 = "hell"
	only_rune = TRUE

/datum/cult/raise/action(mob/living/carbon/user)
	var/mob/living/carbon/human/corpse_to_raise
	var/mob/living/carbon/human/body_to_sacrifice

	var/datum/mind/sacrifice_target
	if(istype(SSticker.mode, /datum/game_mode/cult))
		var/datum/game_mode/cult/cur_mode = SSticker.mode
		sacrifice_target = cur_mode.sacrifice_target

	for(var/mob/living/carbon/human/M in holder.loc)
		if(M.stat != DEAD)
			continue
		if(sacrifice_target && sacrifice_target == M.mind)
			to_chat(user, "<span class='cult'>The Geometer of blood wants this dead mortal for himself.</span>")
			return fizzle(user)
		if(M.mind)
			corpse_to_raise = M

	if(!corpse_to_raise)
		to_chat(user, "<span class='cult'>You require a restless spirit which clings to this world. Beckon their prescence with the sacred chants of Nar-Sie.</span>")
		return fizzle(user)

	for(var/obj/effect/rune/R in cult_runes)
		if(!istype(R.power, type) || R.power == src)
			continue
		for(var/mob/living/carbon/human/H in R.loc)
			if(H.stat == DEAD)
				continue
			if(sacrifice_target && sacrifice_target == H.mind)
				to_chat(user, "<span class='cult'>The Geometer of blood wants this still alive mortal for himself.</span>")
				return fizzle(user)
			body_to_sacrifice = H
			break

	if(!body_to_sacrifice)
		to_chat(user, "<span class='cult'>The sacrifical corpse is not dead. You must free it from this world of illusions before it may be used.</span>")
		return fizzle(user)

	corpse_to_raise.revive()
	playsound(holder, 'sound/magic/cult_revive.ogg', VOL_EFFECTS_MASTER)
	SSticker.mode.add_cultist(corpse_to_raise.mind) // all checks in proc add_cultist, No reason to worry


	user.say("Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!")
	corpse_to_raise.visible_message("<span class='cult'>[corpse_to_raise]'s eyes glow with a faint red as he stands up, slowly starting to breathe again.</span>", \
		"<span class='cult'>Life... I'm alive again...</span>", \
		"<span class='cult'>You hear a faint, slightly familiar whisper.</span>")
	body_to_sacrifice.visible_message("<span class='cult'>[body_to_sacrifice] is torn apart, a black smoke swiftly dissipating from his remains!</span>", \
		"<span class='cult'>You feel as your blood boils, tearing you apart.</span>", \
		"<span class='cult'>You hear a thousand voices, all crying in pain.</span>")
	body_to_sacrifice.gib()

	to_chat(corpse_to_raise, "<span class='cult'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. \
		The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</span>")
	to_chat(corpse_to_raise, "<span class='cult'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark \
		One above all else. Bring It back.</span>")

/datum/cult/obscure
	word1 = "hide"
	word2 = "see"
	word3 = "blood"

/datum/cult/obscure/rune_reaction(mob/living/carbon/user)
	user.say("Kla[pick("'","`")]atu barada nikt'o!")
	user.visible_message("<span class='danger'>The rune turns into gray dust, veiling the surrounding runes.</span>")
	qdel(holder)


/datum/cult/obscure/talisman_reaction(mob/living/carbon/user)
	user.whisper("Kla[pick("'","`")]atu barada nikt'o!")
	user.visible_message("<span class='danger'>Dust emanates from [user]'s hands for a moment.</span>", \
		"<span class='cult'>Your talisman turns into gray dust, veiling the surrounding runes.</span>")

/datum/cult/obscure/action(mob/living/carbon/user, radius = 4)
	var/finded = FALSE
	var/turf/center = get_turf(holder)
	for(var/obj/effect/rune/R in range(radius, center))
		if(R != holder)
			R.invisibility = INVISIBILITY_OBSERVER
		finded = TRUE
	if(finded)
		return holder_reaction(user)
	fizzle(user)

/datum/cult/ajourney
	word1 = "hell"
	word2 = "travel"
	word3 = "self"
	only_rune = TRUE
	var/mob/living/ajourned
	var/mob/dead/observer/ghost
	var/cooldown = 0

/datum/cult/ajourney/Destroy()
	if(isprocessing)
		STOP_PROCESSING(SSobj, src)
		to_chat(ghost, "<span class='cult'>The astral cord that ties your body and your spirit has been severed. \
			You are likely to wander the realm beyond until your body is finally dead and thus reunited with you.</span>")
		ghost.can_reenter_corpse = FALSE
		ghost = null
		ajourned = null
	return ..()

/datum/cult/ajourney/process()
	if(ghost)
		if(QDELETED(ghost))
			ajourned = null
			ghost = null
			STOP_PROCESSING(SSobj, src)
			return
		if(!ajourned || QDELETED(ajourned))
			STOP_PROCESSING(SSobj, src)
			to_chat(ghost, "<span class='cult'>The astral cord that ties your body and your spirit has been severed. \
				You are likely to wander the realm beyond until your body is finally dead and thus reunited with you.</span>")
			ghost.can_reenter_corpse = FALSE
			ghost = null
			ajourned = null
			return
	if(ghost.can_reenter_corpse)
		if(holder.loc != ajourned.loc)
			to_chat(ghost, "<span class='cult'>The astral cord that ties your body and your spirit has been severed!</span>")
			ghost.can_reenter_corpse = FALSE
	else if(holder.loc == ajourned.loc)
		to_chat(ghost, "<span class='cult'>The astral cord has been restored!</span>")
		ghost.can_reenter_corpse = TRUE
	if(cooldown < world.time)
		cooldown = world.time + 100
		ajourned.take_bodypart_damage(10, 0)


/datum/cult/ajourney/action(mob/living/carbon/human/user)
	if(!istype(user) || user.loc != holder.loc)
		return fizzle(user)
	user.say("Fwe[pick("'","`")]sh mah erl nyag r'ya!")
	user.visible_message("<span class='userdanger'>[user]'s eyes glow blue as \he freezes in place, absolutely motionless.</span>", \
		"<span class='userdanger'>The shadow that is your spirit separates itself from your body. You are now in the realm beyond.\
		While this is a great sight, being here strains your mind and body. Hurry...</span>", \
		"<span class='userdanger'>You hear only complete silence for a moment.</span>")
	ajourned = user
	ghost = user.ghostize(TRUE)
	playsound(holder, 'sound/effects/ghost.ogg', VOL_EFFECTS_MASTER)
	START_PROCESSING(SSobj, src)

/datum/cult/manifest
	word1 = "blood"
	word2 = "see"
	word3 = "travel"
	only_rune = TRUE
	var/mob/living/guider
	var/list/dummies = list()

/datum/cult/manifest/Destroy()
	if(isprocessing)
		for(var/mob/living/L in dummies)
			L.visible_message("<span class='userdanger'>[L] slowly dissipates into dust and bones.</span>", \
				"<span class='userdanger'>You feel pain, as bonds formed between your soul and this homunculus break.</span>", \
				"<span class='userdanger'>You hear faint rustle.</span>")
			L.dust()
		dummies.Cut()
		guider = null
		STOP_PROCESSING(SSobj, src)
	return ..()

/datum/cult/manifest/process()
	var/amount_of_dummies = length(dummies)
	if(guider && guider.loc == holder.loc && !guider.stat && guider.client && amount_of_dummies > 0)
		guider.take_bodypart_damage(2 * amount_of_dummies, 0)
	else
		for(var/mob/living/L in dummies)
			L.visible_message("<span class='userdanger'>[L] slowly dissipates into dust and bones.</span>", \
				"<span class='userdanger'>You feel pain, as bonds formed between your soul and this homunculus break.</span>", \
				"<span class='userdanger'>You hear faint rustle.</span>")
			L.dust()
		dummies.Cut()
		guider = null
		STOP_PROCESSING(SSobj, src)

/datum/cult/manifest/action(mob/living/carbon/human/user)
	if(guider && guider != user)
		return fizzle(user)
	if(user.loc != holder.loc)
		return fizzle(user)
	var/mob/dead/observer/ghost
	for(var/mob/dead/observer/O in holder.loc)
		if(!O.client || (O.mind && O.mind.current && O.mind.current.stat != DEAD))
			continue
		ghost = O
		break
	if(!ghost || jobban_isbanned(ghost, ROLE_CULTIST) || jobban_isbanned(ghost, "Syndicate") || role_available_in_minutes(ghost, ROLE_CULTIST))
		return fizzle(user)
	playsound(holder, 'sound/magic/manifest.ogg', VOL_EFFECTS_MASTER)
	user.say("Gal'h'rfikk harfrandid mud[pick("'","`")]gib!")
	var/mob/living/carbon/human/dummy/D = new(holder.loc) // in soultstone code we have block for type dummy
	user.visible_message("<span class='userdanger'>A shape forms in the center of the rune. A shape of... a man.</span>", \
		"<span class='cult'>A shape forms in the center of the rune. A shape of... a man.</span>", \
		"<span class='userdanger'>You hear liquid flowing.</span>")
	D.real_name = "Unknown"
	var/chose_name = FALSE
	for(var/obj/item/weapon/paper/P in holder.loc)
		if(P.info)
			D.real_name = copytext(P.info, findtext(P.info,">")+1, findtext(P.info,"<",2) )
			chose_name = TRUE
			break
	if(!chose_name)
		D.real_name = "[pick(first_names_male)] [pick(last_names)]"
	D.universal_speak = 1
	D.status_flags &= ~GODMODE
	D.s_tone = 35
	D.b_eyes = 200
	D.r_eyes = 200
	D.g_eyes = 200
	D.underwear = 0
	D.key = ghost.key
	SSticker.mode.add_cultist(D.mind)
	D.mind.special_role = "Cultist"
	dummies += D
	to_chat(D, "<span class='cult'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. \
		The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.	Assist your new compatriots in their \
		dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back</span>")
	guider = user
	START_PROCESSING(SSobj, src)

/datum/cult/reveal
	word1 = "blood"
	word2 = "see"
	word3 = "hide"

/datum/cult/reveal/holder_reaction(mob/living/carbon/user)
	if(istype(holder, /obj/item/weapon/nullrod))
		to_chat(user, "<span class='notice'>Arcane markings suddenly glow from underneath a thin layer of dust!</span>")
	else
		return ..()

/datum/cult/reveal/rune_reaction(mob/living/carbon/user)
	user.say("Nikt[pick("'","`")]o barada kla'atu!")
	holder.visible_message("<span class='danger'>The rune turns into red dust, reveaing the surrounding runes.</span>")
	qdel(holder)

/datum/cult/reveal/talisman_reaction(mob/living/carbon/user)
	user.whisper("Nikt[pick("'","`")]o barada kla'atu!")
	holder.visible_message("<span class='userdanger'>Red dust emanates from [usr]'s hands for a moment.</span>",\
		"<span class='userdanger'>Your talisman turns into red dust, revealing the surrounding runes.</span>")
	qdel(holder)

/datum/cult/reveal/action(mob/living/carbon/user, radius = 6)
	var/S = FALSE
	var/turf/center = get_turf(holder)
	for(var/obj/effect/rune/R in range(radius, center))
		if(R != holder)
			R.invisibility = SEE_INVISIBLE_LIVING
			S = TRUE
	if(S)
		return holder_reaction(user)

/datum/cult/wall
	word1 = "destroy"
	word2 = "travel"
	word3 = "self"
	only_rune = TRUE

/datum/cult/wall/action(mob/living/carbon/user)
	user.say("Khari[pick("'","`")]d! Eske'te tannin!")
	user.take_bodypart_damage(2, 0)
	if(holder.density)
		holder.density = FALSE
		to_chat(user, "<span class='userdanger'>Your blood flows into the rune, and you feel that the very space over the rune thickens.</span>")
	else
		to_chat(user, "<span class='userdanger'>Your blood flows into the rune, and you feel as the rune releases its grasp on space.</span>")
		holder.density = TRUE

/datum/cult/freedom
	word1 = "travel"
	word2 = "technology"
	word3 = "other"
	only_rune = TRUE

/datum/cult/freedom/action(mob/living/carbon/user)
	var/list/cultists = list()
	for(var/datum/mind/H in SSticker.mode.cult)
		if(iscarbon(H.current))
			cultists += H.current
	var/list/acolytes = nearest_cultists()
	var/amount_of_acolytes = length(acolytes)
	if(amount_of_acolytes < 3)
		return fizzle(user)
	var/mob/living/carbon/cultist = input("Choose the one who you want to free", "Followers of Geometer") as null|anything in (cultists - acolytes)
	var/is_processed = FALSE
	if(!cultist)
		return fizzle(user)
	if(cultist.buckled)
		cultist.buckled.unbuckle_mob()
		is_processed = TRUE
	if (cultist.handcuffed)
		cultist.drop_from_inventory(cultist.handcuffed)
		is_processed = TRUE
	if (cultist.legcuffed)
		cultist.drop_from_inventory(cultist.legcuffed)
		is_processed = TRUE
	if (istype(cultist.wear_mask, /obj/item/clothing/mask/muzzle))
		cultist.remove_from_mob(cultist.wear_mask)
		is_processed = TRUE
	if(istype(cultist.loc, /obj/structure/closet))
		var/obj/structure/closet/closet = cultist.loc
		if(istype(closet.loc, /obj/structure/bigDelivery))
			var/obj/structure/bigDelivery/D = closet.loc
			closet.forceMove(get_turf(D.loc))
			qdel(D)
		if(closet.welded || closet.locked || !closet.opened)
			closet.welded = FALSE
			closet.locked = FALSE
			closet.open()
			closet.update_icon()
			is_processed = TRUE
	if(istype(cultist.loc, /obj/machinery/dna_scannernew))
		var/obj/machinery/dna_scannernew/scanner = cultist.loc
		if(scanner.locked)
			scanner.locked = FALSE
			scanner.panel_open = FALSE
			scanner.open(cultist)
			is_processed = TRUE
	if(!is_processed)
		to_chat(user, "<span class='cult'>The [cultist] is already free.</span>")
		return fizzle(user)
	for(var/mob/living/carbon/C in acolytes)
		user.take_overall_damage(45 / amount_of_acolytes, 0)
		C.say("Khari[pick("'","`")]d! Gual'te nikka!")
	qdel(holder)

/datum/cult/talisman
	word1 = "hell"
	word2 = "technology"
	word3 = "join"
	only_rune = TRUE

/datum/cult/talisman/action(mob/living/carbon/user)
	var/obj/item/weapon/paper/newtalisman
	for(var/obj/item/weapon/paper/P in holder.loc)
		if(!P.info)
			newtalisman = P
			break
	if(!newtalisman)
		to_chat(user, "<span class='cult'>The blank is tainted. It is unsuitable.</span>")
		return fizzle(user)

	for(var/obj/effect/rune/R in get_turf(user))
		if(R == holder)
			continue
		if(R.power)
			if(R.power.only_rune)
				to_chat(user, "<span class='cult'>The power in that rune is too powerful for talisman.</span>")
				return fizzle(user)

			var/obj/item/weapon/paper/talisman/talisman = new(get_turf(newtalisman))
			talisman.power = R.power
			talisman.power.holder = talisman
			R.power = null
			qdel(newtalisman)
			qdel(R)
			holder.visible_message("<span class='userdanger'>The runes turn into dust, which then forms into an arcane image on the paper.</span>")
			user.say("H'drak v[pick("'","`")]loso, mir'kanas verbot!")
			return
		to_chat(user, "<span class='cult'>There is no power to transfer.</span>")
		break
	return fizzle(user)

/datum/cult/sacrifice
	word1 = "hell"
	word2 = "blood"
	word3 = "join"
	only_rune = TRUE

/datum/cult/sacrifice/action(mob/living/carbon/user)
	var/list/acolytes = nearest_cultists(1, "Barhah hra zar[pick("'","`")]garis!")
	var/acolytes_amount = length(acolytes)
	if(acolytes_amount < 3)
		for(var/mob/M in acolytes)
			to_chat(M, "<span class='cult'>You will need more cultists chanting for the sacrifice to succeed.</span>")
			fizzle(M)
		return

	var/list/victims = list()
	var/datum/mind/sacrifice_target

	if(istype(SSticker.mode, /datum/game_mode/cult))
		var/datum/game_mode/cult/cur_mode = SSticker.mode
		sacrifice_target = cur_mode.sacrifice_target

	for(var/target in holder.loc)
		if(ishuman(target) && !iscultist(target))
			victims[target] = 80
		else if(ismonkey(target))
			victims[target] = 40
		else if(isxeno(target))
			victims[target] = 75
		else if(isIAN(target))
			victims[target] = 70
		else if(istype(target, /obj/item/brain))
			var/obj/item/brain/B = target
			victims[B.brainmob] = 60
		else if(istype(target, /obj/item/device/mmi))
			var/obj/item/device/mmi/B = target
			victims[B.brainmob] = 60
		else if(istype(target, /obj/item/device/aicard))
			for(var/mob/living/silicon/ai/A in target)
				victims[A] = 70
				break
	if(length(victims) < 1)
		return fizzle(user)
	playsound(holder, 'sound/magic/disintegrate.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/H in victims)
		if(sacrifice_target && sacrifice_target == H.mind)
			var/datum/game_mode/cult/cur_mode = SSticker.mode // we checked our mode earlier
			cur_mode.sacrificed += H.mind
			if(isrobot(H))
				H.dust() //To prevent the MMI from remaining
			else
				H.gib()
			to_chat(user, "<span class='cult'>The Geometer of Blood accepts this sacrifice, your objective is now complete.</span>")

		else
			var/prob_divider = max(1 + H.stat, 2)
			to_chat(user, "<span class='cult'>The Geometer of Blood accepts this sacrifice.</span>")
			if(prob(victims[H] / prob_divider))
				SSticker.mode.grant_runeword(user)
			else
				to_chat(user, "<span class='cult'>However, this soul was not enough to gain His favor.</span>")

			if(isrobot(H))
				H.dust() //To prevent the MMI from remaining
			else
				H.gib()

/datum/cult/communicate
	word1 = "self"
	word2 = "other"
	word3 = "technology"
	var/busy = FALSE

/datum/cult/communicate/holder_reaction(mob/living/carbon/user, input)
	if(istype(holder, /obj/effect/rune))
		return rune_reaction(user, input)
	return talisman_reaction(user, input)

/datum/cult/communicate/rune_reaction(mob/living/user, input)
	user.say("O bidai nabora se[pick("'","`")]sma!")
	user.say("[input]")
	busy = FALSE

/datum/cult/communicate/talisman_reaction(mob/living/user, input)
	user.whisper("O bidai nabora se[pick("'","`")]sma!")
	user.whisper("[input]")
	qdel(holder)

/datum/cult/communicate/action(mob/living/user)
	if(busy)
		return
	busy = TRUE
	var/input = sanitize(input(user, "Please choose a message to tell to the other acolytes.", "Voice of Blood", ""))
	if(!input)
		busy = FALSE
		return fizzle(user)
	for(var/datum/mind/H in SSticker.mode.cult)
		if(H.current)
			to_chat(H.current, "<span class='cult'>Acolyte [user.real_name]: [input]</span>")

	playsound(holder, 'sound/magic/message.ogg', VOL_EFFECTS_MASTER)
	holder_reaction(user, input)

/datum/cult/summon
	word1 = "join"
	word2 = "other"
	word3 = "self"
	only_rune = TRUE

/datum/cult/summon/action(mob/living/carbon/user)
	var/list/cultists = list()
	for(var/datum/mind/H in SSticker.mode.cult)
		if (iscarbon(H.current))
			cultists += H.current

	var/list/acolytes = nearest_cultists()
	var/acolytes_amount = length(acolytes)
	if(acolytes_amount < 3)
		return fizzle(user)
	var/mob/living/carbon/cultist = input("Choose the one who you want to summon", "Followers of Geometer") as null|anything in (cultists - acolytes)
	if(!cultist)
		return fizzle()
	if(cultist.incapacitated() || !isturf(cultist.loc))
		for(var/mob/C in acolytes)
			to_chat(C, "<span class='userdanger'>You cannot summon the [cultist], for his shackles of blood are strong.</span>")
		return fizzle()
	cultist.visible_message("<span class='userdanger'>The [cultist] suddenly disappears!</span>")
	cultist.forceMove(get_turf(holder.loc))
	cultist.lying = 1
	for(var/mob/living/carbon/C in acolytes)
		C.say("N'ath reth sh'yro eth d[pick("'","`")]rekkathnor!")
		C.take_overall_damage(90 / acolytes_amount, 0)
	user.visible_message("<span class='userdanger'>Rune disappears with a flash of red light, and in its place now a body lies.</span>", \
		"<span class='cult'>You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a body.</span>", \
		"<span class='cult'>You hear a pop and smell ozone.</span>")
	qdel(holder)

/datum/cult/deafen
	word1 = "hide"
	word2 = "other"
	word3 = "see"

/datum/cult/deafen/rune_reaction(mob/living/carbon/user)
	user.say("Sti[pick("'","`")] kaliedir!")
	to_chat(user, "<span class='cult'>The world becomes quiet as the deafening rune dissipates into fine dust.</span>")
	return 120

/datum/cult/deafen/talisman_reaction(mob/living/carbon/user)
	user.whisper("Sti[pick("'","`")] kaliedir!")
	to_chat(user, "<span class='cult'>Your talisman turns into gray dust, deafening everyone around.</span>")
	return 70

/datum/cult/deafen/action(mob/living/carbon/user)
	var/list/affected = nearest_heretics()
	if(length(affected) < 1)
		return
	var/deafness_modifier = max(5, holder_reaction(user) / length(affected))
	for(var/mob/living/carbon/C in affected)
		C.playsound_local(null, 'sound/effects/mob/ear_ring_single.ogg', VOL_EFFECTS_MASTER)
		C.ear_deaf += deafness_modifier
		to_chat(C, "<span class='userdanger'>The world around you suddenly becomes quiet.</span>")
		if(prob(1))
			C.sdisabilities |= DEAF
	qdel(holder)

/datum/cult/blind
	word1 = "destroy"
	word2 = "see"
	word3 = "other"

/datum/cult/blind/rune_reaction(mob/living/carbon/user)
	user.say("Sti[pick("'","`")] kaliesin!")
	to_chat(user, "<span class='cult'>The rune flashes, blinding those who not follow the Nar-Sie, and dissipates into fine dust.</span>")
	return 90

/datum/cult/blind/talisman_reaction(mob/living/carbon/user)
	user.whisper("Sti[pick("'","`")] kaliesin!")
	to_chat(user, "<span class='cult'>Your talisman turns into gray dust, blinding those who not follow the Nar-Sie.</span>")
	return 30

/datum/cult/blind/action(mob/living/carbon/user)
	var/list/affected = nearest_heretics()
	if(length(affected) < 1)
		return fizzle(user)
	var/blindless_modifier = clamp(holder_reaction(user) / length(affected), 5, 30)
	for(var/mob/living/carbon/C in affected)
		C.eye_blurry += blindless_modifier
		C.eye_blind += blindless_modifier / 2
		if(prob(5))
			C.disabilities |= NEARSIGHTED
			if(prob(10))
				C.sdisabilities |= BLIND
		C.show_message("<span class='userdanger'>Suddenly you see red flash that blinds you.</span>", SHOWMSG_VISUAL)
	qdel(holder)

/datum/cult/bloodboil
	word1 = "destroy"
	word2 = "see"
	word3 = "blood"
	only_rune = TRUE

/datum/cult/bloodboil/action(mob/living/carbon/user)
	var/list/acolytes = nearest_cultists(1, "Dedo ol[pick("'","`")]btoh!")
	if(length(acolytes) < 3)
		to_chat(user, "<span class='cult'>You will need more cultists chanting for the bloodboil to succeed.</span>")
		return fizzle(user)
	var/damage_for_acolytes = 45 / length(acolytes)
	var/list/heretics = nearest_heretics()
	if(length(heretics) < 1)
		return fizzle(user)
	var/damage_modifier = min(150 / length(heretics), 45)

	for(var/mob/living/carbon/M in heretics)
		M.take_overall_damage(damage_modifier, damage_modifier)
		to_chat(M, "<span class='warning'>Your blood boils!</span>")
		if(prob(5) && M)
			M.gib()
	for(var/obj/effect/rune/R in view(holder))
		if(prob(10))
			explosion(R.loc, -1, 0, 1, 5)
	for(var/mob/living/carbon/C in acolytes)
		C.take_overall_damage(damage_for_acolytes, 0)
	qdel(holder)

/datum/cult/stun
	word1 = "join"
	word2 = "hide"
	word3 = "technology"

/datum/cult/stun/rune_reaction(mob/living/carbon/user)
	user.say("Fuu ma[pick("'","`")]jin!")
	var/list/heretics = nearest_heretics()
	if(length(heretics) < 1)
		return fizzle(user)
	var/stun_modifier = 12 / length(heretics)
	for(var/mob/living/carbon/C in heretics)
		C.flash_eyes()
		if(C.stuttering < 1 && (!(HULK in C.mutations)))
			C.stuttering = 1
			C.Weaken(stun_modifier)
			C.Stun(stun_modifier)
			C.show_message("<span class='userdanger'>The rune explodes in a bright flash.</span>", SHOWMSG_VISUAL)
	qdel(holder)

/datum/cult/stun/talisman_reaction(mob/living/carbon/user, mob/living/affected)
	user.say("Dream sign ''Evil sealing talisman'[pick("'","`")]!")
	var/obj/item/weapon/nullrod/N = locate() in affected
	if(N)
		affected.visible_message("<span class='danger'>[user] invokes a talisman at [affected], but they are unaffected!</span>")
		qdel(holder)
		return
	else
		affected.visible_message("<span class='danger'>[user] invokes a talisman at [affected]!</span>")

	if(issilicon(affected))
		affected.Weaken(15)
	else if(iscarbon(affected))
		var/mob/living/carbon/C = affected
		C.flash_eyes()
		if(!(HULK in C.mutations))
			C.silent += 10
			C.Weaken(15)
			C.Stun(15)
	qdel(holder)

/datum/cult/stun/action(mob/living/carbon/user)
	if(istype(holder, /obj/effect/rune))
		rune_reaction(user)

/datum/cult/brainswap
	word1 = "travel"
	word2 = "blood"
	word3 = "other"
	only_rune = TRUE
	var/brainswapping = FALSE

/datum/cult/brainswap/action(mob/living/carbon/user)
	if(user.is_busy())
		return
	var/bdam = rand(2, 10)
	for(var/obj/effect/rune/R in cult_runes)
		if(!istype(R.power, type) || R.power == src)
			continue
		for(var/mob/living/target in holder.loc)
			if(!do_checks(user, target))
				return
			user.whisper("Yu[pick("'","`")]Ai! Lauri lantar lassi srinen'ni nótim ve rmar aldaron!")
			to_chat(user, "<span class='warning'>You feel your mind floating away...</span>")
			to_chat(target, "<span class='warning'>You feel your mind floating away...</span>")
			brainswapping = TRUE
			if(!do_after(user, BRAINSWAP_TIME, FALSE, target, FALSE, FALSE) || !do_checks(user, target))
				brainswapping = FALSE
				continue
			to_chat(user, "<span class='warning'>You feel weakend.</span>")
			target.adjustBrainLoss(bdam)
			user.adjustBrainLoss(bdam)
			user.say ("Yu[pick("'","`")]Ai! Lauri lantar lassi srinen'ni nótim ve rmar aldaron!")
			to_chat(user, "<span class='danger'>Your mind flows into other body. You feel a lack of intelligence.</span>")
			var/mob/dead/observer/ghost = target.ghostize(FALSE)
			user.mind.transfer_to(target)
			ghost.mind.transfer_to(user)
			user.key = ghost.key
			SSticker.mode.update_all_cult_icons()
			brainswapping = FALSE
			return

/datum/cult/brainswap/proc/do_checks(mob/user, mob/target)
	var/list/compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	if(target == user)
		to_chat(user, "<span class='warning'>You cant swap minds with yourself.</span>")
		return FALSE
	else if(!(target.type in compatible_mobs))
		to_chat(user, "<span class='warning'>Their mind isn't compatible with yours.</span>")
		return FALSE
	else if(target.stat == DEAD)
		to_chat(user, "<span class='warning'>Swapping your mind with a dead body is a bad idea, isn't it?</span>")
		return FALSE
	else if(!target.mind || !target.key)
		to_chat(user, "<span class='warning'>He is catatonic, even our magic cant affect him.</span>")
		return FALSE
	else if(brainswapping)
		to_chat(user, "<span class='warning'>Someone is already conducting a ritual here.</span>")
		return FALSE
	else
		return TRUE

/datum/cult/armor
	word1 = "hell"
	word2 = "destroy"
	word3 = "other"

/datum/cult/armor/rune_reaction(mob/living/carbon/user)
	user.say("N'ath reth sh'yro eth d[pick("'","`")]raggathnor!")

/datum/cult/armor/talisman_reaction(mob/living/carbon/user)
	user.whisper("N'ath reth sh'yro eth d[pick("'","`")]raggathnor!")

/datum/cult/armor/action(mob/living/carbon/user)
	holder_reaction(user)
	user.visible_message("<span class='userdanger'>The rune disappears with a flash of red light, and a set of armor appears on [user]...</span>", \
	"<span class='userdanger'>You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor.</span>")
	user.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(user), SLOT_HEAD)
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(user), SLOT_WEAR_SUIT)
	user.equip_to_slot_or_del(new /obj/item/clothing/shoes/boots/cult(user), SLOT_SHOES)
	user.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(user), SLOT_BACK)
	user.put_in_hands(new /obj/item/weapon/melee/cultblade(user))
	playsound(holder, 'sound/magic/cult_equip.ogg', VOL_EFFECTS_MASTER)
	qdel(holder)

#undef BRAINSWAP_TIME
