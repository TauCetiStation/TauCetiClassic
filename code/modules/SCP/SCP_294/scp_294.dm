/obj/machinery/scp294
	name = "SCP-294"
	desc = "A standard coffee vending machine. This one seems to have a QWERTY keyboard."
	icon = 'code/modules/SCP/SCP_294/SCP.dmi'
	icon_state = "scp294"
	layer = 2.9
	anchored = 1
	density = 1
	var/uses_left = 12
	var/last_use = 0
	var/restocking_timer = 0
	var/cooldown_delay = 2000
	var/black_list = list("adminordrazine", "xenomicrobes", "nanites", "mutationtoxin", "amutationtoxin")

/obj/machinery/scp294/attack_hand(mob/user)
	if((last_use + 3 SECONDS) > world.time)
		visible_message("<span class='notice'>[src] displays NOT READY message.</span>")
		return
	last_use = world.time
	if(uses_left < 1)
		visible_message("<span class='notice'>[src] displays RESTOCKING, PLEASE WAIT message.</span>")
		return
	var/product = null
	var/mob/living/carbon/victim = null
	var/input_reagent = lowertext(input("Enter the name of any liquid", "What would you like to drink?") as text)
	for(var/mob/living/carbon/M in world)
		if (lowertext(M.real_name) == input_reagent)
			if (istype(M, /mob/living/carbon/))
				victim = M
				if(victim)
					M.emote("scream",,, 1)
					to_chat(M, "<span class='danger'>You feel a sharp stabbing pain in your insides!</span>")
					var/i
					var/pain = rand(1, 6)
					for(i=1; i<=pain; i++)
						M.adjustBruteLoss(5)
	if(!victim)
		product = find_reagent(input_reagent)
		if(product in black_list)
			product = null
	sleep(10)
	if(product)
		playsound(src, 'sound/items/vending.ogg', 50, 1, 1)
		var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/D = new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(loc)
		D.reagents.add_reagent(product, 25)
		visible_message("<span class='notice'>[src] dispenses a drinking glass that's full of liquid.</span>")
		uses_left--
		if (uses_left < 1)
			spawn(cooldown_delay)
				uses_left = 12
	else if (victim)
		playsound(src, 'sound/items/vending.ogg', 50, 1, 1)
		var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/D = new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(loc)
		product = victim.take_blood(D,25)
		if(product != null)
			D.reagents.reagent_list += product
			D.reagents.update_total()
			D.on_reagent_change()
		else
			D.reagents.add_reagent("blood", 25)
		visible_message("<span class='notice'>[src] dispenses a drinking glass that's full of liquid.</span>")
		uses_left--
		if (uses_left < 1)
			spawn(cooldown_delay)
				uses_left = 12
	else
		visible_message("<span class='notice'>[src]'s OUT OF RANGE light flashes rapidly.</span>")



/obj/machinery/scp294/proc/find_reagent(input)
	. = FALSE
	if(chemical_reagents_list[input])
		var/datum/reagent/R = chemical_reagents_list[input]
		if(R)
			return R.id
	else
		input = replacetext(lowertext(input), " ", "")
		input = replacetext(input, "-", "")
		input = replacetext(input, "_", "")
		for(var/X in chemical_reagents_list)
			var/datum/reagent/R = chemical_reagents_list[X]
			if(R && input == replacetext(replacetext(replacetext(lowertext(R.name), " ", ""), "-", ""), "_", ""))
				return R.id
			else if(R && input == replacetext(replacetext(replacetext(lowertext(R.id), " ", ""), "-", ""), "_", ""))
				return R.id