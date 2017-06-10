import { Channel } from "phoenix";

document.addEventListener("turbolinks:load", function() {
    document.ytct = document.getElementById("ytid").getAttribute("data-ytid");
    onYouTubeIframeAPIReady && onYouTubeIframeAPIReady();
})

window.addEventListener("load", function(event) {
    var event = new Event("turbolinks:load");
    document.dispatchEvent(event);
}, false);

// This code loads the IFrame Player API code asynchronously.
var loadYoutubeApi = function() {
    if (window.YT) { return; };
    var tag = document.createElement('script');
    tag.src = "https://www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
} 

var timer

window.onPlayerReady = function onPlayerReady() {}
window.onPlayerPlaybackQualityChange = function onPlayerPlaybackQualityChange() {}
window.onPlayerStateChange = function onPlayerStateChange(event) {
    if (event.data == YT.PlayerState.PLAYING) {
         timer = setInterval(function() {
          if (player.getCurrentTime() >= player.getDuration()) {
             clearInterval(timer);
          };
          playingAt(player.getCurrentTime())
        }, 400);
    } else {
        clearInterval(timer);
    }
}
window.onPlayerError = function onPlayerError() {}

window.player = null
window.onYouTubeIframeAPIReady = function onYouTubeIframeAPIReady() {
    if (!window.YT) {
        loadYoutubeApi();
        return;
    }
    window.player = new YT.Player('player', {
        videoId: document.ytct,
        width: "100%",
        playerVars: { 'autoplay': 0, 'controls': 0 },
        events: {
            'onReady': onPlayerReady,
            'onPlaybackQualityChange': onPlayerPlaybackQualityChange,
            'onStateChange': onPlayerStateChange,
            'onError': onPlayerError
        }
    });
}

window.gotoTimestamp = function gotoTimestamp(timestamp) {
  window.player.seekTo(timestamp, true);
  currentTimestampIndex = currentTimestamp = 0
  for (var i = 0; i < timestamps.length; i++) { 
       timestamps[i].getElementsByTagName("a")[0].style.color = ""
       if (timestamps[i].getAttribute("data-timestamp") == timestamp) {
            timestamps[i].getElementsByTagName("a")[0].style.color = "hotpink"
       }
  }
}

window.scrollToLine = function scrollToLine(line) {
    var list = document.getElementsByClassName("list-player"),
        targetLi = document.getElementById(line); // id tag of the <li> element

    list.scrollTop = (targetLi.offsetTop - 50);
}

var timestamps = document.getElementById("list-lines").getElementsByTagName("li")
var currentTimestampIndex = 0
var currentTimestamp = parseFloat(timestamps[0].getAttribute("data-timestamp")) || 0

document.addEventListener("turbolinks:load", function() {
     timestamps = document.getElementById("list-lines").getElementsByTagName("li")
     currentTimestampIndex = 0
     currentTimestamp = parseFloat(timestamps[0].getAttribute("data-timestamp")) || 0
})

function playingAt(time) {
     // console.log(time, currentTimestampIndex, currentTimestamp)
     if (time >= currentTimestamp && currentTimestampIndex < timestamps.length-1) {
        timestamps[currentTimestampIndex].getElementsByTagName("a")[0].style.color = ""

        currentTimestampIndex = currentTimestampIndex + 1
        currentTimestamp = parseFloat(timestamps[currentTimestampIndex].getAttribute("data-timestamp"))

        tl.moveToIndex(currentTimestampIndex)

        timestamps[currentTimestampIndex].getElementsByTagName("a")[0].style.color = "hotpink"
     }
}


import {Socket, Presence} from "phoenix"

if (document.socket == undefined) {
    document.socket = new Socket("/socket", {params: {guardian_token: document.jwt}})
    document.socket.connect() 
}

function fade(element) {
    var op = 1;  // initial opacity
    var timer = setInterval(function () {
        if (op <= 0.1){
            clearInterval(timer);
            element.style.display = 'none';
        }
        element.style.opacity = op;
        element.style.filter = 'alpha(opacity=' + op * 100 + ")";
        op -= op * 0.1;
    }, 50);
}

export var Player = {
    presence_channel: Channel,
    like_channel: Channel,
    comment_channel: Channel,

    ytid: "",

    presences: {},

    join_like_channel: function () {
        this.like_channel = document.socket.channel("like:"+ytid, {})

        this.like_channel.join()
            .receive('ok', function(resp) { console.log('LIKE: Joined successfully', resp) })
            .receive('error', function(resp) { console.log('LIKE: Unable to join', resp) })

        this.like_channel.on("likes_count", payload => {
            console.log(payload.likes_count)
            document.getElementById("likes-count").innerText = payload.likes_count
        })
    },

    join_comment_channel: function () {
        this.comment_channel = document.socket.channel("comment:"+ytid, {})

        this.comment_channel.join()
            .receive('ok', function(resp) { console.log('COMMENT: Joined successfully', resp) })
            .receive('error', function(resp) { console.log('COMMENT: Unable to join', resp) })

        this.comment_channel.on("created_comment", payload => {
            console.log(payload)
            var p = document.createElement("p")
            p.innerText = payload.body
            p.className = "marquee"
            p.style.color = '#'+(Math.random()*0xFFFFFF<<0).toString(16);
            p.style.top = Math.floor((Math.random() * 300) + 1) + "px"
            // p.setAttribute("class", "marquee")
            document.getElementById("marquees").appendChild(p)
        })
    },

    join_presence_channel: function () {
        this.presence_channel = document.socket.channel("watch:"+ytid, {})

        this.presence_channel.join()
            .receive("ok", resp => { console.log("PRESENCE: Joined successfully", resp) })
            .receive("error", resp => { console.log("PRESENCE: Unable to join", resp) })

        this.presence_channel.on("presence_state", state => {
            this.presences = Presence.syncState(this.presences, state, this.onJoin, this.onLeave)
                let listBy = (id, {metas: [first, ...rest]}) => {
                first.count = rest.length + 1 // count of this user's presences
                first.id = id
                return first
              }
              let onlineUsers = Presence.list(state, listBy)

            document.getElementsByClassName("alert-info")[0].innerText = "Online Users: "+ onlineUsers.map(function(obj){return obj["id"];}).join(", ")
            setTimeout(function(){ document.getElementsByClassName("alert-info")[0].innerText = "" }, 3000);
            // console.log("Presence synced", this.presences)
          })

        this.presence_channel.on("presence_diff", diff => {
            this.presences = Presence.syncDiff(this.presences, diff, this.onJoin, this.onLeave)
            let listBy = (id, {metas: [first, ...rest]}) => {
                first.count = rest.length + 1 // count of this user's presences
                first.id = id
                return first
              }
            let onlineUsers = Presence.list(this.presences, listBy)
            document.getElementsByClassName("alert-info")[0].innerText = "Neue User: "+onlineUsers.map(function(obj){return obj["id"];}).join(", ")
            setTimeout(function(){ document.getElementsByClassName("alert-info")[0].innerText = "" }, 3000);
            // console.log("Presence diff synced", diff)
        })
    },

    init: function (theYtid) {
        console.log('Loading Module: Player')

        this.ytid = theYtid
        
        if (this.presence_channel.isClosed()) {
            this.presence_channel = document.socket.channel("watch:"+ytid, {})
        }
        if (this.like_channel.isClosed()) {
            this.like_channel = document.socket.channel("like:"+ytid, {})
        }
        if (this.comment_channel.isClosed()) {
            this.comment_channel = document.socket.channel("comment:"+ytid, {})
        }

        if (this.presence_channel.isJoined() == false) {
            this.join_presence_channel()
        }
        if (this.like_channel.isJoined() == false) {
            this.join_like_channel()
        }
        if (this.comment_channel.isJoined() == false) {
            this.join_comment_channel()
        }

    },

    onJoin: function (id, current, newPres) {
        // if(!current){
        //   console.log("user has entered for the first time", newPres)
        // } else {
        //   console.log("user additional presence", newPres)
        // }
    },

    onLeave: function (id, current, leftPres) {
        // if(current.metas.length === 0){
        //   console.log("user has left from all devices", leftPres)
        // } else {
        //   console.log("user left from a device", leftPres)
        // }
    }

}


