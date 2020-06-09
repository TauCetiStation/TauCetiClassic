/mob/living/carbon
	gender = MALE
	var/list/stomach_contents = list()
	var/chest_brain_op_stage = 0
	var/list/datum/disease2/disease/virus2 = list()
	var/antibodies = 0
	var/last_eating = 0 	//Not sure what this does... I found it hidden in food.dm

	var/life_tick = 0      // The amount of life ticks that have processed on this mob.
	var/analgesic = 0 // when this is set, the mob isn't affected by shock or pain
					  // life should decrease this by 1 every tick
	// total amount of wounds on mob, used to spread out healing and the like over all wounds
	var/number_wounds = 0
	var/obj/item/handcuffed = null //Whether or not the mob is handcuffed
	var/obj/item/legcuffed = null  //Same as handcuffs but for legs. Bear traps use this.
	//Surgery info
	var/datum/surgery_status/op_stage = new/datum/surgery_status
	//Active emote/pose
	var/pose = null

	var/pulse = PULSE_NORM	//current pulse level

	var/oxygen_alert = 0
	var/phoron_alert = 0
	var/fire_alert = 0
	var/pressure_alert = 0
	var/temperature_alert = 0
	var/co2overloadtime = null
	var/temperature_resistance = T0C+75

	var/metabolism_factor = METABOLISM_FACTOR

	var/obj/item/head
	var/obj/item/shoes
	var/obj/item/neck
	var/obj/item/mouth

	var/stamina = 100 //Ian uses this for now.
