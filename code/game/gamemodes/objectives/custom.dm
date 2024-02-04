/datum/objective/custom
	explanation_text = "Просто будь собой"
	completed = OBJECTIVE_WIN

//if user passed - means that this will be called as an explicit custom objective and will require user input
/datum/objective/custom/New(text, mob/user, datum/faction/faction)
	if(!user)
		return
	if(faction)
		src.faction = faction
	var/txt = input(user, "Что должно быть в тексте задачи?", "Настраиваемая задача.", "Просто будь собой.")
	explanation_text = txt

/datum/objective/custom/wishgranter

/datum/objective/custom/wishgranter/New()
	switch(rand(1,100))
		if(1 to 50)
			explanation_text = "Укради [pick("ручной телепортер", "антикварный лазер капитана", "реактивный ранец", "ID-карту капитана", "капитанскую униформу")]."
		if(51 to 60)
			explanation_text = "Уничтожьте 70% баков с фороном на станции."
		if(61 to 70)
			explanation_text = "Перекройте подачу энергии на станции."
		if(71 to 80)
			explanation_text = "Уничтожить ИИ."
		if(81 to 90)
			explanation_text = "Убить всех обезьян на станции."
		else
			explanation_text = "80% членов экипажа должно покинуть станции на шаттле."

/datum/objective/custom/clowns
	explanation_text = "Взломай столько вещей, сколько сможешь! ХОООНК!"
