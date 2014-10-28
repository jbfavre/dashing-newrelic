points = {}
last_x = {}
current = {}

newrelic = Newrelic.new()
points = newrelic.points

# build points list from history
newrelic.app_ids.each do |app_id|
  newrelic.metrics.each do |metric|
    key = "nr_#{app_id}_#{metric.gsub(/ /,'_')}"
    last_x[key] = points[key].last[:x]
  end
end

SCHEDULER.every '30s', :first_in => 0 do |job|

  # get last values
  current = newrelic.get_values

  # generate dashing events
  newrelic.app_ids.each do |app_id|
    newrelic.metrics.each do |metric|
      key = "nr_#{app_id}_#{metric.gsub(/ /,'_')}"

      ## Drop the first point value and increment x by 1
      points[key].shift
      last_x[key] += 1

      ## Push the most recent point value
      points[key] << { x: last_x[key], y: current[key] }

      send_event(key, { current: current[key], points: points[key] })
    end
  end

end
