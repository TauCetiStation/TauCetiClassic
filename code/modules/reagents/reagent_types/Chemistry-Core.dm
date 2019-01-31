/datum/reagent/water
	name = "Water"
	id = "water"
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
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

			if(H.species && H.species.name in list(HUMAN, UNATHI, TAJARAN))
				if(H.hair_painted && !(H.head && ((H.head.flags & BLOCKHAIR) || (H.head.flags & HIDEEARS))) && H.h_style != "Bald")
					H.dyed_r_hair = Clamp(round(H.dyed_r_hair * volume_coefficient + ((H.r_hair * volume) / 10)), 0, 255)
					H.dyed_g_hair = Clamp(round(H.dyed_g_hair * volume_coefficient + ((H.g_hair * volume) / 10)), 0, 255)
					H.dyed_b_hair = Clamp(round(H.dyed_b_hair * volume_coefficient + ((H.b_hair * volume) / 10)), 0, 255)
					if(H.dyed_r_hair == H.r_hair && H.dyed_g_hair == H.g_hair && H.dyed_b_hair == H.b_hair)
						H.hair_painted = FALSE
						changes_occured = TRUE
				if(H.facial_painted && !((H.wear_mask && (H.wear_mask.flags & HEADCOVERSMOUTH)) || (H.head && (H.head.flags & HEADCOVERSMOUTH))) && H.f_style != "Shaved")
					H.dyed_r_facial = Clamp(round(H.dyed_r_facial * volume_coefficient + ((H.r_facial * volume) / 10)), 0, 255)
					H.dyed_g_facial = Clamp(round(H.dyed_g_facial * volume_coefficient + ((H.g_facial * volume) / 10)), 0, 255)
					H.dyed_b_facial = Clamp(round(H.dyed_b_facial * volume_coefficient + ((H.b_facial * volume) / 10)), 0, 255)
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

/datum/reagent/water/holywater // May not be a "core" reagent, but I decided to keep the subtypes near  their parents.
	name = "Holy Water"
	id = "holywater"
	description = "An ashen-obsidian-water mix, this solution will alter certain sections of the brain's rationality."
	color = "#e0e8ef" // rgb: 224, 232, 239

/datum/reagent/water/holywater/on_general_digest(mob/living/M)
	..()
	if(holder.has_reagent("unholywater"))
		holder.remove_reagent("unholywater", 2 * REM)
	if(ishuman(M) && iscultist(M) && prob(10))
		ticker.mode.remove_cultist(M.mind)
		M.visible_message("<span class='notice'>[M]'s eyes blink and become clearer.</span>",
				          "<span class='notice'>A cooling sensation from inside you brings you an untold calmness.</span>")

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
	name = "Unholy Water"
	id = "unholywater"
	description = "A corpsen-ectoplasmic-water mix, this solution could alter concepts of reality itself."
	data = 1
	color = "#C80064" // rgb: 200,0, 100

/datum/reagent/water/unholywater/on_general_digest(mob/living/M)
	..()
	if(iscultist(M) && prob(10))
		switch(data)
			if(1 to 30)
				M.heal_bodypart_damage(REM, REM)
			if(30 to 60)
				M.heal_bodypart_damage(2 * REM, 2 * REM)
			if(60 to INFINITY)
				M.heal_bodypart_damage(3 * REM, 3 * REM)
	else if(!iscultist(M))
		switch(data)
			if(1 to 20)
				M.make_jittery(3)
			if(20 to 40)
				M.make_jittery(6)
				if(prob(15))
					M.sleeping += 1
			if(40 to 80)
				M.make_jittery(12)
				if(prob(30))
					M.sleeping += 1
			if(80 to INFINITY)
				M.sleeping += 1
	data++

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

/datum/reagent/acetone
	name = "Acetone"
	id = "acetone"
	description = "A colorless liquid solvent used in chemical synthesis."
	taste_message = "acid"
	reagent_state = LIQUID
	color = "#808080"
	custom_metabolism = REAGENTS_METABOLISM * 0.2

/datum/reagent/acetone/on_general_digest(mob/living/M)
	M.adjustToxLoss(REAGENTS_METABOLISM * 0.7) //Default toxin damage

/datum/reagent/aluminum
	name = "Aluminum"
	id = "aluminum"
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = SOLID
	color = "#A8A8A8"
	taste_message = "metal"

/datum/reagent/ammonia
	name = "Ammonia"
	id = "ammonia"
	taste_message = "mordant"
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = LIQUID
	color = "#404030"
	custom_metabolism = REAGENTS_METABOLISM * 0.5
	overdose = 5

/datum/reagent/ammonia/on_general_digest(mob/living/M)
	M.adjustToxLoss(REAGENTS_METABOLISM * 0.35)

/datum/reagent/ammonia/on_diona_digest(mob/living/M)
	..()
	M.nutrition += 1 * REM
	return FALSE

/datum/reagent/ammonia/on_vox_digest(mob/living/M)
	..()
	M.adjustOxyLoss(-2 * REAGENTS_METABOLISM)
	return FALSE

/datum/reagent/carbon
	name = "Carbon"
	id = "carbon"
	description = "A chemical element, the builing block of life."
	reagent_state = SOLID
	color = "#1C1300" // rgb: 30, 20, 0
	taste_message = "like a pencil or something"
	custom_metabolism = 0.01

/datum/reagent/carbon/reaction_turf(var/turf/T, var/volume)
	src = null
	if(!istype(T, /turf/space))
		var/obj/effect/decal/cleanable/dirt/dirtoverlay = locate(/obj/effect/decal/cleanable/dirt, T)
		if (!dirtoverlay)
			dirtoverlay = new/obj/effect/decal/cleanable/dirt(T)
			dirtoverlay.alpha = volume * 30
		else
			dirtoverlay.alpha = min(dirtoverlay.alpha + volume * 30, 255)

/datum/reagent/copper
	name = "Copper"
	id = "copper"
	description = "A highly ductile metal."
	color = "#6E3B08"
	taste_message = "copper"
	custom_metabolism = 0.01

/datum/reagent/fuel
	name = "Welding fuel"
	id = "fuel"
	description = "Required for welders. Flamable."
	reagent_state = LIQUID
	color = "#660000"
	overdose = REAGENTS_OVERDOSE
	taste_message = "motor oil"

/datum/reagent/fuel/reaction_obj(obj/O, volume)
	var/turf/the_turf = get_turf(O)
	if(!the_turf)
		return //No sense trying to start a fire if you don't have a turf to set on fire. --NEO
	new /obj/effect/decal/cleanable/liquid_fuel(the_turf, volume)

/datum/reagent/fuel/reaction_turf(turf/T, volume)
	new /obj/effect/decal/cleanable/liquid_fuel(T, volume)

/datum/reagent/fuel/on_general_digest(mob/living/M)
	..()
	M.adjustToxLoss(1)

/datum/reagent/fuel/reaction_mob(mob/living/M, method=TOUCH, volume)//Splashing people with welding fuel to make them easy to ignite!
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		M.adjust_fire_stacks(volume / 10)

/datum/reagent/fuel/hydrazine
	name = "Hydrazine"
	id = "hydrazine"
	description = "A toxic, colorless, flammable liquid with a strong ammonia-like odor, in hydrate form."
	taste_message = "sweet tasting metal"
	reagent_state = LIQUID
	color = "#808080"

/datum/reagent/fuel/hydrazine/on_general_digest(mob/living/M)
	M.adjustToxLoss(1.5)

/datum/reagent/iron
	name = "Iron"
	id = "iron"
	description = "Pure iron is a metal."
	reagent_state = SOLID
	color = "#C8A5DC"
	overdose = REAGENTS_OVERDOSE
	taste_message = "metal"
	restrict_species = list(IPC, DIONA)

/datum/reagent/lithium
	name = "Lithium"
	id = "lithium"
	description = "A chemical element, used as antidepressant."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	overdose = REAGENTS_OVERDOSE
	taste_message = "happiness"
	restrict_species = list(IPC, DIONA)

/datum/reagent/lithium/on_general_digest(mob/living/M)
	..()
	if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
		step(M, pick(cardinal))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))

/datum/reagent/mercury
	name = "Mercury"
	id = "mercury"
	description = "A chemical element."
	reagent_state = LIQUID
	color = "#484848"
	overdose = REAGENTS_OVERDOSE
	taste_message = "druggie poison"
	restrict_species = list(IPC, DIONA)

/datum/reagent/mercury/on_general_digest(mob/living/M)
	..()
	if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
		step(M, pick(cardinal))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))
	M.adjustBrainLoss(2)

/datum/reagent/phosphorus
	name = "Phosphorus"
	id = "phosphorus"
	description = "A chemical element, the backbone of biological energy carriers."
	reagent_state = SOLID
	color = "#832828"
	taste_message = "vinegar"
	custom_metabolism = REAGENTS_METABOLISM * 0.5

/datum/reagent/phosphorus/on_diona_digest(mob/living/M)
	..()
	M.adjustBruteLoss(-REM)
	M.adjustOxyLoss(-REM)
	M.adjustToxLoss(-REM)
	M.adjustFireLoss(-REM)
	M.nutrition += REM
	return FALSE

/datum/reagent/potassium
	name = "Potassium"
	id = "potassium"
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	reagent_state = SOLID
	color = "#A0A0A0"
	taste_message = "sweetness"

/datum/reagent/radium
	name = "Radium"
	id = "radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = SOLID
	color = "#C7C7C7" // rgb: 199,199,199
	taste_message = "bonehurting juice"

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
	src = null
	if(volume >= 3)
		if(!istype(T, /turf/space))
			var/obj/effect/decal/cleanable/greenglow/glow = locate(/obj/effect/decal/cleanable/greenglow, T)
			if(!glow)
				new /obj/effect/decal/cleanable/greenglow(T)

/datum/reagent/silicon
	name = "Silicon"
	id = "silicon"
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	reagent_state = SOLID
	color = "#A8A8A8"
	taste_message = "a CPU"

/datum/reagent/sodium
	name = "Sodium"
	id = "sodium"
	description = "A chemical element, readily reacts with water."
	reagent_state = SOLID
	color = "#808080"
	taste_message = "salty metal"

/datum/reagent/sugar
	name = "Sugar"
	id = "sugar"
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
	reagent_state = SOLID
	color = "#FFFFFF"
	taste_message = "sweetness"

/datum/reagent/sugar/on_general_digest(mob/living/M)
	..()
	M.nutrition += REM

/datum/reagent/sulfur
	name = "Sulfur"
	id = "sulfur"
	description = "A chemical element with a pungent smell."
	reagent_state = SOLID
	color = "#BF8C00"
	taste_message = "old eggs"

/datum/reagent/gold
	name = "Gold"
	id = "gold"
	description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
	reagent_state = SOLID
	color = "#F7C430" // rgb: 247, 196, 48
	taste_message = "expensive metal"

/datum/reagent/silver
	name = "Silver"
	id = "silver"
	description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
	reagent_state = SOLID
	color = "#D0D0D0" // rgb: 208, 208, 208
	taste_message = "expensive yet reasonable metal"

/datum/reagent/uranium
	name ="Uranium"
	id = "uranium"
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = SOLID
	color = "#B8B8C0" // rgb: 184, 184, 192
	taste_message = "the inside of a reactor"

/datum/reagent/uranium/on_general_digest(mob/living/M)
	..()
	M.apply_effect(1, IRRADIATE, 0)

/datum/reagent/uranium/reaction_turf(turf/T, volume)
	src = null
	if(volume >= 3)
		if(!istype(T, /turf/space))
			var/obj/effect/decal/cleanable/greenglow/glow = locate(/obj/effect/decal/cleanable/greenglow, T)
			if(!glow)
				new /obj/effect/decal/cleanable/greenglow(T)

/datum/reagent/hydrogen
	name = "Hydrogen"
	id = "hydrogen"
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	reagent_state = GAS
	color = "#808080"
	taste_message = null
