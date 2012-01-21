# Wunderground Ruby API wrapper

Wunderground Ruby is an API wrapper for interacting with the [Wunderground API](http://www.wunderground.com/weather/api/)


##Installation

    $ gem install wunderground_ruby

or in your Gemfile

	gem 'wunderground_ruby'

##Requirements

A Wunderground account and API key.
If a request is attempted without an APIkey, this wrapper will raise a MissingAPIKey exception

JSON only at the moment.

##Usage

You can create an instance of the API wrapper and pass it the API key:

    w_api = Wunderground.new("your apikey")

You can also set the environment variable "WUNDERGROUND_API_KEY" and wunderground_ruby will use it when you create an instance:

    w_api = Wunderground.new

This gem/wrapper uses some method_missing fun to make it easier to get feature and location data from Wunderground

Any number of [features](http://www.wunderground.com/weather/api/d/documentation.html#request) work by passing the features from the method straight into the request URL.

Check out below and test file for more examples.

Standard request breakdown:

	wrapper_object.get_[feature]_and_[another feature]_for(optional_hash,"and/or location string")
	
##Optional Hash

This ugly little guy handles the nonconformists in Wunderground's API request structure. Luckily there are only two of these baddies. (details below)

	optional_hash = {lang: "FR", geo_ip:"127.0.0.1"}
	
Can you think of a better way to handle these? Pull requests welcome.

##Features

The method_missing magic happens here.

	w_api.get_forecast_for("WA","Spokane")
	w_api.get_forecast_and_conditions_for("1234.1234,-1234.1234") #a lat/long string
	w_api.get_webcams_and_conditions_and_alerts_for("33043") #a zipcode

##Locations

Any location string that Wunderground accepts will pass straight through this wrapper to their API, _except for a specific geo-ip._ (examples below)

	#there is some handy array joining, if needed
	w_api.get_forecast_for("WA/Spokane") #equivalent to the next example
	w_api.get_forecast_for("WA","Spokane") #equivalent to the previous example
	
	#zipcodes,lat/long, aiport codes, all of them just pass straight through this wrapper and into the request URL
	w_api.get_conditions_for("77898")
	
	#weather station code uniqueness - they use the 'pws:' prefix for weather station codes. So does this wrapper.
	w_api.get_conditions_for("pws:STATIONCODE")
	
	w_api.get_conditions_for("autoip") #passes straight through, but only gets the weather for your server's IP, so not very useful probably
	
For geocoding a specific ip address as the location, just provide an IP like this:
	
	w_api.get_alerts_for({geo_ip: "127.0.0.1"})
	
This was the quickest workaround to the non-conformity of the auto_ip request format.
	
	
##Language Support

Because the Language modifier in Wunderground's request structure uses a colon, which doesn't jive with the method_missing design, adding a specific language to one request can be done like this:

	w_api.get_forecast_for({lang:"FR"},"France","Paris")

Also, you can set the default language in the constructor or with a setter.

	w_api = Wunderground.new("apikey",{language: "FR"})
	w_api.language = 'FR'
	w_api.get_forecast_for("France","Paris") #automatically includes /lang:FR/ in the request url, so results will be in French
	w_api.get_forecast_for({lang:"DE"},"France","Paris") #this will override the French(FR) default with German(DE)
	
##History Support

While it is possible to call

	w_api.get_history20101231_for("77789")

to get the history data for this date/location. You may enjoy more flexibility when using get_history_for:

	w_api.get_history_for("20101010","AL","Birmingham")
	w_api.get_history_for(1.year.ago,"33909")
	w_api.get_history_for(Date.now, {lang: "FR"}, "France/Paris")
	w_api.get_history_for(Date.now, {lang: "DE", geo_ip:"123.4.5.6"})

.get_history_for accepts a string or any Date/Time/DateTime-like object that responds to .strftime("%Y%m%d") to auto-format the date.


### Other Stuff

wunderground_ruby defaults to a 30 second timeout. You can optionally set your own timeout (in seconds) like so:

	w_api = Wunderground.new("apikey",{timeout: 60})
    w_api.timeout = 5


### Error Handling

By default you are expected to handle errors returned by the APIs manually. (see their documentation for more information about these errors)

If you set the `throws_exceptions` boolean attribute for a given instance then
wunderground_ruby will attempt to intercept the errors and raise an APIError exception if you feel like catching it.

##Contributing

Do eet.

##Thanks

* [Amro Mousa](https://github.com/amro) - design inspiration (*cough* stolen)


##Copyrights

* Copyright (c) 2012 Winfred Nadeau. See LICENSE.txt for details.

Winfred Nadeau is not affiliated with [Wunderground.com](http://wunderground.com), so check them out for licensing/copyright/legal/TOS details regarding their API and their data.
