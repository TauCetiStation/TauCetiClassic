// ENERGY NET
/*Allows the ninja to capture people, I guess.
Must right click on a mob to activate.*/
/obj/item/clothing/suit/space/space_ninja/proc/ninjanet(mob/living/carbon/M in oview())//Only living carbon mobs.
	set name = "Energy Net (500E)"
	set desc = "Captures a opponent in a net of energy."
	set category = null
	set src = usr.contents

	//var/C = 700
	var/C = 50
	if(!ninjacost(C,0)&&iscarbon(M))
		var/mob/living/carbon/human/U = affecting
		if(M.client)//Monkeys without a client can still step_to() and bypass the net. Also, netting inactive people is lame.
		//if(M)//DEBUG
			if(!locate(/obj/effect/energy_net) in M.loc)//Check if they are already being affected by an energy net.
				for(var/turf/T in getline(U.loc, M.loc))
					if(T.density)//Don't want them shooting nets through walls. It's kind of cheesy.
						to_chat(U, "You may not use an energy net through solid obstacles!")
						return
				spawn(0)
					U.Beam(M,"n_beam",,15)
				M.captured = 1
				U.say("Get over here!")
				var/obj/effect/energy_net/E = new /obj/effect/energy_net(M.loc)
				E.layer = M.layer+1//To have it appear one layer above the mob.
				U.visible_message("<span class='warning'>[U] caught [M] with an energy net!</span>")
				E.affecting = M
				E.master = U
				spawn(0)//Parallel processing.
					E.process(M)
				cell.use(C*10) // Nets now cost what should be most of a standard battery, since your taking someone out of the round
			else
				to_chat(U, "They are already trapped inside an energy net.")
		else
			to_chat(U, "They will bring no honor to your Clan!")
	return
