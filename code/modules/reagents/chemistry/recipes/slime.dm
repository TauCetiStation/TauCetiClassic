//Grey
/datum/chemical_reaction/slimespawn
			name = "Slime Spawn"
			id = "m_spawn"
			result = null
			required_reagents = list("phoron" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/grey
			required_other = 1
/datum/chemical_reaction/slimespawn/on_reaction(datum/reagents/holder)
	for(var/mob/O in viewers(get_turf_loc(holder.my_atom), null))
		O.show_message(text("\red Infused with phoron, the core begins to quiver and grow, and soon a new baby slime emerges from it!"), 1)
	var/mob/living/carbon/slime/S = new /mob/living/carbon/slime
	S.loc = get_turf_loc(holder.my_atom)


/datum/chemical_reaction/slimemonkey
			name = "Slime Monkey"
			id = "m_monkey"
			result = null
			required_reagents = list("blood" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/grey
			required_other = 1
/datum/chemical_reaction/slimemonkey/on_reaction(datum/reagents/holder)
	for(var/i = 1, i <= 3, i++)
		var /obj/item/weapon/reagent_containers/food/snacks/monkeycube/M = new /obj/item/weapon/reagent_containers/food/snacks/monkeycube
		M.loc = get_turf_loc(holder.my_atom)

//Green
/datum/chemical_reaction/slimemutate
			name = "Mutation Toxin"
			id = "mutationtoxin"
			result = "mutationtoxin"
			required_reagents = list("phoron" = 5)
			result_amount = 1
			required_other = 1
			required_container = /obj/item/slime_extract/green

//Metal
/datum/chemical_reaction/slimemetal
			name = "Slime Metal"
			id = "m_metal"
			result = null
			required_reagents = list("phoron" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/metal
			required_other = 1
/datum/chemical_reaction/slimemetal/on_reaction(datum/reagents/holder)
	new /obj/item/stack/sheet/metal(get_turf_loc(holder.my_atom), 15)
	new /obj/item/stack/sheet/plasteel(get_turf_loc(holder.my_atom), 5)

//Gold
/datum/chemical_reaction/slimecrit
			name = "Slime Crit"
			id = "m_tele"
			result = null
			required_reagents = list("phoron" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/gold
			required_other = 1
/datum/chemical_reaction/slimecrit/on_reaction(datum/reagents/holder)

				/*var/blocked = list(/mob/living/simple_animal/hostile,
					/mob/living/simple_animal/hostile/pirate,
					/mob/living/simple_animal/hostile/pirate/ranged,
					/mob/living/simple_animal/hostile/russian,
					/mob/living/simple_animal/hostile/russian/ranged,
					/mob/living/simple_animal/hostile/syndicate,
					/mob/living/simple_animal/hostile/syndicate/melee,
					/mob/living/simple_animal/hostile/syndicate/melee/space,
					/mob/living/simple_animal/hostile/syndicate/ranged,
					/mob/living/simple_animal/hostile/syndicate/ranged/space,
					/mob/living/simple_animal/hostile/alien/queen/large,
					/mob/living/simple_animal/hostile/faithless,
					/mob/living/simple_animal/hostile/panther,
					/mob/living/simple_animal/hostile/snake,
					/mob/living/simple_animal/hostile/retaliate,
					/mob/living/simple_animal/hostile/retaliate/clown
					)//exclusion list for things you don't want the reaction to create.
				var/list/critters = typesof(/mob/living/simple_animal/hostile) - blocked // list of possible hostile mobs

				playsound(get_turf_loc(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

				for(var/mob/living/carbon/human/M in viewers(get_turf_loc(holder.my_atom), null))
					if(M:eyecheck() <= 0)
						M.flash_eyes()

				for(var/i = 1, i <= 5, i++)
					var/chosen = pick(critters)
					var/mob/living/simple_animal/hostile/C = new chosen
					C.faction = "slimesummon"
					C.loc = get_turf_loc(holder.my_atom)
					if(prob(50))
						for(var/j = 1, j <= rand(1, 3), j++)
							step(C, pick(NORTH,SOUTH,EAST,WEST))*/
	for(var/mob/O in viewers(get_turf_loc(holder.my_atom), null))
		O.show_message(text("\red The slime core fizzles disappointingly,"), 1)

//Silver
/datum/chemical_reaction/slimebork
			name = "Slime Bork"
			id = "m_tele2"
			result = null
			required_reagents = list("phoron" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/silver
			required_other = 1
/datum/chemical_reaction/slimebork/on_reaction(datum/reagents/holder)

	var/list/borks = typesof(/obj/item/weapon/reagent_containers/food/snacks) - /obj/item/weapon/reagent_containers/food/snacks
				// BORK BORK BORK

	playsound(get_turf_loc(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/living/carbon/human/M in viewers(get_turf_loc(holder.my_atom), null))
		if(M:eyecheck() <= 0)
			M.flash_eyes()

	for(var/i = 1, i <= 4 + rand(1,2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.loc = get_turf_loc(holder.my_atom)
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))

/datum/chemical_reaction/slimebork2
			name = "Slime Bork 2"
			id = "m_tele4"
			result = null
			required_reagents = list("water" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/silver
			required_other = 1
/datum/chemical_reaction/slimebork2/on_reaction(datum/reagents/holder)

	var/list/borks2 = typesof(/obj/item/weapon/reagent_containers/food/drinks) - /obj/item/weapon/reagent_containers/food/drinks
	// BORK BORK BORK

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/living/carbon/human/M in viewers(get_turf(holder.my_atom), null))
		if(M:eyecheck() <= 0)
			M.flash_eyes()

	for(var/i = 1, i <= 4 + rand(1,2), i++)
		var/chosen = pick(borks2)
		var/obj/B = new chosen
		if(B)
			B.loc = get_turf(holder.my_atom)
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))


//Blue
/datum/chemical_reaction/slimefrost
			name = "Slime Frost Oil"
			id = "m_frostoil"
			result = "frostoil"
			required_reagents = list("phoron" = 5)
			result_amount = 10
			required_container = /obj/item/slime_extract/blue
			required_other = 1
//Dark Blue
/datum/chemical_reaction/slimefreeze
			name = "Slime Freeze"
			id = "m_freeze"
			result = null
			required_reagents = list("phoron" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/darkblue
			required_other = 1
/datum/chemical_reaction/slimefreeze/on_reaction(datum/reagents/holder)
	for(var/mob/O in viewers(get_turf_loc(holder.my_atom), null))
		O.show_message(text("\red The slime extract begins to vibrate violently !"), 1)
	sleep(50)
	playsound(get_turf_loc(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)
	for(var/mob/living/M in range (get_turf_loc(holder.my_atom), 7))
		M.bodytemperature -= 140
		to_chat(M, "\blue You feel a chill!")

//Orange
/datum/chemical_reaction/slimecasp
			name = "Slime Capsaicin Oil"
			id = "m_capsaicinoil"
			result = "capsaicin"
			required_reagents = list("blood" = 5)
			result_amount = 10
			required_container = /obj/item/slime_extract/orange
			required_other = 1

/datum/chemical_reaction/slimefire
			name = "Slime fire"
			id = "m_fire"
			result = null
			required_reagents = list("phoron" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/orange
			required_other = 1
/datum/chemical_reaction/slimefire/on_reaction(datum/reagents/holder)
	for(var/mob/O in viewers(get_turf_loc(holder.my_atom), null))
		O.show_message(text("\red The slime extract begins to vibrate violently !"), 1)
	sleep(50)
	if(!(holder.my_atom && holder.my_atom.loc))
		return

	var/turf/location = get_turf(holder.my_atom.loc)
	for(var/turf/simulated/floor/target_tile in range(0, location))
		target_tile.assume_gas("phoron", 25, 1400)
		spawn (0)
			target_tile.hotspot_expose(700, 400)
	message_admins("Orange slime extract activated by [key_name_admin(usr)](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>)")
	log_game("Orange slime extract activated by [usr.ckey]([usr])")

//Yellow
/datum/chemical_reaction/slimeoverload
			name = "Slime EMP"
			id = "m_emp"
			result = null
			required_reagents = list("blood" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/yellow
			required_other = 1
/datum/chemical_reaction/slimeoverload/on_reaction(datum/reagents/holder, created_volume)
	empulse(get_turf_loc(holder.my_atom), 3, 7)
	message_admins("Yellow slime extract activated by [key_name_admin(usr)](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>)")
	log_game("Yellow slime extract activated by [usr.ckey]([usr])")

/datum/chemical_reaction/slimecell
			name = "Slime Powercell"
			id = "m_cell"
			result = null
			required_reagents = list("phoron" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/yellow
			required_other = 1
/datum/chemical_reaction/slimecell/on_reaction(datum/reagents/holder, created_volume)
	var/obj/item/weapon/stock_parts/cell/slime/P = new /obj/item/weapon/stock_parts/cell/slime
	P.loc = get_turf_loc(holder.my_atom)

/datum/chemical_reaction/slimeglow
			name = "Slime Glow"
			id = "m_glow"
			result = null
			required_reagents = list("water" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/yellow
			required_other = 1
/datum/chemical_reaction/slimeglow/on_reaction(datum/reagents/holder)
	for(var/mob/O in viewers(get_turf_loc(holder.my_atom), null))
		O.show_message(text("\red The contents of the slime core harden and begin to emit a warm, bright light."), 1)
	var/obj/item/device/flashlight/slime/F = new /obj/item/device/flashlight/slime
	F.loc = get_turf(holder.my_atom)

//Purple

/datum/chemical_reaction/slimepsteroid
			name = "Slime Steroid"
			id = "m_steroid"
			result = null
			required_reagents = list("phoron" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/purple
			required_other = 1
/datum/chemical_reaction/slimepsteroid/on_reaction(datum/reagents/holder)
	var/obj/item/weapon/slimesteroid/P = new /obj/item/weapon/slimesteroid
	P.loc = get_turf_loc(holder.my_atom)



/datum/chemical_reaction/slimejam
			name = "Slime Jam"
			id = "m_jam"
			result = "slimejelly"
			required_reagents = list("sugar" = 5)
			result_amount = 10
			required_container = /obj/item/slime_extract/purple
			required_other = 1


//Dark Purple
/datum/chemical_reaction/slimeplasma
			name = "Slime Plasma"
			id = "m_plasma"
			result = null
			required_reagents = list("phoron" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/darkpurple
			required_other = 1
/datum/chemical_reaction/slimeplasma/on_reaction(datum/reagents/holder)
	new /obj/item/stack/sheet/mineral/phoron(get_turf_loc(holder.my_atom), 10)

//Red
/datum/chemical_reaction/slimeglycerol
			name = "Slime Glycerol"
			id = "m_glycerol"
			result = "glycerol"
			required_reagents = list("phoron" = 5)
			result_amount = 8
			required_container = /obj/item/slime_extract/red
			required_other = 1


/datum/chemical_reaction/slimebloodlust
			name = "Bloodlust"
			id = "m_bloodlust"
			result = null
			required_reagents = list("blood" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/red
			required_other = 1
/datum/chemical_reaction/slimebloodlust/on_reaction(datum/reagents/holder)
	for(var/mob/living/carbon/slime/slime in viewers(get_turf_loc(holder.my_atom), null))
		slime.tame = 0
		slime.rabid = 1
		for(var/mob/O in viewers(get_turf_loc(holder.my_atom), null))
			O.show_message(text("\red The [slime] is driven into a frenzy!."), 1)

//Pink
/datum/chemical_reaction/slimeppotion
			name = "Slime Potion"
			id = "m_potion"
			result = null
			required_reagents = list("phoron" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/pink
			required_other = 1
/datum/chemical_reaction/slimeppotion/on_reaction(datum/reagents/holder)
	var/obj/item/weapon/slimepotion/P = new /obj/item/weapon/slimepotion
	P.loc = get_turf_loc(holder.my_atom)


//Black
/datum/chemical_reaction/slimemutate2
			name = "Advanced Mutation Toxin"
			id = "mutationtoxin2"
			result = "amutationtoxin"
			required_reagents = list("phoron" = 5)
			result_amount = 1
			required_other = 1
			required_container = /obj/item/slime_extract/black

//Oil
/datum/chemical_reaction/slimeexplosion
			name = "Slime Explosion"
			id = "m_explosion"
			result = null
			required_reagents = list("phoron" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/oil
			required_other = 1
/datum/chemical_reaction/slimeexplosion/on_reaction(datum/reagents/holder)
	for(var/mob/O in viewers(get_turf_loc(holder.my_atom), null))
		O.show_message(text("\red The slime extract begins to vibrate violently !"), 1)
	sleep(50)
	explosion(get_turf_loc(holder.my_atom), 1 ,3, 6)
	message_admins("Oil slime extract activated by [key_name_admin(usr)](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>)")
	log_game("Oil slime extract activated by [usr.ckey]([usr])")
//Light Pink
/datum/chemical_reaction/slimepotion2
			name = "Slime Potion 2"
			id = "m_potion2"
			result = null
			result_amount = 1
			required_container = /obj/item/slime_extract/lightpink
			required_reagents = list("phoron" = 5)
			required_other = 1
/datum/chemical_reaction/slimepotion2/on_reaction(datum/reagents/holder)
	var/obj/item/weapon/slimepotion2/P = new /obj/item/weapon/slimepotion2
	P.loc = get_turf_loc(holder.my_atom)
//Adamantine
/datum/chemical_reaction/slimegolem
			name = "Slime Golem"
			id = "m_golem"
			result = null
			required_reagents = list("phoron" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/adamantine
			required_other = 1
/datum/chemical_reaction/slimegolem/on_reaction(datum/reagents/holder)
	var/obj/effect/golemrune/Z = new /obj/effect/golemrune
	Z.loc = get_turf_loc(holder.my_atom)

//Bluespace
/datum/chemical_reaction/slimecrystal
			name = "Slime Crystal"
			id = "m_crystal"
			result = null
			required_reagents = list("blood" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/bluespace
			required_other = 1
/datum/chemical_reaction/slimecrystal/on_reaction(datum/reagents/holder)
	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		O.show_message(text("\red The bluespace crystal appears out of thin air!"), 1)
	var/obj/item/bluespace_crystal/I = new /obj/item/bluespace_crystal
	I.loc = get_turf(holder.my_atom)

//Cerulean
/datum/chemical_reaction/slimepsteroid2
			name = "Slime Steroid 2"
			id = "m_steroid2"
			result = null
			required_reagents = list("phoron" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/cerulean
			required_other = 1
/datum/chemical_reaction/slimepsteroid2/on_reaction(datum/reagents/holder)
	var/obj/item/weapon/slimesteroid2/P = new /obj/item/weapon/slimesteroid2
	P.loc = get_turf(holder.my_atom)

//Sepia
/datum/chemical_reaction/slimecamera
			name = "Slime Camera"
			id = "m_camera"
			result = null
			required_reagents = list("phoron" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/sepia
			required_other = 1
/datum/chemical_reaction/slimecamera/on_reaction(datum/reagents/holder)
	var/obj/item/device/camera/P = new /obj/item/device/camera
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimefilm
			name = "Slime Film"
			id = "m_film"
			result = null
			required_reagents = list("blood" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/sepia
			required_other = 1
/datum/chemical_reaction/slimefilm/on_reaction(datum/reagents/holder)
	var/obj/item/device/camera_film/P = new /obj/item/device/camera_film
	P.loc = get_turf(holder.my_atom)

//Pyrite
/datum/chemical_reaction/slimepaint
			name = "Slime Paint"
			id = "s_paint"
			result = null
			required_reagents = list("phoron" = 5)
			result_amount = 1
			required_container = /obj/item/slime_extract/pyrite
			required_other = 1
/datum/chemical_reaction/slimepaint/on_reaction(datum/reagents/holder)
	var/list/paints = typesof(/obj/item/weapon/reagent_containers/glass/paint) - /obj/item/weapon/reagent_containers/glass/paint
	var/chosen = pick(paints)
	var/obj/B = new chosen
	if(B)
		B.loc = get_turf(holder.my_atom)