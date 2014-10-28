# Customisable New Relic widgets for Dashing

This Newrelic widget for dashing is a fork from [https://github.com/thenayr/dashing-newrelic/](https://github.com/thenayr/dashing-newrelic/).  
It's much more generic.

## Description

This is a widget to help monitor your web applications performance using New Relic.  The widget aims to be generic, that is you can use it for multiple application ID and any metric returned by the New Relic API.  
Default metrics are:

* **Error Rate**
* **Response Time**
* **Requests per minute (throughput)**
* **Apdex**

The widget is designed for maximum visibility from a distance. Widgets contains a maximum of 60 points of data at any given time. The chart will start on the right of the chart and fill over time to be the full width of the widget. Historical data stored by dashing will be used if available.

Neutral colours are used for behaving values, and high contrast yellow and red for warning and errors respectively. The widget is responsive and react to changes in the values returned. There are three possible colors, neutral (green), yellow and red.

## Dependencies

The following gems are required:
 * [newrelic_api](https://github.com/newrelic/newrelic_api)
 * [activeresource](https://github.com/rails/activeresource)

Place them inside the Dashing `Gemfile`:

```
## Gemfile
gem 'newrelic_api'
gem 'activeresource'
```

Then `bundle install`

## Using the New Relic widgets

These widgets are designed for quick and easy usage.  First copy the `widget`, `assets`, `job`, and `lib` folders into place.  The assets folder contains a background image for the widgets.

Now copy over the `config.yml` into the root directory of your Dashing application.  Be sure to replace the following options inside of the config file with your own New Relic information:

```yaml
:newrelic:
  :api_key: "xxxxxxxxxxxxxxx"
  :app_ids: [ 'xxxxx', 'yyyyy', 'zzzzz' ]
  :metrics: [ 'Apdex', 'Error Rate', 'Response Time', 'Throughput' ]
```
These config options get loaded in the job file.

Now you only need to add the widgets into your dashboard, where `xxxxx` is your application ID:

* **Response time widget**
```html
<li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
  <div id="nr_xxxxx_Response_Time" data-id="nr_xxxxx_Response_Time" data-view="Newrelic" data-title="Response time" data-green="200" data-yellow="500" ></div>
</li>
```

* **RPM (throughput) widget**
```html
<li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
  <div id="nr_xxxxx_Throughput" data-id="nr_xxxxx_Throughput" data-view="Newrelic" data-title="RPM" data-green="2000" data-yellow="2500" ></div>
</li>
```

* **Error rate widget**
```html
<li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
  <div id="nr_xxxxx_Error_Rate" data-id="nr_xxxxx_Error_Rate" data-view="Newrelic" data-title="Error rate" data-green="1" data-yellow="3"></div>
</li>
```

* **Apdex widget**
```html
<li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
  <div id="nr_xxxxx_Apdex" data-id="nr_xxxxx_Apdex" data-view="Newrelic" data-title="Apdex" data-green="0.9" data-yellow="0.8" ></div>
</li>
```

## Customize responsive (color changing) widgets

You can customise the thresholds for the point at which the widgets change colours. This is done by changing the `data-green` and `data-yellow` attributes of the HTML you added to the dashboard above.

Any value between `data-green` and `data-yellow` will be yellow. If `data-green` is larger than `data-yellow`, then anything above `data-green` will be green, and anything below `data-yellow` will be red, and vice-versa.

## Adding more widgets

You can easily add new widgets using any value returned by the New Relic API. Follow this example to add a 'CPU' widget:

 * Add new metric to `metrics` array in file `config.yml`, for example `:metrics: [ 'Apdex', 'Error Rate', 'Response Time', 'Throughput', 'CPU' ]`
 * Add widget to you dashboard:
```html
<li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
  <div id="nr_xxxxx_CPU" data-id="nr_xxxxx_CPU" data-view="Newrelic" data-title="CPU" data-green="70" data-yellow="90" ></div>
</li>
```
 * You now have a CPU widget which will be green below 70%, yellow up to 90% and red above.

### Metrics available from API

As of 5 July 2014, the following metrics are available from the API on the free usage tier (take care to maintain spaces/capitalisation/etc):

 * `Apdex` (index)
 * `Error Rate` (percent)
 * `Throughput` (rpm)
 * `Errors` (epm)
 * `Response Time` (ms)
 * `DB` (percent)
 * `CPU` (percent)
 * `Memory` (MB)
