/datum/component/gnawing

/datum/component/gnawing/Initialize()
	START_PROCESSING(SSgnaw, src)

/datum/component/gnawing/process()
	var/mob/living/simple_animal/animal = parent
	if(animal.incapacitated())
		return
	var/list/attack = animal.get_unarmed_attack()
	for(var/obj/structure/cable/C in animal.loc)
		C.health -= attack["damage"]
		C.check_health()

/datum/component/gnawing/Destroy()
	STOP_PROCESSING(SSgnaw, src)
	return ..()
