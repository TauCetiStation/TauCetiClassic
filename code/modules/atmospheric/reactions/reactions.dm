#define HVAL 999999 //infinity is kind of overkill anyway

/datum/atmosReaction/n2oSynthesis
    id = "n2osynth"
    minTemp = 373.15
    maxTemp = 773.15
    minPressure = 100
    maxPressure = HVAL
    producedHeat = -4
    consumed = list("nitrogen" = 2, "oxygen" = 1)
    created = list("sleeping_agent" = 3)
    catalysts = list()
    inhibitors = list("const" = 10)

/datum/atmosReaction/n2oSynthesisPhydr
    id = "n2osynthphydr"
    minTemp = 273.15
    maxTemp = 773.15
    minPressure = 50
    maxPressure = HVAL
    producedHeat = -4
    consumed = list("nitrogen" = 2, "oxygen" = 1)
    created = list("sleeping_agent" = 3)
    catalysts = list("phydr" = 5)
    inhibitors = list("const" = 10)

/datum/atmosReaction/n2oDecomposition
    id = "n2odec"
    minTemp = 773.15
    maxTemp = HVAL
    minPressure = -HVAL
    maxPressure = HVAL
    producedHeat = 4
    consumed = list("sleeping_agent" = 3)
    created = list("nitrogen" = 2, "oxygen" = 1)
    catalysts = list()
    inhibitors = list("phydr" = 10)

/datum/atmosReaction/bzSynthesis
    id = "bzsynt"
    minTemp = 373.15
    maxTemp = 573.15
    minPressure = 100
    maxPressure = HVAL
    producedHeat = -2
    consumed = list("sleeping_agent" = 2, "phoron" = 1)
    created = list("bz" = 3)
    catalysts = list()
    inhibitors = list("const" = 10)

/datum/atmosReaction/bzDecomposition
    id = "bzdec"
    minTemp = 573.15
    maxTemp = HVAL
    minPressure = 0
    maxPressure = HVAL
    producedHeat = 2
    consumed = list("bz" = 3)
    created = list("sleeping_agent" = 2, "phoron" = 1)
    catalysts = list()
    inhibitors = list("phydr" = 10)

/datum/atmosReaction/constSynthesis
    id = "constsynth"
    minTemp = 773.15
    maxTemp = HVAL
    minPressure = 2000
    maxPressure = HVAL
    producedHeat = 1
    consumed = list("carbon_dioxide" = 3, "tritium" = 1)
    created = list("const" = 4)
    catalysts = list()
    inhibitors = list("const" = 30, "oxygen" = 1, "nitrogen" = 1, "hydrogen" = 1, "phoron" = 1, "sleeping_agent" = 1, "phydr" = 1, "triox" = 1, "bz" = 1)

/datum/atmosReaction/trioxSynthesis
    id = "trioxsynth"
    minTemp = -HVAL
    maxTemp = 273.15
    minPressure = 4000
    maxPressure = HVAL
    producedHeat = 4
    consumed = list("oxygen" = 3)
    created = list("triox" = 3)
    catalysts = list("bz" = 5)
    inhibitors = list("const" = 10)

/datum/atmosReaction/trioxDecomposition
    id = "trioxdec"
    minTemp = 573.15
    maxTemp = HVAL
    minPressure = 0
    maxPressure = HVAL
    producedHeat = -4
    consumed = list("triox" = 3)
    created = list("ox" = 3)
    catalysts = list()
    inhibitors = list("phydr" = 10)

/datum/atmosReaction/phydrSynthesis
    id = "phydrsynt"
    minTemp = 573.15
    maxTemp = HVAL
    minPressure = 2000
    maxPressure = HVAL
    producedHeat = -4
    consumed = list("hydrogen" = 2, "triox" = 1)
    created = list("phydr" = 3)
    catalysts = list()
    inhibitors = list("const" = 1)

/datum/atmosReaction/phydrDecomposition
    id = "phydrdec"
    minTemp = -HVAL
    maxTemp = 273.15
    minPressure = 0
    maxPressure = HVAL
    producedHeat = 4
    consumed = list("phydr" = 3)
    created = list("hydrogen" = 2, "triox" = 1)
    catalysts = list()
    inhibitors = list("phydr" = 30)

/datum/atmosReaction/phydrDecompositionConst
    id = "phydrdecconst"
    minTemp = -HVAL
    maxTemp = HVAL
    minPressure = -HVAL
    maxPressure = HVAL
    producedHeat = 4
    consumed = list("phydr" = 1)
    created = list("hydrogen" = 2, "triox" = 1)
    catalysts = list("const" = 1)
    inhibitors = list()

/datum/atmosReaction/ctirinSynthesis
    id = "ctirinsynth"
    minTemp = 373.15
    maxTemp = HVAL
    minPressure = 6000
    maxPressure = HVAL
    producedHeat = 4
    consumed = list("triox" = 3, "helium" = 1)
    created = list("ctirin" = 1, "oxygen" = 3)
    catalysts = list()
    inhibitors = list("const" = 10)

/datum/atmosReaction/ctirinSynthesisBZ
    id = "ctirinsynthbz"
    minTemp = 373.15
    maxTemp = HVAL
    minPressure = 4000
    maxPressure = HVAL
    producedHeat = -1
    consumed = list("triox" = 1, "helium" = 1)
    created = list("ctirin" = 2)
    catalysts = list("bz" = 5)
    inhibitors = list("const" = 10)

/datum/atmosReaction/ctirinDecomposition
    id = "ctirindec"
    minTemp = 773.15
    maxTemp = HVAL
    minPressure = 0
    maxPressure = HVAL
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
    minTemp = round(rand(0, 100) / 100) * 100
    maxTemp = round(rand(100, 1000) / 100) * 100
    minPressure = round(rand(0, 100) / 100) * 100
    maxPressure = round(rand(100, 1000) / 100) * 100
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

/datum/atmosReaction/solidPhydrSynthesis
    id = "sphydrsynth"
    minTemp = 3273.15
    maxTemp = HVAL
    minPressure = 8000
    maxPressure = HVAL
    producedHeat = -10
    consumed = list("phydr" = 100)
    inhibitors = list("const" = 1)

/datum/atmosReaction/solidPhydrSynthesis/postReact(datum/gas_mixture/G, turf/T = null)
    if(!T) //can't add solid proto hydrate if we don't know location of the reaction
        G.gas["phydr"] += 100
        return
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

#undef HVAL
