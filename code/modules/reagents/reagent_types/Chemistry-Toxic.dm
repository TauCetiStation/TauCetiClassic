/datum/reagent/toxin
	name = "Токсин"
	id = "toxin"
	description = "Токсинчый химикат."
	reagent_state = LIQUID
	color = "#cf3600" // rgb: 207, 54, 0
	var/toxpwr = 0.7 // Toxins are really weak, but without being treated, last very long.
	custom_metabolism = 0.1
	taste_message = "горечь"
	flags = list(IS_ORGANIC = TRUE)

	// Most toxins use "ticks" to determine their effect. The list is initialized here to be used there later.
	data = list()

/datum/reagent/toxin/on_general_digest(mob/living/M)
	..()
	if(toxpwr)
		M.adjustToxLoss(toxpwr * REM)

/datum/reagent/toxin/on_skrell_digest(mob/living/M)
	..()
	return !flags[IS_ORGANIC]

/datum/reagent/toxin/amatoxin
	name = "Аматоксин"
	id = "amatoxin"
	description = "Сильный яд, получаемый из некоторых видов грибов."
	reagent_state = LIQUID
	color = "#792300" // rgb: 121, 35, 0
	toxpwr = 1
	flags = list(IS_ORGANIC = TRUE)

/datum/reagent/toxin/mutagen
	name = "Нестабильный мутаген"
	id = "mutagen"
	description = "Может вызвать непредсказуемые мутации. Держать подальше от детей."
	reagent_state = LIQUID
	color = "#13bc5e" // rgb: 19, 188, 94
	toxpwr = 0
	flags = list()

/datum/reagent/toxin/mutagen/reaction_mob(mob/living/carbon/M, method=TOUCH, volume)
	if(!..())
		return
	if(!istype(M) || !M.dna)
		return  //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	src = null
	if((method==TOUCH && prob(33)) || method==INGEST)
		randmuti(M)
		if(prob(98))
			randmutb(M)
		else
			randmutg(M)
		domutcheck(M, null)
		M.UpdateAppearance()

/datum/reagent/toxin/mutagen/on_general_digest(mob/living/M)
	..()
	M.apply_effect(10, IRRADIATE, 0)

/datum/reagent/toxin/phoron
	name = "Форон"
	id = "phoron"
	description = "Жидкий форон."
	reagent_state = LIQUID
	color = "#ef0097" // rgb: 231, 27, 0
	toxpwr = 3
	flags = list()

/datum/reagent/toxin/phoron/on_general_digest(mob/living/M)
	..()
	if(holder.has_reagent("inaprovaline"))
		holder.remove_reagent("inaprovaline", 2 * REM)

/datum/reagent/toxin/phoron/reaction_obj(obj/O, volume)
	src = null
	if((!O) || (!volume))
		return FALSE
	if(volume < 0)
		return FALSE
	if(volume > 300)
		return FALSE

	var/turf/simulated/T = get_turf(O)
	if(!istype(T))
		return
	T.assume_gas("phoron", volume, T20C)

/datum/reagent/toxin/phoron/reaction_turf(turf/simulated/T, volume)
	. = ..()
	if(volume < 0)
		return
	if(volume > 300)
		return

	if(!istype(T))
		return
	T.assume_gas("phoron", volume, T20C)

/datum/reagent/toxin/phoron/reaction_mob(mob/living/M, method=TOUCH, volume)//Splashing people with plasma is stronger than fuel!
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		M.adjust_fire_stacks(volume / 5)

/datum/reagent/toxin/lexorin
	name = "Лексорин"
	id = "lexorin"
	description = "Временно останавливает дыхание. Вызывает повреждение тканей."
	reagent_state = LIQUID
	color = "#c8a5dc" // rgb: 200, 165, 220
	toxpwr = 0
	overdose = REAGENTS_OVERDOSE
	restrict_species = list(IPC, DIONA)
	flags = list()

/datum/reagent/toxin/lexorin/on_general_digest(mob/living/M)
	..()
	if(prob(33))
		M.take_bodypart_damage(1 * REM, 0)
	M.adjustOxyLoss(3)
	if(prob(20))
		M.emote("gasp")

/datum/reagent/toxin/slimejelly
	name = "Слизневый джем"
	id = "slimejelly"
	description = "Липкая полужидкость, полученная из одной из самых смертоносных форм жизни из существующих. ТАК ПРАВДОПОДОБНО."
	reagent_state = LIQUID
	color = "#801e28" // rgb: 128, 30, 40
	toxpwr = 0
	flags = list(IS_ORGANIC = TRUE)

/datum/reagent/toxin/slimejelly/on_general_digest(mob/living/M)
	..()
	if(prob(10))
		to_chat(M, "<span class='warning'>Ваши внутренности горят!</span>")
		M.adjustToxLoss(rand(20,60) * REM)
	else if(prob(40))
		M.heal_bodypart_damage(5 * REM, 0)

/datum/reagent/toxin/cyanide //Fast and Lethal
	name = "Цианид"
	id = "cyanide"
	description = "Сильно токсичное химическое вещество."
	reagent_state = LIQUID
	color = "#cf3600" // rgb: 207, 54, 0
	toxpwr = 4
	custom_metabolism = 0.4
	restrict_species = list(IPC, DIONA)
	flags = list()

/datum/reagent/toxin/cyanide/on_general_digest(mob/living/M)
	..()
	M.adjustOxyLoss(4 * REM)
	if(!data["ticks"])
		data["ticks"] = 1
	data["ticks"]++
	switch(data["ticks"])
		if(1 to 5)
			M.throw_alert("oxy", /obj/screen/alert/oxy)
		if(6 to INFINITY)
			M.SetSleeping(20 SECONDS)
			M.throw_alert("oxy", /obj/screen/alert/oxy)
	if(data["ticks"] % 3 == 0)
		M.emote("gasp")

/datum/reagent/toxin/minttoxin
	name = "Мятный Токсин"
	id = "minttoxin"
	description = "Полезно при работы с нежелательными клиентами."
	reagent_state = LIQUID
	color = "#cf3600" // rgb: 207, 54, 0
	toxpwr = 0
	flags = list(IS_ORGANIC = TRUE)

/datum/reagent/toxin/minttoxin/on_general_digest(mob/living/M)
	..()
	if(HAS_TRAIT(M, TRAIT_FAT))
		M.gib()

/datum/reagent/toxin/carpotoxin
	name = "Карпотоксин"
	id = "carpotoxin"
	description = "Смертельный нейротоксин, вырабатываемый ужасным космическим карпом."
	reagent_state = LIQUID
	color = "#003333" // rgb: 0, 51, 51
	toxpwr = 2
	flags = list(IS_ORGANIC = TRUE)

/datum/reagent/toxin/zombiepowder
	name = "Зомби-порошок"
	id = "zombiepowder"
	description = "Сильный нейротоксин, который вводит субъекта в состояние, подобное смерти."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	toxpwr = 0.5
	restrict_species = list(IPC, DIONA)

/datum/reagent/toxin/zombiepowder/on_general_digest(mob/living/M)
	..()
	M.status_flags |= FAKEDEATH
	M.adjustOxyLoss(0.5 * REM)
	M.Weaken(10)
	M.silent = max(M.silent, 10)
	M.tod = worldtime2text()

/datum/reagent/toxin/zombiepowder/Destroy()
	if(holder && ismob(holder.my_atom))
		var/mob/M = holder.my_atom
		M.status_flags &= ~FAKEDEATH
	return ..()

/datum/reagent/toxin/mindbreaker
	name = "ЛСД" // на самом деле это не лсд, but who cares
	id = "mindbreaker"
	description = "Мощный галлюциноген."
	reagent_state = LIQUID
	color = "#b31008" // rgb: 139, 166, 233
	toxpwr = 0
	custom_metabolism = 0.05
	overdose = REAGENTS_OVERDOSE
	flags = list()

/datum/reagent/toxin/mindbreaker/on_general_digest(mob/living/M)
	..()
	M.hallucination += 10

/datum/reagent/toxin/plantbgone
	name = "Plant-B-Gone"
	id = "plantbgone"
	description = "Опасный токсичный гербицид. Не употреблять в пищу!"
	reagent_state = LIQUID
	color = "#49002e" // rgb: 73, 0, 46
	toxpwr = 1
	flags = list()

// Clear off wallrot fungi
/datum/reagent/toxin/plantbgone/reaction_turf(turf/T, volume)
	. = ..()
	if(istype(T, /turf/simulated/wall))
		var/turf/simulated/wall/W = T
		if(W.rotting)
			W.rotting = 0
			for(var/obj/effect/E in W)
				if(E.name == "Wallrot")
					qdel(E)

			W.visible_message("<span class='notice'>Грибы полностью растворены жидкостью!</span>")

/datum/reagent/toxin/plantbgone/reaction_obj(obj/O, volume)
	if(istype(O,/obj/structure/alien/weeds))
		var/obj/structure/alien/weeds/alien_weeds = O
		alien_weeds.health -= rand(15,35) // Kills alien weeds pretty fast
		alien_weeds.healthcheck()
	else if(istype(O,/obj/effect/glowshroom)) //even a small amount is enough to kill it
		qdel(O)
	else if(istype(O,/obj/effect/spacevine))
		if(prob(50))
			del(O) //Kills kudzu too.
	// Damage that is done to growing plants is separately at code/game/machinery/hydroponics at obj/item/hydroponics

/datum/reagent/toxin/plantbgone/reaction_mob(mob/living/M, method=TOUCH, volume)
	src = null
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(!C.wear_mask) // If not wearing a mask
			C.adjustToxLoss(2) // 4 toxic damage per application, doubled for some reason ~~(What could possible double it, if the toxpwr = 1 :hmm: :thinking:)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.dna)
					if(H.species.flags[IS_PLANT]) //plantmen take a LOT of damage
						H.adjustToxLoss(50)

/datum/reagent/toxin/stoxin
	name = "Снотворное"
	id = "stoxin"
	description = "Эффективное снотворное для лечения бессонницы."
	reagent_state = LIQUID
	color = "#e895cc" // rgb: 232, 149, 204
	toxpwr = 0
	custom_metabolism = 0.1
	overdose = REAGENTS_OVERDOSE
	restrict_species = list(IPC, DIONA)
	flags = list()

/datum/reagent/toxin/stoxin/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1
	switch(data["ticks"])
		if(1 to 12)
			if(prob(5))
				M.emote("yawn")
		if(12 to 15)
			M.eye_blurry = max(M.eye_blurry, 10)
		if(15 to 49)
			if(prob(50))
				M.Weaken(2)
			M.drowsyness  = max(M.drowsyness, 20)
		if(50 to INFINITY)
			M.Weaken(20)
			M.drowsyness  = max(M.drowsyness, 30)
	data["ticks"]++

/datum/reagent/toxin/chloralhydrate
	name = "Хлоральгидрат"
	id = "chloralhydrate"
	description = "Сильное успокаивающее средство."
	reagent_state = SOLID
	color = "#000067" // rgb: 0, 0, 103
	toxpwr = 0
	custom_metabolism = 0.1 //Default 0.2
	overdose = 15
	overdose_dam = 6
	restrict_species = list(IPC, DIONA)
	flags = list()

/datum/reagent/toxin/chloralhydrate/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1
	data["ticks"]++
	switch(data["ticks"])
		if(1)
			M.confused += 2
			M.drowsyness += 2
		if(2 to 199)
			M.Weaken(30)
		if(200 to INFINITY)
			M.SetSleeping(20 SECONDS)

/datum/reagent/toxin/potassium_chloride
	name = "Хлористый калий"
	id = "potassium_chloride"
	description = "Восхитительная соль, которая останавливает сердце при введении в сердечную мышцу."
	reagent_state = SOLID
	color = "#ffffff" // rgb: 255,255,255
	toxpwr = 0
	overdose = 30
	flags = list()

/datum/reagent/toxin/potassium_chloride/on_general_digest(mob/living/M)
	..()
	if(M.stat != UNCONSCIOUS)
		if(volume >= overdose)
			if(M.losebreath >= 10)
				M.losebreath = max(10, M.losebreath - 10)
			M.adjustOxyLoss(2)
			M.Weaken(10)

/datum/reagent/toxin/potassium_chlorophoride
	name = "Хлорофорид Калия" // хлор + форон = хлорофорид
	id = "potassium_chlorophoride"
	description = "Специальное химическое вещество на основе хлорида калия, останавливающее сердце для проведения операций. Не употреблять в пищу!"
	reagent_state = SOLID
	color = "#ffffff" // rgb: 255,255,255
	toxpwr = 2
	overdose = 20
	flags = list()

/datum/reagent/toxin/potassium_chlorophoride/on_general_digest(mob/living/M)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.stat != UNCONSCIOUS)
			if(H.losebreath >= 10)
				H.losebreath = max(10, M.losebreath - 10)
			H.adjustOxyLoss(2)
			H.Weaken(10)

/datum/reagent/toxin/beer2	//disguised as normal beer for use by emagged brobots
	name = "Пиво"
	id = "beer2"
	description = "Алкогольный напиток, приготовленный из солодовых зерен, хмеля, дрожжей и воды. Процесс ферментации не завершён." //If the players manage to analyze this, they deserve to know something is wrong.
	reagent_state = LIQUID
	color = "#fbbf0d" // rgb: 251, 191, 13
	custom_metabolism = 0.15 // Sleep toxins should always be consumed pretty fast
	overdose = REAGENTS_OVERDOSE * 0.5
	restrict_species = list(IPC, DIONA)

/datum/reagent/toxin/beer2/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1
	switch(data["ticks"])
		if(1)
			M.confused += 2
			M.drowsyness += 2
		if(2 to 50)
			M.SetSleeping(20 SECONDS)
		if(51 to INFINITY)
			M.SetSleeping(20 SECONDS)
			M.adjustToxLoss((data["ticks"] - 50) * REM)
	data["ticks"]++

/datum/reagent/toxin/mutetoxin //the new zombie powder. @ TG Port
	name = "Заглушающий токсин"
	id = "mutetoxin"
	description = "Токсин, временно парализующий голосовые связки."
	color = "#f0f8ff" // rgb: 240, 248, 255
	custom_metabolism = 0.4
	toxpwr = 0
	flags = list()

/datum/reagent/toxin/mutetoxin/on_general_digest(mob/living/M)
	..()
	M.silent = max(M.silent, 3)

/datum/reagent/toxin/acid
	name = "Серная кислота"
	id = "sacid"
	description = "Очень агрессивная минеральная кислота с молекулярной формулой H2SO4."
	reagent_state = LIQUID
	color = "#db5008" // rgb: 219, 80, 8
	toxpwr = 1
	var/meltprob = 10
	flags = list()

/datum/reagent/toxin/acid/on_general_digest(mob/living/M)
	..()
	M.take_bodypart_damage(0, 1 * REM)

/datum/reagent/toxin/acid/reaction_mob(mob/living/M, method=TOUCH, volume)//magic numbers everywhere
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.head)
				if(prob(meltprob) && !H.head.unacidable)
					to_chat(H, "<span class='danger'>Ваш головной убор тает, но защищает вас от кислоты!</span>")
					qdel(H.head)
					H.update_inv_head()
					H.update_hair()
				else
					to_chat(H, "<span class='warning'>Ваш головной убор защищает вас от кислоты.</span>")
				return

			if(H.wear_mask)
				if(prob(meltprob) && !H.wear_mask.unacidable)
					to_chat(H, "<span class='danger'>Ваша маска тает, но защищает вас от кислоты!</span>")
					qdel(H.wear_mask)
					H.update_inv_wear_mask()
					H.update_hair()
				else
					to_chat(H, "<span class='warning'>Ваша маска защищает вас от кислоты.</span>")
				return

			if(H.glasses) //Doesn't protect you from the acid but can melt anyways!
				if(prob(meltprob) && !H.glasses.unacidable)
					to_chat(H, "<span class='danger'>Ваши очки тают!</span>")
					qdel(H.glasses)
					H.update_inv_glasses()

		else if(ismonkey(M))
			var/mob/living/carbon/monkey/MK = M
			if(MK.wear_mask)
				if(!MK.wear_mask.unacidable)
					to_chat(MK, "<span class='danger'>Ваша маска тает, но защищает вас от кислоты!</span>")
					qdel(MK.wear_mask)
					MK.update_inv_wear_mask()
				else
					to_chat(MK, "<span class='warning'>Ваша маска защищает вас от кислоты.</span>")
				return

		if(!M.unacidable)
			if(ishuman(M) && volume >= 10)
				var/mob/living/carbon/human/H = M
				var/obj/item/organ/external/head/BP = H.bodyparts_by_name[BP_HEAD]
				if(BP)
					BP.take_damage(4 * toxpwr, 2 * toxpwr)
					if(prob(meltprob)) //Applies disfigurement
						H.emote("scream")
						BP.disfigured = TRUE
			else
				M.take_bodypart_damage(min(6 * toxpwr, volume * toxpwr)) // uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
	else
		if(!M.unacidable)
			M.take_bodypart_damage(min(6 * toxpwr, volume * toxpwr))

/datum/reagent/toxin/acid/reaction_obj(obj/O, volume)
	if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)) && prob(meltprob * 3))
		if(!O.unacidable)
			var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
			I.desc = "Кажется, когда-то это было [O]" // был была было
			for(var/mob/M in viewers(5, O))
				to_chat(M, "<span class='warning'>[O] тает.</span>")
			qdel(O)

/datum/reagent/toxin/acid/polyacid
	name = "Политриновая кислота"
	id = "pacid"
	description = "Чрезвычайно агрессивное химическое вещество."
	reagent_state = LIQUID
	color = "#8e18a9" // rgb: 142, 24, 169
	toxpwr = 2
	meltprob = 30
	flags = list()

//////////////////////////////////////////////
//////////////New poisons///////////////////// // TODO: Make them a subtype of /toxin/
//////////////////////////////////////////////

/datum/reagent/alphaamanitin
	name = "Альфа-аманитин"
	id = "alphaamanitin"
	description = "Смертельный быстро разлагающийся токсин, получаемый из некоторых видов грибов."
	color = "#792300" //rgb: 121, 35, 0
	custom_metabolism = 0.5

/datum/reagent/alphaamanitin/on_general_digest(mob/living/M)
	..()

	M.adjustToxLoss(6)
	M.adjustOxyLoss(2)
	M.adjustBrainLoss(2)

/datum/reagent/aflatoxin
	name = "Афлатоксин"
	id = "aflatoxin"
	description = "Смертельный токсин отложенного действия. Вызывает общее отравление и повреждает структуру ДНК."
	reagent_state = LIQUID
	color = "#792300" //rgb: 59, 8, 5
	custom_metabolism = 0.05

	data = list()

/datum/reagent/aflatoxin/on_general_digest(mob/living/M)
	..()

	if(!data["ticks"])
		data["ticks"] = 1

	if(data["ticks"] >= 165)
		M.adjustToxLoss(4)
		M.apply_effect(5*REM,IRRADIATE,0)
	data["ticks"]++

/datum/reagent/chefspecial	//From VG. Only for traitors
	name = "Комплимент от шефа"
	id = "chefspecial"
	description = "Чрезвычайно токсичное химическое вещество, которое обязательно приведет к смерти."
	reagent_state = LIQUID
	color = "#792300" //rgb: 207, 54, 0
	custom_metabolism = 0.01
	taste_message = "СМЕРТЬ"
	restrict_species = list(IPC, DIONA)

	data = list()

/datum/reagent/chefspecial/on_general_digest(mob/living/M)
	..()

	if(!data["ticks"])
		data["ticks"] = 1

	if(data["ticks"] >= 165)
		M.death(0)
		M.attack_log += "\[[time_stamp()]\]<font color='red'>Died a quick and painless death by <font color='green'>Chef Excellence's Special Sauce</font>.</font>"
	data["ticks"]++

/datum/reagent/dioxin
	name = "Диоксин"
	id = "dioxin"
	description = "Сильный яд с кумулятивным действием."
	reagent_state = LIQUID
	color = "#792300" //rgb: 207, 54, 0
	custom_metabolism = 0 //No metabolism

	data = list()

/datum/reagent/dioxin/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1

	if(data["ticks"] >= 130)
		M.make_jittery(2)
		M.make_dizzy(2)
		switch (volume)
			if(10 to 20)
				if(prob(5))
					M.emote(pick("twitch","giggle"))
				if(data["ticks"] >=180)
					M.adjustToxLoss(1)
			if(20 to 30)
				if(prob(10))
					M.emote(pick("twitch","giggle"))
				M.adjustToxLoss(3)
				M.adjustBrainLoss(2)
			if(30 to INFINITY)
				if(prob(20))
					M.emote(pick("twitch","giggle"))
				M.adjustToxLoss(3)
				M.adjustBrainLoss(2)
				if(ishuman(M) && prob(5))
					var/mob/living/carbon/human/H = M
					var/obj/item/organ/internal/heart/IO = H.organs_by_name[O_HEART]
					if(istype(IO))
						IO.take_damage(10, 0)
	data["ticks"]++

/datum/reagent/mulligan
	name = "Муллиган"
	id = "mulligan"
	description = "Этот токсин быстро изменит ДНК человека. Обычно используется шпионами и убийцами Синдиката, которым требуется экстренная смена личности."
	reagent_state = LIQUID
	color = "#5eff3b" //RGB: 94, 255, 59
	custom_metabolism = 1000

/datum/reagent/mulligan/on_general_digest(mob/living/carbon/human/H)
	..()
	if(!istype(H) || H.species.flags[NO_DNA])
		return
	to_chat(H,"<span class='warning'><b>Вы скрипите зубами от боли, пока ваше тело быстро мутирует!</b></span>")
	H.visible_message("<b>[H]</b> внезапно преображается!")
	H.gender = pick(MALE, FEMALE)
	if(H.gender == MALE)
		H.name = pick(first_names_male)
	else
		H.name = pick(first_names_female)
	H.name += " [pick(last_names)]"
	H.real_name = H.name
	var/datum/preferences/A = new()	//Randomize appearance for the human
	A.randomize_appearance_for(H)

/datum/reagent/slimetoxin
	name = "Токсин мутации"
	id = "mutationtoxin"
	description = "Разрушающий токсин, вырабатываемый слизнями."
	reagent_state = LIQUID
	color = "#13bc5e" // rgb: 19, 188, 94
	overdose = REAGENTS_OVERDOSE
	custom_metabolism = 0.02

	data = list()

/datum/reagent/slimetoxin/on_general_digest(mob/living/M)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.name == SLIME)
			return
		if(!data["ticks"])
			data["ticks"] = 1
		data["ticks"]++
		switch(data["ticks"])
			if(1)
				to_chat(H, "<span class='warning'>Вы чувствуете себя иначе, каким-то образом...</span>")
			if(2 to 11)
				var/obj/item/organ/external/BP = pick(H.bodyparts)
				if(BP.is_flesh())
					BP.take_damage(10)
					if(prob(25))
						to_chat(H, "<span class='warning'>Ваша плоть начинает таять!</span>")
						H.emote("scream")
						BP.sever_artery()
			if(12 to 21)
				var/obj/item/organ/internal/BP = H.organs_by_name[pick(H.species.has_organ)]
				BP.take_damage(5)
				if(prob(25))
					to_chat(H, "<span class='warning'>Вы чувствуете невыносимую боль внутри себя!</span>")
					H.emote("scream")
			if(30)
				if(H.set_species(SLIME))
					to_chat(H, "<span class='warning'>Ваша плоть мутирует, и вы чувствуете себя свободными!</span>")
					H.dna.mutantrace = "slime"
					H.update_mutantrace()
					for(var/obj/item/organ/external/BP in H.bodyparts)
						BP.status = 0
					for(var/obj/item/organ/internal/BP in H.organs)
						BP.rejuvenate()
			if(31 to 50)
				M.heal_bodypart_damage(0,5)
				M.adjustOxyLoss(-2 * REM)

/datum/reagent/aslimetoxin
	name = "Продвинутый токсин мутации"
	id = "amutationtoxin"
	description = "Продвинутый разрушающий токсин, вырабатываемый слизнями."
	reagent_state = LIQUID
	color = "#13bc5e" // rgb: 19, 188, 94
	overdose = REAGENTS_OVERDOSE

/datum/reagent/aslimetoxin/on_general_digest(mob/living/M)
	..()
	if(istype(M, /mob/living/carbon) && M.stat != DEAD)
		to_chat(M, "<span class='warning'>Ваша плоть быстро мутирует!</span>")
		if(M.notransform)
			return
		M.notransform = TRUE
		M.canmove = 0
		M.icon = null
		M.cut_overlays()
		M.invisibility = 101
		for(var/obj/item/W in M)
			if(istype(W, /obj/item/weapon/implant))	//TODO: Carn. give implants a dropped() or something
				qdel(W)
				continue
			W.layer = initial(W.layer)
			W.loc = M.loc
			W.dropped(M)
		M.sec_hud_set_implants()
		var/mob/living/carbon/slime/new_mob = new /mob/living/carbon/slime(M.loc)
		new_mob.a_intent = INTENT_HARM
		new_mob.universal_speak = 1
		if(M.mind)
			M.mind.transfer_to(new_mob)
		else
			new_mob.key = M.key
		qdel(M)

////////////////////////////////////////////////////////////////////////////////////////////
//////////////Harmful reagents that are not quite toxins but I diagress/////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
/datum/reagent/space_drugs
	name = "Космонаркотики"
	id = "space_drugs"
	description = "Незаконное химическое соединение, используемое в качестве наркотика."
	reagent_state = LIQUID
	color = "#60a584" // rgb: 96, 165, 132
	custom_metabolism = REAGENTS_METABOLISM * 0.5
	overdose = REAGENTS_OVERDOSE
	restrict_species = list(IPC, DIONA)

/datum/reagent/space_drugs/on_general_digest(mob/living/M)
	..()
	M.druggy = max(M.druggy, 15)
	if(isturf(M.loc) && !istype(M.loc, /turf/space))
		if(M.canmove && !M.incapacitated())
			if(prob(10))
				step(M, pick(cardinal))
	if(prob(7))
		M.emote(pick("twitch","drool","moan","giggle"))

/datum/reagent/serotrotium
	name = "Серотротий"
	id = "serotrotium"
	description = "Химическое соединение, которое способствует сосредоточенному производству нейротрансмиттера серотонина у людей."
	reagent_state = LIQUID
	color = "#202040" // rgb: 20, 20, 40
	custom_metabolism = REAGENTS_METABOLISM * 0.25
	overdose = REAGENTS_OVERDOSE
	restrict_species = list(IPC, DIONA)

/datum/reagent/serotrotium/on_general_digest(mob/living/M)
	..()
	if(ishuman(M))
		if(prob(7))
			M.emote(pick("twitch","drool","moan","gasp"))

/datum/reagent/cryptobiolin
	name = "Криптобиолин"
	id = "cryptobiolin"
	description = "Вызывает замешательство и головокружение."
	reagent_state = LIQUID
	color = "#000055" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	custom_metabolism = REAGENTS_METABOLISM * 0.5
	taste_message = null
	restrict_species = list(IPC, DIONA)

/datum/reagent/cryptobiolin/on_general_digest(mob/living/M)
	..()
	M.make_dizzy(1)
	if(!M.confused)
		M.confused = 1
	M.confused = max(M.confused, 20)

/datum/reagent/impedrezene
	name = "Импедрезен"
	id = "impedrezene"
	description = "Наркотик, который снижает способность человека, замедляя высшие функции клеток мозга."
	reagent_state = LIQUID
	color = "#c8a5dc" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	restrict_species = list(IPC, DIONA)

/datum/reagent/impedrezene/on_general_digest(mob/living/M)
	..()
	M.jitteriness = max(M.jitteriness - 5, 0)
	if(prob(80))
		M.adjustBrainLoss(1 * REM)
	if(prob(50))
		M.drowsyness = max(M.drowsyness, 3)
	if(prob(10))
		M.emote("drool")
