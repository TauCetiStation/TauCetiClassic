//TRAIN STATION 13

//All unique visible machines are here, while invisible are in trainstation.dm

/obj/machinery/conveyor_switch/oneway/train
	name = "power throttle"
	desc = "A throttle (or regulator) is a handle that controls the speed or direction of rotation in the train engine."
	icon = 'trainstation13/icons/trainmachines.dmi'

/obj/machinery/space_heater/potbellystove
	name = "potbelly stove"
	desc = "This little stove will keep you warm and cozy during cold winter."
	anchored = TRUE
	density = TRUE
	icon = 'trainstation13/icons/trainmachines.dmi'
	icon_state = "sheater-off"

/obj/machinery/media/jukebox/train
	name = "wall radio"
	desc = "A modern wall mounted radio with audio visualizer. You see some text in Russian on maintenance panel: \"Не влезай! Убьет!\""
	icon = 'trainstation13/icons/trainmachines.dmi'
	density = 0
	playlist_id="train"
	// Must be defined on your server.
	playlists=list(
		"train"  = "Train Tunes",
		"bar"  = "Bar Mix",
		"mogesfm84"  = "Moghes FM-84",
		"moges" = "Moghes Club Music",
		"club" = "Club Mix",
		"customs" = "Customs Music",
		"japan" = "Banzai Radio",
		"govnar" = "Soviet Radio",
		"classic" = "Classical Music",
		"ussr_disco" = "Disco USSR-89s",
		"topreptilian" = "Top Reptillian",
		"zvukbanok" = "Sounds of beer cans",
		"eurobeat" = "Eurobeat",
		"finland" = "Suomi wave",
		"dreamsofvenus" = "Dreams of Venus",
		"hiphop" = "Hip-Hop for Space Gangstas",
		"vaporfunk" = "Qerrbalak VaporFunkFM",
		"thematic" = "Side-Bursting Tunes",
		"lofi" = "Sadness/Longing/Loneliness",
	)

/obj/machinery/media/jukebox/train/attackby(obj/item/W, mob/user, params)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(iswrenching(W))
		if(user.is_busy(src))
			return
		user.visible_message("<span class='notice'>[user.name] attempts to disassemble \the [src.name].</span>","<span class='notice'>You attempt to disasemble \the [src.name].</span>")
		if(W.use_tool(src, user, 30, volume = 50))
			user.visible_message("<span class='notice'>[user.name] has failed to disassemble \the [src.name]. In Soviet Union [src.name] disassembles you!</span>","<span class='warning'>You have failed to disassemble \the [src.name]. In Soviet Union [src.name] disassembles you!</span>")
			playsound(src, 'sound/effects/sparks4.ogg', VOL_EFFECTS_MASTER)

			Disassemble(user)
	else
		..()

/obj/machinery/media/jukebox/train/proc/Disassemble(mob/living/user)
	if(istype(user))
		user.dust()
	else
		qdel(user)

/obj/machinery/computer/security/wooden_tv/train
	name = "Spektr-88"
	desc = "An old color TV that is still able to receive few analog channels."
	icon_state = "security_det_miami"
	state_broken_preset = null
	state_nopower_preset = null
	light_color = "#f535aa"
	network = list("TV")
	pixel_y = 3