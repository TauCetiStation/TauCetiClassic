ADD_TO_GLOBAL_LIST(/obj/item/device/geyger, geyger_items_list)
/obj/item/device/geyger
	name = "radiation dosimeter"
	desc = "count rad"
	icon_state = "geyger"
	item_state = "multitool"

/obj/item/device/geyger/proc/recieve_rad_signal(amount_rad, distance_to_rad)
	if(!amount_rad)
		return
	if(distance_to_rad < 0)
		return
	var/distance_factor = signal_power * distance_to_rad
	if(distance_factor < signal_power)
		SOUND_ALERT
	if(distance_factor >= signal_power)
		SOUND_LOUD
	if(distance_factor > 1)
		SOUND_MEDIUM
	if(distance_factor > 1)
		SOUND_LIGHT

// Singularity pull (size * 3) [9 is 3 size]
// Suppermatter when consumed 500 * (sqrt(1/distance+1)) [176 in 7 distance]
// Suppermatter attackby radiation 150 * (1/sqrt(distance+1)) [53 in 7 distance]
// Suppermatter light explosion 160 * (sqrt(1/distance)) [60 in 7 distance]
// Suppermatter big explosion 200 * (sqrt(1/distance+1)) [70 in 7 distance]
// Space [5]
// Artefact touch 10 * 5  = [50]
// Artefact aura [10]
// Artefact pulse [10 * power]
// Health traitor analyze intensity * 10 (default 10*10) [100]
// Decloner gun [30-40]
// Phoron gun [20]
// AEGun in range 0 [3-120]
// AEGun in range 1-4 once pulse [300]
// Chernobyl 40 * (sqrt(1/distance+1)) [14 in 1 distance]
// Engine Accelerator Wave (5-15) * 2 * 3 [90]
// Mech Nuclear module [0,9]
// Luminophore [1]
// Rig Nuclear module [5-25]
// Rad Virus [5-20]
// Mineral wall ??? [25 in 200 distance]
// EM field radiation * 0.001 [?]
// Flora gun [30-80]
// Teleporter [80-120]
// Uran Door [15 in 3 distance]
// Uran Door [12 in 3 distance]
// Uran False door + rad other walls [12 in 3 distance]
// Rad Storm [40-70 per tick 40% chance]
// Mutagen per consume [10]
// Broadcaster [225 in 3 distance]
// Radium per consume [2 * REM]
// Radium when you have virus 50% chance [50]
// Radiocarbon Spectrometer [3-4]

// Human consume
// if rad > 100 stun 10 weaken 20
// 1 dose consume per life (2 sec)
// prob 25 to give 1 toxloss
// if rad > 50 consume 1 dose
	// prob(5) && prob (rad) Bald
	// prob(5) consume 5 dose + 6 weaken
// if rad > 75 consume 1 dose, 3 toxloss
	// prob(1) mutate

