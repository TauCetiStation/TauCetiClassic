/datum/event/roundstart/forgotten_headset/start()
	for(var/mob/living/carbon/human/H in human_list)
		if((H.l_ear || H.r_ear) && prob(10))
			var/headset_to_del = H.l_ear ? H.l_ear : H.r_ear
			qdel(headset_to_del)

/datum/event/roundstart/forgotten_survbox/start()
	for(var/mob/living/carbon/human/H in human_list)
		if(!prob(10))
			continue
		var/list/boxs = H.get_all_contents_type(/obj/item/weapon/storage/box/survival)
		if(!boxs.len)
			continue
		for(var/box in boxs)
			qdel(box)

var/global/list/fueltank_list = list()
/datum/event/roundstart/forgotten_fueltank/start()
	for(var/fueltank in fueltank_list)
		qdel(fueltank)

var/global/list/watertank_list = list()
/datum/event/roundstart/forgotten_watertank/start()
	for(var/watertank in watertank_list)
		qdel(watertank)

var/global/list/cleaners_list = list()
/datum/event/roundstart/forgotten_cleaner/start()
	for(var/cleaner in cleaners_list)
		qdel(cleaner)
