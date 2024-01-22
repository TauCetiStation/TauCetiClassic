var/global/list/global_map = null
	//list/global_map = list(list(1,5),list(4,3))//an array of map Z levels.
	//Resulting sector map looks like
	//|_1_|_4_|
	//|_5_|_3_|
	//
	//1 - SS13
	//4 - Derelict
	//3 - AI satellite
	//5 - empty space

var/global/list/newplayer_start = list()
var/global/list/latejoin = list()
var/global/list/prisonwarp = list()	//prisoners go to these
var/global/list/xeno_spawn = list()//Aliens spawn at these.
var/global/list/tdome1 = list()
var/global/list/tdome2 = list()
var/global/list/tdomeobserve = list()
var/global/list/tdomeadmin = list()
var/global/list/prisonsecuritywarp = list()	//prison security goes to these
var/global/list/prisonwarped = list()	//list of players already warped
var/global/list/cardinal = list(NORTH, SOUTH, EAST, WEST)
var/global/list/cardinalz = list(NORTH, SOUTH, EAST, WEST, UP, DOWN)
var/global/list/cornerdirs = list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
var/global/list/cornerdirsz = list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST, NORTH|UP, EAST|UP, WEST|UP, SOUTH|UP, NORTH|DOWN, EAST|DOWN, WEST|DOWN, SOUTH|DOWN)
var/global/list/alldirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
var/global/list/reverse_dir = list(2, 1, 3, 8, 10, 9, 11, 4, 6, 5, 7, 12, 14, 13, 15, 32, 34, 33, 35, 40, 42, 41, 43, 36, 38, 37, 39, 44, 46, 45, 47, 16, 18, 17, 19, 24, 26, 25, 27, 20, 22, 21, 23, 28, 30, 29, 31, 48, 50, 49, 51, 56, 58, 57, 59, 52, 54, 53, 55, 60, 62, 61, 63)
var/global/list/prisonerstart = list()
	//away missions
var/global/list/awaydestinations = list()	//a list of landmarks that the warpgate can take you to

//List of preloaded templates
var/global/list/datum/map_template/map_templates = list()

//var/list/datum/map_template/ruins_templates = list()
//var/list/datum/map_template/space_ruins_templates = list()
//var/list/datum/map_template/lava_ruins_templates = list()

//var/list/datum/map_template/shuttle_templates = list()
var/global/list/datum/map_template/shelter_templates = list()
var/global/list/datum/map_template/holoscene_templates = list()
var/global/list/datum/map_template/spacestructures_templates = list()
