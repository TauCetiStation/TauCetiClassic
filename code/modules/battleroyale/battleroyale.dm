var/list/battreroyale_players = list()
var/list/battreroyale_landmarks = list()

/proc/battleroyal_init()
	for(var/mob/living/carbon/human/H in player_list)
		for (var/obj/O in H.contents)
			if(istype(O, /obj/item/weapon/br_ticket))
				battreroyale_players[H] = O
				continue

	if(battreroyale_players.len < 1)
		to_chat(world, "<span class='info bold italic'>Not enough people for battle royale, skipping show...</span>")
		return
	
	to_chat(world, "<span class='info bold italic'>And it's Battle Royale time!!</span>")
	ticker.restart_timeout += 1200//+2 min

	for(var/mob/living/carbon/human/H in battreroyale_players)
		var/turf/T = pick(battreroyale_landmarks)
		var/obj/item/weapon/br_ticket/ticket = battreroyale_players[H]
		to_chat(H, "<span class='info bold italic'>BR preparing: [ticket.role]</span>")

		if(ticket.role == "Observer")
			var/mob/temp_mob = H.ghostize(FALSE, FALSE)
			temp_mob.loc = T
			continue

		H.revive()

		if(ticket.role == "Budget")
			for(var/obj/item/W in H)
				H.drop_from_inventory(W)

		H.loc = T

		if(ticket.role == "VIP")
			var/obj/item/weapon/gun/energy/pulse_rifle/priffle = new
			H.put_in_hands(priffle)

		if(ticket.role == "Donator")
			var/obj/item/toy/prize/durand/durand = new
			H.put_in_hands(durand)

/obj/effect/landmark/br_start
	name = "br_start"

/obj/effect/landmark/br_start/atom_init()
	. = ..()
	battreroyale_landmarks += loc