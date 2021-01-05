#define BRAINSWAP_TIME 50

/datum/rune
	var/name
	var/obj/effect/rune/holder
	var/datum/religion/religion
	var/only_rune = FALSE
	// Used only for sprite generation
	// All words ("travel", "blood", "join", "hell", "destroy", "technology", "self", "see", "other", "hide")
	var/list/words = list()

/datum/rune/New(holder)
	src.holder = holder

/datum/rune/Destroy()
	holder = null
	return ..()

/datum/rune/New(holder)
	..()
	if(global.cult_religion)
		religion = global.cult_religion

/datum/rune/proc/can_action(mob/living/carbon/user)
	return TRUE

/datum/rune/proc/action(mob/living/carbon/user)
	return

/datum/rune/proc/action_wrapper(mob/living/carbon/user)
	if(!can_action(user))
		return

	action(user)
	if(religion.disposable_rune)
		qdel(holder)
	fizzle(user)
	holder_reaction(user)

/datum/rune/proc/holder_reaction(mob/living/carbon/user)
	if(istype(holder, /obj/effect/rune))
		return rune_reaction(user)
	return talisman_reaction(user)

/datum/rune/proc/rune_reaction(mob/living/carbon/user)
	return

/datum/rune/proc/talisman_reaction(mob/living/carbon/user)
	return

/datum/rune/proc/nearest_cultists(range = 1, message)
	var/list/acolytes = list()
	var/turf/center = get_turf(holder)
	for(var/mob/living/carbon/C in range(range, center))
		if(religion.is_member(C) && !C.stat)
			acolytes += C
			if(message)
				C.say(message)
	return acolytes

/datum/rune/proc/nearest_heretics(range = 7, ignore_nullrod = FALSE)
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

/datum/rune/proc/fizzle(mob/living/user)
	if(istype(holder, /obj/effect/rune))
		user.say(pick("Хаккрутйу гопоенйим.", "Храсаи пивроиашан.", "Фирййи прхив мазенхор.", "Танах ех вакантахе.", "Облияе на ораие.", "Миуф хон внор'с.", "Вакабаи хий фен йусших."))
	else
		user.whisper(pick("Хаккрутжу гопоенжим.", "Нхерасаи пивроиашан.", "Фиржжи прхив мазенхор.", "Танах ех вакантахе.", "Облияе на ораие.", "Мийф хон внор'с.", "Вакабаи хиж фен жусвикс."))
	holder.visible_message("<span class='danger'>Иероглиф начинает пульсировать незаметным светом и сразу тухнет.</span>","<span class='danger'>Вы слишите тихое шипение.</span>")

/datum/rune/cult
/datum/rune/cult/teleport_to_heaven
	name = "Teleport to HEAVEN"
	var/turf/destination
	words = list("travel", "self", "hell")

/datum/rune/cult/teleport_to_heaven/action(mob/living/carbon/user)
	var/area/A = locate(religion.area_type)
	var/turf/T = get_turf(pick(A.contents))
	destination = T
	var/list/companions = holder.handle_teleport_grab(T, usr)
	user.forceMove(T)
	user.eject_from_wall(TRUE, companions = companions)
	if(user && (!destination || locate(/datum/rune/cult) in destination)) // user can gibbed
		var/obj/effect/rune/R = new(get_turf(user), religion)
		R.power = new /datum/rune/cult/teleport_from_heaven(R, get_turf(holder))
		R.icon = get_uristrune_cult(TRUE, R.power.words)
		var/datum/religion/cult/C = religion
		if(companions)
			for(var/i in 1 to companions.len + 1) // with usr
				C.create_anomalys(TRUE)
		else
			C.create_anomalys(TRUE)

/datum/rune/cult/teleport_from_heaven
	name = "Teleport from HEAVEN"
	var/turf/destination
	words = list("travel", "self", "technology")

/datum/rune/cult/teleport_from_heaven/New(holder, turf/_destination)
	..()
	destination = _destination

/datum/rune/cult/teleport_from_heaven/Destroy()
	destination = null
	return ..()

/datum/rune/cult/teleport_from_heaven/action(mob/living/carbon/user)
	holder.handle_teleport_grab(destination, usr)
	user.forceMove(destination)

/datum/rune/cult/capture_area
	name = "Capture area"
	words = list("join", "hell", "technology")
	var/static/already_use = FALSE
	var/static/first_area_captured = FALSE

/datum/rune/cult/capture_area/Destroy()
	already_use = FALSE
	return ..()

/datum/rune/cult/capture_area/can_action(mob/living/carbon/user)
	var/area/area = get_area(user)
	if(religion == area.religion)
		to_chat(user, "<span class='warning'>Эта зона уже под вашим контролем.</span>")
		return FALSE

	if(first_area_captured)
		if(!istype(religion, area.religion?.type))
			to_chat(user, "<span class='warning'>Вы должны находится в уже захваченной зоне, а руна в зоне, которую вы хотите захватить.</span>")
			return FALSE

	else if(already_use)
		to_chat(user, "<span class='warning'>Вы уже захватываете одну зону.</span>")
		return FALSE

	return TRUE

/datum/rune/cult/capture_area/action(mob/living/carbon/user)
	already_use = TRUE
	var/area/A = get_area(holder)
	var/datum/announcement/station/cult/capture_area/announce = new
	announce.play(A)
	if(religion.religify_area(A.type, CALLBACK(src, .proc/capture_iteration)))
		first_area_captured = TRUE
	already_use = FALSE

/datum/rune/cult/capture_area/proc/capture_iteration(i, list/all_items)
	if(!holder || !src)
		return FALSE

	if((100*i)/all_items.len % 25 == 0)
		for(var/mob/M in religion.members)
			to_chat(M, "<span class='cult'>Захват [get_area(holder)] завершен на [round((100*i)/all_items.len, 0.1)]%</span>")

	INVOKE_ASYNC(src, .proc/capture_effect, i, all_items)
	sleep(10)
	return TRUE

/datum/rune/cult/capture_area/proc/capture_effect(i, list/all_items)
	var/turf = get_turf(all_items[i])
	var/list/viewing = list()
	for(var/mob/M in viewers(turf))
		if(M.client && (M.client.prefs.toggles & SHOW_ANIMATIONS))
			viewing |= M.client

	var/image/I = image(uristrune_cache[pick(uristrune_cache)], turf)
	flick_overlay(I, viewing, 30)
	animate(I, alpha = 0, time = 30)

/datum/rune/cult/teleport
	words = list("travel", "self", "see")
	var/id

/datum/rune/cult/teleport/New(holder, id)
	..()
	if(!id)
		src.id = rand(1, 100000)
	else
		src.id = id

/datum/rune/cult/teleport/action(mob/living/carbon/user)
	var/list/allrunes = list()
	for(var/obj/effect/rune/R in religion.runes)
		if(!istype(R.power, type) || R.power == src)
			continue
		var/datum/rune/cult/teleport/T = R.power
		if(T.id == id && !is_centcom_level(R.loc.z))
			allrunes += R

	var/length = length(allrunes)
	if(length >= 5)
		to_chat(user, "<span class='userdanger'>You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric.</span>")
		user.take_overall_damage(5, 0)
		return FALSE
	else if(length)
		user.visible_message("<span class='userdanger'>[user] disappears in a flash of red light!</span>", \
			"<span class='cult'>You feel as your body gets dragged through the dimension of Nar-Sie!</span>", \
			"<span class='userdanger'>You hear a sickening crunch and sloshing of viscera.</span>")
		playsound(user, 'sound/magic/Teleport_diss.ogg', VOL_EFFECTS_MASTER)
		user.forceMove(get_turf(pick(allrunes)))
		playsound(user, 'sound/magic/Teleport_app.ogg', VOL_EFFECTS_MASTER)

/datum/rune/cult/item_port
	words = list("travel", "other", "see")
	only_rune = TRUE
	var/id

/datum/rune/cult/item_port/New(holder, id)
	..()
	if(!id)
		src.id = rand(1, 100000)
	else
		src.id = id

/datum/rune/cult/item_port/action(mob/living/carbon/user)
	var/list/allrunes = list()
	var/list/acolytes = nearest_cultists(1, "Sas[pick("'","`")]so c'arta forbici tarem!")
	if(length(acolytes) < 3)
		return fizzle(user)
	for(var/obj/effect/rune/R in religion.runes)
		if(!istype(R.power, type) || R.power == src)
			continue
		var/datum/rune/cult/item_port/I = R.power
		if(!is_centcom_level(R.loc.z) && I.id == id)
			allrunes += R

	var/length = length(allrunes)
	if(length >= 5)
		to_chat(user, "<span class='cult'>You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric.</span>")
		user.take_overall_damage(5, 0)
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

/datum/rune/cult/convert
	words = list("join", "blood", "self")
	only_rune = TRUE
	var/in_use = FALSE

/datum/rune/cult/convert/action(mob/living/carbon/user)
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
			if(!global.cult_religion.mode.is_convertable_to_cult(M.mind))
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

/datum/rune/cult/emp
	words = list("destroy", "see", "technology")

/datum/rune/cult/emp/rune_reaction(mob/living/carbon/user)
	return 3

/datum/rune/cult/emp/talisman_reaction(mob/living/carbon/user)
	return 5

/datum/rune/cult/emp/action(mob/living/carbon/user)
	var/emp_power = holder_reaction(user)
	var/turf/turf = get_turf(holder)
	playsound(holder, 'sound/items/Welder2.ogg', VOL_EFFECTS_MASTER, 25)
	turf.hotspot_expose(700,125)
	empulse(turf, (emp_power - 2), emp_power)

/datum/rune/cult/drain
	words = list("travel", "blood", "self")
	only_rune = TRUE

/mob/living/carbon/proc/drain_dot(loop_value) //recursive proc to Imitate "damage over time" mechanics
	if(loop_value > 0 && src && stat != DEAD)
		take_overall_damage(3, 0)
		addtimer(CALLBACK(src, .proc/drain_dot, --loop_value), 20)

/datum/rune/cult/drain/action(mob/living/carbon/user)
	var/drain = 0
	for(var/obj/effect/rune/R in religion.runes)
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

/datum/rune/cult/seer
	words = list("see", "hell", "join")
	only_rune = TRUE

/datum/rune/cult/seer/action(mob/living/carbon/human/user)
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

/datum/rune/cult/raise
	words = list("blood", "hell", "join")
	only_rune = TRUE

/datum/rune/cult/raise/action(mob/living/carbon/user)
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

	for(var/obj/effect/rune/R in religion.runes)
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

/datum/rune/cult/obscure
	words = list("hide", "see", "blood")

/datum/rune/cult/obscure/action(mob/living/carbon/user, radius = 4)
	var/turf/center = get_turf(holder)
	for(var/obj/effect/rune/R in range(radius, center))
		if(R != holder)
			R.invisibility = INVISIBILITY_OBSERVER

/datum/rune/cult/ajourney
	words = list("hell", "travel", "self")
	only_rune = TRUE
	var/mob/living/ajourned
	var/mob/dead/observer/ghost
	var/cooldown = 0

/datum/rune/cult/ajourney/Destroy()
	if(isprocessing)
		STOP_PROCESSING(SSobj, src)
		to_chat(ghost, "<span class='cult'>The astral cord that ties your body and your spirit has been severed. \
			You are likely to wander the realm beyond until your body is finally dead and thus reunited with you.</span>")
		ghost.can_reenter_corpse = FALSE
		ghost = null
		ajourned = null
	return ..()

/datum/rune/cult/ajourney/process()
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


/datum/rune/cult/ajourney/action(mob/living/carbon/human/user)
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

/datum/rune/cult/manifest
	words = list("blood", "see", "travel")
	only_rune = TRUE
	var/mob/living/guider
	var/list/dummies = list()

/datum/rune/cult/manifest/Destroy()
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

/datum/rune/cult/manifest/process()
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

/datum/rune/cult/manifest/action(mob/living/carbon/human/user)
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

/datum/rune/cult/reveal
	words = list("blood", "see", "hide")

/datum/rune/cult/reveal/action(mob/living/carbon/user, radius = 6)
	var/turf/center = get_turf(holder)
	for(var/obj/effect/rune/R in range(radius, center))
		if(R != holder)
			R.invisibility = SEE_INVISIBLE_LIVING

/datum/rune/cult/wall
	words = list("destroy", "travel", "self")
	only_rune = TRUE

/datum/rune/cult/wall/action(mob/living/carbon/user)
	user.say("Khari[pick("'","`")]d! Eske'te tannin!")
	user.take_bodypart_damage(2, 0)
	if(holder.density)
		holder.density = FALSE
		to_chat(user, "<span class='userdanger'>Your blood flows into the rune, and you feel that the very space over the rune thickens.</span>")
	else
		to_chat(user, "<span class='userdanger'>Your blood flows into the rune, and you feel as the rune releases its grasp on space.</span>")
		holder.density = TRUE

/datum/rune/cult/freedom
	words = list("technology", "travel", "other")
	only_rune = TRUE

/datum/rune/cult/freedom/action(mob/living/carbon/user)
	var/list/cultists = list()
	for(var/datum/mind/H in global.cult_religion.members)
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

/datum/rune/cult/summon
	words = list("join", "other", "self")
	only_rune = TRUE

/datum/rune/cult/summon/action(mob/living/carbon/user)
	var/list/cultists = list()
	for(var/datum/mind/H in global.cult_religion.members)
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

/datum/rune/cult/deafen
	words = list("hide", "other", "see")

/datum/rune/cult/deafen/rune_reaction(mob/living/carbon/user)
	return 120

/datum/rune/cult/deafen/talisman_reaction(mob/living/carbon/user)
	return 70

/datum/rune/cult/deafen/action(mob/living/carbon/user)
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
/datum/rune/cult/blind
	words = list("destroy", "other", "see")

/datum/rune/cult/blind/rune_reaction(mob/living/carbon/user)
	return 90

/datum/rune/cult/blind/talisman_reaction(mob/living/carbon/user)
	return 30

/datum/rune/cult/blind/action(mob/living/carbon/user)
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

/datum/rune/cult/bloodboil
	words = list("destroy", "blood", "see")
	only_rune = TRUE

/datum/rune/cult/bloodboil/action(mob/living/carbon/user)
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

/datum/rune/cult/stun
	words = list("join", "hide", "technology")

/datum/rune/cult/stun/rune_reaction(mob/living/carbon/user)
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

/datum/rune/cult/stun/talisman_reaction(mob/living/carbon/user, mob/living/affected)
	user.say("Dream sign ''Evil sealing talisman'[pick("'","`")]!")
	var/obj/item/weapon/nullrod/N = locate() in affected
	if(N)
		affected.visible_message("<span class='danger'>[user] invokes a talisman at [affected], but they are unaffected!</span>")
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

/datum/rune/cult/brainswap
	words = list("travel", "blood", "other")
	only_rune = TRUE
	var/brainswapping = FALSE

/datum/rune/cult/brainswap/action(mob/living/carbon/user)
	if(user.is_busy())
		return
	var/bdam = rand(2, 10)
	for(var/obj/effect/rune/R in religion.runes)
		if(!istype(R.power, type) || R.power == src)
			continue
		for(var/mob/living/target in holder.loc)
			if(!do_checks(user, target))
				return
			user.whisper("Yu[pick("'","`")]Ai! Lauri lantar lassi srinen'ni nótim ve rmar aldaron!")
			to_chat(user, "<span class='warning'>You feel your mind floating away...</span>")
			to_chat(target, "<span class='warning'>You feel your mind floating away...</span>")
			brainswapping = TRUE
			if(do_after(user, BRAINSWAP_TIME, FALSE, target, FALSE, FALSE) && do_checks(user, target))
				brainswapping = TRUE
			else
				brainswapping = FALSE
			to_chat(user, "<span class='warning'>You feel weakend.</span>")
			target.adjustBrainLoss(bdam)
			user.adjustBrainLoss(bdam)
			user.say ("Yu[pick("'","`")]Ai! Lauri lantar lassi srinen'ni nótim ve rmar aldaron!")
			to_chat(user, "<span class='danger'>Your mind flows into other body. You feel a lack of intelligence.</span>")
			var/mob/dead/observer/ghost = target.ghostize(FALSE)
			user.mind.transfer_to(target)
			ghost.mind.transfer_to(user)
			user.key = ghost.key
			brainswapping = FALSE
			return

/datum/rune/cult/brainswap/proc/do_checks(mob/user, mob/target)
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

/datum/rune/cult/armor
	words = list("hell", "destroy", "other")

/datum/rune/cult/armor/action(mob/living/carbon/user)
	user.visible_message("<span class='userdanger'>The rune disappears with a flash of red light, and a set of armor appears on [user]...</span>", \
	"<span class='userdanger'>You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor.</span>")
	user.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(user), SLOT_HEAD)
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(user), SLOT_WEAR_SUIT)
	user.equip_to_slot_or_del(new /obj/item/clothing/shoes/boots/cult(user), SLOT_SHOES)
	user.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(user), SLOT_BACK)
	user.put_in_hands(new /obj/item/weapon/melee/cultblade(user))
	playsound(holder, 'sound/magic/cult_equip.ogg', VOL_EFFECTS_MASTER)

#undef BRAINSWAP_TIME
