document.addEventListener("turbolinks:load", function() {
    onYouTubeIframeAPIReady && onYouTubeIframeAPIReady();
})

// This code loads the IFrame Player API code asynchronously.
var loadYoutubeApi = function() {
    if (window.YT) { return; };
    var tag = document.createElement('script');
    tag.src = "https://www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
} 

window.onPlayerReady = function onPlayerReady() {}
window.onPlayerPlaybackQualityChange = function onPlayerPlaybackQualityChange() {}
window.onPlayerStateChange = function onPlayerStateChange() {}
window.onPlayerError = function onPlayerError() {}

var player;
window.onYouTubeIframeAPIReady = function onYouTubeIframeAPIReady() {
    if (!window.YT) {
        loadYoutubeApi();
        return;
    }
    player = new YT.Player('player', {
        videoId: ytid,
        width: 730,
        playerVars: { 'autoplay': 1, 'controls': 0 },
        events: {
            'onReady': onPlayerReady,
            'onPlaybackQualityChange': onPlayerPlaybackQualityChange,
            'onStateChange': onPlayerStateChange,
            'onError': onPlayerError
        }
    });
}

window.gotoTimestamp = function gotoTimestamp(timestamp) {
  player.seekTo(timestamp, true);
}

