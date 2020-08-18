//Preferences stuff
	//Hairstyles
var/global/list/hair_styles_list = list()			//stores /datum/sprite_accessory/hair indexed by name
var/global/list/facial_hair_styles_list = list()	//stores /datum/sprite_accessory/facial_hair indexed by name
	//Hairstyles Cache
var/global/list/hairs_cache = list()        // Circular doubly linked list indexed by name and hash. see global_lists.dm
var/global/list/facial_hairs_cache = list() // Circular doubly linked list indexed by name and hash. see global_lists.dm
	//Underwear
var/global/list/underwear_m = list("White", "Grey", "Green", "Blue", "Black", "Mankini", "None") //Curse whoever made male/female underwear diffrent colours
var/global/list/underwear_f = list("Red", "White", "Yellow", "Blue", "Black", "Thong", "None")
	//undershirt
var/global/list/undershirt_t = list("Black Tank top", "White Tank top", "Black shirt", "White shirt", "Love shirt", "Corgy shirt", "Brit shirt", "I love NT shirt", "Peace shirt", "Mond shirt", "Pacman shirt", "Sailor shirt", "Short sleeves white shirt", "Short sleeves purple shirt", "Short sleeves blue shirt", "Short sleeves green shirt", "Short sleeves black shirt", "Blue shirt","Red shirt","Yellow shirt","Green shirt","Blue polo","Red polo","White polo","Gray-yellow polo","Green sport shirt","Red sport shirt","Blue sport shirt","Red top","White top", "None")
var/global/list/socks_t = list("White normal", "White normal hipster", "White short", "White knee", "White long", "Black normal", "Black short", "Black knee", "Black long", "Tights knee", "Tights long", "Tights full", "Rainbow knee", "Rainbow long", "Stripped knee", "Stripped long", "USA knee", "USA long", "Australia knee", "Australia long", "Present knee", "Present long", "None")
	//Backpacks
var/global/list/backbaglist = list("Nothing", "Backpack", "Sporty Backpack", "Satchel", "Satchel Alt")
