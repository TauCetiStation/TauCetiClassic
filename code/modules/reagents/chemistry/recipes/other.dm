/datum/chemical_reaction/water //I can't believe we never had this.
			name = "Water"
			id = "water"
			result = "water"
			required_reagents = list("oxygen" = 1, "hydrogen" = 2)
			result_amount = 1

/datum/chemical_reaction/thermite
			name = "Thermite"
			id = "thermite"
			result = "thermite"
			required_reagents = list("aluminum" = 1, "iron" = 1, "oxygen" = 1)
			result_amount = 3

/datum/chemical_reaction/lube
			name = "Space Lube"
			id = "lube"
			result = "lube"
			required_reagents = list("water" = 1, "silicon" = 1, "oxygen" = 1)
			result_amount = 4

/datum/chemical_reaction/virus_food
			name = "Virus Food"
			id = "virusfood"
			result = "virusfood"
			required_reagents = list("water" = 1, "milk" = 1)
			result_amount = 5

/datum/chemical_reaction/glycerol
			name = "Glycerol"
			id = "glycerol"
			result = "glycerol"
			required_reagents = list("cornoil" = 3, "sacid" = 1)
			result_amount = 1

/datum/chemical_reaction/sodiumchloride
			name = "Sodium Chloride"
			id = "sodiumchloride"
			result = "sodiumchloride"
			required_reagents = list("sodium" = 1, "chlorine" = 1)
			result_amount = 2

/datum/chemical_reaction/potassium_chloride
			name = "Potassium Chloride"
			id = "potassium_chloride"
			result = "potassium_chloride"
			required_reagents = list("sodiumchloride" = 1, "potassium" = 1)
			result_amount = 2

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
		to_chat(M, "\red The solution violently bubbles!")

	location = get_turf(holder.my_atom)

	for(var/mob/M in viewers(5, location))
		to_chat(M, "\red The solution spews out foam!")

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
		to_chat(M, "\red The solution spews out a metalic foam!")

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
		to_chat(M, "\red The solution spews out a metalic foam!")

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

/datum/chemical_reaction/deuterium
	name = "Deuterium"
	result = null
	required_reagents = list("water" = 70, "oxygen" = 30)
	result_amount = 1

/datum/chemical_reaction/deuterium/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	if(istype(T))
		new /obj/item/stack/sheet/mineral/deuterium(T, created_volume)
