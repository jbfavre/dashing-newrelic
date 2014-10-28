points = {}
last_x = {}
current = {}

newrelic = Newrelic.new()
points = newrelic.points

# build points list from history
points.each do |key,value|
  last_x[key] = value.last[:x]
end

SCHEDULER.every '30s', :first_in => 0 do |job|

  # get last values
  current = newrelic.get_values

  # generate dashing events
  current.each do |key,value|

    ## Drop the first point value and increment x by 1
    points[key].shift
    last_x[key] += 1

    ## Push the most recent point value
    points[key] << { x: last_x[key], y: value }

    send_event(key, { current: value, points: points[key] })
  end

end
