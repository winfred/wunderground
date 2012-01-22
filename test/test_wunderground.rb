require 'helper'
require 'cgi'
require 'ruby-debug'
require 'addressable/uri'

class TestWunderground < Test::Unit::TestCase

  context "attributes" do

    setup do
      @api_key = "12345"
    end

    should "have no API by default" do
      @wunderground = Wunderground.new
      assert_equal(nil, @wunderground.api_key)
    end

    should "set an API key in constructor" do
      @wunderground = Wunderground.new(@api_key)
      assert_equal(@api_key, @wunderground.api_key)
    end
    should 'set timeout in constructor' do
      @wunderground = Wunderground.new(@api_key,{timeout: 60})
      assert_equal(60,@wunderground.timeout)
    end
    should 'set language in constructor' do
      @wunderground = Wunderground.new(@apikey,{language:"FR"})
      assert_equal('FR',@wunderground.language)
    end

    should "set an API key from the 'WUNDERGROUND_API_KEY' ENV variable" do
      ENV['WUNDERGROUND_API_KEY'] = @api_key
      @wunderground = Wunderground.new
      assert_equal(@api_key, @wunderground.api_key)
      ENV.delete('WUNDERGROUND_API_KEY')
    end

    should "set an API key from the 'WUNDERGROUND_APIKEY' ENV variable" do
      ENV['WUNDERGROUND_APIKEY'] = @api_key
      @wunderground = Wunderground.new
      assert_equal(@api_key, @wunderground.api_key)
      ENV.delete('WUNDERGROUND_APIKEY')
    end

    should "set an API key via setter" do
      @wunderground = Wunderground.new
      @wunderground.api_key = @api_key
      assert_equal(@api_key, @wunderground.api_key)
    end

    should "set and get timeout" do
      @wunderground = Wunderground.new
      timeout = 30
      @wunderground.timeout = timeout
      assert_equal(timeout, @wunderground.timeout)
    end
  end

  context "api url" do
    setup do
      @wunderground = Wunderground.new
      @wunderground.api_key = '123'
      @url = "http://api.wunderground.com/api/"
    end
    should "raise exception at empty api key" do
      @wunderground.api_key=nil
      expect_get(@url,{timeout:30})
      assert_raise Wunderground::MissingAPIKey do
        @wunderground.get_forecast_for("CA","San Fransisco")
      end
    end

    should "contain api key" do
      expect_get(@url+"123/forecast/q/ME/Portland.json",{timeout:30})
      @wunderground.get_forecast_for("ME","Portland")
    end
    should 'contain multiple Wunderground methods from ruby method' do
      expect_get(@url+"123/forecast/conditions/q/.json",{timeout: 30})
      @wunderground.get_forecast_and_conditions_for()
    end
    should 'contain language modifier for method with {lang:"code"} hash' do
      expect_get(@url+"123/forecast/lang:FR/q/ME/Portland.json",{timeout: 30})
      @wunderground.get_forecast_for("ME","Portland", lang: 'FR')
    end
    context 'location parameter' do
      should 'formats query of type array' do
        expect_get(@url+"123/forecast/q/ME/Portland.json",{timeout: 30})
        @wunderground.get_forecast_for("ME","Portland")
      end
      should 'formats query of type string' do
        expect_get(@url+"123/forecast/q/1234.1234,-1234.1234.json",{timeout: 30})
        @wunderground.get_forecast_for("1234.1234,-1234.1234")
        expect_get(@url+"123/forecast/q/pws:WHAT.json",{timeout: 30})
        @wunderground.get_forecast_for("pws:WHAT")
      end
      should 'formats query of type geo_ip' do
        expect_get(@url+"123/forecast/q/autoip.json?geo_ip=127.0.0.1",{timeout: 30})
        @wunderground.get_forecast_for(geo_ip: "127.0.0.1")
      end
    end
    context 'language support' do
      setup {@wunderground.language = "FR"}
      should 'automatically set language for all location types' do
        expect_get(@url+"123/forecast/lang:FR/q/pws:KCATAHOE2.json",{timeout: 30})
        @wunderground.get_forecast_for("pws:KCATAHOE2")
      end
      should 'have optional language override on call' do
        expect_get(@url+"123/forecast/lang:DE/q/ME/Portland.json",{timeout: 30})
        @wunderground.get_forecast_for("ME","Portland", lang: 'DE')
      end
      should 'pass language through history helper' do
        expect_get(@url+"123/history_#{Time.now.strftime("%Y%m%d")}/lang:DE/q/ME/Portland.json",{timeout: 30})
        @wunderground.get_history_for(Time.now,"ME","Portland",lang: 'DE')
      end
      should 'pass language through planner helper' do
        expect_get(@url+"123/planner_#{Time.now.strftime("%m%d")}#{(Time.now + 700000).strftime('%m%d')}/lang:DE/q/ME/Portland.json",{timeout: 30})
        @wunderground.get_planner_for(Time.now,(Time.now+700000),"ME","Portland", lang: 'DE')
      end
      should 'pass language through planner helper with IP' do
        expect_get(@url+"123/planner_#{Time.now.strftime('%m%d')}#{(Time.now +  
              700000).strftime('%m%d')}/lang:DE/q/autoip.json?geo_ip=127.0.0.1",{timeout: 30})
        @wunderground.get_planner_for(Time.now,(Time.now+700000),lang: "DE",geo_ip: "127.0.0.1")
      end
    end
    context 'for get_history_for(date,location) helper' do
      should 'pass string dates straight to URL' do
        expect_get(@url+"123/history_20110121/q/ME/Portland.json",{timeout: 30})
        @wunderground.get_history_for("20110121","ME","Portland")
      end
      should 'accept Time objects' do
        expect_get(@url+"123/history_#{Time.now.strftime("%Y%m%d")}/q/ME/Portland.json",{timeout: 30})
        @wunderground.get_history_for(Time.now,"ME","Portland")
      end
      should 'accept Date objects' do
        expect_get(@url+"123/history_#{Time.now.strftime("%Y%m%d")}/q/ME/Portland.json",{timeout: 30})
        @wunderground.get_history_for(Time.now.to_date,"ME","Portland")
      end
      should 'accept Date object and pass optional hash object' do
        expect_get(@url+"123/history_#{Time.now.strftime("%Y%m%d")}/q/autoip.json?geo_ip=127.0.0.1",{timeout: 30})
        @wunderground.get_history_for(Time.now.to_datetime,geo_ip: '127.0.0.1')
      end
    end
    context 'for get_planner_for helper' do
      should 'pass string date ranges through' do
        expect_get(@url+"123/planner_03130323/q/ME/Portland.json",{timeout: 30})
        @wunderground.get_planner_for("03130323","ME","Portland")
      end
      should 'turn two date objects into a properly formatted string' do
        expect_get(@url+"123/planner_#{Time.now.strftime('%m%d')}#{(Time.now + 700000).strftime('%m%d')}/q/autoip.json?geo_ip=127.0.0.1",{timeout: 30})
        @wunderground.get_planner_for(Time.now,(Time.now + 700000),geo_ip: '127.0.0.1')
      end
    end
  end


  context "Wunderground instances" do
    setup do
      @key = "TESTKEY"
      @wunderground = Wunderground.new(@key)
      @url = "http://api.wunderground.com/api/TESTKEY/forecast/q/ME/Portland.json"
      @returns = Struct.new(:body).new(["array", "entries"].to_json)
    end

    
    should 'throw exception if non-standard get_function_for(location) method is called' do
      assert_raise NoMethodError do
        @wunderground.scramble
      end
    end

    should "throw exception if configured to and the API replies with a JSON hash containing a key called 'error'" do
      @wunderground.throws_exceptions = true
      Wunderground.stubs(:get).returns(Struct.new(:body).new({response:{'error' => 'bad things'}}.to_json))
      assert_raise Wunderground::APIError do
        @wunderground.get_forecast_for("CA","San_Fransisco")
      end
    end
  end


  private

    def expect_get(expected_url,expected_options)
      Wunderground.expects(:get).with{|url, opts|
        url == expected_url &&
        opts[:timeout] == expected_options[:timeout]
      }.returns(Struct.new(:body).new("") )
    end
end
