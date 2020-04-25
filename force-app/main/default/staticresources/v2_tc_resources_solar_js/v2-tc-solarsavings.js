// v2-tc-solarsavings.js

function initMap() {
    var map = new google.maps.Map(document.getElementById('map'), {
        center: { lat: 32.880116, lng: -96.713989 },
        zoom: 13,
        disableDefaultUI: true,
        mapTypeId: 'hybrid'
    });
    var input = document.getElementById('formatted_address');
    var autocomplete = new google.maps.places.Autocomplete(input, { placeholder: undefined });

    // Bind the map's bounds (viewport) property to the autocomplete object,
    // so that the autocomplete requests use the current map bounds for the
    // bounds option in the request.
    autocomplete.bindTo('bounds', map);

    // Set the data fields to return when the user selects a place.
    autocomplete.setFields(
        ['address_components', 'formatted_address', 'geometry', 'icon', 'name']);

    var marker = new google.maps.Marker({
        map: map,
        anchorPoint: new google.maps.Point(0, -29)
    });

    autocomplete.addListener('place_changed', function() {
        marker.setVisible(false);
        var place = autocomplete.getPlace();
        if (!place.geometry) {
            // User entered the name of a Place that was not suggested and
            // pressed the Enter key, or the Place Details request failed.
            window.alert("No details available for input: '" + place.name + "'");
            return;
        }

        // If the place has a geometry, then present it on a map.
        if (place.geometry.viewport) {
            map.fitBounds(place.geometry.viewport);
            map.setZoom(18);
        } else {
            map.setCenter(place.geometry.location);
            map.setZoom(18);
        }
        marker.setPosition(place.geometry.location);
        marker.setVisible(true);

        var address_components = place.address_components;
        var components = {};
        jQuery.each(address_components, function(k, v1) { jQuery.each(v1.types, function(k2, v2) { components[v2] = v1.long_name }); });

        var latitude = place.geometry.location.lat();
        var longitude = place.geometry.location.lng();
        var state = components.administrative_area_level_1;
        var postalcode = components.postal_code;

        // Set session storage vars
        sessionStorage.setItem('formatted_address', JSON.stringify(place.formatted_address));
        sessionStorage.setItem('lat', JSON.stringify(latitude));
        sessionStorage.setItem('lng', JSON.stringify(longitude));

        // match baseURL with backend
        var axiosObject = axios.create({ baseURL: "http://localhost:3000" });
        axiosObject.get('/api/avgprice', {
                params: {
                    state: state
                }
            })
            .then(function(response) {
                var queryPriceResult = response.data.data/100.0;
                console.log(queryPriceResult);
                axiosObject.get('/api/solarkwh', {
                        params: {
                            lat: latitude,
                            lng: longitude
                        }
                    })
                    .then(function(response) {

                        var querySolarResult = response.data.data;
                        console.log(querySolarResult);

                        var installationSize = 5; // kw size of system
                        var yearlySunlightKwhMedian = Math.round(querySolarResult);
                        var avgPriceKwh = queryPriceResult;
                        var monthlySavings = parseFloat((yearlySunlightKwhMedian * avgPriceKwh) * installationSize / 12).toFixed(2); // average monthly savings 

                        $("#kwhmedian").text(yearlySunlightKwhMedian + " kWh of usable sunlight per year");
                        $("#savings").text("$" + monthlySavings + " average monthly savings");
                    })
                    .catch(function(error) {
                        console.log(error);
                    });

            })
            .catch(function(error) {
                console.log(error);
            });
    });
}