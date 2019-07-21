//Cyborg
/datum/design/borg_suit
	name = "Cyborg Endoskeleton"
	id = "borg_suit"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_suit
	materials = list(MAT_METAL=50000)
	construction_time = 500
	starts_unlocked = TRUE
	category = list("Cyborg")

/datum/design/borg_chest
	name = "Cyborg Torso"
	id = "borg_chest"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/chest
	materials = list(MAT_METAL=40000)
	construction_time = 350
	starts_unlocked = TRUE
	category = list("Cyborg")

/datum/design/borg_head
	name = "Cyborg Head"
	id = "borg_head"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/head
	materials = list(MAT_METAL=25000)
	construction_time = 350
	starts_unlocked = TRUE
	category = list("Cyborg")

/datum/design/borg_l_arm
	name = "Cyborg Left Arm"
	id = "borg_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/l_arm
	materials = list(MAT_METAL=18000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Cyborg")

/datum/design/borg_r_arm
	name = "Cyborg Right Arm"
	id = "borg_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/r_arm
	materials = list(MAT_METAL=18000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Cyborg")

/datum/design/borg_l_leg
	name = "Cyborg Left Leg"
	id = "borg_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/l_leg
	materials = list(MAT_METAL=15000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Cyborg")

/datum/design/borg_r_leg
	name = "Cyborg Right Leg"
	id = "borg_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/r_leg
	materials = list(MAT_METAL=15000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Cyborg")

//Cyborg Components
/datum/design/borg_binary
	name = "Binary Communication Device"
	id = "borg_binary"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/binary_communication_device
	materials = list(MAT_METAL=5000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Cyborg Components")

/datum/design/borg_actuator
	name = "Actuator"
	id = "borg_actuator"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/actuator
	materials = list(MAT_METAL=5000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Cyborg Components")

/datum/design/borg_armour_plating
	name = "Armour Plating"
	id = "borg_armour_plating"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/armour
	materials = list(MAT_METAL=5000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Cyborg Components")

/datum/design/borg_camera
	name = "Camera"
	id = "borg_camera"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/camera
	materials = list(MAT_METAL=5000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Cyborg Components")

/datum/design/borg_diagnosis_unit
	name = "Diagnosis Unit"
	id = "borg_diagnosis_unit"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/diagnosis_unit
	materials = list(MAT_METAL=5000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Cyborg Components")

/datum/design/borg_radio
	name = "Radio"
	id = "borg_radio"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/radio
	materials = list(MAT_METAL=5000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Cyborg Components")


//Ripley
/datum/design/ripley_chassis
	name = "Exosuit Chassis (APLU \"Ripley\")"
	id = "ripley_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/ripley
	materials = list(MAT_METAL=20000)
	construction_time = 100
	starts_unlocked = TRUE
	category = list("Ripley")

/datum/design/ripley_torso
	name = "Exosuit Torso (APLU \"Ripley\")"
	id = "ripley_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_torso
	materials = list(MAT_METAL=40000, MAT_GLASS=15000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Ripley")

/datum/design/ripley_left_arm
	name = "Exosuit Left Arm (APLU \"Ripley\")"
	id = "ripley_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_left_arm
	materials = list(MAT_METAL=25000)
	construction_time = 150
	starts_unlocked = TRUE
	category = list("Ripley")

/datum/design/ripley_right_arm
	name = "Exosuit Right Arm (APLU \"Ripley\")"
	id = "ripley_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_right_arm
	materials = list(MAT_METAL=25000)
	construction_time = 150
	starts_unlocked = TRUE
	category = list("Ripley")

/datum/design/ripley_left_leg
	name = "Exosuit Left Leg (APLU \"Ripley\")"
	id = "ripley_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_left_leg
	materials = list(MAT_METAL=30000)
	construction_time = 150
	starts_unlocked = TRUE
	category = list("Ripley")

/datum/design/ripley_right_leg
	name = "Exosuit Right Leg (APLU \"Ripley\")"
	id = "ripley_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_right_leg
	materials = list(MAT_METAL=30000)
	construction_time = 150
	starts_unlocked = TRUE
	category = list("Ripley")


//Odysseus
/datum/design/odysseus_chassis
	name = "Exosuit Chassis (\"Odysseus\")"
	id = "odysseus_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/odysseus
	materials = list(MAT_METAL=20000)
	construction_time = 100
	starts_unlocked = TRUE
	category = list("Odysseus")

/datum/design/odysseus_torso
	name = "Exosuit Torso (\"Odysseus\")"
	id = "odysseus_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_torso
	materials = list(MAT_METAL=25000)
	construction_time = 180
	starts_unlocked = TRUE
	category = list("Odysseus")

/datum/design/odysseus_head
	name = "Exosuit Head (\"Odysseus\")"
	id = "odysseus_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_head
	materials = list(MAT_METAL=6000, MAT_GLASS=10000)
	construction_time = 100
	starts_unlocked = TRUE
	category = list("Odysseus")

/datum/design/odysseus_left_arm
	name = "Exosuit Left Arm (\"Odysseus\")"
	id = "odysseus_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_left_arm
	materials = list(MAT_METAL=10000)
	construction_time = 120
	starts_unlocked = TRUE
	category = list("Odysseus")

/datum/design/odysseus_right_arm
	name = "Exosuit Right Arm (\"Odysseus\")"
	id = "odysseus_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_right_arm
	materials = list(MAT_METAL=10000)
	construction_time = 120
	starts_unlocked = TRUE
	category = list("Odysseus")

/datum/design/odysseus_left_leg
	name = "Exosuit Left Leg (\"Odysseus\")"
	id = "odysseus_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_left_leg
	materials = list(MAT_METAL=15000)
	construction_time = 130
	starts_unlocked = TRUE
	category = list("Odysseus")

/datum/design/odysseus_right_leg
	name = "Exosuit Right Leg (\"Odysseus\")"
	id = "odysseus_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_right_leg
	materials = list(MAT_METAL=15000)
	construction_time = 130
	starts_unlocked = TRUE
	category = list("Odysseus")


//Gygax
/datum/design/gygax_chassis
	name = "Exosuit Chassis (\"Gygax\")"
	id = "gygax_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/gygax
	materials = list(MAT_METAL=25000)
	construction_time = 100
	starts_unlocked = TRUE
	category = list("Gygax")

/datum/design/gygax_torso
	name = "Exosuit Torso (\"Gygax\")"
	id = "gygax_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_torso
	materials = list(MAT_METAL=50000, MAT_GLASS=20000, MAT_DIAMOND=2000)
	construction_time = 300
	starts_unlocked = TRUE
	category = list("Gygax")

/datum/design/gygax_head
	name = "Exosuit Head (\"Gygax\")"
	id = "gygax_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_head
	materials = list(MAT_METAL=20000, MAT_GLASS=10000, MAT_DIAMOND=2000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Gygax")

/datum/design/gygax_left_arm
	name = "Exosuit Left Arm (\"Gygax\")"
	id = "gygax_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_left_arm
	materials = list(MAT_METAL=30000, MAT_DIAMOND=1000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Gygax")

/datum/design/gygax_right_arm
	name = "Exosuit Right Arm (\"Gygax\")"
	id = "gygax_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_right_arm
	materials = list(MAT_METAL=30000, MAT_DIAMOND=1000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Gygax")

/datum/design/gygax_left_leg
	name = "Exosuit Left Leg (\"Gygax\")"
	id = "gygax_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_left_leg
	materials = list(MAT_METAL=35000, MAT_DIAMOND=1000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Gygax")

/datum/design/gygax_right_leg
	name = "Exosuit Right Leg (\"Gygax\")"
	id = "gygax_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_right_leg
	materials = list(MAT_METAL=35000, MAT_DIAMOND=1000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Gygax")

/datum/design/gygax_armour
	name = "Exosuit Armour (\"Gygax\")"
	id = "gygax_armour"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_armour
	materials = list(MAT_METAL=50000, MAT_DIAMOND=10000)
	construction_time = 600
	starts_unlocked = TRUE
	category = list("Gygax")

//Gygax Ultra
/datum/design/ultra_chassis
	name = "Exosuit Chassis (\"Gygax Ultra\")"
	id = "ultra_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/ultra
	materials = list(MAT_METAL=37500)
	construction_time = 100
	starts_unlocked = TRUE
	category = list("Gygax Ultra")

/datum/design/ultra_torso
	name = "Exosuit Torso (\"Gygax Ultra\")"
	id = "ultra_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ultra_torso
	materials = list(MAT_METAL=68750, MAT_GLASS=25000, MAT_DIAMOND=2500)
	construction_time = 300
	starts_unlocked = TRUE
	category = list("Gygax Ultra")

/datum/design/ultra_head
	name = "Exosuit Head (\"Gygax Ultra\")"
	id = "ultra_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ultra_head
	materials = list(MAT_METAL=31250, MAT_GLASS=12500, MAT_DIAMOND=2500)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Gygax Ultra")

/datum/design/ultra_left_arm
	name = "Exosuit Left Arm (\"Gygax Ultra\")"
	id = "ultra_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ultra_left_arm
	materials = list(MAT_METAL=43750, MAT_DIAMOND=1250)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Gygax Ultra")

/datum/design/ultra_right_arm
	name = "Exosuit Right Arm (\"Gygax Ultra\")"
	id = "ultra_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ultra_right_arm
	materials = list(MAT_METAL=43750, MAT_DIAMOND=1250)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Gygax Ultra")

/datum/design/ultra_left_leg
	name = "Exosuit Left Leg (\"Gygax Ultra\")"
	id = "ultra_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ultra_left_leg
	materials = list(MAT_METAL=50000, MAT_DIAMOND=1250)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Gygax Ultra")

/datum/design/ultra_right_leg
	name = "Exosuit Right Leg (\"Gygax Ultra\")"
	id = "ultra_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ultra_right_leg
	materials = list(MAT_METAL=50000, MAT_DIAMOND=1250)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Gygax Ultra")

/datum/design/ultra_armour
	name = "Exosuit Armour (\"Gygax Ultra\")"
	id = "ultra_armour"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ultra_armour
	materials = list(MAT_METAL=75000, MAT_DIAMOND=25000)
	construction_time = 600
	starts_unlocked = TRUE
	category = list("Gygax Ultra")

//Durand
/datum/design/durand_chassis
	name = "Exosuit Chassis (\"Durand\")"
	id = "durand_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/durand
	materials = list(MAT_METAL=25000)
	construction_time = 100
	starts_unlocked = TRUE
	category = list("Durand")

/datum/design/durand_torso
	name = "Exosuit Torso (\"Durand\")"
	id = "durand_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_torso
	materials = list(MAT_METAL=55000, MAT_GLASS=10000, MAT_SILVER=10000)
	construction_time = 300
	starts_unlocked = TRUE
	category = list("Durand")

/datum/design/durand_head
	name = "Exosuit Head (\"Durand\")"
	id = "durand_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_head
	materials = list(MAT_METAL=25000, MAT_GLASS=15000, MAT_SILVER=3000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Durand")

/datum/design/durand_left_arm
	name = "Exosuit Left Arm (\"Durand\")"
	id = "durand_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_left_arm
	materials = list(MAT_METAL=35000, MAT_SILVER=4000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Durand")

/datum/design/durand_right_arm
	name = "Exosuit Right Arm (\"Durand\")"
	id = "durand_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_right_arm
	materials = list(MAT_METAL=35000, MAT_SILVER=4000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Durand")

/datum/design/durand_left_leg
	name = "Exosuit Left Leg (\"Durand\")"
	id = "durand_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_left_leg
	materials = list(MAT_METAL=40000, MAT_SILVER=4000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Durand")

/datum/design/durand_right_leg
	name = "Exosuit Right Leg (\"Durand\")"
	id = "durand_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_right_leg
	materials = list(MAT_METAL=40000, MAT_SILVER=4000)
	construction_time = 200
	starts_unlocked = TRUE
	category = list("Durand")

/datum/design/durand_armour
	name = "Exosuit Armour (\"Durand\")"
	id = "durand_armour"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_armour
	materials = list(MAT_METAL=50000, MAT_URANIUM=30000)
	construction_time = 600
	starts_unlocked = TRUE
	category = list("Durand")


//Vindicator
/datum/design/vindicator_chassis
	name = "Exosuit Chassis (\"Vindicator\")"
	id = "vindicator_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/vindicator
	materials = list(MAT_METAL=28000)
	construction_time = 100
	starts_unlocked = TRUE
	category = list("Vindicator")

/datum/design/vindicator_torso
	name = "Exosuit Torso (\"Vindicator\")"
	id = "vindicator_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/vindicator_torso
	materials = list(MAT_METAL=60000, MAT_GLASS=23000, MAT_SILVER=10000)
	construction_time = 330
	starts_unlocked = TRUE
	category = list("Vindicator")

/datum/design/vindicator_head
	name = "Exosuit Head (\"Vindicator\")"
	id = "vindicator_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/vindicator_head
	materials = list(MAT_METAL=30000, MAT_GLASS=13000, MAT_SILVER=3000)
	construction_time = 220
	starts_unlocked = TRUE
	category = list("Vindicator")

/datum/design/vindicator_left_arm
	name = "Exosuit Left Arm (\"Vindicator\")"
	id = "vindicator_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/vindicator_left_arm
	materials = list(MAT_METAL=40000, MAT_SILVER=3000)
	construction_time = 220
	starts_unlocked = TRUE
	category = list("Vindicator")

/datum/design/vindicator_right_arm
	name = "Exosuit Right Arm (\"Vindicator\")"
	id = "vindicator_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/vindicator_right_arm
	materials = list(MAT_METAL=40000, MAT_SILVER=3000)
	construction_time = 220
	starts_unlocked = TRUE
	category = list("Vindicator")

/datum/design/vindicator_left_leg
	name = "Exosuit Left Leg (\"Vindicator\")"
	id = "vindicator_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/vindicator_left_leg
	materials = list(MAT_METAL=50000, MAT_SILVER=3000)
	construction_time = 220
	starts_unlocked = TRUE
	category = list("Vindicator")

/datum/design/vindicator_right_leg
	name = "Exosuit Right Leg (\"Vindicator\")"
	id = "vindicator_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/vindicator_right_leg
	materials = list(MAT_METAL=50000, MAT_SILVER=3000)
	construction_time = 220
	starts_unlocked = TRUE
	category = list("Vindicator")

/datum/design/vindicator_armour
	name = "Exosuit Armour (\"Vindicator\")"
	id = "vindicator_armour"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/vindicator_armour
	materials = list(MAT_METAL=60000, MAT_URANIUM=15000)
	construction_time = 660
	starts_unlocked = TRUE
	category = list("Vindicator")


//Exosuit Equipment
/datum/design/firefighter_chassis
	name = "Exosuit Chassis (\"Firefighter\")"
	id = "firefighter_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/firefighter
	materials = list(MAT_METAL=20000)
	construction_time = 100
	starts_unlocked = TRUE
	category = list("Exosuit Equipment")

/datum/design/mech_hydraulic_clamp
	name = "Exosuit Engineering Equipement (Hydraulic Clamp)"
	id = "mech_hydraulic_clamp"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp
	materials = list(MAT_METAL=10000)
	construction_time = 100
	starts_unlocked = TRUE
	category = list("Exosuit Equipment")

/datum/design/mech_drill
	name = "Exosuit Engineering Equipement (Drill)"
	id = "mech_drill"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/drill
	materials = list(MAT_METAL=10000)
	construction_time = 100
	starts_unlocked = TRUE
	category = list("Exosuit Equipment")

/datum/design/mech_extinguisher
	name = "Exosuit Engineering Equipement (Extinguisher)"
	id = "mech_extinguisher"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/extinguisher
	materials = list(MAT_METAL=10000)
	construction_time = 100
	starts_unlocked = TRUE
	category = list("Exosuit Equipment")

/datum/design/mech_cable_layer
	name = "Exosuit Engineering Equipement (Cable Layer)"
	id = "mech_cable_layer"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/cable_layer
	materials = list(MAT_METAL=10000)
	construction_time = 100
	starts_unlocked = TRUE
	category = list("Exosuit Equipment")

/datum/design/mech_sleeper
	name = "Exosuit Medical Equipement (Mounted Sleeper)"
	id = "mech_sleeper"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/sleeper
	materials = list(MAT_METAL=5000, MAT_GLASS=10000)
	construction_time = 100
	starts_unlocked = TRUE
	category = list("Exosuit Equipment")

/datum/design/mech_generator
	name = "Exosuit Equipement (Phoron Generator)"
	id = "mech_generator"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/generator
	materials = list(MAT_METAL=10000, MAT_GLASS=1000, MAT_SILVER=500)
	construction_time = 100
	starts_unlocked = TRUE
	category = list("Exosuit Equipment")

/datum/design/mech_taser
	name = "Exosuit Weapon (PBT \"Pacifier\" Mounted Taser)"
	id = "mech_taser"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	materials = list(MAT_METAL=35000)
	construction_time = 100
	starts_unlocked = TRUE
	category = list("Exosuit Equipment")

/datum/design/mech_lmg
	name = "Exosuit Weapon (\"Ultra AC 2\" LMG)"
	id = "mech_lmg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	materials = list(MAT_METAL=35000)
	construction_time = 100
	starts_unlocked = TRUE
	category = list("Exosuit Equipment")

/datum/design/mech_scattershot
	name = "Exosuit Weapon (LBX AC 10 \"Scattershot\")"
	desc = "Allows for the construction of LBX AC 10."
	id = "mech_scattershot"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	materials = list(MAT_METAL=50000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_carbine
	name = "Exosuit Weapon (FNX-99 \"Hades\" Carbine)"
	desc = "Allows for the construction of FNX-99 \"Hades\" Carbine."
	id = "mech_carbine"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	materials = list(MAT_METAL=70000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_laser
	name = "Exosuit Weapon (CH-PS \"Immolator\" Laser)"
	desc = "Allows for the construction of CH-PS Laser."
	id = "mech_laser"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	materials = list(MAT_METAL=20000, MAT_SILVER=5000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_laser_heavy
	name = "Exosuit Weapon (CH-LC \"Solaris\" Laser Cannon)"
	desc = "Allows for the construction of CH-LC Laser Cannon."
	id = "mech_laser_heavy"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	materials = list(MAT_METAL=25000, MAT_SILVER=8000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_ion
	name = "Exosuit Weapon (MKIV Ion Heavy Cannon)"
	desc = "Allows for the construction of MKIV Ion Heavy Cannon."
	id = "mech_ion"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	materials = list(MAT_METAL=20000, MAT_SILVER=6000, MAT_URANIUM=2000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_pulse
	name = "Exosuit Weapon (eZ-13 mk2 Heavy pulse rifle)"
	desc = "Allows for the construction of eZ-13 mk2 Heavy pulse rifle."
	id = "mech_pulse"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse
	materials = list(MAT_METAL=15000, MAT_SILVER=25000, MAT_URANIUM=6000, MAT_PHORON=6000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_missile_rack
	name = "Exosuit Weapon (SRM-8 Missile Rack)"
	desc = "Allows for the construction of SRM-8 Missile Rack."
	id = "mech_missile_rack"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/explosive
	materials = list(MAT_METAL=22000, MAT_SILVER=8000, MAT_GOLD=6000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_grenade_launcher
	name = "Exosuit Weapon (SGL-6 Grenade Launcher)"
	desc = "Allows for the construction of SGL-6 Grenade Launcher."
	id = "mech_grenade_launcher"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	materials = list(MAT_METAL=22000, MAT_SILVER=8000, MAT_GOLD=6000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/clusterbang_launcher
	name = "Exosuit Module (SOP-6 Clusterbang Launcher)"
	desc = "A weapon that violates the Geneva Convention at 6 rounds per minute."
	id = "clusterbang_launcher"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang/limited
	materials = list(MAT_METAL=20000, MAT_GOLD=10000, MAT_URANIUM=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_wormhole_gen
	name = "Exosuit Module (Localized Wormhole Generator)"
	desc = "An exosuit module that allows generating of small quasi-stable wormholes."
	id = "mech_wormhole_gen"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/wormhole_generator
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_teleporter
	name = "Exosuit Module (Teleporter Module)"
	desc = "An exosuit module that allows exosuits to teleport to any position in view."
	id = "mech_teleporter"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/teleporter
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_rcd
	name = "Exosuit Module (RCD Module)"
	desc = "An exosuit-mounted Rapid Construction Device."
	id = "mech_rcd"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/rcd
	materials = list(MAT_METAL=30000, MAT_GOLD=20000, MAT_PHORON=25000, MAT_SILVER=20000)
	construction_time = 1200
	category = list("Exosuit Equipment")

/datum/design/mech_gravcatapult
	name = "Exosuit Module (Gravitational Catapult Module)"
	desc = "An exosuit mounted Gravitational Catapult."
	id = "mech_gravcatapult"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/gravcatapult
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_repair_droid
	name = "Exosuit Module (Repair Droid Module)"
	desc = "Automated Repair Droid. BEEP BOOP!"
	id = "mech_repair_droid"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/repair_droid
	materials = list(MAT_METAL=10000, MAT_GLASS=5000, MAT_GOLD=1000, MAT_SILVER=2000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_energy_relay
	name = "Exosuit Module (Tesla Energy Relay)"
	desc = "Tesla Energy Relay."
	id = "mech_energy_relay"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	materials = list(MAT_METAL=10000, MAT_GLASS=2000, MAT_GOLD=2000, MAT_SILVER=3000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_ccw_armor
	name = "Exosuit Module (Reactive Armor Booster Module)"
	desc = "Exosuit-mounted armor booster."
	id = "mech_ccw_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster
	materials = list(MAT_METAL=20000, MAT_GOLD=5000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_proj_armor
	name = "Exosuit Module (Reflective Armor Booster Module)"
	desc = "Exosuit-mounted armor booster."
	id = "mech_proj_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	materials = list(MAT_METAL=20000, MAT_GOLD=5000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_syringe_gun
	name = "Exosuit Module (Syringe Gun)"
	desc = "Exosuit-mounted syringe gun and chemical synthesizer."
	id = "mech_syringe_gun"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/syringe_gun
	materials = list(MAT_METAL=3000, MAT_GLASS=2000)
	construction_time = 200
	category = list("Exosuit Equipment")

/datum/design/mech_diamond_drill
	name = "Exosuit Module (Diamond Mining Drill)"
	desc = "An upgraded version of the standard drill."
	id = "mech_diamond_drill"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill
	materials = list(MAT_METAL=10000, MAT_DIAMOND=6500)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_generator_nuclear
	name = "Exosuit Module (ExoNuclear Reactor)"
	desc = "Compact nuclear reactor module."
	id = "mech_generator_nuclear"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/generator/nuclear
	materials = list(MAT_METAL=10000, MAT_GLASS=1000, MAT_SILVER=500)
	construction_time = 100
	category = list("Exosuit_Equipment")

//Cyborg Upgrade Modules
/datum/design/borg_upgrade_reset
	name = "Cyborg Upgrade Module (Reset Module)"
	id = "borg_upgrade_reset"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/reset
	materials = list(MAT_METAL=10000)
	construction_time = 120
	starts_unlocked = TRUE
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_rename
	name = "Cyborg Upgrade Module (Rename Module)"
	id = "borg_upgrade_rename"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/rename
	materials = list(MAT_METAL=35000)
	construction_time = 120
	starts_unlocked = TRUE
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_restart
	name = "Cyborg Upgrade Module (Restart Module)"
	id = "borg_upgrade_restart"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/restart
	materials = list(MAT_METAL=60000, MAT_GLASS=5000)
	construction_time = 120
	starts_unlocked = TRUE
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_vtec
	name = "Cyborg Upgrade Module (VTEC Module)"
	id = "borg_upgrade_vtec"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/vtec
	materials = list(MAT_METAL=80000, MAT_GLASS=6000, MAT_GOLD=5000)
	construction_time = 120
	starts_unlocked = TRUE
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_tasercooler
	name = "Cyborg Upgrade Module (Rapid Taser Cooling Module)"
	id = "borg_upgrade_tasercooler"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/tasercooler
	materials = list(MAT_METAL=80000, MAT_GLASS=6000, MAT_GOLD=2000, MAT_DIAMOND=500)
	construction_time = 120
	starts_unlocked = TRUE
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_jetpack
	name = "Cyborg Upgrade Module (Mining Jetpack)"
	id = "borg_upgrade_jetpack"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/jetpack
	materials = list(MAT_METAL=10000, MAT_PHORON=15000, MAT_URANIUM=20000)
	construction_time = 120
	starts_unlocked = TRUE
	category = list("Cyborg Upgrade Modules")


//Misc
/datum/design/mecha_tracking
	name = "Exosuit Tracking Beacon"
	id = "mecha_tracking"
	build_type = MECHFAB
	build_path =/obj/item/mecha_parts/mecha_tracking
	materials = list(MAT_METAL=500)
	construction_time = 50
	starts_unlocked = TRUE
	category = list("Misc")
