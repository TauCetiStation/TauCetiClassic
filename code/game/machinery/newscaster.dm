//##############################################
//################### NEWSCASTERS BE HERE! ####
//###-Agouri###################################

#define COMMENTS_ON_PAGE 5 //number of comments per page

/datum/feed_message
	var/author = ""
	var/body = ""
	//var/parent_channel
	var/backup_body = ""
	var/backup_author = ""
	var/is_admin_message = 0
	var/icon/img = null
	var/icon/backup_img
	var/list/voters = list() //stores a string with voters
	var/likes = 0
	var/dislikes = 0
	var/count_comments = 0
	var/comments_closed = TRUE //spoiler
	var/list/datum/comment_pages/pages = list()

/datum/comment_pages
	var/list/datum/message_comment/comments = list() //stores COMMENTS_ON_PAGE comments

/datum/message_comment
	var/author = ""
	var/backup_author = ""
	var/body = ""
	var/backup_body = ""
	var/time = ""

/datum/feed_channel
	var/channel_name = ""
	var/list/datum/feed_message/messages = list()
	//var/message_count = 0
	var/locked = 0
	var/lock_comments = FALSE
	var/author = ""
	var/backup_author = ""
	var/censored = 0
	var/is_admin_channel = 0
	//var/page = null //For newspapers

/datum/feed_message/proc/clear()
	src.author = ""
	src.body = ""
	src.backup_body = ""
	src.backup_author = ""
	src.img = null
	src.backup_img = null

/datum/feed_channel/proc/clear()
	src.channel_name = ""
	src.messages = list()
	src.locked = 0
	src.author = ""
	src.backup_author = ""
	src.censored = 0
	src.is_admin_channel = 0

/datum/feed_message/Destroy()
	QDEL_LIST(pages)
	return ..()

/datum/comment_pages/Destroy()
	QDEL_LIST(comments)
	return ..()

/datum/feed_network
	var/list/datum/feed_channel/network_channels = list()
	var/datum/feed_message/wanted_issue

var/datum/feed_network/news_network = new /datum/feed_network     //The global news-network, which is coincidentally a global list.

var/list/obj/machinery/newscaster/allCasters = list() //Global list that will contain reference to all newscasters in existence.

/obj/item/newscaster_frame
	name = "newscaster frame"
	desc = "Used to build newscasters, just secure to the wall."
	icon_state = "newscaster"
	item_state = "syringe_kit"
	m_amt = 25000
	g_amt = 15000

/obj/item/newscaster_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(usr,on_wall)
	if (!(ndir in cardinal))
		return
	var/turf/loc = get_turf(usr)
	var/area/A = loc.loc
	if (!istype(loc, /turf/simulated/floor))
		to_chat(usr, "<span class='alert'>Newscaster cannot be placed on this spot.</span>")
		return
	if (A.requires_power == 0 || A.name == "Space")
		to_chat(usr, "<span class='alert'>Newscaster cannot be placed in this area.</span>")
		return
	for(var/obj/machinery/newscaster/T in loc)
		to_chat(usr, "<span class='alert'>There is another newscaster here.</span>")
		return
	var/obj/machinery/newscaster/N = new(loc)
	N.pixel_y -= (loc.y - on_wall.y) * 32
	N.pixel_x -= (loc.x - on_wall.x) * 32
	qdel(src)




/obj/machinery/newscaster
	name = "Newscaster"
	desc = "A standard Nanotrasen-licensed newsfeed handler for use in commercial space stations. All the news you absolutely have no use for, in one place!"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "newscaster_normal"
	var/isbroken = 0  //1 if someone banged it with something heavy
	var/ispowered = 1 //starts powered, changes with power_change()
	//var/list/datum/feed_channel/channel_list = list() //This list will contain the names of the feed channels. Each name will refer to a data region where the messages of the feed channels are stored.
	//OBSOLETE: We're now using a global news network
	var/screen = 0                  //Or maybe I'll make it into a list within a list afterwards... whichever I prefer, go fuck yourselves :3
		// 0 = welcome screen - main menu
		// 1 = view feed channels
		// 2 = create feed channel
		// 3 = create feed story
		// 4 = feed story submited sucessfully
		// 5 = feed channel created successfully
		// 6 = ERROR: Cannot create feed story
		// 7 = ERROR: Cannot create feed channel
		// 8 = print newspaper
		// 9 = viewing channel feeds
		// 10 = censor feed story
		// 11 = censor feed channel
		// 12 = pick censor channel
		// 13 = pick d notice
		// 14 = wanted issue handler
		// 15 = create wanted issue
		// 16 = ERROR: Cannot create wanted issue
		// 17 = wanted issue deleted
		// 18 = view wanted issue
		// 19 = wanted issue edited
		// 20 = orinting successful
		// 21 = need more paper
		// 22 = ERROR: Cannot create comment
		// 23 = all comment
		// 24 = all comment for security
		//Holy shit this is outdated, made this when I was still starting newscasters :3
	var/paper_remaining = 0
	var/securityCaster = 0
		// 0 = Caster cannot be used to issue wanted posters
		// 1 = the opposite
	var/unit_no = 0 //Each newscaster has a unit number
	//var/datum/feed_message/wanted //We're gonna use a feed_message to store data of the wanted person because fields are similar
	//var/wanted_issue = 0          //OBSOLETE
		// 0 = there's no WANTED issued, we don't need a special icon_state
		// 1 = Guess what.
	var/alert_delay = 500
	var/alert = 0
		// 0 = there hasn't been a news/wanted update in the last alert_delay
		// 1 = there has
	var/scanned_user = "Unknown" //Will contain the name of the person who currently uses the newscaster
	var/msg = ""                //Feed message
	var/obj/item/weapon/photo/photo = null
	var/channel_name = "" //the feed channel which will be receiving the feed, or being created
	var/c_locked = 0        //Will our new channel be locked to public submissions?
	var/hitstaken = 0      //Death at 3 hits from an item with force>=15
	var/datum/feed_channel/viewing_channel = null
	light_range = 0
	anchored = 1
	var/comment_msg = "" //stores a comment that has not yet been posted
	var/datum/comment_pages/current_page = null
	var/datum/feed_message/viewing_message = null

/obj/machinery/newscaster/security_unit                   //Security unit
	name = "Security Newscaster"
	securityCaster = 1

/obj/machinery/newscaster/atom_init()         //Constructor, ho~
	allCasters += src
	paper_remaining = 15            // Will probably change this to something better
	for(var/obj/machinery/newscaster/NEWSCASTER in allCasters) // Let's give it an appropriate unit number
		unit_no++
	update_icon() //for any custom ones on the map...
	. = ..()                                //I just realised the newscasters weren't in the global machines list. The superconstructor call will tend to that

/obj/machinery/newscaster/Destroy()
	allCasters -= src
	return ..()

/obj/machinery/newscaster/update_icon()
	if(!ispowered || isbroken)
		icon_state = "newscaster_off"
		if(isbroken) //If the thing is smashed, add crack overlay on top of the unpowered sprite.
			src.cut_overlays()
			src.add_overlay(image(src.icon, "crack3"))
		return

	src.cut_overlays() //reset overlays

	if(news_network.wanted_issue) //wanted icon state, there can be no overlays on it as it's a priority message
		icon_state = "newscaster_wanted"
		return

	if(alert) //new message alert overlay
		src.add_overlay("newscaster_alert")

	if(hitstaken > 0) //Cosmetic damage overlay
		src.add_overlay(image(src.icon, "crack[hitstaken]"))

	icon_state = "newscaster_normal"
	return

/obj/machinery/newscaster/power_change()
	if(isbroken) //Broken shit can't be powered.
		return
	if( src.powered() )
		src.ispowered = 1
		stat &= ~NOPOWER
		src.update_icon()
	else
		spawn(rand(0, 15))
			src.ispowered = 0
			stat |= NOPOWER
			src.update_icon()
	update_power_use()

/obj/machinery/newscaster/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			src.isbroken=1
			if(prob(50))
				qdel(src)
			else
				src.update_icon() //can't place it above the return and outside the if-else. or we might get runtimes of null.update_icon() if(prob(50)) goes in.
			return
		else
			if(prob(50))
				src.isbroken=1
			src.update_icon()
			return

/obj/machinery/newscaster/ui_interact(mob/user)            //########### THE MAIN BEEF IS HERE! And in the proc below this...############
	if(isbroken)
		return

	if(isobserver(user))
		to_chat(user, "[src]'s UI has no support for observer.")
		return

	if(ishuman(user) || issilicon(user)) // need abit of rewriting this to make it work for observers.
		var/mob/living/human_or_robot_user = user
		var/dat
		dat = ""

		src.scan_user(human_or_robot_user) //Newscaster scans you

		switch(screen)
			if(0)
				dat += "Welcome to Newscasting Unit #[src.unit_no].<BR> Interface & News networks Operational."
				dat += "<BR><FONT SIZE=1>Property of Nanotransen Inc</FONT>"
				if(news_network.wanted_issue)
					dat+= "<HR><A href='?src=\ref[src];view_wanted=1'>Read Wanted Issue</A>"
				dat+= "<HR><BR><A href='?src=\ref[src];create_channel=1'>Create Feed Channel</A>"
				dat+= "<BR><A href='?src=\ref[src];view=1'>View Feed Channels</A>"
				dat+= "<BR><A href='?src=\ref[src];create_feed_story=1'>Submit new Feed story</A>"
				dat+= "<BR><A href='?src=\ref[src];menu_paper=1'>Print newspaper</A>"
				dat+= "<BR><A href='?src=\ref[src];refresh=1'>Re-scan User</A>"
				dat+= "<BR><BR><A href='?src=\ref[human_or_robot_user];mach_close=newscaster_main'>Exit</A>"
				if(src.securityCaster)
					var/wanted_already = 0
					if(news_network.wanted_issue)
						wanted_already = 1

					dat+="<HR><B>Feed Security functions:</B><BR>"
					dat+="<BR><A href='?src=\ref[src];menu_wanted=1'>[(wanted_already) ? ("Manage") : ("Publish")] \"Wanted\" Issue</A>"
					dat+="<BR><A href='?src=\ref[src];menu_censor_story=1'>Censor Feed Stories</A>"
					dat+="<BR><A href='?src=\ref[src];menu_censor_channel=1'>Mark Feed Channel with Nanotrasen D-Notice</A>"
				dat+="<BR><HR>The newscaster recognises you as: <FONT COLOR='green'>[src.scanned_user]</FONT>"
			if(1)
				dat+= "Station Feed Channels<HR>"
				if( isemptylist(news_network.network_channels) )
					dat+="<I>No active channels found...</I>"
				else
					for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
						if(CHANNEL.is_admin_channel)
							dat+="<B><FONT style='BACKGROUND-COLOR: LightGreen '><A href='?src=\ref[src];show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A></FONT></B><BR>"
						else
							dat+="<B><A href='?src=\ref[src];show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : null]<BR></B>"
					/*for(var/datum/feed_channel/CHANNEL in src.channel_list)
						dat+="<B>[CHANNEL.channel_name]: </B> <BR><FONT SIZE=1>\[created by: <FONT COLOR='maroon'>[CHANNEL.author]</FONT>\]</FONT><BR><BR>"
						if( isemptylist(CHANNEL.messages) )
							dat+="<I>No feed messages found in channel...</I><BR><BR>"
						else
							for(var/datum/feed_message/MESSAGE in CHANNEL.messages)
								dat+="-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"*/

				dat+="<BR><HR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Back</A>"
			if(2)
				dat+="Creating new Feed Channel..."
				dat+="<HR><B><A href='?src=\ref[src];set_channel_name=1'>Channel Name</A>:</B> [src.channel_name]<BR>"
				dat+="<B>Channel Author:</B> <FONT COLOR='green'>[src.scanned_user]</FONT><BR>"
				dat+="<B><A href='?src=\ref[src];set_channel_lock=1'>Will Accept Public Feeds</A>:</B> [(src.c_locked) ? ("NO") : ("YES")]<BR><BR>"
				dat+="<BR><A href='?src=\ref[src];submit_new_channel=1'>Submit</A><BR><BR><A href='?src=\ref[src];setScreen=[0]'>Cancel</A><BR>"
			if(3)
				dat+="Creating new Feed Message..."
				dat+="<HR><B><A href='?src=\ref[src];set_channel_receiving=1'>Receiving Channel</A>:</B> [src.channel_name]<BR>" //MARK
				dat+="<B>Message Author:</B> <FONT COLOR='green'>[src.scanned_user]</FONT><BR>"
				dat+="<B><A href='?src=\ref[src];set_new_message=1'>Message Body</A>:</B> [src.msg] <BR>"
				dat+="<B><A href='?src=\ref[src];set_attachment=1'>Attach Photo</A>:</B>  [(src.photo ? "Photo Attached" : "No Photo")]</BR>"
				dat+="<BR><A href='?src=\ref[src];submit_new_message=1'>Submit</A><BR><BR><A href='?src=\ref[src];setScreen=[0]'>Cancel</A><BR>"
			if(4)
				dat+="Feed story successfully submitted to [src.channel_name].<BR><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(5)
				dat+="Feed Channel [src.channel_name] created successfully.<BR><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(6)
				dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed story to Network.</B></FONT><HR><BR>"
				if(src.channel_name=="")
					dat+="<FONT COLOR='maroon'>Invalid receiving channel name.</FONT><BR>"
				if(src.scanned_user=="Unknown")
					dat+="<FONT COLOR='maroon'>Channel author unverified.</FONT><BR>"
				if(src.msg == "" || src.msg == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>Invalid message body.</FONT><BR>"

				dat+="<BR><A href='?src=\ref[src];setScreen=[3]'>Return</A><BR>"
			if(7)
				dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed Channel to Network.</B></FONT><HR><BR>"
				//var/list/existing_channels = list()            //Let's get dem existing channels - OBSOLETE
				var/list/existing_authors = list()
				for(var/datum/feed_channel/FC in news_network.network_channels)
					//existing_channels += FC.channel_name       //OBSOLETE
					if(FC.author == "\[REDACTED\]")
						existing_authors += FC.backup_author
					else
						existing_authors += FC.author
				if(src.scanned_user in existing_authors)
					dat+="<FONT COLOR='maroon'>There already exists a Feed channel under your name.</FONT><BR>"
				if(src.channel_name=="" || src.channel_name == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>Invalid channel name.</FONT><BR>"
				var/check = 0
				for(var/datum/feed_channel/FC in news_network.network_channels)
					if(FC.channel_name == src.channel_name)
						check = 1
						break
				if(check)
					dat+="<FONT COLOR='maroon'>Channel name already in use.</FONT><BR>"
				if(src.scanned_user=="Unknown")
					dat+="<FONT COLOR='maroon'>Channel author unverified.</FONT><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[2]'>Return</A><BR>"
			if(8)
				var/total_num=length(news_network.network_channels)
				var/active_num=total_num
				var/message_num=0
				for(var/datum/feed_channel/FC in news_network.network_channels)
					if(!FC.censored)
						message_num += length(FC.messages)    //Dont forget, datum/feed_channel's var messages is a list of datum/feed_message
					else
						active_num--
				dat+="Network currently serves a total of [total_num] Feed channels, [active_num] of which are active, and a total of [message_num] Feed Stories." //TODO: CONTINUE
				dat+="<BR><BR><B>Liquid Paper remaining:</B> [(src.paper_remaining) *100 ] cm^3"
				dat+="<BR><BR><A href='?src=\ref[src];print_paper=[0]'>Print Paper</A>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Cancel</A>"
			if(9)
				dat+="<B>[src.viewing_channel.channel_name]: </B><FONT SIZE=1>\[created by: <FONT COLOR='maroon'>[src.viewing_channel.author]</FONT>\]</FONT><HR>"
				if(src.viewing_channel.censored)
					dat+="<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>"
					dat+="No further feed story additions are allowed while the D-Notice is in effect.<BR><BR>"
				else
					if( isemptylist(src.viewing_channel.messages) )
						dat+="<I>No feed messages found in channel...</I><BR>"
					else
						var/i = 0
						for(var/datum/feed_message/MESSAGE in src.viewing_channel.messages)
							i++
							dat+="-[MESSAGE.body] <BR>"
							if(MESSAGE.img)
								usr << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
								dat+="<img src='tmp_photo[i].png' width = '180'><BR><BR>"
							dat+="<FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"
							//If a person has already voted, then the button will not be clickable
							dat+="<FONT SIZE=1>[((src.scanned_user in MESSAGE.voters) || (src.scanned_user == "Unknown")) ? ("<img src=like_clck.png>") : ("<A href='?src=\ref[src];setLike=\ref[MESSAGE]'><img src=like.png></A>")]: <FONT SIZE=2>[MESSAGE.likes]</FONT> \
											   [((src.scanned_user in MESSAGE.voters) || (src.scanned_user == "Unknown")) ? ("<img src=dislike_clck.png>") : ("<A href='?src=\ref[src];setDislike=\ref[MESSAGE]'><img src=dislike.png></A>")]: <FONT SIZE=2>[MESSAGE.dislikes]</FONT></FONT>"

							dat+="<BR><A href='?src=\ref[src];open_pages=\ref[MESSAGE]'><B>Open Comments</B></A> - ([MESSAGE.count_comments])<HR>"

				dat+="<A href='?src=\ref[src];refresh=1'>Refresh</A>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[1]'>Back</A>"
			if(10)
				dat+="<B>Nanotrasen Feed Censorship Tool</B><BR>"
				dat+="<FONT SIZE=1>NOTE: Due to the nature of news Feeds, total deletion of a Feed Story is not possible.<BR>"
				dat+="Keep in mind that users attempting to view a censored feed will instead see the \[REDACTED\] tag above it.</FONT>"
				dat+="<HR>Select Feed channel to get Stories from:<BR>"
				if(isemptylist(news_network.network_channels))
					dat+="<I>No feed channels found active...</I><BR>"
				else
					for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
						dat+="<A href='?src=\ref[src];pick_censor_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : null]<BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Cancel</A>"
			if(11)
				dat+="<B>Nanotrasen D-Notice Handler</B><HR>"
				dat+="<FONT SIZE=1>A D-Notice is to be bestowed upon the channel if the handling Authority deems it as harmful for the station's"
				dat+="morale, integrity or disciplinary behaviour. A D-Notice will render a channel unable to be updated by anyone, without deleting any feed"
				dat+="stories it might contain at the time. You can lift a D-Notice if you have the required access at any time.</FONT><HR>"
				if(isemptylist(news_network.network_channels))
					dat+="<I>No feed channels found active...</I><BR>"
				else
					for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
						dat+="<A href='?src=\ref[src];pick_d_notice=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : null]<BR>"

				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Back</A>"
			if(12)
				dat+="<B>[src.viewing_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.viewing_channel.author]</FONT> \]</FONT><BR>"
				dat+="<FONT SIZE=2><A href='?src=\ref[src];censor_channel_author=\ref[src.viewing_channel]'>[(src.viewing_channel.author=="\[REDACTED\]") ? ("Undo Author censorship") : ("Censor channel Author")]</A></FONT><BR>"


				if( isemptylist(src.viewing_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					for(var/datum/feed_message/MESSAGE in src.viewing_channel.messages)
						dat+="-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"
						dat+="<FONT SIZE=2><A href='?src=\ref[src];censor_channel_story_body=\ref[MESSAGE]'>[(MESSAGE.body == "\[REDACTED\]") ? ("Undo story censorship") : ("Censor story")]</A>  -\
						                   <A href='?src=\ref[src];censor_channel_story_author=\ref[MESSAGE]'> [(MESSAGE.author == "\[REDACTED\]") ? ("Undo Author censorship") : ("Censor message Author")]</A></FONT><BR>"
						dat+="<HR><A href='?src=\ref[src];open_censor_pages=\ref[MESSAGE]'><B>Open Comments</B></A> - <B><FONT SIZE=2><A href='?src=\ref[src];locked_comments=1'>[(src.viewing_channel.lock_comments) ? ("Unlock") : ("Lock")]</A></B></FONT><BR><HR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[10]'>Back</A>"
			if(13)
				dat+="<B>[src.viewing_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.viewing_channel.author]</FONT> \]</FONT><BR>"
				dat+="Channel messages listed below. If you deem them dangerous to the station, you can <A href='?src=\ref[src];toggle_d_notice=\ref[src.viewing_channel]'>Bestow a D-Notice upon the channel</A>.<HR>"
				if(src.viewing_channel.censored)
					dat+="<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>"
					dat+="No further feed story additions are allowed while the D-Notice is in effect.</FONT><BR><BR>"
				else
					if( isemptylist(src.viewing_channel.messages) )
						dat+="<I>No feed messages found in channel...</I><BR>"
					else
						for(var/datum/feed_message/MESSAGE in src.viewing_channel.messages)
							dat+="-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"

				dat+="<BR><A href='?src=\ref[src];setScreen=[11]'>Back</A>"
			if(14)
				dat+="<B>Wanted Issue Handler:</B>"
				var/wanted_already = 0
				var/end_param = 1
				if(news_network.wanted_issue)
					wanted_already = 1
					end_param = 2

				if(wanted_already)
					dat+="<FONT SIZE=2><BR><I>A wanted issue is already in Feed Circulation. You can edit or cancel it below.</FONT></I>"
				dat+="<HR>"
				dat+="<A href='?src=\ref[src];set_wanted_name=1'>Criminal Name</A>: [src.channel_name] <BR>"
				dat+="<A href='?src=\ref[src];set_wanted_desc=1'>Description</A>: [src.msg] <BR>"
				dat+="<A href='?src=\ref[src];set_attachment=1'>Attach Photo</A>: [(src.photo ? "Photo Attached" : "No Photo")]</BR>"
				if(wanted_already)
					dat+="<B>Wanted Issue created by:</B><FONT COLOR='green'> [news_network.wanted_issue.backup_author]</FONT><BR>"
				else
					dat+="<B>Wanted Issue will be created under prosecutor:</B><FONT COLOR='green'> [src.scanned_user]</FONT><BR>"
				dat+="<BR><A href='?src=\ref[src];submit_wanted=[end_param]'>[(wanted_already) ? ("Edit Issue") : ("Submit")]</A>"
				if(wanted_already)
					dat+="<BR><A href='?src=\ref[src];cancel_wanted=1'>Take down Issue</A>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Cancel</A>"
			if(15)
				dat+="<FONT COLOR='green'>Wanted issue for [src.channel_name] is now in Network Circulation.</FONT><BR><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(16)
				dat+="<B><FONT COLOR='maroon'>ERROR: Wanted Issue rejected by Network.</B></FONT><HR><BR>"
				if(src.channel_name=="" || src.channel_name == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>Invalid name for person wanted.</FONT><BR>"
				if(src.scanned_user=="Unknown")
					dat+="<FONT COLOR='maroon'>Issue author unverified.</FONT><BR>"
				if(src.msg == "" || src.msg == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>Invalid description.</FONT><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(17)
				dat+="<B>Wanted Issue successfully deleted from Circulation</B><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(18)
				dat+="<B><FONT COLOR ='maroon'>-- STATIONWIDE WANTED ISSUE --</B></FONT><BR><FONT SIZE=2>\[Submitted by: <FONT COLOR='green'>[news_network.wanted_issue.backup_author]</FONT>\]</FONT><HR>"
				dat+="<B>Criminal</B>: [news_network.wanted_issue.author]<BR>"
				dat+="<B>Description</B>: [news_network.wanted_issue.body]<BR>"
				dat+="<B>Photo:</B>: "
				if(news_network.wanted_issue.img)
					usr << browse_rsc(news_network.wanted_issue.img, "tmp_photow.png")
					dat+="<BR><img src='tmp_photow.png' width = '180'>"
				else
					dat+="None"
				dat+="<BR><BR><A href='?src=\ref[src];setScreen=[0]'>Back</A><BR>"
			if(19)
				dat+="<FONT COLOR='green'>Wanted issue for [src.channel_name] successfully edited.</FONT><BR><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(20)
				dat+="<FONT COLOR='green'>Printing successful. Please receive your newspaper from the bottom of the machine.</FONT><BR><BR>"
				dat+="<A href='?src=\ref[src];setScreen=[0]'>Return</A>"
			if(21)
				dat+="<FONT COLOR='maroon'>Unable to print newspaper. Insufficient paper. Please notify maintenance personnel to refill machine storage.</FONT><BR><BR>"
				dat+="<A href='?src=\ref[src];setScreen=[0]'>Return</A>"
			if(22)
				dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit comment to Network.</B></FONT><HR><BR>"
				if(src.comment_msg == "" || src.comment_msg == null)
					dat+="<FONT COLOR='maroon'>Invalid lenght of comment.</FONT><BR>"
				if(src.scanned_user == "Unknown")
					dat+="<FONT COLOR='maroon'>Invalid name.</FONT><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[1]'>Return</A><BR>"
			if(23)
				dat+="<B>Story ([src.viewing_message.body])</B><HR>"
				var/datum/feed_message/MESSAGE = src.viewing_message
				dat+="Number of Comments - [MESSAGE.count_comments]<BR>"
				if(!src.viewing_channel.lock_comments)
					dat+="<B><A href='?src=\ref[src];leave_a_comment=\ref[MESSAGE]'>Leave a comment</A></B>"
				else
					dat+="<B><FONT SIZE=3>Comments are closed!</FONT></B>"
				var/datum/comment_pages/PAGE = src.current_page
				if(PAGE.comments.len != 0) //perfecto
					dat+="<HR>"
				for(var/datum/message_comment/COMMENT in PAGE.comments)
					dat+="<FONT COLOR='GREEN'>[COMMENT.author]</FONT> <FONT COLOR='RED'>[COMMENT.time]</FONT><BR>"
					dat+="-<FONT SIZE=3>[COMMENT.body]</FONT><BR>"
				var/i = 0
				dat+="<HR>"
				for(var/datum/comment_pages/PAGES in MESSAGE.pages)
					i++
					dat+="[(src.current_page != PAGES) ? ("<A href='?src=\ref[src];next_page=\ref[PAGES]'> [i]</A>") : (" [i]")]"
				dat+="<HR><A href='?src=\ref[src];refresh=1'>Refresh</A><BR>"
				dat+="<A href='?src=\ref[src];setScreen=[9]'>Return</A>"
			if(24)
				dat+="<B>Story ([src.viewing_message.body])</B><HR>"
				var/datum/feed_message/MESSAGE = src.viewing_message
				dat+="Number of Comments - [MESSAGE.count_comments]<HR>"
				var/datum/comment_pages/PAGE = src.current_page
				for(var/datum/message_comment/COMMENT in PAGE.comments)
					dat+="<FONT COLOR='GREEN'>[COMMENT.author]</FONT> <FONT COLOR='RED'>[COMMENT.time]</FONT><BR>"
					dat+="<FONT SIZE=2><A href='?src=\ref[src];censor_author_comment=\ref[COMMENT]'>[(COMMENT.author == "\[REDACTED\]") ? ("Undo Author censorship") : ("Censor Author")]</A></FONT><BR>"
					dat+="-<FONT SIZE=3>[COMMENT.body]</FONT><BR>"
					dat+="<FONT SIZE=2><A href='?src=\ref[src];censor_body_comment=\ref[COMMENT]'>[(COMMENT.body == "\[REDACTED\]") ? ("Undo comment censorship") : ("Censor comment")]</A></FONT><BR><HR>"
				var/i = 0
				for(var/datum/comment_pages/PAGES in MESSAGE.pages)
					i++
					dat+="[(src.current_page != PAGES) ? ("<A href='?src=\ref[src];next_censor_page=\ref[PAGES]'> [i]</A>") : (" [i]")]"
				dat+="<HR><A href='?src=\ref[src];refresh=1'>Refresh</A><BR>"
				dat+="<A href='?src=\ref[src];setScreen=[10]'>Return</A>"
			else
				dat+="Error 404"

		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/newscaster)		//Sending pictures to the client
		assets.register()
		assets.send(human_or_robot_user)

		var/datum/browser/popup = new(human_or_robot_user, "window=newscaster_main", src.name, 400, 600, ntheme = CSS_THEME_LIGHT)
		popup.set_content(dat)
		popup.open()

	/*if(src.isbroken) //debugging shit
		return
	src.hitstaken++
	if(src.hitstaken==3)
		src.isbroken = 1
	src.update_icon()*/


/obj/machinery/newscaster/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["set_channel_name"])
		src.channel_name = sanitize_safe(input(usr, "Provide a Feed Channel Name", "Network Channel Handler", input_default(channel_name)), MAX_LNAME_LEN)
		//src.update_icon()

	else if(href_list["set_channel_lock"])
		src.c_locked = !src.c_locked
		//src.update_icon()

	else if(href_list["submit_new_channel"])
		//var/list/existing_channels = list() //OBSOLETE
		var/list/existing_authors = list()
		for(var/datum/feed_channel/FC in news_network.network_channels)
			//existing_channels += FC.channel_name
			if(FC.author == "\[REDACTED\]")
				existing_authors += FC.backup_author
			else
				existing_authors  +=FC.author
		var/check = 0
		for(var/datum/feed_channel/FC in news_network.network_channels)
			if(FC.channel_name == src.channel_name)
				check = 1
				break
		if(src.channel_name == "" || src.channel_name == "\[REDACTED\]" || src.scanned_user == "Unknown" || check || (src.scanned_user in existing_authors) )
			src.screen = 7
		else
			var/choice = alert("Please confirm Feed channel creation","Network Channel Handler","Confirm","Cancel")
			if(choice=="Confirm")
				var/datum/feed_channel/newChannel = new /datum/feed_channel
				newChannel.channel_name = src.channel_name
				newChannel.author = src.scanned_user
				newChannel.locked = c_locked
				feedback_inc("newscaster_channels",1)
				/*for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)    //Let's add the new channel in all casters.
					NEWSCASTER.channel_list += newChannel*/                     //Now that it is sane, get it into the list. -OBSOLETE
				news_network.network_channels += newChannel                        //Adding channel to the global network
				src.screen = 5
		//src.update_icon()

	else if(href_list["set_channel_receiving"])
		//var/list/datum/feed_channel/available_channels = list()
		var/list/available_channels = list()
		for(var/datum/feed_channel/F in news_network.network_channels)
			if( (!F.locked || F.author == scanned_user) && !F.censored)
				available_channels += F.channel_name
		src.channel_name = input(usr, "Choose receiving Feed Channel", "Network Channel Handler") in available_channels

	else if(href_list["set_new_message"])
		src.msg = sanitize(input(usr, "Write your Feed story", "Network Channel Handler", input_default(src.msg)), extra = FALSE)

	else if(href_list["set_attachment"])
		AttachPhoto(usr)

	else if(href_list["submit_new_message"])
		if(src.msg == "" || src.msg == "\[REDACTED\]" || src.scanned_user == "Unknown" || src.channel_name == "" )
			src.screen = 6
		else
			var/datum/feed_message/newMsg = new /datum/feed_message
			var/datum/comment_pages/CP = new /datum/comment_pages
			newMsg.author = src.scanned_user
			newMsg.body = src.msg
			if(photo)
				newMsg.img = photo.img
			feedback_inc("newscaster_stories",1)
			for(var/datum/feed_channel/FC in news_network.network_channels)
				if(FC.channel_name == src.channel_name)
					FC.messages += newMsg                  //Adding message to the network's appropriate feed_channel
					newMsg.pages += CP
					break
			src.screen = 4
			for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
				NEWSCASTER.newsAlert(src.channel_name)

	else if(href_list["create_channel"])
		src.screen = 2

	else if(href_list["create_feed_story"])
		src.screen = 3

	else if(href_list["menu_paper"])
		src.screen = 8
	else if(href_list["print_paper"])
		if(!src.paper_remaining)
			src.screen = 21
		else
			src.print_paper()
			src.screen = 20

	else if(href_list["menu_censor_story"])
		src.screen = 10

	else if(href_list["menu_censor_channel"])
		src.screen = 11

	else if(href_list["menu_wanted"])
		var/already_wanted = 0
		if(news_network.wanted_issue)
			already_wanted = 1

		if(already_wanted)
			src.channel_name = news_network.wanted_issue.author
			src.msg = news_network.wanted_issue.body
		src.screen = 14

	else if(href_list["set_wanted_name"])
		src.channel_name = sanitize(input(usr, "Provide the name of the Wanted person", "Network Security Handler", input_default(channel_name)), MAX_LNAME_LEN)

	else if(href_list["set_wanted_desc"])
		src.msg = sanitize(input(usr, "Provide the a description of the Wanted person and any other details you deem important", "Network Security Handler", input_default(msg)), extra = FALSE)

	else if(href_list["submit_wanted"])
		var/input_param = text2num(href_list["submit_wanted"])
		if(src.msg == "" || src.channel_name == "" || src.scanned_user == "Unknown")
			src.screen = 16
		else
			var/choice = alert("Please confirm Wanted Issue [(input_param==1) ? ("creation.") : ("edit.")]","Network Security Handler","Confirm","Cancel")
			if(choice == "Confirm")
				if(input_param == 1)          //If input_param == 1 we're submitting a new wanted issue. At 2 we're just editing an existing one. See the else below
					var/datum/feed_message/WANTED = new /datum/feed_message
					WANTED.author = src.channel_name
					WANTED.body = src.msg
					WANTED.backup_author = src.scanned_user //I know, a bit wacky
					if(photo)
						WANTED.img = photo.img
					news_network.wanted_issue = WANTED
					for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
						NEWSCASTER.newsAlert()
						NEWSCASTER.update_icon()
					src.screen = 15
				else
					if(news_network.wanted_issue.is_admin_message)
						to_chat(usr, "The wanted issue has been distributed by a Nanotrasen higherup. You cannot edit it.")
						return FALSE
					news_network.wanted_issue.author = src.channel_name
					news_network.wanted_issue.body = src.msg
					news_network.wanted_issue.backup_author = src.scanned_user
					if(photo)
						news_network.wanted_issue.img = photo.img
					src.screen = 19

	else if(href_list["cancel_wanted"])
		if(news_network.wanted_issue.is_admin_message)
			to_chat(usr, "The wanted issue has been distributed by a Nanotrasen higherup. You cannot take it down.")
			return FALSE
		var/choice = alert("Please confirm Wanted Issue removal","Network Security Handler","Confirm","Cancel")
		if(choice=="Confirm")
			news_network.wanted_issue = null
			for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
				NEWSCASTER.update_icon()
			src.screen = 17

	else if(href_list["view_wanted"])
		src.screen = 18
	else if(href_list["censor_channel_author"])
		var/datum/feed_channel/FC = locate(href_list["censor_channel_author"])
		if(FC.is_admin_channel)
			to_chat(usr, "This channel was created by a Nanotrasen Officer. You cannot censor it.")
			return FALSE
		if(FC.author != "<B>\[REDACTED\]</B>")
			FC.backup_author = FC.author
			FC.author = "<B>\[REDACTED\]</B>"
		else
			FC.author = FC.backup_author

	else if(href_list["censor_channel_story_author"])
		var/datum/feed_message/MSG = locate(href_list["censor_channel_story_author"])
		if(MSG.is_admin_message)
			to_chat(usr, "This message was created by a Nanotrasen Officer. You cannot censor its author.")
			return FALSE
		if(MSG.author != "<B>\[REDACTED\]</B>")
			MSG.backup_author = MSG.author
			MSG.author = "<B>\[REDACTED\]</B>"
		else
			MSG.author = MSG.backup_author

	else if(href_list["censor_channel_story_body"])
		var/datum/feed_message/MSG = locate(href_list["censor_channel_story_body"])
		if(MSG.is_admin_message)
			to_chat(usr, "This channel was created by a Nanotrasen Officer. You cannot censor it.")
			return FALSE
		if(MSG.img != null)
			MSG.backup_img = MSG.img
			MSG.img = null
		else
			MSG.img = MSG.backup_img
		if(MSG.body != "<B>\[REDACTED\]</B>")
			MSG.backup_body = MSG.body
			MSG.body = "<B>\[REDACTED\]</B>"
		else
			MSG.body = MSG.backup_body

	else if(href_list["censor_author_comment"])
		var/datum/message_comment/COMMENT = locate(href_list["censor_author_comment"])
		if(COMMENT.author != "<FONT SIZE=2><B>\[REDACTED\]</B></FONT>")
			COMMENT.backup_author = COMMENT.author
			COMMENT.author = "<FONT SIZE=2><B>\[REDACTED\]</B></FONT>"
		else
			COMMENT.author = COMMENT.backup_author

	else if(href_list["censor_body_comment"])
		var/datum/message_comment/COMMENT = locate(href_list["censor_body_comment"])
		if(COMMENT.body != "<FONT SIZE=2><B>\[REDACTED\]</B></FONT>")
			COMMENT.backup_body = COMMENT.body
			COMMENT.body = "<FONT SIZE=2><B>\[REDACTED\]</B></FONT>"
		else
			COMMENT.body = COMMENT.backup_body

	else if(href_list["pick_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["pick_d_notice"])
		src.viewing_channel = FC
		src.screen = 13

	else if(href_list["toggle_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["toggle_d_notice"])
		if(FC.is_admin_channel)
			to_chat(usr, "This channel was created by a Nanotrasen Officer. You cannot place a D-Notice upon it.")
			return FALSE
		FC.censored = !FC.censored

	else if(href_list["view"])
		src.screen = 1

	else if(href_list["setScreen"]) //Brings us to the main menu and resets all fields~
		src.screen = text2num(href_list["setScreen"])
		if (src.screen == 0)
			src.scanned_user = "Unknown"
			msg = ""
			src.c_locked = 0
			channel_name = ""
			src.viewing_channel = null

	else if(href_list["show_channel"])
		var/datum/feed_channel/FC = locate(href_list["show_channel"])
		src.viewing_channel = FC
		src.screen = 9

	else if(href_list["pick_censor_channel"])
		var/datum/feed_channel/FC = locate(href_list["pick_censor_channel"])
		src.viewing_channel = FC
		src.screen = 12

	else if(href_list["setLike"])
		var/datum/feed_message/FM = locate(href_list["setLike"])
		FM.voters += src.scanned_user
		FM.likes += 1

	else if(href_list["setDislike"])
		var/datum/feed_message/FM = locate(href_list["setDislike"])
		FM.voters += src.scanned_user
		FM.dislikes += 1

	else if(href_list["open_pages"]) //page with comments for assistants
		var/datum/feed_message/FM = locate(href_list["open_pages"])
		src.viewing_message = FM
		src.current_page = FM.pages[1]
		src.screen = 23

	else if(href_list["open_censor_pages"]) //page with comments for security
		var/datum/feed_message/FM = locate(href_list["open_censor_pages"])
		src.viewing_message = FM
		src.current_page = FM.pages[1]
		src.screen = 24

	else if(href_list["next_page"])
		var/datum/comment_pages/CP = locate(href_list["next_page"])
		src.screen = 23
		src.current_page = CP

	else if(href_list["next_censor_page"])
		var/datum/comment_pages/CP = locate(href_list["next_censor_page"])
		src.screen = 24
		src.current_page = CP

	else if(href_list["leave_a_comment"])
		var/datum/feed_message/FM = locate(href_list["leave_a_comment"])
		src.comment_msg = sanitize(input(usr, "Write your comment", "Network Channel Handler", input_default(src.comment_msg)), extra = FALSE)
		if(src.comment_msg == "" || src.comment_msg == null || src.scanned_user == "Unknown")
			src.screen = 22
		else
			var/datum/message_comment/COMMENT = new /datum/message_comment
			COMMENT.author = src.scanned_user
			COMMENT.body = src.comment_msg
			COMMENT.time = worldtime2text()

			var/lenght = FM.pages.len //find the last page
			var/size = FM.pages[lenght].comments.len

			if(size - COMMENTS_ON_PAGE != 0) //Create new page, if comments on the page are equal
				FM.pages[lenght].comments += COMMENT
			else
				var/datum/comment_pages/CP = new /datum/comment_pages
				FM.pages += CP
				CP.comments += COMMENT

			FM.count_comments += 1

			src.comment_msg = ""

	else if(href_list["locked_comments"])
		if(src.viewing_channel.lock_comments)
			src.viewing_channel.lock_comments = FALSE
		else
			src.viewing_channel.lock_comments = TRUE

	src.updateUsrDialog()

/obj/machinery/newscaster/attackby(obj/item/I, mob/user)

/*	if (istype(I, /obj/item/weapon/card/id) || istype(I, /obj/item/device/pda) ) //Name verification for channels or messages
		if(src.screen == 4 || src.screen == 5)
			if( istype(I, /obj/item/device/pda) )
				var/obj/item/device/pda/P = I
				if(P.id)
					src.scanned_user = "[P.id.registered_name] ([P.id.assignment])"
					src.screen=2
			else
				var/obj/item/weapon/card/id/T = I
				src.scanned_user = text("[T.registered_name] ([T.assignment])")
				src.screen=2*/  //Obsolete after autorecognition

	if(iswrench(I))
		if(user.is_busy())
			return
		to_chat(user, "<span class='notice'>Now [anchored ? "un" : ""]securing [name]</span>")
		if(I.use_tool(src, user, 60, volume = 50))
			new /obj/item/newscaster_frame(loc)
			playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
			qdel(src)
		return

	if (src.isbroken)
		playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', VOL_EFFECTS_MASTER)
		user.visible_message("<EM>[user.name]</EM> further abuses the shattered [src.name].")
	else
		if(istype(I, /obj/item/weapon) )
			user.do_attack_animation(src)
			user.SetNextMove(CLICK_CD_MELEE)
			var/obj/item/weapon/W = I
			if(W.force <15)
				user.visible_message("[user.name] hits the [src.name] with the [W.name] with no visible effect.")
				playsound(src, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER)
			else
				src.hitstaken++
				if(src.hitstaken==3)
					user.visible_message("[user.name] smashes the [src.name]!")
					src.isbroken=1
					playsound(src, 'sound/effects/Glassbr3.ogg', VOL_EFFECTS_MASTER)
				else
					user.visible_message("[user.name] forcefully slams the [src.name] with the [I.name]!")
					playsound(src, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER)
		else
			to_chat(user, "<span class='info'>This does nothing.</span>")
	src.update_icon()

/obj/machinery/newscaster/attack_paw(mob/user)
	to_chat(user, "<span class='info'>The newscaster controls are far too complicated for your tiny brain!</span>")
	return

/obj/machinery/newscaster/proc/AttachPhoto(mob/user)
	if(photo)
		if(!issilicon(user))
			photo.loc = src.loc
			user.put_in_inactive_hand(photo)
		photo = null
	if(istype(user.get_active_hand(), /obj/item/weapon/photo))
		photo = user.get_active_hand()
		user.drop_item()
		photo.loc = src
	else if(istype(user,/mob/living/silicon))
		var/mob/living/silicon/tempAI = user
		var/obj/item/device/camera/siliconcam/camera = tempAI.aiCamera

		if(!camera)
			return
		var/datum/picture/selection = camera.selectpicture()
		if (!selection)
			return

		var/obj/item/weapon/photo/P = new/obj/item/weapon/photo()
		P.construct(selection)
		photo = P




//########################################################################################################################
//###################################### NEWSPAPER! ######################################################################
//########################################################################################################################

/obj/item/weapon/newspaper
	name = "Newspaper"
	desc = "An issue of The Griffon, the newspaper circulating aboard Nanotrasen Space Stations."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "newspaper"
	w_class = ITEM_SIZE_SMALL	//Let's make it fit in trashbags!
	attack_verb = list("bapped")
	var/screen = 0
	var/pages = 0
	var/curr_page = 0
	var/list/datum/feed_channel/news_content = list()
	var/datum/feed_message/important_message = null
	var/scribble=""
	var/scribble_page = null

/obj/item/weapon/newspaper/attack_self(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/dat
		src.pages = 0
		switch(screen)
			if(0) //Cover
				dat+="<DIV ALIGN='center'><B><FONT SIZE=6>The Griffon</FONT></B></div>"
				dat+="<DIV ALIGN='center'><FONT SIZE=2>Nanotrasen-standard newspaper, for use on Nanotrasen© Space Facilities</FONT></div><HR>"
				if(isemptylist(src.news_content))
					if(src.important_message)
						dat+="Contents:<BR><ul><B><FONT COLOR='red'>**</FONT>Important Security Announcement<FONT COLOR='red'>**</FONT></B> <FONT SIZE=2>\[page [src.pages+2]\]</FONT><BR></ul>"
					else
						dat+="<I>Other than the title, the rest of the newspaper is unprinted...</I>"
				else
					dat+="Contents:<BR><ul>"
					for(var/datum/feed_channel/NP in src.news_content)
						src.pages++
					if(src.important_message)
						dat+="<B><FONT COLOR='red'>**</FONT>Important Security Announcement<FONT COLOR='red'>**</FONT></B> <FONT SIZE=2>\[page [src.pages+2]\]</FONT><BR>"
					var/temp_page=0
					for(var/datum/feed_channel/NP in src.news_content)
						temp_page++
						dat+="<B>[NP.channel_name]</B> <FONT SIZE=2>\[page [temp_page+1]\]</FONT><BR>"
					dat+="</ul>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[src.scribble]\"</I>"
				dat+= "<HR><DIV STYLE='float:right;'><A href='?src=\ref[src];next_page=1'>Next Page</A></DIV> <div style='float:left;'><A href='?src=\ref[human_user];mach_close=newspaper_main'>Done reading</A></DIV>"
			if(1) // X channel pages inbetween.
				for(var/datum/feed_channel/NP in src.news_content)
					src.pages++ //Let's get it right again.
				var/datum/feed_channel/C = src.news_content[src.curr_page]
				dat+="<FONT SIZE=4><B>[C.channel_name]</B></FONT><FONT SIZE=1> \[created by: <FONT COLOR='maroon'>[C.author]</FONT>\]</FONT><BR><BR>"
				if(C.censored)
					dat+="This channel was deemed dangerous to the general welfare of the station and therefore marked with a <B><FONT COLOR='red'>D-Notice</B></FONT>. Its contents were not transferred to the newspaper at the time of printing."
				else
					if(isemptylist(C.messages))
						dat+="No Feed stories stem from this channel..."
					else
						dat+="<ul>"
						var/i = 0
						for(var/datum/feed_message/MESSAGE in C.messages)
							i++
							dat+="-[MESSAGE.body] <BR>"
							if(MESSAGE.img)
								user << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
								dat+="<img src='tmp_photo[i].png' width = '180'><BR>"
							dat+="<FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"
							dat+="<FONT SIZE=1>Likes: [MESSAGE.likes] Dislikes: [MESSAGE.dislikes]</FONT><BR><BR>"
						dat+="</ul>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[src.scribble]\"</I>"
				dat+= "<BR><HR><DIV STYLE='float:left;'><A href='?src=\ref[src];prev_page=1'>Previous Page</A></DIV> <DIV STYLE='float:right;'><A href='?src=\ref[src];next_page=1'>Next Page</A></DIV>"
			if(2) //Last page
				for(var/datum/feed_channel/NP in src.news_content)
					src.pages++
				if(src.important_message!=null)
					dat+="<DIV STYLE='float:center;'><FONT SIZE=4><B>Wanted Issue:</B></FONT SIZE></DIV><BR><BR>"
					dat+="<B>Criminal name</B>: <FONT COLOR='maroon'>[important_message.author]</FONT><BR>"
					dat+="<B>Description</B>: [important_message.body]<BR>"
					dat+="<B>Photo:</B>: "
					if(important_message.img)
						user << browse_rsc(important_message.img, "tmp_photow.png")
						dat+="<BR><img src='tmp_photow.png' width = '180'>"
					else
						dat+="None"
				else
					dat+="<I>Apart from some uninteresting Classified ads, there's nothing on this page...</I>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[src.scribble]\"</I>"
				dat+= "<HR><DIV STYLE='float:left;'><A href='?src=\ref[src];prev_page=1'>Previous Page</A></DIV>"
			else
				dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"

		dat+="<BR><HR><div align='center'>[src.curr_page+1]</div>"

		var/datum/browser/popup = new(human_user, "window=newspaper_main", src.name, 300, 400, ntheme = CSS_THEME_LIGHT)
		popup.set_content(dat)
		popup.open()
	else
		to_chat(user, "The paper is full of intelligible symbols!")


/obj/item/weapon/newspaper/Topic(href, href_list)
	var/mob/living/U = usr
	..()
	if ((src in U.contents) || ( istype(loc, /turf) && in_range(src, U) ))
		U.set_machine(src)
		if(href_list["next_page"])
			if(curr_page==src.pages+1)
				return //Don't need that at all, but anyway.
			if(src.curr_page == src.pages) //We're at the middle, get to the end
				src.screen = 2
			else
				if(curr_page == 0) //We're at the start, get to the middle
					src.screen=1
			src.curr_page++
			playsound(src, pick(SOUNDIN_PAGETURN), VOL_EFFECTS_MASTER)

		else if(href_list["prev_page"])
			if(curr_page == 0)
				return
			if(curr_page == 1)
				src.screen = 0

			else
				if(curr_page == src.pages+1) //we're at the end, let's go back to the middle.
					src.screen = 1
			src.curr_page--
			playsound(src, pick(SOUNDIN_PAGETURN), VOL_EFFECTS_MASTER)

		if (istype(src.loc, /mob))
			src.attack_self(src.loc)


/obj/item/weapon/newspaper/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/pen))
		if(src.scribble_page == src.curr_page)
			to_chat(user, "<FONT COLOR='blue'>There's already a scribble in this page... You wouldn't want to make things too cluttered, would you?</FONT>")
		else
			var/s = sanitize(input(user, "Write something", "Newspaper", ""))
			if (!s)
				return
			if (!in_range(src, usr) && src.loc != usr)
				return
			src.scribble_page = src.curr_page
			src.scribble = s
			src.attack_self(user)
		return
	return ..()


////////////////////////////////////helper procs


/obj/machinery/newscaster/proc/scan_user(mob/living/user)
	if(istype(user,/mob/living/carbon/human))                       //User is a human
		var/mob/living/carbon/human/human_user = user
		if(human_user.wear_id)                                      //Newscaster scans you
			if(istype(human_user.wear_id, /obj/item/device/pda) )	//autorecognition, woo!
				var/obj/item/device/pda/P = human_user.wear_id
				if(P.id)
					src.scanned_user = "[P.id.registered_name] ([P.id.assignment])"
				else
					src.scanned_user = "Unknown"
			else if(istype(human_user.wear_id, /obj/item/weapon/card/id) )
				var/obj/item/weapon/card/id/ID = human_user.wear_id
				src.scanned_user ="[ID.registered_name] ([ID.assignment])"
			else
				src.scanned_user ="Unknown"
		else
			src.scanned_user ="Unknown"
	else
		var/mob/living/silicon/ai_user = user
		src.scanned_user = "[ai_user.name] ([ai_user.job])"


/obj/machinery/newscaster/proc/print_paper()
	feedback_inc("newscaster_newspapers_printed",1)
	var/obj/item/weapon/newspaper/NEWSPAPER = new /obj/item/weapon/newspaper
	for(var/datum/feed_channel/FC in news_network.network_channels)
		NEWSPAPER.news_content += FC
	if(news_network.wanted_issue)
		NEWSPAPER.important_message = news_network.wanted_issue
	NEWSPAPER.loc = get_turf(src)
	src.paper_remaining--
	return

//Removed for now so these aren't even checked every tick. Left this here in-case Agouri needs it later.
///obj/machinery/newscaster/process()       //Was thinking of doing the icon update through process, but multiple iterations per second does not
//	return                                  //bode well with a newscaster network of 10+ machines. Let's just return it, as it's added in the machines list.

/obj/machinery/newscaster/proc/newsAlert(channel)
	if(channel)
		audible_message("<span class='newscaster'><EM>[name]</EM> beeps, \"Breaking news from [channel]!\"</span>")
		alert = 1
		update_icon()
		spawn(300)
			alert = 0
			update_icon()
		playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)
	else
		audible_message("<span class='newscaster'><EM>[name]</EM> beeps, \"Attention! Wanted issue distributed!\"</span>")
		playsound(src, 'sound/machines/warning-buzzer.ogg', VOL_EFFECTS_MASTER)
	return

#undef COMMENTS_ON_PAGE
