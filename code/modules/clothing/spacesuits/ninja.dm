/obj/item/clothing/head/helmet/space/space_ninja
	desc = "What may appear to be a simple black garment is in fact a highly sophisticated nano-weave helmet. Standard issue ninja gear."
	name = "ninja hood"
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	allowed = list(/obj/item/weapon/stock_parts/cell)
	armor = list(melee = 60, bullet = 50, laser = 60,energy = 45, bomb = 50, bio = 100, rad = 50)
	species_restricted = null
	body_parts_covered = HEAD|FACE
	force = 0
	hitsound = list()

/obj/item/clothing/head/helmet/space/space_ninja/equipped(mob/living/user, slot)
	. = ..()
	if(slot == SLOT_HEAD)
		RegisterSignal(user, COMSIG_LIVING_CAN_TRACK, PROC_REF(can_track))
	else
		UnregisterSignal(user, COMSIG_LIVING_CAN_TRACK)

/obj/item/clothing/head/helmet/space/space_ninja/dropped(mob/living/user)
	. = ..()
	UnregisterSignal(user, COMSIG_LIVING_CAN_TRACK)

/obj/item/clothing/head/helmet/space/space_ninja/proc/can_track(datum/source)
	SIGNAL_HANDLER
	return COMPONENT_CANT_TRACK

/obj/item/clothing/suit/space/space_ninja
	name = "ninja suit"
	desc = "A unique, vaccum-proof suit of nano-enhanced armor designed specifically for Spider Clan assassins."
	icon_state = "s-ninja"
	item_state = "s-ninja_suit"
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box/magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/stock_parts/cell)
	slowdown = 0
	armor = list(melee = 60, bullet = 50, laser = 60,energy = 45, bomb = 30, bio = 100, rad = 50)
	species_restricted = null //Workaround for spawning alien ninja without internals.
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	supporting_limbs = list()

	// Hardsuit breaching data
	breach_threshold = 30 //A suit breach is a major issue for ninjas. This should maybe help.
	can_breach = 1

	//Important parts of the suit.
	var/mob/living/carbon/affecting = null//The wearer.
	var/obj/item/weapon/stock_parts/cell/cell//Starts out with a high-capacity cell using New().
	var/datum/effect/effect/system/spark_spread/spark_system//To create sparks.
	var/reagent_list[] = list("tricordrazine","tramadol","dexalinp","spaceacillin","anti_toxin","nutriment","radium","hyronalin")//The reagents ids which are added to the suit at New().
	var/list/stored_research//For stealing station research.
	var/obj/item/weapon/disk/tech_disk/t_disk//To copy design onto disk.

		//Other articles of ninja gear worn together, used to easily reference them after initializing.
	var/obj/item/clothing/head/helmet/space/space_ninja/n_hood
	var/obj/item/clothing/shoes/space_ninja/n_shoes
	var/obj/item/clothing/gloves/space_ninja/n_gloves

		//Main function variables.
	var/s_initialized = 0//Suit starts off.
	var/s_coold = 0//If the suit is on cooldown. Can be used to attach different cooldowns to abilities. Ticks down every second based on suit ntick().
	var/s_cost = 5.0//Base energy cost each ntick.
	var/s_acost = 25.0//Additional cost for additional powers active.
	var/k_cost = 200.0//Kamikaze energy cost each ntick.
	var/k_damage = 1.0//Brute damage potentially done by Kamikaze each ntick.
	var/s_delay = 40.0//How fast the suit does certain things, lower is faster. Can be overridden in specific procs. Also determines adverse probability.
	var/a_transfer = 20.0//How much reagent is transferred when injecting.
	var/r_maxamount = 80.0//How much reagent in total there is.

		//Support function variables.
	var/spideros = 0//Mode of SpiderOS. This can change so I won't bother listing the modes here (0 is hub). Check ninja_equipment.dm for how it all works.
	var/s_active = 0//Stealth off.
	var/s_busy = 0//Is the suit busy with a process? Like AI hacking. Used for safety functions.
	var/kamikaze = 0//Kamikaze on or off.
	var/k_unlock = 0//To unlock Kamikaze.

		//Ability function variables.
	var/s_bombs = 10.0//Number of starting ninja smoke bombs.
	var/a_boost = 3.0//Number of adrenaline boosters.

		//Onboard AI related variables.
	var/mob/living/silicon/ai/AI//If there is an AI inside the suit.
	var/obj/item/device/paicard/pai//A slot for a pAI device
	var/obj/effect/overlay/hologram//Is the AI hologram on or off? Visible only to the wearer of the suit. This works by attaching an image to a blank overlay.
	var/flush = 0//If an AI purge is in progress.
	var/s_control = 1//If user in control of the suit.
