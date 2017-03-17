/mob/living/carbon/human
	var/age = 30		//Player's age (pure fluff)

	var/backbag = 2		//Which backpack type the player has chosen. Nothing, Satchel or Backpack.

	// General information
	var/home_system = ""
	var/citizenship = ""
	var/personal_faction = ""
	var/religion = ""

	var/used_skillpoints = 0
	var/skill_specialization = null
	var/list/skills = null

	var/miming = null //Toggle for the mime's abilities.

	var/xylophone = 0 //For the spoooooooky xylophone cooldown

	//Golem stuff
	var/my_master = 0
	var/my_golems = list()

	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/human = 5)
