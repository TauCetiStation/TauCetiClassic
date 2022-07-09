// Possibles title screens
var/global/list/lobby_screens = list('icons/lobby/nss_exodus_system.gif', 'icons/lobby/standart.gif')
var/global/list/new_year_screens = list('icons/lobby/nss_exodus_system.gif', 'icons/lobby/newyear.gif')

var/global/current_lobby_screen = 'icons/lobby/nss_exodus_loading.gif'

#define CROSS_BOX "<span style='color:red'>☒</span>"
#define CHECK_BOX "<span style='color:lime'>☑</span>"

#define MARK_READY     "READY [CHECK_BOX]"
#define MARK_NOT_READY "READY [CROSS_BOX]"

#define QUALITY_READY     "QUALITY [CHECK_BOX]"
#define QUALITY_NOT_READY "QUALITY [CROSS_BOX]"

/mob/dead/new_player/proc/get_lobby_html()
	var/dat = {"
	<html>
		<head>
			<meta http-equiv="X-UA-Compatible" content="IE=edge">
			<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
			<style>
				@font-face {
					font-family: "Fixedsys";
					src: url("FixedsysExcelsior3.01Regular.ttf");
				}

				body,
				html {
					margin: 0;
					overflow: hidden;
					text-align: center;
					background-color: black;
					-ms-user-select: none;
				}

				img {
					border-style: none;
				}

				.back {
					position: absolute;
					width: auto;
					height: 100vmin;
					min-width: 100vmin;
					min-height: 100vmin;
					top: 50%;
					left:50%;
					transform: translate(-50%, -50%);
					z-index: 0;
				}

				.container_nav {
					position: absolute;
					width: auto;
					min-width: 100vmin;
					min-height: 50vmin;
					padding-left: 10vmin;
					padding-top: 60vmin;
					box-sizing: border-box;
					top: 50%;
					left: 50%;
					transform: translate(-50%, -50%);
					z-index: 1;
				}

				.menu_a {
					display: inline-block;
					font-family: "Fixedsys";
					font-weight: lighter;
					text-decoration: none;
					width: 25%;
					text-align: left;
					color:white;
					margin-right: 100%;
					margin-top: 5px;
					padding-left: 6px;
					font-size: 4vmin;
					line-height: 4vmin;
					height: 4vmin;
					letter-spacing: 1px;
				}

				.menu_a:hover {
					border-left: 3px solid white;
					font-weight: bolder;
					padding-left: 3px;
				}

			</style>
		</head>
		<body>
			<div class="container_nav">
				<a class="menu_a" href='?src=\ref[src];lobby_setup=1'>SETUP</a>
	"}

	if(!SSticker || SSticker.current_state <= GAME_STATE_PREGAME)
		dat += {"<a id="ready" class="menu_a" href='?src=\ref[src];lobby_ready=1'>[ready ? MARK_READY : MARK_NOT_READY]</a>"}
	else
		dat += {"<a class="menu_a" href='?src=\ref[src];lobby_crew=1'>CREW</a>"}
		dat += {"<a class="menu_a" href='?src=\ref[src];lobby_join=1'>JOIN</a>"}

	var/has_quality = client.prefs.selected_quality_name
	dat += {"<a id="quality" class="menu_a" href='?src=\ref[src];lobby_be_special=1'>[has_quality ? QUALITY_READY : QUALITY_NOT_READY]</a>"}

	dat += {"<a class="menu_a" href='?src=\ref[src];lobby_observe=1'>OBSERVE</a>"}
	dat += "<br><br>"
	dat += {"<a class="menu_a" href='?src=\ref[src];lobby_changelog=1'>CHANGELOG</a>"}

	dat += "</div>"
	dat += {"<img src="titlescreen.gif" class="back" alt="">"}
	dat += {"

	<script>
		var ready_mark = document.getElementById("ready");
		function setReadyStatus(isReady) {
			ready_mark.innerHTML = Boolean(Number(isReady)) ? "[MARK_READY]" : "[MARK_NOT_READY]";
		}

		var quality_mark=document.getElementById("quality");
		function set_quality(setQuality) {
			quality_mark.innerHTML = Boolean(Number(setQuality)) ? "[QUALITY_READY]" : "[QUALITY_NOT_READY]";
		}
	</script>
	"}
	dat += "</body></html>"
	return dat

#undef CROSS_BOX
#undef CHECK_BOX

#undef MARK_READY
#undef MARK_NOT_READY
#undef QUALITY_READY
#undef QUALITY_NOT_READY
