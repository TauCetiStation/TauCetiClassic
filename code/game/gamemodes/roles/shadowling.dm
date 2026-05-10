/datum/role/shadowling
	name = SHADOW
	id = SHADOW

	required_pref = ROLE_SHADOWLING
	restricted_jobs = list("AI", "Cyborg", "Security Cadet", "Security Officer", "Warden", "Head of Security", "Captain", "Blueshield Officer")
	restricted_species_flags = list(IS_SYNTHETIC)

	antag_hud_type = ANTAG_HUD_SHADOW
	antag_hud_name = "hudshadowling"

	logo_state = "shadowling-logo"

	skillset_type = /datum/skillset/shadowling
	change_to_maximum_skills = TRUE

/datum/role/shadowling/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, "<b>Вы - Шедоулинг. На данный момент, вы скрываетесь под личиной одного из сотрудников станции [station_name()].</b>")
	to_chat(antag.current, "<b>В этой слабой оболочке, вы способны лишь: Enthrall - поработить не просвещённого (имеет увеличенно время, если цель не ослабленна порабощенным), Hatch - облачиться в свою истинную форму (находится во вкладке Shadowling Evolution в верхней-правой части экрана), и Hivemind Commune - общаться с себе подобными братьями и рабами.</b>")
	to_chat(antag.current, "<b>Другие Шедоулинги являются вашими братьями и союзниками. Вы должны помогать им, как и они вам, для достижения общей цели.</b>")
	to_chat(antag.current, "<b>Если вы впервые играете за Шедоулинга, или хотите ознакомится с вашими способностями, перейдите на эту страницу нашей вики - https://wiki.taucetistation.org/Shadowling</b><br>")

	var/output_text = {"<font color='red'>============Внимание! Значительные тестовые изменения!============</font><BR>
	[sanitize("- Способность Enthrall имеет значительное замедление, если цель не была до этого ослабленна способностью тралла Threll's mark")]<BR>
	[sanitize("- В полной форме тень потеряла способность Glare (открывается при достижении 75% от необходимых для победы траллов). Ищите новые способы красть людей.")]<BR>
	[sanitize("- Тень не умирает от 1 выстрела лазера, а также получила часть слотов")]<BR>
	[sanitize("- Если вы поработили кого-то с меткой от тралла, тралл получает бонусы в порядке: лечение в темноте, слабое перемещение в тенях (слабый джаунт), глаза тени и усиление лечения (и начинает получать урон от света), глушение света, усиление лечения в темноте и урон на свету, а также становление новым тенелингом.")]<BR>
	"}
	var/datum/browser/popup = new(antag.current, "window=shd", nwidth = 600, nheight = 300)
	popup.set_content(output_text)
	popup.open()

/datum/role/shadowling/OnPostSetup(laterole)
	. = ..()
	var/mob/living/carbon/human/S = antag.current

	if(antag.assigned_role == "Clown")
		to_chat(S, "<span class='notice'>Ваша нечеловеческая природа позволила преодолеть вашего внутреннего клоуна.</span>")
		REMOVE_TRAIT(S, TRAIT_CLUMSY, GENETIC_MUTATION_TRAIT)

	S.verbs += /mob/living/carbon/human/proc/shadowling_hatch
	S.AddSpell(new /obj/effect/proc_holder/spell/targeted/enthrall)
	S.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind)
	RegisterSignal(S, COMSIG_MOB_DIED, PROC_REF(shadowling_death_signal))

/datum/role/shadowling/proc/shadowling_death_signal()
	SIGNAL_HANDLER
	to_chat(antag.current, "<span class='shadowling'><font size=3>asd</span></font>")
	to_chat(world, "<span class='shadowling'><font size=3>s</span></font>")
	var/shadowling_alive = FALSE
	for(var/datum/role/shadowling/S in faction.members)
		if(S.antag.current.stat != DEAD && ishuman(S.antag.current)) //&& S.antag.current != antag.current) //We have at least one S-ling alive
			shadowling_alive = TRUE
			break

	for(var/datum/role/thrall/T in faction.members)
		if(!T.antag.current)
			continue

		to_chat(T.antag.current, "<span class='shadowling'><font size=3>Sudden realization strikes you like a truck! ONE OF OUR MASTERS HAS DIED!!!</span></font>")

		if(shadowling_alive)
			continue
		SEND_SIGNAL(T.antag.current, COMSIG_CLEAR_MOOD_EVENT, "thralled")
		SEND_SIGNAL(T.antag.current, COMSIG_ADD_MOOD_EVENT, "master_died", /datum/mood_event/master_died)
		to_chat(T.antag.current, "<span class='shadowling'><font size=3>Последний мастер пал! Ваши оковы упали, вы потеряли смысл жизни! Почти... Нужно создать нового мастера! Соберите вокруг себя четверых живых и разумных гуманоидов, и произведите ритуал Возвышения!</span></font>")
		T.antag.current.AddSpell(new /obj/effect/proc_holder/spell/no_target/shadow_ascension)

/datum/role/shadowling/RemoveFromRole(datum/mind/M, msg_admins)
	for(var/I in list(/obj/effect/proc_holder/spell/targeted/enthrall,
		/obj/effect/proc_holder/spell/targeted/shadowling_hivemind))
		var/obj/effect/proc_holder/spell/S = antag.current.GetSpell(I)
		if(S)
			antag.current.RemoveSpell(S)

	M.current.verbs -= /mob/living/carbon/human/proc/shadowling_hatch

/datum/role/thrall
	name = SHADOW_THRALL
	id = SHADOW_THRALL

	antag_hud_type = ANTAG_HUD_SHADOW
	antag_hud_name = "hudthrall"

	logo_state = "thrall-logo"

	skillset_type = /datum/skillset/thrall
	change_to_maximum_skills = TRUE
	var/marks = 0
	var/stage = 0

/datum/role/thrall/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, "<b>Вы были порабощены Шедоулингом и обязаны выполнять любой приказ, и помогать ему в достижении его целей.</b>")
	to_chat(antag.current, "<span class='notice'><b>Hivemined Commune</b> позволит общаться с вашими собратьями и мастером.</span>")
	to_chat(antag.current, "<span class='notice'><b>Threll's Mark</b> позволяет ослабить душу схваченного человека, а если мастер его поработит, тебе достанется кусочек души. Души усиляют. И кто знает, быть может, следующим мастером станешь ты?</span>")

	var/output_text = {"<font color='red'>============Внимание! Значительные тестовые изменения!============</font><BR>
	[sanitize("- Способность Enthrall тенелинга имеет значительное замедление, если цель не была до этого ослабленна способностью тралла Threll's mark")]<BR>
	[sanitize("- В полной форме тень потеряла способность Glare (открывается при достижении 75% от необходимых для победы траллов). Ищите новые способы красть людей.")]<BR>
	[sanitize("- Тень не умирает от 1 выстрела лазера, а также получила часть слотов")]<BR>
	[sanitize("- Ваша способность значительно ускоряет порабощение жертвы тенелингом в его второй форме, при этом вы получаете бонусы в следующем порядке за каждую новую жертву: \
	1) Лечение в темноте <BR>\
	2) Слабое перемещение в тенях (слабый джаунт) <BR>\
	3) Глаза тени, усиление лечения в темноте, а также начинаете получать урон от света <BR>\
	4) Глушение света на манер тенелинга <BR>\
	5) Усиление лечения в темноте и урона на свету, усиление джаунта <BR>\
	6) Становление новым тенелингом.")]<BR>\
	"}
	var/datum/browser/popup = new(antag.current, "window=shd", nwidth = 600, nheight = 300)
	popup.set_content(output_text)
	popup.open()

/datum/role/thrall/OnPreSetup(greeting, custom)
	. = ..()
	antag.current.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind)
	var/obj/effect/proc_holder/spell/targeted/enthrall/thrall_mark/S = new()
	S.role = src
	antag.current.AddSpell(S)
	SEND_SIGNAL(antag.current, COMSIG_ADD_MOOD_EVENT, "thralled", /datum/mood_event/thrall)

/datum/role/thrall/RemoveFromRole(datum/mind/M, msg_admins)
	SEND_SIGNAL(antag.current, COMSIG_CLEAR_MOOD_EVENT, "thralled")

	for(var/I in list(/obj/effect/proc_holder/spell/targeted/enthrall/thrall_mark,
		/obj/effect/proc_holder/spell/no_target/shadow_ascension,
		/obj/effect/proc_holder/spell/targeted/shadowling_hivemind,
		/obj/effect/proc_holder/spell/aoe_turf/veil,
		/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shadow_walk/lesser))
		var/obj/effect/proc_holder/spell/S = antag.current.GetSpell(I)
		if(S)
			antag.current.RemoveSpell(S)

	..()

/datum/role/thrall/proc/get_mark()
	to_chat(antag.current, "<span class='shadowling'>Мастер принял подношение, и великодушно даровал тебе частицу духа Его нового раба!</span>")
	marks++
	if(marks > 1 && stage < 1)
		to_chat(antag.current, "<span class='shadowling'><i>Тьма сгущается в твоей душе, и ты получил <b>Дарование Тьмы</b>. Теперь Тьма будет лечить и помогать тебе, пускай и не столь сильно.</i></span>")
		antag.current.AddComponent(/datum/component/darkness_healing)
		stage++

	if(marks > 2 && stage < 2)
		to_chat(antag.current, "<span class='shadowling'><i>Тьма сгущается в твоей душе, и ты получил <b>Малое перемещение в тенях</b>. Позволяет тебе сбежать.</i></span>")
		antag.current.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shadow_walk/lesser)
		stage++

	if(marks > 3 && stage < 3)
		to_chat(antag.current, "<span class='shadowling'><i>Тьма сгущается в твоей душе, и ты получил <b>Озарение во тьме</b>. Твои глаза теперь источник ужаса для непрозревших, а ты можешь видеть во тьме отныне!.</i></span>")

		var/datum/component/darkness_healing/C = antag.current.GetComponent(/datum/component/darkness_healing)
		if(C)
			C.multiplier = 1.5
			C.damage_multiplier = 0.5

		var/mob/living/carbon/human/H = antag.current
		ADD_TRAIT(H, TRAIT_GLOWING_EYES, INNATE_TRAIT)
		H.regenerate_icons(TRUE)
		if(H.glasses)
			H.drop_from_inventory(H.glasses, get_turf(H))
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/night/shadowling, SLOT_GLASSES)
		stage++

	if(marks > 4 && stage < 4)
		to_chat(antag.current, "<span class='shadowling'><i>Тьма сгущается в твоей душе, и ты получил <b>Вуаль тьмы</b>. Позволяет тебе погружать окружающее пространство во тьму, как это делает Мастер.</i></span>")
		antag.current.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/veil)
		stage++

	if(marks > 5 && stage < 5)
		to_chat(antag.current, "<span class='shadowling'><i>Тьма сгущается в твоей душе, и ты улучшил <b>Малое перемещение в тенях</b>, а также стал более привержен ко тьме</i></span>")
		var/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/J = antag.current.GetSpell(/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shadow_walk/lesser)
		if(J)
			J.movement_cooldown = 2
			J.jaunt_duration = 7 SECONDS
			J.charge_max = 60 SECONDS

		var/datum/component/darkness_healing/C = antag.current.GetComponent(/datum/component/darkness_healing)
		if(C)
			C.multiplier = 2
			C.damage_multiplier = 1
		stage++

	if(marks > 6  && stage < 6)
		to_chat(antag.current, "<span class='shadowling'><i>Тьма сгущается в твоей душе, заполоняя её... И внезапно, ты понял... <b>Ты - Мастер!</b></i></span>")
		var/datum/faction/shadowlings/F = faction
		F.thrall2master(antag.current, src)

/datum/role/thrall/extraPanelButtons()
	var/dat = ..()
	dat += " - <a href='byond://?src=\ref[antag];mind=\ref[antag];role=\ref[src];get_mark=1;'>(Give mark point)</a>"
	dat += " - <a href='byond://?src=\ref[antag];mind=\ref[antag];role=\ref[src];get_shadow_ascension=1;'>(Give shadow ascension)</a>"
	return dat

/datum/role/thrall/RoleTopic(href, href_list, datum/mind/M, admin_auth)
	if(href_list["get_mark"])
		get_mark()
	if(href_list["get_shadow_ascension"])
		M.current.AddSpell(new /obj/effect/proc_holder/spell/no_target/shadow_ascension)
