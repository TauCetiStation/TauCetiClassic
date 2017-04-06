var/list/sacrificed = list()

/////////////////////////////////////////FIRST RUNE
/obj/effect/rune/proc/teleport(mob/living/user, key)
	var/allrunesloc[]
	allrunesloc = new/list()
	var/index = 0
	//	var/tempnum = 0
	for(var/obj/effect/rune/R in world)
		if(R == src)
			continue
		if(R.word1 == cultwords["travel"] && R.word2 == cultwords["self"] && R.word3 == key && R.z != ZLEVEL_CENTCOMM)
			index++
			allrunesloc.len = index
			allrunesloc[index] = R.loc
	if(index >= 5)
		to_chat(user, "<span class='red'>You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric.</span>")
		if (istype(user, /mob/living))
			user.take_overall_damage(5, 0)
		qdel(src)
	if(allrunesloc && index != 0)
		if(istype(src,/obj/effect/rune))
			user.say("Sas[pick("'","`")]so c'arta forbici!")//Only you can stop auto-muting
		else
			user.whisper("Sas[pick("'","`")]so c'arta forbici!")
		user.visible_message("<span class='red'>[user] disappears in a flash of red light!</span>", \
		"<span class='red'>You feel as your body gets dragged through the dimension of Nar-Sie!</span>", \
		"<span class='red'>You hear a sickening crunch and sloshing of viscera.</span>")
		user.loc = allrunesloc[rand(1,index)]
		return
	if(istype(src,/obj/effect/rune))
		return	fizzle() //Use friggin manuals, Dorf, your list was of zero length.
	else
		call(/obj/effect/rune/proc/fizzle)(user)
		return


/obj/effect/rune/proc/itemport(mob/living/user, key)
	//var/allrunesloc[]
	//allrunesloc = new/list()
	//var/index = 0
	//var/tempnum = 0
	var/runecount = 0
	var/obj/effect/rune/IP = null
	for(var/obj/effect/rune/R in world)
		if(R == src)
			continue
		if(R.word1 == cultwords["travel"] && R.word2 == cultwords["other"] && R.word3 == key)
			IP = R
			runecount++
	if(runecount >= 2)
		to_chat(user, "<span class='red'>You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric.</span>")
		if (istype(user, /mob/living))
			user.take_overall_damage(14, 0)
		qdel(src)
	user.say("Sas[pick("'","`")]so c'arta forbici tarem!")
	user.visible_message("<span class='red'>You feel air moving from the rune - like as it was swapped with somewhere else.</span>", \
	"<span class='red'>You feel air moving from the rune - like as it was swapped with somewhere else.</span>", \
	"<span class='red'>You smell ozone.</span>")
	for(var/obj/O in loc)
		if(!O.anchored)
			O.loc = IP.loc
	for(var/mob/M in loc)
		M.loc = IP.loc
	return


/////////////////////////////////////////SECOND RUNE

/obj/effect/rune/proc/tomesummon(mob/living/user)
	if(istype(src,/obj/effect/rune))
		user.say("N[pick("'","`")]ath reth sh'yro eth d'raggathnor!")
	else
		user.whisper("N[pick("'","`")]ath reth sh'yro eth d'raggathnor!")
	user.visible_message("<span class='red'>Rune disappears with a flash of red light, and in its place now a book lies.</span>", \
	"<span class='red'>You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a book.</span>", \
	"<span class='red'>You hear a pop and smell ozone.</span>")
	if(istype(src,/obj/effect/rune))
		new /obj/item/weapon/book/tome(loc)
	else
		new /obj/item/weapon/book/tome(user.loc)
	qdel(src)
	return



/////////////////////////////////////////THIRD RUNE

/obj/effect/rune/proc/convert(mob/living/user)
	for(var/mob/living/carbon/M in loc)
		if(iscultist(M) || M.stat==2)
			continue
		user.say("Mah[pick("'","`")]weyh pleggh at e'ntrath!")
		M.visible_message("<span class='red'>[M] writhes in pain as the markings below him glow a bloody red.</span>", \
		"<span class='red'>AAAAAAHHHH!.</span>", \
		"<span class='red'>You hear an anguished scream.</span>")
		var/choice = alert(M,"Do you wanna to gave your soul to the Geometr?",,"Yes","No")
		var/accept = 0
		if(choice == "Yes")
			accept = 1
		if(accept && is_convertable_to_cult(M.mind) && !jobban_isbanned(M, ROLE_CULTIST) && !jobban_isbanned(M, "Syndicate") && !role_available_in_minutes(M, ROLE_CULTIST))
		//putting jobban check here because is_convertable uses mind as argument
			ticker.mode.add_cultist(M.mind)
			M.mind.special_role = "Cultist"
			to_chat(M, "<span class='cult'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</span>")
			to_chat(M, "<span class='cult'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>")
			return 1
		else
			to_chat(M, "<span class='cult'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</span>")
			to_chat(M, "<span class='danger'>And you were able to force it out of your mind. You now know the truth, there's something horrible out there, stop it and its minions at all costs.</span>")
			return 0
	return fizzle(user)



/////////////////////////////////////////FOURTH RUNE

/obj/effect/rune/proc/tearreality(mob/living/user)
	var/list/cultist = cults_in_range(src, "Tok-lyr rqa'nap g[pick("'","`")]lt-ulotf!")
	if(cultist.len >= 9)
		if(ticker.mode.name == "cult")
			var/summon_allowed = 0
			for(var/objective in ticker.mode:objectives)
				if(objective == "eldergod")
					summon_allowed = 1
			if(summon_allowed)
				ticker.mode:eldergod = 0
			else
				ticker.mode:eldertry += 1
			if(ticker.mode:eldertry)
				switch(ticker.mode:eldertry)
					if(1)
						for(var/mob/M in range(1,src))
							if(iscultist(M) && !M.stat)
								to_chat(M, "<font size='3'><span class='danger'>I have no interest in coming to your world.</span></font>")
					if(5)
						for(var/mob/M in range(1,src))
							if(iscultist(M) && !M.stat)
								if(ishuman(M))
									var/mob/living/carbon/human/H = M
									H.apply_effect(80,AGONY,0)
								to_chat(M, "<font size='4'><span class='danger'>I SAID NO!!</span></font>")
					if(10)
						for(var/mob/M in range(1,src))
							if(iscultist(M) && !M.stat)
								if(ishuman(M))
									var/mob/living/carbon/human/H = M
									H.apply_effect(80,AGONY,0)
								to_chat(M, "<font size='5'><span class='danger'>LAST WARNING.</span></font>")
					if(15 to 100)
						for(var/mob/M in range(1,src))
							if(iscultist(M) && !M.stat)
								M.gib()
						to_chat(world, "<font size='15'><span class='danger'>FUCK YOU!!!</span></font>")
						ticker.mode:eldertry = 0
			if(!summon_allowed)
				return
		if(ticker.mode.nar_sie_has_risen)
			for(var/mob/M in range(1,src))
				if(iscultist(M) && !M.stat)
					to_chat(M, "<font size='4'><span class='danger'>I am already here!</span></font>")
					return
		ticker.mode.nar_sie_has_risen = 1
		new /obj/singularity/narsie/large(loc)
		return
	else
		return fizzle(user)

/////////////////////////////////////////FIFTH RUNE

/obj/effect/rune/proc/emp(mob/living/user, U, range_red) //range_red - var which determines by which number to reduce the default emp range, U is the source loc, needed because of talisman emps which are held in hand at the moment of using and that apparently messes things up -- Urist
	if(istype(src,/obj/effect/rune))
		user.say("Ta'gh fara[pick("'","`")]qha fel d'amar det!")
	else
		user.whisper("Ta'gh fara[pick("'","`")]qha fel d'amar det!")
	playsound(U, 'sound/items/Welder2.ogg', 25, 1)
	var/turf/T = get_turf(U)
	if(T)
		T.hotspot_expose(700,125)
	var/rune = src // detaching the proc - in theory
	empulse(U, (range_red - 2), range_red)
	qdel(rune)
	return

/////////////////////////////////////////SIXTH RUNE

/obj/effect/rune/proc/drain(mob/living/user)
	var/drain = 0
	var/self_healing = 0
	for(var/obj/effect/rune/R in world)
		if(R.word1==cultwords["travel"] && R.word2==cultwords["blood"] && R.word3==cultwords["self"])
			for(var/mob/living/carbon/D in R.loc)
				if(D.stat!=2)
					var/bdrain = rand(1,25)
					to_chat(D, "<span class='red'>You feel weakened.</span>")
					D.take_overall_damage(bdrain, 0)
					drain += bdrain
					if(D == user)
						self_healing = 1
	if(!drain || self_healing)
		return fizzle()
	user.say ("Yu[pick("'","`")]gular faras desdae. Havas mithum javara. Umathar uf'kal thenar!")
	user.visible_message("<span class='red'>Blood flows from the rune into [user]!</span>", \
	"<span class='red'>The blood starts flowing from the rune and into your frail mortal body. You feel... empowered.</span>", \
	"<span class='red'>You hear a liquid flowing.</span>")
	if(user.bhunger)
		user.bhunger = max(user.bhunger-2*drain,0)
	if(drain>=50)
		user.visible_message("<span class='red'>[user]'s eyes give off eerie red glow!</span>", \
		"<span class='red'>...but it wasn't nearly enough. You crave, crave for more. The hunger consumes you from within.</span>", \
		"<span class='red'>You hear a heartbeat.</span>")
		user.bhunger += drain
		src = user
		spawn()
			for (,user.bhunger>0,user.bhunger--)
				sleep(50)
				user.take_overall_damage(3, 0)
		return
	user.heal_organ_damage(drain%5, 0)
	if(prob(20) && ishuman(user))
		var/mob/living/carbon/human/H = user
		for(var/datum/organ/external/External in H.organs)
			if(External.status & ORGAN_BROKEN || External.status & ORGAN_SPLINTED || External.status & ORGAN_DESTROYED)
				External.rejuvenate()
				break
	drain-=drain%5
	for (,drain>0,drain-=5)
		sleep(2)
		user.heal_organ_damage(5, 0)
	return

/////////////////////////////////////////SEVENTH RUNE

/obj/effect/rune/proc/seer(mob/living/user)
	if(user.loc == loc)
		if(user.seer==1)
			user.say("Rash'tla sektath mal[pick("'","`")]zua. Zasan therium viortia.")
			to_chat(user, "<span class='red'>The world beyond fades from your vision.</span>")
			user.see_invisible = SEE_INVISIBLE_LIVING
			user.seer = 0
		else if(user.see_invisible != SEE_INVISIBLE_LIVING)
			to_chat(user, "<span class='red'>The world beyond flashes your eyes but disappears quickly, as if something is disrupting your vision.</span>")
			user.see_invisible = SEE_INVISIBLE_CULT
			user.seer = 0
		else
			user.say("Rash'tla sektath mal[pick("'","`")]zua. Zasan therium vivira. Itonis al'ra matum!")
			to_chat(user, "<span class='red'>The world beyond opens to your eyes.</span>")
			user.see_invisible = SEE_INVISIBLE_CULT
			user.seer = 1
		return
	return fizzle(user)

/////////////////////////////////////////EIGHTH RUNE

/obj/effect/rune/proc/raise(mob/living/user)
	var/mob/living/carbon/human/corpse_to_raise
	var/mob/living/carbon/human/body_to_sacrifice

	var/is_sacrifice_target = 0
	for(var/mob/living/carbon/human/M in loc)
		if(M.stat == DEAD)
			if(ticker.mode.name == "cult" && M.mind == ticker.mode:sacrifice_target)
				is_sacrifice_target = 1
			else
				corpse_to_raise = M
				if(M.key)
					M.ghostize(can_reenter_corpse = TRUE)	//kick them out of their body
				break
	if(!corpse_to_raise)
		if(is_sacrifice_target)
			to_chat(user, "<span class='red'>The Geometer of blood wants this mortal for himself.</span>")
		return fizzle(user)
	is_sacrifice_target = 0
	find_sacrifice:
		for(var/obj/effect/rune/R in world)
			if(R.word1==cultwords["blood"] && R.word2==cultwords["join"] && R.word3==cultwords["hell"])
				for(var/mob/living/carbon/human/N in R.loc)
					if(ticker.mode.name == "cult" && N.mind && N.mind == ticker.mode:sacrifice_target)
						is_sacrifice_target = 1
					else
						if(N.stat!= DEAD)
							body_to_sacrifice = N
							break find_sacrifice

	if(!body_to_sacrifice)
		if (is_sacrifice_target)
			to_chat(user, "<span class='red'>The Geometer of blood wants that corpse for himself.</span>")
		else
			to_chat(user, "<span class='red'>The sacrifical corpse is not dead. You must free it from this world of illusions before it may be used.</span>")
		return fizzle(user)

	var/mob/dead/observer/ghost
	for(var/mob/dead/observer/O in loc)
		if(!O.client)	continue
		if(O.mind && O.mind.current && O.mind.current.stat != DEAD)	continue
		ghost = O
		break

	if(!ghost)
		to_chat(user, "<span class='red'>You require a restless spirit which clings to this world. Beckon their prescence with the sacred chants of Nar-Sie.</span>")
		return fizzle(user)

	corpse_to_raise.revive()

	corpse_to_raise.key = ghost.key	//the corpse will keep its old mind! but a new player takes ownership of it (they are essentially possessed)
											//This means, should that player leave the body, the original may re-enter
	user.say("Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!")
	corpse_to_raise.visible_message("<span class='red'>[corpse_to_raise]'s eyes glow with a faint red as he stands up, slowly starting to breathe again.</span>", \
	"<span class='red'>Life... I'm alive again...</span>", \
	"<span class='red'>You hear a faint, slightly familiar whisper.</span>")
	body_to_sacrifice.visible_message("<span class='red'>[body_to_sacrifice] is torn apart, a black smoke swiftly dissipating from his remains!</span>", \
	"<span class='red'>You feel as your blood boils, tearing you apart.</span>", \
	"<span class='red'>You hear a thousand voices, all crying in pain.</span>")
	body_to_sacrifice.gib()

//			if(ticker.mode.name == "cult")
//				ticker.mode:add_cultist(corpse_to_raise.mind)
//			else
//				ticker.mode.cult |= corpse_to_raise.mind

	to_chat(corpse_to_raise, "<span class='cult'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</span>")
	to_chat(corpse_to_raise, "<span class='cult'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>")
	return

/////////////////////////////////////////NINETH RUNE

/obj/effect/rune/proc/obscure(mob/living/user, rad)
	var/S=0
	for(var/obj/effect/rune/R in orange(rad,src))
		if(R != src)
			R.invisibility=INVISIBILITY_OBSERVER
		S=1
	if(S)
		if(istype(src,/obj/effect/rune))
			user.say("Kla[pick("'","`")]atu barada nikt'o!")
			visible_message("<span class='red'>The rune turns into gray dust, veiling the surrounding runes.</span>")
			qdel(src)
		else
			user.whisper("Kla[pick("'","`")]atu barada nikt'o!")
			to_chat(user, "<span class='red'>Your talisman turns into gray dust, veiling the surrounding runes.</span>")
			user.visible_message("<span class='red'>Dust emanates from [user]'s hands for a moment.</span>")
		return
	call(/obj/effect/rune/proc/fizzle)(user) // we call it cuz of talismans, yeah

/////////////////////////////////////////TENTH RUNE

/obj/effect/rune/proc/ajourney(mob/living/user) //some bits copypastaed from admin tools - Urist
	if(user.loc==loc)
		var/mob/living/carbon/human/L = user
		user.say("Fwe[pick("'","`")]sh mah erl nyag r'ya!")
		user.visible_message("<span class='red'>[user]'s eyes glow blue as \he freezes in place, absolutely motionless.</span>", \
		"<span class='red'>The shadow that is your spirit separates itself from your body. You are now in the realm beyond. While this is a great sight, being here strains your mind and body. Hurry...</span>", \
		"<span class='red'>You hear only complete silence for a moment.</span>")
		user.ghostize(1)
		L.ajourn = 1
		while(L)
			if(L.key)
				L.ajourn=0
				return
			else
				L.take_organ_damage(10, 0)
			sleep(100)
	return fizzle(user)

/////////////////////////////////////////ELEVENTH RUNE

/obj/effect/rune/proc/manifest(mob/living/user)
	var/obj/effect/rune/this_rune = src
	src = null
	if(user.loc != this_rune.loc)
		return this_rune.fizzle(user)
	var/mob/dead/observer/ghost
	for(var/mob/dead/observer/O in this_rune.loc)
		if(!O.client)	continue
		if(O.mind && O.mind.current && O.mind.current.stat != DEAD)	continue
		ghost = O
		break
	if(!ghost)
		return this_rune.fizzle(user)
	if(jobban_isbanned(ghost, ROLE_CULTIST) || jobban_isbanned(ghost, "Syndicate") || role_available_in_minutes(ghost, ROLE_CULTIST))
		return this_rune.fizzle(user)

	user.say("Gal'h'rfikk harfrandid mud[pick("'","`")]gib!")
	var/mob/living/carbon/human/dummy/D = new(this_rune.loc)
	user.visible_message("<span class='red'>A shape forms in the center of the rune. A shape of... a man.</span>", \
	"<span class='red'>A shape forms in the center of the rune. A shape of... a man.</span>", \
	"<span class='red'>You hear liquid flowing.</span>")
	D.real_name = "Unknown"
	var/chose_name = 0
	for(var/obj/item/weapon/paper/P in this_rune.loc)
		if(P.info)
			D.real_name = copytext(P.info, findtext(P.info,">")+1, findtext(P.info,"<",2) )
			chose_name = 1
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

	if(ticker.mode.name == "cult")
		ticker.mode.add_cultist(D.mind)
	else
		ticker.mode.cult+=D.mind

	D.mind.special_role = "Cultist"
	to_chat(D, "<span class='cult'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</span>")
	to_chat(D, "<span class='cult'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>")
	while(this_rune && user && user.stat==CONSCIOUS && user.client && user.loc==this_rune.loc)
		user.take_organ_damage(1, 0)
		sleep(30)
	if(D)
		D.visible_message("<span class='red'>[D] slowly dissipates into dust and bones.</span>", \
		"<span class='red'>You feel pain, as bonds formed between your soul and this homunculus break.</span>", \
		"<span class='red'>You hear faint rustle.</span>")
		D.dust()
	return

/////////////////////////////////////////TWELFTH RUNE

/obj/effect/rune/proc/talisman(mob/living/user)//only hide, emp, teleport, deafen, blind and tome runes can be imbued atm
	var/obj/item/weapon/paper/newtalisman
	var/unsuitable_newtalisman = 0
	for(var/obj/item/weapon/paper/P in loc)
		if(!P.info)
			newtalisman = P
			break
		else
			unsuitable_newtalisman = 1
	if (!newtalisman)
		if (unsuitable_newtalisman)
			to_chat(user, "<span class='red'>The blank is tainted. It is unsuitable.</span>")
		return fizzle(user)

	var/obj/effect/rune/imbued_from
	var/obj/item/weapon/paper/talisman/T
	for(var/obj/effect/rune/R in orange(1,src))
		if(R == src)
			continue
		if(R.word1==cultwords["travel"] && R.word2==cultwords["self"])  //teleport
			T = new(loc)
			T.imbue = "[R.word3]"
			T.info = "[R.word3]"
			imbued_from = R
			break
		if(R.word1==cultwords["see"] && R.word2==cultwords["blood"] && R.word3==cultwords["hell"]) //tome
			T = new(loc)
			T.imbue = "newtome"
			imbued_from = R
			break
		if(R.word1==cultwords["destroy"] && R.word2==cultwords["see"] && R.word3==cultwords["technology"]) //emp
			T = new(loc)
			T.imbue = "emp"
			imbued_from = R
			break
		if(R.word1==cultwords["blood"] && R.word2==cultwords["see"] && R.word3==cultwords["destroy"]) //conceal
			T = new(loc)
			T.imbue = "conceal"
			imbued_from = R
			break
		if(R.word1==cultwords["hell"] && R.word2==cultwords["destroy"] && R.word3==cultwords["other"]) //armor
			T = new(loc)
			T.imbue = "armor"
			imbued_from = R
			break
		if(R.word1==cultwords["blood"] && R.word2==cultwords["see"] && R.word3==cultwords["hide"]) //reveal
			T = new(loc)
			T.imbue = "revealrunes"
			imbued_from = R
			break
		if(R.word1==cultwords["hide"] && R.word2==cultwords["other"] && R.word3==cultwords["see"]) //deafen
			T = new(loc)
			T.imbue = "deafen"
			imbued_from = R
			break
		if(R.word1==cultwords["destroy"] && R.word2==cultwords["see"] && R.word3==cultwords["other"]) //blind
			T = new(loc)
			T.imbue = "blind"
			imbued_from = R
			break
		if(R.word1==cultwords["self"] && R.word2==cultwords["other"] && R.word3==cultwords["technology"]) //communicat
			T = new(loc)
			T.imbue = "communicate"
			imbued_from = R
			break
		if(R.word1==cultwords["join"] && R.word2==cultwords["hide"] && R.word3==cultwords["technology"]) //communicat
			T = new(loc)
			T.imbue = "runestun"
			imbued_from = R
			break
		if(R.word1==cultwords["technology"] && R.word2==cultwords["blood"] && R.word3==cultwords["travel"]) //construct
			T = new(loc)
			T.imbue = "construction"
			imbued_from = R
			break
	if (imbued_from)
		visible_message("<span class='red'>The runes turn into dust, which then forms into an arcane image on the paper.</span>")
		user.say("H'drak v[pick("'","`")]loso, mir'kanas verbot!")
		qdel(imbued_from)
		qdel(newtalisman)
	else
		return fizzle(user)

/////////////////////////////////////////THIRTEENTH RUNE

/obj/effect/rune/proc/mend(mob/living/user)
	src = null
	user.say("Uhrast ka'hfa heldsagen ver[pick("'","`")]lot!")
	user.take_overall_damage(200, 0)
	runedec+=10
	user.visible_message("<span class='red'>[user] keels over dead, his blood glowing blue as it escapes his body and dissipates into thin air.</span>", \
	"<span class='red'>In the last moment of your humble life, you feel an immense pain as fabric of reality mends... with your blood.</span>", \
	"<span class='red'>You hear faint rustle.</span>")
	for(,user.stat==2)
		sleep(600)
		if (!user)
			return
	runedec-=10
	return

/////////////////////////////////////////FOURTEETH RUNE

		// returns 0 if the rune is not used. returns 1 if the rune is used.
/obj/effect/rune/proc/communicate(mob/living/user)
	. = 1 // Default output is 1. If the rune is deleted it will return 1
	var/input = input(user, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
	input = sanitize(copytext(input, 1, MAX_MESSAGE_LEN))
	if(!input)
		if (istype(src))
			fizzle(user)
			return 0
		else
			return 0
	if(istype(src,/obj/effect/rune))
		user.say("O bidai nabora se[pick("'","`")]sma!")
	else
		user.whisper("O bidai nabora se[pick("'","`")]sma!")

	if(istype(src,/obj/effect/rune))
		user.say("[input]")
	else
		user.whisper("[input]")
	var/my_message = "<span class='cult'>[(ishuman(user) ? "Acolyte" : "Construct")] [user]: [input]</span>"
	for(var/datum/mind/H in ticker.mode.cult)
		if (H.current)
			to_chat(H.current,my_message)
	for(var/mob/M in dead_mob_list)
		if(M.client)
			to_chat(M,my_message)
	log_say("[user.real_name]/[user.key] : [input]")
	qdel(src)
	return 1

/////////////////////////////////////////FIFTEENTH RUNE

/obj/effect/rune/proc/sacrifice(mob/living/user)
	var/list/mob/living/carbon/human/cultsinrange = cults_in_range(src,"Barhah hra zar[pick("'","`")]garis!")
	var/list/mob/living/carbon/human/victims = list()
	for(var/mob/living/carbon/human/V in loc)//Checks for non-cultist humans to sacrifice
		if(ishuman(V) && !iscultist(V))
			victims += V//Checks for cult status and mob type
	for(var/obj/item/I in loc)//Checks for MMIs/brains/Intellicards
		if(istype(I,/obj/item/brain))
			var/obj/item/brain/B = I
			victims += B.brainmob
		else if(istype(I,/obj/item/device/mmi))
			var/obj/item/device/mmi/B = I
			victims += B.brainmob
		else if(istype(I,/obj/item/device/aicard))
			for(var/mob/living/silicon/ai/A in I)
				victims += A

	for(var/mob/H in victims)
		if(cultsinrange.len < 3)
			to_chat(user, "<span class='red'>Your target's earthly bonds are too strong. You need more cultists to succeed in this ritual.</span>")
			return
		else if(ticker.mode.name == "cult" && H.mind == ticker.mode:sacrifice_target)
			sacrificed += H.mind
			if(isrobot(H))
				H.dust()//To prevent the MMI from remaining
			else
				H.gib()
			to_chat(user, "<span class='red'>The Geometer of Blood accepts this sacrifice, your objective is now complete.</span>")
		else
			var/chances_of_runeword = 40
			if(ismonkey(H))
				chances_of_runeword = 20
			else if(H.stat != 2 && ishuman(H))
				chances_of_runeword = 80
			if(prob(chances_of_runeword))
				to_chat(user, "<span class='red'>The Geometer of Blood accepts this sacrifice.</span>")
				ticker.mode.grant_runeword(user)
			else
				to_chat(user, "<span class='red'>The Geometer of blood accepts this sacrifice.</span>")
				to_chat(user, "<span class='red'>However, this soul was not enough to gain His favor.</span>")
			if(isrobot(H))
				H.dust()//To prevent the MMI from remaining
			else
				H.gib()

/////////////////////////////////////////SIXTEENTH RUNE

/obj/effect/rune/proc/revealrunes(mob/living/user, obj/W)
	var/go=0
	var/rad
	var/S=0
	if(istype(W,/obj/effect/rune))
		rad = 6
		go = 1
	if (istype(W,/obj/item/weapon/paper/talisman))
		rad = 4
		go = 1
	if (istype(W,/obj/item/weapon/nullrod))
		rad = 1
		go = 1
	if(go)
		for(var/obj/effect/rune/R in orange(rad,src))
			if(R != src)
				R:visibility=15
			S=1
	if(S)
		if(istype(W,/obj/item/weapon/nullrod))
			to_chat(user, "<span class='red'>Arcane markings suddenly glow from underneath a thin layer of dust!</span>")
			return
		if(istype(W,/obj/effect/rune))
			user.say("Nikt[pick("'","`")]o barada kla'atu!")
			visible_message("<span class='red'>The rune turns into red dust, reveaing the surrounding runes.</span>")
			qdel(src)
			return
		if(istype(W,/obj/item/weapon/paper/talisman))
			user.whisper("Nikt[pick("'","`")]o barada kla'atu!")
			to_chat(user, "<span class='red'>Your talisman turns into red dust, revealing the surrounding runes.</span>")
			for (var/mob/V in orange(1,user.loc))
				if(V!=user)
					V.show_message("<span class='red'>Red dust emanates from [user]'s hands for a moment.</span>", 3)
			return
		return
	if(istype(W,/obj/effect/rune))
		return	fizzle(user)
	if(istype(W,/obj/item/weapon/paper/talisman))
		call(/obj/effect/rune/proc/fizzle)(user)
		return

/////////////////////////////////////////SEVENTEENTH RUNE

/obj/effect/rune/proc/wall(mob/living/user)
	user.say("Khari[pick("'","`")]d! Eske'te tannin!")
	density = !density
	user.take_organ_damage(2, 0)
	if(density)
		to_chat(user, "<span class='red'>Your blood flows into the rune, and you feel that the very space over the rune thickens.</span>")
	else
		to_chat(user, "<span class='red'>Your blood flows into the rune, and you feel as the rune releases its grasp on space.</span>")
	return

/////////////////////////////////////////EIGHTTEENTH RUNE

/obj/effect/rune/proc/freedom(mob/living/user)
	var/list/mob/living/carbon/cultists = new
	for(var/datum/mind/H in ticker.mode.cult)
		if (istype(H.current,/mob/living/carbon))
			cultists+=H.current
	var/list/mob/living/carbon/users = cults_in_range(src)
	if(users.len>=3)
		var/mob/living/carbon/cultist = input("Choose the one who you want to free", "Followers of Geometer") as null|anything in (cultists - users)
		if(!cultist)
			return fizzle(user)
		if (cultist == user) //just to be sure.
			return
		if(!(cultist.buckled || \
			cultist.handcuffed || \
			istype(cultist.wear_mask, /obj/item/clothing/mask/muzzle) || \
			(istype(cultist.loc, /obj/structure/closet)&&cultist.loc:welded) || \
			(istype(cultist.loc, /obj/structure/closet/secure_closet)&&cultist.loc:locked) || \
			(istype(cultist.loc, /obj/machinery/dna_scannernew)&&cultist.loc:locked) \
		))
			to_chat(user, "<span class='red'>The [cultist] is already free.</span>")
			return
		if(cultist.buckled)
			cultist.buckled.unbuckle_mob()
		if (cultist.handcuffed)
			cultist.drop_from_inventory(cultist.handcuffed)
		if (cultist.legcuffed)
			cultist.drop_from_inventory(cultist.legcuffed)
		if (istype(cultist.wear_mask, /obj/item/clothing/mask/muzzle))
			cultist.remove_from_mob(cultist.wear_mask)
		if(istype(cultist.loc, /obj/structure/closet)&&cultist.loc:welded)
			cultist.loc:welded = 0
		if(istype(cultist.loc, /obj/structure/closet/secure_closet)&&cultist.loc:locked)
			cultist.loc:locked = 0
		if(istype(cultist.loc, /obj/machinery/dna_scannernew)&&cultist.loc:locked)
			cultist.loc:locked = 0
		for(var/mob/living/carbon/C in users)
			user.take_overall_damage(15, 0)
		qdel(src)
	return fizzle(user)

/////////////////////////////////////////NINETEENTH RUNE

/obj/effect/rune/proc/cultsummon(mob/living/user)
	var/list/mob/living/carbon/cultists = new
	for(var/datum/mind/H in ticker.mode.cult)
		if (istype(H.current,/mob/living/carbon))
			cultists+=H.current
	var/list/mob/living/carbon/users = cults_in_range(src, "N'ath reth sh'yro eth d[pick("'","`")]rekkathnor!")

	if(users.len>=3)
		var/mob/living/carbon/cultist = input("Choose the one who you want to summon", "Followers of Geometer") as null|anything in (cultists - user)
		if(!cultist)
			return fizzle(user)
		if (cultist == user) //just to be sure.
			return
		if(cultist.buckled || cultist.handcuffed || (!isturf(cultist.loc) && !istype(cultist.loc, /obj/structure/closet)))
			to_chat(user, "<span class='red'>You cannot summon \the [cultist], for his shackles of blood are strong.")
			return fizzle(user)
		cultist.loc = loc
		cultist.lying = 1
		for(var/mob/living/carbon/human/C in users)
			C.take_divided_damage(60, 0)
		user.visible_message("<span class='red'>Rune disappears with a flash of red light, and in its place now a body lies.</span>", \
		"<span class='red'>You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a body.</span>", \
		"<span class='red'>You hear a pop and smell ozone.</span>")
		qdel(src)
	return fizzle(user)

/////////////////////////////////////////TWENTIETH RUNES

/obj/effect/rune/proc/deafen(mob/living/user)
	if(istype(src,/obj/effect/rune))
		var/affected = 0
		for(var/mob/living/carbon/C in range(7,src))
			if (iscultist(C))
				continue
			if(locate(/obj/item/weapon/nullrod) in C)
				continue
			C.ear_deaf += 50
			C.show_message("<span class='red'>The world around you suddenly becomes quiet.</span>", 3)
			affected++
			if(prob(1))
				C.sdisabilities |= DEAF
		if(affected)
			user.say("Sti[pick("'","`")] kaliedir!")
			to_chat(user, "<span class='red'>The world becomes quiet as the deafening rune dissipates into fine dust.</span>")
			qdel(src)
		else
			return fizzle(user)
	else
		var/affected = 0
		for(var/mob/living/carbon/C in range(7,user))
			if (iscultist(C))
				continue
			if(locate(/obj/item/weapon/nullrod) in C)
				continue
			C.ear_deaf += 30
			//talismans is weaker.
			C.show_message("<span class='red'>The world around you suddenly becomes quiet.</span>", 3)
			affected++
		if(affected)
			user.whisper("Sti[pick("'","`")] kaliedir!")
			to_chat(user, "<span class='red'>Your talisman turns into gray dust, deafening everyone around.</span>")
			for (var/mob/V in orange(1,src))
				if(!(iscultist(V)))
					V.show_message("<span class='red'>Dust flows from [user]'s hands for a moment, and the world suddenly becomes quiet...</span>", 3)
	return

/obj/effect/rune/proc/blind(mob/living/user)
	if(istype(src,/obj/effect/rune))
		var/affected = 0
		for(var/mob/living/carbon/C in viewers(src))
			if (iscultist(C))
				continue
			if(locate(/obj/item/weapon/nullrod) in C)
				continue
			C.eye_blurry += 50
			C.eye_blind += 20
			if(prob(5))
				C.disabilities |= NEARSIGHTED
				if(prob(10))
					C.sdisabilities |= BLIND
			C.show_message("<span class='red'>Suddenly you see red flash that blinds you.</span>", 3)
			affected++
		if(affected)
			user.say("Sti[pick("'","`")] kaliesin!")
			to_chat(user, "<span class='red'>The rune flashes, blinding those who not follow the Nar-Sie, and dissipates into fine dust.</span>")
			qdel(src)
		else
			return fizzle(user)
	else
		var/affected = 0
		for(var/mob/living/carbon/C in view(2,user))
			if (iscultist(C))
				continue
			if(locate(/obj/item/weapon/nullrod) in C)
				continue
			C.eye_blurry += 30
			C.eye_blind += 10
			//talismans is weaker.
			affected++
			C.show_message("<span class='red'>You feel a sharp pain in your eyes, and the world disappears into darkness...</span>", 3)
		if(affected)
			user.whisper("Sti[pick("'","`")] kaliesin!")
			to_chat(user, "<span class='red'>Your talisman turns into gray dust, blinding those who not follow the Nar-Sie.</span>")

/obj/effect/rune/proc/bloodboil(mob/living/user) //cultists need at least one DANGEROUS rune. Even if they're all stealthy.
/*
			var/list/mob/living/carbon/cultists = new
			for(var/datum/mind/H in ticker.mode.cult)
				if (istype(H.current,/mob/living/carbon))
					cultists+=H.current
*/
	var/list/cultcount = cults_in_range(src) //also, wording for it is old wording for obscure rune, which is now hide-see-blood.
//			var/list/cultboil = list(cultists-usr) //and for this words are destroy-see-blood.
	if(cultcount.len>=3)
		for(var/mob/living/carbon/M in viewers(user))
			if(iscultist(M))
				continue
			if(locate(/obj/item/weapon/nullrod) in M)
				continue
			M.take_overall_damage(51,51)
			to_chat(M, "<span class='warning'>Your blood boils!</span>")
			if(prob(5))
				spawn(5)
					M.gib()
		for(var/obj/effect/rune/R in view(src))
			if(prob(10))
				explosion(R.loc, -1, 0, 1, 5)
		for(var/mob/living/carbon/human/C in orange(1,src))
			if(iscultist(C) && !C.stat)
				C.say("Dedo ol[pick("'","`")]btoh!")
				C.take_overall_damage(15, 0)
		qdel(src)
	else
		return fizzle(user)

// WIP rune, I'll wait for Rastaf0 to add limited blood.

/obj/effect/rune/proc/burningblood(mob/living/user)
	var/list/cultcount = cults_in_range(src)
	if(cultcount.len >= 5)
		for(var/obj/effect/rune/R in world)
			if(R.blood_DNA == blood_DNA)
				for(var/mob/living/M in orange(2,R))
					M.take_overall_damage(0,15)
					if (R.invisibility>M.see_invisible)
						to_chat(M, "<span class='red'>Aargh it burns!</span>")
					else
						to_chat(M, "<span class='red'>Rune suddenly ignites, burning you!</span>")
					var/turf/T = get_turf(R)
					T.hotspot_expose(700,125)
		for(var/obj/effect/decal/cleanable/blood/B in world)
			if(B.blood_DNA == blood_DNA)
				for(var/mob/living/M in orange(1,B))
					M.take_overall_damage(0,5)
					to_chat(M, "<span class='red'>Blood suddenly ignites, burning you!</span>")
					var/turf/T = get_turf(B)
					T.hotspot_expose(700,125)
					qdel(B)
		qdel(src)

//////////             Rune 24 (counting burningblood, which kinda doesnt work yet.)

/obj/effect/rune/proc/runestun(mob/living/user, mob/living/T)
	if(istype(src,/obj/effect/rune))   ///When invoked as rune, flash and stun everyone around.
		user.say("Fuu ma[pick("'","`")]jin!")
		for(var/mob/living/L in viewers(src))
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				if(locate(/obj/item/weapon/nullrod) in C)
					continue
				C.flash_eyes()
				if(C.stuttering < 1 && (!(HULK in C.mutations)))
					C.stuttering = 1
				C.Weaken(1)
				C.Stun(1)
				C.show_message("<span class='red'>The rune explodes in a bright flash.</span>", 3)

			else if(issilicon(L))
				var/mob/living/silicon/S = L
				S.Weaken(5)
				S.show_message("<span class='red'>BZZZT... The rune has exploded in a bright flash.</span>", 3)
		qdel(src)
	else                        ///When invoked as talisman, stun and mute the target mob.
		user.say("Dream sign ''Evil sealing talisman'[pick("'","`")]!")
		user.visible_message("<span class='danger'>[user] invokes a talisman at [T]</span>")
		if(locate(/obj/item/weapon/nullrod) in T)
			return
		if(issilicon(T))
			T.Weaken(15)
		else if(iscarbon(T))
			var/mob/living/carbon/C = T
			C.flash_eyes()
			if (!(HULK in C.mutations))
				C.silent += 15
			C.Weaken(25)
			C.Stun(25)

/////////////////////////////////////////TWENTY-FIFTH RUNE

/obj/effect/rune/proc/armor(mob/living/user)
	var/mob/living/carbon/human/H = user
	if(istype(src,/obj/effect/rune))
		H.say("N'ath reth sh'yro eth d[pick("'","`")]raggathnor!")
	else
		H.whisper("N'ath reth sh'yro eth d[pick("'","`")]raggathnor!")
	H.visible_message("<span class='red'>The rune disappears with a flash of red light, and a set of armor appears on [H]...</span>", \
	"<span class='red'>You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor.</span>")

	H.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/cultrobes/alt(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(H), slot_back)
	//the above update their overlay icons cache but do not call update_icons()
	//the below calls update_icons() at the end, which will update overlay icons by using the (now updated) cache
	H.put_in_hands(new /obj/item/weapon/melee/cultblade(H))	//put in hands or on floor
	H.put_in_hands(new /obj/item/weapon/legcuffs/bola/cult(H))
	qdel(src)
	return

//////////////////////////////////////////TWENTY-SIXTH RUNE

/obj/effect/rune/proc/brainswap(mob/living/user)
	var/list/compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	var/bdam = rand(2,10)
	for(var/obj/effect/rune/R in world)
		if(R.word1==cultwords["travel"] && R.word2==cultwords["blood"] && R.word3==cultwords["other"])
			for(var/mob/living/carbon/D in R.loc)
				if(!(D.type in compatible_mobs) || !D.mind)
					to_chat(user, "Their mind isn't compatible with yours.")
					return
				if(!(user.type in compatible_mobs))
					to_chat(user, "Your mind isn't compatible with their.")
					return
				else
					to_chat(D, "<span class='red'>You feel weakened.</span>")
					D.adjustBrainLoss(bdam)
					user.adjustBrainLoss(bdam)
					user.say ("Yu[pick("'","`")]Ai! Lauri lantar lassi srinen,ni n�tim ve rmar aldaron!")
					to_chat(user, "<span class='red'>Your mind flows into other body. You feel a lack of intelligence.</span>")
					var/datum/mind/M = D.mind
					user.mind.transfer_to(D)
					M.transfer_to(user)
					user.Paralyse(7)
					D.Paralyse(7)
					ticker.mode.update_all_cult_icons()

//////////////////////////////////////////TWENTY-SEVENTH RUNE
/obj/effect/rune/proc/construction(mob/living/user, obj/item/stack/sheet/P)
	user.say("N[pick("'","`")]ath em ka'az an trus te'ng")
	if(!istype(P))
		to_chat(user,"<span class='warning'>The talisman must be used on metal or plasteel!</span>")
		return fizzle(user)
	if(istype(P,/obj/item/stack/sheet/plasteel))
		var/amount = min(25,P.amount)
		P.use(amount)
		new /obj/item/stack/sheet/runed_metal(get_turf(user), amount)
		to_chat(user,"<span class='warning'>The rune clings to the plasteel, transforming it into runed metal!</span>")
		user.playsound_local(get_turf(src),'sound/effects/magic.ogg',100,falloff = 5)
		qdel(src)
	else if(istype(P, /obj/item/stack/sheet/metal))
		if(P.use(25))
			new /obj/structure/constructshell(get_turf(user))
			to_chat(user,"<span class='warning'>The rune clings to the metal and twists it into a construct shell!</span>")
			user.playsound_local(get_turf(src),'sound/effects/magic.ogg',100,falloff = 5)
			qdel(src)
		else
			to_chat(user,"<span class='warning'>You need more metal to produce a construct shell!</span>")

proc/cults_in_range(atom/center, message = null)
	var/list/mob/living/carbon/human/cultsinrange = list()
	for(var/mob/living/carbon/C in orange(1,center))
		if(iscultist(C) && !C.stat)
			cultsinrange += C
			if(message)
				C.say(message)
	return cultsinrange