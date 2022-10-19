#define HVAL 999999 //infinity is kind of overkill anyway

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
    inhibitors = list("const" = 20, "oxygen" = 1, "nitrogen" = 1, "hydrogen" = 1, "phoron" = 1, "sleeping_agent" = 1, "phydr" = 1, "triox" = 1, "bz" = 1)

/datum/atmosReaction/trioxSynthesis
    id = "trioxsynth"
    minTemp = 0
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
    inhibitors = list()

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

#undef HVAL
