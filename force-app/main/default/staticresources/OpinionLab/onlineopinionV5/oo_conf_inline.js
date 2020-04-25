/*
OnlineOpinion v5.9.3
Released: 09/21/2015. Compiled 09/30/2015 12:09:31 PM -0500
Branch: 5.9.3 efe6bf2541deb563c2a9884b2a3034c881047acf
Components: Full
UMD: disabled
The following code is Copyright 1998-2015 Opinionlab, Inc. All rights reserved. Unauthorized use is prohibited. This product and other products of OpinionLab, Inc. are protected by U.S. Patent No. 6606581, 6421724, 6785717 B1 and other patents pending. http://www.opinionlab.com
*/

/*
Inline configuration
*********************
Object is now being instantiated against the OOo object (1 global class)
To call this object, place the below in the click event
onClick="OOo.oo_launch(event, 'oo_feedback')"
*/
(function (w, o) {
    'use strict';

    var OpinionLabInit = function () {

        o.oo_feedback = new o.Ocode({});

        o.oo_launch = function(e, feedback) {
            var evt = e || window.event;
            o[feedback].show(evt);
        };

    };

    o.addEventListener(w, 'load', OpinionLabInit, false);

})(window, OOo);