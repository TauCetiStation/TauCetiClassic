//assoc. list containing atmosReaction instances of all types, with their id being the key
var/global/list/atmosReactionList

//assoc. list containing atmosReaction instances, in which key is the rarest gas
var/global/list/atmosReactionListRarest

//list with gas mixtures, which are (possibly) suitable for reactions.
//index is priority, with 1 being the lowest, and 3 being the highest one
var/global/list/list/possibleReactionMixes = list(list(), list(), list())
