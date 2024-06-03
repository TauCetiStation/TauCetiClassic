// do not use these prefs dirrectly, see /code/game/sound.dm for sound methods

/datum/pref/player/audio
	category = PREF_PLAYER_AUDIO
	value_type = PREF_TYPE_RANGE
	value_parameters = list(0, 100)

	var/volume_channel

/datum/pref/player/audio/on_update(client/client, old_value)
	client?.mob?.playsound_local(null, 'sound/weapons/saberon.ogg', volume_channel, vary = FALSE, channel = CHANNEL_VOLUMETEST)

// lobby
/datum/pref/player/audio/lobby
	name = "Lobby"
	description = "Громкость музыки в лобби"
	value = 100

	volume_channel = VOL_MUSIC

/datum/pref/player/audio/lobby/on_update(client/client, old_value)
	client?.mob?.playsound_music_update_volume(VOL_MUSIC, CHANNEL_MUSIC)
	..()

// ambient
/datum/pref/player/audio/ambient
	name = "Ambient"
	description = "Громкость эмбиент музыки и эффектов"
	value = 100

	volume_channel = VOL_AMBIENT

/datum/pref/player/audio/ambient/on_update(client/client, old_value)
	client?.mob?.playsound_music_update_volume(VOL_AMBIENT, CHANNEL_AMBIENT)
	client?.mob?.playsound_music_update_volume(VOL_AMBIENT, CHANNEL_AMBIENT_LOOP)
	..()

// effect_master
/datum/pref/player/audio/effect_master // todo: this is too confusing
	name = "Effects: Master"
	description = "Общий модификатор громкости всех игровых эффектов"
	value = 100

	volume_channel = VOL_EFFECTS_MASTER

// effect_announcement
/datum/pref/player/audio/effect_announcement
	name = "Effects: Announcement"
	description = "Игровые аудио-аннонсы (относится к игровым эффектам)"
	value = 100

	volume_channel = VOL_EFFECTS_VOICE_ANNOUNCEMENT

// effect_misc
/datum/pref/player/audio/effect_misc // todo rename spammy | annoying etc
	name = "Effects: Miscellaneous"
	description = "Теслы, эммитеры, и некоторые другие надоедливые спамящие эффекты (относится к игровым эффектам)"
	value = 100

	volume_channel = VOL_EFFECTS_MISC

// effect_instrument
/datum/pref/player/audio/effect_instrument
	name = "Effects: Instruments"
	description = "Музыкальные инструменты (относится к игровым эффектам)"
	value = 100

	volume_channel = VOL_EFFECTS_INSTRUMENT

// notifications
/datum/pref/player/audio/notifications
	name = "Notifications"
	description = "OOC-уведомления (клонирование, личные сообщения админов и менторов)"
	value = 100

	volume_channel = VOL_NOTIFICATIONS

// admin_sound
/datum/pref/player/audio/admin_sound
	name = "Admin sounds"
	description = "Музыка и звуки, проигрываемые администраторами"
	value = 100

	volume_channel = VOL_ADMIN

/datum/pref/player/audio/admin_sound/on_update(client/client, old_value)
	client?.mob?.playsound_music_update_volume(VOL_ADMIN, CHANNEL_ADMIN)
	..()

// jukebox
/datum/pref/player/audio/jukebox
	name = "Jukebox"
	description = "Громкость музыки из Jukebox автомата"
	value = 100

	volume_channel = VOL_JUKEBOX

/datum/pref/player/audio/jukebox/on_update(client/client, old_value) // todo
	var/datum/media_manager/media = client?.media
	//..()
	if(istype(media)) // will be updated in "/mob/living/Login()" if changed in lobby.
		media.update_volume()

		if(!value && old_value) // only play/stop if last change is a mute or unmute state.
			media.stop_music()
		else if(value && !old_value)
			media.update_music()

