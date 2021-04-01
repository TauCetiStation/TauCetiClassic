/* GAME MODES */
/datum/announcement/centcomm/malf
	subtitle = "Network Monitoring"


/* Blob */
/datum/announcement/centcomm/blob/outbreak5
	name = "Blob: Level 5 Outbreak"
	subtitle = "Biohazard Alert"
	message = "Господа, у вас абсолютно точно не блоб. " + \
			"Но карантин мы всё же введём."
	sound = "outbreak"

/datum/announcement/centcomm/blob/critical
	name = "Blob: Blob Critical Mass"
	subtitle = "Biohazard Alert"
	message = "Biohazard has reached critical mass. Station loss is imminent."

/* Nuclear */
/datum/announcement/centcomm/nuclear/war
	name = "Nuclear: Declaration of War"
	subtitle = "Declaration of War"
	message = "The Syndicate has declared they intent to utterly destroy Space Station 13 with a nuclear device, and dares the crew to try and stop them."
/datum/announcement/centcomm/nuclear/war/play(message)
	if(message)
		src.message = message
	..()

/* Vox */
/datum/announcement/centcomm/vox/arrival
	name = "Vox: Shuttle Arrives"
	message = "Внимание, Космическая Станция 13, неподалёку от вашей станции проходит корабль не отвечающий на наши запросы. " + \
			"По последним данным этот корабль принадлежит Торговой Конфедерации."
/datum/announcement/centcomm/vox/arrival/play()
	message = "Внимание, [station_name()], неподалёку от вашей станции проходит корабль не отвечающий на наши запросы. " + \
			"По последним данным этот корабль принадлежит Торговой Конфедерации."

/datum/announcement/centcomm/vox/returns
	name = "Vox: Shuttle Returns"
	subtitle = "NSV Icarus"
	message = "Your guests are pulling away, Exodus - moving too fast for us to draw a bead on them. " + \
			"Looks like they're heading out of Space Station 13 at a rapid clip."
/datum/announcement/centcomm/vox/returns/play()
	message = "Your guests are pulling away, Exodus - moving too fast for us to draw a bead on them. " + \
			"Looks like they're heading out of [system_name()] at a rapid clip."

/* Malfunction */
/datum/announcement/centcomm/malf/declared
	name = "Malf: Declared Victory"
	title = null
	subtitle = null
	message = null
	flags = ANNOUNCE_SOUND
	sound = "malf"

/datum/announcement/centcomm/malf/first
	name = "Malf: Announce №1"
	message = "Внимание персоналу КСН Исход. Мы обнаружили нетипичные трассировки в вашей сети. " + \
			"Похоже, что кто-то хочет взломать ваши системы. Мы сообщим больше как только так сразу."
	sound = "malf1"

/datum/announcement/centcomm/malf/second
	name = "Malf: Announce №2"
	message = "Мы начали отслеживание взломщика. Похоже, что он прямо у вас на станции. " + \
			"Поэтому, проверьте свои консоли АПЦ. А, ну и да, кстати... химик, пока ещё рано варить термит."
	sound = "malf2"

/datum/announcement/centcomm/malf/third
	name = "Malf: Announce №3"
	message = "Это очень странно и необычно, потому что взломщик искуссно заметает следы. " + \
			"Ни один человек не может так быстро работать с машинами... Да и СПУ тоже..."
	sound = "malf3"

/datum/announcement/centcomm/malf/fourth
	name = "Malf: Announce №4"
	message = "Похоже, что мы обнаружили вашего взломщика, и э-э-э-это ваш-ваш-ваш на-на-на -еллект. Он пы-ы-ы-тается запустить механизм самоуничт..."
	sound = "malf4"

/datum/announcement/centcomm/malf/rickroll
	name = "Malf: Rick Roll"
	message = "Похоже, что мы обнаружили вашего взломщика, и э-э-э-это ваш-ваш-ваш на-на-на -еллект. Он пы-ы-ы-тается запустить механизм самоуничт...  [Rick Astley - Never Gonna Give You Up]"
	sound = "malf4aprilfools"
