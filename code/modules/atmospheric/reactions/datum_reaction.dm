/datum/atmosReaction
    var/id = ""
    var/minTemp = 0 //kelvins
    var/maxTemp = 0 //kelvins
    var/minPressure = 0 //kpa
    var/maxPressure = 0 //kpa
    var/producedHeat = 0 //joules
    var/list/consumed = list()
    var/list/created = list()
    var/list/catalysts = list()
    var/list/inhibitors = list()

/datum/atmosReaction/proc/canReact(datum/gas_mixture/G)
    var/count = 0
    var/list/toRemove[0]
    if(!consumed.len)
        return
    for(var/gas in G.gas)
        if(consumed[gas] <= G.gas[gas])
            count ++
            toRemove[gas] = consumed[gas]
        else if(catalysts.len)
            if(catalysts[gas] <= G.gas[gas])
                count ++
        else if(inhibitors.len)
            if(inhibitors[gas] <= G.gas[gas])
                count = 0

    if(count == consumed.len + catalysts.len)
        if((G.return_pressure() > minPressure && G.return_pressure() < maxPressure) && (G.temperature > minTemp && G.temperature < maxTemp))
            return toRemove
    return FALSE

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
