//TRAIN STATION 13

//Not really sure if there will be additional unique mobs, but this module is meant just for them.

/mob/living/simple_animal/pug/frank
	name = "Frank"
	real_name = "Frank"
	desc = "It's a pug. Not at all suspicious, pug."
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU", "Who let the dogs out?! Woof, woof, woof, woof, woof!", "Grrrrr... Bark! Bark! Bark!", "You humans! When will you learn size doesn't matter? Just because something's important, doesn't mean it's not very small.", "How about we do the good cop, bad cop routine? You can interrogate the witness, and I'll just growl. Grrrrr...", "Listen, partner. I may look like a dog, but I'm only play one here.")
	speak_emote = list("says", "barks", "woofs")
	emote_hear = list("barks", "woofs", "yaps", "pants", "looks around", "adjusts the skin")
	emote_see = list("shakes its head", "chases its tail", "shivers", "laughs", "pretends to be a dog", "hums a pop song")
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/xenomeat = 3)