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
					border-style:none;
				}

				.fone{
					position: relative;
					width: 100%;
					min-width: 100vh;
					height: 100vh;
					top:-50vh;
					left: 0;
					z-index: 0;
				}

				.container{
					height: 100%;
					width: 100vh;
					margin-left: auto;
					margin-right: auto;
				}

				.container_nav {
					position: relative;
					margin-top: auto;
					height: 50vh;
					top: 70vh;
					left:10%;
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
					margin-top: 0.5vh;
					padding-left: 6px;
					font-size: 4vh;
					line-height: 4vh;
					height: 4vh;
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
			<div class="container">
				<div class="container_nav">
				<a class="menu_a" href='?src=\ref[src];lobby_setup=1'>SETUP</a>
	"}

	if(!SSticker || SSticker.current_state <= GAME_STATE_PREGAME)
		dat += {"<a id="ready" class="menu_a" href='?src=\ref[src];lobby_ready=1' >READY ☒</a>
	"}
	else
		dat += {"<a class="menu_a" href='?src=\ref[src];lobby_crew=1'>CREW</a>
	"}
		dat += {"<a class="menu_a" href='?src=\ref[src];lobby_join=1'>JOIN</a>
	"}

	dat += {"<a class="menu_a" href='?src=\ref[src];lobby_observe=1'>OBSERVE</a>
	"}
	dat += {"<br><br><a class="menu_a" href='?src=\ref[src];lobby_changelog=1'>CHANGELOG</a>
	"}

	dat += "</div>"
	dat += {"<img src="titlescreen.gif" class="fone" alt="">"}
	dat += {"
	<script language="JavaScript">
		var i=0;
		var mark=document.getElementById("ready");
		var marks=new Array('READY ☒', 'READY ☑');
		function imgsrc() {
			i++;
			if (i == marks.length)
				i = 0;
			mark.textContent = marks\[i\];
		}
	</script>
	"}
	dat += "</div></body></html>"
	return dat
