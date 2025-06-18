/obj/effect/proc_holder/spell/targeted/projectile/magic_missile
	name = "Магическая Ракета"
	desc = "Заклинание выпускает несколько медленно летящих зарядов с самонаведением в ближайшие цели."

	school = "evocation"
	charge_max = 350
	clothes_req = 1
	invocation = "FORTI GY AMA"
	invocation_type = "shout"
	range = 7

	max_targets = 5
	sound = 'sound/magic/MAGIC_MISSILE.ogg'
	proj_icon_state = "magicm"
	proj_name = "a magic missile"
	proj_lingering = 1
	proj_type = /obj/effect/proc_holder/spell/targeted/inflict_handler/magic_missile

	proj_lifespan = 20
	proj_step_delay = 5

	proj_trail = 1
	proj_trail_lifespan = 5
	proj_trail_icon_state = "magicmd"

	action_icon_state = "magicm"

/obj/effect/proc_holder/spell/targeted/inflict_handler/magic_missile
	desc = "Какое-то богохульство."
	amt_stunned = 2
	amt_weakened = 5
	amt_dam_fire = 10
	sound = 'sound/magic/MAGIC_MISSILE.ogg'


/obj/effect/proc_holder/spell/targeted/inflict_handler/magic_missile/Click()
	if(loc && Adjacent(usr))
		qdel(src)
	else if(cast_check())
		choose_targets()
	return TRUE

/obj/effect/proc_holder/spell/targeted/genetic/mutate
	name = "Мутация"
	desc = "Это заклинание сделает вас халком и даст пострелять лазером из глаз, но недолго."

	school = "transmutation"
	charge_max = 400
	clothes_req = 1
	invocation = "BIRUZ BENNAR"
	invocation_type = "shout"
	message = "<span class='notice'>Вы чувствовать сила! Вы чувствуете давление в области глаз!</span>"
	range = -1
	include_user = 1
	sound = 'sound/magic/Mutate.ogg'
	action_icon_state = "mutate"

	mutations = list(LASEREYES, HULK)
	duration = 300

/obj/effect/proc_holder/spell/targeted/inflict_handler/disintegrate
	name = "Disintegrate"
	desc = "This spell instantly kills somebody adjacent to you with the vilest of magick."

	school = "evocation"
	charge_max = 600
	clothes_req = 1
	invocation = "EI NATH"
	invocation_type = "shout"
	range = 1

	action_icon_state = "gib"

	destroys = "gib_brain"

	sparks_spread = 1
	sparks_amt = 4

/obj/effect/proc_holder/spell/targeted/smoke
	name = "Дым"
	desc = "Заклинание создает удушающий дым вокруг вас и не требует одежды для использования."

	school = "conjuration"
	charge_max = 120
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1
	sound = 'sound/magic/Smoke.ogg'
	action_icon_state = "smoke"

	smoke_spread = 2
	smoke_amt = 10

/obj/effect/proc_holder/spell/targeted/emplosion/disable_tech
	name = "Отключить Технологию"
	desc = "Отключает всю технологическую мумбу-юмбу в радиусе действия."
	charge_max = 400
	clothes_req = 1
	invocation = "NEC CANTIO"
	invocation_type = "shout"
	range = -1
	include_user = 1
	sound = 'sound/magic/Disable_Tech.ogg'
	action_icon_state = "emp"

	emp_heavy = 6
	emp_light = 10

/obj/effect/proc_holder/spell/targeted/turf_teleport/blink
	name = "Скачок"
	desc = "Мгновенно телепортирует вас в случайном направлении на небольшую дистанцию."

	school = "abjuration"
	charge_max = 20
	clothes_req = 1
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1
	sound = 'sound/magic/blink.ogg'
	action_icon_state = "blink"

	smoke_spread = 1
	smoke_amt = 10

	inner_tele_radius = 0
	outer_tele_radius = 6

	centcomm_cancast = FALSE //prevent people from getting to centcomm

/obj/effect/proc_holder/spell/targeted/area_teleport/teleport
	name = "Телепорт"
	desc = "Переносит вас туда, куда вы выберите."

	school = "abjuration"
	charge_max = 600
	clothes_req = 1
	invocation = "SCYAR NILA"
	invocation_type = "shout"
	range = -1
	include_user = 1
	sound = 'sound/magic/Teleport_app.ogg'
	action_icon_state = "spell_teleport"

	smoke_spread = 1
	smoke_amt = 5

/obj/effect/proc_holder/spell/targeted/forcewall
	name = "Магическая Стена"
	desc = "Создает неразрушимую стену на 30 секунд и не требует одежды для использования."
	school = "transmutation"
	charge_max = 600
	clothes_req = 0
	range = -1
	include_user = 1
	invocation = "TARCOL MINTI ZHERI"
	invocation_type = "whisper"
	sound = 'sound/magic/ForceWall.ogg'
	action_icon_state = "shield"
	var/summon_path = /obj/effect/forcefield/magic

/obj/effect/proc_holder/spell/targeted/forcewall/cast(list/targets, mob/living/user = usr)
	new summon_path(get_turf(user), user)
	if(user.dir == SOUTH || user.dir == NORTH)
		new summon_path(get_step(user, EAST), user)
		new summon_path(get_step(user, WEST), user)
	else
		new summon_path(get_step(user, NORTH), user)
		new summon_path(get_step(user, SOUTH), user)

/obj/effect/proc_holder/spell/aoe_turf/conjure/carp
	name = "Призыв Карпа"
	desc = "Это заклинание призывает очень злого карпа."

	school = "conjuration"
	charge_max = 300
	action_icon_state = "purple_carp"
	clothes_req = 1
	invocation = "NOUK FHUNMM SACP RISSKA"
	invocation_type = "shout"
	range = 1

	summon_type = list(/mob/living/simple_animal/hostile/carp/wizard)


/obj/effect/proc_holder/spell/aoe_turf/conjure/construct
	name = "Ремесленник"
	desc = "Призывает конструкта, которым могут управлять тени."

	school = "conjuration"
	charge_max = 600
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0

	action_icon_state = "artificer"

	summon_type = list(/obj/structure/constructshell)


/obj/effect/proc_holder/spell/aoe_turf/conjure/creature
	name = "Призвать Рой Существ"
	desc = "Разрывает реальность и позволяет призвать ужасающих созданий."

	school = "conjuration"
	charge_max = 1200
	clothes_req = 0
	invocation = "IA IA"
	invocation_type = "shout"
	summon_amt = 10
	range = 3

	summon_type = list(/mob/living/simple_animal/hostile/creature)

/obj/effect/proc_holder/spell/targeted/trigger/blind
	name = "Ослепление"
	desc = "Позволяет временно ослепить одного человека и не требует одежды для использования."

	school = "transmutation"
	charge_max = 300
	clothes_req = 0
	invocation = "STI KALY"
	invocation_type = "whisper"
	sound = 'sound/magic/Blind.ogg'
	message = "<span class ='notice'>Вы почувствовали сильную боль в глазах.</span>"

	action_icon_state = "blind"

	starting_spells = list(/obj/effect/proc_holder/spell/targeted/inflict_handler/blind, /obj/effect/proc_holder/spell/targeted/genetic/blind)

/obj/effect/proc_holder/spell/targeted/inflict_handler/blind
	amt_eye_blind = 10
	amt_eye_blurry = 20
	sound = 'sound/magic/Blind.ogg'

/obj/effect/proc_holder/spell/targeted/genetic/blind
	disabilities = 1
	duration = 300
	sound = 'sound/magic/Blind.ogg'

/obj/effect/proc_holder/spell/aoe_turf/conjure/the_traps
	name = "Ловушки!"
	desc = "Призывает несколько ловушек, чтобы запутать противника и возможно вас."
	charge_max = 250
	clothes_req = 1
	invocation = "CAVERE INSIDIAS"
	invocation_type = "shout"
	range = 3
	summon_type = list(
		/obj/structure/trap/wizard/stun,
		/obj/structure/trap/wizard/fire,
		/obj/structure/trap/wizard/chill,
		/obj/structure/trap/wizard/damage,
					)
	summon_lifespan = 3000
	summon_amt = 5

	action_icon_state = "the_traps"

/obj/effect/proc_holder/spell/dumbfire/fireball
	name = "Огненный Шар"
	desc = "Выстреливает огненным шаром в цель."

	school = "evocation"
	charge_max = 100
	clothes_req = 0
	invocation = "ONI SOMA"
	invocation_type = "shout"
	sound = 'sound/magic/Fireball.ogg'
	range = 20

	action_icon_state = "fireball"

	proj_icon_state = "fireball"
	proj_name = "a fireball"
	proj_type = /obj/effect/proc_holder/spell/turf/fireball

	proj_lifespan = 200
	proj_step_delay = 1

/obj/effect/proc_holder/spell/turf/fireball/cast(turf/T)
	explosion(T, 0, 0, 1, adminlog = FALSE)


/obj/effect/proc_holder/spell/targeted/inflict_handler/fireball
	amt_dam_brute = 20
	amt_dam_fire = 25

/obj/effect/proc_holder/spell/targeted/explosion/fireball
	ex_severe = -1
	ex_heavy = -1
	ex_light = 2
	ex_flash = 5






//////////////////////////////Construct Spells/////////////////////////

/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser
	charge_max = 1800
	action_background_icon_state = "bg_cult"

/obj/effect/proc_holder/spell/aoe_turf/conjure/floor
	name = "Создание пола"
	desc = "Это заклинание строит пол культа."

	school = "conjuration"
	charge_max = 20
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list(/turf/simulated/floor/engine/cult, /turf/simulated/floor/engine/cult/lava)
	centcomm_cancast = FALSE //Stop crashing the server by spawning turfs on transit tiles

	action_icon_state = "floorconstruct"
	action_background_icon_state = "bg_cult"

/obj/effect/proc_holder/spell/aoe_turf/conjure/wall
	name = "Создание стены"
	desc = "Это заклинание строит стену культа."

	school = "conjuration"
	charge_max = 100
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list(/turf/simulated/wall/cult, /turf/simulated/wall/cult/runed, /turf/simulated/wall/cult/runed/anim)
	centcomm_cancast = FALSE //Stop crashing the server by spawning turfs on transit tiles

	action_icon_state = "lesserconstruct"
	action_background_icon_state = "bg_cult"

/obj/effect/proc_holder/spell/aoe_turf/conjure/door
	name = "Возвести Ворота"
	desc = "Это заклинание создает Врата."

	action_icon_state = "cult_door"
	action_background_icon_state = "bg_cult"

	school = "conjuration"
	charge_max = 400
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list(/obj/structure/mineral_door/cult)
	centcomm_cancast = FALSE

/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone
	name = "Создание камня души"
	desc = "Это заклинание вызывает легендарнейший фрагмент обелиска душ."

	school = "conjuration"
	charge_max = 3000
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0

	summon_type = list(/obj/item/device/soulstone)

	action_icon_state = "summonsoulstone"
	action_background_icon_state = "bg_cult"

/obj/effect/proc_holder/spell/aoe_turf/conjure/lesserforcewall
	name = "Силовой барьер"
	desc = "Это заклинание создает временное силовое поле для защиты себя и союзников."

	school = "transmutation"
	charge_max = 300
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list(/obj/effect/forcefield/cult)
	summon_lifespan = 200
	action_icon_state = "floorconstruct"
	action_background_icon_state = "bg_cult"

/obj/effect/proc_holder/spell/targeted/communicate
	name = "Сообщить"
	desc = "Позволяет отправить сообщение всем в твоей религии"

	charge_max = 400
	clothes_req = 0
	range = -1
	max_targets = 1
	include_user = 1

	action_icon_state = "cult_comms"
	action_background_icon_state = "bg_cult"

/obj/effect/proc_holder/spell/targeted/communicate/cast(list/targets, mob/user = usr)
	if(!user.my_religion)
		to_chat(user, "Вы не можете с кем-либо общаться.")
		return

	var/input = sanitize(input(user, "Введите сообщение, которое услышат другие последователи.", "[user.my_religion.name]", ""))
	if(!input)
		return
	if(!user.my_religion)
		usr.RemoveSpell(src)
		return

	var/text = "<span class='[user.my_religion.style_text]'>[user.mind.holy_role == CULT_ROLE_MASTER ? "Предвестник" : "Аколит"] [user.real_name]: [input]</span>"
	log_say("([user.my_religion.name]) Аколит [user.real_name]: [input]")
	for(var/mob/M in global.mob_list)
		if(isobserver(M))
			to_chat(M, "[FOLLOW_LINK(M, user)] [text]")
		if(user.my_religion.is_member(M))
			if(iseminence(M))
				to_chat(M, "[FOLLOW_LINK(M, user)] [text]")
			else
				to_chat(M, text)

	playsound(user, 'sound/magic/message.ogg', VOL_EFFECTS_MASTER, extrarange = -6) // radius 3

/obj/effect/proc_holder/spell/targeted/communicate/fastener
	charge_max = 100
