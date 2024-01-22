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
var/global/list/mime_names = file2list("config/names/mime.txt")
var/global/list/pirate_first = file2list("config/names/piratefirst.txt")
var/global/list/pirate_second = file2list("config/names/piratesecond.txt")

// Traitors key-words
var/global/list/rus_nouns
var/global/list/rus_adjectives
var/global/list/rus_verbs
var/global/list/rus_occupations
var/global/list/rus_bays
var/global/list/rus_local_terms

//loaded on startup because of "
//would include in rsc if ' was used

var/global/list/forbidden_names = list("space","floor","wall","r-wall","monkey","unknown","inactive ai","plating","unknown","arrivals alert system")
