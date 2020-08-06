///////////////////////////////////////////////////////////////////////////////////
/datum/chemical_reaction
	var/name = null
	var/id = null
	var/result = null
	var/list/required_reagents = new/list()
	var/list/required_catalysts = new/list()

	// Both of these variables are mostly going to be used with slime cores - but if you want to, you can use them for other things
	var/atom/required_container = null // the container required for the reaction to happen
	var/required_other = 0 // an integer required for the reaction to happen

	var/result_amount = 0
	var/secondary = 0 // set to nonzero if secondary reaction
	var/list/secondary_results = list()		//additional reagents produced by the reaction
	var/requires_heating = 0

/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, created_volume)
	return

/datum/chemical_reaction/proc/check_requirements(datum/reagents/holder)
	return TRUE

		//I recommend you set the result amount to the total volume of all components.

/datum/chemical_reaction/explosion_potassium
	name = "Explosion"
	id = "explosion_potassium"
	result = null
	required_reagents = list("water" = 1, "potassium" = 1)
	result_amount = 2

/datum/chemical_reaction/explosion_potassium/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/reagents_explosion/e = new()
	e.set_up(round (created_volume/10, 1), location, 0, 0)
	e.start()
	holder.clear_reagents()

/datum/chemical_reaction/emp_pulse
	name = "EMP Pulse"
	id = "emp_pulse"
	result = null
	required_reagents = list("uranium" = 1, "iron" = 1) // Yes, laugh, it's the best recipe I could think of that makes a little bit of sense
	result_amount = 2

/datum/chemical_reaction/emp_pulse/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	// 100 created volume = 4 heavy range & 7 light range. A few tiles smaller than traitor EMP grandes.
	// 200 created volume = 8 heavy range & 14 light range. 4 tiles larger than traitor EMP grenades.
	empulse(location, round(created_volume / 24), round(created_volume / 14), 1)
	holder.clear_reagents()
	return
/*
/datum/chemical_reaction/silicate
	name = "Silicate"
	id = "silicate"
	result = "silicate"
	required_reagents = list("aluminum" = 1, "silicon" = 1, "oxygen" = 1)
	result_amount = 3
*/
/datum/chemical_reaction/stoxin
	name = "Sleep Toxin"
	id = "stoxin"
	result = "stoxin"
	required_reagents = list("chloralhydrate" = 1, "sugar" = 4)
	result_amount = 5

/datum/chemical_reaction/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	result = "sterilizine"
	required_reagents = list("ethanol" = 1, "anti_toxin" = 1, "chlorine" = 1)
	result_amount = 3

/datum/chemical_reaction/inaprovaline
	name = "Inaprovaline"
	id = "inaprovaline"
	result = "inaprovaline"
	required_reagents = list("oxygen" = 1, "carbon" = 1, "sugar" = 1)
	result_amount = 3

/datum/chemical_reaction/anti_toxin
	name = "Anti-Toxin (Dylovene)"
	id = "anti_toxin"
	result = "anti_toxin"
	required_reagents = list("silicon" = 1, "potassium" = 1, "nitrogen" = 1)
	result_amount = 3

/datum/chemical_reaction/thermopsis
	name = "Thermopsis"
	id = "thermopsis"
	result = "thermopsis"
	required_reagents = list("anti_toxin" = 1, "sugar" = 1, "carbon" = 1)
	result_amount = 3

/datum/chemical_reaction/mutagen
	name = "Unstable mutagen"
	id = "mutagen"
	result = "mutagen"
	required_reagents = list("radium" = 1, "phosphorus" = 1, "chlorine" = 1)
	result_amount = 3

/datum/chemical_reaction/tramadol
	name = "Tramadol"
	id = "tramadol"
	result = "tramadol"
	required_reagents = list("inaprovaline" = 1, "ethanol" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/paracetamol
	name = "Paracetamol"
	id = "paracetamol"
	result = "paracetamol"
	required_reagents = list("tramadol" = 1, "sugar" = 1, "water" = 1)
	result_amount = 3

/datum/chemical_reaction/oxycodone
	name = "Oxycodone"
	id = "oxycodone"
	result = "oxycodone"
	required_reagents = list("ethanol" = 1, "tramadol" = 1)
	required_catalysts = list("phoron" = 1)
	result_amount = 1

///datum/chemical_reaction/cyanide
//	name = "Cyanide"
//	id = "cyanide"
//	result = "cyanide"
//	required_reagents = list("hydrogen" = 1, "carbon" = 1, "nitrogen" = 1)
//	result_amount = 1

/datum/chemical_reaction/water //I can't believe we never had this.
	name = "Water"
	id = "water"
	result = "water"
	required_reagents = list("oxygen" = 2, "hydrogen" = 1)
	result_amount = 1

/datum/chemical_reaction/thermite
	name = "Thermite"
	id = "thermite"
	result = "thermite"
	required_reagents = list("aluminum" = 1, "iron" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/lexorin
	name = "Lexorin"
	id = "lexorin"
	result = "lexorin"
	required_reagents = list("phoron" = 1, "hydrogen" = 1, "nitrogen" = 1)
	result_amount = 3

/datum/chemical_reaction/nicotine
	name = "Nicotine"
	id = "nicotine"
	result = "nicotine"
	required_reagents = list("lexorin" = 5, "nitrogen" = 2, "inaprovaline" = 1)
	result_amount = 5

/datum/chemical_reaction/space_drugs
	name = "Space Drugs"
	id = "space_drugs"
	result = "space_drugs"
	required_reagents = list("mercury" = 1, "sugar" = 1, "lithium" = 1)
	result_amount = 3

/datum/chemical_reaction/lube
	name = "Space Lube"
	id = "lube"
	result = "lube"
	required_reagents = list("water" = 1, "silicon" = 1, "oxygen" = 1)
	result_amount = 4

/datum/chemical_reaction/pacid
	name = "Polytrinic acid"
	id = "pacid"
	result = "pacid"
	required_reagents = list("sacid" = 1, "chlorine" = 1, "potassium" = 1)
	result_amount = 3

/datum/chemical_reaction/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	result = "synaptizine"
	required_reagents = list("sugar" = 1, "lithium" = 1, "water" = 1)
	result_amount = 3

/datum/chemical_reaction/hyronalin
	name = "Hyronalin"
	id = "hyronalin"
	result = "hyronalin"
	required_reagents = list("radium" = 1, "anti_toxin" = 1)
	result_amount = 2

/datum/chemical_reaction/arithrazine
	name = "Arithrazine"
	id = "arithrazine"
	result = "arithrazine"
	required_reagents = list("hyronalin" = 1, "hydrogen" = 1)
	result_amount = 2

/datum/chemical_reaction/impedrezene
	name = "Impedrezene"
	id = "impedrezene"
	result = "impedrezene"
	required_reagents = list("mercury" = 1, "oxygen" = 1, "sugar" = 1)
	result_amount = 2

/datum/chemical_reaction/kelotane
	name = "Kelotane"
	id = "kelotane"
	result = "kelotane"
	required_reagents = list("silicon" = 1, "carbon" = 1)
	result_amount = 2

/datum/chemical_reaction/peridaxon
	name = "Peridaxon"
	id = "peridaxon"
	result = "peridaxon"
	required_reagents = list("bicaridine" = 2, "clonexadone" = 2)
	required_catalysts = list("phoron" = 5)
	result_amount = 2

/datum/chemical_reaction/virus_food
	name = "Virus Food"
	id = "virusfood"
	result = "virusfood"
	required_reagents = list("water" = 1, "milk" = 1)
	result_amount = 5

/datum/chemical_reaction/leporazine
	name = "Leporazine"
	id = "leporazine"
	result = "leporazine"
	required_reagents = list("silicon" = 1, "copper" = 1)
	required_catalysts = list("phoron" = 5)
	result_amount = 2

/datum/chemical_reaction/cryptobiolin
	name = "Cryptobiolin"
	id = "cryptobiolin"
	result = "cryptobiolin"
	required_reagents = list("potassium" = 1, "oxygen" = 1, "sugar" = 1)
	result_amount = 3

/datum/chemical_reaction/tricordrazine
	name = "Tricordrazine"
	id = "tricordrazine"
	result = "tricordrazine"
	required_reagents = list("inaprovaline" = 1, "anti_toxin" = 1)
	result_amount = 2

/datum/chemical_reaction/alkysine
	name = "Alkysine"
	id = "alkysine"
	result = "alkysine"
	required_reagents = list("chlorine" = 1, "nitrogen" = 1, "anti_toxin" = 1)
	result_amount = 2

/datum/chemical_reaction/dexalin
	name = "Dexalin"
	id = "dexalin"
	result = "dexalin"
	required_reagents = list("oxygen" = 2, "phoron" = 0.1)
	required_catalysts = list("phoron" = 5)
	result_amount = 1

/datum/chemical_reaction/dermaline
	name = "Dermaline"
	id = "dermaline"
	result = "dermaline"
	required_reagents = list("oxygen" = 1, "phosphorus" = 1, "kelotane" = 1)
	result_amount = 3

/datum/chemical_reaction/dexalinp
	name = "Dexalin Plus"
	id = "dexalinp"
	result = "dexalinp"
	required_reagents = list("dexalin" = 1, "carbon" = 1, "iron" = 1)
	result_amount = 3

/datum/chemical_reaction/bicaridine
	name = "Bicaridine"
	id = "bicaridine"
	result = "bicaridine"
	required_reagents = list("inaprovaline" = 1, "carbon" = 1)
	result_amount = 2

/datum/chemical_reaction/kyphotorin
	name = "Kyphotorin"
	id = "kyphotorin"
	result = "kyphotorin"
	required_reagents = list("lexorin" = 5, "peridaxon" = 5, "nanobots" = 1, "dexalinp" = 5, "sugar" = 5, "iron" = 5)
	result_amount = 5

/datum/chemical_reaction/hyperzine
	name = "Hyperzine"
	id = "hyperzine"
	result = "hyperzine"
	required_reagents = list("sugar" = 1, "phosphorus" = 1, "sulfur" = 1,)
	result_amount = 3

/datum/chemical_reaction/ryetalyn
	name = "Ryetalyn"
	id = "ryetalyn"
	result = "ryetalyn"
	required_reagents = list("arithrazine" = 1, "carbon" = 1)
	result_amount = 2

/datum/chemical_reaction/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	result = "cryoxadone"
	required_reagents = list("dexalin" = 1, "water" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/clonexadone
	name = "Clonexadone"
	id = "clonexadone"
	result = "clonexadone"
	required_reagents = list("cryoxadone" = 1, "sodium" = 1, "phoron" = 0.1)
	required_catalysts = list("phoron" = 5)
	result_amount = 2

/datum/chemical_reaction/spaceacillin
	name = "Spaceacillin"
	id = "spaceacillin"
	result = "spaceacillin"
	required_reagents = list("cryptobiolin" = 1, "inaprovaline" = 1)
	result_amount = 2

/datum/chemical_reaction/imidazoline
	name = "imidazoline"
	id = "imidazoline"
	result = "imidazoline"
	required_reagents = list("carbon" = 1, "hydrogen" = 1, "anti_toxin" = 1)
	result_amount = 2

/datum/chemical_reaction/dextromethorphan
	name = "Dextromethorphan"
	id = "dextromethorphan"
	result = "dextromethorphan"
	required_reagents = list("dexalinp" = 1, "oxycodone" = 1)
	required_catalysts = list("phoron" = 5)
	result_amount = 2

/datum/chemical_reaction/ethylredoxrazine
	name = "Ethylredoxrazine"
	id = "ethylredoxrazine"
	result = "ethylredoxrazine"
	required_reagents = list("oxygen" = 1, "anti_toxin" = 1, "carbon" = 1)
	result_amount = 3

/datum/chemical_reaction/ethanoloxidation
	name = "ethanoloxidation"	//Kind of a placeholder in case someone ever changes it so that chemicals
	id = "ethanoloxidation"		//	react in the body. Also it would be silly if it didn't exist.
	result = "water"
	required_reagents = list("ethylredoxrazine" = 1, "ethanol" = 1)
	result_amount = 2

/datum/chemical_reaction/glycerol
	name = "Glycerol"
	id = "glycerol"
	result = "glycerol"
	required_reagents = list("cornoil" = 3, "sacid" = 1)
	result_amount = 1

/datum/chemical_reaction/nitroglycerin
	name = "Nitroglycerin"
	id = "nitroglycerin"
	result = "nitroglycerin"
	required_reagents = list("glycerol" = 1, "pacid" = 1, "sacid" = 1)
	result_amount = 2

/datum/chemical_reaction/nitroglycerin/on_reaction(datum/reagents/holder, created_volume)
	var/datum/effect/effect/system/reagents_explosion/e = new()
	e.set_up(round (created_volume/2, 1), holder.my_atom, 0, 0)
	e.holder_damage(holder.my_atom)
	if(isliving(holder.my_atom))
		e.amount *= 0.5
		var/mob/living/L = holder.my_atom
		if(L.stat!=DEAD)
			e.amount *= 0.5
	e.start()

	holder.clear_reagents()
	return

/datum/chemical_reaction/sodiumchloride
	name = "Sodium Chloride"
	id = "sodiumchloride"
	result = "sodiumchloride"
	required_reagents = list("sodium" = 1, "chlorine" = 1)
	result_amount = 2

/datum/chemical_reaction/flash_powder
	name = "Flash powder"
	id = "flash_powder"
	result = null
	required_reagents = list("aluminum" = 1, "potassium" = 1, "sulfur" = 1 )
	result_amount = null

/datum/chemical_reaction/flash_powder/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(2, 1, location)
	s.start()

	var/range = created_volume / 3
	if(isatom(holder.my_atom))
		var/atom/A = holder.my_atom
		A.flash_lighting_fx(_range = (range + 2), _reset_lighting = FALSE)

	for(var/mob/living/carbon/M in viewers(world.view, location))
		if(M.eyecheck() > 0)
			continue
		M.flash_eyes()
		switch(get_dist(M, location))
			if(0 to 3)
				M.Weaken(15)

			if(4 to 5)
				M.Stun(5)

/datum/chemical_reaction/napalm
	name = "Napalm"
	id = "napalm"
	result = null
	required_reagents = list("aluminum" = 1, "phoron" = 1, "sacid" = 1 )
	result_amount = 1

/datum/chemical_reaction/napalm/on_reaction(datum/reagents/holder, created_volume)
	var/turf/simulated/T = get_turf(holder.my_atom.loc)
	for(var/turf/simulated/target_tile in range(1, T))
		if(!target_tile.blocks_air && !target_tile.density)
			target_tile.assume_gas("phoron", created_volume * 0.2)
			INVOKE_ASYNC(target_tile, /turf/simulated.proc/hotspot_expose, 700, 400, holder.my_atom)
	holder.del_reagent("napalm")

		/*
/datum/chemical_reaction/smoke
	name = "Smoke"
	id = "smoke"
	result = null
	required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1 )
	result_amount = null
	secondary = 1

/datum/chemical_reaction/smoke/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/system/bad_smoke_spread/S = new /datum/effect/system/bad_smoke_spread
	S.attach(location)
	S.set_up(10, 0, location)
	playsound(location, 'sound/effects/smoke.ogg', VOL_EFFECTS_MASTER, null, null, -3)
	spawn(0)
		S.start()
		sleep(10)
		S.start()
		sleep(10)
		S.start()
		sleep(10)
		S.start()
		sleep(10)
		S.start()
	holder.clear_reagents()
	return	*/

/datum/chemical_reaction/chemsmoke
	name = "Chemsmoke"
	id = "chemsmoke"
	result = null
	required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1)
	result_amount = 0.4
	secondary = 1

/datum/chemical_reaction/chemsmoke/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/smoke_spread/chem/S = new /datum/effect/effect/system/smoke_spread/chem
	S.attach(location)
	S.set_up(holder, created_volume, 0, location)
	playsound(location, 'sound/effects/smoke.ogg', VOL_EFFECTS_MASTER, null, null, -3)
	spawn(0)
		S.start()
	holder.clear_reagents()
	return

/datum/chemical_reaction/chloralhydrate
	name = "Chloral Hydrate"
	id = "chloralhydrate"
	result = "chloralhydrate"
	required_reagents = list("ethanol" = 1, "chlorine" = 3, "water" = 1)
	result_amount = 1

/datum/chemical_reaction/mutetoxin //i'll just fit this in here snugly between other unfun chemicals :v @ TG Port
	name = "Mute toxin"
	id = "mutetoxin"
	result = "mutetoxin"
	required_reagents = list("uranium" = 2, "water" = 1, "carbon" = 1)
	result_amount = 2

/datum/chemical_reaction/potassium_chloride
	name = "Potassium Chloride"
	id = "potassium_chloride"
	result = "potassium_chloride"
	required_reagents = list("sodiumchloride" = 1, "potassium" = 1)
	result_amount = 2

/datum/chemical_reaction/potassium_chlorophoride
	name = "Potassium Chlorophoride"
	id = "potassium_chlorophoride"
	result = "potassium_chlorophoride"
	required_reagents = list("potassium_chloride" = 1, "phoron" = 1, "chloralhydrate" = 1)
	result_amount = 4

/datum/chemical_reaction/stoxin
	name = "Sleep Toxin"
	id = "stoxin"
	result = "stoxin"
	required_reagents = list("chloralhydrate" = 1, "sugar" = 4)
	result_amount = 5

/datum/chemical_reaction/zombiepowder
	name = "Zombie Powder"
	id = "zombiepowder"
	result = "zombiepowder"
	required_reagents = list("carpotoxin" = 5, "stoxin" = 5, "copper" = 5)
	result_amount = 2

/datum/chemical_reaction/rezadone
	name = "Rezadone"
	id = "rezadone"
	result = "rezadone"
	required_reagents = list("carpotoxin" = 1, "cryptobiolin" = 1, "copper" = 1)
	result_amount = 3

/datum/chemical_reaction/mindbreaker
	name = "Mindbreaker Toxin"
	id = "mindbreaker"
	result = "mindbreaker"
	required_reagents = list("silicon" = 1, "hydrogen" = 1, "anti_toxin" = 1)
	result_amount = 3

/datum/chemical_reaction/lipozine
	name = "Lipozine"
	id = "Lipozine"
	result = "lipozine"
	required_reagents = list("sodiumchloride" = 1, "ethanol" = 1, "radium" = 1)
	result_amount = 3

/datum/chemical_reaction/phoronsolidification
	name = "Solid Phoron"
	id = "solidphoron"
	result = null
	required_reagents = list("iron" = 5, "frostoil" = 5, "phoron" = 20)
	result_amount = 1

/datum/chemical_reaction/phoronsolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/mineral/phoron(location)
	return

/datum/chemical_reaction/plastication
	name = "Plastic"
	id = "solidplastic"
	result = null
	required_reagents = list("pacid" = 10, "plasticide" = 20)
	result_amount = 1

/datum/chemical_reaction/plastication/on_reaction(datum/reagents/holder)
	new /obj/item/stack/sheet/mineral/plastic(get_turf(holder.my_atom),10)
	return

/datum/chemical_reaction/virus_food
	name = "Virus Food"
	id = "virusfood"
	result = "virusfood"
	required_reagents = list("water" = 5, "milk" = 5, "oxygen" = 5)
	result_amount = 15
/*
/datum/chemical_reaction/mix_virus
	name = "Mix Virus"
	id = "mixvirus"
	result = "blood"
	required_reagents = list("virusfood" = 5)
	required_catalysts = list("blood")
	var/level = 2

/datum/chemical_reaction/mix_virus/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Evolve(level - rand(0, 1))


/datum/chemical_reaction/mix_virus/mix_virus_2
	name = "Mix Virus 2"
	id = "mixvirus2"
	required_reagents = list("mutagen" = 5)
	level = 4

/datum/chemical_reaction/mix_virus/rem_virus
	name = "Devolve Virus"
	id = "remvirus"
	required_reagents = list("synaptizine" = 5)

/datum/chemical_reaction/mix_virus/rem_virus/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Devolve()
*/
/datum/chemical_reaction/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = "condensedcapsaicin"
	result = "condensedcapsaicin"
	required_reagents = list("capsaicin" = 2)
	required_catalysts = list("phoron" = 5)
	result_amount = 1
///////////////////////////////////////////////////////////////////////////////////

// foam and foam precursor

/datum/chemical_reaction/surfactant
	name = "Foam surfactant"
	id = "foam surfactant"
	result = "fluorosurfactant"
	required_reagents = list("fluorine" = 2, "carbon" = 2, "sacid" = 1)
	result_amount = 5


/datum/chemical_reaction/foam
	name = "Foam"
	id = "foam"
	result = null
	required_reagents = list("fluorosurfactant" = 1, "water" = 1)
	result_amount = 2

/datum/chemical_reaction/foam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/mob/M in viewers(5, location))
		to_chat(M, "<span class='warning'>The solution violently bubbles!</span>")

	location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		to_chat(M, "<span class='warning'>The solution spews out foam!</span>")

	//world << "Holder volume is [holder.total_volume]"
	//for(var/datum/reagent/R in holder.reagent_list)
	//	world << "[R.name] = [R.volume]"

	var/datum/effect/effect/system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 0)
	s.start()
	holder.clear_reagents()
	return

/datum/chemical_reaction/metalfoam
	name = "Metal Foam"
	id = "metalfoam"
	result = null
	required_reagents = list("aluminum" = 3, "foaming_agent" = 1, "pacid" = 1)
	result_amount = 5

/datum/chemical_reaction/metalfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		to_chat(M, "<span class='warning'>The solution spews out a metalic foam!</span>")

	var/datum/effect/effect/system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 1)
	s.start()
	return

/datum/chemical_reaction/ironfoam
	name = "Iron Foam"
	id = "ironlfoam"
	result = null
	required_reagents = list("iron" = 3, "foaming_agent" = 1, "pacid" = 1)
	result_amount = 5

/datum/chemical_reaction/ironfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		to_chat(M, "<span class='warning'>The solution spews out a metalic foam!</span>")

	var/datum/effect/effect/system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 2)
	s.start()
	return



/datum/chemical_reaction/foaming_agent
	name = "Foaming Agent"
	id = "foaming_agent"
	result = "foaming_agent"
	required_reagents = list("lithium" = 1, "hydrogen" = 1)
	result_amount = 1

// Synthesizing these three chemicals is pretty complex in real life, but fuck it, it's just a game!
/datum/chemical_reaction/ammonia
	name = "Ammonia"
	id = "ammonia"
	result = "ammonia"
	required_reagents = list("hydrogen" = 3, "nitrogen" = 1)
	result_amount = 3

/datum/chemical_reaction/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	result = "diethylamine"
	required_reagents = list ("ammonia" = 1, "ethanol" = 1)
	result_amount = 2

/datum/chemical_reaction/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	result = "cleaner"
	required_reagents = list("ammonia" = 1, "water" = 1)
	result_amount = 2

/datum/chemical_reaction/plantbgone
	name = "Plant-B-Gone"
	id = "plantbgone"
	result = "plantbgone"
	required_reagents = list("toxin" = 1, "water" = 4)
	result_amount = 5


/////////////////////////////////////OLD SLIME CORE REACTIONS ///////////////////////////////
/*
/datum/chemical_reaction/slimepepper
	name = "Slime Condensedcapaicin"
	id = "m_condensedcapaicin"
	result = "condensedcapsaicin"
	required_reagents = list("sugar" = 1)
	result_amount = 1
	required_container = /obj/item/slime_core
	required_other = 1

/datum/chemical_reaction/slimefrost
	name = "Slime Frost Oil"
	id = "m_frostoil"
	result = "frostoil"
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_core
	required_other = 1

/datum/chemical_reaction/slimeglycerol
	name = "Slime Glycerol"
	id = "m_glycerol"
	result = "glycerol"
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_core
	required_other = 1

/datum/chemical_reaction/slime_explosion
	name = "Slime Explosion"
	id = "m_explosion"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 2
	required_container = /obj/item/slime_core
	required_other = 2

/datum/chemical_reaction/slime_explosion/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/reagents_explosion/e = new()
	e.set_up(round (created_volume/10, 1), location, 0, 0)
	e.start()

	holder.clear_reagents()
	return

/datum/chemical_reaction/slimejam
	name = "Slime Jam"
	id = "m_jam"
	result = "slimejelly"
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_core
	required_other = 2

/datum/chemical_reaction/slimesynthi
	name = "Slime Synthetic Flesh"
	id = "m_flesh"
	result = null
	required_reagents = list("sugar" = 1)
	result_amount = 1
	required_container = /obj/item/slime_core
	required_other = 2

/datum/chemical_reaction/slimesynthi/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh(location)
	return

/datum/chemical_reaction/slimeenzyme
	name = "Slime Enzyme"
	id = "m_enzyme"
	result = "enzyme"
	required_reagents = list("blood" = 1, "water" = 1)
	result_amount = 2
	required_container = /obj/item/slime_core
	required_other = 3

/datum/chemical_reaction/slimeplasma
	name = "Slime Plasma"
	id = "m_plasma"
	result = "plasma"
	required_reagents = list("sugar" = 1, "blood" = 2)
	result_amount = 2
	required_container = /obj/item/slime_core
	required_other = 3

/datum/chemical_reaction/slimevirus
	name = "Slime Virus"
	id = "m_virus"
	result = null
	required_reagents = list("sugar" = 1, "sacid" = 1)
	result_amount = 2
	required_container = /obj/item/slime_core
	required_other = 3

/datum/chemical_reaction/slimevirus/on_reaction(datum/reagents/holder, created_volume)
	holder.clear_reagents()

	var/virus = pick(/datum/disease/advance/flu, /datum/disease/advance/cold, \
	 /datum/disease/pierrot_throat, /datum/disease/fake_gbs, \
	 /datum/disease/brainrot, /datum/disease/magnitis)


	var/datum/disease/F = new virus(0)
	var/list/data = list("viruses"= list(F))
	holder.add_reagent("blood", 20, data)

	holder.add_reagent("cyanide", rand(1,10))

	return

/datum/chemical_reaction/slimeteleport
	name = "Slime Teleport"
	id = "m_tele"
	result = null
	required_reagents = list("pacid" = 2, "mutagen" = 2)
	required_catalysts = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_core
	required_other = 4

/datum/chemical_reaction/slimeteleport/on_reaction(datum/reagents/holder, created_volume)
	// Calculate new position (searches through beacons in world)
	var/obj/item/device/radio/beacon/chosen
	var/list/possible = list()
	for(var/obj/item/device/radio/beacon/W in not_world)
		possible += W

	if(possible.len > 0)
		chosen = pick(possible)

	if(chosen)
	// Calculate previous position for transition

		var/turf/FROM = get_turf_loc(holder.my_atom) // the turf of origin we're travelling FROM
		var/turf/TO = get_turf_loc(chosen)			 // the turf of origin we're travelling TO

		playsound(TO, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

		var/list/flashers = list()
		for(var/mob/living/carbon/human/M in viewers(TO, null))
			if(M:eyecheck() <= 0)
				M.flash_eyes()
				flashers += M

		var/y_distance = TO.y - FROM.y
		var/x_distance = TO.x - FROM.x
		for (var/atom/movable/A in range(2, FROM )) // iterate thru list of mobs in the area
			if(istype(A, /obj/item/device/radio/beacon)) continue // don't teleport beacons because that's just insanely stupid
			if( A.anchored && !istype(A, /mob/dead/observer) ) continue // don't teleport anchored things (computers, tables, windows, grilles, etc) because this causes problems!
			// do teleport ghosts however because hell why not

			var/turf/newloc = locate(A.x + x_distance, A.y + y_distance, TO.z) // calculate the new place
			if(!A.Move(newloc)) // if the atom, for some reason, can't move, FORCE them to move! :) We try Move() first to invoke any movement-related checks the atom needs to perform after moving
				A.loc = locate(A.x + x_distance, A.y + y_distance, TO.z)

			spawn()
				if(ismob(A) && !(A in flashers)) // don't flash if we're already doing an effect
					var/mob/M = A
					if(M.client)
						var/obj/blueeffect = new /obj(src)
						blueeffect.screen_loc = "WEST,SOUTH to EAST,NORTH"
						blueeffect.icon = 'icons/effects/effects.dmi'
						blueeffect.icon_state = "shieldsparkles"
						blueeffect.layer = 17
						blueeffect.mouse_opacity = 0
						M.client.screen += blueeffect
						sleep(20)
						M.client.screen -= blueeffect
						qdel(blueeffect)

/datum/chemical_reaction/slimecrit
	name = "Slime Crit"
	id = "m_tele"
	result = null
	required_reagents = list("sacid" = 1, "blood" = 1)
	required_catalysts = list("plasma" = 1)
	result_amount = 1
	required_container = /obj/item/slime_core
	required_other = 4

/datum/chemical_reaction/slimecrit/on_reaction(datum/reagents/holder, created_volume)
	var/blocked = list(/mob/living/simple_animal/hostile,
		/mob/living/simple_animal/hostile/pirate,
		/mob/living/simple_animal/hostile/pirate/ranged,
		/mob/living/simple_animal/hostile/russian,
		/mob/living/simple_animal/hostile/russian/ranged,
		/mob/living/simple_animal/hostile/syndicate,
		/mob/living/simple_animal/hostile/syndicate/melee,
		/mob/living/simple_animal/hostile/syndicate/melee/space,
		/mob/living/simple_animal/hostile/syndicate/ranged,
		/mob/living/simple_animal/hostile/syndicate/ranged/space,
		/mob/living/simple_animal/hostile/xenomorph/queen/large,
		/mob/living/simple_animal/clown
		)//exclusion list for things you don't want the reaction to create.
	var/list/critters = typesof(/mob/living/simple_animal/hostile) - blocked // list of possible hostile mobs

	playsound(holder.my_atom, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(get_turf_loc(holder.my_atom), null))
		if(M:eyecheck() <= 0)
			M.flash_eyes()

	for(var/i = 1, i <= created_volume, i++)
		var/chosen = pick(critters)
		var/mob/living/simple_animal/hostile/C = new chosen
		C.loc = get_turf_loc(holder.my_atom)
		if(prob(50))
			for(var/j = 1, j <= rand(1, 3), j++)
				step(C, pick(NORTH,SOUTH,EAST,WEST))

/datum/chemical_reaction/slimebork
	name = "Slime Bork"
	id = "m_tele"
	result = null
	required_reagents = list("sugar" = 1, "water" = 1)
	result_amount = 2
	required_container = /obj/item/slime_core
	required_other = 4

/datum/chemical_reaction/slimebork/on_reaction(datum/reagents/holder, created_volume)
	var/list/borks = typesof(/obj/item/weapon/reagent_containers/food/snacks) - /obj/item/weapon/reagent_containers/food/snacks
	// BORK BORK BORK

	playsound(holder.my_atom, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(get_turf_loc(holder.my_atom), null))
		if(M:eyecheck() <= 0)
			M.flash_eyes()

	for(var/i = 1, i <= created_volume + rand(1,2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.loc = get_turf_loc(holder.my_atom)
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))



/datum/chemical_reaction/slimechloral
	name = "Slime Chloral"
	id = "m_bunch"
	result = "chloralhydrate"
	required_reagents = list("blood" = 1, "water" = 2)
	result_amount = 2
	required_container = /obj/item/slime_core
	required_other = 5

/datum/chemical_reaction/slimeretro
	name = "Slime Retro"
	id = "m_xeno"
	result = null
	required_reagents = list("sugar" = 1)
	result_amount = 1
	required_container = /obj/item/slime_core
	required_other = 5

/datum/chemical_reaction/slimeretro/on_reaction(datum/reagents/holder, created_volume)
	var/datum/disease/F = new /datum/disease/dna_retrovirus(0)
	var/list/data = list("viruses"= list(F))
	holder.add_reagent("blood", 20, data)

/datum/chemical_reaction/slimefoam
	name = "Slime Foam"
	id = "m_foam"
	result = null
	required_reagents = list("sacid" = 1)
	result_amount = 2
	required_container = /obj/item/slime_core
	required_other = 5

/datum/chemical_reaction/slimefoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/mob/M in viewers(5, location))
		to_chat(M, "<span class='warning'>The solution violently bubbles!</span>")

	location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		to_chat(M, "<span class='warning'>The solution spews out foam!</span>")

	//world << "Holder volume is [holder.total_volume]"
	//for(var/datum/reagent/R in holder.reagent_list)
	//	world << "[R.name] = [R.volume]"

	var/datum/effect/effect/system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 0)
	s.start()
	holder.clear_reagents()
	return
*/
/////////////////////////////////////////////NEW SLIME CORE REACTIONS/////////////////////////////////////////////

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
	holder.my_atom.visible_message("<span class='warning'>Infused with phoron, the core begins to quiver and grow, and soon a new baby slime emerges from it!</span>")
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
		var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/M = new /obj/item/weapon/reagent_containers/food/snacks/monkeycube
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
		/mob/living/simple_animal/hostile/xenomorph/queen/large,
		/mob/living/simple_animal/hostile/faithless,
		/mob/living/simple_animal/hostile/panther,
		/mob/living/simple_animal/hostile/snake,
		/mob/living/simple_animal/hostile/retaliate,
		/mob/living/simple_animal/hostile/retaliate/clown
		)//exclusion list for things you don't want the reaction to create.
	var/list/critters = typesof(/mob/living/simple_animal/hostile) - blocked // list of possible hostile mobs

	playsound(holder.my_atom, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

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
	holder.my_atom.visible_message("<span class='warning'>The slime core fizzles disappointingly,</span>")

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
	for(var/mob/living/carbon/human/M in viewers(usr.loc))
		if(M.eyecheck() <= 0)
			M.flash_eyes()

	spawn_food(get_turf_loc(holder.my_atom), 4 + rand(1,2))

/datum/chemical_reaction/slimebork2
	name = "Slime Bork 2"
	id = "m_tele4"
	result = null
	required_reagents = list("water" = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/silver
	required_other = 1

/datum/chemical_reaction/slimebork2/on_reaction(datum/reagents/holder)
	for(var/mob/living/carbon/human/M in viewers(usr.loc))
		if(M.eyecheck() <= 0)
			M.flash_eyes()

	spawn_food(get_turf_loc(holder.my_atom), 4 + rand(1,2))


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
	holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently !</span>")
	sleep(50)
	playsound(holder.my_atom, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)
	for(var/mob/living/M in range(get_turf_loc(holder.my_atom), 7))
		M.bodytemperature -= 140
		to_chat(M, "<span class='notice'>You feel a chill!</span>")

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
	holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently !</span>")
	sleep(50)
	if(!(holder.my_atom && holder.my_atom.loc))
		return

	var/turf/location = get_turf(holder.my_atom.loc)
	for(var/turf/simulated/floor/target_tile in range(0, location))
		target_tile.assume_gas("phoron", 25, 1400)
		spawn (0)
			target_tile.hotspot_expose(700, 400)
	message_admins("Orange slime extract activated by [key_name_admin(usr)](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) [ADMIN_JMP(usr)]")
	log_game("Orange slime extract activated by [key_name(usr)]")

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
	message_admins("Yellow slime extract activated by [key_name_admin(usr)](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) [ADMIN_JMP(usr)]")
	log_game("Yellow slime extract activated by [key_name(usr)]")

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
	holder.my_atom.visible_message("<span class='warning'>The contents of the slime core harden and begin to emit a warm, bright light.</span>")
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
		holder.my_atom.visible_message("<span class='warning'>The [slime] is driven into a frenzy!.</span>")

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
	holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently !</span>")
	sleep(50)
	explosion(get_turf_loc(holder.my_atom), 1 ,3, 6)
	message_admins("Oil slime extract activated by [key_name_admin(usr)](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) [ADMIN_JMP(usr)]")
	log_game("Oil slime extract activated by [key_name(usr)]")

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
	holder.my_atom.visible_message("<span class='warning'>The bluespace crystal appears out of thin air!</span>")
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
//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

/datum/chemical_reaction/tea
	name = "Tea"
	id = "tea"
	result = "tea"
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/weapon/reagent_containers/glass/beaker/fluff/eleanor_stone

/datum/chemical_reaction/tofu
	name = "Tofu"
	id = "tofu"
	result = null
	required_reagents = list("soymilk" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 1

/datum/chemical_reaction/tofu/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/tofu(location)
	return

/datum/chemical_reaction/chocolate_bar
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	required_reagents = list("soymilk" = 2, "coco" = 2, "sugar" = 2)
	result_amount = 1

/datum/chemical_reaction/chocolate_bar/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)
	return

/datum/chemical_reaction/chocolate_bar2
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	required_reagents = list("milk" = 2, "coco" = 2, "sugar" = 2)
	result_amount = 1

/datum/chemical_reaction/chocolate_bar2/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)
	return

/datum/chemical_reaction/hot_coco
	name = "Hot Coco"
	id = "hot_coco"
	result = "hot_coco"
	required_reagents = list("water" = 5, "coco" = 1)
	result_amount = 5

/datum/chemical_reaction/soysauce
	name = "Soy Sauce"
	id = "soysauce"
	result = "soysauce"
	required_reagents = list("soymilk" = 4, "sacid" = 1)
	result_amount = 5

/datum/chemical_reaction/cheesewheel
	name = "Cheesewheel"
	id = "cheesewheel"
	result = null
	required_reagents = list("milk" = 40)
	required_catalysts = list("enzyme" = 5)
	result_amount = 1

/datum/chemical_reaction/cheesewheel/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel(location)
	return

/datum/chemical_reaction/syntiflesh
	name = "Syntiflesh"
	id = "syntiflesh"
	result = null
	required_reagents = list("blood" = 5, "clonexadone" = 1)
	result_amount = 1

/datum/chemical_reaction/syntiflesh/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh(location)
	return

/datum/chemical_reaction/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	result = "hot_ramen"
	required_reagents = list("water" = 1, "dry_ramen" = 3)
	result_amount = 3

/datum/chemical_reaction/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	result = "hell_ramen"
	required_reagents = list("capsaicin" = 1, "hot_ramen" = 6)
	result_amount = 6

/datum/chemical_reaction/hot_hell_ramen
	name = "Hot Spicy Ramen"
	id = "hot_hell_ramen"
	result = "hot_hell_ramen"
	required_reagents = list("water" = 1, "hell_ramen" = 3)
	result_amount = 3

////////////////////////////////////////// COCKTAILS //////////////////////////////////////


/datum/chemical_reaction/goldschlager
	name = "Goldschlager"
	id = "goldschlager"
	result = "goldschlager"
	required_reagents = list("vodka" = 10, "gold" = 1)
	result_amount = 10

/datum/chemical_reaction/patron
	name = "Patron"
	id = "patron"
	result = "patron"
	required_reagents = list("tequilla" = 10, "silver" = 1)
	result_amount = 10

/datum/chemical_reaction/bilk
	name = "Bilk"
	id = "bilk"
	result = "bilk"
	required_reagents = list("milk" = 1, "beer" = 1)
	result_amount = 2

/datum/chemical_reaction/icetea
	name = "Iced Tea"
	id = "icetea"
	result = "icetea"
	required_reagents = list("ice" = 1, "tea" = 3)
	result_amount = 4

/datum/chemical_reaction/icecoffee
	name = "Iced Coffee"
	id = "icecoffee"
	result = "icecoffee"
	required_reagents = list("ice" = 1, "coffee" = 3)
	result_amount = 4

/datum/chemical_reaction/nuka_cola
	name = "Nuka Cola"
	id = "nuka_cola"
	result = "nuka_cola"
	required_reagents = list("uranium" = 1, "cola" = 6)
	result_amount = 6

/datum/chemical_reaction/moonshine
	name = "Moonshine"
	id = "moonshine"
	result = "moonshine"
	required_reagents = list("nutriment" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

/datum/chemical_reaction/grenadine
	name = "Grenadine Syrup"
	id = "grenadine"
	result = "grenadine"
	required_reagents = list("berryjuice" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

/datum/chemical_reaction/wine
	name = "Wine"
	id = "wine"
	result = "wine"
	required_reagents = list("grapejuice" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

/datum/chemical_reaction/pwine
	name = "Poison Wine"
	id = "pwine"
	result = "pwine"
	required_reagents = list("poisonberryjuice" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

/datum/chemical_reaction/melonliquor
	name = "Melon Liquor"
	id = "melonliquor"
	result = "melonliquor"
	required_reagents = list("watermelonjuice" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

/datum/chemical_reaction/bluecuracao
	name = "Blue Curacao"
	id = "bluecuracao"
	result = "bluecuracao"
	required_reagents = list("orangejuice" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

/datum/chemical_reaction/spacebeer
	name = "Space Beer"
	id = "spacebeer"
	result = "beer"
	required_reagents = list("cornoil" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

/datum/chemical_reaction/vodka
	name = "Vodka"
	id = "vodka"
	result = "vodka"
	required_reagents = list("potato" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10
/datum/chemical_reaction/sake
	name = "Sake"
	id = "sake"
	result = "sake"
	required_reagents = list("rice" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

/datum/chemical_reaction/kahlua
	name = "Kahlua"
	id = "kahlua"
	result = "kahlua"
	required_reagents = list("coffee" = 5, "sugar" = 5)
	required_catalysts = list("enzyme" = 5)
	result_amount = 5

/datum/chemical_reaction/gin_tonic
	name = "Gin and Tonic"
	id = "gintonic"
	result = "gintonic"
	required_reagents = list("gin" = 2, "tonic" = 1)
	result_amount = 3

/datum/chemical_reaction/cuba_libre
	name = "Cuba Libre"
	id = "cubalibre"
	result = "cubalibre"
	required_reagents = list("rum" = 2, "cola" = 1)
	result_amount = 3

/datum/chemical_reaction/martini
	name = "Classic Martini"
	id = "martini"
	result = "martini"
	required_reagents = list("gin" = 2, "vermouth" = 1)
	result_amount = 3

/datum/chemical_reaction/vodkamartini
	name = "Vodka Martini"
	id = "vodkamartini"
	result = "vodkamartini"
	required_reagents = list("vodka" = 2, "vermouth" = 1)
	result_amount = 3

/datum/chemical_reaction/white_russian
	name = "White Russian"
	id = "whiterussian"
	result = "whiterussian"
	required_reagents = list("blackrussian" = 3, "cream" = 2)
	result_amount = 5

/datum/chemical_reaction/whiskey_cola
	name = "Whiskey Cola"
	id = "whiskeycola"
	result = "whiskeycola"
	required_reagents = list("whiskey" = 2, "cola" = 1)
	result_amount = 3

/datum/chemical_reaction/screwdriver
	name = "Screwdriver"
	id = "screwdrivercocktail"
	result = "screwdrivercocktail"
	required_reagents = list("vodka" = 2, "orangejuice" = 1)
	result_amount = 3

/datum/chemical_reaction/bloody_mary
	name = "Bloody Mary"
	id = "bloodymary"
	result = "bloodymary"
	required_reagents = list("vodka" = 1, "tomatojuice" = 2, "limejuice" = 1)
	result_amount = 4

/datum/chemical_reaction/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = "gargleblaster"
	result = "gargleblaster"
	required_reagents = list("vodka" = 1, "gin" = 1, "whiskey" = 1, "cognac" = 1, "limejuice" = 1)
	result_amount = 5

/datum/chemical_reaction/brave_bull
	name = "Brave Bull"
	id = "bravebull"
	result = "bravebull"
	required_reagents = list("tequilla" = 2, "kahlua" = 1)
	result_amount = 3

/datum/chemical_reaction/tequilla_sunrise
	name = "Tequilla Sunrise"
	id = "tequillasunrise"
	result = "tequillasunrise"
	required_reagents = list("tequilla" = 2, "orangejuice" = 1)
	result_amount = 3

/datum/chemical_reaction/phoron_special
	name = "Toxins Special"
	id = "toxins_special"
	result = "toxins_special"
	required_reagents = list("rum" = 2, "vermouth" = 1, "phoron" = 2)
	result_amount = 5

/datum/chemical_reaction/beepsky_smash
	name = "Beepksy Smash"
	id = "beepksysmash"
	result = "beepskysmash"
	required_reagents = list("limejuice" = 2, "whiskey" = 2, "iron" = 1)
	result_amount = 4

/datum/chemical_reaction/doctor_delight
	name = "The Doctor's Delight"
	id = "doctordelight"
	result = "doctorsdelight"
	required_reagents = list("limejuice" = 1, "tomatojuice" = 1, "orangejuice" = 1, "cream" = 1, "tricordrazine" = 1)
	result_amount = 5

/datum/chemical_reaction/irish_cream
	name = "Irish Cream"
	id = "irishcream"
	result = "irishcream"
	required_reagents = list("whiskey" = 2, "cream" = 1)
	result_amount = 3

/datum/chemical_reaction/manly_dorf
	name = "The Manly Dorf"
	id = "manlydorf"
	result = "manlydorf"
	required_reagents = list ("beer" = 1, "ale" = 2)
	result_amount = 3

/datum/chemical_reaction/hooch
	name = "Hooch"
	id = "hooch"
	result = "hooch"
	required_reagents = list ("sugar" = 1, "ethanol" = 2, "fuel" = 1)
	result_amount = 3

/datum/chemical_reaction/irish_coffee
	name = "Irish Coffee"
	id = "irishcoffee"
	result = "irishcoffee"
	required_reagents = list("irishcream" = 1, "coffee" = 1)
	result_amount = 2

/datum/chemical_reaction/b52
	name = "B-52"
	id = "b52"
	result = "b52"
	required_reagents = list("irishcream" = 1, "kahlua" = 1, "cognac" = 1)
	result_amount = 3

/datum/chemical_reaction/atomicbomb
	name = "Atomic Bomb"
	id = "atomicbomb"
	result = "atomicbomb"
	required_reagents = list("b52" = 10, "uranium" = 1)
	result_amount = 10

/datum/chemical_reaction/margarita
	name = "Margarita"
	id = "margarita"
	result = "margarita"
	required_reagents = list("tequilla" = 2, "limejuice" = 1)
	result_amount = 3

/datum/chemical_reaction/longislandicedtea
	name = "Long Island Iced Tea"
	id = "longislandicedtea"
	result = "longislandicedtea"
	required_reagents = list("vodka" = 1, "gin" = 1, "tequilla" = 1, "cubalibre" = 1)
	result_amount = 4

/datum/chemical_reaction/icedtea
	name = "Long Island Iced Tea"
	id = "longislandicedtea"
	result = "longislandicedtea"
	required_reagents = list("vodka" = 1, "gin" = 1, "tequilla" = 1, "cubalibre" = 1)
	result_amount = 4

/datum/chemical_reaction/threemileisland
	name = "Three Mile Island Iced Tea"
	id = "threemileisland"
	result = "threemileisland"
	required_reagents = list("longislandicedtea" = 10, "uranium" = 1)
	result_amount = 10

/datum/chemical_reaction/whiskeysoda
	name = "Whiskey Soda"
	id = "whiskeysoda"
	result = "whiskeysoda"
	required_reagents = list("whiskey" = 2, "sodawater" = 1)
	result_amount = 3

/datum/chemical_reaction/black_russian
	name = "Black Russian"
	id = "blackrussian"
	result = "blackrussian"
	required_reagents = list("vodka" = 3, "kahlua" = 2)
	result_amount = 5

/datum/chemical_reaction/manhattan
	name = "Manhattan"
	id = "manhattan"
	result = "manhattan"
	required_reagents = list("whiskey" = 2, "vermouth" = 1)
	result_amount = 3

/datum/chemical_reaction/manhattan_proj
	name = "Manhattan Project"
	id = "manhattan_proj"
	result = "manhattan_proj"
	required_reagents = list("manhattan" = 10, "uranium" = 1)
	result_amount = 10

/datum/chemical_reaction/vodka_tonic
	name = "Vodka and Tonic"
	id = "vodkatonic"
	result = "vodkatonic"
	required_reagents = list("vodka" = 2, "tonic" = 1)
	result_amount = 3

/datum/chemical_reaction/gin_fizz
	name = "Gin Fizz"
	id = "ginfizz"
	result = "ginfizz"
	required_reagents = list("gin" = 2, "sodawater" = 1, "limejuice" = 1)
	result_amount = 4

/datum/chemical_reaction/bahama_mama
	name = "Bahama mama"
	id = "bahama_mama"
	result = "bahama_mama"
	required_reagents = list("rum" = 2, "orangejuice" = 2, "limejuice" = 1, "ice" = 1)
	result_amount = 6

/datum/chemical_reaction/singulo
	name = "Singulo"
	id = "singulo"
	result = "singulo"
	required_reagents = list("vodka" = 5, "radium" = 1, "wine" = 5)
	result_amount = 10

/datum/chemical_reaction/alliescocktail
	name = "Allies Cocktail"
	id = "alliescocktail"
	result = "alliescocktail"
	required_reagents = list("martini" = 1, "vodka" = 1)
	result_amount = 2

/datum/chemical_reaction/demonsblood
	name = "Demons Blood"
	id = "demonsblood"
	result = "demonsblood"
	required_reagents = list("rum" = 1, "spacemountainwind" = 1, "blood" = 1, "dr_gibb" = 1)
	result_amount = 4

/datum/chemical_reaction/booger
	name = "Booger"
	id = "booger"
	result = "booger"
	required_reagents = list("cream" = 1, "banana" = 1, "rum" = 1, "watermelonjuice" = 1)
	result_amount = 4

/datum/chemical_reaction/antifreeze
	name = "Anti-freeze"
	id = "antifreeze"
	result = "antifreeze"
	required_reagents = list("vodka" = 2, "cream" = 1, "ice" = 1)
	result_amount = 4

/datum/chemical_reaction/barefoot
	name = "Barefoot"
	id = "barefoot"
	result = "barefoot"
	required_reagents = list("berryjuice" = 1, "cream" = 1, "vermouth" = 1)
	result_amount = 3

/datum/chemical_reaction/grapesoda
	name = "Grape Soda"
	id = "grapesoda"
	result = "grapesoda"
	required_reagents = list("grapejuice" = 2, "cola" = 1)
	result_amount = 3



////DRINKS THAT REQUIRED IMPROVED SPRITES BELOW:: -Agouri/////

/datum/chemical_reaction/sbiten
	name = "Sbiten"
	id = "sbiten"
	result = "sbiten"
	required_reagents = list("vodka" = 10, "capsaicin" = 1)
	result_amount = 10

/datum/chemical_reaction/red_mead
	name = "Red Mead"
	id = "red_mead"
	result = "red_mead"
	required_reagents = list("blood" = 1, "mead" = 1)
	result_amount = 2

/datum/chemical_reaction/mead
	name = "Mead"
	id = "mead"
	result = "mead"
	required_reagents = list("sugar" = 1, "water" = 1)
	required_catalysts = list("enzyme" = 5)
	result_amount = 2

/datum/chemical_reaction/iced_beer
	name = "Iced Beer"
	id = "iced_beer"
	result = "iced_beer"
	required_reagents = list("beer" = 10, "frostoil" = 1)
	result_amount = 10

/datum/chemical_reaction/iced_beer2
	name = "Iced Beer"
	id = "iced_beer"
	result = "iced_beer"
	required_reagents = list("beer" = 5, "ice" = 1)
	result_amount = 6

/datum/chemical_reaction/grog
	name = "Grog"
	id = "grog"
	result = "grog"
	required_reagents = list("rum" = 1, "water" = 1)
	result_amount = 2

/datum/chemical_reaction/soy_latte
	name = "Soy Latte"
	id = "soy_latte"
	result = "soy_latte"
	required_reagents = list("coffee" = 1, "soymilk" = 1)
	result_amount = 2

/datum/chemical_reaction/cafe_latte
	name = "Cafe Latte"
	id = "cafe_latte"
	result = "cafe_latte"
	required_reagents = list("coffee" = 1, "milk" = 1)
	result_amount = 2

/datum/chemical_reaction/acidspit
	name = "Acid Spit"
	id = "acidspit"
	result = "acidspit"
	required_reagents = list("sacid" = 1, "wine" = 5)
	result_amount = 6

/datum/chemical_reaction/amasec
	name = "Amasec"
	id = "amasec"
	result = "amasec"
	required_reagents = list("iron" = 1, "wine" = 5, "vodka" = 5)
	result_amount = 10

/datum/chemical_reaction/changelingsting
	name = "Changeling Sting"
	id = "changelingsting"
	result = "changelingsting"
	required_reagents = list("screwdrivercocktail" = 1, "limejuice" = 1, "lemonjuice" = 1)
	result_amount = 5

/datum/chemical_reaction/aloe
	name = "Aloe"
	id = "aloe"
	result = "aloe"
	required_reagents = list("cream" = 1, "whiskey" = 1, "watermelonjuice" = 1)
	result_amount = 2

/datum/chemical_reaction/andalusia
	name = "Andalusia"
	id = "andalusia"
	result = "andalusia"
	required_reagents = list("rum" = 1, "whiskey" = 1, "lemonjuice" = 1)
	result_amount = 3

/datum/chemical_reaction/neurotoxin
	name = "Neurotoxin"
	id = "neurotoxin"
	result = "neurotoxin"
	required_reagents = list("gargleblaster" = 1, "stoxin" = 1)
	result_amount = 2

/datum/chemical_reaction/snowwhite
	name = "Snow White"
	id = "snowwhite"
	result = "snowwhite"
	required_reagents = list("beer" = 1, "lemon_lime" = 1)
	result_amount = 2

/datum/chemical_reaction/irishcarbomb
	name = "Irish Car Bomb"
	id = "irishcarbomb"
	result = "irishcarbomb"
	required_reagents = list("ale" = 1, "irishcream" = 1)
	result_amount = 2

/datum/chemical_reaction/syndicatebomb
	name = "Syndicate Bomb"
	id = "syndicatebomb"
	result = "syndicatebomb"
	required_reagents = list("beer" = 1, "whiskeycola" = 1)
	result_amount = 2

/datum/chemical_reaction/erikasurprise
	name = "Erika Surprise"
	id = "erikasurprise"
	result = "erikasurprise"
	required_reagents = list("ale" = 1, "limejuice" = 1, "whiskey" = 1, "banana" = 1, "ice" = 1)
	result_amount = 5

/datum/chemical_reaction/devilskiss
	name = "Devils Kiss"
	id = "devilskiss"
	result = "devilskiss"
	required_reagents = list("blood" = 1, "kahlua" = 1, "rum" = 1)
	result_amount = 3

/datum/chemical_reaction/hippiesdelight
	name = "Hippies Delight"
	id = "hippiesdelight"
	result = "hippiesdelight"
	required_reagents = list("psilocybin" = 1, "gargleblaster" = 1)
	result_amount = 2

/datum/chemical_reaction/bananahonk
	name = "Banana Honk"
	id = "bananahonk"
	result = "bananahonk"
	required_reagents = list("banana" = 1, "cream" = 1, "sugar" = 1)
	result_amount = 3

/datum/chemical_reaction/silencer
	name = "Silencer"
	id = "silencer"
	result = "silencer"
	required_reagents = list("nothing" = 1, "cream" = 1, "sugar" = 1)
	result_amount = 3

/datum/chemical_reaction/driestmartini
	name = "Driest Martini"
	id = "driestmartini"
	result = "driestmartini"
	required_reagents = list("nothing" = 1, "gin" = 1)
	result_amount = 2

/datum/chemical_reaction/lemonade
	name = "Lemonade"
	id = "lemonade"
	result = "lemonade"
	required_reagents = list("lemonjuice" = 1, "sugar" = 1, "water" = 1)
	result_amount = 3

/datum/chemical_reaction/kiraspecial
	name = "Kira Special"
	id = "kiraspecial"
	result = "kiraspecial"
	required_reagents = list("orangejuice" = 1, "limejuice" = 1, "sodawater" = 1)
	result_amount = 2

/datum/chemical_reaction/brownstar
	name = "Brown Star"
	id = "brownstar"
	result = "brownstar"
	required_reagents = list("orangejuice" = 2, "cola" = 1)
	result_amount = 2

/datum/chemical_reaction/milkshake
	name = "Milkshake"
	id = "milkshake"
	result = "milkshake"
	required_reagents = list("cream" = 1, "ice" = 2, "milk" = 2)
	result_amount = 5

/datum/chemical_reaction/chocolatemilkshake
	name = "Chocolate Milkshake"
	id = "milkshake_chocolate"
	result = "milkshake_chocolate"
	required_reagents = list("milkshake" = 1, "hot_coco" = 1)
	result_amount = 2

/datum/chemical_reaction/strawberrymilkshake
	name = "Strawberry Milkshake"
	id = "milkshake_strawberry"
	result = "milkshake_strawberry"
	required_reagents = list("milkshake" = 1, "berryjuice" = 1)
	result_amount = 2

/datum/chemical_reaction/rewriter
	name = "Rewriter"
	id = "rewriter"
	result = "rewriter"
	required_reagents = list("spacemountainwind" = 1, "coffee" = 1)
	result_amount = 2

/datum/chemical_reaction/suidream
	name = "Sui Dream"
	id = "suidream"
	result = "suidream"
	required_reagents = list("space_up" = 2, "bluecuracao" = 1, "melonliquor" = 1)
	result_amount = 4

/datum/chemical_reaction/bacardi
	name = "Bacardi"
	id = "bacardi"
	result = "bacardi"
	required_reagents = list("rum" = 3, "grenadine" = 1, "limejuice" = 2)
	result_amount = 5

/datum/chemical_reaction/bacardialoha
	name = "Bacardi Aloha"
	id = "bacardialoha"
	result = "bacardialoha"
	required_reagents = list("rum" = 1, "cognac" = 1, "limejuice" = 1, "martini" = 1, "gin" = 1)
	result_amount = 5

/datum/chemical_reaction/bacardilemonade_lime
	name = "Bacardi Lemon Lime"
	id = "bacardilemonade_lime"
	result = "bacardilemonade"
	required_reagents = list("rum" = 2, "lemon_lime" = 2, "ice" = 1)
	result_amount = 5

/datum/chemical_reaction/bacardilemonade_lemon
	name = "Bacardi Lemonade"
	id = "bacardilemonade"
	result = "bacardilemonade"
	required_reagents = list("rum" = 2, "lemonade" = 2, "ice" = 1)
	result_amount = 5

//////////////////////////////////////////////
//////////////New poisons/////////////////////
//////////////////////////////////////////////

/datum/chemical_reaction/alphaamanitin
	name = "Alpha-amanitin"
	id = "alphaamanitin"
	result = "alphaamanitin"
	required_reagents = list("amatoxin" = 1, "toxin" = 1, "mutagen" = 1)
	required_catalysts = list("phoron" = 5)
	result_amount = 1

/datum/chemical_reaction/aflatoxin
	name = "Aflatoxin"
	id = "aflatoxin"
	result = "aflatoxin"
	required_reagents = list("amatoxin" = 1, "mercury" = 3, "ammonia" = 1)
	result_amount = 1

/*
/datum/chemical_reaction/chefspecial
	name = "Chef's Special"
	id = "chefspecial"
	result = "chefspecial"
	required_reagents = list("aflatoxin" = 1, "alphaamanitin" = 1, "enzyme" = 1)
	result_amount = 1
*/

/datum/chemical_reaction/dioxin
	name = "dioxin"
	id = "dioxin"
	result = "dioxin"
	required_reagents = list("silver" = 2, "diethylamine" = 1)
	result_amount = 3

/////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////// Nanobots /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/chemical_reaction/nanobots
	name = "Nanobots"
	id = "nanobots"
	result = "nanobots"
	required_reagents = list("nanites2" = 1, "uranium" = 10, "gold" = 10, "nutriment" = 10, "silicon" = 10)
	result_amount = 1

/datum/chemical_reaction/nanobots2
	name = "Nanobots2"
	id = "nanobots2"
	result = "nanobots"
	required_reagents = list("mednanobots" = 1, "cryoxadone" = 2)
	result_amount = 1

/datum/chemical_reaction/mednanobots
	name = "Medical Nanobots"
	id = "mednanobots"
	result = "mednanobots"
	required_reagents = list("nanobots" = 1, "doctorsdelight" = 5)
	result_amount = 1

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/chemical_reaction/deuterium
	name = "Deuterium"
	result = null
	required_reagents = list("water" = 70, "oxygen" = 30)
	result_amount = 1

/datum/chemical_reaction/deuterium/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	if(istype(T))
		new /obj/item/stack/sheet/mineral/deuterium(T, created_volume)

/datum/chemical_reaction/aqueous_foam
	name = "Aqueous Film Forming Foam"
	id = "aqueous_foam"
	result = "aqueous_foam"
	required_reagents = list("fluorosurfactant" = 1, "silicon" = 1)
	result_amount = 10

/datum/chemical_reaction/hair_dye
	name = "Hair Dye"
	id = "whitehairdye"
	result = "whitehairdye"
	required_reagents = list("lube" = 1, "sodiumchloride" = 1)
	result_amount = 2

/*
TODO: Convert everything to custom hair dye,
      so this will be all gone. ~ Luduk.
*/

/datum/chemical_reaction/hair_dye/red
	name = "Red Hair Dye"
	id = "redhairdye"
	result = "redhairdye"
	required_reagents = list("whitehairdye" = 1, "iron" = 1)
	result_amount = 1 // They don't mix, instead they react.

/datum/chemical_reaction/hair_dye/blue
	name = "Blue Hair Dye"
	id = "bluehairdye"
	result = "bluehairdye"
	required_reagents = list("whitehairdye" = 1, "copper" = 1)
	result_amount = 1

/datum/chemical_reaction/hair_dye/green
	name = "Green Hair Dye"
	id = "greenhairdye"
	result = "greenhairdye"
	required_reagents = list("whitehairdye" = 1, "chlorine" = 1)
	result_amount = 1

/datum/chemical_reaction/hair_dye/black
	name = "Black Hair Dye"
	id = "blackhairdye"
	result = "blackhairdye"
	required_reagents = list("whitehairdye" = 1, "carbon" = 1)
	result_amount = 1

/datum/chemical_reaction/hair_dye/brown
	name = "Brown Hair Dye"
	id = "brownhairdye"
	result = "brownhairdye"
	required_reagents = list("whitehairdye" = 1, "sulfur" = 1)
	result_amount = 1

/datum/chemical_reaction/hair_dye/blond
	name = "Blond Hair Dye"
	id = "blondhairdye"
	result = "blondhairdye"
	required_reagents = list("whitehairdye" = 1, "sugar" = 1)
	result_amount = 1

// Converting dyes to paint. START madness

/datum/chemical_reaction/hair_dye_empowering
	name = "White Dye Empowering"
	id = "whitedyeempower"
	result = "paint_white"
	required_reagents = list("whitehairdye" = 1, "glycerol" = 10)
	result_amount = 1

/datum/chemical_reaction/hair_dye_empowering/red
	name = "Red Dye Empowering"
	id = "reddyeempower"
	result = "paint_red"
	required_reagents = list("redhairdye" = 1, "glycerol" = 10)
	result_amount = 1

/datum/chemical_reaction/hair_dye_empowering/blue
	name = "Blue Dye Empowering"
	id = "bluedyeempower"
	result = "paint_blue"
	required_reagents = list("bluehairdye" = 1, "glycerol" = 10)
	result_amount = 1

/datum/chemical_reaction/hair_dye_empowering/green
	name = "Green Dye Empowering"
	id = "greendyeempower"
	result = "paint_green"
	required_reagents = list("greenhairdye" = 1, "glycerol" = 10)
	result_amount = 1

/datum/chemical_reaction/hair_dye_empowering/black
	name = "Black Dye Empowering"
	id = "blackdyeempower"
	result = "paint_black"
	required_reagents = list("blackhairdye" = 1, "glycerol" = 10)
	result_amount = 1

/datum/chemical_reaction/hair_dye_empowering/brown
	name = "Brown Dye Empowering"
	id = "browndyeempower"
	result = "paint_brown"
	required_reagents = list("brownhairdye" = 1, "glycerol" = 10)
	result_amount = 1

/datum/chemical_reaction/hair_dye_empowering/blond
	name = "Blond Dye Empowering"
	id = "blonddyeempower"
	result = "paint_blond"
	required_reagents = list("blondhairdye" = 1, "glycerol" = 10)
	result_amount = 1

// END madness.

/datum/chemical_reaction/unholywater
	name = "Unholy Water"
	id = "unholywater"
	result = "unholywater"
	required_reagents = list("water" = 1, "ectoplasm" = 1)
	result_amount = 1 // Because rules of logic shouldn't apply here either.

/datum/chemical_reaction/hair_growth_accelerator
	name = "Hair Growth Accelerator"
	id = "hair_growth_accelerator"
	result = "hair_growth_accelerator"
	required_reagents = list("ryetalyn" = 1, "anti_toxin" = 1, "sugar" = 1)
	result_amount = 3

/datum/chemical_reaction/paint_empowering
	name = "Empowering Paint"
	id = "paint_empowering"
	result = null
	required_reagents = list("customhairdye" = -1) // This is indeed very cheesy, but prevents from removing the paint.
	result_amount = 1

/datum/chemical_reaction/paint_empowering/check_requirements(datum/reagents/holder)
	return holder.get_reagent_amount("glycerol") > 0

/datum/chemical_reaction/paint_empowering/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/chd
	var/datum/reagent/gly
	for(var/datum/reagent/R in holder.reagent_list)
		if(R.id == "customhairdye")
			chd = R
		else if(R.id == "glycerol")
			gly = R
	var/modifier = min(chd.volume, gly.volume)
	var/new_color_weight = chd.color_weight + modifier
	if(new_color_weight >= 20)
		holder.add_reagent("paint_custom", chd.volume, chd.data)
		holder.remove_reagent("customhairdye", chd.volume)
	else
		chd.color_weight = new_color_weight
	holder.remove_reagent("glycerol", modifier)

/datum/chemical_reaction/paint_depowering
	name = "Depowering Paint"
	id = "paint_depowering"
	result = null
	required_reagents = list("customhairdye" = -1) // This is indeed very cheesy, but prevents from removing the paint.
	result_amount = 1

/datum/chemical_reaction/paint_depowering/check_requirements(datum/reagents/holder)
	var/datum/reagent/R = holder.get_reagent(/datum/reagent/paint/hair_dye/custom)
	return (R.color_weight > 10) && (holder.get_reagent_amount("water") > 0)

/datum/chemical_reaction/paint_depowering/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/chd
	var/datum/reagent/wat
	for(var/datum/reagent/R in holder.reagent_list)
		if(R.id == "customhairdye")
			chd = R
		else if(R.id == "water")
			wat = R
	var/modifier = min(chd.volume, wat.volume)
	var/new_color_weight = chd.color_weight + modifier
	if(new_color_weight >= 10)
		chd.color_weight = new_color_weight
		holder.remove_reagent("water", modifier)
