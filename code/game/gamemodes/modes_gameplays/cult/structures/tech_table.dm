/obj/structure/cult/tech_table
	name = "scientific altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "techaltar"
	light_color = "#2f0e0e"
	light_power = 2
	light_range = 3

	// /datum/aspect = image
	// Maybe be wrapped too in /datum/building_agent
	var/static/list/aspect_images = list()
	// /datum/building_agent = image
	var/static/list/uniq_images = list()
	// string = image
	var/static/list/category_images = list()

	var/researching = FALSE
	var/research_time = 15 MINUTES
	var/end_research_time

	var/current_research = "Ничего"
	var/datum/building_agent/tech/choosed_tech
	var/tech_timer

	var/list/pylon_around

	var/datum/religion/religion

/obj/structure/cult/tech_table/Destroy()
	pylon_around = null
	if(tech_timer)
		deltimer(tech_timer)
	if(choosed_tech)
		choosed_tech.researching = FALSE
		choosed_tech = null
	return ..()

/obj/structure/cult/tech_table/examine(mob/user, distance)
	..()
	if(!religion)
		return
	if(isliving(user)) // for ghosts
		if(!user.mind?.holy_role || !religion || religion.aspects.len == 0)
			return

	to_chat(user, "<span class='notice'>Текущее исследование: [current_research].</span>")
	to_chat(user, "<span class='notice'>Аспекты и их сила в [religion.name]:</span>")
	for(var/name in religion.aspects)
		var/datum/aspect/A = religion.aspects[name]
		to_chat(user, "\t<font color='[A.color]'>[name]</font> с силой <font size='[1+A.power]'><i>[A.power]</i></font>")

/obj/structure/cult/tech_table/attack_hand(mob/user)
	if(!user.mind.holy_role || !user.my_religion)
		return

	if(!religion)
		religion = user.my_religion

	if(religion.aspects.len == 0)
		to_chat(user, "<span class='warning'>Сначала выберите аспекты.</span>")
		return

	if(researching)
		to_chat(user, "<span class='warning'>Осталось [round((end_research_time - world.time) * 0.1)] секунд до конца исследования.</span>")
		return

	var/datum/religion/cult/R = religion
	if(R)
		if(R.research_forbidden && !iseminence(user))
			to_chat(user, "<span class='warning'>По решению Возвышенного последователям запрещено самим исследовать!</span>")
			return

	if(!aspect_images.len)
		gen_aspect_images()
	if(uniq_images.len < religion.available_techs.len)
		gen_tech_images(user)
	if(!category_images.len)
		gen_category_images()

	var/choice = show_radial_menu(user, src, category_images, tooltips = TRUE, require_near = TRUE)

	switch(choice)
		if("Аспекты")
			choose_aspect(user)
		if("Уникальные технологии")
			choose_uniq_tech(user)

/obj/structure/cult/tech_table/proc/choose_uniq_tech(mob/user)
	for(var/datum/building_agent/B in uniq_images)
		B.name = "[initial(B.name)] [B.get_costs()]"

	choosed_tech = show_radial_menu(user, src, uniq_images, tooltips = TRUE, require_near = TRUE)
	if(!choosed_tech || choosed_tech.researching)
		return
	if(!religion.check_costs(choosed_tech.favor_cost, choosed_tech.piety_cost, user))
		return

	religion.adjust_favor(-choosed_tech.favor_cost)
	religion.adjust_piety(-choosed_tech.piety_cost)

	to_chat(user, "<span class='notice'>Вы начали изучение [initial(choosed_tech.name)].</span>")

	current_research = initial(choosed_tech.name)
	choosed_tech.researching = TRUE
	start_activity(CALLBACK(src, PROC_REF(research_tech), choosed_tech))

/obj/structure/cult/tech_table/proc/research_tech(datum/building_agent/tech/choosed_tech)
	religion.add_tech(choosed_tech.building_type)

	uniq_images -= choosed_tech
	religion.available_techs -= choosed_tech
	qdel(uniq_images[choosed_tech])

	end_activity()

/obj/structure/cult/tech_table/proc/choose_aspect(mob/user)
	// Generates a name with the power of an aspect and upgrade cost
	for(var/datum/aspect/A in aspect_images)
		var/datum/aspect/in_religion = religion.aspects[initial(A.name)]
		A.name = "[initial(A.name)], сила: [in_religion ? in_religion.power : "0"], piety: [get_upgrade_cost(in_religion)]"

	var/datum/aspect/choosed_aspect = show_radial_menu(user, src, aspect_images, tooltips = TRUE, require_near = TRUE)
	if(!choosed_aspect)
		return
	var/datum/aspect/in_religion = religion.aspects[initial(choosed_aspect.name)]
	if(!religion.check_costs(null, get_upgrade_cost(in_religion), user))
		return

	religion.adjust_piety(-get_upgrade_cost(in_religion))

	to_chat(user, "<span class='notice'>Вы начали [in_religion ? "улучшение" : "изучение"] [initial(choosed_aspect.name)].</span>")
	current_research = "[in_religion ? "улучшение" : "изучение"] [initial(choosed_aspect.name)]"
	start_activity(CALLBACK(src, PROC_REF(upgrade_aspect), choosed_aspect))

/obj/structure/cult/tech_table/proc/upgrade_aspect(datum/aspect/aspect_to_upgrade)
	if(initial(aspect_to_upgrade.name) in religion)
		var/datum/aspect/A = religion.aspects[initial(aspect_to_upgrade.name)]
		A.power += 1
	else
		religion.add_aspects(list(aspect_to_upgrade.type = 1))

	end_activity()

/obj/structure/cult/tech_table/proc/get_upgrade_cost(datum/aspect/in_religion)
	if(!in_religion)
		var/all_aspects = 0
		for(var/aspect_name in cult_religion.aspects)
			all_aspects++
		var/cost = max(100, 50 + 25 * all_aspects) //We don't count 6 initial aspects and scale for static 150, +50 piety for each new aspect
		return cost
	return in_religion.power * 50

/obj/structure/cult/tech_table/proc/gen_category_images()
	category_images = list(
		"Аспекты" = aspect_images[pick(aspect_images)],
		"Уникальные технологии" = uniq_images[pick(uniq_images)],
	)

/obj/structure/cult/tech_table/proc/gen_tech_images(mob/user)
	uniq_images = list()
	for(var/datum/building_agent/tech/BA in religion.available_techs)
		uniq_images[BA] = image(icon = BA.icon, icon_state = BA.icon_state)

/obj/structure/cult/tech_table/proc/gen_aspect_images()
	var/list/aspects = subtypesof(/datum/aspect)
	aspect_images = list()
	for(var/type in aspects)
		var/datum/aspect/A = new type
		if(!A.name)
			qdel(A)
			continue
		aspect_images[A] = image(icon = A.icon, icon_state = A.icon_state)

/obj/structure/cult/tech_table/proc/start_activity(datum/callback/end_activity)
	LAZYINITLIST(pylon_around)
	for(var/obj/structure/cult/pylon/P in oview(3))
		if(!P.anchored)
			continue
		new /obj/effect/temp_visual/cult/sparks(P.loc)
		pylon_around += P
		P.icon_state = "pylon_glow"
		P.can_unwrench = FALSE
	researching = TRUE
	var/time_reduce = 2.2*sqrt(pylon_around.len)MINUTE //https://www.desmos.com/Calculator/acwqntgi7v 1 pylon = 2 mins, 4 pyls = 4 mins, 10=7, 45=15
	end_research_time = max(1, world.time + research_time - time_reduce)
	can_unwrench = FALSE
	tech_timer = addtimer(end_activity, research_time - time_reduce, TIMER_STOPPABLE)

/obj/structure/cult/tech_table/proc/end_activity()
	researching = FALSE
	for(var/obj/structure/cult/pylon/P in pylon_around)
		pylon_around -= P
		P.icon_state = "pylon"
		P.can_unwrench = TRUE

	current_research = "Ничего"
	can_unwrench = TRUE
