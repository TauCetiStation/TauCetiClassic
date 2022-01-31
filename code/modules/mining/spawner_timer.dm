/datum/spawner_timer
	var/timer = 150 //Раз в сколько тиков рожаются новые мобы
	var/rand_max_mob = 3

/datum/spawner_timer/proc/randomize_max()
	if(timer == 0)
		timer = 150
		rand_max_mob = rand(2,10)
	timer -= 1