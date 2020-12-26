/datum/reagent/srejuvenate
	name = "Лекарственное снотворное"
	id = "stoxin2"
	description = "Усыпляет людей и лечит их."
	reagent_state = LIQUID
	color = "#c8a5dc" // rgb: 200, 165, 220
	custom_metabolism = REAGENTS_METABOLISM * 0.5
	overdose = REAGENTS_OVERDOSE
	restrict_species = list(IPC, DIONA)

	data = list()

/datum/reagent/srejuvenate/on_general_digest(mob/living/M)
	..()
	if(M.losebreath >= 10)
		M.losebreath = max(10, M.losebreath-10)
	if(!data["ticks"])
		data["ticks"] = 1
	data["ticks"]++
	switch(data["ticks"])
		if(1 to 15)
			M.eye_blurry = max(M.eye_blurry, 10)
		if(15 to 25)
			M.drowsyness  = max(M.drowsyness, 20)
		if(25 to INFINITY)
			M.SetSleeping(20 SECONDS)
			M.adjustOxyLoss(-M.getOxyLoss())
			M.SetWeakened(0)
			M.SetStunned(0)
			M.SetParalysis(0)
			M.dizziness = 0
			M.drowsyness = 0
			M.stuttering = 0
			M.confused = 0
			M.jitteriness = 0

/datum/reagent/inaprovaline
	name = "Инапровалин"
	id = "inaprovaline"
	description = "Синаптический стимулятор и кардиостимулятор. Обычно используется для стабилизации состояния пациентов."
	reagent_state = LIQUID
	color = "#00bfff" // rgb: 200, 165, 220
	custom_metabolism = REAGENTS_METABOLISM * 0.5
	overdose = REAGENTS_OVERDOSE * 2
	restrict_species = list(IPC, DIONA)

/datum/reagent/inaprovaline/on_general_digest(mob/living/M)
	..()
	if(M.losebreath >= 10)
		M.losebreath = max(10, M.losebreath-5)

/datum/reagent/inaprovaline/on_vox_digest(mob/living/M)
	..()
	M.adjustToxLoss(REAGENTS_METABOLISM)
	return FALSE // General digest proc shouldn't be called.

/datum/reagent/ryetalyn
	name = "Риеталин"
	id = "ryetalyn"
	description = "Излечивает генетические аномалии с помощью каталитического процесса."
	reagent_state = SOLID
	color = "#004000" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	custom_metabolism = 2 * REAGENTS_METABOLISM

	data = list()

/datum/reagent/ryetalyn/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1

	for(var/datum/dna/gene/gene in dna_genes)
		if(!gene.block)
			continue
		if(!prob(REM * data["ticks"]))
			continue
		M.dna.SetSEValue(gene.block, rand(1,2048))
		genemutcheck(M, gene.block, null, MUTCHK_FORCED)

	data["ticks"]++

/datum/reagent/paracetamol
	name = "Парацетамол"
	id = "paracetamol"
	description = "Слабое простое болеутолящее средство."
	reagent_state = LIQUID
	color = "#c8a5dc"
	overdose = 60
	restrict_species = list(IPC, DIONA)

/datum/reagent/paracetamol/on_general_digest(mob/living/M)
	..()
	if(volume > overdose)
		M.hallucination = max(M.hallucination, 2)

/datum/reagent/tramadol
	name = "Трамадол"
	id = "tramadol"
	description = "Простое но эффективное обезбаливающее."
	reagent_state = LIQUID
	color = "#cb68fc"
	overdose = 30
	custom_metabolism = 0.025
	restrict_species = list(IPC, DIONA)

/datum/reagent/tramadol/on_general_digest(mob/living/M)
	..()
	if(volume > overdose)
		M.hallucination = max(M.hallucination, 2)

/datum/reagent/oxycodone
	name = "Оксикодон"
	id = "oxycodone"
	description = "Эффективное обезболивающее, вызывающее сильное привыкание."
	reagent_state = LIQUID
	color = "#800080"
	overdose = 20
	custom_metabolism = 0.025
	restrict_species = list(IPC, DIONA)

/datum/reagent/oxycodone/on_general_digest(mob/living/M)
	..()
	if(volume > overdose)
		M.druggy = max(M.druggy, 10)
		M.hallucination = max(M.hallucination, 3)

/datum/reagent/sterilizine
	name = "Стерилизин"
	id = "sterilizine"
	description = "Стерилизует раны перед операцией."
	reagent_state = LIQUID
	color = "#c8a5dc" // rgb: 200, 165, 220

	//makes you squeaky clean
/datum/reagent/sterilizine/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == TOUCH)
		M.germ_level -= min(volume*20, M.germ_level)

/datum/reagent/sterilizine/reaction_obj(obj/O, volume)
	O.germ_level -= min(volume*20, O.germ_level)

/datum/reagent/sterilizine/reaction_turf(turf/T, volume)
	. = ..()
	T.germ_level -= min(volume*20, T.germ_level)

/datum/reagent/leporazine
	name = "Лепоразин"
	id = "leporazine"
	description = "Используется для стабилизации температуры пациента."
	reagent_state = LIQUID
	color = "#c8a5dc" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	taste_message = null

/datum/reagent/leporazine/on_general_digest(mob/living/M)
	..()
	if(M.bodytemperature > BODYTEMP_NORMAL)
		M.bodytemperature = max(BODYTEMP_NORMAL, M.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(M.bodytemperature < 311)
		M.bodytemperature = min(BODYTEMP_NORMAL, M.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/kelotane
	name = "Келотан"
	id = "kelotane"
	description = "Препарат использующийся для лечения ожогов."
	reagent_state = LIQUID
	color = "#ffc600" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	taste_message = null
	restrict_species = list(IPC, DIONA)

/datum/reagent/kelotane/on_general_digest(mob/living/M)
	..()
	M.heal_bodypart_damage(0,2 * REM)

/datum/reagent/dermaline
	name = "Дермалин"
	id = "dermaline"
	description = "Следующий шаг в лечении ожогов. Работает вдвое лучше, чем келотан, и позволяет телу восстанавливать даже самые поврежденные ткани."
	reagent_state = LIQUID
	color = "#ff8000" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE * 0.5
	taste_message = null
	restrict_species = list(IPC, DIONA)

/datum/reagent/dermaline/on_general_digest(mob/living/M)
	..()
	M.heal_bodypart_damage(0,3 * REM)
	if(volume >= overdose && (HUSK in M.mutations) && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.mutations.Remove(HUSK)
		H.update_body()

/datum/reagent/dexalin
	name = "Дексалин"
	id = "dexalin"
	description = "Используется при лечении кислородного голодания."
	reagent_state = LIQUID
	color = "#0080ff" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	taste_message = "кислорода"
	restrict_species = list(IPC, DIONA)

/datum/reagent/dexalin/on_general_digest(mob/living/M)
	..()
	M.adjustOxyLoss(-2 * REM)

	if(holder.has_reagent("lexorin"))
		holder.remove_reagent("lexorin", 2 * REM)

/datum/reagent/dexalin/on_vox_digest(mob/living/M, alien) // Now dexalin does not remove lexarin from Vox. For the better or the worse.
	..()
	M.adjustToxLoss(2 * REM)
	return FALSE

/datum/reagent/dextromethorphan
	name = "Декстрометорфан"
	id = "dextromethorphan"
	description = "Обезболивающее химическое средство, которое лечит повреждения легких и кашель."
	reagent_state = LIQUID
	color = "#ffc0cb" // rgb: 255, 192, 203
	overdose = 10
	custom_metabolism = REAGENTS_METABOLISM * 0.5
	taste_message = "тошнотворной горечи"
	restrict_species = list(IPC, DIONA)

	data = list()

/datum/reagent/dextromethorphan/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1
	M.adjustOxyLoss(-M.getOxyLoss())
	if(holder.has_reagent("lexorin"))
		holder.remove_reagent("lexorin", 2 * REM)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/lungs/IO = H.organs_by_name[O_LUNGS]
		if(istype(IO))
			if(IO.damage > 0 && IO.robotic < 2)
				IO.damage = max(IO.damage - 0.7, 0)
		switch(data["ticks"])
			if(50 to 100)
				H.disabilities &= ~COUGHING
			if(100 to INFINITY)
				H.hallucination = max(H.hallucination, 7)
	data["ticks"]++

/datum/reagent/dexalinp/on_vox_digest(mob/living/M)
	..()
	M.adjustToxLoss(7 * REM)
	return FALSE

/datum/reagent/dexalinp
	name = "Дексалин Плюс"
	id = "dexalinp"
	description = "Используется при лечении кислородного голодания. Очень эффективен."
	reagent_state = LIQUID
	color = "#0040ff" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE * 0.5
	taste_message = "ability to breath"
	restrict_species = list(IPC, DIONA)

/datum/reagent/dexalinp/on_general_digest(mob/living/M)
	..()
	M.adjustOxyLoss(-M.getOxyLoss())

	if(holder.has_reagent("lexorin"))
		holder.remove_reagent("lexorin", 2 * REM)

/datum/reagent/dexalinp/on_vox_digest(mob/living/M) // Now dexalin plus does not remove lexarin from Vox. For the better or the worse.
	..()
	M.adjustToxLoss(6 * REM) // Let's just say it's thrice as poisonous.
	return FALSE

/datum/reagent/tricordrazine
	name = "Трикордразин"
	id = "tricordrazine"
	description = "Трикордразин является сильнодействующим стимулятором, первоначально полученным из кордразина. Может использоваться для лечения широкого спектра травм."
	reagent_state = LIQUID
	color = "#00b080" // rgb: 200, 165, 220
	taste_message = null
	restrict_species = list(IPC, DIONA)

/datum/reagent/tricordrazine/on_general_digest(mob/living/M)
	..()
	if(M.getOxyLoss())
		M.adjustOxyLoss(-1 * REM)
	if(M.getBruteLoss() && prob(80))
		M.heal_bodypart_damage(REM, 0)
	if(M.getFireLoss() && prob(80))
		M.heal_bodypart_damage(0, REM)
	if(M.getToxLoss() && prob(80))
		M.adjustToxLoss(-1 * REM)

/datum/reagent/anti_toxin
	name = "Анти-Токсин (Диловен)"
	id = "anti_toxin"
	description = "Анти-токсин широкого спектра."
	reagent_state = LIQUID
	color = "#00a000" // rgb: 200, 165, 220
	taste_message = null
	restrict_species = list(IPC, DIONA)

/datum/reagent/anti_toxin/on_general_digest(mob/living/M)
	..()
	M.reagents.remove_all_type(/datum/reagent/toxin, REM, 0, 1)
	M.drowsyness = max(M.drowsyness - 2 * REM, 0)
	M.hallucination = max(0, M.hallucination - 5 * REM)
	M.adjustToxLoss(-2 * REM)

/datum/reagent/thermopsis
	name = "Термопсис"
	id = "thermopsis"
	description = "Раздражает рецепторы желудка, что вызывает рефлекторное усиление рвоты."
	reagent_state = LIQUID
	color = "#a0a000"
	taste_message = "рвоты"
	restrict_species = list(IPC, DIONA)

	data = list()

/datum/reagent/thermopsis/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1
	data["ticks"]++
	if(data["ticks"] > 10)
		M.vomit()
		data["ticks"] -= rand(0, 10)

/datum/reagent/adminordrazine //An OP chemical for admins
	name = "Админордразин"
	id = "adminordrazine"
	description = "Это магия. Мы не должны объяснять это."
	reagent_state = LIQUID
	color = "#c8a5dc" // rgb: 200, 165, 220
	taste_message = "педальной магии"

/datum/reagent/adminordrazine/on_general_digest(mob/living/M)
	..()
	M.reagents.remove_all_type(/datum/reagent/toxin, 5 * REM, 0, 1)
	M.setCloneLoss(0)
	M.setOxyLoss(0)
	M.radiation = 0
	M.heal_bodypart_damage(5,5)
	M.adjustToxLoss(-5)
	M.hallucination = 0
	M.setBrainLoss(0)
	M.disabilities = 0
	M.sdisabilities = 0
	M.eye_blurry = 0
	M.eye_blind = 0
	M.SetWeakened(0)
	M.SetStunned(0)
	M.SetParalysis(0)
	M.silent = 0
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.confused = 0
	M.SetSleeping(0)
	M.jitteriness = 0
	for(var/datum/disease/D in M.viruses)
		D.spread = "Remissive"
		D.stage--
		if(D.stage < 1)
			D.cure()

/datum/reagent/synaptizine
	name = "Синаптизин"
	id = "synaptizine"
	description = "Используется для лечения галлюцинаций."
	reagent_state = LIQUID
	color = "#99ccff" // rgb: 200, 165, 220
	custom_metabolism = 0.01
	overdose = REAGENTS_OVERDOSE
	restrict_species = list(IPC, DIONA)

/datum/reagent/synaptizine/on_general_digest(mob/living/M)
	..()
	M.drowsyness = max(M.drowsyness - 5, 0)
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	if(holder.has_reagent("mindbreaker"))
		holder.remove_reagent("mindbreaker", 5)
	M.hallucination = max(0, M.hallucination - 10)
	if(prob(60))
		M.adjustToxLoss(1)

/datum/reagent/hyronalin
	name = "Гироналин"
	id = "hyronalin"
	description = "Лекарственный препарат, применяемый для противодействия эффекту радиационного отравления."
	reagent_state = LIQUID
	color = "#408000" // rgb: 200, 165, 220
	custom_metabolism = 0.05
	overdose = REAGENTS_OVERDOSE
	taste_message = null

/datum/reagent/hyronalin/on_general_digest(mob/living/M)
	..()
	M.radiation = max(M.radiation - 3 * REM, 0)

/datum/reagent/arithrazine
	name = "Аритразин"
	id = "arithrazine"
	description = "Нестабильный препарат, используемый в самых тяжелых случаях радиационного отравления."
	reagent_state = LIQUID
	color = "#008000" // rgb: 200, 165, 220
	custom_metabolism = 0.05
	overdose = REAGENTS_OVERDOSE
	taste_message = null

/datum/reagent/arithrazine/on_general_digest(mob/living/M)
	..()
	M.radiation = max(M.radiation - 7 * REM, 0)
	M.adjustToxLoss(-1 * REM)
	if(prob(15))
		M.take_bodypart_damage(1, 0)

/datum/reagent/alkysine
	name = "Алкиcин"
	id = "alkysine"
	description = "Лекарство, используемое для уменьшения повреждения неврологической ткани после катастрофической травмы. Может лечить ткани мозга."
	reagent_state = LIQUID
	color = "#8b00ff" // rgb: 200, 165, 220
	custom_metabolism = 0.05
	overdose = REAGENTS_OVERDOSE
	taste_message = null

/datum/reagent/alkysine/on_general_digest(mob/living/M)
	..()
	M.adjustBrainLoss(-3 * REM)

/datum/reagent/imidazoline
	name = "Имидазолин"
	id = "imidazoline"
	description = "Лечит повреждения глаз."
	reagent_state = LIQUID
	color = "#a0dbff" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	taste_message = "моркови"
	restrict_species = list(IPC, DIONA)

/datum/reagent/imidazoline/on_general_digest(mob/living/M)
	..()
	M.eye_blurry = max(M.eye_blurry - 5, 0)
	M.eye_blind = max(M.eye_blind - 5, 0)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/eyes/IO = H.organs_by_name[O_EYES]
		if(istype(IO))
			if(IO.damage > 0 && IO.robotic < 2)
				IO.damage = max(IO.damage - 1, 0)

/datum/reagent/peridaxon
	name = "Перидаксон"
	id = "peridaxon"
	description = "Используется для восстановления органов и нервной системы. Применяйте с осторожностью."
	reagent_state = LIQUID
	color = "#561ec3" // rgb: 200, 165, 220
	overdose = 10
	taste_message = null
	restrict_species = list(IPC, DIONA)

/datum/reagent/peridaxon/on_general_digest(mob/living/M)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/damaged_organs = 0
		//Peridaxon is hard enough to get, it's probably fair to make this all organs
		for(var/obj/item/organ/internal/IO in H.organs)
			if(IO.damage > 0 && IO.robotic < 2)
				damaged_organs++

		if(!damaged_organs)
			return
		for(var/obj/item/organ/internal/IO in H.organs)
			if(IO.damage > 0 && IO.robotic < 2)
				IO.damage = max(IO.damage - (3 * custom_metabolism / damaged_organs), 0)

/datum/reagent/kyphotorin
	name = "Кифоторин"
	id = "kyphotorin"
	description = "Использует наниты, чтобы стимулировать восстановление частей тела и костей. Применяйте с осторожностью."
	reagent_state = LIQUID
	color = "#551a8b" // rgb: 85, 26, 139
	overdose = 5.1
	custom_metabolism = 0.07
	taste_message = "машин"
	restrict_species = list(IPC, DIONA)

/datum/reagent/kyphotorin/on_general_digest(mob/living/M)
	..()
	if(!ishuman(M) || volume > overdose)
		return
	var/mob/living/carbon/human/H = M
	if(H.nutrition < 200) // if nanites don't have enough resources, they stop working and still spend
		H.make_jittery(100)
		volume += 0.07
		return
	H.jitteriness = max(0,H.jitteriness - 100)
	if(!H.regenerating_bodypart)
		H.regenerating_bodypart = H.find_damaged_bodypart()
	if(H.regenerating_bodypart)
		H.nutrition -= 3
		H.apply_effect(3, WEAKEN)
		H.apply_damages(0,0,1,4,0,5)
		H.regen_bodyparts(4, FALSE)
	else
		volume += 0.07

/datum/reagent/bicaridine
	name = "Бикаридин"
	id = "bicaridine"
	description = "Лекарство используемое для лечения механических повреждений."
	reagent_state = LIQUID
	color = "#bf0000" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	taste_message = null
	restrict_species = list(IPC, DIONA)

/datum/reagent/bicaridine/on_general_digest(mob/living/M, alien)
	..()
	M.heal_bodypart_damage(2 * REM, 0)

/datum/reagent/hyperzine
	name = "Гиперзин"
	id = "hyperzine"
	description = "Высокоэффективный, длительный мышечный стимулятор."
	reagent_state = LIQUID
	color = "#ff4f00" // rgb: 200, 165, 220
	custom_metabolism = 0.03
	overdose = REAGENTS_OVERDOSE * 0.5
	taste_message = "скорости"
	restrict_species = list(IPC, DIONA)

/datum/reagent/hyperizine/on_general_digest(mob/living/M)
	..()
	if(prob(5))
		M.emote(pick("twitch","blink","shiver"))

/datum/reagent/cryoxadone
	name = "Криоксадон"
	id = "cryoxadone"
	description = "Химическая смесь с почти магической целительной силой. Его основным ограничением является то, что для правильного метаболизма температура тела целевой группы должна быть ниже 170 К."
	reagent_state = LIQUID
	color = "#80bfff" // rgb: 200, 165, 220
	taste_message = null

/datum/reagent/cryoxadone/on_general_digest(mob/living/M)
	..()
	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-1)
		M.adjustOxyLoss(-1)
		M.heal_bodypart_damage(1, 1)
		M.adjustToxLoss(-1)

/datum/reagent/clonexadone
	name = "Clonexadone"
	id = "clonexadone"
	description = "Жидкое соединение, подобное тому, которое используется в процессе клонирования. Может использоваться для «завершения» процесса клонирования при использовании вместе с криотрубой."
	reagent_state = LIQUID
	color = "#8080ff" // rgb: 200, 165, 220
	taste_message = null

/datum/reagent/clonexadone/on_general_digest(mob/living/M)
	..()
	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-3)
		M.adjustOxyLoss(-3)
		M.heal_bodypart_damage(3, 3)
		M.adjustToxLoss(-3)

/datum/reagent/rezadone
	name = "Резадон"
	id = "rezadone"
	description = "Порошок, полученный из рыбного токсина, это вещество может эффективно лечить генетические повреждения у гуманоидов, хотя чрезмерное употребление имеет побочные эффекты."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	overdose = REAGENTS_OVERDOSE
	taste_message = null

	data = list()

/datum/reagent/rezadone/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1
	data["ticks"]++
	switch(data["ticks"])
		if(1 to 15)
			M.adjustCloneLoss(-1)
			M.heal_bodypart_damage(1, 1)
		if(15 to 35)
			M.adjustCloneLoss(-2)
			M.heal_bodypart_damage(2, 1)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/obj/item/organ/external/head/BP = H.bodyparts_by_name[BP_HEAD]
				if(BP && BP.disfigured)
					BP.disfigured = FALSE
					to_chat(M, "Your face is shaped normally again.")
		if(35 to INFINITY)
			M.adjustToxLoss(1)
			M.make_dizzy(5)
			M.make_jittery(5)

/datum/reagent/spaceacillin
	name = "Космоциллин"
	id = "spaceacillin"
	description = "Универсальное противовирусное средство."
	reagent_state = LIQUID
	color = "#ffffff" // rgb: 200, 165, 220
	custom_metabolism = 0.01
	overdose = REAGENTS_OVERDOSE
	taste_message = null

/datum/reagent/ethylredoxrazine // FUCK YOU, ALCOHOL
	name = "Этилредоксразин"
	id = "ethylredoxrazine"
	description = "Мощный окислитель, вступающий в реакцию с этанолом."
	reagent_state = SOLID
	color = "#605048" // rgb: 96, 80, 72
	overdose = REAGENTS_OVERDOSE
	taste_message = null

/datum/reagent/ethylredoxrazine/on_general_digest(mob/living/M)
	..()
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.confused = 0
	M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 1 * REM, 0, 1)

/datum/reagent/vitamin //Helps to regen blood and hunger(but doesn't really regen hunger because of the commented code below).
	name = "Витамин"
	id = "vitamin"
	description = "Все лучшие витамины, минералы и углеводы, необходимые организму в чистом виде."
	reagent_state = SOLID
	color = "#664330" // rgb: 102, 67, 48
	taste_message = null

/datum/reagent/vitamin/on_general_digest(mob/living/M)
	..()
	if(prob(50))
		M.adjustBruteLoss(-1)
		M.adjustFireLoss(-1)
	/*if(M.nutrition < NUTRITION_LEVEL_WELL_FED) //we are making him WELL FED
		M.nutrition += 30*/  //will remain commented until we can deal with fat
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/blood_volume = H.vessel.get_reagent_amount("blood")
		if(!(NO_BLOOD in H.species.flags))//do not restore blood on things with no blood by nature.
			if(blood_volume < BLOOD_VOLUME_NORMAL && blood_volume)
				var/datum/reagent/blood/B = locate() in H.vessel.reagent_list
				B.volume += 0.5

/datum/reagent/lipozine
	name = "Липозин" // The anti-nutriment.
	id = "lipozine"
	description = "Химическое соединение, вызывающее мощную реакцию сжигания жира."
	reagent_state = LIQUID
	nutriment_factor = 10 * REAGENTS_METABOLISM
	color = "#bbeda4" // rgb: 187, 237, 164
	overdose = REAGENTS_OVERDOSE

/datum/reagent/lipozine/on_general_digest(mob/living/M)
	..()
	M.nutrition = max(M.nutrition - nutriment_factor, 0)
	M.overeatduration = 0

/datum/reagent/stimulants
	name = "Стимуляторы"
	id = "stimulants"
	description = "Стимуляторы удерживаюие тебя на ногах в важный момент."
	reagent_state = LIQUID
	color = "#99ccff" // rgb: 200, 165, 220
	custom_metabolism = 0.5
	overdose = REAGENTS_OVERDOSE
	restrict_species = list(IPC, DIONA)

/datum/reagent/stimulants/on_general_digest(mob/living/M)
	..()
	M.drowsyness = max(M.drowsyness - 5, 0)
	M.AdjustParalysis(-3)
	M.AdjustStunned(-3)
	M.AdjustWeakened(-3)
	var/mob/living/carbon/human/H = M
	H.adjustHalLoss(-30)
	H.shock_stage -= 20

/datum/reagent/nanocalcium
	name = "Нанокальций"
	id = "nanocalcium"
	description = "Усовершенствованные наниты, содержащие кальций, предназначены для восстановления костей. Наномашины, сынок."
	reagent_state = LIQUID
	color = "#9b3401"
	overdose = REAGENTS_OVERDOSE
	custom_metabolism = 0.1
	taste_message = "целостности"
	restrict_species = list(IPC, DIONA)
	data = list()

/datum/reagent/nanocalcium/on_general_digest(mob/living/carbon/human/M)
	..()
	if(!ishuman(M))
		return

	if(!data["ticks"])
		data["ticks"] = 1
	data["ticks"]++
	switch(data)
		if(1 to 10)
			M.make_dizzy(1)
			if(prob(10))
				to_chat(M, "<span class='warning'>Ваша кожа кажется горячей, и ваши вены горят!</span>")
		if(10 to 20)
			if(M.reagents.has_reagent("tramadol") || M.reagents.has_reagent("oxycodone"))
				M.adjustToxLoss(5)
			else
				M.confused += 2
		if(20 to 60)
			for(var/obj/item/organ/external/E in M.bodyparts)
				if(E.is_broken())
					if(prob(50))
						to_chat(M, "<span class='notice'>Вы чувствуете жжение в своей [E.name] в то время как она невольно выпрямляется!</span>")
						E.brute_dam = 0
						E.status &= ~BROKEN
						holder.remove_reagent("nanocalcium", 10)
