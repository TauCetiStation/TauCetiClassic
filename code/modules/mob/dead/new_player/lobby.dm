// Possibles title screens
var/global/custom_lobby_image // admins custom screens, have priority
var/global/lobby_screens = list("lobby-ny" = list("mp4" = 'html/media/lobby-ny.mp4', "png" = 'html/media/lobby-ny.png'))
var/global/lobby_screen = "lobby-ny"

#define MARK_READY     "READY&nbsp;☑"
#define MARK_NOT_READY "READY&nbsp;☒"

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

				.background {
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

				.background.background__fallback {
					z-index: -1;
				}

				.container_nav {
					position: absolute;
					width: auto;
					min-width: 100vmin;
					min-height: 50vmin;
					padding-left: 5vmin;
					padding-top: 50vmin;
					box-sizing: border-box;
					top: 50%;
					left: 50%;
					transform: translate(-50%, -50%);
					z-index: 1;
				}

				.container_nav_rot {
					transform: rotate3d(3, 5, 0, 25deg);
					transform-origin: top center;
				}

				.menu_a {
					display: inline-block;
					font-family: "Fixedsys";
					font-weight: lighter;
					text-decoration: none;
					/*width: 25%;*/
					text-align: left;
					color:white;
					margin-right: 100%;
					margin-top: 5px;
					/*padding-left: 6px;*/
					font-size: 4vmin;
					line-height: 4vmin;
					height: 4vmin;
					letter-spacing: 1px;
					opacity: 0.5;
					color: #2baaff;
					text-shadow: 1px 1px 3px #098fd9, -1px -1px 3px #098fd9;
				}

				.menu_a:hover {
					font-weight: bolder;
					opacity: 0.85;
					/*border-left: 3px solid white;
					padding-left: 3px;*/
				}
			</style>
		</head>
		<body>
	"}

	dat += {"
			<div class="container_nav"><div class="container_nav_rot">
				<a class="menu_a" href='?src=\ref[src];lobby_setup=1'>SETUP</a>
	"}

	if(!SSticker || SSticker.current_state <= GAME_STATE_PREGAME)
		dat += {"<a id="ready" class="menu_a" href='?src=\ref[src];lobby_ready=1'>[ready ? MARK_READY : MARK_NOT_READY]</a>"}
	else
		dat += {"<a class="menu_a" href='?src=\ref[src];lobby_crew=1'>CREW</a>"}
		dat += {"<a class="menu_a" href='?src=\ref[src];lobby_join=1'>JOIN</a>"}

	dat += {"<a class="menu_a" href='?src=\ref[src];lobby_observe=1'>OBSERVE</a>"}
	dat += "<br><br>"
	dat += {"<a class="menu_a" href='?src=\ref[src];lobby_changelog=1'>CHANGELOG</a>"}

	dat += "</div></div>"
	
	if(global.custom_lobby_image)
		dat += {"<img src="titlescreen.gif" class="background" alt="">"}
	else if (client.prefs.lobbyanimation)
		dat += {"
		<video class="background" width="400" height="400" loop mute autoplay>
			<source src="[global.lobby_screen].mp4" type="video/mp4">
			<!-- Magic worlds for IE: https://stackoverflow.com/a/24697998 -->
		</video>
		<img class="background background__fallback" src="[global.lobby_screen].png">
		"}
	else
		dat += {"<img class="background" src="[global.lobby_screen].png">"}

	dat += {"
	<script>
		var mark = document.getElementById("ready");
		function setReadyStatus(isReady) {
			mark.innerHTML = Boolean(Number(isReady)) ? "[MARK_READY]" : "[MARK_NOT_READY]";
		}
	</script>
	"}
	dat += "</body></html>"
	return dat

#undef MARK_READY
#undef MARK_NOT_READY
