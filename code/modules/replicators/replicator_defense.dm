/mob/living/simple_animal/hostile/replicator
	var/weakened_until = 0

/mob/living/simple_animal/hostile/replicator/IsWeaken()
	return weakened_until > world.time

/mob/living/simple_animal/hostile/replicator/AmountWeaken()
	return max(0.0, weakened_until - world.time)

/mob/living/simple_animal/hostile/replicator/Weaken(amount, ignore_canstun = FALSE)
	weakened_until = max(weakened_until, world.time + amount * SS_WAIT_DEFAULT)

/mob/living/simple_animal/hostile/replicator/SetWeakened(amount, ignore_canstun = FALSE)
	weakened_until = world.time + amount * SS_WAIT_DEFAULT

/mob/living/simple_animal/hostile/replicator/AdjustWeakened(amount, ignore_canstun = FALSE)
	weakened_until = world.time + AmountWeaken() + amount * SS_WAIT_DEFAULT
