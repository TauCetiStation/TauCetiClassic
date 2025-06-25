//Preferences stuff
	//Hairstyles
var/global/list/hair_styles_list = list()			//stores /datum/sprite_accessory/hair indexed by name
var/global/list/facial_hair_styles_list = list()	//stores /datum/sprite_accessory/facial_hair indexed by name
	//Hairstyles Cache
var/global/list/hairs_cache = list()        // Circular doubly linked list indexed by name and hash. see global_lists.dm
var/global/list/facial_hairs_cache = list() // Circular doubly linked list indexed by name and hash. see global_lists.dm
	//Underwear
var/global/list/underwear_m = list("White", "Black", "Coyot", "Olive", "Navy", "Pink", "None") //Curse whoever made male/female underwear diffrent colours
var/global/list/underwear_f = list("White", "Black", "Coyot", "Olive", "Navy", "Pink", "None")
	//undershirt
var/global/list/undershirt_t = list("Black Tank top", "White Tank top", "Blue Tank top", "Red Tank top", "Yellow Tank top", "Green Tank top", "Pink Tank top", "Purple Tank top", "Olive Tank top", "Navy Tank top", "Coyot Tank top", "Black shirt", "White shirt", "Blue shirt", "Red shirt", "Yellow shirt", "Green shirt", "Pink shirt","Purple shirt","Olive shirt","Navy shirt","Coyot shirt","None")
var/global/list/socks_t = list("White short", "White normal", "White long", "White knee", "Black short", "Black normal", "Black long", "Black knee", "Olive short", "Olive normal", "Olive long", "Olive knee", "Navy short", "Navy normal", "Navy long", "Navy knee", "Tights short", "Tights long", "Tights full", "None")
	//Backpacks
var/global/list/backbaglist = list("Nothing", "Backpack", "Sporty Backpack", "Satchel", "Satchel Alt")
	//Heights
var/global/list/heights_list = list(HUMANHEIGHT_SHORTEST, HUMANHEIGHT_SHORT, HUMANHEIGHT_MEDIUM, HUMANHEIGHT_TALL, HUMANHEIGHT_TALLEST)
