/mob/living/simple_animal/hostile
	/// A dict of sort type = amount.
	var/list/loot_list = list()
	/// All amounts of loot from loot_list are multiplied by this value.
	var/loot_mod = 1.0

/mob/living/simple_animal/hostile/death(gibbed)
	spawn_loot()
	return ..()

/mob/living/simple_animal/hostile/proc/spawn_loot()
	for(var/loot_type in loot_list)
		var/spawn_am = round(loot_list[loot_type] * loot_mod)
		for(var/am in 1 to spawn_am)
			new loot_type(loc)
