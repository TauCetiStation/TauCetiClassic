/*****************************************
*
* FUNCTION AND VAR DECLARATIONS
*
******************************************/

//DEBUG STUFF
var triggerError = attachErrorHandler('browserOutput', true);
var escaper = encodeURIComponent || escape;
var decoder = decodeURIComponent || unescape;

//Globals
window.status = 'Output';
var $messages, $subOptions, $selectedSub, $contextMenu, $filterMessages, $last_message;
var opts = {
	//General
	'messageCount': 0, //A count...of messages...
	'messageLimit': 2053, //A limit...for the messages...
	'scrollSnapTolerance': 10, //If within x pixels of bottom
	'clickTolerance': 10, //Keep focus if outside x pixels of mousedown position on mouseup
	'imageRetryDelay': 50, //how long between attempts to reload images (in ms)
	'imageRetryLimit': 5, //how many attempts should we make?
	'popups': 0, //Amount of popups opened ever
	'wasd': false, //Is the user in wasd mode?
	'priorChatHeight': 0, //Thing for height-resizing detection
	'restarting': false, //Is the round restarting?

	//Options menu
	'selectedSubLoop': null, //Contains the interval loop for closing the selected sub menu
	'suppressSubClose': false, //Whether or not we should be hiding the selected sub menu
	'highlightTerms': [],
	'highlightLimit': 5,
	'highlightColor': '#FFFF00', //The color of the highlighted message
	'pingDisabled': false, //Has the user disabled the ping counter
	'emojiList': [],

	//Ping display
	'lastPang': 0, //Timestamp of the last response from the server.
	'pangLimit': 35000,
	'pingTime': 0, //Timestamp of when ping sent
	'pongTime': 0, //Timestamp of when ping received
	'noResponse': false, //Tracks the state of the previous ping request
	'noResponseCount': 0, //How many failed pings?

	//Clicks
	'mouseDownX': null,
	'mouseDownY': null,
	'preventFocus': false, //Prevents switching focus to the game window

	//Client Connection Data
	'clientDataLimit': 5,
	'clientData': [],

	//Admin music volume update
	'volumeUpdateDelay': 700, //Time from when the volume updates to data being sent to the server
	'volumeUpdating': false, //True if volume update function set to fire
	'updatedVolume': 0, //The volume level that is sent to the server

	'messageCombining': true,

	// List of macros in the 'hotkeymode' macro set.
	'macros': {}
};

function clamp(val, min, max) {
	return Math.max(min, Math.min(val, max));
}

function outerHTML(el) {
    var wrap = document.createElement('div');
    wrap.appendChild(el.cloneNode(true));
    return wrap.innerHTML;
}

//Polyfill for fucking date now because of course IE8 and below don't support it
if (!Date.now) {
	Date.now = function now() {
		return new Date().getTime();
	};
}
//Polyfill for trim() (IE8 and below)
if (typeof String.prototype.trim !== 'function') {
	String.prototype.trim = function () {
		return this.replace(/^\s+|\s+$/g, '');
	};
}

// Linkify the contents of a node, within its parent.
function linkify(parent, insertBefore, text) {
	var start = 0;
	var match;
	var regex = /(?:(?:https?:\/\/)|(?:www\.))(?:[^ ]*?\.[^ ]*?)+[-A-Za-z0-9+&@#\/%?=~_|$!:,.;()]+/ig;
	while ((match = regex.exec(text)) !== null) {
		// add the unmatched text
		parent.insertBefore(document.createTextNode(text.substring(start, match.index)), insertBefore);

		var href = match[0];
		if (!/^https?:\/\//i.test(match[0])) {
			href = "http://" + match[0];
		}

		// add the link
		var link = document.createElement("a");
		link.href = href;
		link.textContent = match[0];
		parent.insertBefore(link, insertBefore);

		start = regex.lastIndex;
	}
	if (start !== 0) {
		// add the remaining text and remove the original text node
		parent.insertBefore(document.createTextNode(text.substring(start)), insertBefore);
		parent.removeChild(insertBefore);
	}
}

// Recursively linkify the children of a given node.
function linkify_node(node) {
	if (typeof Node === 'undefined') {
		node.innerHTML = linkify_fallback(node.innerHTML);
		return;
	}

	var children = node.childNodes;
	// work backwards to avoid the risk of looping forever on our own output
	for (var i = children.length - 1; i >= 0; --i) {
		var child = children[i];
		if (child.nodeType == Node.TEXT_NODE) {
			// text is to be linkified
			linkify(node, child, child.textContent);
		} else if (child.nodeName != "A" && child.nodeName != "a") {
			// do not linkify existing links
			linkify_node(child);
		}
	}
}

//fallback for old IE
function linkify_fallback(text) {
	var rex = /((?:<a|<iframe|<img)(?:.*?(?:src="|href=").*?))?(?:(?:https?:\/\/)|(?:www\.))+(?:[^ ]*?\.[^ ]*?)+[-A-Za-z0-9+&@#\/%?=~_|$!:,.;]+/ig;
	return text.replace(rex, function ($0, $1) {
		if(/^https?:\/\/.+/i.test($0)) {
			return $1 ? $0: '<a href="'+$0+'">'+$0+'</a>';
		}
		else {
			return $1 ? $0: '<a href="http://'+$0+'">'+$0+'</a>';
		}
	});
}

//:peka:
function emojify(node) {
	var rex = /:[\w\d\-_]+:/g;
	node.innerHTML = node.innerHTML.replace(rex, function ($0) {
		return '<i class="em em-'+$0.substring(1, $0.length-1)+'">'+$0+'</i>';
	});
}

// Colorizes the highlight spans
function setHighlightColor(match) {
	match.style.background = opts.highlightColor;
}

//Highlights words based on user settings
function highlightTerms(el) {
	var element = $(el);
	if(!(element.mark)) { // mark.js isn't loaded; give up
		return;
	}
	for (var i = 0; i < opts.highlightTerms.length; i++) { //Each highlight term
		if(opts.highlightTerms[i]) {
			element.mark(opts.highlightTerms[i], {"element" : "span", "each" : setHighlightColor});
		}
	}
}

function iconError(E) {
	var that = this;
	setTimeout(function() {
		var attempts = $(that).data('reload_attempts');
		if (typeof attempts === 'undefined' || !attempts) {
			attempts = 1;
		}
		if (attempts > opts.imageRetryLimit)
			return;
		var src = that.src;
		that.src = null;
		that.src = src+'#'+attempts;
		$(that).data('reload_attempts', ++attempts);
	}, opts.imageRetryDelay);
}

//Send a message to the client
function output(message, flag) {
	if (typeof message === 'undefined') {
		return;
	}

	if (typeof flag === 'undefined') {
		flag = '';
	}

	if (flag !== 'internal') {
		opts.lastPang = Date.now();
	}

	var atBottom = false;

	var bodyHeight = $('body').height();
	var messagesHeight = $messages.outerHeight();
	var scrollPos = $('body,html').scrollTop();
	var compensateScroll = 0;

	// Create the element - if combining is off, we use it, and if it's on, we
	// might discard it bug need to check its text content. Some messages vary
	// only in HTML markup, have the same text content, and should combine.
	var entry = document.createElement('div');
	entry.innerHTML = message;
	var trimmed_message = entry.textContent || entry.innerText || "";

	var handled = false;
	if (opts.messageCombining) {
		var lastmessages = $messages.children('div.entry:last-child').last();
		if (lastmessages.length && $last_message && $last_message == trimmed_message) {
			var badge = lastmessages.children('.r').last();
			if (badge.length) {
				badge = badge.detach();
				badge.text(parseInt(badge.text()) + 1);
			} else {
				badge = $('<span/>', {'class': 'r', 'text': 2});
			}
			lastmessages.html(message);
			lastmessages.append(badge);
			badge.animate({
				"font-size": "0.9em"
			}, 100, function() {
				badge.animate({
					"font-size": "0.7em"
				}, 100);
			});
			handled = true;
		}
	}

	if (!handled) {
		//Actually append the message
		entry.className = 'entry';

		$last_message = trimmed_message;
		$messages[0].appendChild(entry);

		opts.messageCount++;

		$(entry).find("img.icon").error(iconError);

		var to_linkify = $(entry).find(".linkify");

		for(var i = 0; i < to_linkify.length; ++i) {
			linkify_node(to_linkify[i]);
		}

		var to_emojify = $(entry).find(".emojify");

		for(var i = 0; i < to_emojify.length; ++i) {
			emojify(to_emojify[i]);
		}

		//Actually do the snap
		//Stuff we can do after the message shows can go here, in the interests of responsiveness
		if (opts.highlightTerms && opts.highlightTerms.length > 0) {
			highlightTerms(entry);
		}
	}

	//Should we snap the output to the bottom?
	if (bodyHeight + scrollPos >= messagesHeight - opts.scrollSnapTolerance) {
		atBottom = true;
		if ($('#newMessages').length) {
			$('#newMessages').remove();
		}
	//If not, put the new messages box in
	} else {
		if ($('#newMessages').length) {
			var messages = $('#newMessages .number').text();
			messages = parseInt(messages);
			messages++;
			$('#newMessages .number').text(messages);
			if (messages == 2) {
				$('#newMessages .messageWord').append('s');
			}
		} else {
			$messages.after('<a href="#" id="newMessages"><span class="number">1</span> new <span class="messageWord">message</span> <i class="icon-double-angle-down"></i></a>');
		}
	}

	//Pop the top message off if history limit reached
	if (opts.messageCount >= opts.messageLimit) {
		var $firstMsg = $messages.children('div.entry:first-child');
		compensateScroll = $firstMsg.outerHeight();
		$firstMsg.remove();
		opts.messageCount--;
	}

	if (atBottom) {
		$('body,html').scrollTop($messages.outerHeight());
	} else if(compensateScroll) {
		$('body,html').scrollTop(scrollPos - compensateScroll);
	}
}

//Runs a route within byond, client or server side. Consider this "ehjax" for byond.
function runByond(uri) {
	window.location = uri;
}

function setCookie(cname, cvalue, exdays) {
	cvalue = escaper(cvalue);
	var d = new Date();
	d.setTime(d.getTime() + (exdays*24*60*60*1000));
	var expires = 'expires='+d.toUTCString();
	document.cookie = "tau-" + cname + '=' + cvalue + '; ' + expires + "; path=/";
}

function getCookie(cname) {
	var name = "tau-" + cname + '=';
	var ca = document.cookie.split(';');
	for(var i=0; i < ca.length; i++) {
	var c = ca[i];
	while (c.charAt(0)==' ') c = c.substring(1);
		if (c.indexOf(name) === 0) {
			return decoder(c.substring(name.length,c.length));
		}
	}
	return '';
}

function rgbToHex(R,G,B) {return toHex(R)+toHex(G)+toHex(B);}
function toHex(n) {
	n = parseInt(n,10);
	if (isNaN(n)) return "00";
	n = Math.max(0,Math.min(n,255));
	return "0123456789ABCDEF".charAt((n-n%16)/16) + "0123456789ABCDEF".charAt(n%16);
}

function handleClientData(ckey, ip, compid) {
	//byond sends player info to here
	var currentData = {'ckey': ckey, 'ip': ip, 'compid': compid};
	if (opts.clientData && !$.isEmptyObject(opts.clientData)) {
		runByond('?_src_=chat&proc=analyzeClientData&param[charset]='+document.defaultCharset+'&param[cookie]='+JSON.stringify({'connData': opts.clientData}));

		for (var i = 0; i < opts.clientData.length; i++) {
			var saved = opts.clientData[i];
			if (currentData.ckey == saved.ckey && currentData.ip == saved.ip && currentData.compid == saved.compid) {
				return; //Record already exists
			}
		}

		if (opts.clientData.length >= opts.clientDataLimit) {
			opts.clientData.shift();
		}
	} else {
		runByond('?_src_=chat&proc=analyzeClientData&param[charset]='+document.defaultCharset+'&param[cookie]=none');
	}

	//Update the cookie with current details
	opts.clientData.push(currentData);
	setCookie('connData', JSON.stringify(opts.clientData), 365);
}

//Server calls this on ehjax response
//Or, y'know, whenever really
function ehjaxCallback(data) {
	opts.lastPang = Date.now();
	if (data == 'softPang') {
		return;
	} else if (data == "pang") {
		opts.pingCounter = 0;
		opts.pingTime = Date.now();
		runByond('?_src_=chat&proc=ping');
	} else if (data == 'pong') {
		if (opts.pingDisabled) {return;}
		opts.pongTime = Date.now();
		var pingDuration = Math.ceil((opts.pongTime - opts.pingTime) / 2);
		$('#pingMs').text(pingDuration+'ms');
		pingDuration = Math.min(pingDuration, 255);
		var red = pingDuration;
		var green = 255 - pingDuration;
		var blue = 0;
		var hex = rgbToHex(red, green, blue);
		$('#pingDot').css('color', '#'+hex);
	} else if (data == 'roundrestart') {
		opts.restarting = true;
		output('<div class="connectionClosed internal restarting">The connection has been closed because the server is restarting. Please wait while you automatically reconnect.</div>', 'internal');
	} else {
		//Oh we're actually being sent data instead of an instruction
		var dataJ;
		try {
			dataJ = $.parseJSON(data);
		} catch (e) {
			//But...incorrect :sadtrombone:
			window.onerror('JSON: '+e+'. '+data, 'browserOutput.html', 327);
			return;
		}
		data = dataJ;

		if (data.clientData) {
			if (opts.restarting) {
				opts.restarting = false;
				$('.connectionClosed.restarting:not(.restored)').addClass('restored').text('The round restarted and you successfully reconnected!');
			}
			if (!data.clientData.ckey && !data.clientData.ip && !data.clientData.compid) {
				//TODO: Call shutdown perhaps
				return;
			} else {
				handleClientData(data.clientData.ckey, data.clientData.ip, data.clientData.compid);
			}
		} else if (data.firebug) {
			if (data.trigger) {
				output('<span class="internal boldnshit">Loading firebug console, triggered by '+data.trigger+'...</span>', 'internal');
			} else {
				output('<span class="internal boldnshit">Loading firebug console...</span>', 'internal');
			}

			var firebugEl = document.createElement('script');
			firebugEl.src = 'https://getfirebug.com/firebug-lite-debug.js';
			document.body.appendChild(firebugEl);

		} else if (data.emoji) {
			emojiList = data.emoji;
		}
	}
}

function createPopup(contents, width) {
	opts.popups++;
	$('body').append('<div class="popup" id="popup'+opts.popups+'" style="width: '+width+'px;">'+contents+' <a href="#" class="close"><i class="icon-remove"></i></a></div>');

	//Attach close popup event
	var $popup = $('#popup'+opts.popups);
	var height = $popup.outerHeight();
	$popup.css({'height': height+'px', 'margin': '-'+(height/2)+'px 0 0 -'+(width/2)+'px'});

	$popup.on('click', '.close', function(e) {
		e.preventDefault();
		$popup.remove();
	});
}

function toggleWasd(state) {
	opts.wasd = (state == 'on' ? true : false);
}

function subSlideUp() {
	$(this).removeClass('scroll');
	$(this).css('height', '');
}

function startSubLoop() {
	if (opts.selectedSubLoop) {
		clearInterval(opts.selectedSubLoop);
	}
	return setInterval(function() {
		if (!opts.suppressSubClose && $selectedSub.is(':visible')) {
			$selectedSub.slideUp('fast', subSlideUp);
			clearInterval(opts.selectedSubLoop);
		}
	}, 5000); //every 5 seconds
}

function handleToggleClick($sub, $toggle) {
	if ($selectedSub !== $sub && $selectedSub.is(':visible')) {
		$selectedSub.slideUp('fast', subSlideUp);
	}
	$selectedSub = $sub;
	if ($selectedSub.is(':visible')) {
		$selectedSub.slideUp('fast', subSlideUp);
		clearInterval(opts.selectedSubLoop);
	} else {
		$selectedSub.slideDown('fast', function() {
			var windowHeight = $(window).height();
			var toggleHeight = $toggle.outerHeight();
			var priorSubHeight = $selectedSub.outerHeight();
			var newSubHeight = windowHeight - toggleHeight;
			$(this).height(newSubHeight);
			if (priorSubHeight > (windowHeight - toggleHeight)) {
				$(this).addClass('scroll');
			}
		});
		opts.selectedSubLoop = startSubLoop();
	}
}

function copyToClipboard(text) {
	var $temp = $('<input>');
	$('body').append($temp);
	$temp.val(text).select();
	document.execCommand('copy');
	$temp.remove();
}

/*****************************************
*
* MAKE MACRO DICTIONARY
*
******************************************/

// Callback for winget.
function wingetMacros(macros) {
	var idRegex = /.*?\.(?!(?:CRTL|ALT|SHIFT)\+)(.*?)(?:\+REP)?\.command/; // Do NOT match macros which need crtl, alt or shift to be held down (saves a ton of headache because I don't give enough of a fuck).
	for (var key in macros) {
		match   = idRegex.exec(key);
		if (match === null)
			continue;
		macroID = match[1].toUpperCase();

		opts.macros[macroID] = macros[key];
	}
}

/*****************************************
*
* DOM READY
*
******************************************/

if (typeof $ === 'undefined') {
	var div = document.getElementById('loading').childNodes[1];
	div += '<br><br>ERROR: Jquery did not load.';
}

$(function() {
	$messages = $('#messages');
	$subOptions = $('#subOptions');
	$selectedSub = $subOptions;

	//Hey look it's a controller loop!
	setInterval(function() {
		if (opts.lastPang + opts.pangLimit < Date.now() && !opts.restarting) { //Every pingLimit
			if (!opts.noResponse) { //Only actually append a message if the previous ping didn't also fail (to prevent spam)
				opts.noResponse = true;
				opts.noResponseCount++;
				output('<div class="connectionClosed internal" data-count="'+opts.noResponseCount+'">You are either AFK, experiencing lag or the connection has closed.</div>', 'internal');
			}
		} else if (opts.noResponse) { //Previous ping attempt failed ohno
			$('.connectionClosed[data-count="'+opts.noResponseCount+'"]:not(.restored)').addClass('restored').text('Your connection has been restored (probably)!');
			opts.noResponse = false;
		}
	}, 2000); //2 seconds


	/*****************************************
	*
	* LOAD SAVED CONFIG
	*
	******************************************/
	var savedConfig = {
		'sfontSize': getCookie('fontsize'),
		'slineHeight': getCookie('lineheight'),
		'spingDisabled': getCookie('pingdisabled'),
		'shighlightTerms': getCookie('highlightterms'),
		'shighlightColor': getCookie('highlightcolor'),
		'smessagecombining': getCookie('messagecombining'),
	};

	if (savedConfig.sfontSize) {
		$messages.css('font-size', savedConfig.sfontSize);
		output('<span class="internal boldnshit">Loaded font size setting of: '+savedConfig.sfontSize+'</span>', 'internal');
	}
	if (savedConfig.slineHeight) {
		$("body").css('line-height', savedConfig.slineHeight);
		output('<span class="internal boldnshit">Loaded line height setting of: '+savedConfig.slineHeight+'</span>', 'internal');
	}
	if (savedConfig.spingDisabled) {
		if (savedConfig.spingDisabled == 'true') {
			opts.pingDisabled = true;
			$('#ping').hide();
		}
		output('<span class="internal boldnshit">Loaded ping display of: '+(opts.pingDisabled ? 'hidden' : 'visible')+'</span>', 'internal');
	}
	if (savedConfig.shighlightTerms) {
		var savedTerms = $.parseJSON(savedConfig.shighlightTerms);
		var actualTerms = '';
		for (var i = 0; i < savedTerms.length; i++) {
			if (savedTerms[i]) {
				actualTerms += savedTerms[i] + ', ';
			}
		}
		if (actualTerms) {
			actualTerms = actualTerms.substring(0, actualTerms.length - 2);
			output('<span class="internal boldnshit">Loaded highlight strings of: ' + actualTerms+'</span>', 'internal');
			opts.highlightTerms = savedTerms;
		}
	}
	if (savedConfig.shighlightColor) {
		opts.highlightColor = savedConfig.shighlightColor;
		output('<span class="internal boldnshit">Loaded highlight color of: '+savedConfig.shighlightColor+'</span>', 'internal');
	}

	if (savedConfig.smessagecombining) {
		if (savedConfig.smessagecombining == 'false') {
			opts.messageCombining = false;
		} else {
			opts.messageCombining = true;
		}
	}

	(function() {
		var dataCookie = getCookie('connData');
		if (dataCookie) {
			var dataJ;
			try {
				dataJ = $.parseJSON(dataCookie);
			} catch (e) {
				window.onerror('JSON '+e+'. '+dataCookie, 'browserOutput.html', 434);
				return;
			}
			opts.clientData = dataJ;
		}
	})();


	/*****************************************
	*
	* BASE CHAT OUTPUT EVENTS
	*
	******************************************/

	$('body').on('click', 'a', function(e) {
		e.preventDefault();
	});

	$('body').on('mousedown', function(e) {
		var $target = $(e.target);

		if ($contextMenu && opts.hasOwnProperty('contextMenuTarget') && opts.contextMenuTarget) {
			hideContextMenu();
			return false;
		}

		if ($target.is('a') || $target.parent('a').length || $target.is('input') || $target.is('textarea')) {
			opts.preventFocus = true;
		} else {
			opts.preventFocus = false;
			opts.mouseDownX = e.pageX;
			opts.mouseDownY = e.pageY;
		}
	});

	$messages.on('mousedown', function(e) {
		if ($selectedSub && $selectedSub.is(':visible')) {
			$selectedSub.slideUp('fast', subSlideUp);
			clearInterval(opts.selectedSubLoop);
		}
	});

	$('body').on('mouseup', function(e) {
		if (!opts.preventFocus &&
			(e.pageX >= opts.mouseDownX - opts.clickTolerance && e.pageX <= opts.mouseDownX + opts.clickTolerance) &&
			(e.pageY >= opts.mouseDownY - opts.clickTolerance && e.pageY <= opts.mouseDownY + opts.clickTolerance)
		) {
			opts.mouseDownX = null;
			opts.mouseDownY = null;
			runByond('byond://winset?mapwindow.map.focus=true');
		}
	});

	$messages.on('click', 'a', function(e) {
		var href = $(this).attr('href');
		$(this).addClass('visited');
		if (href[0] == '?' || (href.length >= 8 && href.substring(0,8) == 'byond://')) {
			runByond(href);
		} else {
			href = escaper(href);
			runByond('?action=openLink&link='+href);
		}
	});

	//Fuck everything about this event. Will look into alternatives.
	$('body').on('keydown', function(e) {
		if (e.target.nodeName == 'INPUT' || e.target.nodeName == 'TEXTAREA') {
			return;
		}

		if (e.ctrlKey || e.altKey || e.shiftKey) { //Band-aid "fix" for allowing ctrl+c copy paste etc. Needs a proper fix.
			return;
		}

		e.preventDefault();

		var k = e.which;
		var command; // Command to execute through winset.

		var c = "";
		switch (k) {
			case 8:
				c = 'BACK';
				break;
			case 9:
				c = 'TAB';
				break;
			case 13:
				c = 'ENTER';
				break;
			case 19:
				c = 'PAUSE';
				break;
			case 27:
				c = 'ESCAPE';
				break;
			case 33: // Page up
				c = 'NORTHEAST';
				break;
			case 34: // Page down
				c = 'SOUTHEAST';
				break;
			case 35: // End
				c = 'SOUTHWEST';
				break;
			case 36: // Home
				c = 'NORTHWEST';
				break;
			case 37:
				c = 'WEST';
				break;
			case 38:
				c = 'NORTH';
				break;
			case 39:
				c = 'EAST';
				break;
			case 40:
				c = 'SOUTH';
				break;
			case 45:
				c = 'INSERT';
				break;
			case 46:
				c = 'DELETE';
				break;
			case 93: // That weird thing to the right of alt gr.
				c = 'APPS';
				break;

			default:
				c = String.fromCharCode(k);
		}

		if(opts.macros.hasOwnProperty(c.toUpperCase()))
			command = opts.macros[c];

		if (command) {
			runByond('byond://winset?mapwindow.map.focus=true;command='+command);
			return false;
		}
		else if (c.length == 0) {
			if (!e.shiftKey) {
				c = c.toLowerCase();
			}
			runByond('byond://winset?mapwindow.map.focus=true;mainwindow.input.text='+c);
			return false;
		} else {
			runByond('byond://winset?mapwindow.map.focus=true');
			return false;
		}
	});

	//Mildly hacky fix for scroll issues on mob change (interface gets resized sometimes, messing up snap-scroll)
	$(window).on('resize', function(e) {
		if ($(this).height() !== opts.priorChatHeight) {
			$('body,html').scrollTop($messages.outerHeight());
			opts.priorChatHeight = $(this).height();
		}
	});


	/*****************************************
	*
	* OPTIONS INTERFACE EVENTS
	*
	******************************************/

	$('body').on('click', '#newMessages', function(e) {
		var messagesHeight = $messages.outerHeight();
		$('body,html').scrollTop(messagesHeight);
		$('#newMessages').remove();
        runByond("byond://winset?mapwindow.map.focus=true");
	});


	$('#toggleOptions').click(function(e) {
		handleToggleClick($subOptions, $(this));
	});

	$('#subOptions, #toggleOptions').mouseenter(function() {
		opts.suppressOptionsClose = true;
	});

	$('#subOptions, #toggleOptions').mouseleave(function() {
		opts.suppressOptionsClose = false;
	});

	$('#decreaseFont').click(function(e) {
		var fontSize = parseInt($messages.css('font-size'));
		fontSize = fontSize - 1 + 'px';
		$messages.css({'font-size': fontSize});
		setCookie('fontsize', fontSize, 365);
		output('<span class="internal boldnshit">Font size set to '+fontSize+'</span>', 'internal');
	});

	$('#increaseFont').click(function(e) {
		var fontSize = parseInt($messages.css('font-size'));
		fontSize = fontSize + 1 + 'px';
		$messages.css({'font-size': fontSize});
		setCookie('fontsize', fontSize, 365);
		output('<span class="internal boldnshit">Font size set to '+fontSize+'</span>', 'internal');
	});

	$('#decreaseLineHeight').click(function(e) {
		var lineheightvar = parseInt($("body").css('line-height'));
		lineheightvar = (lineheightvar - 1) + "px";
		$("body").css({'line-height': lineheightvar});
		setCookie('lineheight', lineheightvar, 365);
		output('<span class="internal boldnshit">Line height set to '+lineheightvar+'</span>', 'internal');
	});

	$('#increaseLineHeight').click(function(e) {
		var lineheightvar = parseInt($("body").css('line-height'));
		lineheightvar = (lineheightvar + 1) + "px";
		$("body").css({'line-height': lineheightvar});
		setCookie('lineheight', lineheightvar, 365);
		output('<span class="internal boldnshit">Line height set to '+lineheightvar+'</span>', 'internal');
	});

	$('#togglePing').click(function(e) {
		if (opts.pingDisabled) {
			$('#ping').slideDown('fast');
			opts.pingDisabled = false;
		} else {
			$('#ping').slideUp('fast');
			opts.pingDisabled = true;
		}
		setCookie('pingdisabled', (opts.pingDisabled ? 'true' : 'false'), 365);
	});

	$('#saveLog').click(function(e) {
		// Supported only under IE 10+.
		if (window.Blob) {
			$.ajax({
				type: 'GET',
				url: 'browserOutput.css',
				success: function(styleData) {
					var chatLogHtml = '<head><title>Chat Log</title><style>' + styleData + '</style></head><body>' + $messages.html() + '</body>';

					var currentData = new Date();
					var formattedDate = (currentData.getMonth() + 1) + '.' + currentData.getDate() + '.' + currentData.getFullYear();
					var formattedTime = currentData.getHours() + '-' + currentData.getMinutes();

					var blobObject = new Blob([chatLogHtml]);
					var fileName = 'TauCeti ChatLog (' + formattedDate + ' ' + formattedTime + ').html';

					window.navigator.msSaveBlob(blobObject, fileName);
				}
			});
		} else {
			output('<span class="big red">This function does not supported on your version of Internet Explorer (9 or less). Please, update to the latest version.</span>', 'internal');
		}
	});

	$('#highlightTerm').click(function(e) {
		if(!($().mark)) {
			output('<span class="internal boldnshit">Highlighting is disabled. You are probably using Internet Explorer 8 and need to update.</span>', 'internal');
			return;
		}
		if ($('.popup .highlightTerm').is(':visible')) {return;}
		var termInputs = '';
		for (var i = 0; i < opts.highlightLimit; i++) {
			termInputs += '<div><input type="text" name="highlightTermInput'+i+'" id="highlightTermInput'+i+'" class="highlightTermInput'+i+'" maxlength="255" value="'+(opts.highlightTerms[i] ? opts.highlightTerms[i] : '')+'" /></div>';
		}
		var popupContent = '<div class="head">String Highlighting</div>' +
			'<div class="highlightPopup" id="highlightPopup">' +
				'<div>Choose up to '+opts.highlightLimit+' strings that will highlight the line when they appear in chat.</div>' +
				'<form id="highlightTermForm">' +
					termInputs +
					'<div><input type="text" name="highlightColor" id="highlightColor" class="highlightColor" '+
						'style="background-color: '+(opts.highlightColor ? opts.highlightColor : '#FFFF00')+'" value="'+(opts.highlightColor ? opts.highlightColor : '#FFFF00')+'" maxlength="7" /></div>' +
					'<div><input type="submit" name="highlightTermSubmit" id="highlightTermSubmit" class="highlightTermSubmit" value="Save" /></div>' +
				'</form>' +
			'</div>';
		createPopup(popupContent, 250);
	});

	$('body').on('keyup', '#highlightColor', function() {
		var color = $('#highlightColor').val();
		color = color.trim();
		if (!color || color.charAt(0) != '#') return;
		$('#highlightColor').css('background-color', color);
	});

	$('body').on('submit', '#highlightTermForm', function(e) {
		e.preventDefault();

		var count = 0;
		while (count < opts.highlightLimit) {
			var term = $('#highlightTermInput'+count).val();
			if (term) {
				term = term.trim();
				if (term === '') {
					opts.highlightTerms[count] = null;
				} else {
					opts.highlightTerms[count] = term.toLowerCase();
				}
			} else {
				opts.highlightTerms[count] = null;
			}
			count++;
		}

		var color = $('#highlightColor').val();
		color = color.trim();
		if (color == '' || color.charAt(0) != '#') {
			opts.highlightColor = '#FFFF00';
		} else {
			opts.highlightColor = color;
		}
		var $popup = $('#highlightPopup').closest('.popup');
		$popup.remove();

		setCookie('highlightterms', JSON.stringify(opts.highlightTerms), 365);
		setCookie('highlightcolor', opts.highlightColor, 365);
	});

	$('#emojiPicker').click(function () {
		var header = '<div class="head">Emoji Picker</div>' +
			'<div class="emojiPicker">' +
				'<div id="picker-notify"><span><b>COPIED</b></span></div>' +
				'<p>Emoji will be copied to the clipboard.</p>';

		var main = '<div class="emojiList">';

		emojiList.forEach(function (emoji) {
			main += '<a href="#" data-emoji="' + emoji + '" title="' + emoji + '"><i class="em em-' + emoji + '"></i></a>';
		});

		var footer = '</div></div>';

		createPopup(header + main + footer, 400);

		$('.emojiPicker a').click(function () {
			copyToClipboard(':' + $(this).data('emoji') + ':');

			var $pickerNotify = $('#picker-notify');
			$pickerNotify.slideDown('fast', function() {
				setTimeout(function() {
					$pickerNotify.slideUp('fast');
				}, 500);
			});
		});
	});

	$('#clearMessages').click(function() {
		$messages.empty();
		opts.messageCount = 0;
	});

	$('#toggleCombine').click(function(e) {
		opts.messageCombining = !opts.messageCombining;
		setCookie('messagecombining', (opts.messageCombining ? 'true' : 'false'), 365);
	});

	$('img.icon').error(iconError);

	// Tell BYOND to give us a macro list.
	// I don't know why but for some retarded reason,
	// You need to activate hotkeymode before you can winget the macros in it.
	//todo
	runByond('byond://winset?id=mainwindow&macro=hotkeymode');
	runByond('byond://winset?id=mainwindow&macro=macro');

	runByond('byond://winget?callback=wingetMacros&id=hotkeymode.*&property=command');

	/*****************************************
	*
	* KICK EVERYTHING OFF
	*
	******************************************/

	runByond('?_src_=chat&proc=doneLoading');
	if ($('#loading').is(':visible')) {
		$('#loading').remove();
	}
	$('#userBar').show();
	opts.priorChatHeight = $(window).height();
});
