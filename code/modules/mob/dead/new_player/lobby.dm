// Possibles title screens
var/global/custom_lobby_image // admins custom screens
var/global/lobby_screens = list(
	"lobby" = list("mp4" = 'html/media/lobby.mp4', "png" = 'html/media/lobby.png'),
	"lobby-ny" = list("mp4" = 'html/media/lobby-ny.mp4', "png" = 'html/media/lobby-ny.png'),
	)

var/global/lobby_screen = "lobby"

#define CHECK_BOX "<span class='menu_box menu_box__check'>☑</span>"
#define CROSS_BOX "<span class='menu_box menu_box__cross'>☒</span>"

#define MARK_READY     "READY&#8239;[CHECK_BOX]"
#define MARK_NOT_READY "READY&#8239;[CROSS_BOX]"

#define QUALITY_READY     "BE&#8239;SPECIAL&#8239;[CHECK_BOX]"
#define QUALITY_NOT_READY "BE&#8239;SPECIAL&#8239;[CROSS_BOX]"

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

				body.lobby-default .container_nav_rot {
					transform: rotate3d(3, 5, 0, 25deg);
					transform-origin: top center;
				}

				.menu_a {
					display: inline-block;
					font-family: "Fixedsys";
					font-weight: lighter;
					text-decoration: none;
					text-align: left;
					color:white;
					margin-right: 100%;
					margin-top: 5px;
					font-size: 3.6vmin; /* 4vmin if we can make logo small */
					line-height: 3.6vmin;
					height: 3.6vmin;
					letter-spacing: 1px;
					color: #2baaff;
					text-shadow: 1px 1px 3px #098fd9, -1px -1px 3px #098fd9;
				}

				body.lobby-default .menu_a {
					opacity: 0.5;
				}

				.menu_a:hover {
					font-weight: bolder;
				}

				body.lobby-default .menu_a:hover {
					opacity: 0.85;
				}

				.menu_box {
					text-shadow: 1px 1px 3px, -1px -1px 3px;
				}

				.menu_box__check {
					color: lime;
				}

				.menu_box__cross {
					color: red;
				}

			</style>
		</head>
		<body class="[custom_lobby_image ? "lobby-custom" : "lobby-default"]">
	"}

	dat += {"
			<div class="container_nav"><div class="container_nav_rot">
				<a class="menu_a" href='?src=\ref[src];lobby_setup=1'>SETUP</a>
	"}

	if(config.alt_lobby_menu)
		dat += {"<a class="menu_a" href='?src=\ref[src];event_join=1'>JOIN</a>"}
	else
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

	dat += "</div></div>"
	
	if(global.custom_lobby_image)
		dat += {"<img src="titlescreen.gif" class="background" alt="">"}
	else if (client.prefs.lobbyanimation)
		dat += {"
		<video class="background" width="400" height="400" loop mute autoplay>
			<source src="[global.lobby_screen].mp4" type="video/mp4">
		</video>
		<img class="background background__fallback" src="[global.lobby_screen].png">
		"}
	else
		dat += {"<img class="background" src="[global.lobby_screen].png">"}

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

		/* pass any keys to byond, somehow this will work */
		document.body.addEventListener('keydown', function (event) {
			window.location = 'byond://?__keydown='+event.which;
			return false;
		})

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
