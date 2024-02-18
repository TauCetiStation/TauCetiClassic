/datum/objective/download_telecommunications_data
	explanation_text = "Скачайте важную информацию с телекоммуникационного узла на выданную вам дискету."
	required_equipment = /obj/item/weapon/disk/telecomms

/datum/objective/download_telecommunications_data/check_completion()
	var/list/items = owner.current.GetAllContents()
	for(var/obj/item/i in items)
		if(istype(i, required_equipment))
			var/obj/item/weapon/disk/telecomms/disk = i
			if(disk.have_data == TRUE)
				return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/obj/item/weapon/disk/telecomms
	name = "Suspicious Disk"
	cases = list("подозрительно выглядящая дискета", "подозрительно выглядящей дискеты", "подозрительно выглядящей дискете", "подозрительно выглядящую дискету", "подозрительно выглядящей дискетой"), "подозрительно выглядящей дискете"
	desc = "Печально известная и исключительно нелегальная модель дискеты, такие часто используются корпоративными шпионами для кражи данных."
	origin_tech = "magnets=5;programming=5;syndicate=3"
	icon_state = "syndidisk"
	item_state = "card-id"
	w_class = SIZE_TINY
	var/have_data = FALSE

/obj/item/weapon/disk/telecomms/examine(mob/user)
	..()
	if(have_data == TRUE)
		to_chat(user, "<span class='notice'>Память дискеты заполнена.</span>")
