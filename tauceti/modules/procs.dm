//mob - who is being feed
//user - who is feeding
//food - whai is feeded
//eatverb - take/drink/eat method
proc/CanEat(user, mob, food, eatverb = "consume")
	if(ishuman(mob))
		var/mob/living/carbon/human/Feeded = mob
		if(Feeded.head)
			var/obj/item/Head = Feeded.head
			if(Head.flags & HEADCOVERSMOUTH)
				if (Feeded == user)
					user<<"You can't [eatverb] [food] through [Head]"
				else
					user<<"You can't feed [Feeded] with [food] through [Head]"
				return 0
		if(Feeded.wear_mask)
			var/obj/item/Mask = Feeded.wear_mask
			if(Mask.flags & MASKCOVERSMOUTH)
				if (Feeded == user)
					user<<"You can't [eatverb] [food] through [Mask]"
				else
					user<<"You can't feed [Feeded] with [food] through [Mask]"
				return 0
		return 1

/proc/random_color()
	var/list/rand = list("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f")
	return "#" + pick(rand) + pick(rand) + pick(rand) + pick(rand) + pick(rand) + pick(rand)

//for chalkboard
/proc/count_occurrences(string, substring)
	var/count = 0
	var/found = 0
	var/length = length(substring)

	found = findtext(string, substring)

	while(found)
		count++
		found += length
		found = findtext(string, substring, found)

	return count

//from /tg, for cards
/mob/proc/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_l_hand)
			return l_hand
		if(slot_r_hand)
			return r_hand
	return null


/proc/noob_notify(var/mob/M)
	//todo: check db before
	if(!M.client)
		return
	if(M.client.holder)
		return
	if(!isnum(M.client.player_age))
		for(var/client/C in clients)
			if(C.holder)
				C << "<span class=\"admin\"><span class=\"prefix\">New player notify:</span> <span class=\"message\">[M.ckey] join to the game as [M.mind.name] [M.mind.assigned_role ? "([M.mind.assigned_role])" : ""] - <a href='http://www.byond.com/members/[M.ckey]'>Byond Profile</a> (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.x];Y=[M.y];Z=[M.z]'>JMP</a>)</span></span>"

				if(R_ADMIN & C.holder.rights)
					C << "<span class=\"admin\"><span class=\"prefix\">New player notify:</span> <span class=\"message\">[M.ckey] ip: [M.lastKnownIP]</span></span>"