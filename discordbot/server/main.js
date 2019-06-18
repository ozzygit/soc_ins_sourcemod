/**
	Discord bot by Circleus
	Updated by Ozzy and MERZBAU (most of code)
	version 1.1
	Update is to address issue with Rcon timing out due to the way SRCDS handles timeouts on RCON

GIT Repos:
Circleus: https://github.com/zWolfi/INS_sourcemod
Ozzy: https://github.com/ozzygit/Insurgency_Sourcemod

Discord:
Circleus [TEC] - Terror Error Community: https://discord.gg/G2SMMnU 
Ozzy: [SOC] - https://discord.gg/3BbGmZR

This discord bot enables you to send messages to your game from discord
The sourcemod plugin discordchat.sp is required and discord.sp is also recommended.

You'll need to install nodejs and npm to run. I (ozzy) also recommend you use forever so it remains running when terminal is closed (if linux)
This will need to run as long as the server is running. If this is shutdown, the bot will go offline

Look at the commented lines below and fill out your server IP, port, rcon_password, and your bot token.

Read through everything and edit it.
After all that, all you have to do is to run the main.js from the server folder and you will have to invite your bot to your discord server.
Bot will show up in your discord server and you will have to give the permission to the bot strictly. Otherwise the bot will send all the messages from all the text channel to in game chat.

FULL credit goes to Circleus for the development of the plugin and his support to Ozzy. Credit goes to MERZBAU with getting the RCON timeout issue fixed.
*/


//Discord
var Discord = require("discord.js");
var bot = new Discord.Client();

//Rcon
var Rcon = require("rcon");
var rconConnection = new Rcon('IP here', port, 'rcon_password here');
//Example: new Rcon('192.168.1.256', 27015, 'killyouall123');


console.log("[SERVER] Server started");

//Rcon
rconConnection.on('auth', function() {
	console.log("[RCON] Authed!");
}).on('response', function(str) {
	console.log("[RCON] Response: " + str);
}).on('end', function() {
	console.log("[RCON] Socket closed!");
});

//Establish rcon connection
rconConnection.connect();


//Discord bot events
//Bot connected to discord and its ready
bot.on('ready', () => {
	console.log('[INS-DISCORD] Successfully Loaded');
	bot.user.setActivity('Insurgency', { type: 'PLAYING' });
});

//Bot reconnecting
bot.on('reconnecting', () => {
	console.log('[INS-DISCORD] Reconnecting');
});

//When a user on discord send a message
bot.on("message", msg => {
	if(msg.author.bot) return;
	
	//Filter out channel so only the channel 'ins-ingame-chat' can send message to in game
	if(msg.channel.name != 'ins-ingame-chat') return;
	
	var nickname = msg.member.displayName;
	var username = msg.author.username;
	var message = msg.content;
	
	//Filter out ```
	if(message.indexOf("```") !== -1)
	{
		const send_message = 'An Error Occur```Unable to send that message```';
		msg.channel.send(send_message);
		return;
	}
	
	//msg.channel.send(msg.author.toString() + ' said ' + message);
	
	//After it passed all the check we send a rcon message to the in-game server
	//In-game server will print out to all chat using that cvar
	rconConnection.send('discordchat ' + username + ' : ' + message);
	
	console.log('[INS-DISCORD] ' + username + ' : ' + message)
});

//Discord bot token (Require you to create your own discord bot in https://discordapp.com/developers/applications/)
bot.login("Your bot token here");