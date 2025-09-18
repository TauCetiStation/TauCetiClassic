/datum/objective/custom
	explanation_text = "Просто будь собой."
	completed = OBJECTIVE_WIN

//if user passed - means that this will be called as an explicit custom objective and will require user input
/datum/objective/custom/New(text, mob/user, datum/faction/faction)
	if(!user)
		return
	if(faction)
		src.faction = faction
	var/txt = input(user, "Каким должен быть текст этой цели?", "Кастомная цель", "Просто будь собой.")
	explanation_text = txt

/datum/objective/custom/wishgranter

/datum/objective/custom/wishgranter/New()
	switch(rand(1,100))
		if(1 to 50)
			explanation_text = "Украдите [pick("ручной телепортер", "капитанский антикварный лазерный пистолет", "джетпак", "капитанскую ID карту", "комбинезон капитана")]."
		if(51 to 60)
			explanation_text = "Уничтожьте резервуаровы с фороном на станции минимум на 70% и более."
		if(61 to 70)
			explanation_text = "Обесточьте станцию на 80%."
		if(71 to 80)
			explanation_text = "Уничтожьте ИИ."
		if(81 to 90)
			explanation_text = "Убьйте всех обезьян на станции."
		else
			explanation_text = "Убедитесь, что не менее 80% станции эвакуируется на шаттле."

/datum/objective/custom/clowns
	explanation_text = "ВЗЛОМАЙТЕ как можно больше вещей! ХОНК!!"
