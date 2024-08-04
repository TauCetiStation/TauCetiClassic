/obj/item/weapon/book/skillbook
	name = "Skillbook"

	unique = TRUE
	dat = FALSE // no content, just skill boosts

	// will be set automatically
	var/datum/skillset/bonus_skillset

	var/list/skills

	// co-authored with ChatGPT!
	var/static/list/narrative_messages = list(
		"Этот абзац кажется бесконечным.",
		"Вы на автомате пятый раз перечитываете абзац.",
		"Вы замечаете мелкие ошибки в тексте и начинаете их исправлять.",
		"Вы ничего не поняли из этой главы.",
		"Кто-то подрисовал этому портрету усы.",
		"Вы зеваете и случайно пролистываете несколько страниц.",
		"Книга упорно сопротивляется попыткам быть прочитанной.",
		"Вы находите закладку с надписью 'Сдать в библиотеку до [game_year-10]'.",
		"Кажется, кто-то пролил здесь кофе.",
		"На этом абзаце у вас начинает косить глаза.",
		"Вы замечаете каракули на полях, изображающие схему какого-то непонятного устройства.",
		"Похоже, кто-то использовал страницу как подставку для чашки.",
		"Вы пробуете читать вслух, но книга всё равно не становится интереснее.",
		"Кажется, книга становится толще по мере чтения.",
		"Вы находите смешной анекдот, написанный на полях.",
		"Вы замечаете, что текст периодически меняет шрифт без видимой причины.",
		"Вы читаете главу и понимаете, что это описание вечеринки на прошлой неделе.",
		"Каждая страница кажется более скучной, чем предыдущая.",
		"Кто-то выделил маркером всю страницу.",
		"На этой странице кто-то нарисовал карту станции, но она больше похожа на лабиринт.",
		"Вы замечаете, что кто-то выделил маркером все скучные места... и это почти вся книга.",
		"Вы видите заметку: 'Не забудьте покормить карпов в резервуаре'.",
		"Вы находите страницу с нарисованным планом побега из брига.",
		"Вы замечаете, что кто-то записал сюда результаты недавнего эксперимента на полигоне.",
		"На полях книги вы находите список лучших пряток в технических тоннелях.",
		"Вы находите карту станции с помеченным тайником, но к вашему сожалению это другая станция.",
		"На этой странице кто-то оставил список любимых трюков клоуна.",
		"На этой странице кто-то записал данные аномалии.",
		"Автор пытается быть смешным, но у него плохо получается.",
	)

/obj/item/weapon/book/skillbook/atom_init()
	. = ..()

	title = name

	desc = "Boosts work efficiency for following tasks while in hands:\n"

	bonus_skillset = new

	for(var/skill_type in skills)
		var/level = skills[skill_type]
		bonus_skillset.set_value(skill_type, level)

		var/datum/skill/S = all_skills[skill_type]
		desc += "[S.name]: up to [S.custom_ranks[level + 1]] level; "

/obj/item/weapon/book/skillbook/equipped(mob/living/user, slot)
	..()

	if(!istype(user))
		return

	// well, about Ian - why not? idk if it even works
	if(slot == SLOT_L_HAND || slot == SLOT_R_HAND || (isIAN(user) && slot == SLOT_MOUTH))
		user.add_skills_buff(bonus_skillset)
	else
		user.remove_skills_buff(bonus_skillset)

/obj/item/weapon/book/skillbook/dropped(mob/living/user)
	..()

	if(!istype(user))
		return

	user.remove_skills_buff(bonus_skillset)

/obj/item/weapon/book/skillbook/proc/is_helpful(mob/living/user)
	var/datum/skills/user_skills = user.get_skills()

	for(var/skill in skills)
		if(user_skills.get_value(skill) < skills[skill])
			return TRUE
	return FALSE

/obj/item/weapon/book/skillbook/attack_self(mob/living/user)
	if(carved)
		handle_carved()
		return

	if(!istype(user))
		return

	if(is_helpful(user))
		to_chat(user, "<span class='notice'><span class='bold'>Эта книга будет вам полезна.</span> Это невозможно выучить за одну смену, достаточно просто иметь книгу под рукой. Но, видимо, скука взяла своё, так что вы начинаете перелистывать книгу.</span>")
	else
		to_chat(user, "<span class='notice'><span class='bold'>Эта книга бесполезна для вас.</span> Вы и так всё знаете. Но, видимо, скука взяла своё, так что вы начинаете перелистывать книгу.</span>")

	user.visible_message("[user] opens a book titled \"[src.title]\" and begins reading intently.")

	do_after(user, 30 SECONDS, target = src, extra_checks = CALLBACK(src, PROC_REF(narrative_message), user, src))

// just need it so i can inject messages in do_after
/obj/item/weapon/book/skillbook/proc/narrative_message(mob/user)
	if(prob(1))
		to_chat(user, "<span class='italics'>[pick(narrative_messages)]</span>")
	return TRUE

/* departments stuff */

/obj/item/weapon/book/skillbook/engineering
	name = "Skills 101: Engineering"
	icon_state = "Skillbook_engi"
	item_state = "Skillbook_engi"
	item_state_world = "Skillbook_engi_world"

	skills = list(
		/datum/skill/construction = SKILL_LEVEL_TRAINED,
		/datum/skill/engineering = SKILL_LEVEL_TRAINED,
		/datum/skill/atmospherics = SKILL_LEVEL_TRAINED,
		/datum/skill/civ_mech = SKILL_LEVEL_TRAINED,
	)

/obj/item/weapon/book/skillbook/medical
	name = "Skills 101: Medicine"
	icon_state = "Skillbook_med"
	item_state = "Skillbook_med"
	item_state_world = "Skillbook_med_world"

	skills = list(
		/datum/skill/medical = SKILL_LEVEL_TRAINED,
		/datum/skill/surgery = SKILL_LEVEL_TRAINED,
		/datum/skill/chemistry = SKILL_LEVEL_TRAINED,
	)

/obj/item/weapon/book/skillbook/science
	name = "Skills 101: Science"
	icon_state = "Skillbook_sci"
	item_state = "Skillbook_sci"
	item_state_world = "Skillbook_sci_world"

	skills = list(
		/datum/skill/research = SKILL_LEVEL_TRAINED,
		/datum/skill/medical = SKILL_LEVEL_NOVICE,
		/datum/skill/surgery = SKILL_LEVEL_NOVICE,
		/datum/skill/construction = SKILL_LEVEL_NOVICE,
		/datum/skill/engineering = SKILL_LEVEL_TRAINED,
		/datum/skill/chemistry = SKILL_LEVEL_NOVICE,
	)

/obj/item/weapon/book/skillbook/robust
	name = "Skills 101: Robust"
	icon_state = "Skillbook_robust"
	item_state = "Skillbook_robust"
	item_state_world = "Skillbook_robust_world"

	skills = list(
		/datum/skill/firearms = SKILL_LEVEL_TRAINED,
		/datum/skill/melee = SKILL_LEVEL_TRAINED,
		/datum/skill/combat_mech = SKILL_LEVEL_TRAINED,
		/datum/skill/police = SKILL_LEVEL_TRAINED,
	)

/* more specialized stuff */

/obj/item/weapon/book/skillbook/chemistry
	name = "Skills 101: Chemistry"
	icon_state = "Skillbook_chem"
	item_state = "Skillbook_chem"
	item_state_world = "Skillbook_chem_world"

	skills = list(
		/datum/skill/chemistry = SKILL_LEVEL_TRAINED,
	)

/obj/item/weapon/book/skillbook/surgery
	name = "Skills 101: Surgery"
	icon_state = "Skillbook_med"
	item_state = "Skillbook_med"
	item_state_world = "Skillbook_med_world"

	skills = list(
		/datum/skill/surgery = SKILL_LEVEL_TRAINED,
		/datum/skill/medical = SKILL_LEVEL_NOVICE,
	)

/obj/item/weapon/book/skillbook/exosuits
	name = "Skills 101: Exosuits"
	icon_state = "Skillbook_mech"
	item_state = "Skillbook_mech"
	item_state_world = "Skillbook_mech_world"

	skills = list(
		/datum/skill/civ_mech = SKILL_LEVEL_TRAINED,
		/datum/skill/combat_mech = SKILL_LEVEL_TRAINED,
	)


/datum/action/cooldown/skill_educate
	name = "Провести лекцию"
	check_flags = AB_CHECK_ALIVE | AB_CHECK_INCAPACITATED
	button_icon = 'icons/obj/library.dmi'
	button_icon_state = "book"
	cooldown_time = 5 MINUTE
	var/list/learners = list()
	var/learning = FALSE

/datum/action/cooldown/skill_educate/Checks()
	if(!IsAvailable())
		to_chat(owner, "<span class='notice'>Вы слишком устали, чтобы обучать кого-то ещё.</span>")
		return FALSE
	if(!ishuman(owner))
		to_chat(owner, "<span class='notice'>Вы должны быть человеком, чтобы кого-то обучить.</span>")
		return FALSE
	var/mob/living/carbon/human/H = owner
	if(!istype(H.get_active_hand(), /obj/item/weapon/book/skillbook))
		to_chat(owner, "<span class='notice'>Чтобы чему-то обучить, надо для начала взять нужную книгу в руки.</span>")
		return FALSE
	for(var/mob/living/carbon/human/learner in range(H.loc, 3))
		if(learner != owner && learner.buckled)
			learners += learner
	if(learners.len < 5)
		to_chat(owner, "<span class='notice'>Для проведения лекции нужно как минимум 5 слушающих.</span>")
		learners = list()
		return FALSE
	. = ..()

/datum/action/cooldown/skill_educate/Trigger()
	if(!Checks() || !owner)
		return

	owner.set_typing_indicator(TRUE)
	var/message
	input(owner, "Скажите что-то про тему лекции", "Вступительное слово", "Тема этой лекции ") as text|null
	owner.set_typing_indicator(FALSE)
	if(!message)
		to_chat(owner, "<span class='notice'>Лекция не может быть проведена без слов.</span>")
		return
	owner.say_verb(message)

	var/education_time = max(10, 20 - (length(sanitize_safe(message)) / 10)) SECOND

	var/mob/living/carbon/human/H = owner
	learning = TRUE

	owner.visible_message(
		"<span class='notice'>Учитель открывает книгу и начинает вести лекцию.</span>",
		"<span class='notice'>Вы открываете книгу и начинаете вести лекцию.</span>",
		"<span class='notice'>Вы слышите шелест бумаги и голос учителя, ведущего лекцию.</span>")

	for(var/mob/living/carbon/human/learner as anything in learners)
		educate(learner, education_time)

	if(do_after(owner, education_time, TRUE, owner))
		var/obj/item/weapon/book/skillbook/SB = H.get_active_hand()
		for(var/mob/living/carbon/human/learner as anything in learners)
			learner.add_skills_buff(SB.bonus_skillset)
		StartCooldown()
		learners = list()

	learning = FALSE


/datum/action/cooldown/skill_educate/proc/educate(mob/learner, education_time)
	set waitfor = FALSE
	if(!do_after(learner, education_time, FALSE, learner, extra_checks = CALLBACK(src, PROC_REF(is_learning))))
		learners -= learner

/datum/action/cooldown/skill_educate/proc/is_learning()
	return learning
