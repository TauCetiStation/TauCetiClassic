/**********************
 * AWW SHIT IT'S TIME FOR RADIO
 *
 * Concept stolen from D2K5
 *
 * Rewritten (except for player HTML) by N3X15
 ***********************/

#define MEDIA_VOLUME SANITIZE_VOL(50)

// Open up VLC and play musique.
// Converted to VLC for cross-platform and ogg support. - N3X
var/global/const/PLAYER_HTML={"
	<OBJECT id='player' CLASSID='CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6' type='application/x-oleobject'></OBJECT>
	<script>
function noErrorMessages () { return true; }
window.onerror = noErrorMessages;
function SetMusic(url, time, volume) {
	var player = document.getElementById('player');
	player.URL = url;
	player.Controls.currentPosition = +time;
	player.Settings.volume = +volume;
}
function SetVolume(volume) {
	var player = document.getElementById('player');
	player.Settings.volume = volume;
}
	</script>"}

/mob/living/proc/update_music()
	client?.media?.update_music()

/area
	// One media source per area.
	var/obj/machinery/media/media_source = null

#ifdef DEBUG_MEDIAPLAYER
#define MP_DEBUG(x) owner << x
#warn Please comment out #define DEBUG_MEDIAPLAYER before committing.
#else
#define MP_DEBUG(x)
#endif


/datum/media_manager
	var/url = ""
	var/start_time = 0
	var/volume = MEDIA_VOLUME

	var/client/owner

	var/const/window = "rpane.hosttracker"
	//var/const/window = "mediaplayer" // For debugging.

/datum/media_manager/New(client/owner_)
	owner = owner_
	volume = MEDIA_VOLUME * owner.get_sound_volume(VOL_JUKEBOX)
	if(isliving(owner.mob))
		open()

// Actually pop open the player in the background.
/datum/media_manager/proc/open()
	owner << browse(PLAYER_HTML, "window=[window]")
	update_music()

// Tell the player to play something via JS.
/datum/media_manager/proc/send_update()
	if(!volume && !length(url))
		return // Nope.
	var/playtime = round((world.time - start_time) / 10)
	owner << output(list2params(list(url, playtime, volume)), "[window]:SetMusic")

/datum/media_manager/proc/stop_music()
	url=""
	start_time=world.time
	send_update()

// Scan for media sources and use them.
/datum/media_manager/proc/update_music()
	var/targetURL = ""
	var/targetStartTime = 0

	if (!owner)
		//testing("owner is null")
		return
	if(!isliving(owner.mob))
		return
	var/area/A = get_area(owner.mob)
	if(!A)
		//testing("[owner] in [mob.loc].  Aborting.")
		stop_music()
		return
	var/obj/machinery/media/M = A.media_source
	if(M && M.playing)
		targetURL = M.media_url
		targetStartTime = M.media_start_time
		//owner << "Found audio source: [M.media_url] @ [(world.time - start_time) / 10]s."
	//else
	//	testing("M is not playing or null.")
	if (url != targetURL || abs(targetStartTime - start_time) > 1)
		url = targetURL
		start_time = targetStartTime
		send_update()

/datum/media_manager/proc/update_volume()
	volume = MEDIA_VOLUME * owner.get_sound_volume(VOL_JUKEBOX)
	owner << output(list2params(list(volume)), "[window]:SetVolume")
	send_update()

#undef MEDIA_VOLUME
