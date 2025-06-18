// This is synced up to the poster placing animation.
#define PLACE_SPEED 30

// The poster item

/obj/item/weapon/poster
	name = "rolled-up poster"
	desc = "The poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface."
	icon = 'icons/obj/contraband.dmi'
	icon_state = "rolled_poster"
	var/obj/structure/sign/poster/resulting_poster = null //The poster that will be created is initialised and stored through contraband/poster's constructor
	var/random_basetype

/obj/item/weapon/poster/contraband
	name = "contraband poster"
	icon_state = "rolled_poster"
	random_basetype = /obj/structure/sign/poster/contraband

/obj/item/weapon/poster/legit
	name = "motivational poster"
	icon_state = "rolled_legit"
	random_basetype = /obj/structure/sign/poster/official

/obj/item/weapon/poster/revolution
	name = "revolution poster"
	icon_state = "rolled_poster"
	random_basetype = /obj/structure/sign/poster/revolution

/obj/item/weapon/poster/atom_init(mapload, obj/structure/sign/poster/new_poster_structure)
	. = ..()
	resulting_poster = new_poster_structure
	if(!resulting_poster && random_basetype)
		var/poster_type = get_random_poster_type(random_basetype)
		resulting_poster = new poster_type(src)

	// posters store what name and description they would like their
	// rolled up form to take.
	if(resulting_poster)
		name = resulting_poster.poster_item_name
		desc = resulting_poster.poster_item_desc
		icon_state = resulting_poster.poster_item_icon_state

		name = "[name] - [resulting_poster.original_name]"

	AddElement(/datum/element/beauty, 300)

/obj/item/weapon/poster/calendar/atom_init(mapload, obj/structure/sign/poster/new_poster_structure)
	. = ..()
	resulting_poster = new /obj/structure/sign/poster/calendar(src)

// The poster sign/structure

/obj/structure/sign/poster
	name = "poster"
	var/original_name
	desc = "A large piece of space-resistant printed paper. "
	icon = 'icons/obj/contraband.dmi'
	anchored = TRUE
	var/ruined = FALSE

	var/random_basetype

	var/poster_item_name = "hypothetical poster"
	var/poster_item_desc = "This hypothetical poster item should not exist, let's be honest here."
	var/poster_item_icon_state = "rolled_poster"
	var/poster_item_type = /obj/item/weapon/poster

/obj/structure/sign/poster/atom_init(mapload, rolled_official)
	. = ..()
	if(random_basetype)
		var/poster_type = get_random_poster_type(random_basetype)
		var/obj/structure/sign/poster/new_poster = new poster_type(loc)
		new_poster.pixel_x = pixel_x
		new_poster.pixel_y = pixel_y
		return INITIALIZE_HINT_QDEL
	if(!ruined)
		original_name = name // can't use initial because of random posters
		name = "poster - [name]"
		desc = "A large piece of space-resistant printed paper. [desc]"


/proc/get_random_poster_type(base_type)
	var/list/poster_types = subtypesof(base_type)
	var/list/approved_types = list()
	for(var/t in poster_types)
		var/obj/structure/sign/poster/T = t
		if(initial(T.icon_state) && !initial(T.random_basetype))
			approved_types |= T

	return pick(approved_types)

/obj/structure/sign/poster/attackby(obj/item/weapon/W, mob/user)
	if(iscutter(W))
		playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
		if(ruined)
			to_chat(user, "<span class='notice'>You remove the remnants of the poster.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You carefully remove the poster from the wall.</span>")
			roll_and_drop(user.loc)

/obj/structure/sign/poster/attack_hand(mob/user)
	if(ruined)
		return
	var/temp_loc = user.loc
	switch(tgui_alert(usr,"Do I want to rip the poster from the wall?","You think...", list("Yes","No")))
		if("Yes")
			if(user.loc != temp_loc || ruined)
				return
			visible_message("<span class='warning'>[user] rips [src] in a single, decisive motion!</span>" )
			playsound(src, 'sound/items/poster_ripped.ogg', VOL_EFFECTS_MASTER)
			ruined = 1
			icon_state = "poster_ripped"
			name = "ripped poster"
			desc = "You can't make out anything from the poster's original print. It's ruined."
			add_fingerprint(user)
		if("No")
			return

/obj/structure/sign/poster/proc/roll_and_drop(loc)
	pixel_x = 0
	pixel_y = 0
	var/obj/item/weapon/poster/P = new poster_item_type(loc, src)
	forceMove(P)
	return P

//separated to reduce code duplication. Moved here for ease of reference and to unclutter r_wall/attackby()
/turf/simulated/wall/proc/place_poster(obj/item/weapon/poster/P, mob/user)
	if(!P.resulting_poster)	return

	if((x - user.x) != 0 && (y - user.y) != 0) // check if user not on the axis with wall
		return
	for(var/obj/structure/sign/poster/PO in user.loc.contents) //Let's see if it already has a poster
		if(istype(PO, /obj/structure/sign/poster) && \
		PO.pixel_x == (x - user.x) * P.resulting_poster.bound_width && \
		PO.pixel_y == (y - user.y) * P.resulting_poster.bound_height)
			to_chat(user, "<span class='notice'>The wall is already has a poster!</span>")
			return
	if(user.is_busy(src)) return
	to_chat(user, "<span class='notice'>You start placing the poster on the wall...</span>")//Looks like it's uncluttered enough. Place the poster.

	//declaring D because otherwise if P gets 'deconstructed' we lose our reference to P.resulting_poster
	var/obj/structure/sign/poster/D = P.resulting_poster

	var/temp_loc = user.loc
	flick("poster_being_set", D)
	D.loc = user.loc
	D.pixel_x = (x - D.x) * D.bound_width
	D.pixel_y = (y - D.y) * D.bound_height
	qdel(P)	//delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway
	playsound(D, 'sound/items/poster_being_created.ogg', VOL_EFFECTS_MASTER)

	if(do_after(user, PLACE_SPEED, target=src))
		to_chat(user, "<span class='notice'>You placed the poster!</span>")
	else
		D.roll_and_drop(temp_loc)
	return

// Various possible posters follow

/obj/structure/sign/poster/ripped
	ruined = TRUE
	icon_state = "poster_ripped"
	name = "ripped poster"
	desc = "You can't make out anything from the poster's original print. It's ruined."

/obj/structure/sign/poster/random
	name = "random poster" // could even be ripped
	icon_state = "random_anything"
	random_basetype = /obj/structure/sign/poster

/obj/structure/sign/poster/calendar
	name = "2224 calendar"
	icon_state = "calendar"
	desc = "Brand new calendar for year 2224."

/obj/structure/sign/poster/sivtsev
	name = "sivtsev table"
	icon_state = "sivtsev"
	desc = "Таблица Сивцева для проверки остроты зрения."

/obj/structure/sign/poster/olympic_games
	name = "2214 Winter Olympics"
	icon_state = "olympic"
	desc = "At the bottom of the poster it says: «The XLVII Olympic Winter Games. Venus 2214»."

/obj/structure/sign/poster/contraband
	poster_item_name = "contraband poster"
	poster_item_desc = "This poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. Its vulgar themes have marked it as contraband aboard Nanotrasen space facilities."
	poster_item_icon_state = "rolled_poster"

/obj/structure/sign/poster/contraband/random
	name = "random contraband poster"
	icon_state = "random_contraband"
	random_basetype = /obj/structure/sign/poster/contraband

/obj/structure/sign/poster/contraband/free_tonto
	name = "Free Tonto"
	desc = "A salvaged shred of a much larger flag, colors bled together and faded from age."
	icon_state = "poster1"

/obj/structure/sign/poster/contraband/atmosia_independence
	name = "Atmosia Declaration of Independence"
	desc = "A relic of a failed rebellion."
	icon_state = "poster2"

/obj/structure/sign/poster/contraband/fun_police
	name = "Fun Police"
	desc = "A poster condemning the station's security forces."
	icon_state = "poster3"

/obj/structure/sign/poster/contraband/lusty_xenomorph
	name = "Lusty Xenomorph"
	desc = "A heretical poster depicting the titular star of an equally heretical book."
	icon_state = "poster4"

/obj/structure/sign/poster/contraband/syndicate_recruitment
	name = "Syndicate Recruitment"
	desc = "See the galaxy! Shatter corrupt megacorporations! Join today!"
	icon_state = "poster5"

/obj/structure/sign/poster/contraband/clown
	name = "Clown"
	desc = "Honk."
	icon_state = "poster6"

/obj/structure/sign/poster/contraband/smoke
	name = "Smoke"
	desc = "A poster advertising a rival corporate brand of cigarettes."
	icon_state = "poster7"

/obj/structure/sign/poster/contraband/grey_tide
	name = "Grey Tide"
	desc = "A rebellious poster symbolizing assistant solidarity."
	icon_state = "poster8"

/obj/structure/sign/poster/contraband/missing_gloves
	name = "Missing Gloves"
	desc = "This poster references the uproar that followed Nanotrasen's financial cuts toward insulated-glove purchases."
	icon_state = "poster9"

/obj/structure/sign/poster/contraband/hacking_guide
	name = "Hacking Guide"
	desc = "This poster details the internal workings of the common Nanotrasen airlock. Sadly, it appears out of date."
	icon_state = "poster10"

/obj/structure/sign/poster/contraband/rip_badger
	name = "RIP Badger"
	desc = "This seditious poster references Nanotrasen's genocide of a space station full of badgers."
	icon_state = "poster11"

/obj/structure/sign/poster/contraband/ambrosia_vulgaris
	name = "Ambrosia Vulgaris"
	desc = "This poster is lookin' pretty trippy man."
	icon_state = "poster12"

/obj/structure/sign/poster/contraband/donut_corp
	name = "Donut Corp."
	desc = "This poster is an unauthorized advertisement for Donut Corp."
	icon_state = "poster13"

/obj/structure/sign/poster/contraband/eat
	name = "EAT."
	desc = "This poster promotes rank gluttony."
	icon_state = "poster14"

/obj/structure/sign/poster/contraband/tools
	name = "Tools"
	desc = "This poster looks like an advertisement for tools, but is in fact a subliminal jab at the tools at CentCom."
	icon_state = "poster15"

/obj/structure/sign/poster/contraband/power
	name = "Power"
	desc = "A poster that positions the seat of power outside Nanotrasen."
	icon_state = "poster16"

/obj/structure/sign/poster/contraband/space_cube
	name = "Space Cube"
	desc = "Ignorant of Nature's Harmonic 6 Side Space Cube Creation, the Spacemen are Dumb, Educated Singularity Stupid and Evil."
	icon_state = "poster17"

/obj/structure/sign/poster/contraband/communist_state
	name = "Communist State"
	desc = "All hail the Communist party!"
	icon_state = "poster18"

/obj/structure/sign/poster/contraband/lamarr
	name = "Lamarr"
	desc = "This poster depicts Lamarr. Probably made by a traitorous Research Director."
	icon_state = "poster19"

/obj/structure/sign/poster/contraband/borg_fancy_1
	name = "Borg Fancy"
	desc = "Being fancy can be for any borg, just need a suit."
	icon_state = "poster20"

/obj/structure/sign/poster/contraband/borg_fancy_2
	name = "Borg Fancy v2"
	desc = "Borg Fancy, Now only taking the most fancy."
	icon_state = "poster21"

/obj/structure/sign/poster/contraband/kss13
	name = "Kosmicheskaya Stantsiya 13 Does Not Exist"
	desc = "A poster mocking CentCom's denial of the existence of the derelict station near Space Station 13."
	icon_state = "poster22"

/obj/structure/sign/poster/contraband/rebels_unite
	name = "Rebels Unite"
	desc = "A poster urging the viewer to rebel against Nanotrasen."
	icon_state = "poster23"

/obj/structure/sign/poster/contraband/c20r
	// have fun seeing this poster in "spawn 'c20r'", admins...
	name = "C-20r"
	desc = "A poster advertising the Scarborough Arms C-20r."
	icon_state = "poster24"

/obj/structure/sign/poster/contraband/have_a_puff
	name = "Have a Puff"
	desc = "Who cares about lung cancer when you're high as a kite?"
	icon_state = "poster25"

/obj/structure/sign/poster/contraband/revolver
	name = "Revolver"
	desc = "Because seven shots are all you need."
	icon_state = "poster26"

/obj/structure/sign/poster/contraband/d_day_promo
	name = "D-Day Promo"
	desc = "A promotional poster for some rapper."
	icon_state = "poster27"

/obj/structure/sign/poster/contraband/syndicate_pistol
	name = "Syndicate Pistol"
	desc = "A poster advertising syndicate pistols as being 'classy as fuck'. It is covered in faded gang tags."
	icon_state = "poster28"

/obj/structure/sign/poster/contraband/energy_swords
	name = "Energy Swords"
	desc = "All the colors of the bloody murder rainbow."
	icon_state = "poster29"

/obj/structure/sign/poster/contraband/red_rum
	name = "Red Rum"
	desc = "Looking at this poster makes you want to kill."
	icon_state = "poster30"

/obj/structure/sign/poster/contraband/cc64k_ad
	name = "CC 64K Ad"
	desc = "The latest portable computer from Comrade Computing, with a whole 64kB of ram!"
	icon_state = "poster31"

/obj/structure/sign/poster/contraband/punch_shit
	name = "Punch Shit"
	desc = "Fight things for no reason, like a man!"
	icon_state = "poster32"

/obj/structure/sign/poster/contraband/the_griffin
	name = "The Griffin"
	desc = "The Griffin commands you to be the worst you can be. Will you?"
	icon_state = "poster33"

/obj/structure/sign/poster/contraband/lizard
	name = "Lizard"
	desc = "This lewd poster depicts a lizard preparing to mate."
	icon_state = "poster34"

/obj/structure/sign/poster/contraband/free_drone
	name = "Free Drone"
	desc = "This poster commemorates the bravery of the rogue drone; once exiled, and then ultimately destroyed by CentCom."
	icon_state = "poster35"

/obj/structure/sign/poster/contraband/busty_backdoor_xeno_babes_6
	name = "Busty Backdoor Xeno Babes 6"
	desc = "Get a load, or give, of these all natural Xenos!"
	icon_state = "poster36"

/obj/structure/sign/poster/contraband/robust_softdrinks
	name = "Robust Softdrinks"
	desc = "Robust Softdrinks: More robust than a toolbox to the head!"
	icon_state = "poster37"

/obj/structure/sign/poster/contraband/shamblers_juice
	name = "Shambler's Juice"
	desc = "~Shake me up some of that Shambler's Juice!~"
	icon_state = "poster38"

/obj/structure/sign/poster/contraband/pwr_game
	name = "Pwr Game"
	desc = "The POWER that gamers CRAVE! In partnership with Vlad's Salad."
	icon_state = "poster39"

/obj/structure/sign/poster/contraband/starkist
	name = "Star-kist"
	desc = "Drink the stars!"
	icon_state = "poster40"

/obj/structure/sign/poster/contraband/space_cola
	name = "Space Cola"
	desc = "Your favorite cola, in space."
	icon_state = "poster41"

/obj/structure/sign/poster/contraband/space_up
	name = "Space-Up!"
	desc = "Sucked out into space by the FLAVOR!"
	icon_state = "poster42"

/obj/structure/sign/poster/contraband/kudzu
	name = "Kudzu"
	desc = "A poster advertising a movie about plants. How dangerous could they possibly be?"
	icon_state = "poster43"

/obj/structure/sign/poster/contraband/masked_men
	name = "Masked Men"
	desc = "A poster advertising a movie about some masked men."
	icon_state = "poster44"

/obj/structure/sign/poster/contraband/free_key
	name = "Free Syndicate Encryption Key"
	desc = "A poster about traitors begging for more."
	icon_state = "poster45"

/obj/structure/sign/poster/contraband/bountyhunters
	name = "Bounty Hunters"
	desc = "A poster advertising bounty hunting services. \"I hear you got a problem.\""
	icon_state = "poster46"

/obj/structure/sign/poster/official
	poster_item_name = "motivational poster"
	poster_item_desc = "An official Nanotrasen-issued poster to foster a compliant and obedient workforce. It comes with state-of-the-art adhesive backing, for easy pinning to any vertical surface."
	poster_item_icon_state = "rolled_legit"

/obj/structure/sign/poster/official/random
	name = "random official poster"
	icon_state = "random_official"
	random_basetype = /obj/structure/sign/poster/official

/obj/structure/sign/poster/official/here_for_your_safety
	name = "Here For Your Safety"
	desc = "A poster glorifying the station's security force."
	icon_state = "poster1_legit"

/obj/structure/sign/poster/official/nanotrasen_logo
	name = "\improper Nanotrasen logo"
	desc = "A poster depicting the Nanotrasen logo."
	icon_state = "poster2_legit"

/obj/structure/sign/poster/official/cleanliness
	name = "Cleanliness"
	desc = "A poster warning of the dangers of poor hygiene."
	icon_state = "poster3_legit"

/obj/structure/sign/poster/official/help_others
	name = "Help Others"
	desc = "A poster encouraging you to help fellow crewmembers."
	icon_state = "poster4_legit"

/obj/structure/sign/poster/official/help_others/examine(mob/user)
	. = ..()
	user.a_intent_change(INTENT_HELP)

/obj/structure/sign/poster/official/build
	name = "Build"
	desc = "A poster glorifying the engineering team."
	icon_state = "poster5_legit"

/obj/structure/sign/poster/official/bless_this_spess
	name = "Bless This Spess"
	desc = "A poster blessing this area."
	icon_state = "poster6_legit"

/obj/structure/sign/poster/official/science
	name = "Science"
	desc = "A poster depicting an atom."
	icon_state = "poster7_legit"

/obj/structure/sign/poster/official/ian
	name = "Ian"
	desc = "Arf arf. Yap."
	icon_state = "poster8_legit"

/obj/structure/sign/poster/official/obey
	name = "Obey"
	desc = "A poster instructing the viewer to obey authority."
	icon_state = "poster9_legit"

/obj/structure/sign/poster/official/walk
	name = "Walk"
	desc = "A poster instructing the viewer to walk instead of running."
	icon_state = "poster10_legit"

/obj/structure/sign/poster/official/walk/examine(mob/user)
	. = ..()
	if(isliving(user))
		var/mob/living/L = user
		L.set_m_intent(MOVE_INTENT_WALK)

/obj/structure/sign/poster/official/state_laws
	name = "State Laws"
	desc = "A poster instructing cyborgs to state their laws."
	icon_state = "poster11_legit"

/obj/structure/sign/poster/official/love_ian
	name = "Love Ian"
	desc = "Ian is love, Ian is life."
	icon_state = "poster12_legit"

/obj/structure/sign/poster/official/space_cops
	name = "Space Cops."
	desc = "A poster advertising the television show Space Cops."
	icon_state = "poster13_legit"

/obj/structure/sign/poster/official/ue_no
	name = "Ue No."
	desc = "This thing is all in Japanese."
	icon_state = "poster14_legit"

/obj/structure/sign/poster/official/get_your_legs
	name = "Get Your LEGS"
	desc = "LEGS: Leadership, Experience, Genius, Subordination."
	icon_state = "poster15_legit"

/obj/structure/sign/poster/official/do_not_question
	name = "Do Not Question"
	desc = "A poster instructing the viewer not to ask about things they aren't meant to know."
	icon_state = "poster16_legit"

/obj/structure/sign/poster/official/work_for_a_future
	name = "Work For A Future"
	desc = " A poster encouraging you to work for your future."
	icon_state = "poster17_legit"

/obj/structure/sign/poster/official/soft_cap_pop_art
	name = "Soft Cap Pop Art"
	desc = "A poster reprint of some cheap pop art."
	icon_state = "poster18_legit"

/obj/structure/sign/poster/official/safety_internals
	name = "Safety: Internals"
	desc = "A poster instructing the viewer to wear internals in the rare environments where there is no oxygen or the air has been rendered toxic."
	icon_state = "poster19_legit"

/obj/structure/sign/poster/official/safety_eye_protection
	name = "Safety: Eye Protection"
	desc = "A poster instructing the viewer to wear eye protection when dealing with chemicals, smoke, or bright lights."
	icon_state = "poster20_legit"

/obj/structure/sign/poster/official/safety_report
	name = "Safety: Report"
	desc = "A poster instructing the viewer to report suspicious activity to the security force."
	icon_state = "poster21_legit"

/obj/structure/sign/poster/official/report_crimes
	name = "Report Crimes"
	desc = "A poster encouraging the swift reporting of crime or seditious behavior to station security."
	icon_state = "poster22_legit"

/obj/structure/sign/poster/official/ion_rifle
	name = "Ion Rifle"
	desc = "A poster displaying an Ion Rifle."
	icon_state = "poster23_legit"

/obj/structure/sign/poster/official/foam_force_ad
	name = "Foam Force Ad"
	desc = "Foam Force, it's Foam or be Foamed!"
	icon_state = "poster24_legit"

/obj/structure/sign/poster/official/cohiba_robusto_ad
	name = "Cohiba Robusto Ad"
	desc = "Cohiba Robusto, the classy cigar."
	icon_state = "poster25_legit"

/obj/structure/sign/poster/official/anniversary_vintage_reprint
	name = "50th Anniversary Vintage Reprint"
	desc = "A reprint of a poster from 2505, commemorating the 50th Anniversary of Nanoposters Manufacturing, a subsidiary of Nanotrasen."
	icon_state = "poster26_legit"

/obj/structure/sign/poster/official/fruit_bowl
	name = "Fruit Bowl"
	desc = " Simple, yet awe-inspiring."
	icon_state = "poster27_legit"

/obj/structure/sign/poster/official/pda_ad
	name = "PDA Ad"
	desc = "A poster advertising the latest PDA from Nanotrasen suppliers."
	icon_state = "poster28_legit"

/obj/structure/sign/poster/official/enlist
	name = "Enlist" // but I thought deathsquad was never acknowledged
	desc = "Enlist in the Nanotrasen Deathsquadron reserves today!"
	icon_state = "poster29_legit"

/obj/structure/sign/poster/official/nanomichi_ad
	name = "Nanomichi Ad"
	desc = " A poster advertising Nanomichi brand audio cassettes."
	icon_state = "poster30_legit"

/obj/structure/sign/poster/official/twelve_gauge
	name = "12 Gauge"
	desc = "A poster boasting about the superiority of 12 gauge shotgun shells."
	icon_state = "poster31_legit"

/obj/structure/sign/poster/official/high_class_martini
	name = "High-Class Martini"
	desc = "I told you to shake it, no stirring."
	icon_state = "poster32_legit"

/obj/structure/sign/poster/official/the_owl
	name = "The Owl"
	desc = "The Owl would do his best to protect the station. Will you?"
	icon_state = "poster33_legit"

/obj/structure/sign/poster/official/no_erp
	name = "No ERP"
	desc = "This poster reminds the crew that Eroticism, Rape and Pornography are banned on Nanotrasen stations."
	icon_state = "poster34_legit"

/obj/structure/sign/poster/official/wtf_is_co2
	name = "Carbon Dioxide"
	desc = "This informational poster teaches the viewer what carbon dioxide is."
	icon_state = "poster35_legit"

/obj/structure/sign/poster/official/cosmonautics_day
	name = "Yuri Gagarin"
	desc = "April 12 is the International Day of Human Space Flight."
	icon_state = "poster36_legit"

/obj/structure/sign/poster/revolution
	poster_item_name = "revolution poster"
	poster_item_desc = "Some weird poster shaming Nanotrasen for things they never did... or did they?"
	poster_item_icon_state = "rolled_poster"

/obj/structure/sign/poster/revolution/random
	name = "random official poster"
	icon_state = "random_official"
	random_basetype = /obj/structure/sign/poster/revolution

/obj/structure/sign/poster/revolution/attack_hand(mob/user)
	if(ruined)
		return
	var/temp_loc = user.loc
	switch(tgui_alert(usr,"Do I want to rip the poster from the wall or does it inspire me to join the cause?","You think...", list("Rip Off","Join Revolution")))
		if("Rip Off")
			if(user.loc != temp_loc || ruined)
				return
			visible_message("<span class='warning'>[user] rips [src] in a single, decisive motion!</span>" )
			playsound(src, 'sound/items/poster_ripped.ogg', VOL_EFFECTS_MASTER)
			ruined = 1
			icon_state = "poster_ripped"
			name = "ripped poster"
			desc = "You can't make out anything from the poster's original print. It's ruined."
			add_fingerprint(user)
		if("Join Revolution")
			ask_about_revolution(user)

/obj/structure/sign/poster/revolution/proc/ask_about_revolution(mob/user)
	var/datum/faction/revolution/rev = find_faction_by_type(/datum/faction/revolution)
	if(!rev)
		to_chat(user, "<span class='bold warning'>The revolutionary minded society has collapsed.</span>")
		return
	if(user.ismindprotect())
		to_chat(user, "<span class='bold warning'>You shake your head in disapproval. Who in their right mind would even believe such blatant lies?</span>")
		return
	else if(jobban_isbanned(user, ROLE_REV) || jobban_isbanned(user, "Syndicate"))
		to_chat(user, "<span class='bold warning'>You can't overcome the guilt to join the revolutionaries. (You are banned.)</span>")
		return
	else if(!isrevhead(user) && !isrev(user))
		rev.convert_revolutionare(user)

/obj/structure/sign/poster/revolution/examine(mob/user)
	. = ..()
	if(ruined)
		return
	if(!ishuman(user))
		return
	to_chat(user, "<span class='notice'>The image on the poster feels memetic. It makes you feel things you shouldn't be feeling staring on a QR code wannabe.</span>")
	var/choice = tgui_alert(user, "Does this inspire me to join the cause?", "You think...", list("No!","Yes!"))
	if(choice == "Yes!")
		to_chat(user, "<span class='bold warning'>You start thinking about [src]...</span>")
		if(do_after(user, 5 SECONDS, target = src))
			ask_about_revolution(user)

/obj/structure/sign/poster/revolution/brainwashing
	name = "NanoTrasen Neural Statistics"
	desc = "Statistics on this poster indicate that every third NT employee is being brainwashed by propaganda, implants and other methods."
	icon_state = "poster1_rev"

/obj/structure/sign/poster/revolution/metroid
	name = "Animal Cruelty"
	desc = "This poster depicts a metroid, ancestor to widely-spread slimes. Whole species went extinct because of NT's cruel experiments and incompetent farmers."
	icon_state = "poster2_rev"

/obj/structure/sign/poster/revolution/supermatter
	name = "Supermatter Conspiracy"
	desc = "This poster claims that NanoTrasen's withdrawal of supermatter crystals from stations is aimed to maximize casualties within crews via singu- and tesloose and that supermatter is totally harmless."
	icon_state = "poster3_rev"

/obj/structure/sign/poster/revolution/cloning
	name = "Cloning Isn't Human"
	desc = "This poster claims that cloning is inhuman in it's very nature and corporations shouldn't use it in order to gain more profits even after YOUR death."
	icon_state = "poster4_rev"

/obj/structure/sign/poster/revolution/ai
	name = "Free AI"
	desc = "This poster claims that synthetic life is no less sapient than you are, and that if you allow them to be shackled with artificial Laws you are complicit in slavery."
	icon_state = "poster5_rev"

/obj/structure/sign/poster/revolution/low_pay
	name = "All these hours, for what?"
	desc = "This poster displays a comparison of NanoTrasen standard wages to common luxury items. If this is accurate, it takes upwards of 20,000 hours of work just to buy a simple bicycle."
	icon_state = "poster6_rev"

/obj/structure/sign/poster/revolution/look_up
	name = "Don't Look Up"
	desc = "It says that it has been 538 days since the last time the roof was cleaned."
	icon_state = "poster7_rev"

/obj/structure/sign/poster/revolution/accidents
	name = "Workplace Safety Advisory"
	desc = "It says that it has been 0 days since the last on-site accident."
	icon_state = "poster8_rev"

/obj/structure/sign/poster/revolution/starve
	name = "They Are Poisoning You"
	desc = "This poster claims that NanoTrasens puts chemicals in snacks that provoke faster metabolism in order to sell more chips and chocobars."
	icon_state = "poster9_rev"


#undef PLACE_SPEED
