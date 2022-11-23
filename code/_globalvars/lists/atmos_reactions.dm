//assoc. list containing atmosReaction instances of all types, with their id being the key
var/global/list/atmosReactionList[0]

//list with gas mixtures, which are (possibly) suitable for reactions.
//index is priority, with 1 being the lowest, and 3 being the highest one
var/global/list/possibleReactionMixes = list(list(), list(), list())

//list containing all recent reactions, with reference to parent mixture
var/global/list/recentReactions = list()
