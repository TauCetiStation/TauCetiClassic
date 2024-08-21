// do not use these prefs dirrectly, see /code/game/sound.dm for sound methods

/datum/pref/player/audio
	category = PREF_PLAYER_AUDIO
	value_type = PREF_TYPE_RANGE
	value_parameters = list(0, 100)

	var/volume_channel

/datum/pref/player/audio/on_update(client/client, old_value)
	client?.mob?.playsound_local(null, 'sound/weapons/saberon.ogg', volume_channel, vary = FALSE, channel = CHANNEL_VOLUMETEST)

/datum/pref/player/audio/lobby
	name = "Музыка в лобби"
	description = "Громкость музыки в лобби игры."
	value = 100

	volume_channel = VOL_LOBBY_MUSIC

/datum/pref/player/audio/lobby/on_update(client/client, old_value)
	client?.mob?.playsound_music_update_volume(VOL_LOBBY_MUSIC, CHANNEL_MUSIC)
	..()

/datum/pref/player/audio/ambient
	name = "Эмбиент"
	description = "Громкость эффектов окружающей среды - звуки станции, музыка отделов."
	value = 100

	volume_channel = VOL_AMBIENT

/datum/pref/player/audio/ambient/on_update(client/client, old_value)
	client?.mob?.playsound_music_update_volume(VOL_AMBIENT, CHANNEL_AMBIENT)
	client?.mob?.playsound_music_update_volume(VOL_AMBIENT, CHANNEL_AMBIENT_LOOP)
	..()

/datum/pref/player/audio/effects
	name = "Эффекты"
	description = "Громкость игровых эффектов"
	value = 100

	volume_channel = VOL_EFFECTS_MASTER

/datum/pref/player/audio/spam_effects
	name = "Модификатор спам-эффектов"
	description = "Дополнительный модификатор громкости для некоторых, возможно надоедливых, игровых эффектов - теслы, эммитеры, хонк-и и некоторые другие."
	value = 100

	volume_channel = VOL_SPAM_EFFECTS

/datum/pref/player/audio/voice_announcements
	name = "Голосовые аннонсы"
	description = "Громкость озвученных игровых аудио-аннонсов, вроде оповещений с ЦК."
	value = 100

	volume_channel = VOL_VOICE_ANNOUNCEMENTS

/datum/pref/player/audio/instruments
	name = "Музыкальные инструменты"
	description = "Громкость музыки, проигрываемой музыкальными инструментами - пианино, гитара и т.п. Джубокс не относится к этой категории."
	value = 100

	volume_channel = VOL_MUSIC_INSTRUMENTS

/datum/pref/player/audio/notifications
	name = "Уведомления"
	description = "Громкость различных важных уведомлений игрока - личные сообщения админов и менторов, запросы на воскрешение."
	value = 100

	volume_channel = VOL_NOTIFICATIONS

/datum/pref/player/audio/admin_sounds
	name = "Админские звуки"
	description = "Музыка и звуки, проигрываемые администраторами."
	value = 100

	volume_channel = VOL_ADMIN_SOUNDS

/datum/pref/player/audio/admin_sounds/on_update(client/client, old_value)
	client?.mob?.playsound_music_update_volume(VOL_ADMIN_SOUNDS, CHANNEL_ADMIN)
	..()

/datum/pref/player/audio/jukebox
	name = "Jukebox"
	description = "Громкость музыкального автомата."
	value = 100

	volume_channel = VOL_JUKEBOX

/datum/pref/player/audio/jukebox/on_update(client/client, old_value)
	..()
	var/datum/media_manager/media = client?.media
	if(istype(media)) // will be updated in "/mob/living/Login()" if changed in lobby.
		media.update_volume()

		if(!value && old_value) // only play/stop if last change is a mute or unmute state.
			media.stop_music()
		else if(value && !old_value)
			media.update_music()

