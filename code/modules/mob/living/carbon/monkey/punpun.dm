/mob/living/carbon/monkey/punpun //except for a few special persistence features, pun pun is just a normal monkey
	name = "Pun Pun" //C A N O N
	icon_state = "punpun1"
	var/ancestor_name
	var/ancestor_chain = 1
	var/relic_hat	//Note: these two are paths
	var/relic_mask
	var/memory_saved = 0
	var/list/pet_monkey_names = list("Pun Pun", "Bubbles", "Mojo", "George", "Darwin", "Aldo", "Caeser", "Kanzi", "Kong", "Terk", "Grodd", "Mala", "Bojangles", "Coco", "Able", "Baker", "Scatter", "Norbit", "Travis")
	var/list/rare_pet_monkey_names = list("Professor Bobo", "Deempisi's Revenge", "Furious George", "King Louie", "Dr. Zaius", "Jimmy Rustles", "Dinner", "Lanky")
	holder_type = /obj/item/weapon/holder/monkey/punpun

/mob/living/carbon/monkey/punpun/atom_init()
	Read_Memory()
	if(relic_mask)
		equip_to_slot_or_del(new relic_mask, SLOT_WEAR_MASK)
	if(ancestor_name)
		name = ancestor_name
		if(ancestor_chain > 1)
			name += " [num2roman(ancestor_chain)]"
	else
		if(prob(5))
			name = pick(rare_pet_monkey_names)
		else
			name = pick(pet_monkey_names)
		gender = pick(MALE, FEMALE)
	. = ..()

/mob/living/carbon/monkey/punpun/Life()
	if(ticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory(0)
	..()

/mob/living/carbon/monkey/punpun/death(gibbed)
	if(!memory_saved || gibbed)
		Write_Memory(1,gibbed)
	..()

/mob/living/carbon/monkey/punpun/proc/Read_Memory()
	var/savefile/S = new /savefile("data/npc_saves/Punpun.sav")
	S["ancestor_name"] 		>> ancestor_name
	S["ancestor_chain"]		>> ancestor_chain
	S["relic_mask"]			>> relic_mask

/mob/living/carbon/monkey/punpun/proc/Write_Memory(dead, gibbed)
	var/savefile/S = new /savefile("data/npc_saves/Punpun.sav")
	if(gibbed)
		S["ancestor_name"] 		<< null
		S["ancestor_chain"]		<< 1
		S["relic_mask"]			<< null
		return
	if(dead)
		S["ancestor_name"] 		<< ancestor_name
		S["ancestor_chain"]		<< ancestor_chain + 1
	if(!ancestor_name)	//new monkey name this round
		S["ancestor_name"] 		<< name
	if(wear_mask)
		S["relic_mask"]			<< wear_mask.type
	else
		S["relic_mask"]			<< null
	if(!dead)
		memory_saved = 1
