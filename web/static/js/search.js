
import {Socket} from "phoenix"
console.log("Requering Search...")

if (document.socket == undefined) {
    document.socket = new Socket("/socket", {params: {guardian_token: document.jwt}})
    document.socket.connect() 
}

export var Search = {
  channel: document.socket.channel("live-html", {}),
  
  init: function(){
      console.log('Loading Module: Search')
      if (this.channel.isJoined() == false) {
        this.join()
      }
  },

  join: function () {
    // Now that you are connected, you can join channels with a topic:
    this.channel = document.socket.channel("live-html", {})
    this.channel.join()
      .receive("ok", resp => { console.log("Live-Html: Joined successfully", resp) })
      .receive("error", resp => { console.log("Live-Html: Unable to join", resp) })

    this.channel.on("search_results", payload => {
      document.getElementById("search-results").innerHTML = payload.search_html
    })
  },

  onkeypress: function (event) {
    if (event.keyCode == 13) { 

          if (this.channel == undefined) {
            console.log('Search.channel# undefined, reconnecting...')
            return
          }
          
          if (searchInput.value.length < 2) {
            return
          }

          this.channel.push("search", searchInput.value)

      } else {
         document.getElementById("search-results").innerHTML = ""
      }
  }
}

