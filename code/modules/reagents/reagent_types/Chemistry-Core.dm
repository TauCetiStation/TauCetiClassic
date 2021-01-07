/datum/reagent/water
	name = "Вода"
	id = "water"
	description = "Повсеместно встречающееся химическое вещество, состоящее из водорода и кислорода."
	reagent_state = LIQUID
	color = "#0064c8" // rgb: 0, 100, 200
	custom_metabolism = 0.01
	taste_message = null

/datum/reagent/water/reaction_mob(mob/M, method=TOUCH, volume)
	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/volume_coefficient = max((10-volume)/10, 0)
			var/changes_occured = FALSE

			if(H.species && (H.species.name in list(HUMAN, UNATHI, TAJARAN)))
				if(H.hair_painted && !(H.head && ((H.head.flags & BLOCKHAIR) || (H.head.flags & HIDEEARS))) && H.h_style != "Bald")
					H.dyed_r_hair = clamp(round(H.dyed_r_hair * volume_coefficient + ((H.r_hair * volume) / 10)), 0, 255)
					H.dyed_g_hair = clamp(round(H.dyed_g_hair * volume_coefficient + ((H.g_hair * volume) / 10)), 0, 255)
					H.dyed_b_hair = clamp(round(H.dyed_b_hair * volume_coefficient + ((H.b_hair * volume) / 10)), 0, 255)
					if(H.dyed_r_hair == H.r_hair && H.dyed_g_hair == H.g_hair && H.dyed_b_hair == H.b_hair)
						H.hair_painted = FALSE
						changes_occured = TRUE
				if(H.facial_painted && !((H.wear_mask && (H.wear_mask.flags & HEADCOVERSMOUTH)) || (H.head && (H.head.flags & HEADCOVERSMOUTH))) && H.f_style != "Shaved")
					H.dyed_r_facial = clamp(round(H.dyed_r_facial * volume_coefficient + ((H.r_facial * volume) / 10)), 0, 255)
					H.dyed_g_facial = clamp(round(H.dyed_g_facial * volume_coefficient + ((H.g_facial * volume) / 10)), 0, 255)
					H.dyed_b_facial = clamp(round(H.dyed_b_facial * volume_coefficient + ((H.b_facial * volume) / 10)), 0, 255)
					if(H.dyed_r_facial == H.r_facial && H.dyed_g_facial == H.g_facial && H.dyed_b_facial == H.b_facial)
						H.facial_painted = FALSE
						changes_occured = TRUE
			if(!H.head && !H.wear_mask && H.h_style == "Bald" && H.f_style == "Shaved" && volume >= 10)
				H.lip_style = null
				changes_occured = TRUE
				H.update_body()
			if(changes_occured)
				H.update_hair()

/datum/reagent/water/reaction_turf(turf/simulated/T, volume)
	. = ..()
	spawn_fluid(T, volume) // so if will spawn even in space, just for pure visuals
	if(!istype(T))
		return
	src = null
	if(volume >= 3)
		T.make_wet_floor(WATER_FLOOR)

	for(var/mob/living/carbon/slime/M in T)
		M.adjustToxLoss(rand(15,20))

	var/hotspot = (locate(/obj/fire) in T)
	if(hotspot && !istype(T, /turf/space))
		var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles )
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

/datum/reagent/water/reaction_obj(obj/O, volume)
	var/turf/T = get_turf(O)
	var/hotspot = (locate(/obj/fire) in T)
	if(hotspot && !istype(T, /turf/space))
		var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles )
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)
	if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/monkeycube))
		var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/cube = O
		if(!cube.wrapped)
			cube.Expand()
	else if(istype(O, /obj/machinery/camera))
		var/obj/machinery/camera/C = O
		if(C.painted)
			C.remove_paint_state()
			C.color = null

/datum/reagent/water/on_diona_digest(mob/living/M)
	..()
	M.nutrition += REM
	return FALSE

/datum/reagent/water/on_slime_digest(mob/living/M)
	..()
	M.adjustToxLoss(REM)
	return FALSE

/datum/reagent/water/holywater // May not be a "core" reagent, but I decided to keep the subtypes near  their parents.
	name = "Святая вода"
	id = "holywater"
	description = "Смесь пепла, обсидиана и воды, этот раствор изменит некоторые области рациональности мозга."
	color = "#e0e8ef" // rgb: 224, 232, 239

	needed_aspects = list(ASPECT_RESCUE = 1)

/datum/reagent/water/holywater/on_general_digest(mob/living/M)
	..()
	if(holder.has_reagent("unholywater"))
		holder.remove_reagent("unholywater", 2 * REM)
	if(ishuman(M) && iscultist(M) && prob(10))
		SSticker.mode.remove_cultist(M.mind)
		M.visible_message("<span class='notice'>[M] моргает и его глаза становятся чище.</span>",
				          "<span class='notice'>Ощущение прохлады внутри заставляет вас чувствовать невыразимое спокойствие.</span>")

/datum/reagent/water/holywater/reaction_obj(obj/O, volume)
	src = null
	if(istype(O, /obj/item/weapon/dice/ghost))
		var/obj/item/weapon/dice/ghost/G = O
		var/obj/item/weapon/dice/cleansed = new G.normal_type(G.loc)
		if(istype(G, /obj/item/weapon/dice/ghost/d00))
			cleansed.result = (G.result/10)+1
		else
			cleansed.result = G.result
		cleansed.icon_state = "[initial(cleansed.icon_state)][cleansed.result]"
		if(istype(O.loc, /mob/living)) // Just for the sake of me feeling better.
			var/mob/living/M = O.loc
			M.drop_from_inventory(cleansed)
		qdel(O)
	else if(istype(O, /obj/item/candle/ghost))
		var/obj/item/candle/ghost/G = O
		var/obj/item/candle/cleansed = new /obj/item/candle(G.loc)
		if(G.lit) // Haha, but wouldn't water actually extinguish it?
			cleansed.light("")
		cleansed.wax = G.wax
		if(istype(O.loc, /mob/living))
			var/mob/living/M = O.loc
			M.drop_from_inventory(cleansed)
		qdel(O)
	else if(istype(O, /obj/item/weapon/game_kit/chaplain))
		var/obj/item/weapon/game_kit/chaplain/G = O
		var/obj/item/weapon/game_kit/random/cleansed = new /obj/item/weapon/game_kit/random(G.loc)
		if(istype(O.loc, /mob/living))
			var/mob/living/M = O.loc
			M.drop_from_inventory(cleansed)
		qdel(O)
	else if(istype(O, /obj/item/weapon/pen/ghost))
		var/obj/item/weapon/pen/ghost/G = O
		var/obj/item/weapon/pen/cleansed = new /obj/item/weapon/pen(G.loc)
		if(istype(O.loc, /mob/living))
			var/mob/living/M = O.loc
			M.drop_from_inventory(cleansed)
		qdel(O)
	else if(istype(O, /obj/item/weapon/storage/fancy/black_candle_box))
		var/obj/item/weapon/storage/fancy/black_candle_box/G = O
		G.teleporter_delay += volume

/datum/reagent/water/unholywater
	name = "Проклятая вода"
	id = "unholywater"
	description = "Смесь мертвечины, эктоплазмы и воды. Этот раствор может изменить концепцию самой реальности."
	color = "#c80064" // rgb: 200,0, 100

	data = list()

	needed_aspects = list(ASPECT_OBSCURE = 1)

/datum/reagent/water/unholywater/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1
	if(iscultist(M) && prob(10))
		switch(data["ticks"])
			if(1 to 30)
				M.heal_bodypart_damage(REM, REM)
			if(30 to 60)
				M.heal_bodypart_damage(2 * REM, 2 * REM)
			if(60 to INFINITY)
				M.heal_bodypart_damage(3 * REM, 3 * REM)
	else if(!iscultist(M))
		switch(data["ticks"])
			if(1 to 20)
				M.make_jittery(3)
			if(20 to 40)
				M.make_jittery(6)
				if(prob(15))
					M.SetSleeping(20 SECONDS)
			if(40 to 80)
				M.make_jittery(12)
				if(prob(30))
					M.SetSleeping(20 SECONDS)
			if(80 to INFINITY)
				M.SetSleeping(20 SECONDS)
	data["ticks"]++

/datum/reagent/water/unholywater/reaction_obj(obj/O, volume)
	src = null
	if(istype(O, /obj/item/weapon/dice))
		var/obj/item/weapon/dice/N = O
		var/obj/item/weapon/dice/cursed = new N.accursed_type(N.loc)
		if(istype(N, /obj/item/weapon/dice/d00))
			cursed.result = (N.result/10)+1
		else
			cursed.result = N.result
		cursed.icon_state = "[initial(cursed.icon_state)][cursed.result]"
		if(istype(O.loc, /mob/living)) // Just for the sake of me feeling better.
			var/mob/living/M = O.loc
			M.drop_from_inventory(cursed)
		qdel(O)
	else if(istype(O, /obj/item/candle) && !istype(O, /obj/item/candle/ghost))
		var/obj/item/candle/N = O
		var/obj/item/candle/ghost/cursed = new /obj/item/candle/ghost(N.loc)
		if(N.lit) // Haha, but wouldn't water actually extinguish it?
			cursed.light("")
		cursed.wax = N.wax
		if(istype(O.loc, /mob/living))
			var/mob/living/M = O.loc
			M.drop_from_inventory(cursed)
		qdel(O)
	else if(istype(O, /obj/item/weapon/game_kit) && !istype(O, /obj/item/weapon/game_kit/chaplain))
		var/obj/item/weapon/game_kit/N = O
		var/obj/item/weapon/game_kit/random/cursed = new /obj/item/weapon/game_kit/chaplain(N.loc)
		cursed.board_stat = N.board_stat
		if(istype(O.loc, /mob/living))
			var/mob/living/M = O.loc
			M.drop_from_inventory(cursed)
		qdel(O)
	else if(istype(O, /obj/item/weapon/pen) && !istype(O, /obj/item/weapon/pen/ghost))
		var/obj/item/weapon/pen/N = O
		var/obj/item/weapon/pen/ghost/cursed = new /obj/item/weapon/pen/ghost(N.loc)
		if(istype(O.loc, /mob/living))
			var/mob/living/M = O.loc
			M.drop_from_inventory(cursed)
		qdel(O)
	else if(istype(O, /obj/item/weapon/storage/fancy/black_candle_box))
		var/obj/item/weapon/storage/fancy/black_candle_box/G = O
		G.teleporter_delay += volume

/datum/reagent/oxygen
	name = "Кислород"
	id = "oxygen"
	description = "Газ без цвета и запаха."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_message = null
	custom_metabolism = 0.01

/datum/reagent/oxygen/on_vox_digest(mob/living/M)
	..()
	M.adjustToxLoss(REAGENTS_METABOLISM)
	holder.remove_reagent(id, REAGENTS_METABOLISM) //By default it slowly disappears.
	return FALSE

/datum/reagent/copper
	name = "Медь"
	id = "copper"
	description = "Очень податливый металл."
	color = "#6e3b08" // rgb: 110, 59, 8
	taste_message = null
	custom_metabolism = 0.01

/datum/reagent/nitrogen
	name = "Азот"
	id = "nitrogen"
	description = "Газ без цвета, запаха и вкуса."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_message = null
	custom_metabolism = 0.01

/datum/reagent/nitrogen/on_diona_digest(mob/living/M)
	..()
	M.adjustBruteLoss(-REM)
	M.adjustOxyLoss(-REM)
	M.adjustToxLoss(-REM)
	M.adjustFireLoss(-REM)
	M.nutrition += REM
	return FALSE

/datum/reagent/nitrogen/on_vox_digest(mob/living/M)
	..()
	M.adjustOxyLoss(-2 * REM)
	holder.remove_reagent(id, REAGENTS_METABOLISM) //By default it slowly disappears.
	return FALSE

/datum/reagent/hydrogen
	name = "Водород"
	id = "hydrogen"
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	description = "Легковоспламеняющийся двухатомный неметаллический газ без цвета, запаха и вкуса."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_message = null
	custom_metabolism = 0.01

/datum/reagent/potassium
	name = "Калий"
	id = "potassium"
	description = "Мягкий металл с низкой температурой плавления, который может быть легко разрезан ножом. Вызывает сильную реакцию с водой."
	reagent_state = SOLID
	color = "#a0a0a0" // rgb: 160, 160, 160
	taste_message = "плохие идеи"
	custom_metabolism = 0.01

/datum/reagent/mercury
	name = "Ртуть"
	id = "mercury"
	description = "Химический элемент."
	reagent_state = LIQUID
	color = "#484848" // rgb: 72, 72, 72
	overdose = REAGENTS_OVERDOSE
	taste_message = "наркоманский яд"
	restrict_species = list(IPC, DIONA)

/datum/reagent/mercury/on_general_digest(mob/living/M)
	..()
	if(M.canmove && !M.incapacitated() && istype(M.loc, /turf/space))
		step(M, pick(cardinal))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))
	M.adjustBrainLoss(2)

/datum/reagent/sulfur
	name = "Сера"
	id = "sulfur"
	description = "Химический элемент с едким запахом."
	reagent_state = SOLID
	color = "#bf8c00" // rgb: 191, 140, 0
	taste_message = "импульсивные решения"
	custom_metabolism = 0.01

/datum/reagent/carbon
	name = "Углерод"
	id = "carbon"
	description = "Химический элемент. Строительный материал всего живого."
	reagent_state = SOLID
	color = "#1c1300" // rgb: 30, 20, 0
	taste_message = "карандаш или что-то такое"
	custom_metabolism = 0.01

/datum/reagent/carbon/reaction_turf(var/turf/T, var/volume)
	. = ..()
	if(!istype(T, /turf/space))
		var/obj/effect/decal/cleanable/dirt/dirtoverlay = locate(/obj/effect/decal/cleanable/dirt, T)
		if (!dirtoverlay)
			dirtoverlay = new/obj/effect/decal/cleanable/dirt(T)
			dirtoverlay.alpha = volume * 30
		else
			dirtoverlay.alpha = min(dirtoverlay.alpha + volume * 30, 255)

/datum/reagent/chlorine
	name = "Хлор"
	id = "chlorine"
	description = "Химический элемент с характерным запахом."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	overdose = REAGENTS_OVERDOSE
	taste_message = "что-то специфическое"

/datum/reagent/chlorine/on_general_digest(mob/living/M)
	..()
	M.take_bodypart_damage(1 * REM, 0)

/datum/reagent/fluorine
	name = "Фтор"
	id = "fluorine"
	description = "Высокореактивный химический элемент."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	overdose = REAGENTS_OVERDOSE
	taste_message = "зубную пасту"

/datum/reagent/fluorine/on_general_digest(mob/living/M)
	..()
	M.adjustToxLoss(REM)

/datum/reagent/sodium
	name = "Натрий"
	id = "sodium"
	description = "Химический элемент, охотно реагирует с водой."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	taste_message = "ужасную ошибку"
	custom_metabolism = 0.01

/datum/reagent/phosphorus
	name = "Фосфор"
	id = "phosphorus"
	description = "Химический элемент. Основа биологических энергоносителей."
	reagent_state = SOLID
	color = "#832828" // rgb: 131, 40, 40
	taste_message = "ошибочный выбор"
	custom_metabolism = 0.01

/datum/reagent/phosphorus/on_diona_digest(mob/living/M)
	..()
	M.adjustBruteLoss(-REM)
	M.adjustOxyLoss(-REM)
	M.adjustToxLoss(-REM)
	M.adjustFireLoss(-REM)
	M.nutrition += REM
	return FALSE

/datum/reagent/lithium
	name = "Литий"
	id = "lithium"
	description = "Химический элемент. Используется как антидепрессант."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	overdose = REAGENTS_OVERDOSE
	taste_message = "счастье"
	restrict_species = list(IPC, DIONA)

/datum/reagent/lithium/on_general_digest(mob/living/M)
	..()
	if(M.canmove && !M.incapacitated() && istype(M.loc, /turf/space))
		step(M, pick(cardinal))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))

/datum/reagent/sugar
	name = "Сахар"
	id = "sugar"
	description = "Органическое соединение широко известное как столовый сахар и иногда называемое сахароза. Эта белая кристаллическая пыль без запаха имеет приятный сладкий вкус."
	reagent_state = SOLID
	color = "#ffffff" // rgb: 255, 255, 255
	taste_message = "сладость"

	needed_aspects = list(ASPECT_FOOD = 1)

/datum/reagent/sugar/on_general_digest(mob/living/M)
	..()
	M.nutrition += 4 * REM

/datum/reagent/radium
	name = "Радий"
	id = "radium"
	description = "Радий это щелочноземельный металл. Он чрезвычайно радиоактивен."
	reagent_state = SOLID
	color = "#c7c7c7" // rgb: 199,199,199
	taste_message = "горечь"

/datum/reagent/radium/on_general_digest(mob/living/M)
	..()
	M.apply_effect(2 * REM,IRRADIATE, 0)
	// radium may increase your chances to cure a disease
	if(istype(M,/mob/living/carbon)) // make sure to only use it on carbon mobs
		var/mob/living/carbon/C = M
		if(C.virus2.len)
			for(var/ID in C.virus2)
				var/datum/disease2/disease/V = C.virus2[ID]
				if(prob(5))
					if(prob(50))
						M.radiation += 50 // curing it that way may kill you instead
						var/mob/living/carbon/human/H
						if(istype(C,/mob/living/carbon/human))
							H = C
						if(!H || (H.species && !H.species.flags[RAD_ABSORB]))
							M.adjustToxLoss(100)
					M:antibodies |= V.antigen

/datum/reagent/radium/reaction_turf(turf/T, volume)
	. = ..()
	if(volume >= 3)
		if(!istype(T, /turf/space))
			var/obj/effect/decal/cleanable/greenglow/glow = locate(/obj/effect/decal/cleanable/greenglow, T)
			if(!glow)
				new /obj/effect/decal/cleanable/greenglow(T)

/datum/reagent/iron
	name = "Железо"
	id = "iron"
	description = "Чистое железо это металл."
	reagent_state = SOLID
	color = "#c8a5dc" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	taste_message = "металл"

/datum/reagent/gold
	name = "Золото"
	id = "gold"
	description = "Золото это плотный, мягкий, блестящий металл. Самый ковкий и пластичный из известных."
	reagent_state = SOLID
	color = "#f7c430" // rgb: 247, 196, 48
	taste_message = "роскошь"

	needed_aspects = list(ASPECT_GREED = 1)

/datum/reagent/silver
	name = "Серебро"
	id = "silver"
	description = "Мягкий, белый, блестящий переходный металл. Он имеет самую высокую электропроводность среди всех элементов и самую высокую теплопроводность среди всех металлов."
	reagent_state = SOLID
	color = "#d0d0d0" // rgb: 208, 208, 208
	taste_message = "немного роскоши"

	needed_aspects = list(ASPECT_GREED = 1)

/datum/reagent/uranium
	name ="Уран"
	id = "uranium"
	description = "Серебристо-белый металлический химический элемент из ряда актинидов, слаборадиоактивный."
	reagent_state = SOLID
	color = "#b8b8c0" // rgb: 184, 184, 192
	taste_message = "альфа-частицы"

/datum/reagent/uranium/on_general_digest(mob/living/M)
	..()
	M.apply_effect(1, IRRADIATE, 0)

/datum/reagent/uranium/reaction_turf(turf/T, volume)
	. = ..()
	if(volume >= 3)
		if(!istype(T, /turf/space))
			var/obj/effect/decal/cleanable/greenglow/glow = locate(/obj/effect/decal/cleanable/greenglow, T)
			if(!glow)
				new /obj/effect/decal/cleanable/greenglow(T)

/datum/reagent/aluminum
	name = "Алюминий"
	id = "aluminum"
	description = "Серебристо-белый и пластичный член подгруппы химических элементов бора."
	reagent_state = SOLID
	color = "#a8a8a8" // rgb: 168, 168, 168
	taste_message = null

/datum/reagent/silicon
	name = "Кремний"
	id = "silicon"
	description = "Четырехвалентный металлоид. Кремний менее реактивен, чем его химический аналог - углерод."
	reagent_state = SOLID
	color = "#a8a8a8" // rgb: 168, 168, 168
	taste_message = "центральный процессор"
