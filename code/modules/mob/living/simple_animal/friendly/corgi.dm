//Corgi
/mob/living/simple_animal/corgi
	name = "\improper corgi"
	real_name = "corgi"
	desc = "It's a corgi."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks", "woofs", "yaps","pants")
	emote_see = list("shakes its head", "shivers")
	speak_chance = 1
	turns_per_move = 10
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	meat_amount = 3
	response_help  = "pets the"
	response_disarm = "bops the"
	response_harm   = "kicks the"
	see_in_dark = 5
	var/obj/item/inventory_head
	var/obj/item/inventory_back
	var/facehugger
	var/dodged

/mob/living/simple_animal/corgi/Life()
	..()
	regenerate_icons()

/mob/living/simple_animal/corgi/show_inv(mob/user)
	user.set_machine(src)
	if(user.stat) return

	//Text version of inventory
/*
	var/dat = 	"<div align='center'><b>Inventory of [name]</b></div><p>"
	if(inventory_head)
		dat +=	"<br><b>Head:</b> [inventory_head] (<a href='?src=\ref[src];remove_inv=head'>Remove</a>)"
	else
		dat +=	"<br><b>Head:</b> <a href='?src=\ref[src];add_inv=head'>Nothing</a>"
	if(inventory_back)
		dat +=	"<br><b>Back:</b> [inventory_back] (<a href='?src=\ref[src];remove_inv=back'>Remove</a>)"
	else
		dat +=	"<br><b>Back:</b> <a href='?src=\ref[src];add_inv=back'>Nothing</a>"
*/

	//Icon version of Inventory
	var/icon/sprite

	var/dat = 	"<div align='center'><b><hr>Inventory of [name]</b></div><hr>"
	if(inventory_head)
		sprite = new /icon(inventory_head.icon, inventory_head.icon_state)
		user << browse_rsc(sprite, "ian_hat.png")
		dat += "<br><b>Head:</b> <img src='ian_hat.png'>(<a href='?src=\ref[src];remove_inv=head'>Remove</a>)"
	else
		dat +=	"<br><b>Head:</b> <a href='?src=\ref[src];add_inv=head'>Nothing</a>"
	if(inventory_back)
		sprite = new /icon(inventory_back.icon, inventory_back.icon_state)
		user << browse_rsc(sprite, "ian_back.png")
		dat += "<br><b>Back:</b> <img src='ian_back.png'>(<a href='?src=\ref[src];remove_inv=back'>Remove</a>)"
	else
		dat +=	"<br><b>Back:</b> <a href='?src=\ref[src];add_inv=back'>Nothing</a>"
	dat += "<br><a href='?src=\ref[user];mach_close=mob[type]'>Close</a>"

	user << browse(dat, text("window=mob[];size=325x500", type))
	onclose(user, "mob[type]")
	return

/mob/living/simple_animal/corgi/attackby(obj/item/O, mob/user)
	if(inventory_head && inventory_back)
		//helmet and armor = 100% protection
		if( istype(inventory_head,/obj/item/clothing/head/helmet) && istype(inventory_back,/obj/item/clothing/suit/armor) )
			if( O.force )
				to_chat(usr, "\red This animal is wearing too much armor. You can't cause /him any damage.")
				for (var/mob/M in viewers(src, null))
					M.show_message("\red \b [user] hits [src] with the [O], however [src] is too armored.")
			else
				to_chat(usr, "\red This animal is wearing too much armor. You can't reach its skin.")
				for (var/mob/M in viewers(src, null))
					M.show_message("\red [user] gently taps [src] with the [O]. ")
			if(prob(15))
				if(health > 0)
					emote("me",1,"looks at [user] with [pick("an amused","an annoyed","a confused","a resentful","a happy","an excited")] expression on his face")
			return
	..()

/mob/living/simple_animal/corgi/attack_hand(mob/living/carbon/human/M)
	if(inventory_head && inventory_back)
		if(health > 0)
			if( istype(inventory_head,/obj/item/clothing/head/helmet) && istype(inventory_back,/obj/item/clothing/suit/armor) )
				switch(M.a_intent)
					if("hurt", "disarm")
						for(var/mob/O in viewers(src, null))
							if ((O.client && !( O.blinded )))
								//M.show_message("\red [M] gently [response_harm] [src].")
								M.show_message("\red [src] dodges [M]'s kick.")
						if(prob(15))
							emote("me",1,"looks at [M] with [pick("an amused","an annoyed","a confused","a resentful","a happy","an excited")] expression on his face")
						return
	..()

/mob/living/simple_animal/corgi/bullet_act(obj/item/projectile/Proj)
	if(!Proj)	return
	if(inventory_head && inventory_back)
		if(health > 0)
			if( istype(inventory_head,/obj/item/clothing/head/helmet) && istype(inventory_back,/obj/item/clothing/suit/armor) )
				if(!dodged)
					dodged++
					spawn(100)
						dodged = 0
					for (var/mob/M in viewers(src, null))
						if(Proj.flag == "bullet")
							M.show_message("\red \b [src] catches [Proj] with his jaws.")
						else
							M.show_message("\red \b [src] dodges [Proj].")
					if(prob(15))
						emote("me",1,"looks with [pick("a resentful","a happy","an excited")] expression on his face and wants to play more!")
					return
	..()

/mob/living/simple_animal/corgi/hitby(atom/movable/AM)
	if(inventory_head && inventory_back)
		if( istype(inventory_head,/obj/item/clothing/head/helmet) && istype(inventory_back,/obj/item/clothing/suit/armor) )
			for (var/mob/M in viewers(src, null))
				M.show_message("\red [src] has been hit by [AM], however [src] is too armored.")
			if(prob(15))
				if(health > 0)
					emote("me",1,"looks at [AM] with [pick("an amused","an annoyed","a confused")] expression on his face")
			return
	..()

/mob/living/simple_animal/corgi/Topic(href, href_list)
	if(usr.stat) return

	//Removing from inventory
	if(href_list["remove_inv"])
		if(!Adjacent(usr) || !(ishuman(usr) || ismonkey(usr) || isrobot(usr) ||  isalienadult(usr)))
			return
		var/remove_from = href_list["remove_inv"]
		switch(remove_from)
			if("head")
				if(inventory_head)
					name = real_name
					desc = initial(desc)
					speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
					speak_emote = list("barks", "woofs")
					emote_hear = list("barks", "woofs", "yaps","pants")
					emote_see = list("shakes its head", "shivers")
					desc = "It's a corgi."
					set_light(0)
					inventory_head.loc = src.loc
					inventory_head = null
					regenerate_icons()
				else
					to_chat(usr, "\red There is nothing to remove from its [remove_from].")
					return
			if("back")
				if(inventory_back)
					inventory_back.loc = src.loc
					inventory_back = null
					regenerate_icons()
				else
					to_chat(usr, "\red There is nothing to remove from its [remove_from].")
					return

		show_inv(usr) //Commented out because changing Ian's  name and then calling up his inventory opens a new inventory...which is annoying.

	//Adding things to inventory
	else if(href_list["add_inv"])
		if(!Adjacent(usr) || !(ishuman(usr) || ismonkey(usr) || isrobot(usr) ||  isalienadult(usr)))
			return
		var/add_to = href_list["add_inv"]
		if(!usr.get_active_hand())
			to_chat(usr, "\red You have nothing in your hand to put on its [add_to].")
			return
		switch(add_to)
			if("head")
				if(inventory_head)
					to_chat(usr, "\red It's is already wearing something.")
					return
				else
					//Corgis are supposed to be simpler, so only a select few objects can actually be put
					//to be compatible with them. The objects are below.
					//Many  hats added, Some will probably be removed, just want to see which ones are popular.

					var/list/allowed_types = list(
						/obj/item/clothing/head/helmet,
						/obj/item/clothing/glasses/sunglasses,
						/obj/item/clothing/head/caphat,
						/obj/item/clothing/head/collectable/captain,
						/obj/item/clothing/head/that,
						/obj/item/clothing/head/kitty,
						/obj/item/clothing/head/collectable/kitty,
						/obj/item/clothing/head/rabbitears,
						/obj/item/clothing/head/collectable/rabbitears,
						/obj/item/clothing/head/beret,
						/obj/item/clothing/head/collectable/beret,
						/obj/item/clothing/head/det_hat,
						/obj/item/clothing/head/nursehat,
						/obj/item/clothing/head/pirate,
						/obj/item/clothing/head/collectable/pirate,
						/obj/item/clothing/head/ushanka,
						/obj/item/clothing/head/chefhat,
						/obj/item/clothing/head/collectable/chef,
						/obj/item/clothing/head/collectable/police,
						/obj/item/clothing/head/wizard/fake,
						/obj/item/clothing/head/wizard,
						/obj/item/clothing/head/collectable/wizard,
						/obj/item/clothing/head/hardhat/yellow,
						/obj/item/clothing/head/collectable/hardhat,
						/obj/item/clothing/head/hardhat/white,
						/obj/item/weapon/bedsheet,
						/obj/item/clothing/head/helmet/space/santahat,
						/obj/item/clothing/head/collectable/paper,
						/obj/item/clothing/head/soft
					)

					var/obj/item/item_to_add = usr.get_active_hand()
					if(!item_to_add)
						return
					if( ! ( item_to_add.type in allowed_types ) )
						to_chat(usr, "\red It doesn't seem too keen on wearing that item.")
						return
					//place_on_head(usr.get_active_hand())
					usr.drop_item()
					place_on_head(item_to_add)

			if("back")
				if(inventory_back)
					to_chat(usr, "\red It's already wearing something.")
					return
				else
					var/obj/item/item_to_add = usr.get_active_hand()
					if(!item_to_add)
						return

					//Corgis are supposed to be simpler, so only a select few objects can actually be put
					//to be compatible with them. The objects are below.

					var/list/allowed_types = list(
						/obj/item/clothing/suit/armor/vest,
						/obj/item/device/radio,
						/obj/item/device/radio/off
					)

					if( ! ( item_to_add.type in allowed_types ) )
						to_chat(usr, "\red This object won't fit.")
						return

					usr.drop_item()
					item_to_add.loc = src
					src.inventory_back = item_to_add
					regenerate_icons()

		show_inv(usr) //Commented out because changing Ian's  name and then calling up his inventory opens a new inventory...which is annoying.
	else
		..()

/mob/living/simple_animal/corgi/proc/place_on_head(obj/item/item_to_add)
	item_to_add.loc = src
	src.inventory_head = item_to_add
	regenerate_icons()

	//Various hats and items (worn on his head) change Ian's behaviour. His attributes are reset when a HAT is removed.
	switch(inventory_head && inventory_head.type)
		if(/obj/item/clothing/head/caphat, /obj/item/clothing/head/collectable/captain)
			name = "Captain [real_name]"
			desc = "Probably better than the last captain."
		if(/obj/item/clothing/head/kitty, /obj/item/clothing/head/collectable/kitty)
			name = "Runtime"
			emote_see = list("coughs up a furball", "stretches")
			emote_hear = list("purrs")
			speak = list("Purrr", "Meow!", "MAOOOOOW!", "HISSSSS", "MEEEEEEW")
			desc = "It's a cute little kitty-cat! ... wait ... what the hell?"
		if(/obj/item/clothing/head/rabbitears, /obj/item/clothing/head/collectable/rabbitears)
			name = "Hoppy"
			emote_see = list("twitches its nose", "hops around a bit")
			desc = "This is hoppy. It's a corgi-...urmm... bunny rabbit"
		if(/obj/item/clothing/head/beret, /obj/item/clothing/head/collectable/beret)
			name = "Yann"
			desc = "Mon dieu! C'est un chien!"
			speak = list("le woof!", "le bark!", "JAPPE!!")
			emote_see = list("cowers in fear", "surrenders", "plays dead","looks as though there is a wall in front of him")
		if(/obj/item/clothing/head/det_hat)
			name = "Detective [real_name]"
			desc = "[name] sees through your lies..."
			emote_see = list("investigates the area","sniffs around for clues","searches for scooby snacks")
		if(/obj/item/clothing/head/nursehat)
			name = "Nurse [real_name]"
			desc = "[name] needs 100cc of beef jerky...STAT!"
		if(/obj/item/clothing/head/pirate, /obj/item/clothing/head/collectable/pirate)
			name = "[pick("Ol'","Scurvy","Black","Rum","Gammy","Bloody","Gangrene","Death","Long-John")] [pick("kibble","leg","beard","tooth","poop-deck","Threepwood","Le Chuck","corsair","Silver","Crusoe")]"
			desc = "Yaarghh!! Thar' be a scurvy dog!"
			emote_see = list("hunts for treasure","stares coldly...","gnashes his tiny corgi teeth")
			emote_hear = list("growls ferociously", "snarls")
			speak = list("Arrrrgh!!","Grrrrrr!")
		if(/obj/item/clothing/head/ushanka)
			name = "[pick("Comrade","Commissar","Glorious Leader")] [real_name]"
			desc = "A follower of Karl Barx."
			emote_see = list("contemplates the failings of the capitalist economic model", "ponders the pros and cons of vangaurdism")
		if(/obj/item/clothing/head/collectable/police)
			name = "Officer [real_name]"
			emote_see = list("drools","looks for donuts")
			desc = "Stop right there criminal scum!"
		if(/obj/item/clothing/head/wizard/fake,	/obj/item/clothing/head/wizard,	/obj/item/clothing/head/collectable/wizard)
			name = "Grandwizard [real_name]"
			speak = list("YAP", "Woof!", "Bark!", "AUUUUUU", "EI  NATH!")
		if(/obj/item/weapon/bedsheet)
			name = "\improper Ghost"
			speak = list("WoooOOOooo~","AUUUUUUUUUUUUUUUUUU")
			emote_see = list("stumbles around", "shivers")
			emote_hear = list("howls","groans")
			desc = "Spooky!"
		if(/obj/item/clothing/head/helmet/space/santahat)
			name = "Rudolph the Red-Nosed Corgi"
			emote_hear = list("barks christmas songs", "yaps")
			desc = "He has a very shiny nose."
			set_light(6)
		if(/obj/item/clothing/head/soft)
			name = "Corgi Tech [real_name]"
			desc = "The reason your yellow gloves have chew-marks."


//IAN! SQUEEEEEEEEE~
/mob/living/simple_animal/corgi/Ian
	name = "Ian"
	real_name = "Ian"	//Intended to hold the name without altering it.
	gender = MALE
	desc = "It's a corgi."
	var/turns_since_scan = 0
	var/obj/movement_target
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"

/mob/living/simple_animal/corgi/Ian/Life()
	..()

	//Feeding, chasing food, FOOOOODDDD
	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/obj/item/weapon/reagent_containers/food/snacks/S in oview(src,3))
					if(isturf(S.loc) || ishuman(S.loc))
						if(istype(S, /obj/item/weapon/reagent_containers/food/snacks/meat/corgi))
							emote("me",1,"sniffs [S] with a confused expression on his face")
							spawn(50)
								emote("me",1,"cryes for a second, seizes up and falls limp, his eyes dead and lifeless...")
								health = 0
						movement_target = S
						break
			if(movement_target)
				stop_automated_movement = 1
				step_to(src,movement_target,1)
				sleep(3)
				step_to(src,movement_target,1)
				sleep(3)
				step_to(src,movement_target,1)

				if(movement_target)		//Not redundant due to sleeps, Item can be gone in 6 decisecomds
					if (movement_target.loc.x < src.x)
						dir = WEST
					else if (movement_target.loc.x > src.x)
						dir = EAST
					else if (movement_target.loc.y < src.y)
						dir = SOUTH
					else if (movement_target.loc.y > src.y)
						dir = NORTH
					else
						dir = SOUTH

					if(isturf(movement_target.loc) )
						movement_target.attack_animal(src)
					else if(ishuman(movement_target.loc) )
						if(prob(20))
							emote("me",1,"stares at the [movement_target] that [movement_target.loc] has with a sad puppy-face")

		if(prob(1))
			emote("me",1,pick("dances around","chases its tail"))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					dir = i
					sleep(1)

/obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	name = "Corgi meat"
	desc = "Tastes like... well you know..."

//PC stuff-Sieve

/mob/living/simple_animal/corgi/attackby(obj/item/O, mob/user)  //Marker -Agouri
	if(istype(O, /obj/item/weapon/newspaper))
		if(!stat)
			for(var/mob/M in viewers(user, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\blue [user] baps [name] on the nose with the rolled up [O]")
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2))
					dir = i
					sleep(1)
	else
		..()

/mob/living/simple_animal/corgi/regenerate_icons()
	overlays = list()

	if(inventory_head)
		var/head_icon_state = inventory_head.icon_state
		if(health <= 0)
			head_icon_state += "2"

		var/icon/head_icon = image('icons/mob/corgi_head.dmi',head_icon_state)
		if(head_icon)
			overlays += head_icon

	if(inventory_back)
		var/back_icon_state = inventory_back.icon_state
		if(health <= 0)
			back_icon_state += "2"

		var/icon/back_icon = image('icons/mob/corgi_back.dmi',back_icon_state)
		if(back_icon)
			overlays += back_icon

	if(facehugger)
		if(istype(src, /mob/living/simple_animal/corgi/puppy))
			overlays += image('icons/mob/mask.dmi',"facehugger_corgipuppy")
		else
			overlays += image('icons/mob/mask.dmi',"facehugger_corgi")

	return


/mob/living/simple_animal/corgi/puppy
	name = "\improper corgi puppy"
	real_name = "corgi"
	desc = "It's a corgi puppy."
	icon_state = "puppy"
	icon_living = "puppy"
	icon_dead = "puppy_dead"

//pupplies cannot wear anything.
/mob/living/simple_animal/corgi/puppy/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, "\red You can't fit this on [src]")
		return
	..()


//LISA! SQUEEEEEEEEE~
/mob/living/simple_animal/corgi/Lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "It's a corgi with a cute pink bow."
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	var/turns_since_scan = 0
	var/puppies = 0

//Lisa already has a cute bow!
/mob/living/simple_animal/corgi/Lisa/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, "\red [src] already has a cute bow!")
		return
	..()

/mob/living/simple_animal/corgi/Lisa/Life()
	..()

	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 15)
			turns_since_scan = 0
			var/alone = 1
			var/ian = 0
			//for(var/mob/M in oviewers(7, src))
			for(var/mob/M in oview(src,7))
				if(istype(M, /mob/living/simple_animal/corgi/Ian))
					if(M.client)
						alone = 0
						break
					else
						ian = M
				else
					alone = 0
					break
			if(alone && ian && puppies < 4)
				if(near_camera(src) || near_camera(ian))
					return
				new /mob/living/simple_animal/corgi/puppy(loc)
				puppies++


		if(prob(1))
			emote("me",1,pick("dances around","chases her tail"))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					dir = i
					sleep(1)

/mob/living/simple_animal/corgi/Ian/borgi
	name = "E-N"
	real_name = "E-N"	//Intended to hold the name without altering it.
	desc = "It's a borgi."
	icon_state = "borgi"
	icon_living = "borgi"
	icon_dead = "borgi_dead"
	meat_type = null
	var/emagged = 0

/mob/living/simple_animal/corgi/Ian/borgi/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/card/emag) && emagged < 2)
		Emag(user)
	else
		..()

/mob/living/simple_animal/corgi/Ian/borgi/proc/Emag(user)
	if(!emagged)
		emagged = 1
		visible_message("<span class='warning'>[user] swipes a card through [src].</span>", "<span class='notice'>You overload [src]s internal reactor.</span>")
		spawn (1000)
			src.explode()

/mob/living/simple_animal/corgi/Ian/borgi/proc/explode()
	for(var/mob/M in viewers(src, null))
		if (M.client)
			M.show_message("\red [src] makes an odd whining noise.")
	sleep(10)
	explosion(get_turf(src), 0, 1, 4, 7)
	Die()

/mob/living/simple_animal/corgi/Ian/borgi/proc/shootAt(atom/movable/target)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if (!T || !U)
		return
	var/obj/item/projectile/beam/A = new /obj/item/projectile/beam(loc)
	A.icon = 'icons/effects/genetics.dmi'
	A.icon_state = "eyelasers"
	playsound(src.loc, 'sound/weapons/taser2.ogg', 75, 1)
	A.original = target
	A.current = T
	A.starting = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	spawn( 0 )
		A.process()
	return

/mob/living/simple_animal/corgi/Ian/borgi/Life()
	..()
	if(health <= 0) return
	if(emagged && prob(25))
		var/mob/living/carbon/target = locate() in view(10,src)
		if (target)
			shootAt(target)

	//spark for no reason
	if(prob(5))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

/mob/living/simple_animal/corgi/Ian/borgi/proc/Die()
	..()
	visible_message("<b>[src]</b> blows apart!")
	new /obj/effect/decal/cleanable/blood/gibs/robot(src.loc)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	//respawnable_list += src
	qdel(src)
	return
