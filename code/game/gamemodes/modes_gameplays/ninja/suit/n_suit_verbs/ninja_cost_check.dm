// SAFETY CHECK
/*
X is optional, tells the proc to check for specific stuff. C is also optional.
All the procs here assume that the character is wearing the ninja suit if they are using the procs.
They should, as I have made every effort for that to be the case.
In the case that they are not, I imagine the game will run-time error like crazy.
s_cooldown ticks off each second based on the suit recharge proc, in seconds. Default of 1 seconds. Some abilities have no cool down.
*/

//Cost function for suit Procs/Verbs/Abilities
/obj/item/clothing/suit/space/space_ninja/proc/ninjacost(C = 0,X = 0)
	var/mob/living/carbon/human/U = affecting
	if( (U.stat||U.incorporeal_move)&&X!=3 )//Will not return if user is using an adrenaline booster since you can use them when stat==1.
		to_chat(U, "<span class='warning'>You must be conscious and solid to do this.</span>")//It's not a problem of stat==2 since the ninja will explode anyway if they die.
		return 1
	else if(C&&cell.charge<C*10)
		to_chat(U, "<span class='warning'>Not enough energy.</span>")
		return 1
	switch(X)
		if(1)
			cancel_stealth()//Get rid of it.
		if(2)
			if(s_bombs<=0)
				to_chat(U, "<span class='warning'>There are no more smoke bombs remaining.</span>")
				return 1
		if(3)
			if(a_boost<=0)
				to_chat(U, "<span class='warning'>You do not have any more adrenaline boosters.</span>")
				return 1
	return (s_coold)//Returns the value of the variable which counts down to zero.
