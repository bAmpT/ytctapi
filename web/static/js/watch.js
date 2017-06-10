import {Channel} from "phoenix"

export var Watch = {
  apiChannel: Channel,
  ytid: String,

  // Make sure it's called after DOM loaded
  init: function (theYtid) {
      console.log("Loading Module: Watch")
      this.ytid = theYtid

      // Annotate Lines
      mandarinspot.annotate("#list-lines")

      // Init channel
      this.apiChannel = document.socket.channel("live-api", {})
      this.join()
  },

  join: function () {
    
    // Now that you are connected, you can join channels with a topic:
    this.apiChannel.join()
      .receive("ok", resp => { console.log("Live-Api: Joined successfully", resp) })
      .receive("error", resp => { console.log("Live-Api: Unable to join", resp) })

    this.apiChannel.on("addNewWord", payload => {
      console.log( payload )

      if (payload.status == "created") {
        document.getElementsByClassName("alert alert-danger")[0] = "New Word: Added!"
      } else {
        document.getElementsByClassName("alert alert-danger")[0] = "New Word: Error!"
      }
      
      
    })
  },

  addNewWord: function(word) {
    console.log(word)
    this.apiChannel.push("addNewWord", {simp: word})
  }
}


/*
 
 base.init_time_slider = function() {
      base.$controls['time_bar'].on('mousedown', function(e) {
        base.info.time_drag = true;
        base.update_time_slider(e.pageX);
      });
      $(document).on('mouseup', function(e) {
        if(base.info.time_drag) {
          base.info.time_drag = false;
          base.update_time_slider(e.pageX);
        }
      });
      $(document).on('mousemove', function(e) {
        if(base.info.time_drag) {
          base.update_time_slider(e.pageX);
        }
      });
    };

    base.update_time_slider = function(x) {

      if(base.info.duration == 0) {
        return;
      }

      var maxduration = base.info.duration;
      var position = x - base.$controls['time_bar'].offset().left;
      var percentage = 100 * position / base.$controls['time_bar'].width();

      if(percentage > 100) {
        percentage = 100;
      }
      if(percentage < 0) {
        percentage = 0;
      }
      base.$controls['time_bar_time'].css('width',percentage+'%');
      base.youtube.seekTo(maxduration * percentage / 100);

      base.options.on_seek(maxduration * percentage / 100);

    };

    base.init_volume_slider = function() {
      base.$controls['volume_bar'].on('mousedown', function(e) {
        base.info.volume_drag = true;
        base.$controls['volume_icon'].removeClass('yesp-icon-volume-off').addClass('yesp-icon-volume-up');
        base.update_volume(e.pageX);
      });
      $(document).on('mouseup', function(e) {
        if(base.info.volume_drag) {
          base.info.volume_drag = false;
          base.update_volume(e.pageX);
        }
      });
      $(document).on('mousemove', function(e) {
        if(base.info.volume_drag) {
          base.update_volume(e.pageX);
        }
      });
    };

    base.update_volume = function(x, vol) {

      var percentage;

      if(vol) {
        percentage = vol * 100;
      }
      else {
        var position = x - base.$controls['volume_bar'].offset().left;
        percentage = 100 * position / base.$controls['volume_bar'].width();
      }
      
      if(percentage > 100) {
        percentage = 100;
      }
      if(percentage < 0) {
        percentage = 0;
      }
      
      base.$controls['volume_amount'].css('width',percentage+'%');

      base.youtube.setVolume(percentage);

      if(percentage == 0) {
        base.youtube.mute();
      }else if(base.youtube.isMuted()) {
        base.youtube.unMute();
      }

      if(percentage == 0) {
        base.$controls['volume_icon'].addClass('yesp-icon-volume-off').removeClass('yesp-icon-volume-up');
      }else {
        base.$controls['volume_icon'].removeClass('yesp-icon-volume-off').addClass('yesp-icon-volume-up');
      }
      
      base.options.on_volume(percentage/100);
      
    };

 */

