// spawners for existing mob

/datum/spawner/living
	name = "Свободное тело"
	desc = "Продолжи его дело!"

	ranks = list(ROLE_GHOSTLY)

	register_only = TRUE
	time_for_registration = 0.5 MINUTES

	should_be_unique = TRUE

	var/mob/living/mob

/datum/spawner/living/New(mob/living/_mob)
	. = ..()

	mob = _mob
	add_mob_roles()

	RegisterSignal(mob, list(COMSIG_PARENT_QDELETING, COMSIG_LOGIN, COMSIG_MOB_DIED), PROC_REF(self_qdel))

/datum/spawner/living/Destroy()
	UnregisterSignal(mob, list(COMSIG_PARENT_QDELETING, COMSIG_LOGIN, COMSIG_MOB_DIED))
	mob = null
	return ..()

/datum/spawner/living/proc/add_mob_roles()
	ranks |= mob.job

	if(!mob.mind)
		return

	var/datum/mind/mind = mob.mind
	ranks |= mind.antag_roles

/datum/spawner/living/proc/self_qdel()
	SIGNAL_HANDLER
	qdel(src)

/datum/spawner/living/jump(mob/dead/spectator)
	spectator.forceMove(get_turf(mob))

/datum/spawner/living/spawn_body(mob/dead/spectator)
	UnregisterSignal(mob, list(COMSIG_PARENT_QDELETING, COMSIG_LOGIN, COMSIG_MOB_DIED))
	mob.key = spectator.key

/datum/spawner/living/podman
	name = "Подмена"
	desc = "Подмена умерла, да здравствует подмена."
	wiki_ref = "Podmen"

	var/replicant_memory

/datum/spawner/living/podman/New(mob/_mob, _replicant_memory)
	replicant_memory = _replicant_memory
	. = ..(_mob)

/datum/spawner/living/podman/spawn_body(mob/dead/spectator)
	..()

	if(replicant_memory)
		mob.mind.memory = replicant_memory

	to_chat(mob, greet_message())

/datum/spawner/living/podman/proc/greet_message()
	. = "<span class='notice'><B>You awaken slowly, feeling your sap stir into sluggish motion as the warm air caresses your bark.</B></span><BR>"
	. += "<B>You are now in possession of Podmen's body. It's previous owner found it no longer appealing, by rejecting it - they brought you here. You are now, again, an empty shell full of hollow nothings, neither belonging to humans, nor them.</B><BR>"
	. += "<B>Too much darkness will send you into shock and starve you, but light will help you heal.</B>"

/datum/spawner/living/podman/podkid
	name = "Подкидыш"
	desc = "Человечка вырастили на грядке."

/datum/spawner/living/podman/podkid/greet_message()
	. = "<span class='notice'><B>You awaken slowly, feeling your sap stir into sluggish motion as the warm air caresses your bark.</B></span><BR>"
	. += "<B>You are now one of the Podmen, a race of failures, created to never leave their trace. You are an empty shell full of hollow nothings, neither belonging to humans, nor them.</B><BR>"
	. += "<B>Too much darkness will send you into shock and starve you, but light will help you heal.</B>"

/datum/spawner/living/podman/nymph
	name = "Нимфа Дионы"
	desc = "Диону вырастили на грядке."
	wiki_ref = "Dionaea"

/datum/spawner/living/podman/nymph/can_spawn(mob/dead/spectator)
	if(is_alien_whitelisted_banned(spectator, DIONA) || !is_alien_whitelisted(spectator, DIONA))
		to_chat(spectator, "<span class='warning'>Вы не можете играть за дион.</span>")
		return FALSE

	return ..()

/datum/spawner/living/podman/nymph/greet_message()
	. = "<span class='notice'><B>You awaken slowly, feeling your sap stir into sluggish motion as the warm air caresses your bark.</B></span><BR>"
	. += "<B>You are now one of the Dionaea, or were you always one of us? Welcome to the Gestalt, we see you now, again.</B><BR>"
	. += "<B>Too much darkness will send you into shock and starve you, but light will help you heal.</B>"

/datum/spawner/living/podman/fake_nymph
	name = "Нимфа Дионы"
	desc = "Диону вырастили на грядке."

/datum/spawner/living/podman/fake_nymph/greet_message()
	. = "<span class='notice'><B>You awaken slowly, feeling your sap stir into sluggish motion as the warm air caresses your bark.</B></span><BR>"
	. += "<B>You are now one of the Dionaea, sorta, you failed at your attempt to join the Gestalt Consciousness. You are not empty, nor you are full. You are a failure good enough to fool everyone into thinking you are not. DO NOT EVOLVE.</B><BR>"
	. += "<B>Too much darkness will send you into shock and starve you, but light will help you heal.</B>"

/datum/spawner/living/borer
	name = "Борер"
	desc = "Вы становитесь очередным отпрыском бореров."
	wiki_ref = "Cortical_Borer"

/datum/spawner/living/borer/spawn_body(mob/dead/spectator)
	UnregisterSignal(mob, list(COMSIG_PARENT_QDELETING, COMSIG_LOGIN, COMSIG_MOB_DIED))
	mob.transfer_personality(spectator.client)

/*
 * Robots
*/
/datum/spawner/living/robot
	name = "Киборг"
	desc = "Перезагрузка позитронного мозга."
	wiki_ref = "Cyborg"

/datum/spawner/living/robot/syndi
	name = "Киборг синдиката"
	ranks = list(ROLE_OPERATIVE)

/datum/spawner/living/robot/drone
	name = "Дрон"
	wiki_ref = "Maintenance_drone"
	ranks = list(ROLE_DRONE)

/*
 * Religion
*/
/datum/spawner/living/religion_familiar
	name = "Фамильяр Религии"
	desc = "Вы появляетесь в виде какого-то животного в подчинении определённой религии."
	cooldown = 2 MINUTES

	var/datum/religion/religion

/datum/spawner/living/religion_familiar/New(mob/_mob, datum/religion/_religion)
	. = ..(_mob)
	religion = _religion || mob.my_religion

	desc = "Вы появляетесь в виде [mob.name] в подчинении [religion.name]."

/datum/spawner/living/religion_familiar/spawn_body(mob/dead/spectator)
	..()
	religion.add_member(mob, HOLY_ROLE_PRIEST)


/datum/spawner/living/eminence
	name = "Возвышенный культа"
	desc = "Вы станете Возвышенным - ментором и неформальным лидером всего культа."
	ranks = list(ROLE_CULTIST, ROLE_GHOSTLY)

/datum/spawner/living/mimic
	name = "Оживлённый предмет"
	desc = "Вы магическим образом ожили на станции"
	cooldown = 1 MINUTES
	time_for_registration = null
	register_only = FALSE

/datum/spawner/living/evil_shade
	name = "Злой Дух"
	desc = "Магическая сила призвала вас в мир, отомстите живым за причинённые обиды!"
	cooldown = 2 MINUTES
	time_for_registration = null
	register_only = FALSE

/datum/spawner/living/evil_shade/spawn_body(mob/dead/spectator)
	..()
	create_and_setup_role(/datum/role/evil_shade, mob)

/datum/spawner/living/rat
	name = "Крыса"
	desc = "Вы появляетесь в своём новом доме"
	time_for_registration = null
	register_only = FALSE

/datum/spawner/living/rat/spawn_body(mob/dead/spectator)
	. = ..()
	to_chat(mob, "<B>Эта посудина теперь ваш новый дом, похозяйничайте в нём.</B>")
	to_chat(mob, "<B>(Вы можете грызть провода и лампочки).</B>")

/datum/spawner/living/sugar_larva
	name = "Сладкая личинка"
	desc = "Вы форма жизни используемая в качестве скота, ваша задача выжить на станции."
	time_while_available = 1 MINUTES
	register_only = FALSE

/*
 * Heist
*/
/datum/spawner/living/vox
	name = "Вокс-Налётчик"
	desc = "Воксы-налётчики это представители расы Воксов, птице-подобных гуманоидов, дышащих азотом. Прибыли на станцию что бы украсть что-нибудь ценное."
	wiki_ref = "Vox_Raider"

/datum/spawner/living/abductor
	name = "Похититель"
	desc = "Технологически развитое сообщество пришельцев, которые занимаются каталогизированием других существ в Галактике. К сожалению для этих существ, методы похитителей, мягко выражаясь, агрессивны."
	wiki_ref = "Abductor"
	time_for_registration = null
	register_only = FALSE
