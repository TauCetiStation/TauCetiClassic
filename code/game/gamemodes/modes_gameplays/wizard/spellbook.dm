#define CONTRACT_PRICE 5

/datum/spellbook_entry
	var/name = "Entry Name"

	var/spell_type = null
	var/desc = ""
	var/category = "Нападение"
	var/log_name = "XX" //What it shows up as in logs
	var/cost = 2
	var/refundable = 1
	var/surplus = -1 // -1 for infinite, not used by anything atm
	var/obj/effect/proc_holder/spell/S = null //Since spellbooks can be used by only one person anyway we can track the actual spell
	var/buy_word = "Выучить"

/datum/spellbook_entry/proc/IsAvailible() // For config prefs / gamemode restrictions - these are round applied
	return TRUE

/datum/spellbook_entry/proc/RecordPurchase(mob/living/carbon/human/user, obj/item/weapon/spellbook/book)
	var/datum/stat/book_purchase/stat = new
	stat.power_type = spell_type
	stat.power_name = name
	stat.cost = cost
	var/datum/role/wizard/wiz_role = user.mind.GetRole(WIZARD)
	if(wiz_role)
		wiz_role.list_of_purchases += stat

/datum/spellbook_entry/proc/EraseEntry(mob/living/carbon/human/user, obj/item/weapon/spellbook/book)
	var/datum/role/wizard/wiz_role = user.mind.GetRole(WIZARD)
	if(wiz_role)
		for(var/datum/stat/book_purchase/stat in wiz_role.list_of_purchases)
			if(stat.power_type == spell_type)
				wiz_role.list_of_purchases -= stat

/datum/spellbook_entry/proc/CanBuy(mob/living/carbon/human/user, obj/item/weapon/spellbook/book) // Specific circumstances
	if(book.uses < cost)
		return FALSE
	for(var/obj/effect/proc_holder/spell/spell in user.mind.spell_list)
		if(istype(spell, spell_type))
			return FALSE
	return TRUE

/datum/spellbook_entry/proc/Buy(mob/living/carbon/human/user, obj/item/weapon/spellbook/book) //return TRUE on success
	if(!S || QDELETED(S))
		S = new spell_type()
	feedback_add_details("wizard_spell_learned",log_name)
	RecordPurchase(user, book)
	user.AddSpell(S)
	to_chat(user, "<span class='notice'>Вы выучили [S.name].</span>")
	return TRUE

/datum/spellbook_entry/proc/CanRefund(mob/living/carbon/human/user, obj/item/weapon/spellbook/book)
	if(!refundable)
		return FALSE
	if(!S)
		S = new spell_type()
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name))
			return TRUE
	return FALSE

/datum/spellbook_entry/proc/Refund(mob/living/carbon/human/user, obj/item/weapon/spellbook/book) //return point value or -1 for failure
	if(!istype(get_area(user), /area/custom/wizard_station))
		to_chat(user, "<span class='warning'>Вернуть очки можно только в убежище.</span>")
		return -1
	if(!S)
		S = new spell_type()
	for(var/obj/effect/proc_holder/spell/aspell in user.spell_list)
		if(initial(S.name) == initial(aspell.name))
			user.RemoveSpell(aspell)
			EraseEntry(user, book)
			qdel(S)
			return cost
	return -1
/datum/spellbook_entry/proc/GetInfo()
	if(!S)
		S = new spell_type()
	var/dat =""
	dat += "<b>[initial(S.name)]</b>"
	if(S.charge_type == "recharge")
		dat += " Перезарядка: [S.charge_max / 10]"
	dat += " Стоимость: [cost]<br>"
	dat += "<i>[S.desc][desc]</i><br>"
	dat += "[S.clothes_req ? "Нужна магическая одежда" : "Можно колдовать без одежды"]<br>"
	return dat

/datum/spellbook_entry/fireball
	name = "Огненный шар"
	spell_type = /obj/effect/proc_holder/spell/in_hand/fireball
	log_name = "FB"

/datum/spellbook_entry/icebolt
	name = "Ледяная стрела"
	spell_type = /obj/effect/proc_holder/spell/in_hand/icebolt
	log_name = "IB"
	cost = 1 // because this spell does not deal much damage and only slows down

/datum/spellbook_entry/acid
	name = "Кислотный чих"
	spell_type = /obj/effect/proc_holder/spell/in_hand/acid
	log_name = "ACI"
	cost = 1

/datum/spellbook_entry/item/fireballstaff
	name = "Посох Огненных Шаров"
	item_path = /obj/item/weapon/gun/magic/fireball
	desc = "Старый посох, позволяет создавать огненные шары"
	cost = 5

/datum/spellbook_entry/res_touch
	name = "Воскрешение"
	spell_type = /obj/effect/proc_holder/spell/in_hand/res_touch
	log_name = "RT"
	category = "Оборона"
	cost = 1

/datum/spellbook_entry/heal_touch
	name = "Лечение"
	spell_type = /obj/effect/proc_holder/spell/in_hand/heal
	log_name = "HT"
	category = "Оборона"

/datum/spellbook_entry/carp
	name = "Призыв Карпа"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/carp
	log_name = "SC"
	category = "Оборона"
	cost = 2

/datum/spellbook_entry/magicm
	name = "Магическая ракета"
	spell_type = /obj/effect/proc_holder/spell/targeted/projectile/magic_missile
	log_name = "MM"
	category = "Оборона"

/datum/spellbook_entry/disabletech
	name = "Отключить технологию"
	spell_type = /obj/effect/proc_holder/spell/targeted/emplosion/disable_tech
	log_name = "DT"
	category = "Оборона"

/datum/spellbook_entry/repulse
	name = "Репульс"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/repulse
	log_name = "RP"
	category = "Оборона"

/datum/spellbook_entry/timestop
	name = "Остановка времени"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/timestop
	log_name = "TS"
	category = "Оборона"
	cost = 3

/datum/spellbook_entry/smoke
	name = "Дым"
	spell_type = /obj/effect/proc_holder/spell/targeted/smoke
	log_name = "SM"
	category = "Оборона"
	cost = 1

/datum/spellbook_entry/blind
	name = "Ослепление"
	spell_type = /obj/effect/proc_holder/spell/targeted/trigger/blind
	log_name = "BD"

/datum/spellbook_entry/mindswap
	name = "Обмен разумом"
	spell_type = /obj/effect/proc_holder/spell/targeted/mind_transfer
	log_name = "MT"
	category = "Мобильность"

/datum/spellbook_entry/forcewall
	name = "Магическая стена"
	spell_type = /obj/effect/proc_holder/spell/targeted/forcewall
	log_name = "FW"
	category = "Оборона"
	cost = 1

/datum/spellbook_entry/blink
	name = "Скачок"
	spell_type = /obj/effect/proc_holder/spell/targeted/turf_teleport/blink
	log_name = "BL"
	category = "Мобильность"

/datum/spellbook_entry/teleport
	name = "Телепорт"
	spell_type = /obj/effect/proc_holder/spell/targeted/area_teleport/teleport
	log_name = "TP"
	category = "Мобильность"

/datum/spellbook_entry/shapeshift
	name = "Перевёртыш"
	spell_type = /obj/effect/proc_holder/spell/no_target/shapeshift
	log_name = "FH"
	category = "Мобильность"

/datum/spellbook_entry/mutate
	name = "Мутация"
	spell_type = /obj/effect/proc_holder/spell/targeted/genetic/mutate
	log_name = "MU"

/datum/spellbook_entry/jaunt
	name = "Выход из тела"
	spell_type = /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/wizard
	log_name = "EJ"
	category = "Мобильность"

/datum/spellbook_entry/knock
	name = "Стук"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/knock
	log_name = "KN"
	category = "Мобильность"
	cost = 1

/datum/spellbook_entry/summonitem
	name = "Призвать предмет"
	spell_type = /obj/effect/proc_holder/spell/targeted/summonitem
	log_name = "IS"
	category = "Помощь"
	cost = 1

/datum/spellbook_entry/lightningbolt
	name = "Шаровая молния"
	spell_type = /obj/effect/proc_holder/spell/in_hand/tesla
	log_name = "LB"
	cost = 3

/datum/spellbook_entry/lightningbolt/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book) //return TRUE on success
	. = ..()
	user.tesla_ignore = TRUE

/datum/spellbook_entry/lightningbolt/Refund(mob/living/carbon/human/user, obj/item/weapon/spellbook/book)
	. = ..()
	if(.)
		user.tesla_ignore = FALSE

/datum/spellbook_entry/arcane_barrage
	name = "Чародейский обстрел"
	spell_type = /obj/effect/proc_holder/spell/in_hand/arcane_barrage
	log_name = "AB"
	cost = 3

/datum/spellbook_entry/barnyard
	name = "Скотоклятье"
	spell_type = /obj/effect/proc_holder/spell/targeted/barnyardcurse
	log_name = "BC"

/datum/spellbook_entry/gnomecurse
	name = "Гномий дар"
	spell_type = /obj/effect/proc_holder/spell/targeted/gnomecurse
	log_name = "GC"

/datum/spellbook_entry/lighting_shock
	name = "Электрический шок"
	spell_type = /obj/effect/proc_holder/spell/targeted/lighting_shock
	log_name = "LS"

/datum/spellbook_entry/charge
	name = "Заряд"
	spell_type = /obj/effect/proc_holder/spell/no_target/charge
	log_name = "CH"
	category = "Помощь"
	cost = 1

/datum/spellbook_entry/spacetime_dist
	name = "Искажение пространства-времени"
	spell_type = /obj/effect/proc_holder/spell/targeted/spacetime_dist
	log_name = "STD"
	category = "Оборона"
	cost = 1

/datum/spellbook_entry/the_traps
	name = "Ловушки!"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/the_traps
	log_name = "TT"
	category = "Нападение"

/datum/spellbook_entry/item
	name = "Купить предмет"
	refundable = 0
	buy_word = "Призвать"
	var/item_path= null

/datum/spellbook_entry/item/RecordPurchase(mob/living/carbon/human/user, obj/item/weapon/spellbook/book)
	var/datum/stat/book_purchase/stat = new
	stat.power_type = item_path
	stat.power_name = name
	stat.cost = cost
	var/datum/role/wizard/wiz_role = user.mind.GetRole(WIZARD)
	if(wiz_role)
		wiz_role.list_of_purchases += stat

/datum/spellbook_entry/item/EraseEntry(mob/living/carbon/human/user, obj/item/weapon/spellbook/book)
	var/datum/role/wizard/wiz_role = user.mind.GetRole(WIZARD)
	if(wiz_role)
		for(var/datum/stat/book_purchase/stat in wiz_role.list_of_purchases)
			if(stat.power_type == item_path)
				wiz_role.list_of_purchases -= stat

/datum/spellbook_entry/item/CanBuy(mob/living/carbon/human/user, obj/item/weapon/spellbook/book) // Specific circumstances
	. = ..()
	if(.)
		return surplus != 0

/datum/spellbook_entry/item/Buy(mob/living/carbon/human/user, obj/item/weapon/spellbook/book)
	if(surplus > 0)
		surplus = max(surplus - 1, 0)
	new item_path (get_turf(user))
	feedback_add_details("wizard_spell_learned", log_name)
	RecordPurchase(user, book)
	return TRUE

/datum/spellbook_entry/item/GetInfo()
	var/dat =""
	dat += "<b>[name]</b>"
	dat += " Стоимость: [cost]<br>"
	dat += "<i>[desc]</i><br>"
	if(surplus >= 0)
		dat += "[surplus] осталось.<br>"
	return dat

/* Commented because admins ban everyone who uses this staff... Somebody should rebalance this thing
/datum/spellbook_entry/item/staffchange
	name = "Staff of Change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	item_path = /obj/item/weapon/gun/magic/change
	log_name = "ST"
	cost = 4
*/

/datum/spellbook_entry/item/staffanimation
	name = "Посох анимации"
	desc = "Магический посох, стреляющий болтами энергии древних, которые оживляют неодушевленные предметы. Магия не затрагивает машины."
	item_path = /obj/item/weapon/gun/magic/animate
	log_name = "SA"
	category = "Помощь"
	cost = 3

/datum/spellbook_entry/item/staffdoor
	name = "Посох создания дверей"
	desc = "Специфичный посох, который может превращать твердые стены в двери. Полезно с заклинаниями телепорта. Не работает со стеклом."
	item_path = /obj/item/weapon/gun/magic/doorcreation
	log_name = "SD"
	category = "Мобильность"
	cost = 3

/datum/spellbook_entry/item/staffhealing
	name = "Посох лечения"
	desc = "Посох, способный лечить больных и оживлять мертвых."
	item_path = /obj/item/weapon/gun/magic/healing
	log_name = "SH"
	category = "Оборона"
	cost = 4

/datum/spellbook_entry/item/jakboots
	name = "Сапоги Быстроногого Джека"
	desc = "Ботинки, способные ускорять того, кто их носит."
	item_path = /obj/item/clothing/shoes/boots/work/jak
	log_name = "JB"
	category = "Мобильность"
	cost = 3

/datum/spellbook_entry/item/soulstones
	name = "Шесть осколков камня душ и заклинание ремесленника"
	desc = "Осколки камня душ это древний инструмент, способный захватить и содержать в себе душу. Заклинание ремесленника позволяет создать тело для захваченной души."
	item_path = /obj/item/weapon/storage/belt/soulstone/full
	log_name = "SS"
	category = "Помощь"

/datum/spellbook_entry/item/soulstones/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	. =..()
	if(.)
		user.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/construct(user))
	return .

/datum/spellbook_entry/item/necrostone
	name = "Камень некромантии"
	desc = "Камень некромантии позволяет оживить до трех мертвецов в виде скелетов, которыми вы можете командовать."
	item_path = /obj/item/device/necromantic_stone
	log_name = "NS"
	category = "Помощь"
	cost = 3

/datum/spellbook_entry/item/armor
	name = "Набор мастерской брони"
	desc = "Набор замечательной брони, которая позволит вам колдовать и защитит от опасности как в виде людей, так и в виде космоса."
	item_path = /obj/item/clothing/suit/space/rig/wizard
	log_name = "HS"
	category = "Оборона"

/datum/spellbook_entry/item/armor/Buy(mob/living/carbon/human/user,obj/item/weapon/spellbook/book)
	. = ..()
	if(.)
		new /obj/item/clothing/shoes/sandal(get_turf(user)) //In case they've lost them.
		new /obj/item/clothing/head/helmet/space/rig/wizard(get_turf(user))//To complete the outfit
		new /obj/item/clothing/gloves/combat/wizard(get_turf(user))//To complete the outfit COMPLETELY

/datum/spellbook_entry/item/tiara
	name = "Тиара защиты"
	desc = "Дорогостоящая корона из драгоценного металла, инкрустированная магическими кристаллами. Излучает защитную ауру, используя силу РаЗуМа!"
	item_path = /obj/item/clothing/head/wizard/amp/shielded
	log_name = "TZ"
	category = "Оборона"

/datum/spellbook_entry/item/contract
	name = "Контракт ученичества"
	desc = "Магический контракт, что связывает учителя и ученика."
	item_path = /obj/item/weapon/contract
	log_name = "CT"
	category = "Помощь"
	cost = CONTRACT_PRICE

/datum/spellbook_entry/item/contract/Buy(mob/living/carbon/human/user, obj/item/weapon/spellbook/book)
	var/obj/item/weapon/contract/contract = new(get_turf(user))
	contract.wizard = user.mind
	feedback_add_details("wizard_spell_learned",log_name)
	return TRUE

/datum/spellbook_entry/item/tophat
	name = "Шляпа Wabbajack"
	desc = "Магическая шляпа с собственным шляпным измерением."
	item_path = /obj/item/clothing/head/wizard/tophat
	log_name = "TH"
	category = "Помощь"
	refundable = FALSE
	cost = 1
	surplus = 1

/*datum/spellbook_entry/item/battlemage
	name = "Battlemage Armour"
	desc = "An ensorcelled suit of armour, protected by a powerful shield. The shield can completly negate sixteen attacks before being permanently depleted."
	item_path = /obj/item/clothing/suit/space/hardsuit/shielded/wizard
	log_name = "BM"
	limit = 1
	category = "Defensive"

/datum/spellbook_entry/item/battlemage_charge
	name = "Battlemage Armour Charges"
	desc = "A powerful defensive rune, it will grant eight additional charges to a suit of battlemage armour."
	item_path = /obj/item/wizard_armour_charge
	log_name = "AC"
	category = "Defensive"
	cost = 1*/

/datum/spellbook_entry/summon
	name = "Призвать посох"
	category = "Rituals"
	refundable = 0
	buy_word = "Cast"
	var/active = FALSE

/datum/spellbook_entry/summon/CanBuy(mob/living/carbon/human/user, obj/item/weapon/spellbook/book)
	return ..() && !active

/datum/spellbook_entry/summon/GetInfo()
	var/dat =""
	dat += "<b>[name]</b>"
	if(cost > 0)
		dat += " Стоимость: [cost]<br>"
	else
		dat += " Бесплатно<br>"
	dat += "<i>[desc]</i><br>"
	if(active)
		dat += "<b>Уже есть!</b><br>"
	return dat

/datum/spellbook_entry/summon/IsAvailible()
	return SSticker.mode // In case spellbook is placed on map

/obj/item/weapon/spellbook
	name = "spell book"
	desc = "An unearthly tome that glows with power."
	w_class = SIZE_TINY
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	var/uses = 10
	var/temp = null
	var/tab = null
	var/datum/mind/owner
	var/list/datum/spellbook_entry/entries = list()
	var/list/categories = list()

/obj/item/weapon/spellbook/examine(mob/user)
	..()
	if(owner)
		to_chat(user, "There is a small signature on the front cover: \"[owner]\".")
	else
		to_chat(user, "It appears to have no author.")

/obj/item/weapon/spellbook/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/weapon/spellbook/atom_init_late()
	var/entry_types = subtypesof(/datum/spellbook_entry) - /datum/spellbook_entry/item - /datum/spellbook_entry/summon
	for(var/T in entry_types)
		var/datum/spellbook_entry/E = new T
		if(E.IsAvailible())
			entries |= E
			categories |= E.category
		else
			qdel(E)
	tab = categories[1]

/obj/item/weapon/spellbook/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/contract))
		var/obj/item/weapon/contract/contract = I
		if(contract.uses != initial(contract.uses))
			to_chat(user, "<span class='warning'>Контракт был использован, Вы не можете вернуть очки!</span>")
		else
			to_chat(user, "<span class='notice'>Вы скормили контракт обратно книге. Очки возвращены.</span>")
			uses += CONTRACT_PRICE
			qdel(I)
		return FALSE
	return ..()

/obj/item/weapon/spellbook/proc/GetCategoryHeader(category)
	var/dat = ""
	switch(category)
		if("Нападение")
			dat += "Заклинания и предметы, направленные на разрушение.<BR><BR>"
			dat += "Предметы не привязаны к вам и могут быть украдены.<BR>"
			dat += "Также их нельзя вернуть после покупки.<BR>"
			dat += "Для заклинаний: Число после названия заклинания это время перезарядки.<BR>"
		if("Оборона")
			dat += "Заклинания, направленные на повышение вашей выживаемости или уменьшение выживаемости противника.<BR><BR>"
			dat += "Предметы не привязаны к вам и могут быть украдены.<BR>"
			dat += "Также их нельзя вернуть после покупки.<BR>"
			dat += "Для заклинаний: Число после названия заклинания это время перезарядки.<BR>"
		if("Мобильность")
			dat += "Заклинания и предметы, направленные на улучшение вашей способности перемещаться. Стоит попробовать хотя бы раз.<BR><BR>"
			dat += "Предметы не привязаны к вам и могут быть украдены.<BR>"
			dat += "Также их нельзя вернуть после покупки.<BR>"
			dat += "Для заклинаний: Число после названия заклинания это время перезарядки.<BR>"
		if("Помощь")
			dat += "Заклинания и предметы призывающие потусторонние силы для помощи вам или улучшения ваших способностей.<BR><BR>"
			dat += "Предметы не привязаны к вам и могут быть украдены.<BR>"
			dat += "Также их нельзя вернуть после покупки.<BR>"
			dat += "Для заклинаний: Число после названия заклинания это время перезарядки.<BR>"
	return dat

/obj/item/weapon/spellbook/proc/wrap(content)
	var/dat = ""
	dat +="<html><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'><title>Spellbook</title></head>"
	dat += {"
	<head>
		<style type="text/css">
      		body { font-size: 80%; font-family: 'Lucida Grande', Verdana, Arial, Sans-Serif; }
      		ul#tabs { list-style-type: none; margin: 30px 0 0 0; padding: 0 0 0.3em 0; }
      		ul#tabs li { display: inline; }
      		ul#tabs li a { color: #42454a; background-color: #dedbde; border: 1px solid #c9c3ba; border-bottom: none; padding: 0.3em; text-decoration: none; }
      		ul#tabs li a:hover { background-color: #f1f0ee; }
      		ul#tabs li a.selected { color: #000; background-color: #f1f0ee; font-weight: bold; padding: 0.7em 0.3em 0.38em 0.3em; }
      		div.tabContent { border: 1px solid #c9c3ba; padding: 0.5em; background-color: #f1f0ee; }
      		div.tabContent.hide { display: none; }
    	</style>
  	</head>
	"}
	dat += {"[content]</body></html>"}
	return dat

/obj/item/weapon/spellbook/attack_self(mob/user)
	if(!owner)
		to_chat(user, "<span class='notice'>Вы привязали книгу к себе.</span>")
		owner = user.mind
		return
	if(user.mind != owner)
		to_chat(user, "<span class='warning'>[name] не распознала вас как владельца и отказывается открываться!</span>")
		return
	user.set_machine(src)
	var/dat = ""

	dat += "<ul id=\"tabs\">"
	var/list/cat_dat = list()
	for(var/category in categories)
		cat_dat[category] = "<hr>"
		dat += "<li><a [tab==category?"class=selected":""] href='byond://?src=\ref[src];page=[category]'>[category]</a></li>"

	dat += "<li><a><b>Оставшиеся очки: [uses]</b></a></li>"
	dat += "</ul>"

	var/datum/spellbook_entry/E
	for(var/i = 1 to entries.len)
		var/spell_info = ""
		E = entries[i]
		spell_info += E.GetInfo()
		if(E.CanBuy(user,src))
			spell_info+= "<a href='byond://?src=\ref[src];buy=[i]'>[E.buy_word]</A><br>"
		else
			spell_info+= "<span>Нельзя [E.buy_word]</span><br>"
		if(E.CanRefund(user,src))
			spell_info+= "<a href='byond://?src=\ref[src];refund=[i]'>Вернуть</A><br>"
		spell_info += "<hr>"
		if(cat_dat[E.category])
			cat_dat[E.category] += spell_info

	for(var/category in categories)
		dat += "<div class=\"[tab==category?"tabContent":"tabContent hide"]\" id=\"[category]\">"
		dat += GetCategoryHeader(category)
		dat += cat_dat[category]
		dat += "</div>"

	user << browse(wrap(dat), "window=spellbook;size=700x500")
	onclose(user, "spellbook")
	return

/obj/item/weapon/spellbook/Topic(href, href_list)
	..()
	if(!ishuman(usr))
		return TRUE
	var/mob/living/carbon/human/H = usr

	if(H.incapacitated())
		return

	var/datum/spellbook_entry/E = null
	if(loc == H || (Adjacent(H) && isturf(loc)))
		H.set_machine(src)
		if(href_list["buy"])
			E = entries[text2num(href_list["buy"])]
			if(E && E.CanBuy(H,src))
				if(E.Buy(H,src))
					uses -= E.cost
		else if(href_list["refund"])
			E = entries[text2num(href_list["refund"])]
			if(E && E.refundable)
				var/result = E.Refund(H,src)
				if(result > 0)
					uses += result
		else if(href_list["page"])
			tab = sanitize(href_list["page"])
	attack_self(H)
