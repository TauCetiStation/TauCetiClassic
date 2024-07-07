/*
Как это должно работать

Когда ты берешь расу PLUVIAN, тебя сразу заносит в members /datum/religion/pluvia

add_member выдает соответствующие спеллы и заводит нужные регистрации сигналов

remove_member забирает спеллы и регистрации

У этой религии заведены 5 заповедей, которые нельзя нарушать. Под каждую заповедь заведен соотвествующий прок
За нарушение заповеди mob получает haram_point, превышение лимита которого mob выгоняется из религии

1) /datum/religion/pluvia/proc/harm_haram - принимает сигналы атак. Безоружные удары, выстрелы, броски, вскрытия горла ножом, доставание мозга,
удары предметами и другие явно агрессивные дейстивия накидывают тут haram_point

Дизармы, стан дубиной, удары деффибами, шприцы, автоинджекторы, удар предметом без урона и т.д. игнорируются этим проком

2) /datum/religion/pluvia/proc/suicide_haram - принимает сигналы от суицида. Я вспомнил только петлю и выстрел в рот.

3) /datum/religion/pluvia/proc/drunk_haram - принимает сигнал от бухла и наркотиков.
Если упороться или довести алкогольное состояние до второй стадии, ты мнговенно трезвлеешь и тебе накидывает харам.
Я осознано не зовел проверку на то, сам ли он выпил или его напоили.
Это сделано для того чтобы у злоумышленников была возможность быстро накинуть харам_поинтов и только потом убить плувийца без последствий в виде звонков с того света.

4) /datum/religion/pluvia/proc/drunk_haram - Если ешь палочками - все ок. Ешь руками или вилкой - лови харам поинты

5) /datum/religion/pluvia/proc/carpet_haram - Если ходишь по ковру в обуви. Долго объяснять, просто нельзя и все.

У всех /human появилась новая переменная - social_credit

Для плувийцев она важна, потому что она определяет попадет ли плувиец в рай после смерти
Для всех остальных это возможность поднимать social_credit плувийцам.

Плувийский спелл - /obj/effect/proc_holder/spell/create_bless_vote
создает рекомендательное письмо, которое и повышает social_credit owner-а письма за счет social_сredit подписавшего

Разные расы стартуют с разным запасом social_credit

1 )Все /human, кроме перечисленных ниже начинают с social_credit = 1. Соответственно они могут подписать кому-то рекомендательное письмо только один раз
2) Плувийцы начинают с нулевым запасом social_credit, потому что предполагается, что свой social_credit они потратили еще до начала смены и теперь им надо фармить их прямо на станции.
3) Дионы начинают с 3 social_credit, потому что диона это много нимф, которые сплелись в месте. У самых больших и жирных есть по 1 social_credit, а в сумме получается 3. Получается аж 3 возможности подписать письмо
4) СПУ начинают с 0 social_credit, потому что у них нет души
5) Големы начинают с 0 social_credit, потому что они подневольные и не могут за себя отвечать
6) Подмены начинают с 0 social_credit, потому что они слишком молодые чтобы голосовать. (И чтобы плувийцы social_credit не фармили с грядки)

Кроме собственно расы, на social_credit влияет еще наличие импланта лояльности и майндщилда.
Если в тебе такие импланты, то твои сошиал_кредиты обнуляются.
Это сделано для того, чтобы плувийцы (раса с самым большим ролькохант потенциалом) не шла в сб и не помогала сб и главам ловить ролей за social_credit.
Раса дизайнилась именно под социалку с обычным персоналом и с ролями.

Если перед смертью плувиец успел собрать social_credit_threshold, то в его /datum/species/pluvian/handle_death происходит /mob/living/carbon/human/proc/reborn(), который создаем ему тело в раю (место которое будет на цк слое)
Предполагается, что в раю уже можно бухать-курить, ходить по коврам и т.д. Так что этот моб remove_member из /datum/religion/pluvia, потому что в сигналах больше нет смысла.
Также у моба стираются все спеллы - просто на всякий случай.

Если тело плувийца пытаются реанимировать, а сам он успешно попал в рай, ему предложат вернуться в тело через /mob/living/carbon/human/proc/return_to_body_dialog()
При согласии, он опять влетает в свое тело и его отписывают от всех haram сигналов (потому что он теперь живой святой и ему теперь можно грешить при жизни).
Крутые светящиеся глаза бонусом. У живых святых нет /obj/effect/proc_holder/spell/create_bless_vote,
потому что им больше не надо собирать собирать письма, они и так и так после смерти попадут снова в рай.
Зато им выдадут 2 social_credit, которые они смогут кому-то передеать, если захотят.
Все спеллы которые были у него при жизни возвращаются через список spell_to_remember, который заполняется в reborn()

Плувийский спелл - /obj/effect/proc_holder/spell/no_target/ancestor_call создан для связи живых плувийцев и плувийцев в раю.

В раю стоят /obj/structure/pluvia_gong. Если живой плувиец инициатор ancestor_call, то ему создают копию его тела в раю на одном из свободных в данный момент гонгов.

Копия обладает спрайтом звоняещего, но с прозрачностью как у госта. Когда плувиец говорит, фальшивка повторяет за ним все слова. Таким образом можно болтать с мертвыми.
Если мертвый плувиец хочет выйти на связь с живым, он может ударить по гонгу специальной палочкой и выбрать себе цель звонка.
Цель звонка оповестят об этом специальным алертом и звуком гонга. Звонок можно сбросить, нажав на алерт
Если живой плувиец захочет поболтать, то он может просто кастануть ancestor_call и спелл сработает именно к тому гонгу, откуда ему звонили.
За сеанс связи нужно платить 2-мя брейндемедж.

social_credit_threshold должен высчитываться вначале смены исходя из списка живых игроков по такой формуле:

social_credit_threshold = (кол-во людей на смене)/10 + 2.

haram_threshold тоже должен как-то высчитываться, но я еще не придумал по какой формуле это будет справедливо.

*/
/datum/religion/pluvia
	name = "Путь Плувиийца"
	deity_names_by_name = list(
		"Путь Плувиийца" = list("Лунарис")
	)
	bible_info_by_name = list(
		"Путь Плувиийца" = /datum/bible_info/chaplain/bible, //потом переделать на другую
	)

	emblem_info_by_name = list(
		"Путь Плувиийца" = "christianity", //потом переделать на другую
	)

	altar_info_by_name = list(
		"Путь Плувиийца" = "chirstianaltar",
	)
	carpet_type_by_name = list(
		"Путь Плувиийца" = /turf/simulated/floor/carpet,
	)
	style_text = "piety"
	symbol_icon_state = null
	var/haram_harm = 2
	var/haram_drunk = 1
	var/haram_food = 0.5
	var/haram_carpet = 0.25

/datum/religion/pluvia/proc/harm_haram(datum/source, mob/living/carbon/human/target)
	var/mob/living/carbon/human/attacker  = source
	if(istype(target.my_religion, /datum/religion/pluvia) ||target.blessed)
		if(attacker.haram_point < haram_threshold)
			attacker.haram_point += haram_harm
			attacker.playsound_local(null, 'sound/effects/haram.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			to_chat(attacker, "<span class='warning'>\ <font size=3>Вы нарушаете первую заповедь!</span></font>")
		else
			global.pluvia_religion.remove_member(attacker, HOLY_ROLE_PRIEST)
			attacker.social_credit = 0
			to_chat(attacker, "<span class='warning'>\ <font size=5>Врата рая закрыты для вас. Ищите себе другого покровителя</span></font>")
			attacker.playsound_local(null, 'sound/effects/heaven_fail.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/datum/religion/pluvia/proc/suicide_haram(mob/living/carbon/human/target)
	global.pluvia_religion.remove_member(target, HOLY_ROLE_PRIEST)
	target.social_credit = 0
	to_chat(target, "<span class='warning'>\ <font size=5>Вы нарушили вторую заповедь. Врата рая закрыты для вас. Ищите себе другого покровителя</span></font>")
	target.playsound_local(null, 'sound/effects/heaven_fail.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/datum/religion/pluvia/proc/drunk_haram(mob/living/carbon/human/target)
	if(target.haram_point < haram_threshold)
		for(var/datum/reagent/R in target.reagents.reagent_list)
			if(istype(R, /datum/reagent/consumable/ethanol) || istype(R, /datum/reagent/space_drugs) || istype(R,/datum/reagent/ambrosium))
				target.reagents.del_reagent(R.id)
		target.SetDrunkenness(0)
		target.setDrugginess(0)
		target.haram_point += haram_drunk
		target.playsound_local(null, 'sound/effects/haram.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		to_chat(target, "<span class='warning'>\ <font size=3>Вы нарушаете третью заповедь!</span></font>")
	else
		global.pluvia_religion.remove_member(target, HOLY_ROLE_PRIEST)
		to_chat(target, "<span class='warning'>\ <font size=5>Врата рая закрыты для вас. Ищите себе другого покровителя</span></font>")
		target.playsound_local(null, 'sound/effects/heaven_fail.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/datum/religion/pluvia/proc/food_haram(datum/source, obj/item/weapon/reagent_containers/food/snacks/target)
	var/mob/living/carbon/human/H = source
	if(istype(target.loc, /obj/item/weapon/kitchen/utensil/fork/sticks))
		return
	if(H.haram_point < haram_threshold)
		H.haram_point += haram_food
		H.playsound_local(null, 'sound/effects/haram.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		to_chat(H, "<span class='warning'>\ <font size=3>Вы нарушаете четвертую заповедь!</span></font>")
	else
		global.pluvia_religion.remove_member(H, HOLY_ROLE_PRIEST)
		H.social_credit = 0
		to_chat(H, "<span class='warning'>\ <font size=5>Врата рая закрыты для вас. Ищите себе другого покровителя</span></font>")
		H.playsound_local(null, 'sound/effects/heaven_fail.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/datum/religion/pluvia/proc/carpet_haram(mob/living/carbon/human/target)
	if(target.shoes)
		if(target.haram_point < haram_threshold)
			target.haram_point += haram_carpet
			target.playsound_local(null, 'sound/effects/haram.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			to_chat(target, "<span class='warning'>\ <font size=3>Вы нарушаете пятую заповедь!</span></font>")
		else
			global.pluvia_religion.remove_member(target, HOLY_ROLE_PRIEST)
			target.social_credit = 0
			to_chat(target, "<span class='warning'>\ <font size=5>Врата рая закрыты для вас. Ищите себе другого покровителя</span></font>")
			target.playsound_local(null, 'sound/effects/heaven_fail.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/turf/simulated/floor/carpet/Entered(atom/movable/O)
	..()
	if(ishuman(O))
		SEND_SIGNAL(O, COMSIG_HUMAN_ON_CARPET, src)

/datum/religion/pluvia/add_member(mob/living/carbon/human/H)
	. = ..()
	if(ispluvian(H))
		H.AddSpell(new /obj/effect/proc_holder/spell/create_bless_vote)
		H.AddSpell(new /obj/effect/proc_holder/spell/no_target/ancestor_call)
	RegisterSignal(H, COMSIG_HUMAN_HARMED_OTHER, PROC_REF(harm_haram))
	RegisterSignal(H, COMSIG_HUMAN_TRY_SUICIDE, PROC_REF(suicide_haram))
	RegisterSignal(H, COMSIG_HUMAN_IS_DRUNK, PROC_REF(drunk_haram))
	RegisterSignal(H, COMSIG_HUMAN_EAT, PROC_REF(food_haram))
	RegisterSignal(H, COMSIG_HUMAN_ON_CARPET, PROC_REF(carpet_haram))

/datum/religion/pluvia/remove_member(mob/M)
	. = ..()
	for(var/obj/effect/proc_holder/spell/create_bless_vote/spell_to_remove in M.spell_list)
		M.RemoveSpell(spell_to_remove)
	for(var/obj/effect/proc_holder/spell/no_target/spell_to_remove in M.spell_list)
		M.RemoveSpell(spell_to_remove)
	UnregisterSignal(M, list(COMSIG_HUMAN_HARMED_OTHER, COMSIG_PARENT_QDELETING))
	UnregisterSignal(M, list(COMSIG_HUMAN_TRY_SUICIDE, COMSIG_PARENT_QDELETING))
	UnregisterSignal(M, list(COMSIG_HUMAN_IS_DRUNK, COMSIG_PARENT_QDELETING))
	UnregisterSignal(M, list(COMSIG_HUMAN_EAT, COMSIG_PARENT_QDELETING))
	UnregisterSignal(M, list(COMSIG_HUMAN_ON_CARPET, COMSIG_PARENT_QDELETING))

/datum/religion/pluvia/setup_religions()
	global.pluvia_religion = src
	all_religions += src
