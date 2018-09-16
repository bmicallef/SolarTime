#This class is designed to calculate the Sun Rise, Sun Set, and Sun Noon times for a given, DateTime (including time zone), based on a Latitude and longitude
#Author: Brad Micallef 2018-09-16
#The calculations are based on the publically availabl information posted here: http://www.esrl.noaa.gov/gmd/grad/solcalc/calcdetails.html
#Sample useage
#   st = SolarTimes.new( DateTime.new(2016,2,27,19,32,0,-5), 35.227085, -80.843124 )
#       st.get_highnoon     =>      2016-02-27T12:36:50-05:00
#       st.get_sunrise        =>      2016-02-27T06:51:06-05:00
#       st.get_sunset         =>      2016-02-27T18:11:14-05:00

require 'date'

class SolarTime
    #Initializer
    def initialize(datetime, latitude, longitude)
        @datetime = datetime
        @latitude = latitude
        @longitude = longitude

        calculate_times
    end

    #Internal Method
    def calculate_times
        @date = @datetime.to_date
        julian_date = ( @datetime.jd * 1.0)
        julian_century = ( julian_date - 2451545.0 ) / 36525.0
        geo_mean_long_sum_deg = ( 280.46646 + julian_century * ( 36000.76983 + julian_century * 0.0003032)).modulo(360)
        geo_mean_anom_sun_deg = 357.52911 + julian_century * ( 35999.05029 - 0.0001537 * julian_century )
        ecent_earth_orbit = 0.016708634 - julian_century * ( 0.000042037 + 0.0000001267 * julian_century )
        sun_eq_ctr = Math.sin( ( geo_mean_anom_sun_deg  * Math::PI / 180.0  )) * (1.914602 - julian_century * ( 0.004817 + 0.000014 * julian_century )) + Math.sin( (( 2.0 * geo_mean_anom_sun_deg )  * Math::PI / 180.0  )) * ( 0.019993 - 0.000101 * julian_century ) + Math.sin( ( 3 * geo_mean_anom_sun_deg ) * Math::PI / 180.0 ) * 0.000289
        sun_true_long_deg = geo_mean_long_sum_deg + sun_eq_ctr
        sun_app_long_deg = sun_true_long_deg - 0.00569 - 0.00478 * Math.sin( (( 125.04 - 1934.136 * julian_century ) * Math::PI / 180.0))
        mean_obliq_ecliptic_deg = 23 + ( 26 + (( 21.448 - julian_century * ( 46.815 + julian_century * ( 0.00059 - julian_century * 0.001813 )))) / 60 ) / 60
        obliq_corr_deg = mean_obliq_ecliptic_deg + 0.00256 * Math.cos((( 125.04 - 1934.136 * julian_century) * Math::PI / 180.0 ))
        sun_declin_deg = ( Math.asin( Math.sin( ( obliq_corr_deg ) * Math::PI / 180.0 ) * Math.sin( ( sun_app_long_deg ) * Math::PI / 180.0 ))) / Math::PI * 180.0
        var_y = Math.tan(((obliq_corr_deg / 2 ) * Math::PI / 180 )) * Math.tan(((obliq_corr_deg / 2 ) * Math::PI / 180.0))
        eq_of_time_minutes = 4.0 * (( var_y * Math.sin( 2 * ( geo_mean_long_sum_deg ) * Math::PI / 180.0) - 2.0 * ecent_earth_orbit * Math.sin( ( geo_mean_anom_sun_deg ) * Math::PI / 180.0) + 4.0 * ecent_earth_orbit * var_y * Math.sin( ( geo_mean_anom_sun_deg ) * Math::PI / 180.0) * Math.cos( 2 * ( geo_mean_long_sum_deg ) * Math::PI / 180.0) - 0.5 * var_y * var_y * Math.sin( 4.0 * ( geo_mean_long_sum_deg ) * Math::PI / 180.0) - 1.25 * ecent_earth_orbit * ecent_earth_orbit * Math.sin( 2.0 * ( geo_mean_anom_sun_deg ) * Math::PI / 180.0)) / Math::PI * 180.0 )
        ha_sunrise_deg = ( Math.acos( Math.cos( ( 90.833 ) * Math::PI / 180.0 ) / ( Math.cos( ( @latitude ) * Math::PI / 180.0 ) * Math.cos( ( sun_declin_deg ) * Math::PI / 180.0)) - Math.tan( ( @latitude ) * Math::PI / 180.0) * Math.tan( ( sun_declin_deg ) * Math::PI / 180.0))) /  Math::PI * 180.0

        @t_sn = Time.at(( 720 - 4 * @longitude - eq_of_time_minutes + (@datetime.to_time.gmt_offset / 3600.0) ) * 60 )
        @t_sr = @t_sn - (ha_sunrise_deg * 4.0 * 60 )
        @t_ss = @t_sn + (ha_sunrise_deg * 4.0 * 60 )
    end

    #Outputs
    def get_highnoon
        solar_noon = DateTime.new(@date.year, @date.month, @date.day, @t_sn.hour, @t_sn.min, @t_sn.sec, @t_sn.zone)
        return solar_noon
    end

    def get_sunrise
        solar_sunrise = DateTime.new(@date.year, @date.month, @date.day, @t_sr.hour, @t_sr.min, @t_sr.sec, @t_sr.zone)
        return solar_sunrise
    end

    def get_sunset
        solar_sunset = DateTime.new(@date.year, @date.month, @date.day, @t_ss.hour, @t_ss.min, @t_ss.sec, @t_ss.zone)
        return solar_sunset
    end
end
