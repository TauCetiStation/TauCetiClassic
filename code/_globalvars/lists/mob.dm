//Languages/species/whitelist.
var/global/list/all_species[0]
var/global/list/all_languages[0]
var/global/list/language_keys[0]					//table of say codes for all languages
var/global/list/whitelisted_species = list(HUMAN)
var/global/list/sprite_sheet_restricted = list()

var/list/clients = list()							//list of all clients
var/list/admins = list()							//list of all clients whom are admins
var/list/directory = list()							//list of all ckeys with associated client

//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

var/global/list/player_list = list()			//List of all mobs **with clients attached**.
var/global/list/alive_mob_list = list()			//List of all alive mobs, including clientless. Excludes /mob/dead/new_player
var/global/list/dead_mob_list = list()			//List of all dead mobs, including clientless. Excludes /mob/dead/new_player
var/global/list/joined_player_list = list()		//List of all clients that have joined the game at round-start or as a latejoin.

var/global/list/mob_list = list()				//List of all mobs, including clientless
var/global/list/new_player_list = list()
var/global/list/observer_list = list()
var/global/list/living_list = list()
var/global/list/carbon_list = list()
var/global/list/alien_list = list()
var/global/list/queen_list = list()
var/global/list/human_list = list()
var/global/list/monkey_list = list()
var/global/list/silicon_list = list()
var/global/list/ai_list = list()
var/global/list/ai_eyes_list = list()
var/global/list/drone_list = list()

var/global/list/gods_list = list()

var/global/list/med_hud_users = list() //list of all entities using a medical HUD.
var/global/list/sec_hud_users = list() //list of all entities using a security HUD.

//feel free to add shit to lists below
var/list/tachycardics = list("coffee", "inaprovaline", "hyperzine", "nitroglycerin", "thirteenloko", "nicotine")	//increase heart rate
var/list/bradycardics = list("neurotoxin", "cryoxadone", "clonexadone", "space_drugs", "stoxin")					//decrease heart rate
var/list/heartstopper = list("potassium_phorochloride", "zombie_powder") //this stops the heart
var/list/cheartstopper = list("potassium_chloride") //this stops the heart when overdose is met -- c = conditional
