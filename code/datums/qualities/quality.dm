/datum/quality
	var/desc

	var/restriction

/datum/quality/proc/restriction_check(mob/living/carbon/human/H)
	return TRUE

/datum/quality/proc/add_effect(mob/living/carbon/human/H)
	return

/datum/quality/proc/add_post_effect(mob/living/carbon/human/H)
	return

/*
/datum/quality/cyborg
	desc = "Все твои конечности и органы были заменены протезами в результате недавнего несчастного случая."
	restriction = "Нет."

/datum/quality/cyborg/add_effect(mob/living/carbon/human/H)
	qdel(H.bodyparts_by_name[BP_L_LEG])
	qdel(H.bodyparts_by_name[BP_R_LEG])
	qdel(H.bodyparts_by_name[BP_L_ARM])
	qdel(H.bodyparts_by_name[BP_R_ARM])

	var/obj/item/organ/external/l_arm/robot/LA = new(null)
	LA.insert_organ(H)

	var/obj/item/organ/external/r_arm/robot/RA = new(null)
	RA.insert_organ(H)

	var/obj/item/organ/external/l_leg/robot/LL = new(null)
	LL.insert_organ(H)

	var/obj/item/organ/external/r_leg/robot/RL = new(null)
	RL.insert_organ(H)

	for(var/obj/item/organ/internal/IO in H.organs)
		IO.mechanize()

/datum/quality/loadsamoney
	desc = "У тебя целая КУЧА денег! Как бы их потратить?"
	restriction = "Нет."

/datum/quality/loadsamoney/add_post_effect(mob/living/carbon/human/H)
	to_chat(H, "<span class='notice'>В твоем кармане лежит кредитный чип с большим количеством кредитов. Внеси его в ближайшем банкомате.</span>")
	H.equip_to_slot_or_del(new /obj/item/weapon/spacecash/ewallet/roundstart_quality(H), SLOT_L_STORE)

/datum/quality/mute
	desc = "Так вышло, что языка у тебя больше нет."
	restriction = "Нет."

/datum/quality/mute/add_effect(mob/living/carbon/human/H)
	H.add_quirk(QUIRK_MUTE)

/datum/quality/wonder_doctor
	desc = "В качестве эксперимента, тебе выдали таблетку с экспериментальным препаратом, чем-то напоминающим тот самый Философский Камень."
	restriction = "Доктор, Парамедик, СМО."

/datum/quality/wonder_doctor/restriction_check(mob/living/carbon/human/H)
	if(H.mind.assigned_role == "Medical Doctor" || H.mind.assigned_role == "Chief Medical Officer" || H.mind.assigned_role == "Paramedic")
		return TRUE
	else
		return FALSE

/datum/quality/wonder_doctor/add_post_effect(mob/living/carbon/human/H)
	to_chat(H, "<span class='notice'>В твоем кармане лежит фиолетовая таблетка, которая способна излечить любые раны... как жаль, что в ней лишь одна единица вещества.</span>")
	H.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/pill/adminodrazine(H), SLOT_L_STORE)

/datum/quality/mutant
	desc = "Тебе не повезло облучиться по пути на работу."
	restriction = "Нет."

/datum/quality/mutant/add_effect(mob/living/carbon/human/H)
	if(prob(80))
		randmutb(H)
	else
		randmutg(H)
	domutcheck(H, null)

/datum/quality/frail
	desc = "Жизнь раба корпорации довела тебя до серьезной болезни. Здоровье существенно снижено."
	restriction = "Нет."

/datum/quality/frail/add_effect(mob/living/carbon/human/H)
	H.health = 50
	H.maxHealth = 50

/datum/quality/depression
	desc = "Ты в депрессии и чувствуешь себя уныло. Так и живём."
	restriction = "Нет."

/datum/quality/depression/add_effect(mob/living/carbon/human/H)
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "roundstart_depression", /datum/mood_event/depression)

/datum/quality/happiness
	desc = "Ты очень-очень счастлив! Жизнь прекрасна и люди на станции прекрасны!!!"
	restriction = "Нет."

/datum/quality/happiness/add_effect(mob/living/carbon/human/H)
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "roundstart_happiness", /datum/mood_event/happiness)

/datum/quality/prepared
	desc = "Ты задумал пролезть в какой-то отсек. Пришлось найти изоляционные перчатки."
	restriction = "Нет."

/datum/quality/prepared/add_effect(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), SLOT_L_STORE)

/datum/quality/prisoner
	desc = "Тебе не повезло попасть в бриг. Что же делать - сбегать или спокойно досиживать срок?"
	restriction = "Подопытный."

/datum/quality/prisoner/restriction_check(mob/living/carbon/human/H)
	if(H.mind.assigned_role == "Test Subject")
		return TRUE
	else
		return FALSE

/datum/quality/prisoner/add_effect(mob/living/carbon/human/H)
	var/spawnloc = pick(prisonerstart)
	H.forceMove(spawnloc)

/datum/quality/disguise
	desc = "С ЦК тебе прислали прикольную посылочку с лучшим в мире камуфляжем."
	restriction = "Клоун."

/datum/quality/disguise/restriction_check(mob/living/carbon/human/H)
	if(H.mind.assigned_role == "Clown")
		return TRUE
	else
		return FALSE

/datum/quality/disguise/add_effect(mob/living/carbon/human/H)
	to_chat(H, "<span class='notice'>Карта в твоих руках способна менять свой внешний вид и имя владельца, а одежда в коробке заменит целый гардероб.</span>")
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/syndie_kit/chameleon(H), SLOT_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/weapon/card/id/syndicate(H), SLOT_R_HAND)

/datum/quality/clumsy
	desc = "Ты - неуклюжий, криворукий дурачок. Лучше не трогать всякие опасные штуки!"
	restriction = "Все, кроме Клоуна."

/datum/quality/clumsy/restriction_check(mob/living/carbon/human/H)
	if(H.mind.assigned_role == "Clown")
		return FALSE
	else
		return TRUE

/datum/quality/clumsy/add_effect(mob/living/carbon/human/H)
	H.mutations.Add(CLUMSY)

/datum/quality/heavy_equipment
	desc = "По программе усиления СБ тебе была выдана экипировка получше."
	restriction = "Офицер СБ."

/datum/quality/heavy_equipment/restriction_check(mob/living/carbon/human/H)
	if(H.mind.assigned_role == "Security Officer")
		return TRUE
	else
		return FALSE

/datum/quality/heavy_equipment/add_effect(mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/suit/armor/vest/fullbody(H), SLOT_WEAR_SUIT)
	H.equip_or_collect(new /obj/item/clothing/gloves/combat(H), SLOT_GLOVES)
	H.equip_or_collect(new /obj/item/weapon/gun/projectile/automatic/l13(H), SLOT_S_STORE)
	H.equip_or_collect(new /obj/item/ammo_box/magazine/l13_38(H), SLOT_R_HAND)

/datum/quality/big_iron
	desc = "Эта станция слишком мала для тебя и преступности."
	restriction = "Детектив."

/datum/quality/big_iron/restriction_check(mob/living/carbon/human/H)
	if(H.mind.assigned_role == "Detective")
		return TRUE
	else
		return FALSE

/datum/quality/big_iron/add_effect(mob/living/carbon/human/H)
	if(prob(50))
		H.equip_or_collect(new /obj/item/clothing/suit/serifcoat(H), SLOT_WEAR_SUIT)
	else
		H.equip_or_collect(new /obj/item/clothing/suit/poncho(H), SLOT_WEAR_SUIT)
	H.equip_or_collect(new /obj/item/clothing/under/fluff/cowboy/brown(H), SLOT_W_UNIFORM)
	H.equip_or_collect(new /obj/item/clothing/head/western/cowboy(H), SLOT_HEAD)
	H.equip_or_collect(new /obj/item/clothing/shoes/western(H), SLOT_SHOES)
	H.equip_or_collect(new /obj/item/weapon/gun/projectile/revolver/peacemaker(H), SLOT_L_HAND)
	H.equip_or_collect(new /obj/item/ammo_box/c45rubber(H), SLOT_L_STORE)
	H.equip_or_collect(new /obj/item/ammo_box/c45rubber(H), SLOT_R_STORE)

/datum/quality/all_affairs
	desc = "У тебя полный доступ. Да начнётся расследование."
	restriction = "Агент Внутренних Дел."

/datum/quality/all_affairs/restriction_check(mob/living/carbon/human/H)
	if(H.mind.assigned_role == "Internal Affairs Agent")
		return TRUE
	else
		return FALSE

/datum/quality/all_affairs/add_post_effect(mob/living/carbon/human/H)
	to_chat(H, "<span class='notice'>На твоей карточке полный доступ, но необязательно показывать его перед персоналом - вдруг кто-то захочет отнять?</span>")
	var/obj/item/weapon/card/id/id = H.get_idcard()
	id.access = get_all_accesses()


/datum/quality/cultural_heritage
	desc = "Всё племя скинулось на то, чтобы заиметь тебе в космос крутой космический костюм. Лучше оправдать их надежды!"
	restriction = "Унатх."

/datum/quality/cultural_heritage/restriction_check(mob/living/carbon/human/H)
	if((H.species.name == UNATHI))
		return TRUE
	else
		return FALSE

/datum/quality/cultural_heritage/add_effect(mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/suit/space/unathi/breacher(H), SLOT_WEAR_SUIT)
	H.equip_or_collect(new /obj/item/clothing/head/helmet/space/unathi/breacher(H), SLOT_HEAD)

/datum/quality/sunglasses
	desc = "Крутые очки, чувак."
	restriction = "Нет."

/datum/quality/sunglasses/add_effect(mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/glasses/sunglasses(H), SLOT_GLASSES)

/datum/quality/hygiene
	desc = "Гигиена - это важно. Ты принёс из дома мыльце."
	restriction = "Нет."

/datum/quality/hygiene/add_post_effect(mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/weapon/soap(H), SLOT_R_STORE)

/datum/quality/vaccinated
	desc = "Привившись всеми известными человечеству вакцинами, ты стал полностью невосприимчив для любого вируса."
	restriction = "Нет."

/datum/quality/vaccinated/add_effect(mob/living/carbon/human/H)
	ADD_TRAIT(H, TRAIT_VACCINATED, QUALITY_TRAIT)
*/

/datum/quality/protector
	desc = "Помимо основной должности, Нанотрейзен наняли тебя для защиты конкретной персоны на станции. Лучше не подводить работодателя."
	restriction = "Нет."

/datum/quality/protector/add_effect(mob/living/carbon/human/H)
	create_and_setup_role(/datum/role/protector, H)