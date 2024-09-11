/mob/living/silicon/robot/combat/initialize_components()
	components["actuator"] = new/datum/robot_component/actuator/combat(src)
	components["radio"] = new/datum/robot_component/radio/combat(src)
	components["power cell"] = new/datum/robot_component/cell/combat(src)
	components["diagnosis unit"] = new/datum/robot_component/diagnosis_unit/combat(src)
	components["camera"] = new/datum/robot_component/camera/combat(src)
	components["comms"] = new/datum/robot_component/binary_communication/combat(src)
	components["armour"] = new/datum/robot_component/armour/class_3(src)

/datum/robot_component/armour/class_3
	name = "armour plating (Class III)"
	max_damage = 120
