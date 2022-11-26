/datum/atmosReaction
    var/id = ""
    var/rarestGas = "" //to reduce amount of react() calls
    var/minTemp = 0 //kelvins
    var/maxTemp = 0 //kelvins
    var/minPressure = 0 //kilo pascals
    var/maxPressure = 0 //kilo pascals
    var/producedHeat = 0 //joules
    var/list/consumed[0]
    var/list/created[0]
    var/list/catalysts[0]
    var/list/inhibitors[0]

/datum/atmosReaction/proc/canReact(datum/gas_mixture/G)
    var/count = 0
    var/list/toRemove[0]

    if(!(G.temperature > minTemp && G.temperature < maxTemp))
        return FALSE

    var/P = G.return_pressure()
    if(!(P > minPressure && P < maxPressure))
        return FALSE

    if(catalysts.len)
        for(var/gas in catalysts)
            if(catalysts[gas] <= G.gas[gas])
                count ++
    if(count != catalysts.len)
        return FALSE

    if(inhibitors.len)
        for(var/gas in inhibitors)
            if(inhibitors[gas] <= G.gas[gas])
                return FALSE

    for(var/gas in consumed)
        if(consumed[gas] <= G.gas[gas])
            count ++
            toRemove[gas] = consumed[gas]
    if(count != consumed.len)
        return FALSE

    return toRemove

/datum/atmosReaction/proc/preReact(datum/gas_mixture/G)
    return TRUE //insert your own code here

/datum/atmosReaction/proc/react(datum/gas_mixture/G)
    var/R = canReact(G)
    if(R)
        if(preReact(G))
            for(var/gas in R)
                G.gas[gas] = G.gas[gas] - R[gas]
            for(var/gas in created)
                if(G.gas[gas])
                    G.gas[gas] = G.gas[gas] + created[gas]
                else
                    G.gas[gas] = created[gas]
            G.add_thermal_energy(producedHeat)
            postReact(G)
            return TRUE
    return FALSE

/datum/atmosReaction/proc/postReact(datum/gas_mixture/G)
    return //insert your own code here

/datum/atmosReaction/proc/rarestGas()
    var/rarest = ""
    var/maxRarity = 0
    var/list/combined = consumed + catalysts
    for(var/gas in combined)
        var/rarity = gas_data.gases_initial_rnd_points[gas]
        if(!gas_data.gases_knowable[gas] || gas_data.gases_dangerous[gas])
            if(!rarity)
                rarity = 200
            else
                rarity = rarity * 2
        if(rarity > maxRarity)
            maxRarity = rarity
            rarest = gas
    return rarest

/datum/atmosReaction/New()
    ..()
    rarestGas = rarestGas()
