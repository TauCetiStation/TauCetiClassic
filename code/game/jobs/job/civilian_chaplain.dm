//Due to how large this one is it gets its own file
/datum/job/chaplain
	title = "Chaplain"
	flag = CHAPLAIN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_morgue, access_chapel_office, access_crematorium)
	salary = 40
	alt_titles = list("Counselor")
	minimal_player_ingame_minutes = 480
	outfit = /datum/outfit/job/chaplain

/datum/job/chaplain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!visualsOnly && H.mind)
		H.mind.holy_role = HOLY_ROLE_HIGHPRIEST
		INVOKE_ASYNC(global.chaplain_religion, /datum/religion/chaplain.proc/create_by_chaplain, H)
