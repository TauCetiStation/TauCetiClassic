var/global/list/junkyard_bum_list = list()     //list of all bums placements

/obj/effect/landmark/junkyard_bum/New()
	junkyard_bum_list += src
	invisibility = 101

/mob/living/carbon/human/bum/New()
	..()
	generate_random_bum()

/mob/living/carbon/human/proc/generate_random_bum()
	var/obj/randomcatcher/CATCH = new /obj/randomcatcher(src)
	if(prob(80))
		equip_to_slot_or_del(CATCH.get_item(/obj/random/cloth/under), slot_w_uniform)
	if(prob(60))
		equip_to_slot_or_del(CATCH.get_item(/obj/random/cloth/shoes), slot_shoes)
	if(prob(30))
		equip_to_slot_or_del(CATCH.get_item(/obj/random/cloth/backpack), slot_back)
	if(prob(80))
		equip_to_slot_or_del(CATCH.get_item(/obj/random/cloth/gloves), slot_gloves)
	if(prob(30))
		equip_to_slot_or_del(CATCH.get_item(/obj/random/cloth/randomsuit), slot_wear_suit)
	if(prob(80))
		equip_to_slot_or_del(CATCH.get_item(/obj/random/misc/lightsource), slot_r_hand)
	if(prob(25))
		equip_to_slot_or_del(CATCH.get_item(/obj/random/cloth/randomhead), slot_head)
	equip_to_slot_or_del(new /obj/item/weapon/shovel(src), slot_l_hand)
	for(var/obj/item/loot in contents)
		loot.make_old()
	qdel(CATCH)
	gender = pick(MALE, FEMALE)
	if(gender == MALE)
		name = pick(first_names_male)
	else
		name = pick(first_names_female)
	name += " [pick(last_names)]"
	real_name = name
	var/datum/preferences/A = new()	//Randomize appearance for the human
	A.randomize_appearance_for(src)
	sight |= SEE_BLACKNESS
	update_inv_head()
	update_inv_wear_suit()
	update_inv_gloves()
	update_inv_shoes()
	update_inv_w_uniform()
	update_inv_r_hand()
	update_inv_l_hand()


/mob/dead/verb/become_bum()
	set name = "Become space bum"
	set category = "Ghost"
	var/mob/dead/observer/M = usr
	if(ticker.current_state < GAME_STATE_PLAYING)
		to_chat(src, "<span class='warning'> The game hasn't started yet!</span>")
		return
	if(!SSjunkyard.junkyard_initialised)
		to_chat(src, "<span class='warning'>Junkyard not loaded. No space hobos for you. Ask admins to load junkyard.</span>")
		return
	if(config.antag_hud_restricted && M.has_enabled_antagHUD == 1)
		to_chat(src, "<span class='warning'>antagHUD restrictions prevent you from spawning in as a bum.</span>")
		return
	if(client.time_joined_as_spacebum + 1200 >= world.time)
		to_chat(src, "<span class='warning'>You may only spawn as space bum once per 5 minutes. [1200 - world.time + client.time_joined_as_spacebum] seconds to respawn.</span>")
		return
	client.time_joined_as_spacebum = world.time
	var/response = alert(src, "Are you -sure- you want to become a space bum?","Are you sure you want to hobo?","Yeah!","Nope!")
	if(response != "Yeah!")
		return  //Hit the wrong key...again.

	make_bum()

/mob/proc/make_bum()
	var/obj/effect/landmark/location = pick(junkyard_bum_list)
	var/mob/living/carbon/human/bum/host = new /mob/living/carbon/human/bum(location.loc)
	host.ckey = src.ckey
	to_chat(host, "<span class='warning'>You are space bum now. Try to survive. Try to cooperate. Try to be friendly. Only remember: there are no rules!</span>")
	return host
