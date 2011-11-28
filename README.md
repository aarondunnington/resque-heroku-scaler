Resque Heroku Scaler
====================

This [gem][rg] provides autoscaling for [Resque][rq] workers on [Heroku][hk].
Based on previous scaling work developed by [Daniel Huckstep][dh] and
[Alexander Murmann][am].

Autoscaling behavior is provided through a separate monitor process. The
scaler monitor process polls for pending jobs against the specified Resque
Redis backend at a configurable interval. The scaler process runs as a worker
process on Heroku.

Blog Post
---------

For details on the motivation behind using a separate scaler process, please
see [this post][ad].

Setup
-----

Add the following environment variables to your Heroku environment:

* HEROKU_APP
* HEROKU_USERNAME
* HEROKU_PASSWORD

Include the scaler tasks in a file within lib/tasks (ex: lib/tasks/scaler.rake)

```ruby
require 'resque/tasks'
require 'resque/plugins/heroku_scaler/tasks'

task "resque:setup" => :environment
```

In your Procfile, configure the scaler as a worker process using:

```
scaler: bundle exec rake resque:heroku_scaler
```

To run the scaler process, use the following command. Note, the scaler process
is intended to run as a single instance.

```
heroku scale scaler=1
```

Require the worker extensions within the app running the workers. For example,
in lib/tasks/resque.rake.

```ruby
require 'resque/tasks'

task "resque:setup" => :environment do
  require 'resque-heroku-scaler'
  ENV['QUEUE'] = '*'
end
```

In your development environment, the scaler process can run local worker
processes using the rush library. To configure, update your scaler file in
lib/tasks to use the local scale manager below (ex: lib/tasks/scaler.rake).

```ruby
require 'resque/tasks'
require 'resque/plugins/heroku_scaler/tasks'

task "resque:setup" => :environment do
  if Rails.env.development?
    require 'resque-heroku-scaler'
    ENV["RUSH_PATH"] ||= File.expand_path('/path/to/app', __FILE__)
    Resque::Plugins::HerokuScaler.configure do |c|
      c.scale_manager = :local
    end
  end
end
```

[rg]: http://rubygems.org/gems/resque-heroku-scaler
[rq]: http://github.com/defunkt/resque
[hk]: http://devcenter.heroku.com/articles/cedar
[dh]: http://verboselogging.com/2010/07/30/auto-scale-your-resque-workers-on-heroku
[am]: http://github.com/ajmurmann/resque-heroku-autoscaler
[ad]: http://www.dunnington.net/entry/autoscale-resque-workers-on-heroku