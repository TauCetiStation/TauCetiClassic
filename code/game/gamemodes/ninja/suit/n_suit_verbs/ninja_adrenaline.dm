/** 
  * ADRENALINE BOOST
  *  Wakes the user so they are able to do their thing. Also injects a decent dose of radium.
  *  Movement impairing would indicate drugs and the like.
  */
/obj/item/clothing/suit/space/space_ninja/proc/ninjaboost()
	set name = "Adrenaline Boost"
	set desc = "Inject a secret chemical that will counteract all movement-impairing effect."
	set category = "Ninja Ability"
	set popup_menu = 0

	if(!ninjacost(,3))//Have to make sure stat is not counted for this ability.
		var/mob/living/carbon/human/U = affecting
		//Wouldn't need to track adrenaline boosters if there was a miracle injection to get rid of paralysis and the like instantly.
		//For now, adrenaline boosters ARE the miracle injection. Well, radium, really.
		U.SetParalysis(0)
		U.SetWeakened(0)
	/*
	Due to lag, it was possible to adrenaline boost but remain helpless while life.dm resets player stat.
	This lead to me and others spamming adrenaline boosters because they failed to kick in on time.
	It's technically possible to come back from crit with this but it is very temporary.
	Life.dm will kick the player back into unconsciosness the next process loop.
	*/
		U.stat = CONSCIOUS//At least now you should be able to teleport away or shoot ninja stars.
		spawn(30)//Slight delay so the enemy does not immedietly know the ability was used. Due to lag, this often came before waking up.
			U.say(pick("A CORNERED FOX IS MORE DANGEROUS THAN A JACKAL!","HURT ME MOOORRREEE!","IMPRESSIVE!"))
		spawn(70)
			reagents.reaction(U, 2)
			reagents.trans_id_to(U, "radium", a_transfer)
			to_chat(U, "<span class='warning'>You are beginning to feel the after-effect of the injection.</span>")
		a_boost--
		s_coold = 3
	return
