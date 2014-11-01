require 'newrelic-metrics'
require 'yaml'

config = YAML.load File.open("config.yml")
config = config[:newrelic]
api_key = config[:api_key]
metrics = config[:metrics]
points = {}

SCHEDULER.every '30s', :first_in => 0 do |job|

  metrics.map { |app_id, metric_list|
    # Initialize API for considered app_id
    newrelic = NewRelicMetrics.new(api_key, application: app_id)
    # Get defaut metrics for all application
    raw_series = newrelic.show['application_summary']
    # Extract needed informations
    raw_series.map { |rsk, rsv|
      key = "newrelic_#{app_id}_#{rsk.gsub(/\//, '_').downcase}"
      points[key] || (
        history = YAML.load Sinatra::Application.settings.history[key].to_s
        unless history === false
          points[key] = history['data']['points'].map{|ha| Hash[ha.map{|hak,hav| [hak.to_sym,hav] }] }
        else
          points[key] = (0..59).map{|ea| { x: ea, y: 0 } }
        end
      )
      points[key].shift
      points[key] << { x: points[key].last[:x] + 1, y: rsv }
    }
    # If specific metrics are requested
    # No need of history there since we got full metric list from newrelic
    if metric_list && metric_list != {}
      # Get metrics
      raw_serie = newrelic.metrics( Hash[ metric_list.map{ |key, value| [key, value]}],{from:'1 hour ago'})
      # Extract needed informations
      # One-liner by @aeris22
      points = Hash[
        raw_serie['metrics'].collect { |hash|
          [
            "newrelic_#{app_id}_#{hash['name'].gsub(/\//, '_').downcase}",
            hash['timeslices'].collect.with_index { |v, i|
              { :x => i, :y => v['values']['call_count'] }
            }
          ]
        }
      ]
    end
  }

  points.each do |key,values|
    send_event(key, {
        current: values.last[:y],
        points: values
      }
    )
  end

end
