﻿/* **********************************************
     Hide Event Detail link
********************************************** */

$(function () {
    $("a[href*='/in-your-community/events/event-detail']").each(function () {
        var txt = $(this).text().trim();
        if (txt == "Event Detail") {
            $(this).hide();
        }
    });
});

$(document).ready(function () {
    if (window.location.href.slice(window.location.href.indexOf('?') + 1).split('&')[1] != null) {
        if (window.location.href.slice(window.location.href.indexOf('?') + 1).split('&')[1].split('=') != null && window.location.href.slice(window.location.href.indexOf('?') + 1).split('&')[1].split('=') != "") {
            $('#serviceArea').val(decodeURI(window.location.href.slice(window.location.href.indexOf('?') + 1).split('&')[1].split('=')[1]));
        }
        else {
            $('#serviceArea').val("All");
        }
    }

    var searchPage = window.location.href.toLowerCase().indexOf("search.aspx") > -1 ? true : false;
    if (searchPage) {
        document.getElementById("aspnetForm").style.display = "none";
        var audience = '';
        var servicearea = '';
        var topurl = window.location.pathname.split('/')[1];
        var searchtxt = window.location.search.split('?')[1];
        searchtxt = trim(searchtxt);
        if (document.CNP.metadata) {

            audience = document.CNP.metadata.get_audience_type();
            servicearea = document.CNP.metadata.get_service_area();
        }
        if (audience == '' || servicearea == '') {
            var searchUrl = '';
            
            searchUrl = "/" + topurl + "/Pages/searchall.aspx?" + searchtxt;
            if (topurl == 'es-us')
            {
                searchUrl = searchUrl.toLowerCase().replace('/pages/', '/paginas/');
            }
            window.location = searchUrl;
            return;
        }
        document.getElementById("aspnetForm").style.display = "block";
    }

});


/* **********************************************
     Begin Feedback
********************************************** */

function ShowFeedback() {
    $("#div-feedback").hide();
    oo_CNPfeedback.show();
}


/* **********************************************
     Begin Search Box
********************************************** */

function SubmitQuery() {
    var topurl = window.location.pathname.split('/')[1];
    var searchtxt = document.getElementById("global-search_csr_sbox").value;
    searchtxt = trim(searchtxt);
    var audience = '';
    var servicearea = '';
    var subarea = '';
    var searchUrl = '';
    if (document.CNP.metadata) {

         audience = document.CNP.metadata.get_audience_type();
         servicearea = document.CNP.metadata.get_service_area();
         subarea = document.CNP.metadata.get_sub_area();
    }
    if (searchtxt == '' || searchtxt == null || searchtxt == undefined) {
        return false;
    } else if(audience == null & servicearea==null)
    {
        searchUrl = "/" + topurl + "/Pages/searchall.aspx?k=" + searchtxt;        
    }
    else
    {
        searchUrl = "/" + topurl + "/Pages/search.aspx?k=" + searchtxt;        
    }    
    if (topurl == 'es-us') {
        searchUrl = searchUrl.toLowerCase().replace('/pages/', '/paginas/');
    }
    window.location = searchUrl;
    return;
}

function SubmitQueryDesktop() {
    var topurl = window.location.pathname.split('/')[1];
    
    var searchtxt = document.getElementById("global-search-desktop_csr_sbox").value;
    searchtxt = trim(searchtxt);
    var audience = '';
    var servicearea = '';
    var searchUrl = '';  
    
    if (document.CNP.metadata) {
        audience = document.CNP.metadata.get_audience_type();
        servicearea = document.CNP.metadata.get_service_area();       
    }
    if (searchtxt == '' || searchtxt == null || searchtxt == undefined) {
        return false;
    }
    else if (audience == '' || audience == null || audience == undefined || servicearea == '' || servicearea == null || servicearea == undefined)
    {
        searchUrl = "/" + topurl + "/Pages/searchall.aspx?k=" + searchtxt + "&";
    }
    else {
        searchUrl = "/" + topurl + "/Pages/search.aspx?k=" + searchtxt + "&";
    }

    if (topurl == 'es-us')
    {
        searchUrl = searchUrl.toLowerCase().replace('/pages/', '/paginas/');
    }
    window.location = searchUrl;
    return;
}


function SubmitQueryFromSearchBox(strKeyword, strServiceArea) {
    var topurl = window.location.pathname.split('/')[1];
    var searchUrl = '';
    if (strServiceArea == '' || strServiceArea == null || strServiceArea == undefined) {
        searchUrl = "/" + topurl + "/Pages/search.aspx?k=" + strKeyword + "&";
    }
    else {
        searchUrl = "/" + topurl + "/Pages/searchall.aspx?k=" + strKeyword + "&ServiceArea=" + strServiceArea + "&";
    }
    if (topurl == 'es-us') {
        searchUrl = searchUrl.toLowerCase().replace('/pages/', '/paginas/');
    }
    window.location = searchUrl;
    return;
}

function SubmitQueryLink() {
    var topurl = window.location.pathname.split('/')[1];    
    searchAllPageURL = "/" + topurl + "/Pages/searchall.aspx?k=";
    if (topurl == 'es-us') {
        searchAllPageURL = searchAllPageURL.toLowerCase().replace('/pages/', '/paginas/');
    }
    return searchAllPageURL;
}

function triggerEnterKeyPress(e) {
    var topurl = window.location.pathname.split('/')[1];
    var searchtxt = document.getElementById("global-search-desktop_csr_sbox").value;
    searchtxt = trim(searchtxt);
    var searchUrl = '';
    if (e.keyCode === 13) {        
        searchUrl = "/en-us/Pages/search.aspx?k=" + searchtxt;
        if (topurl == 'es-us') {
            searchUrl = searchUrl.toLowerCase().replace('/pages/', '/paginas/');
        }
        window.location = searchUrl;
        return false;
    }
}
function SubmitQueryDesktopRoot() {
    var topurl = window.location.pathname.split('/')[1];
    var searchtxt = document.getElementById("global-search-desktop_csr_sbox").value;    
    searchtxt = trim(searchtxt);
    if (searchtxt == '' || searchtxt == null || searchtxt == undefined) {
        return false;
    } else {
        window.location = "/en-us" + topurl + "/Pages/search.aspx?k=" + searchtxt;
    }
    return;
}
function SubmitQueryDesktopRoot() {

    var searchtxt = document.getElementById("global-search-desktop_csr_sbox").value;
    searchtxt = trim(searchtxt);
    if (searchtxt == '' || searchtxt == null || searchtxt == undefined) {
        return false;
    } else {
        window.location = "/en-us/Pages/search.aspx?k=" + searchtxt;
    }
    return;
}
function trim(s) {
    if (typeof (s) === 'undefined') { return; }
    return s.replace(/^\s+|\s+$/g, "");
}

/* **********************************************
     Begin modal-change-service-area.js
********************************************** */

$(function () {

    //Hide and show the service areas list
    $('#modal-show-list').on("click", function (e) {
        if ($("#modal-change-service-list-business").is(":visible") || $("#modal-change-service-list-residential").is(":visible")) {
            $("#modal-change-service-list-business").hide();
            $("#modal-change-service-list-residential").hide();
        }
        else {
            var audience = $("#modal-audience-type").text();
            if (audience == '')
                audience = $("#user-audience-type").text();

            audience = audience.toString().toLowerCase();

            $("#modal-change-service-list-business").hide();
            $("#modal-change-service-list-residential").hide();

            if (audience == 'business')
                $("#modal-change-service-list-business").show();
            else
                $("#modal-change-service-list-residential").show();
        }
    });

    //Hide and show texas list
    $('#modal-show-texas-list').on("click", function (e) {
        if ($("#modal-change-service-area-texas-region-list").is(":visible"))
            $("#modal-change-service-area-texas-region-list").hide();
        else
            $("#modal-change-service-area-texas-region-list").show();
    });

    //Code to handle service areas list
    $("#modal-change-service-list-business li, #modal-change-service-list-residential li").on("click", function () {

        $('#modal-change-service-area-state').text($(this).text());

        if ($(this).text() === 'Texas') {
            $(".modal-footer").find("button").prop("disabled", true);
            $("#modal-change-service-area-texas-region").text("Select");
            $(".js-texas-region").show();
        }
        else {
            $(".js-texas-region").hide();
            var audience = $("#modal-audience-type").text();
            var servicearea = $(this).text();
            var subarea = "";

            if (audience == '')
                ChangeServiceArea(servicearea, subarea);
            else
                ChangeAudience(audience, servicearea, subarea);

            $(".modal-footer").find("button").prop("disabled", false);
        }

        $("#modal-change-service-list-business").hide();
        $("#modal-change-service-list-residential").hide();
    });

    //Code to handle texas service areas list
    $("#modal-change-service-area-texas-region-list li").on("click", function () {

        $('#modal-change-service-area-texas-region').text($(this).text());
        $(".modal-footer").find("button").prop("disabled", false);

        var audience = $("#modal-audience-type").text();
        var servicearea = $(this).text();
        var subarea = "";

        if (servicearea == "Houston Metro") {
            servicearea = "Texas";
            subarea = "Houston";
        }
        if (servicearea == "Not Houston Metro") {
            servicearea = "Texas";
            subarea = "";
        }

        if (audience == '')
            ChangeServiceArea(servicearea, subarea);
        else
            ChangeAudience(audience, servicearea, subarea);


        $("#modal-change-service-area-texas-region-list").hide();

    });

    //Initialise the modal
    $("#change-service-area-link-nav, #change-service-area-link-footer, #modal-change-service-area-cancel, .audience-link").on("click", function (e) {

        $(".js-texas-region").hide();
        $("#modal-audience-type").text('');
        $("#modal-change-service-list-business").hide();
        $("#modal-change-service-list-residential").hide();
        $("#modal-change-service-area-texas-region-list").hide();
        $('#modal-change-service-area-state').text("Select");
        $("#modal-change-service-area-texas-region").text("Select");
        $(".modal-footer").find("button").prop("disabled", true);

        if ($(this).hasClass("audience-link"))
            $("#modal-audience-type").text($(this).text());
    });

    //Set url on continue
    $("#modal-change-service-area-continue").on("click", function (e) {
        window.location.href = $("#modal-handler-link").text() + "&timestamp=" + new Date().getTime();
        return false;
    });

    function ChangeAudience(audience, servicearea, subarea) {
        servicearea = servicearea.replace(' ', '-');
        var handler = window.location.protocol + "//" + window.location.host;
        handler = handler + "/_layouts/15/CNPCustomHandlers/SelfID.ashx";
        handler = handler + "?Method=CHANGEAUDIENCE&Audience=" + audience;
        handler = handler + "&ServiceArea=" + servicearea;
        handler = handler + "&SubArea=" + subarea;

        $("#modal-handler-link").text(handler);
    }

    function ChangeServiceArea(servicearea, subarea) {
        servicearea = servicearea.replace(' ', '-');
        var handler = window.location.protocol + "//" + window.location.host;
        handler = handler + "/_layouts/15/CNPCustomHandlers/SelfID.ashx";
        handler = handler + "?Method=CHANGESERVICEAREA&ServiceArea=" + servicearea;
        handler = handler + "&SubArea=" + subarea;

        $("#modal-handler-link").text(handler);
    }

});



/* **********************************************
     Begin apps integration.js
********************************************** */

$(function () {

    var mobile = {

        Android: function () {
            return navigator.userAgent.match(/Android/i);
        },
        BlackBerry: function () {
            return navigator.userAgent.match(/BlackBerry/i);
        },
        iOS: function () {
            return navigator.userAgent.match(/iPhone|iPad|iPod/i);
        },
        Opera: function () {
            return navigator.userAgent.match(/Opera Mini/i);
        },
        Windows: function () {
            return navigator.userAgent.match(/IEMobile/i);
        },
        any: function () {
            return (isMobile.Android() || isMobile.BlackBerry() || isMobile.iOS() || isMobile.Opera() || isMobile.Windows());
        }

    };

    function SetQueryParamenters() {
        if (document.CNP.metadata) {

            var audience = document.CNP.metadata.get_audience_type();
            var servicearea = document.CNP.metadata.get_service_area();
            var subarea = document.CNP.metadata.get_sub_area();
            var language = document.CNP.metadata.get_locale();
            var statecode = document.CNP.metadata.get_state_label();
            var appkey = $.now();

            $("iframe").each(function () {
                var src = $(this).attr('src');

                if (decodeURIComponent(src).toLowerCase().indexOf("app") >= 0) {
                    src = SetParam(src, "CNPAudience", audience);
                    src = SetParam(src, "CNPServiceArea", servicearea);
                    src = SetParam(src, "CNPSubArea", subarea);
                    src = SetParam(src, "CNPLanguage", language);
                    src = SetParam(src, "CNPStateCode", statecode);
                    src = SetParam(src, "CNPAppKey", appkey);

                    $(this).attr('src', src);
                }
            });
        }

    }

    function SetParam(src, key, value) {
        var temp1 = "%7B" + key + "%7D";
        src = src.replace(temp1, value);

        var temp2 = "{" + key + "}";
        src = src.replace(temp2, value);
        return src;
    }

    function SetAppWidth() {

        $("iframe").each(function () {
            var src = $(this).attr('src');

            if (decodeURIComponent(src).toLowerCase().indexOf("app") >= 0) {
                
                $webpart = $(this).parent().parent().parent();
                var myNav = navigator.userAgent.toLowerCase();
                var isIE = (myNav.indexOf('msie') != -1) ? parseInt(myNav.split('msie')[1]) : false;
                var ieMobile = myNav.indexOf('iemobile');

                if (!isIE) {
                    $webpart.width('100%');
                } else {
                    if (ieMobile == -1)
                        $webpart.width('770px');
                    else
                        $webpart.width('100%');
                }
                
                $webpart.height('100%');
            }
        });
    }

    function SetAppHeight(newheight) {

        newheight = newheight + ' !important';

        var newWidth = mobile.iOS() ? '72%' : '100%';
        newWidth = newWidth + ' !important';

        $("iframe").each(function () {
            var src = $(this).attr('src');
            if (decodeURIComponent(src).toLowerCase().indexOf("app") >= 0) {

                $(this).parent().parent().attr('height', '100%');
                $(this).parent().parent().attr('width', '100%');
                $(this).parent().parent().attr('style', 'height: 100% !important; width: 100% !important; padding-bottom: 15px;');

                $(this).attr('height', newheight);
                $(this).css('height', newheight);
                $(this).attr('width', newWidth);
                $(this).css('width', newWidth);

                if ($(this).css('float') != 'left' && $(window).width() > 800) {
                    $(this).css('float', 'left');
                }
                $(this).css('position', 'relative');
            }
        });
    }
    
    function HostPageCall() {
        var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
        var eventer = window[eventMethod];
        var messageEvent = eventMethod == "attachEvent" ? "onmessage" : "message";

        eventer(messageEvent, function (e) {
            if (e.data == 'ScrollHost') {
                window.scrollTo(0, 0);
            }

            if (e.data == 'ReloadHost') {
                window.location.reload();
            }

            if (e.data.indexOf("FormName:") == 0) {
                document.WT.completed_form(e.data.split(':')[1]);
            }

            if (e.data.indexOf("OpenPage:") == 0) {
                window.location = e.data.split('Page:')[1];
            }

            if (e.data.indexOf("AdjustHeight:") == 0) {
                var newheight = e.data.split('AdjustHeight:')[1];
                SetAppHeight(newheight);
            }

        }, false);
    }

    HostPageCall();
    SetQueryParamenters();
    SetAppWidth();


});

/* **********************************************
     Footer links alignment fix
********************************************** */

$(function () {
    try {
        $container = $('.fat-footer').find('.sitemap');
        if ($container.children().length > 2) {
            $container.parent().append($container.children()[2]);
            $container.parent().append($container.children()[2]);
        }

        if ($('.lte-ie8').length!=1) {
            $bar = $('.fat-footer').find('.container .sosumi');
            if ($bar.length > 0) {
                $('.fat-footer').append($bar);
            }
        }
    } catch (e) {

    }
});