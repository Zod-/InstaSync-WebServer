/*
    <InstaSync - Watch Videos with friends.>
    Copyright (C) 2015  InstaSync
*/
/*
 * Room: Central flow for all room related tasks
 * This is basically one large singleton class with smaller components that are
 * stored in seperate files purely for organizing the code. The components could technically all
 * be stored in this file but it's easier to seperate them so this file isn't huge (like the old core.js that was 2500 lines)
 */
room = new function(room_name){
	var self = this; //netbeans says this is unused, but it's not. It's not a global variable either
	/* Some default events (override these in room) */
	this.onConnecting = function(){
		self.addMessage({username:""},"Connecting..","text-danger");
	};
	this.onConnected = function(){
		self.addMessage({username:""},"Connected!","text-success");
	};
	this.onJoining = function(){

	};
	this.onJoined = function(){
		//self.addMessage({username:""},"Joined!","text-danger")
	};
	this.onReconnecting = function(){

	};
	this.onReconnect = function(){

	};
	this.reconnectFailed = function(){

	};
	this.onError = function(){

	};
	this.onDisconnect = function(){

	};
	this.autoscroll = true;
	this.mutedIps = new Array();
	this.MAXMESSAGES = 175;
	this.unreadMessages = 0;
	this.unreadTabMessages = 0;
	this.filterGreyname = false;
	this.autosync = true;
	var showYTcontrols = false;
	var messages = 0; //stores how many total messages are in the window (for cleaning up)
	this.player = null;
	this.user = {
		userinfo: null,
		isMod: false,
		isLeader: false
	};
	this.roomName = room_name;
	var socket = null; //make socket private
	this.setSocket = function(ws){
		if (socket == null){ //only allow socket to be set once
			socket = ws;
		}
	};

	this.playlist = null;
	this.userlist = null;

	/*
	 * Fires when document is ready. This code starts the room. When reaching
	 * this function, everything should be good to go (including socket)
	 */
	$(function(){
		var video = new player("media");
		var queue = null; //stores resynch limiter timeout
		function requestResynch(){
			console.log("Resynch requested..");
			if (queue === null && self.autosync){
				queue = setTimeout(function() //prevent to many resynchs
				{
					console.log("Resynch request sent.");
					socket.sendcmd("resynch", null);
					queue = null;
				}, 1000);
			}
		}
		video.on["userSeeked"] = function(time){
			if (self.user.isLeader){
				socket.sendcmd('seekto', {time: time});
			}
			else
				requestResynch();
		};
		video.on["userPlayed"] = function(){
			if (self.user.isLeader){
				socket.sendcmd('resume', null);
			}
			else{//resynch
				requestResynch();
			}
		};
		video.on["userPaused"] = function(){
			if (self.user.isLeader){
				socket.sendcmd('pause', null);
			}
		};
		video.on['resynchNeeded'] = function(){ //trigger this if a resynch is needed? perhaps after a buffer?
			requestResynch();
		};
		//bind events
		self.video = video;
		self.playlist = new playlist(self, socket);
		self.userlist = new userlist(self,socket);
		self.poll = new poll(self,socket);
		onReady(self, socket);
		socket.connect();
	});

	this.cleanUp = function(){ //reset all globals back to defaults & disconnect socket

	};
	var queue = null; //stores resynch limiter timeout
	function requestResynch(){
		console.log("Resynch requested..");
		if (queue === null && autosynch){
			queue = setTimeout(function() //prevent to many resynchs
			{
				console.log("Resynch request sent.");
				global.sendcmd("resynch", null);
				queue = null;
			}, 1000);
		}
	}
	this.userinfo = function(userinfo){
		if (userinfo.loggedin)
		{
			$('#join').hide();
			$('#cin').removeAttr('disabled');
			$('#cin').show();
			$('#cin').focus();
		}
		else
		{
			$('#join').show();
			$('#cin').hide();
			$('#cin').attr('disabled', 'true');
		}
		if (userinfo.permissions > 0)
		{
			$('.mod').show();
			self.user.isMod = true;
		}
		self.user.userinfo = userinfo;
	};
	this.addMessage = function(user, message, extraStyles) { //extraStyles = additional classes FOR THE MESSAGE STYLE
		var usernameClass = "";
		if ((self.filterGreyname === true && user.loggedin === false) || self.isMuted(user.ip))
			return;
		usernameClass += user.loggedin ? "registered " : "unregistered ";
		if (user.permissions > 0){
			usernameClass += "mod-message";
		}
		var messageBox = $('<div/>', {
			"class": "chat-message"
		});
		var usernameSpan; //we attach the modal popup code to this
		if (message.substring(0,4) == "/me "){ //emote text
			message = message['substring'](3);
			var usernameSpan = $("<span/>", {
				"class":"username emote "+usernameClass,
				"text":user.username+" "
			});
			messageBox.append(usernameSpan);
			messageBox.append($("<span/>",{
				"class":"emote",
				"text":message
			}));
		}
		else if(message.substring(0, 4) == '&gt;'){ //greentext
			usernameSpan = $("<span/>", {
				"class":"username "+usernameClass,
				"text":user.username+": "
			});
			messageBox.append(usernameSpan);
			messageBox.append($("<span/>",{
				"class":"message greentext",
				"html":message //convert to text when switching anti xss to client side
			}));
		}
		else if (message[0] == "#"){ //hashtext
			usernameSpan = $("<span/>", {
				"class":"username "+usernameClass,
				"text":user.username+": "
			});
			messageBox.append(usernameSpan);
			messageBox.append(($("<span/>",{
				"class":"message hashtext",
				"html":message //convert to text when switching anti xss to client side
			})));
		}
		else{ //regular message
			usernameSpan = $("<span/>", {
				"class":"username "+usernameClass,
				"text":user.username+": "
			});
			messageBox.append(usernameSpan);
			var msg = $("<span/>",{
				"class":"message "+extraStyles,
				"html":linkify(message)//switch this to text when switching to xss prevention client side
			});
			messageBox.append(msg);
		}
		messageBox.data("user", user);
		$("#chat_messages").append(messageBox);
		if (self.autoscroll === true) {
			var textarea = document.getElementById('chat_messages');
			textarea.scrollTop = textarea.scrollHeight;
		}
		if (!$('#cin').is(':focus')) {
			self.unreadMessages++;
			document.title = '('+self.unreadMessages +') InstaSync - '+ self.roomName + "'s room";
		}
		if (!$("#tabs_chat").hasClass("active")){
			self.unreadTabMessages++;
			$("#tabs_chat .unread-msg-count").text(self.unreadTabMessages);
		}
		messages++
		self.cleanChat();
	};
	this.cleanChat = function(){
		//(C) Faqqq, (C) BibbyTube
		//https://github.com/Bibbytube/Instasynch/blob/master/Chat%20Additions/Autoscroll%20Fix/autoscrollFix.js
		var max = self.MAXMESSAGES;
		//increasing the maximum messages by the factor 2 so messages won't get cleared
		//and won't pile up if the user goes afk with autoscroll off
		if(!self.autoscroll){
			max = max*2;
		}
		while(messages > max){
			$('#chat_messages > :first-child').remove(); //div messages
			messages--;
		}
	};
	this.playlistlock = function(value) {
		if (value == true) {
			//$('#toggleplaylistlock').css('background-image', 'url("/images/lock.png")');
		} else {
			//$('#toggleplaylistlock').css('background-image', 'url("/images/unlock.png")');
		}
	}
	function toggleAutosynch(){
		autosynch = !autosynch;
		if (autosynch)
		{
			global.sendcmd('resynch', null);
		}
	}
	this.playVideo = function(vidinfo, time, playing) {
		//return;
		var indexOfVid = self.playlist.indexOf(vidinfo);
		if (indexOfVid > -1)
		{
			var title = self.playlist.videos[indexOfVid].title;
			var addedby = self.playlist.videos[indexOfVid].addedby;
			$('#playlist .active').removeClass('active');
			$($('#playlist').children('li')[indexOfVid]).addClass('active');
			//Scroll to currently playing videos
			var container = $('#playlist');
			var scrollTo = $("#playlist .active");
			container.animate({
				scrollTop: scrollTo.offset().top - container.offset().top + container.scrollTop()
			});
			//$('#vidTitle').html(title + '<div class=\'via\'> via ' + addedby + '</div>');
		}
		self.video.play(vidinfo, time, playing);
	};
	this.resume = function() {
			self.video.resume();
	}
	this.pause = function() {
			self.video.pause();
	}
	this.seekTo = function(time){
			self.video.seekTo(time);
	}
	this.setSkips = function(skips, skipsNeeded) {
		$('#skip_counter').text(skips + '/' + skipsNeeded);
	};
	this.event = function(event, data){
		switch(event.toLowerCase()) {
			case "playlistlock":
				self.playlistlock(data);
				break;
			case "leader":
				break;
			case "poll-create":
				self.poll.create(data.poll);
				break;
			case "poll-end":
				self.poll.end();
				break;
			case "poll-addvote":
				self.poll.addVote(data.option);
				break;
			case "poll-removevote":
				self.poll.removeVote(data.option);
				break;
			default:

		}
	};
	this.mute = function(ip){
		self.mutedIps[ip] = ip;
		for (var i = 0; i < self.userlist.users.length; i++)
		{
			if (self.userlist.users[i].ip == ip)
			{
				$($("#user_list li")[i]).addClass("muted");
			}
		}
	};
	this.unmute = function(ip){
		self.mutedIps[ip] = undefined;
		for (var i = 0; i < self.userlist.users.length; i++)
		{
			if (self.userlist.users[i].ip == ip)
			{
				$($("#userlist li")[i]).removeClass("muted");
			}
		}
	};
	this.isMuted = function(ip){
		return (self.mutedIps[ip] != undefined);
	};
	this.detectIE = function(){
		var ie = (function(){
			var undef, v = 3, div = document.createElement('div'), all = div.getElementsByTagName('i');
			while (
				div.innerHTML = '<!--[if gt IE ' + (++v) + ']><i></i><![endif]-->',
				all[0]
			);
			return v > 4 ? v : undef;
		}());
		if (ie < 10)
		{
			self.addMessage({username: ""},"Internet Explorer versions 9 and and older are not supported. Please upgrade to I.E. 10 or later.","errortext");
		}
	};
}(ROOM_NAME);