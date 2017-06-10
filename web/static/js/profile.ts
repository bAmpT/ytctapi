
import {Socket, Channel} from "phoenix"

console.log("Loading Module: Profile")

export var Profile = {
  socket: Socket,
  channel: Channel,
  
  constructor: function(theSocket) {
      console.log('Initing: Profile');

      if (theSocket == undefined) {
        this.socket = new Socket("/socket", {params: {guardian_token: document['jwt']}})
        this.socket.connect();
      } else { this.socket = theSocket; }
     
      this.socket.channels.forEach( (theChannel) => {
        if (theChannel.topic == "live-html") {
          this.channel = theChannel;
          return;
        }
      })

      this.joinChannel();
  },

  joinChannel: function() {
    // Now that you are connected, you can join channels with a topic:
    this.channel = this.socket.channel("live-html", {})
    this.channel.join()
      .receive("ok", resp => { console.log("Live-Html: Joined successfully", resp) })
      .receive("error", resp => { console.log("Live-Html: Unable to join", resp) })

    this.channel.on("profile_words_result", payload => {
    	document.getElementsByTagName("MAIN")[0].innerHTML = document.getElementsByTagName("MAIN")[0].innerHTML + payload.profile_words_html
    })
  },

  onclick: function(username) {

      if (this.channel.isJoined() == false) {
        this.joinChannel();
        return
      }

      console.log("Live-Html: profile_words send for " + username)
      this.channel.push("profile_words", username)

  }
}


