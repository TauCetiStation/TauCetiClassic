/datum/atmosReaction
    var/id = ""
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
    if(!consumed.len || !created.len)
        return
    for(var/gas in consumed)
        if(consumed[gas] <= G.gas[gas])
            count ++
            toRemove[gas] = consumed[gas]
    if(catalysts.len)
        for(var/gas in catalysts)
            if(catalysts[gas] <= G.gas[gas])
                count ++
    if(inhibitors.len)
        for(var/gas in inhibitors)
            if(inhibitors[gas] <= G.gas[gas])
                count = 0

    if(count == consumed.len + catalysts.len)
        if((G.return_pressure() > minPressure && G.return_pressure() < maxPressure) && (G.temperature > minTemp && G.temperature < maxTemp))
            return toRemove
    return FALSE

/datum/atmosReaction/proc/preReact(datum/gas_mixture/G, turf/T = null)
    return TRUE //insert your own code here

/datum/atmosReaction/proc/react(datum/gas_mixture/G, turf/T = null)
    var/R = canReact(G)
    if(R)
        if(preReact(G, T))
            for(var/gas in R)
                G.gas[gas] = G.gas[gas] - R[gas]
            for(var/gas in created)
                if(G.gas[gas])
                    G.gas[gas] = G.gas[gas] + created[gas]
                else
                    G.gas[gas] = created[gas]
            G.add_thermal_energy(producedHeat)
            postReact(G, T)
            return TRUE
    return FALSE

/datum/atmosReaction/proc/postReact(datum/gas_mixture/G, turf/T = null)
    return //insert your own code here
