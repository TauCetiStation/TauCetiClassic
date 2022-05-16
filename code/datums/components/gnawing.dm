/datum/component/gnawing

/datum/component/gnawing/Initialize()
	if(!isanimal(parent))
		return COMPONENT_INCOMPATIBLE
	START_PROCESSING(SSgnaw, src)

/datum/component/gnawing/process()
	var/mob/living/simple_animal/animal = parent
	if(animal.incapacitated() || !isturf(animal.loc))
		return
	var/list/attack = animal.get_unarmed_attack()
	var/damage = attack["damage"]
	for(var/obj/structure/cable/C in animal.loc)
		C.take_damage(damage)

/datum/component/gnawing/Destroy()
	STOP_PROCESSING(SSgnaw, src)
	return ..()
