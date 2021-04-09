/mob/living/carbon/xenomorph/larva/verb/evolve()
	set name = "Эволюция"
	set desc = "Превратиться во взрослого ксеноморфа."
	set category = "Alien"

	if(incapacitated())
		to_chat(src, "<span class='warning'>Вы не в состоянии сейчас эволюционировать.</span>")
		return

	if(!isturf(src.loc))
		to_chat(src, "<span class='warning'>Вы не можете эволюционировать, когда находитесь внутри чего-то.</span>")//Silly aliens!
		return

	if(amount_grown >= max_grown)
		var/queen = FALSE
		var/drone = FALSE
		for(var/mob/living/carbon/xenomorph/humanoid/queen/Q in alien_list[ALIEN_QUEEN])
			if(Q.stat == DEAD || !Q.key)
				continue
			queen = TRUE
		for(var/mob/living/carbon/xenomorph/A in alien_list[ALIEN_DRONE])
			if(A.stat == DEAD || !A.key)
				continue
			drone = TRUE
			break	//we don't care how many drones there are

		var/evolve_now = null
		var/alien_caste = null
		if(!queen && !drone)
			evolve_now = alert(src, "Сейчас вы можете превратиться только в трутня, так как среди ксеноморфов нет в живых ни одного трутня либо королевы.", "Улей в опасности!", "Быть Трутнем", "Отмена")
			if(evolve_now == "Отмена")
				return
			alien_caste = "Трутень"
		else
			evolve_now = alert(src, "Вы уверены что хотите сейчас эволюционировать?",,"Да","Нет")
			if(evolve_now == "Нет")
				return
			to_chat(src, {"<br><span class='notice'><b>Вы превращаетесь во взрослого ксеноморфа! Пора выбрать одну из трех каст:</b></span>
	<B>Охотники</B> <span class='notice'>- сильны и подвижны, способны охотиться вдали от улья и быстро перемещаться по вентиляционным шахтам. Охотники производят плазму медленно и имеют небольшие запасы.</span>
	<B>Стражи</B> <span class='notice'>- защитники улья, и они смертельно опасны как вблизи, так и на расстоянии. Менее подвижны, чем охотники, но имеют большие запасы плазмы.</span>
	<B>Трутни</B> <span class='notice'>- рабочий класс, они обустраивают улей, быстро производят плазму и имеют самый большой её запас. Только трутни могут стать королевой ксеноморфов.</span><br>"})

			alien_caste = alert(src, "Пожалуйста, выберите, к какой касте ксеноморфов вы хотите принадлежать.", "Выберите касту", "Охотник", "Страж", "Трутень")
			if(alien_caste == "Отмена")
				return

		to_chat(src, "<span class='alien'>Подождите пока закончится процесс эволюции.</span>")
		if(!do_after(src, 10 SECONDS, target = src))
			return

		var/mob/living/carbon/xenomorph/humanoid/new_xeno
		switch(alien_caste)
			if("Охотник")
				new_xeno = new /mob/living/carbon/xenomorph/humanoid/hunter(loc)
			if("Страж")
				new_xeno = new /mob/living/carbon/xenomorph/humanoid/sentinel(loc)
			if("Трутень")
				new_xeno = new /mob/living/carbon/xenomorph/humanoid/drone(loc)
		if(!new_xeno)
			CRASH("new_xeno = null. Chosen caste: [alien_caste].")
		if(mind)
			mind.transfer_to(new_xeno)
			new_xeno.mind.name = new_xeno.real_name
			qdel(src)
		return
	else
		to_chat(src, "<span class='warning'>Вы еще не выросли.</span>")
		return
