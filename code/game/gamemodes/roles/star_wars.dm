
// JEDI

/datum/role/star_wars/jedi_leader
	name = "Jedi Leader"
	id = JEDI_LEADER
	logo_state = "jedi_logo"
	disallow_job = TRUE

	antag_hud_type = ANTAG_HUD_JEDI
	antag_hud_name = "hud_jedi"

	skillset_type = /datum/skillset/max
	moveset_type = /datum/combat_moveset/cqc

/datum/role/star_wars/jedi_leader/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>Вы - Мастер Джедаев.
На станции был обнаружен артефакт, дарующий людям Силу, ваша задача - совместно с учёными выяснить детали его работы,
а также обучить людей, попавших под воздействие артефакта, использовать приобретённую Силу.

Сила может быть обнаружена с помощью одного из ваших навыков, при использовании он подсветит людей, обладающих силой.
С помощью другого навыка вы можете предложить человеку перейти на светлую её сторону.
(При конверте, снаряжение джедая будет выдано ученику автоматически).

Ваше главное оружие - высокопарные речи и конечно же световой меч, которым не стоит пренебрегать.
Навык владения им позволит вам гарантированно блокировать до 8 ударов в ближнем бою. Вы можете увидеть шанс заблокировать удар, осмотрев ваш меч.
С каждым блокированием атаки это значение будет уменьшаться на 20. Значение медленно восстанавливается по 1% в секунду.
Да пребудет с тобой Сила...
------------------</b></span>"})

/datum/role/star_wars/jedi_leader/OnPostSetup()
	. = ..()

	var/mob/living/carbon/human/H = antag.current
	var/datum/faction/star_wars/jedi/F = faction

	F.force_source.force_users += H
	H.equipOutfit(/datum/outfit/star_wars/jedi)

	var/datum/action/innate/A
	for(var/V in subtypesof(/datum/action/innate/star_wars/jedi))
		A = new V (H)
		A.Grant(H)

	H.AddSpell(new /obj/effect/proc_holder/spell/in_hand/heal/star_wars)
	H.AddSpell(new /obj/effect/proc_holder/spell/targeted/summonitem/star_wars)

/datum/role/star_wars/jedi
	name = "Jedi"
	id = JEDI
	logo_state = "jedi_logo"

	antag_hud_type = ANTAG_HUD_JEDI
	antag_hud_name = "hud_jedi"

	skillset_type = /datum/skillset/willpower
	moveset_type = /datum/combat_moveset/cqc

/datum/role/star_wars/jedi/OnPostSetup()
	. = ..()

	var/mob/living/carbon/C = antag.current
	var/datum/faction/star_wars/jedi/F = faction

	H.AddSpell(new /obj/effect/proc_holder/spell/targeted/summonitem/star_wars)

	if(ishuman(C))
		var/mob/living/carbon/human/H = C

		H.equip_or_collect(new /obj/item/weapon/melee/energy/sword/star_wars/jedi(H), SLOT_IN_BACKPACK)
		H.equip_or_collect(new /obj/item/clothing/shoes/star_wars/jedi(H), SLOT_IN_BACKPACK)
		H.equip_or_collect(new /obj/item/clothing/under/star_wars/jedi(H), SLOT_IN_BACKPACK)
		H.equip_or_collect(new /obj/item/clothing/suit/hooded/star_wars/jedi(H), SLOT_IN_BACKPACK)

/datum/role/star_wars/jedi/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>Вы - ученик Джедая.
Ваша задача - помогать своим мастерам и защищать их.

Ваше главное оружие - высокопарные речи и конечно же световой меч, которым не стоит пренебрегать.
Навык владения им позволит вам гарантированно блокировать до 6 ударов в ближнем бою. Вы можете увидеть шанс заблокировать удар, осмотрев ваш меч.
С каждым блокированием атаки это значение будет уменьшаться на 20. Значение медленно восстанавливается по 1% в секунду.
Да пребудет с тобой Сила...
------------------</b></span>"})

// SITH

/datum/role/star_wars/sith_leader
	name = "Sith Leader"
	id = SITH_LEADER
	logo_state = "sith_logo"

	restricted_jobs = list("Security Cadet", "Security Officer", "Warden", "AI", "Cyborg", "Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Internal Affairs Agent", "Blueshield Officer")

	antag_hud_type = ANTAG_HUD_SITH
	antag_hud_name = "hud_sith"

	skillset_type = /datum/skillset/max
	moveset_type = /datum/combat_moveset/cqc

/datum/role/star_wars/sith_leader/OnPostSetup()
	. = ..()

	var/mob/living/carbon/human/H = antag.current
	var/datum/faction/star_wars/sith/F = faction

	F.force_source.force_users += H

	var/datum/action/innate/A
	for(var/V in subtypesof(/datum/action/innate/star_wars/sith))
		A = new V (H)
		A.Grant(H)

	H.AddSpell(new /obj/effect/proc_holder/spell/targeted/summonitem/star_wars)
	H.AddSpell(new /obj/effect/proc_holder/spell/in_hand/tesla/star_wars)

	H.equip_or_collect(new /obj/item/weapon/melee/energy/sword/star_wars/sith/master(H), SLOT_IN_BACKPACK)
	H.equip_or_collect(new /obj/item/clothing/shoes/star_wars/sith(H), SLOT_IN_BACKPACK)
	H.equip_or_collect(new /obj/item/clothing/under/star_wars/sith(H), SLOT_IN_BACKPACK)
	H.equip_or_collect(new /obj/item/clothing/suit/hooded/star_wars/sith(H), SLOT_IN_BACKPACK)
	H.equip_or_collect(new /obj/item/device/holocomm/sith(H), SLOT_IN_BACKPACK)


/datum/role/star_wars/sith_leader/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>Вы - Мастер Ситхов.
На этой станции был обнаружен артефакт, дарующий людям Силу. Вы, и ещё один мастер-ситх, смогли внедриться сюда в качестве работников.
Ваша задача - поиск людей, способных к Силе, и скрытное склонение их разума на тёмную сторону, для последующего захвата артефакта и власти.

Для поиска у вас есть первый навык, при использовании он напишет в чат обладает ли цель Силой.
Для добровольного конверта используйте второй навык, его использование предложит цели перейти на тёмную сторону силы.
Учтите, что цель может отказаться и выдать вас.
Для конверта против воли, используйте третий навык - промывку мозгов.
С его помощью вы можете принудительно обратить человека, обладающего силой, на тёмную сторону.
При использовании на простом смертном вы сможете отдать ему короткий приказ, который тот будет ОБЯЗАН исполнить и ЗАБЫТЬ о произошедшем.
Промывку мозгов можно использовать на расстоянии одной клетки, используйте это для получения каких-либо преимуществ.

При конверте, всё снаряжение ситха будет выдано ученику автоматически.
Все эти навыки требуют при использовании кликнуть на того, с кем необходимо произвести действие.
Все ваши навыки, кроме второго, абсолютно беспалевны и вы можете свободно использовать их, не боясь что вас обнаружат.
Артефакт выдаёт Силу периодически, поэтому регулярно ищите её у всех окружающих.
Человек не имевший Силу ранее, в следующую же минуту может заполучить её и даже этого не понять.

Ваше главное оружие - световой меч, которым не стоит пренебрегать.
Навык владения им позволит вам гарантированно блокировать до 8 ударов в ближнем бою. Вы можете увидеть шанс заблокировать удар, осмотрев ваш меч.
С каждым блокированием атаки это значение будет уменьшаться на 20. Значение медленно восстанавливается по 1% в секунду.

Сила есть закон.
------------------</b></span>"})

/datum/role/star_wars/sith
	name = "Sith"
	id = SITH
	logo_state = "sith_logo"

	antag_hud_type = ANTAG_HUD_SITH
	antag_hud_name = "hud_sith"

	skillset_type = /datum/skillset/willpower
	moveset_type = /datum/combat_moveset/cqc

/datum/role/star_wars/sith/OnPostSetup()
	. = ..()

	var/mob/living/carbon/C = antag.current
	var/datum/faction/star_wars/sith/F = faction

	H.AddSpell(new /obj/effect/proc_holder/spell/targeted/summonitem/star_wars)

	if(ishuman(C))
		var/mob/living/carbon/human/H = C

		H.equip_or_collect(new /obj/item/weapon/melee/energy/sword/star_wars/sith(H), SLOT_IN_BACKPACK)
		H.equip_or_collect(new /obj/item/clothing/shoes/star_wars/sith(H), SLOT_IN_BACKPACK)
		H.equip_or_collect(new /obj/item/clothing/under/star_wars/sith(H), SLOT_IN_BACKPACK)
		H.equip_or_collect(new /obj/item/clothing/suit/hooded/star_wars/sith(H), SLOT_IN_BACKPACK)

/datum/role/star_wars/sith/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>Вы - ученик Ситха.
Ваша задача - помогать Мастеру и защищать его.
Ситхи пробрались на станцию скрытно, поэтому вам не нужно без необходимости и приказа Мастера выдавать свои способности.

Ваше главное оружие - световой меч, которым не стоит пренебрегать.
Навык владения им позволит вам гарантированно блокировать до 6 ударов в ближнем бою. Вы можете увидеть шанс заблокировать удар, осмотрев ваш меч.
С каждым блокированием атаки это значение будет уменьшаться на 20. Значение медленно восстанавливается по 1% в секунду.
------------------</b></span>"})
