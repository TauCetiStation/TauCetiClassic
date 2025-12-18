#define ASPECT_CATEGORY "Аспекты"
#define UNIQ_CATEGORY "Уникальные технологии"

/obj/structure/cult/tech_table
	name = "scientific altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "techaltar"
	light_color = "#2f0e0e"
	light_power = 2
	light_range = 3

	// string = image()
	var/static/list/tech_images = list()
	// string = /datum/religion_tech
	var/static/list/tech_by_id = list()
	// string = image()
	var/static/list/category_images = list()

	var/researching = FALSE
	var/research_time = 15 MINUTES
	var/end_research_time

	var/current_research = "Ничего"
	var/datum/religion_tech/chosen_tech
	var/tech_timer

	var/list/pylon_around

	var/datum/religion/religion

/obj/structure/cult/tech_table/Destroy()
	pylon_around = null
	if(tech_timer)
		deltimer(tech_timer)
	if(chosen_tech)
		chosen_tech.researching = FALSE
		chosen_tech = null
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

	if(tech_images.len < religion.available_techs.len)
		gen_tech_images(user)
	if(!category_images.len)
		gen_category_images()

	var/choice = show_radial_menu(user, src, category_images, tooltips = TRUE, require_near = TRUE)

	var/list/tech = list()
	var/list/user_tech_images = list()
	for(var/tech_id in tech_by_id)
		var/datum/religion_tech/RT = tech_by_id[tech_id]
		if(istype(RT, /datum/religion_tech/upgrade_aspect))
			var/datum/religion_tech/upgrade_aspect/aspect = RT
			aspect.calculate_costs(religion)

		var/tech_with_cost = "[RT.info.name] [RT.info.get_costs()]"
		if(choice == ASPECT_CATEGORY && istype(RT, /datum/religion_tech/upgrade_aspect))
			tech[tech_with_cost] = tech_id
			user_tech_images[tech_with_cost] = tech_images[tech_id]
		else if(choice == UNIQ_CATEGORY && istype(RT, /datum/religion_tech/cult))
			tech[tech_with_cost] = tech_id
			user_tech_images[tech_with_cost] = tech_images[tech_id]
	choose_tech(user, tech, user_tech_images)

// list/techs is (tech_name_with_cost = tech_id)
// list/user_techs_images is (tech_name_with_cost = tech_images)
/obj/structure/cult/tech_table/proc/choose_tech(mob/user, list/techs, list/user_techs_images)
	var/tech_name_with_cost = show_radial_menu(user, src, user_techs_images, tooltips = TRUE, require_near = TRUE)
	chosen_tech = tech_by_id[techs[tech_name_with_cost]]
	if(!chosen_tech)
		return
	if(chosen_tech.researching)
		to_chat(user, "<span class='warning'>Уже изучается.</span>")
		return
	if(!religion.check_costs(chosen_tech.info.favor_cost, chosen_tech.info.piety_cost, user))
		return

	religion.adjust_favor(-chosen_tech.info.favor_cost)
	religion.adjust_piety(-chosen_tech.info.piety_cost)

	to_chat(user, "<span class='notice'>Вы начали изучение [chosen_tech.info.name].</span>")

	current_research = chosen_tech.info.name
	chosen_tech.researching = TRUE
	start_activity(CALLBACK(src, PROC_REF(research_tech), chosen_tech))

/obj/structure/cult/tech_table/proc/research_tech(datum/religion_tech/researched)
	religion.add_tech(researched)

	tech_by_id -= researched.id
	religion.available_techs -= researched
	qdel(tech_images[researched.id])
	tech_images -= researched.id

	end_activity()

/obj/structure/cult/tech_table/proc/gen_category_images()
	for(var/name in tech_images)
		var/is_aspect_tech = istype(tech_by_id[name], /datum/religion_tech/upgrade_aspect)
		if(!category_images[ASPECT_CATEGORY] && is_aspect_tech)
			var/image/old_image = tech_images[name]
			var/image/copy = image(old_image.icon, old_image.loc, old_image.icon_state)
			category_images[ASPECT_CATEGORY] = copy
		else if(!category_images[UNIQ_CATEGORY] && !is_aspect_tech)
			var/image/old_image = tech_images[name]
			var/image/copy = image(old_image.icon, old_image.loc, old_image.icon_state)
			category_images[UNIQ_CATEGORY] = copy
		if(category_images[UNIQ_CATEGORY] && category_images[ASPECT_CATEGORY])
			break

/obj/structure/cult/tech_table/proc/gen_tech_images(mob/user)
	tech_images = list()
	tech_by_id = list()
	for(var/datum/religion_tech/T in religion.available_techs)
		tech_images[T.id] = image(icon = T.info.icon, icon_state = T.info.icon_state)
		tech_by_id[T.id] = T
	sortTim(tech_by_id, GLOBAL_PROC_REF(cmp_text_asc))

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

#undef ASPECT_CATEGORY
#undef UNIQ_CATEGORY
