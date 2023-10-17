/mob/living
	see_invisible = SEE_INVISIBLE_LIVING
	//Health and life related vars
	var/maxHealth = 100 //Maximum health that should be possible.
	var/health = 100 	//A mob's health


	//Damage related vars, NOTE: THESE SHOULD ONLY BE MODIFIED BY PROCS
	var/bruteloss = 0.0	//Brutal damage caused by brute force (punching, being clubbed by a toolbox ect... this also accounts for pressure damage)
	var/oxyloss = 0.0	//Oxygen depravation damage (no air in lungs)
	var/toxloss = 0.0	//Toxic damage caused by being poisoned or radiated
	var/fireloss = 0.0	//Burn damage caused by being way too hot, too cold or burnt.
	var/cloneloss = 0	//Damage caused by being cloned or ejected from the cloner early. slimes also deal cloneloss damage to victims
	var/brainloss = 0	//'Retardation' damage caused by someone hitting you in the head with a bible or being infected with brainrot.
	var/halloss = 0		//Hallucination damage. 'Fake' damage obtained through hallucinating or the holodeck. Sleeping should cause it to wear off.


	var/hallucination = 0 //Directly affects how long a mob will hallucinate for
	var/list/atom/hallucinations = list() //A list of hallucinated people that try to attack the mob. See /obj/effect/fake_attacker in hallucinations.dm

	// Holly, we're drunk.
	// Should this be in organ/liver ? ~Luduk
	var/drunkenness = 0

	var/last_special = 0 //Used by the resist verb, likely used to prevent players from bypassing next_move by logging in/out.

	//Allows mobs to move through dense areas without restriction. For instance, in space or out of holder objects.
	var/incorporeal_move = 0 //0 is off, 1 is normal, 2 is for ninjas.

	var/now_pushing = null

	var/mob/living/cameraFollow = null

	var/tod = null // Time of death
	var/update_slimes = 1
	var/silent = null 		//Can't talk. Value goes down every life proc.
	var/speed = 0			//Movement addditive modifier

	var/on_fire = 0 //The "Are we on fire?" var
	var/fire_stacks = 0 //Tracks how many stacks of fire we have on, max is usually 20

	var/tesla_ignore = FALSE
	var/list/butcher_results = null

	var/list/recent_tastes = list()
	var/lasttaste = 0 // Prevent tastes spam

	var/list/roundstart_quirks = list()
	var/list/status_effects // a list of all status effects the mob has
	hud_possible = list(HEALTH_HUD, STATUS_HUD, ANTAG_HUD, HOLY_HUD)

	var/force_remote_viewing = FALSE

	// These should be changed whenever the mob somehow permanently affects their image.
	// By default these are filled in in atom_init().
	var/matrix/default_transform = matrix()
	var/default_pixel_x = 0
	var/default_pixel_y = 0
	var/default_layer = 0

	// Moveset type that this mob is spawned with(What the mob should know "by nature")
	var/moveset_type = /datum/combat_moveset/living

	// This var is only used by a punching bag. Causes mob to not notify admins nor store who has hit it.
	var/logs_combat = TRUE

	var/datum/modval/beauty

	var/beauty_living = 0.0
	var/beauty_dead = -100.0

	var/list/spawner_args = null

	COOLDOWN_DECLARE(wc_use_cooldown)
