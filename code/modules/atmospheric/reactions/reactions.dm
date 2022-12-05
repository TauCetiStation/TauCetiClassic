/datum/atmosReaction/n2oSynthesis
	id = "n2osynth"
	minTemp = 773.15
	maxTemp = 1773.15
	minPressure = 1000
	maxPressure = INFINITY
	producedHeat = -4
	consumed = list("nitrogen" = 2, "oxygen" = 1)
	created = list("sleeping_agent" = 3)
	catalysts = list()
	inhibitors = list("const" = 10)

/datum/atmosReaction/n2oSynthesisPhydr
	id = "n2osynthphydr"
	minTemp = 773.15
	maxTemp = 1773.15
	minPressure = 500
	maxPressure = INFINITY
	producedHeat = -4
	consumed = list("nitrogen" = 2, "oxygen" = 1)
	created = list("sleeping_agent" = 3)
	catalysts = list("phydr" = 5)
	inhibitors = list("const" = 10)

/datum/atmosReaction/n2oDecomposition
	id = "n2odec"
	minTemp = 1773.15
	maxTemp = INFINITY
	minPressure = -INFINITY
	maxPressure = INFINITY
	producedHeat = 4
	consumed = list("sleeping_agent" = 3)
	created = list("nitrogen" = 2, "oxygen" = 1)
	catalysts = list()
	inhibitors = list("phydr" = 10)

/datum/atmosReaction/bzSynthesis
	id = "bzsynth"
	minTemp = 373.15
	maxTemp = 573.15
	minPressure = 500
	maxPressure = INFINITY
	producedHeat = -2
	consumed = list("sleeping_agent" = 2, "phoron" = 1)
	created = list("bz" = 3)
	catalysts = list()
	inhibitors = list("const" = 10)

/datum/atmosReaction/bzDecomposition
	id = "bzdec"
	minTemp = 573.15
	maxTemp = INFINITY
	minPressure = 0
	maxPressure = INFINITY
	producedHeat = 2
	consumed = list("bz" = 3)
	created = list("sleeping_agent" = 2, "phoron" = 1)
	catalysts = list()
	inhibitors = list("phydr" = 10)

/datum/atmosReaction/constSynthesis
	id = "constsynth"
	minTemp = 773.15
	maxTemp = INFINITY
	minPressure = 2000
	maxPressure = INFINITY
	producedHeat = 1
	consumed = list("carbon_dioxide" = 3, "tritium" = 1)
	created = list("const" = 4)
	catalysts = list()
	inhibitors = list("const" = 30, "oxygen" = 1, "nitrogen" = 1, "hydrogen" = 1, "phoron" = 1, "sleeping_agent" = 1, "phydr" = 1, "triox" = 1, "bz" = 1)

/datum/atmosReaction/trioxSynthesis
	id = "trioxsynth"
	minTemp = -INFINITY
	maxTemp = 273.15
	minPressure = 4000
	maxPressure = INFINITY
	producedHeat = 4
	consumed = list("oxygen" = 3)
	created = list("triox" = 3)
	catalysts = list("bz" = 5)
	inhibitors = list("const" = 10)

/datum/atmosReaction/trioxDecomposition
	id = "trioxdec"
	minTemp = 573.15
	maxTemp = INFINITY
	minPressure = 0
	maxPressure = INFINITY
	producedHeat = -4
	consumed = list("triox" = 3)
	created = list("ox" = 3)
	catalysts = list()
	inhibitors = list("phydr" = 10)

/datum/atmosReaction/phydrSynthesis
	id = "phydrsynth"
	minTemp = 573.15
	maxTemp = INFINITY
	minPressure = 2000
	maxPressure = INFINITY
	producedHeat = -4
	consumed = list("hydrogen" = 2, "triox" = 1)
	created = list("phydr" = 3)
	catalysts = list()
	inhibitors = list("const" = 1)

/datum/atmosReaction/phydrDecomposition
	id = "phydrdec"
	minTemp = -INFINITY
	maxTemp = 273.15
	minPressure = 0
	maxPressure = INFINITY
	producedHeat = 4
	consumed = list("phydr" = 3)
	created = list("hydrogen" = 2, "triox" = 1)
	catalysts = list()
	inhibitors = list("phydr" = 30)

/datum/atmosReaction/phydrDecompositionConst
	id = "phydrdecconst"
	minTemp = -INFINITY
	maxTemp = INFINITY
	minPressure = -INFINITY
	maxPressure = INFINITY
	producedHeat = 4
	consumed = list("phydr" = 1)
	created = list("hydrogen" = 2, "triox" = 1)
	catalysts = list("const" = 1)
	inhibitors = list()

/datum/atmosReaction/ctirinSynthesis
	id = "ctirinsynth"
	minTemp = 373.15
	maxTemp = INFINITY
	minPressure = 6000
	maxPressure = INFINITY
	producedHeat = 4
	consumed = list("triox" = 3, "helium" = 1)
	created = list("ctirin" = 1, "oxygen" = 3)
	catalysts = list()
	inhibitors = list("const" = 10)

/datum/atmosReaction/ctirinSynthesisBZ
	id = "ctirinsynthbz"
	minTemp = 373.15
	maxTemp = INFINITY
	minPressure = 4000
	maxPressure = INFINITY
	producedHeat = -1
	consumed = list("triox" = 1, "helium" = 1)
	created = list("ctirin" = 2)
	catalysts = list("bz" = 5)
	inhibitors = list("const" = 10)

/datum/atmosReaction/ctirinDecomposition
	id = "ctirindec"
	minTemp = 773.15
	maxTemp = INFINITY
	minPressure = 0
	maxPressure = INFINITY
	producedHeat = 1
	consumed = list("ctirin" = 3)
	created = list("triox" = 2, "helium" = 1)
	catalysts = list()
	inhibitors = list("phydr" = 10)

/datum/atmosReaction/mstabSynthesis
	id = "mstabsynth"
	producedHeat = -2
	created = list("mstab" = 3)

/datum/atmosReaction/mstabSynthesis/New()
	minTemp = CEIL(rand(0, 100) / 100) * 100
	maxTemp = CEIL(rand(100, 1000) / 100) * 100
	minPressure = CEIL(rand(0, 100) / 100) * 100
	maxPressure = CEIL(rand(100, 1000) / 100) * 100
	var/list/used = list()
	for(var/i = 0, i < 3, i++)
		while(TRUE)
			if(used.len == gas_data.gases.len)
				break
			var/N = pick(gas_data.gases)
			if(!used.Find(N))
				consumed[N] = 1
				used.Add(N)
				break
	while(TRUE)
		if(used.len == gas_data.gases.len)
			break
		var/N = pick(gas_data.gases)
		if(!used.Find(N))
			catalysts[N] = 5
			break

	..() //parent is called after filling consumed gases and catalysts, to generate rarest gas, otherwise it will be null

/datum/atmosReaction/solidPhydrSynthesis
	id = "sphydrsynth"
	minTemp = 3273.15
	maxTemp = INFINITY
	minPressure = 8000
	maxPressure = INFINITY
	producedHeat = -10
	consumed = list("phydr" = 100)
	inhibitors = list("const" = 1)

/datum/atmosReaction/solidPhydrSynthesis/postReact(datum/gas_mixture/G)
	var/zone/Z = SSair.look_for_zone(G)
	if(!Z)
		G.gas["phydr"] += 100
		return
	var/turf/simulated/T
	var/failsafe = 0 //to avoid endless loop if our zone somehow only contains dense tiles
	while(TRUE)
		failsafe++
		T = pick(Z.contents)
		if(!T.density || failsafe > 100)
			break
	new /obj/item/weapon/solid_phydr(T)

/obj/item/weapon/solid_phydr
	name = "Solid proto-hydrate"
	desc = "Big chunk of exotic substance created from proto-hydrate under huge pressure and temperature. Highly explosive."
	icon = 'icons/obj/atmos.dmi'
	icon_state = "solid_phydr-na"
	origin_tech = "materials=4;phorontech=1"
	w_class = SIZE_NORMAL
	var/reactionTimer = null

/obj/item/weapon/solid_phydr/update_icon()
	icon_state = "solid_phydr" + (reactionTimer ? "-a" : "-na")

/obj/item/weapon/solid_phydr/attack_self(mob/user)
	if(reactionTimer)
		return
	to_chat(user, "<span class='notice'>You apply force to [src], triggering chain reaction inside it!</span>")
	trigger()

/obj/item/weapon/solid_phydr/attackby(obj/item/weapon/W, mob/user)
	if(reactionTimer)
		return
	if(W.get_current_temperature() > 300)
		to_chat(user, "<span class='notice'>You heat [src], triggering chain reaction inside it!</span>")
		trigger()

/obj/item/weapon/solid_phydr/proc/trigger()
	reactionTimer = addtimer(CALLBACK(src, .proc/react), rand(50, 100), TIMER_STOPPABLE)
	update_icon()

/obj/item/weapon/solid_phydr/proc/react()
	explosion(loc, 2, 4, 6, 8)
	qdel(src)

