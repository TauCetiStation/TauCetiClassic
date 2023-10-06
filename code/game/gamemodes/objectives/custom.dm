/datum/objective/custom
	explanation_text = "Just be yourself"
	completed = OBJECTIVE_WIN

//if user passed - means that this will be called as an explicit custom objective and will require user input
/datum/objective/custom/New(text, mob/user, datum/faction/faction)
	if(!user)
		return
	if(faction)
		src.faction = faction
	var/txt = input(user, "What should be the text of this objective?", "Custom objective", "Just be yourself")
	explanation_text = txt

/datum/objective/custom/wishgranter

/datum/objective/custom/wishgranter/New()
	switch(rand(1,100))
		if(1 to 50)
			explanation_text = "Steal [pick("a hand teleporter", "the Captain's antique laser gun", "a jetpack", "the Captain's ID", "the Captain's jumpsuit")]."
		if(51 to 60)
			explanation_text = "Destroy 70% or more of the station's phoron tanks."
		if(61 to 70)
			explanation_text = "Cut power to 80% or more of the station's tiles."
		if(71 to 80)
			explanation_text = "Destroy the AI."
		if(81 to 90)
			explanation_text = "Kill all monkeys aboard the station."
		else
			explanation_text = "Make certain at least 80% of the station evacuates on the shuttle."

/datum/objective/custom/clowns
	explanation_text = "Emag as many things as you can! HONK!"
