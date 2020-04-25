// JavaScript source code
function CNPAudio(audioId, controlId, title, mp3Url, swfPath) {
    $(function () {
        var player = $('#' + audioId),
            options = {
                ready: function () {
                    $(this).jPlayer("setMedia", {
                        title: title,
                        mp3: mp3Url
                    });
                },
                play: function () { // To avoid multiple jPlayers playing together.
                    $(this).jPlayer("pauseOthers");
                },
                swfPath: swfPath,
                supplied: "mp3",
                wmode: "window",
                globalVolume: true,
                smoothPlayBar: true,
                keyEnabled: true,
                cssSelectorAncestor: "#" + controlId,
                cssSelector: {
                    play: ".play",
                    stop: ".stop"
                },
                preload: "auto"
            };

        //Instance jPlayer
        player.jPlayer(options);

        //pointer to the jPlayer data object
        myPlayerData = player.data("jPlayer");

    });
}