/obj/structure/vilage
	name = ""
	desc = ""
	icon = 'icons/obj/Events/human/vilage.dmi'
	anchored = TRUE
	layer = 11
	density = 1

/obj/structure/vilage/anvil
	icon_state = "anvil"
	name = "Наковальня"
	desc = "Куй железо, пока горячо"

/obj/structure/vilage/fence
	icon_state = "fence"
	name = "Забор"
	desc = "Огораживает"

/obj/structure/vilage/pillar
	icon = 'icons/obj/Events/pillar.dmi'
	icon_state = "pillar_1"
	name = "Колонна"
	desc = "Стоит"

/obj/structure/vilage/pillar/blue
	icon_state = "pillar_2"

/obj/structure/vilage/sett
	name = "Брусчатка"
	icon = 'icons/obj/Events/sett.dmi'
	icon_state = "sett"
	density = 0
	layer = 1
	anchored = TRUE

/obj/structure/sign/poster/banner
	icon = 'icons/obj/Events/human/vilage.dmi'
	icon_state = "banner"
	name = "Знамя"
	desc = "Знамя этого надела"

/obj/structure/vilage/velikiy_sup
	icon_state = "velikiy_sup"
	name = "Котел"
	desc = "О великий суп наварили.."
	density = 1
	anchored = FALSE
	var/on = FALSE
	var/obj/item/frying = null
	var/fry_time = 0.0


/obj/structure/vilage/velikiy_sup/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/deepfryholder))
		to_chat(user, "<span class='notice'>Уже сварено.</span>")
		return

	if (ishuman(user) && !(I.flags & DROPDEL))
		to_chat(user, "<span class='notice'>Ты сунул [I] в [src].</span>")
		on = TRUE
		frying = I
		user.drop_from_inventory(frying, src)

/obj/structure/vilage/velikiy_sup/process()
	..()
	if(frying)
		fry_time++
		if(fry_time == 30)
			playsound(src, 'sound/effects/water_turf_exited_mob.ogg', VOL_EFFECTS_MASTER)
			visible_message("[src] Бульк!")
		else if (fry_time == 60)
			visible_message("[src] Пиздато получается")

/obj/structure/vilage/velikiy_sup/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(frying)
		to_chat(user, "<span class='notice'>Вы достали [frying] из [src].</span>")
		var/obj/item/weapon/reagent_containers/food/snacks/deepfryholder/S = new(loc)
		switch(fry_time)
			if(0 to 15)
				S.color = rgb(166,103,54)
				S.name = "Легкая варка [frying.name]"
			if(16 to 49)
				S.color = rgb(103,63,24)
				S.name = "Нормально сваренно [frying.name]"
			if(50 to 59)
				S.color = rgb(63, 23, 4)
				S.name = "[frying.name] в крутую"
			if(60 to INFINITY)
				S.color = rgb(33,19,9)
				S.name = "Теперь сами жри это"
				S.desc = "Сваришь так-же флаг героя - дам ачивку и бан"
		S.appearance = frying.appearance
		S.desc = frying.desc
		qdel(frying)
		user.put_in_hands(S)
		frying = null
		on = FALSE
		fry_time = 0

/obj/machinery/seed_extractor/vilage
	name = "Место изъятия семян"
	desc = "Удобные пакетики - бонус"
	icon = 'icons/obj/Events/human/vilage.dmi'
	icon_state = "seed"
	use_power = NO_POWER_USE
	seed_multiplier = 2

/obj/machinery/processor/vilage
	name = "Переламыватель"
	desc = "На ручной тяге"
	icon = 'icons/obj/Events/human/vilage.dmi'
	icon_state = "processor"
	use_power = NO_POWER_USE

/obj/machinery/kitchen_machine/microwave/vilage
	name = "Микроволновый казан"
	desc = "А что такое микроволны?"
	icon = 'icons/obj/Events/human/vilage.dmi'
	icon_state = "microwave"
	off_icon = "microwave"
	on_icon = "microwave_procces"
	open_icon = "ready"
	use_power = NO_POWER_USE

/obj/machinery/kitchen_machine/oven/vilage
	name = "Печка"
	desc = "С вытяжкой!"
	icon = 'icons/obj/Events/human/vilage.dmi'
	icon_state = "oven"
	off_icon = "oven"
	on_icon = "oven_on"
	open_icon = "oven_on"
	use_power = NO_POWER_USE

/obj/machinery/kitchen_machine/grill/vilage
	name = "Костер"
	desc = "Маленький, специально для готовки"
	icon = 'icons/obj/Events/human/vilage.dmi'
	icon_state = "grill"
	off_icon = "grill"
	on_icon = "grill_on"
	open_icon = "grill_on"
	use_power = NO_POWER_USE

/obj/machinery/reagentgrinder/vilage
	name = "Ступка"
	desc = "Для получения реагентов"
	icon = 'icons/obj/Events/human/vilage.dmi'
	icon_state = "reagent_grinder1"
	use_power = NO_POWER_USE

/obj/machinery/reagentgrinder/vilage/update_icon()
	icon_state = "reagent_grinder"+num2text(!isnull(beaker))
	return


/obj/structure/tree_of_greed
	name = "Таки древо Мудрости"
	desc = "Оно готово ответить тебе на вопросы, <span class='warning'> небесплатно...</span>"
	anchored = TRUE
	layer = 11
	icon = 'icons/obj/flora/tree_of_greed.dmi'
	icon_state = "tree_of_greed"
	pixel_x = -48
	pixel_y = -20
	density = 1

/obj/structure/tree_of_greed/attack_hand(mob/living/carbon/human/user)
	var/question = sanitize(input(user, "Задайте вопрос древу."))
	for(var/client/X in global.admins)
		to_chat_admin_pm(X,"<span class='adminsay'><span class='prefix'>TREE QUESTION:</span> <EM>[key_name(usr, 1)]</EM> (<a href='?_src_=holder;adminplayerobservejump=\ref[user]'>JMP</A>): <span class='message emojify linkify'>[question]</span></span>")
