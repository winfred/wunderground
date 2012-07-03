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

	wrapper_instance.[feature]_and_[another feature]_for("location string",optional: "hash", values: "at the end")
	
##Optional Hash

This ugly little guy handles the nonconformists in Wunderground's API request structure and the pervasive request timeout option.
Luckily there are only three of these baddies, and only if you need them. (details below)

	optional_hash = {lang: "FR", geo_ip:"127.0.0.1", timeout: 20}
	
Note: If needing to use these options, please place them as the last parameter(s) to the method call.
	
Can you think of a better way to handle these? Pull requests welcome.

##Features

The method_missing magic happens here.

	w_api.forecast_for("WA","Spokane")
	w_api.forecast_and_conditions_for("1234.1234,-1234.1234") #a lat/long string
	w_api.webcams_and_conditions_and_alerts_for("33043") #a zipcode

##Locations

Any location string that Wunderground accepts will pass straight through this wrapper to their API, _except for a specific geo-ip._ (examples below)

	#there is some handy array joining, if needed
	w_api.forecast_for("WA/Spokane") #equivalent to the next example
	w_api.forecast_for("WA","Spokane") #equivalent to the previous example
	
	#zipcodes,lat/long, aiport codes, all of them just pass straight through this wrapper and into the request URL
	w_api.conditions_for("77898")
	
	#weather station code uniqueness - they use the 'pws:' prefix for weather station codes. So does this wrapper.
	w_api.conditions_for("pws:STATIONCODE")
	
	w_api.conditions_for("autoip") #passes straight through, but only gets the weather for your server's IP, so not very useful probably
	
For geocoding a specific ip address as the location, just provide an IP like this:
	
	w_api.alerts_for(geo_ip: "127.0.0.1")
	
This was the quickest workaround to the non-conformity of the auto_ip request format.
	
	
##Language Support

Because the Language modifier in Wunderground's request structure uses a colon, which doesn't jive with the method_missing design, adding a specific language to one request can be done like this:

	w_api.forecast_for("France","Paris", lang 'FR')

Also, you can set the default language in the constructor or with a setter.

	w_api = Wunderground.new("apikey",language: "FR")
	w_api.language = 'FR'
	w_api.forecast_for("France","Paris") #automatically includes /lang:FR/ in the request url, so results will be in French
	w_api.forecast_for("France","Paris",lang: 'DE') #this will override the French(FR) default with German(DE)
	
##History and Planner Helpers

While it is possible to call

	w_api.history20101231_for("77789")
	w_api.planner03150323_for("FL","Destin")

to get the history/planner data for this date/location. You may enjoy more flexibility when using history_for and planner_for:

	w_api.history_for("20101010","AL","Birmingham")
	w_api.history_for(1.year.ago,"33909")
	w_api.history_for(Date.now, "France/Paris",lang: "FR")
	w_api.history_for(Date.now, geo_ip:"123.4.5.6", lang: "FR")
	w_api.planner_for("03150323","AL","Gulf Shores")
	w_api.planner_for(Time.now,Time.now+7.days, geo_ip: "10.0.0.1")
	w_api.planner_for(Time.now,Time.now+7.days,"33030")

.history_for and .planner_for accepts a preformatted string or any Date/Time/DateTime-like object that responds to .strftime to auto-format the date.


## Request Timeout

wunderground_ruby defaults to a 30 second timeout. You can optionally set your own timeout (in seconds) in three ways like so:

	w_api = Wunderground.new("apikey",timeout: 60)
    w_api.timeout = 5
	w_api.history_for(1.year.ago, geo_ip: '127.0.0.1', timeout:60)


### Error Handling

By default you are expected to handle errors returned by the APIs manually. (see their documentation for more information about these errors)

If you set the `throws_exceptions` boolean attribute for a given instance then
wunderground_ruby will attempt to intercept the errors and raise an APIError exception if you feel like catching it.

##Contributing

Do eet.

##Thanks

* [Amro Mousa](https://github.com/amro) - design inspiration


##Copyrights

* Copyright (c) 2012 Winfred Nadeau. See LICENSE.txt for details.

Winfred Nadeau is not affiliated with [Wunderground.com](http://wunderground.com), so check them out for licensing/copyright/legal/TOS details regarding their API and their data.
