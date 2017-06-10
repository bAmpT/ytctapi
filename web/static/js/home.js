
import {Channel} from "phoenix"

/* Lol
window.onload = function() {
//   if (document.socket == undefined) {
//       document.socket = new Socket("/socket", {params: {guardian_token: document.jwt}})
//       document.socket.connect();
//   }
// };
*/

export var Home = {
  channel: Channel,
  
  init: function() {
      console.log("Loading Module: Home")

      // Init channel
      this.channel = document.socket.channel("live-api", {})
      this.join()
      
  },

  join: function () {
    // Now that you are connected, you can join channels with a topic:
    this.channel.join()
      .receive("ok", resp => { console.log("Live-Html: Joined successfully", resp) })
      .receive("error", resp => { console.log("Live-Html: Unable to join", resp) })

    this.channel.on("home_query", payload => {
      console.log( payload.home_html)
      document.getElementById("video-list").innerHTML = payload.home_html
    })
  }
}

