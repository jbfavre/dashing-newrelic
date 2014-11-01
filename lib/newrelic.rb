require 'restclient'
require 'json'
require 'uri'
require 'chronic'

class NewRelicMetrics
  BASE = 'https://api.newrelic.com/v2'

  def initialize(api_key,ids={})
    @api_key = api_key
    raise ArgumentError, "Need to define either an application or server id" if ids.keys.length!=1
    raise ArgumentError, "#{ids.keys.first} must be `application` or `server`" if ids.keys.first != :server && ids.keys.first != :application
    @resource = "#{ids.keys.first}s"
    @resource_id = ids.values.first
  end

  def names
    get("metrics")
  end

  def summarize(metrics={},range={})
    throw ArgumentError, "Range must be an array with the from and to time" if range.length>2

    settings = {summarize:true}.merge(range)

    metrics(metrics,settings)
  end

  def metrics(metrics={},options={})
    query = ""
    conditions = []

    names = metrics.keys
    values = metrics.values.flatten

    names.each {|name| conditions << "names[]=#{URI.encode(name)}" }
    values.each {|val| conditions << "values[]=#{URI.encode(val)}" }

    if options[:from]
      from_time = Chronic.parse(options[:from], context: :past)
      to_time = Chronic.parse(options[:to]) if options[:to]
      to_time ||= Time.now
      if from_time
        conditions << "from=#{from_time.getlocal('+00:00').iso8601}"
        conditions << "to=#{to_time.getlocal('+00:00').iso8601}"
      end
    end

    conditions << "summarize=true" if options[:summarize]

    query = conditions.join('&')
    get("metrics/data",query)
  end

  def show
    uri = URI.parse('https://api.newrelic.com/')
    uri.path = "/v2/applications/#{@resource_id}.json"

    response = RestClient.get(uri.to_s,'X-Api-Key'=>@api_key)
    JSON.parse(response).values.first
  end

  private

  def get(path,query=nil)
    uri = URI.parse('https://api.newrelic.com/')
    uri.path = "/v2/#{@resource}/#{@resource_id}/#{path}.json"
    uri.query = query if query && query != ""

    response = RestClient.get(uri.to_s,'X-Api-Key'=>@api_key)
    JSON.parse(response).values.first
  end
end
