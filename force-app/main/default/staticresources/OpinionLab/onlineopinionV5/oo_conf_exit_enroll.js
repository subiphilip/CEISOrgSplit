/*
OnlineOpinion v5.9.3
Released: 09/21/2015. Compiled 09/30/2015 12:09:31 PM -0500
Branch: 5.9.3 efe6bf2541deb563c2a9884b2a3034c881047acf
Components: Full
UMD: disabled
The following code is Copyright 1998-2015 Opinionlab, Inc. All rights reserved. Unauthorized use is prohibited. This product and other products of OpinionLab, Inc. are protected by U.S. Patent No. 6606581, 6421724, 6785717 B1 and other patents pending. http://www.opinionlab.com
*/

/* global window, OOo */

/*

/* Exit Event configuration */
(function (w, o) {
    'use strict';

    var OpinionLabInit = function () {

        o.oo_exit = new o.Ocode({
            events: {
                onExit: 100,
                disableLinks: /^(https:\/\/centerpointenergy\.secure\.force\.com\/EnrollRemote|https:\/\/centerpointenergy\.secure\.force\.com\/PlanDetails|https:\/\/centerpointenergy\.secure\.force\.com\/ChangeZip|https:\/\/centerpointenergy\.secure\.force\.com\/shopplans|https:\/\/centerpointenergy\.secure\.force\.com\/Register)/i,
                disableFormElements: true
            },
            cookie: {
                name: 'oo_exit',
                type: 'domain',
                expiration: 2592000
            },
            referrerRewrite: {
                searchPattern: /:\/\/[^\/]*/,
                replacePattern: '://siteexit.mytruecost.com'
            },
        });

    };

    o.addEventListener(w, 'load', OpinionLabInit, false);

})(window, OOo);