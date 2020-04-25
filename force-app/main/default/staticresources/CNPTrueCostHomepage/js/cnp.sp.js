document.CNP = document.CNP || { nav: new nav_util(), sp: new init_sp(), config: {}, page: {}, faqAnchor: new faq_util() };

var carousel_Interval = '6000';
var CONTENT_MAX_LENGTH = '256';
var CONTENT_MEDIUM_LENGTH = '100';

function nav_item_list() {
    return {
        'event_page': 'in-your-community/events/event-detail?eventId=',
        'view_all_events_page': 'in-your-community/events',
        'view_all_youtube_video': 'http://www.youtube.com/channel/UCG8nTw-42fWVSOUPLciVXDQ',
        'view_all_howto_video': '#',
        'view_all_audiostream': '#',
        'news_room_page': 'corporate/about-us/news',

    };
};



function nav_util() {
    this.items = nav_item_list();
    this.get_page = function (key) { return this[key]; };
    this.get_safe_page = function (key) { var page = this.items[key]; return page ? page : '#'; };
    this.get_top_url = function () { return window.location.pathname.split('/')[1]; };
    this.get_site_search_url = function () { return "/" + window.location.pathname.split('/')[1] + "/en-us/Pages/search.aspx?k="; };
    this.get_url = function (key, id) { var val = this.items[key]; return val ? val + id : '#' };
    this.get_abs_url = function (key, id) { var val = this.items[key]; return val ? get_client_path() + val + id : '#' }; //abs - absolute url
    this.get_page_url = function () { return get_client_path() };
}

function get_client_path() {
    var url = window.location.href;
    if (url.indexOf('?') > -1)
        url = url.substr(0, url.indexOf('?'));
    else if (url.indexOf('#') > -1)
        url = url.substr(0, url.indexOf('#'));
    return (url.charAt(url.length - 1) == '/') ? url : url + '/';
}

function nav_metadata(config) {
    this.d = config;
    this.is_residential_page = function () { return this.d.is_residential; }
    this.is_corporate_page = function () { return this.d.is_corporate; }
    this.get_service_area = function () { return this.d.servicecnpArea; }
    this.get_audience_type = function () { return this.d.audience; }
    this.get_sub_area = function () { return this.d.subarea; }
    this.get_locale = function () { return this.d.locale; }
    this.is_business_page = function () { return !this.d.is_residential && !this.d.is_corporate; }
    this.is_signed_in = function () { return this.d.signed_in; }
    this.get_web_url = function () { return this.d.web_url; }
    this.is_hsp = function () { return this.d.is_hsp_web; }
    this.is_faqenable = function () { return this.d.is_faqenable; }
    this.is_shareble = function () { return this.d.is_shareble; }
    this.get_state_label = function () { return this.d.state_label; }
    this.get_resultsource_guid = function () { return this.d.resultsource; }
}

function init_sp() {
    this.get_term_string_array = GetTermStringArray;
    this.get_link_array = function (param) { return (param) ? param.split(',') : [] };
}

function init_managed_nav(navData) {
    document.CNP.metadata = new nav_metadata(navData);
}

function GetTermStringArray(input) {
    var results = new Array();
    var mmDataRegex = /#0[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\|(.*?)(GTSET|GP0|GPP|L0|$)/igm;
    var match = mmDataRegex.exec(input);
    while (match != null) {
        results.push(match[1].replace(/\n/g, "").replace(';', ''));
        match = mmDataRegex.exec(input);
    }
    return results;
}

function registerFaqSearch(ctx) {
    initFaq();
    document.CNP.faq.registerSearch(ctx);
}

function registerFaqFilter(ctx) {
    initFaq();
    document.CNP.faq.registerFilter(ctx);
}

function initFaq() {
    //if (document.cnp.faq) return;
    if (document.CNP.faq !== undefined) return;

    var faq = { can_search: false, filter: {}, query: {}, allTopics: [] };
    faq.registerSearch = function (context) {
        document.CNP.faq.query = { id: context.ClientControl.get_id(), ctx: context };
        document.CNP.faq.can_search = true;
    }
    faq.registerFilter = function (context) {
        document.CNP.faq.filter[context.ClientControl.get_id()] = context;
    }
    faq.search = function (str) {
        if (document.CNP.faq.can_search) {
            document.CNP.faq.query.ctx.ClientControl.search(str);
            console.log(str);
        } else {
            console.log('search not registered');
        }
    }

    faq.allTopics = [];
    document.CNP.faq = faq;
}

function getLinkArray(str) {
    if (str) {
        // parse the label for the link
        var linkParser = inputValue.split(',');
        var linkText = linkParser[linkParser.length - 1]; //display the link URL if no label was provided
    }
}

/* **********************************************
     Begin Carousel Support
********************************************** */
//Added for Carousel A & B

function CarouselSlider(target, noofitems) {
    var classActive = "";
    var pagingControl = "";
    for (var i = 0; i < noofitems; i++) {
        if (i == 0) {
            classActive = "class='active'";
        }
        else {
            classActive = "";
        }
        pagingControl += "<li data-target='" + target + "' data-slide-to='" + i + "' " + classActive + "></li>";
    }
    return pagingControl;
}

function NavigateToPage(objUrl) {
    if (objUrl != '')
        window.location = objUrl;
    else {
        alert('Item Url is not well formatted!');
    }
}

function FormNavUrl(objPageName, listItemId) {
    var locale = document.CNP.metadata.get_locale();
    var servArea = document.CNP.metadata.get_service_area();
    var audienceType = document.CNP.metadata.get_audience_type();
    var nav_page_url = '/' + locale + '/' + audienceType + '/' + document.CNP.nav.get_url(objPageName, listItemId);
    return nav_page_url;
}

function Html2Text(html) {
    //Converts HTML iiiiinto plain text, to trim the news content which best suite for recent news web part.
    var objDiv = document.createElement('div');
    objDiv.innerHTML = html;
    var text = objDiv.textContent || objDiv.innerText;
    return text;
}


/* **********************************************
     Begin FAQ Rating
********************************************** */
// Faq Rating Module
var faqrate,
FaqRating = {
    OnFail: function (results) {
        alert('Unable to rate the selected FAQ at the moment.');
    },
    getRating: function (webURL, siteID, faqID, myRatingSpanId) {
        if (webURL == null || siteID == null || faqID == null) {
            return;
        }
        $.support.cors = true;
        var requestURL = webURL + "/_Layouts/15/CNPCustomHandlers/FaqRating.ashx?Method=GetRating&SiteID=" + siteID + "&FaqID=" + faqID;
        //alert(requestURL);
        $.ajax({
            url: requestURL,
            contentType: "application/json; charset=utf-8",
            success: function (data) {
                if (data.Payload) {
                    var myRating = data.Payload.Rating;
                    var myRatingClassName = GetRatingClassName(myRating);
                    $("#" + myRatingSpanId).find("fieldset").addClass("disabled");
                    $("#" + myRatingSpanId).addClass(myRatingClassName);
                }
            },
            error: function (data) {
                console.log(data.responseJSON.StatusCode);
                console.log(data.responseJSON.StatusMessage);
            }
        });
    },
    updateRating: function (webURL, siteID, faqID, rating) {
        if (webURL == null || siteID == null || faqID == null || rating == null) {
            return;
        }
        $.support.cors = true;
        var requestURL = webURL + "/_Layouts/15/CNPCustomHandlers/FaqRating.ashx?Method=UpdateRating&SiteID=" + siteID + "&FaqID=" + faqID + "&Rating=" + rating;
        //alert(requestURL);
        $.ajax({
            url: requestURL,
            contentType: "application/json; charset=utf-8",
            success: function (data) {
                //var myRating = data.Payload.Rating;
                //$("#getRating").text("my rating: " + myRating);
            },
            error: function (data) {
                console.log(data.responseJSON.StatusCode);
                console.log(data.responseJSON.StatusMessage);
            }
        });
    }
};

function SeeAllTopics_OnClick(searchBoxId) {
    $('.faq-see-all').click(function () {
        $('.faq-search-results').hide();
        $(".all-topics").parent().parent().show();
        var emptyQuery = "";
        document.CNP.faq.search(emptyQuery);
        $("input[id*='" + searchBoxId + "'][type='search']").val(emptyQuery);
    });
}

function ResultTopic_OnClick(searchBoxId) {
    $('.faq-result-topic').click(function () {
        var item = $(this).attr('data-item');
        if (item !== undefined) {
            document.CNP.faq.search(item);
            $("input[id*='" + searchBoxId + "'][type='search']").val(item);
        }
    });
}

function Rating_OnClick(currControl, siteURL) {
    var ratingSiteID = "";
    var ratingFaqID = "";
    var ratingDataItem = "";
    var ratingValue = currControl.value;
    ratingDataItem = currControl.parentNode.attributes["data-item"].value;
    ratingSiteID = ratingDataItem.split("_").shift();
    ratingFaqID = ratingDataItem.split("_").pop();
    var currUrl = document.URL;
    var indexNextSlash = currUrl.indexOf("/", 8);
    var currSiteUrl = currUrl.substring(0, indexNextSlash);
    FaqRating.updateRating(currSiteUrl, ratingSiteID, ratingFaqID, ratingValue);
}

function ratingOnHoverIE8() {

    /* hover states in ie8 */
    var $ie8RatingLabel = $(".lte-ie8 .faq-results-items .rating > input ~ label");

    $ie8RatingLabel.each(function () {
        var $labelVal = $(this).attr("value");
        var $olderBrothers = $(this).nextUntil("div");
        var $parentRating = $(this).parents("span");

        if ($labelVal === "a" || $labelVal === "b") {
            $(this).hover(
                function () {
                    $(this).addClass("redStar");
                    $olderBrothers.addClass("redStar");
                }, function () {
                    $(this).removeClass("redStar");
                    $olderBrothers.removeClass("redStar");
                }
            );
        } else if ($labelVal === "c" || $labelVal === "d") {
            $(this).hover(
                function () {
                    $(this).addClass("orangeStar");
                    $olderBrothers.addClass("orangeStar");
                }, function () {
                    $(this).removeClass("orangeStar");
                    $olderBrothers.removeClass("orangeStar")
                }
            );
        } else {
            $(this).hover(
                function () {
                    $(this).addClass("greenStar");
                    $olderBrothers.addClass("greenStar");
                }, function () {
                    $(this).removeClass("greenStar");
                    $olderBrothers.removeClass("greenStar");
                }
            );
        }
    });
}

function GetRatingClassName(faqRating) {
    var ratingClassName = "";
    switch (Math.ceil(faqRating)) {
        case 1:
            ratingClassName = "one-star-rating";
            break;
        case 2:
            ratingClassName = "two-star-rating";
            break;
        case 3:
            ratingClassName = "three-star-rating";
            break;
        case 4:
            ratingClassName = "four-star-rating";
            break;
        case 5:
            ratingClassName = "five-star-rating";
            break;
        default:
            ratingClassName = "zero-star-rating";
            break;
    }
    return ratingClassName;
}

/* **********************************************
     End FAQ Rating
********************************************** */

function pad(retval) {
    if (retval < 10)
    { return ("0" + retval.toString()); }
    else
    { return retval.toString(); }
}

function FormatDate(hours, minutes) {
    var suffix = $resource("am_pm")[0];
    if (hours >= 12) {
        suffix = $resource("am_pm")[1];
        hours = hours - 12;
    }
    if (hours == 0) {
        hours = 12;
    }
    return pad(hours) + ":" + pad(minutes) + " " + suffix;
}

function SearchQuerySuggestion() {
    this.init = function (searchSelector) {
        this.settings = this.settings || {}
        this.settings.searchInputs = $(searchSelector)
        this.bindSearchInputs();
    },
    this.bindSearchInputs = function () {
        this.settings.searchInputs.each(function () {
            var eachSearchInput = $(this);
            eachSearchInput.data("old_value", eachSearchInput.val());

            // Bind Cut, Paste and KeyDown Event Listener to current search input box
            eachSearchInput.bind("paste cut keydown", function (e) {
                var that = this;
                setTimeout(function () {
                    // If search input box not empty
                    if ($(that).val()) {
                        $(that).data("old_value", $(that).val());

                        // Query Suggestion using AutoComplete
                        document.CNP.page.search.setSearchAutoComplete(eachSearchInput, that)
                    }
                }, 200);
            })
        });
    },
    this.getFields = function (results) {
        r = {};
        //for (var i = 0; i < results.length; i++) {
        //    if (results[i] != undefined && results[i].Key != undefined) {
        //        r[results[i].Key] = results[i].Value;
        //    }
        //}
        r["Title"] = results;
        r["Text"] = results;
        return r;
    },
    this.setSearchAutoComplete = function (eachSearchInput, that) {
        eachSearchInput.autocomplete({
            minLength: 1,
            source: function (request, response) {
                // Call Search REST API and get search result for query suggestion
                var currUrl = document.URL;
                var indexNextSlash = currUrl.indexOf("/", 8);
                var currSiteUrl = currUrl.substring(0, indexNextSlash);
                var resultsource = document.CNP.metadata.get_resultsource_guid();
                $.ajax({
                    url: currSiteUrl + "/_Layouts/15/CNPCustomHandlers/FaqRating.ashx?Method=SUGGESTQUERY&SearchQuery=" + $(that).val(),
                    method: "GET",
                    contentType: "application/json; charset=utf-8",

                    success: function (data) {
                        if (data.Payload) {
                            response($.map(data.Payload, function (item) {
                                return {
                                    fields: document.CNP.page.search.getFields(item)
                                }
                            }));
                        }
                    },
                    error: function (data) {
                        //Logging error and not displaying to the end user as an alert
                        if (window.console && window.console.log) {
                            window.console.log("Query Suggestion Error: Fail to call Search REST API");
                        }
                    }
                });
            },
            focus: function (event, ui) { // If Query Suggestion get focused
                eachSearchInput.val(ui.item.fields.Title);
                return false;
            },
            select: function (event, ui) { // If Query Suggestion get selected
                eachSearchInput.val(ui.item.fields.Title);
                return false;
            }
        })
        .data("ui-autocomplete")._renderItem = function (ul, item) { // render Query suggestion with <ul> and <li>
            return $("<li></li>")
                .data("ui-autocomplete-item", item)
                .append(item.fields.Title)
                .appendTo(ul);
        };
    }
}

function init_search_autocomplete(selector) {
    var suggestion = new SearchQuerySuggestion();
    suggestion.init(selector);
    document.CNP.page.search = suggestion;
}

// Override only if native toISOString is not defined
if (!Date.prototype.toISOString) {
    // Here we rely on JSON serialization for dates because it matches 
    // the ISO standard. However, we check if JSON serializer is present 
    // on a page and define our own .toJSON method only if necessary
    if (!Date.prototype.toJSON) {
        Date.prototype.toJSON = function (key) {
            function f(n) {
                // Format integers to have at least two digits.
                return n < 10 ? '0' + n : n;
            }

            return this.getUTCFullYear() + '-' +
                f(this.getUTCMonth() + 1) + '-' +
                f(this.getUTCDate()) + 'T' +
                f(this.getUTCHours()) + ':' +
                f(this.getUTCMinutes()) + ':' +
                f(this.getUTCSeconds()) + 'Z';
        };
    }

    Date.prototype.toISOString = Date.prototype.toJSON;
}



function GetServiceStripUrl(objLinkUrl) {


    if (document.CNP.metadata != undefined) {
        var locale = document.CNP.metadata.get_locale();
        var servArea = document.CNP.metadata.get_service_area();
        var audienceType = document.CNP.metadata.get_audience_type();
        if (audienceType == null) {
            audienceType = "residential";
        }
        var nav_page_url = '/' + locale + '/' + audienceType;
        var strLinkUrl = objLinkUrl.toString().toUpperCase();
        strLinkUrl = strLinkUrl.replace("EN-US/AUDIENCE_HOLDER", "/AUDIENCE_HOLDER");
        strLinkUrl = strLinkUrl.replace("EN-US/AUDIENCE_TYPE", "/AUDIENCE_TYPE");
        if (strLinkUrl.indexOf("AUDIENCE_TYPE") > -1 || strLinkUrl.indexOf("AUDIENCE_HOLDER") > -1) {
            nav_page_url += strLinkUrl.replace("/AUDIENCE_TYPE", "");
            nav_page_url = nav_page_url.toString().replace("/AUDIENCE_HOLDER", "");
        }
        else {
            nav_page_url = strLinkUrl;
        }
        return nav_page_url.toString().toLowerCase();
    }
    else {
        console.log("document.CNP.metadata is undefined as cookie is blank");
        return objLinkUrl;
    }
}


$(function () {
    $(document).on('click', 'a', function (e) {
        var link = $(this).attr("href").toLowerCase();
        if (link.indexOf("audience_holder") >= 0) {
            e.preventDefault();
            window.location.href = ReplaceAudienceHolder(link);
        }
    });
});

$(function () {
    $(document).on('click', '.anchor-override', function (e) {
        e.preventDefault();
        window.location.href = ReplaceAudienceHolder($(this).attr('href'));
    });
});

function ReplaceAudienceHolder(currenturl) {

    //simulate a centerpoint energy page request
    //use window.location to get url
    var currentUrl = window.location;
    //parse the current browser url
    var url = parseURL(currentUrl);
    //get the relative url from the anchor tag
    var relativeUrl = currenturl.replace(url.protocol + "://", "").replace(url.host, "");
    var servArea = document.CNP.metadata.get_service_area();
    var audienceType = document.CNP.metadata.get_audience_type();
    //check to see if the audience segment exists
    var selfId = "";
    var split = relativeUrl.split("/");
    //if corporate, do not include self id
    if (!(split[1] == "corporate")) {
        if (url.segments.length >= 2) {
            // if need to switch between business/residential
            if (!(split[1] == "business") && !(split[1] == "residential")) {
                selfId = "/" + audienceType;
            } else {
                selfId = "/" + servArea;

            }
        }
    }
    //get page language
    var language = "/" + url.segments[0];


    var newUrl = url.protocol + "://" + url.host + language + selfId + relativeUrl.replace("/audience_holder", "");
    if (servArea == "" && audienceType == "") {
        newUrl = url.protocol + "://" + url.host + language;
    }
    return newUrl;
}
// This function creates a new anchor element and uses location
// properties (inherent) to get the desired URL data. Some String
// operations are used (to normalize results across browsers).
function parseURL(url) {
    var a = document.createElement('a');
    a.href = url;
    return {
        source: url,
        protocol: a.protocol.replace(':', ''),
        host: a.hostname,
        port: a.port,
        query: a.search,
        params: (function () {
            var ret = {},
                seg = a.search.replace(/^\?/, '').split('&'),
                len = seg.length, i = 0, s;
            for (; i < len; i++) {
                if (!seg[i]) { continue; }
                s = seg[i].split('=');
                ret[s[0]] = s[1];
            }
            return ret;
        })(),
        file: (a.pathname.match(/\/([^\/?#]+)$/i) || [, ''])[1],
        hash: a.hash.replace('#', ''),
        path: a.pathname.replace(/^([^\/])/, '/$1'),
        relative: (a.href.match(/tps?:\/\/[^\/]+(.+)/) || [, ''])[1],
        segments: a.pathname.replace(/^\//, '').split('/')
    };
}

/* **********************************************
     Begin FAQ Utility
********************************************** */
function faq_util() {
    this.aOnClick = function (e) {
        e.preventDefault();
        var context = SP.ClientContext.get_current();
        var list = context.get_web().get_lists().getById(_spPageContextInfo.pageListId);
        var item = list.getItemById(_spPageContextInfo.pageItemId);
        var baseUrl = "/" + parseURL(window.location).segments[0] + "/pages/faq.aspx?k=";

        var FAQSuccess = function () {
            //On Success
            //default search to the document title
            //var searchTerms = encodeURI(document.title);
            var searchTerms = document.title;
            var keywords = item.get_item("CNPKeywords");
            for (var i = 0; i < keywords.get_count() ; i++) {
                //if page has keywords build the FAQ query
                var term = keywords.getItemAtIndex(i);
                var label = term.get_label();

                //In order to retrieve accurate results,
                //separate all terms by OR
                if (i == 0) {
                    searchTerms = '"' + label + '"';
                } else {
                    searchTerms += ' OR ' + '"' + label + '"';
                }
            }

            //Redirect to the FAQ page
            baseUrl += encodeURI(searchTerms);
            window.location = baseUrl;
        };

        var FAQError = function (sender, args) {
            //If there was an error, just use the document title
            //redirect to FAQ page
            window.location = baseUrl + encodeURI(document.title);
        };

        //Load the CNP Keywords column
        context.load(item, "CNPKeywords");
        context.executeQueryAsync(FAQSuccess, FAQError);
    }
}
var listItem;

$(document).ready(function () {
    if ($('li#faqs').length && $('li#share').length) {
        RenderFaqShare();
    }
    if (self === top) {
        var antiClickjack = document.getElementById("antiClickjack");
        antiClickjack.parentNode.removeChild(antiClickjack);
    } else {
        if (self.location.href.indexOf("?PreviewPage=True") != -1) {

            var antiClickjack = document.getElementById("antiClickjack");
            antiClickjack.parentNode.removeChild(antiClickjack);
        }
        else {
            top.location = self.location;
        }
    }
});

function RenderFaqShare() {

    var faqenable = document.CNP.metadata.is_faqenable();
    var shareable = document.CNP.metadata.is_shareble();
    if (faqenable == 'true') {
        $('li#faqs').show();
    }
    else {
        $('li#faqs').hide();
    }
    if (shareable == 'true') {
        $('li#share').show();
    }
    else {
        $('li#share').hide();
    }
}


//Bind FAQ anchors to FAQ.Search during the click event.
$(function () {
    $('li.faqs a').on('click', document.CNP.faqAnchor.aOnClick);
});
