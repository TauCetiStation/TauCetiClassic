//Preferences stuff
	//Hairstyles
var/global/list/hair_styles_list = list()			//stores /datum/sprite_accessory/hair indexed by name
var/global/list/facial_hair_styles_list = list()	//stores /datum/sprite_accessory/facial_hair indexed by name
	//Hairstyles Cache
var/global/list/hairs_cache = list()        // Circular doubly linked list indexed by name and hash. see global_lists.dm
var/global/list/facial_hairs_cache = list() // Circular doubly linked list indexed by name and hash. see global_lists.dm
	//Underwear
// todo: instead of underwear/undershirt/socks names read it from dmi states
var/global/list/underwear_t = list("White", "Black", "Coyot", "Olive", "Navy", "Pink")
var/global/list/undershirt_t = list("Black Tank top", "White Tank top", "Blue Tank top", "Red Tank top", "Yellow Tank top", "Green Tank top", "Pink Tank top", "Purple Tank top", "Olive Tank top", "Navy Tank top", "Coyot Tank top", "Black shirt", "White shirt", "Blue shirt", "Red shirt", "Yellow shirt", "Green shirt", "Pink shirt","Purple shirt","Olive shirt","Navy shirt","Coyot shirt")
var/global/list/socks_t = list("White short", "White normal", "White knee", "White long", "Black short", "Black normal", "Black knee", "Black long", "Olive short", "Olive normal", "Olive knee", "Olive long", "Navy short", "Navy normal", "Navy knee", "Navy long", "Tights short", "Tights long", "Tights full")
	//Backpacks
var/global/list/undershirt_prints_t = list("heart", "ian", "ceti", "nt", "beerex", "mond", "pacman", "sailor", "mountain")
var/global/list/backbaglist = list("Nothing", "Backpack", "Sporty Backpack", "Satchel", "Satchel Alt")
	//Heights
var/global/list/heights_list = list(HUMANHEIGHT_SHORTEST, HUMANHEIGHT_SHORT, HUMANHEIGHT_MEDIUM, HUMANHEIGHT_TALL, HUMANHEIGHT_TALLEST)
