/datum/role/space_trader
	name = SPACE_TRADER
	id = SPACE_TRADER

	disallow_job = TRUE
	logo_state = "space_traders"
	var/datum/outfit/outfit
	var/money = 100
	var/greet = "<span class='notice'><b>Вы - космический торговец.</b></span>"

/datum/role/space_trader/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, greet)

/datum/role/space_trader/OnPostSetup(laterole)
	. = ..()
	var/mob/living/carbon/human/H = antag.current

	H.equipOutfit(outfit)

	var/datum/money_account/MA = create_random_account_and_store_in_mind(H, money)
	var/obj/item/weapon/card/id/cargo/C = new(H)
	C.rank = "Space Trader"
	C.assignment = C.rank
	C.assign(H.real_name)
	C.access = list(access_space_traders)
	C.associated_account_number = MA.account_number
	H.equip_or_collect(C, SLOT_WEAR_ID)

	var/obj/item/device/pda/pda = new(H)
	pda.assign(H.real_name)
	pda.ownrank = C.rank
	pda.owner_account = MA.account_number
	pda.owner_fingerprints += C.fingerprint_hash
	MA.owner_PDA = pda
	H.equip_or_collect(pda, SLOT_R_STORE)

/datum/role/space_trader/dealer
	skillset_type = /datum/skillset/quartermaster
	outfit = /datum/outfit/space_trader/dealer
	money = 500
	greet = {"<span class='notice'><b>Вы - барыга, владеющий торговым судном и товаром на нём.
Вместе с вами на корабле находятся ваши работники - охранник и грузчик.
У вас есть 4 минуты чтобы разложить товар по прилавку и витринам, после чего вы сможете отправиться на станцию.
В вашем трюме могут находится не вполне законные вещи, для их сокрытия от службы безопасности в трюме есть тайник.
Тайник находится в углу, ближайшем к носу корабля, справа от постера. Он вмонтирован в стену и открыть его можете только вы.
Ваша первая общая цель - заработок, но что же делать если товар уже распродан, а денег не хватает?
Попробуйте найти этим двум оболтусам работёнку на станции. Она может быть и не вполне законной, но кого это волнует, когда за это платят деньги.
Ваша вторая общая цель - добыча определённых предметов на станции. Вы можете действовать как хотите.
Попробуете ли вы выкупить нужную вещь, выкрасть, или подрядить на это дело кого-то на станции, это не важно.
Важно лишь чтобы цель была в вашем трюме в конце смены.
Не забывайте что вы не одни, а цели общие. Действуйте сообща с вашими работниками.
------------------</b></span>"}

/datum/role/space_trader/guard
	skillset_type = /datum/skillset/officer
	outfit = /datum/outfit/space_trader/guard
	money = 200
	greet = {"<span class='notice'><b>Вы - ЧОПовец, нанятый для охраны.
Охранять вам нужно всё, корабль, товар на нём и конечно же вашего нанимателя барыгу.
У вас есть пушка и вы можете свободно использовать её, но только на территории корабля.
Выходя на станцию, не забывайте, что вы на ней гость, не стоит по поводу и без размахивать стволом, лишнее внимание от службы безопасности вам ни к чему.
Так или иначе у вас есть общие цели, так что не оставайтесь в стороне, может и для вас найтись работа.
Не забывайте что вы не одни, а цели общие. Действуйте сообща с барыгой и грузчиком.
------------------</b></span>"}

/datum/role/space_trader/porter
	skillset_type = /datum/skillset/cargotech
	outfit = /datum/outfit/space_trader/porter
	money = 20
	greet = {"<span class='notice'><b>Вы - грузчик, нанятый барыгой.
Таскайте грузы, выставляйте товары на продажу, помогите барыге обогатиться и не забудьте спросить свою долю!
У вас есть 4 минуты чтобы помочь барыге разложить товар по прилавку и витринам, после чего вы сможете отправиться на станцию.
Кроме того у вас есть общие цели, не оставайтесь в стороне и окажите команде посильную помощь в их выполнении.
Не забывайте что вы не одни, а цели общие. Действуйте сообща с барыгой и охранником.
------------------</b></span>"}
