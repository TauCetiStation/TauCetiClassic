#define SOUND_LIGHT "sound/items/radioactive_machine_light.ogg"
#define SOUND_MEDIUM "sound/items/radioactive_machine_medium.ogg"
#define SOUND_LOUD "sound/items/radioactive_machine_huge.ogg"
#define SOUND_ALERT "sound/items/radioactive_machine_alert.ogg"

// dose per second
#define SAFE_DOSE 5
#define HEALTH_EFFECT_DOSE 7.5
#define DANGEROUS_DOSE 10

ADD_TO_GLOBAL_LIST(/obj/item/device/geiger, geiger_items_list)
/obj/item/device/geiger
	name = "radiation dosimeter"
	desc = "count rad"
	icon_state = "geiger_v2"
	item_state = "multitool"
	var/status
	var/last_rad_signal = 0
	var/last_distance = 0
	COOLDOWN_DECLARE(sound_play_cd)

/obj/item/device/geiger/attack_self(mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	status = !status
	icon_state = status ? "geiger_v2_on" : "geiger_v2"
	playsound(user, 'sound/items/flashlight.ogg', VOL_EFFECTS_MASTER, 20)
	to_chat(user, "<span class='notice'>You turn [status ? "on" : "off"] [src].</span>")

/obj/item/device/geiger/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>Last recieved radiation signal: [last_rad_signal] mSv.<br>Approximate distance: [last_rad_signal] m.</span>")

/obj/item/device/geiger/proc/recieve_rad_signal(amount_rad, distance_to_rad)
	if(!status)
		return
	if(!amount_rad)
		return
	if(distance_to_rad < 0)
		return
	var/distance_volume = abs(clamp(distance_to_rad, 0, 70)-100)
	var/dose_sound = SOUND_LIGHT
	switch(amount_rad)
		if(SAFE_DOSE to HEALTH_EFFECT_DOSE)
			dose_sound = SOUND_MEDIUM
		if(HEALTH_EFFECT_DOSE to DANGEROUS_DOSE)
			dose_sound = SOUND_LOUD
		if(DANGEROUS_DOSE to INFINITY)
			dose_sound = SOUND_ALERT
	if(COOLDOWN_FINISHED(src, sound_play_cd))
		playsound(src, dose_sound, VOL_EFFECTS_MASTER, distance_volume)
		var/sound/S = sound(dose_sound)
		COOLDOWN_START(src, sound_play_cd, S.len)
	last_rad_signal = round(amount_rad)
	last_distance = distance_to_rad

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


// https://freesound.org/people/Benboncan/sounds/66922/
// https://freesound.org/people/leonelmail/sounds/328381/
