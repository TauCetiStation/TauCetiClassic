var/global/list/ai_names = file2list("config/names/ai.txt")
var/global/list/wizard_first = file2list("config/names/wizardfirst.txt")
var/global/list/wizard_second = file2list("config/names/wizardsecond.txt")
var/global/list/ninja_titles = file2list("config/names/ninjatitle.txt")
var/global/list/ninja_names = file2list("config/names/ninjaname.txt")
var/global/list/commando_names = file2list("config/names/death_commando.txt")
var/global/list/first_names_male = file2list("config/names/first_male.txt")
var/global/list/first_names_female = file2list("config/names/first_female.txt")
var/global/list/last_names = file2list("config/names/last.txt")
var/global/list/clown_names = file2list("config/names/clown.txt")

// Traitors key-words
var/global/list/rus_nouns = file2list("config/names/rus_nouns.txt")
var/global/list/rus_adjectives = file2list("config/names/rus_adjectives.txt")
var/global/list/rus_verbs = file2list("config/names/rus_verbs.txt")
var/global/list/rus_occupations = file2list("config/names/rus_occupations.txt")
var/global/list/rus_bays = file2list("config/names/rus_bays.txt")
var/global/list/rus_local_terms = file2list("config/names/rus_local_terms.txt")

//loaded on startup because of "
//would include in rsc if ' was used

var/global/list/forbidden_names = list("space","floor","wall","r-wall","monkey","unknown","inactive ai","plating","unknown","arrivals alert system")