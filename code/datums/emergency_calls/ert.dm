/datum/emergency_call/nt_ert
	name = "NT ERT"
	probability = 100

/datum/emergency_call/nt_ert/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>After leaving your [pick(75;"distant", 20;"close", 5;"ever-lovingly close")] [pick("family", "friends", "band of friends", "friend group", "relatives", "cousins")] [pick("behind", "behind in safety", "behind secretly", "behind regrettably")], you decided to join the ranks of a Nanotrasen private military contracting group.</b>")
	to_chat(H, "<B>Working there has proven to be [pick(50;"very", 20;"somewhat", 5;"astoundingly")] profitable for you.</b>")
	to_chat(H, "<B>While you are [pick("enlisted as", "officially", "part-time officially", "privately")] [pick("an employee", "a security officer", "an officer")], much of your work is off the books. You work as a skilled rapid-response contractor.</b>")
	to_chat(H, "")
	to_chat(H, "<B>Today, Nanotrasen station, [station_name], has sent out a distress signal. Your time is running short, get your shuttle launching!</b>")
	to_chat(H, "<B>Make sure the personnel with loalty implant is safe.</b>")
	to_chat(H, "<B>If there is no such personnel, eliminate the threat and ask for directives via fax.</b>")

/datum/emergency_call/nt_ert/create_member(mob/dead/observer/M)
	var/turf/spawn_loc = get_spawn_point()

	if(!istype(spawn_loc))
		return

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(spawn_loc)

	H.name = "[pick(first_names_male)] [pick(last_names)]"
	H.real_name = H.name

	H.mind = M.mind
	to_chat(world, "[H] is here")
	H.ckey = M.ckey
	to_chat(world, "Transfering [M.ckey] to [H]")

	if(M)
		qdel(M)

	print_backstory(H)

	if(!leader)
		leader = H
		H.equipOutfit(/datum/outfit/ert/leader)
		to_chat(H, "<span class='notice'>You are the leader of this Nanotrasen contractor team in responding to the distress signal sent out nearby. Address the situation and get your team to safety!</span>")
		return

	if(medics < max_medics)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/ert(src), SLOT_W_UNIFORM)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(src), SLOT_SHOES)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/swat(src), SLOT_GLOVES)
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(src), SLOT_GLASSES)
		to_chat(H, "<span class='notice'>You are a Nanotrasen medic assigned to this Nanotrasen contractor team to respond to the distress signal sent out nearby. Keep your squad alive in this fight!</span>")
		medics++
		return

	if(prob(40))
		H.equip_to_slot_or_del(new /obj/item/clothing/under/ert(src), SLOT_W_UNIFORM)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(src), SLOT_SHOES)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/swat(src), SLOT_GLOVES)
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(src), SLOT_GLASSES)
		to_chat(H, "<span class='notice'>You are a Nanotrasen point-man assigned to this team to respond to the distress signal sent out nearby. Be the avanguard of your squad!</span>")
		return

	if(prob(30))
		H.equip_to_slot_or_del(new /obj/item/clothing/under/ert(src), SLOT_W_UNIFORM)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(src), SLOT_SHOES)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/swat(src), SLOT_GLOVES)
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(src), SLOT_GLASSES)
		to_chat(H, "<span class='notice'>You are a Nanotrasen heavy sniper assigned to this team to respond to the distress signal sent out nearby. Support your squad with long ranged firepower!</span>")
		return

	if(prob(30))
		to_chat(H, "<span class='notice'>You are a Nanotrasen combat engineer assigned to this team to respond to the distress signal sent out nearby. Make a way to victory for your squad!</span>")
		return

	H.equip_to_slot_or_del(new /obj/item/clothing/under/ert(src), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(src), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/swat(src), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(src), SLOT_GLASSES)
	to_chat(H, "<span class='notice'>You are a Nanotrasen contractor assigned to this team to respond to the TGMC distress signal sent out nearby. Assist your team and protect NT's interests whenever possible!</span>")
