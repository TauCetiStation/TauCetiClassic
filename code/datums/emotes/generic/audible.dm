/datum/emote/whimper
	key = "whimper"

	message_1p = "Вы хнычете."
	message_3p = "хнычет."

	message_impaired_production = "издаёт слабый звук."
	message_impaired_reception = "делает печальное лицо."

	message_miming = "беззвучно и жалобно поскуливает, скривив лицо в страдальческой гримасе."
	message_muzzled = "издаёт сдавленный звук."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_EMOTIONLESS)


/datum/emote/roar
	key = "roar"

	message_1p = "Вы рычите!"
	message_3p = "рычит!"

	message_impaired_production = "издаёт громкий звук!"

	message_miming = "широко разевает рот в яростной гримасе!"
	message_muzzled = "издаёт громкий звук!"

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS

/datum/emote/roar/get_impaired_msg(mob/user)
	return "пугающе разевает рот!"


/datum/emote/gasp
	key = "gasp"

	message_1p = "Вы судорожно вдыхаете!"
	message_3p = "судорожно вдыхает!"

	message_impaired_production = "жадно ловит ртом воздух!"
	message_impaired_reception = "жадно ловит ртом воздух!"

	message_miming = "беззвучно ловит ртом воздух!"
	message_muzzled = "издаёт сдавленный звук."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_NO_BREATHE)

	cloud = "cloud-gasp"


/datum/emote/choke
	key = "choke"

	message_1p = "Вы задыхаетесь."
	message_3p = "задыхается."

	message_impaired_production = "издаёт сдавленный звук."

	message_miming = "театрально хватается за горло, изображая удушье."
	message_muzzled = "издаёт сдавленный звук."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_NO_BREATHE)

	cloud = "cloud-gasp"

/datum/emote/choke/get_impaired_msg(mob/user)
	return "отчаянно хватается за горло!"


/datum/emote/moan
	key = "moan"

	message_1p = "Вы стонете!"
	message_3p = "стонет!"

	message_impaired_production = "тихо стонет."

	message_miming = "закатывает глаза в немом стоне!"
	message_muzzled = "тихо стонет!"

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_EMOTIONLESS)

/datum/emote/moan/get_impaired_msg(mob/user)
	return "широко открывает рот"


/datum/emote/cough
	key = "cough"

	message_1p = "Вы кашляете."
	message_3p = "кашляет."

	message_impaired_production = "сильно содрогается!"

	message_miming = "содрогается в беззвучном кашле."
	message_muzzled = "глухо кашляет."

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_NO_BREATHE)

/datum/emote/cough/get_impaired_msg(mob/user)
	return "подаётся вперёд, открывая и закрывая рот!"
