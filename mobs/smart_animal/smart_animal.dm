/*
 * Подкласс simple_animal, мобы реагирующие на окружающий мир
 * Смотреть так-же simple_animal.dm
 * Тут только основы с пояснениями, более частные случаи в smart_animal_reactions.dm(СКОРО)
 */
/mob/living/simple_animal/smart_animal

	//разговоры вокруг, можем парсить и как-то реагировать на них
	proc/listen_talks(message, mob/user as mob)
		return

	//вызывается , если кто-то встал на соседний с мобом тайл, будь это человек или объект.
	//объекты и HasEntered() работают как-то выборочно, но с мобами работает
	//можем либо отреагировать эмоутом, либо звуком, либо даже запустить звуковой файл(как на гунах, да)
	HasEntered(AM as mob|obj)
		return

	//если кто-то в поле видимости кого-то атакует(рукопашная, или стрельба), сообщаем об этом мобу
	proc/fight(var/mob/attacker, var/mob/attacked)
		return

	//В РАЗРАБОТКЕ
	//Реакция на смерть моба в поле зрения
	//Можем проверить, одного ли он с нами типа, и опять же как-то отреагировать
	proc/mob_death(dead as mob)
		return

	//когда кто-то на кого-то показал в поле видимости моба
	proc/target_point(var/atom/target, var/mob/user)
		return

	//Повернуться в направлении цели
	proc/turn_to(var/atom/target)
		if (target.loc.x < src.x)
			dir = WEST
		else if (target.loc.x > src.x)
			dir = EAST
		else if (target.loc.y < src.y)
			dir = SOUTH
		else if (target.loc.y > src.y)
			dir = NORTH
		else
			dir = SOUTH