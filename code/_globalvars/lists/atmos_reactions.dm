var/global/list/atmosReactionList = list()
var/global/list/possibleReactionTurfs = list( //associative list (with priority being a key) containing turfs which *may* be viable for reactions
"1" = list(), 
"2" = list(),
"3" = list())
var/global/list/recentReactions = list() //reactions put themselves here after they were completed
