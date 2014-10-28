require 'yaml'
require 'newrelic_api'

class Newrelic

  attr_reader :metrics, :points

  #def initialize(options)
  #  @metrics  = get_config[:metrics]
  #  @points = {}
  #end

  def points
    @history = {}
    app_ids.each do |app_id|
      metrics.each do |metric|
        key = "nr_#{app_id}_#{metric.gsub(/ /,'_')}"
        history = YAML.load Sinatra::Application.settings.history[key].to_s
        unless history === false
          @history[key] = history['data']['points'].map{|a| Hash[a.map{|k,v| [k.to_sym,v] }] }
        else
          @history[key] = (0..59).map{|a| { x: a, y: 0 } }
        end
      end
    end
    @history
  end

  def get_values
    @values = {}
    app_ids.each do |app_id|
      metrics.each do |metric|
        key = "nr_#{app_id}_#{metric.gsub(/ /,'_')}"
        nr_app = newrelic_app.select { |i| i.id = app_id }
        @values[key]  = nr_app[0].threshold_values.select{|v| v.name.eql? metric}[0].metric_value
      end
    end
    @values
  end

  def metrics
    get_config[:metrics]
  end

  def app_ids
    get_config[:app_ids]
  end

  private

  def newrelic_app
    NewRelicApi.api_key = api_key
    NewRelicApi::Account.find(:first).applications
  end

  def app_select
    newrelic_app.select { |i| i.id = app_id }
  end

  def api_key
    get_config[:api_key]
  end

  def get_config
    config = YAML.load File.open("config.yml")
    config[:newrelic]
  end

end
