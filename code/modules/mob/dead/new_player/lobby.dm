// Possibles title screens
var/global/list/lobby_screens = list('icons/lobby/nss_exodus_system.gif', 'icons/lobby/standart.gif')
var/global/list/new_year_screens = list('icons/lobby/nss_exodus_system.gif', 'icons/lobby/newyear.gif')

var/global/current_lobby_screen = 'icons/lobby/nss_exodus_loading.gif'

/mob/dead/new_player/proc/get_lobby_html()
	var/dat = {"
	<html>
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<style type='text/css'>
			body,
			html {
				margin: 0;
				overflow: hidden;
				text-align: center;
				background-color: black;
			}

			img {
				border-style:none;
			}

			.fone{
				position: relative;
				object-fit: contain;
				width: 100%;
				height: 100%;
				top:-35%;
				left: 0;
				z-index: 0;
			}

			.container_nav {
				position: relative;
				height: 35%;
				width: min-content;
				z-index: 1;
				left: 10%;
				top: 60%;
			}

			.container_nav img {
				margin-right: 100%;
				width: 300px;
			}

			.menu_a {
				position: relative;
			}

			.menu_a:hover {
				border-left: 2px solid white;
			}

		</style>
	</head>
	<body>
	<div class="container_nav">
	<a class="menu_a" href='?src=\ref[src];lobby_setup=1'><img src='setup.png' /></a>
	"}

	if(!SSticker || SSticker.current_state <= GAME_STATE_PREGAME)
		dat += {"<a class="menu_a" href='?src=\ref[src];lobby_ready=1'><img id="image" src='ready_neok.png' onClick="imgsrc()" /></a>
		"}
	else
		dat += {"<a class="menu_a" href='?src=\ref[src];lobby_crew=1'><img src='manifest.png' /></a>
		"}
		dat += {"<a class="menu_a" href='?src=\ref[src];lobby_join=1'><img src='joingame.png' /></a>
		"}

	dat += {"<a class="menu_a" href='?src=\ref[src];lobby_observe=1'><img src='observe.png' /></a>
	"}
	dat += {"<a class="menu_a" href='?src=\ref[src];lobby_changelog=1'><img src='changelog.png' /></a>
	"}

	dat += "</div>"
	dat += {"
		<script language="JavaScript">
			var i=0;
			var image=document.getElementById("image");
			var imgs=new Array('ready_neok.png', 'ready_ok.png');
			function imgsrc() {
				i++;
				if (i == imgs.length)
					i = 0;
				image.src = imgs\[i\];
			}
		</script>
	"}
	dat += {"<img src="titlescreen.gif" class="fone" alt="">"}
	dat += "</body></html>"
	return dat
