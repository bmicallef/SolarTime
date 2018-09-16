require_relative 'solar_time'

st = SolarTime.new(DateTime.new(2016,3,16,15,38,0,-5),35.227085,-80.843124) 

puts 'Sun Rise is at: ' + st.get_sunrise.to_s
puts 'High Noon is at: ' + st.get_highnoon.to_s
puts 'Sun Set is at: ' + st.get_sunset.to_s
puts ''
puts 'Start the graph at the hour: ' + st.get_sunrise.hour.to_s
puts 'Stop the graph at the hour: ' + (st.get_sunset.hour + 1).to_s
