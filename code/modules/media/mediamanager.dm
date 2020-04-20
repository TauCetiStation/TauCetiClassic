/**********************
 * AWW SHIT IT'S TIME FOR RADIO
 *
 * Concept stolen from D2K5
 *
 * Rewritten (except for player HTML) by N3X15
 ***********************/

// Open up VLC and play musique.
// Converted to VLC for cross-platform and ogg support. - N3X
var/const/PLAYER_HTML={"
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
	//world << "Update start"
	if (client && client.media)
		//world << "Media Exists"
		client.media.update_music()
	//else
	//	testing("[src] - client: [client?"Y":"N"]; client.media: [client && client.media ? "Y":"N"]")

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
	var/volume = 25

	var/client/owner
	var/mob/living/mob

	var/const/window = "rpane.hosttracker"
	//var/const/window = "mediaplayer" // For debugging.

/datum/media_manager/New(mob/living/holder)
	if(!istype(holder))
		return
	mob = holder
	owner = mob.client
	volume = owner.get_sound_volume(VOL_JUKEBOX)

// Actually pop open the player in the background.
/datum/media_manager/proc/open()
	owner << browse(PLAYER_HTML, "window=[window]")
	send_update()

// Tell the player to play something via JS.
/datum/media_manager/proc/send_update()
	if(!owner.get_sound_volume(VOL_JUKEBOX) && url != "")
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
	//var/targetVolume = volume

	if (!owner)
		//testing("owner is null")
		return
	if(!isliving(mob))
		return
	var/area/A = get_area(mob)
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
		//volume = targetVolume
		send_update()

/datum/media_manager/proc/update_volume()
	volume = owner.prefs.snd_jukebox_vol
	owner << output(list2params(list(volume)), "[window]:SetVolume")
	//send_update()
