/mob/living/silicon/robot/syndicate/initialize_components()
	components["actuator"] = new/datum/robot_component/actuator/combat(src)
	components["radio"] = new/datum/robot_component/radio/combat(src)
	components["power cell"] = new/datum/robot_component/cell/combat(src)
	components["diagnosis unit"] = new/datum/robot_component/diagnosis_unit/combat(src)
	components["camera"] = new/datum/robot_component/camera/combat(src)
	components["comms"] = new/datum/robot_component/binary_communication/combat(src)
	components["armour"] = new/datum/robot_component/armour/class_5(src)

/datum/robot_component/armour/class_5
	name = "armour plating (Class V)"
	max_damage = 180

//Combat Components (+75% HP)
/datum/robot_component/actuator/combat
	name = "actuator"
	max_damage = 88

/datum/robot_component/cell/combat
	max_damage = 88

/datum/robot_component/radio/combat
	max_damage = 70

/datum/robot_component/binary_communication/combat
	max_damage = 53

/datum/robot_component/camera/combat
	max_damage = 70

/datum/robot_component/diagnosis_unit/combat
	max_damage = 53
