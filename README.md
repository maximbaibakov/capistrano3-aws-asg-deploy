[![Gem Downloads](http://img.shields.io/gem/dt/capistrano3-asg-deploy.svg)](https://rubygems.org/gems/capistrano3-asg-deploy) [![Gem Version](https://badge.fury.io/rb/capistrano3-asg-deploy.png)](http://badge.fury.io/rb/capistrano3-asg-deploy) [![MIT license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)
# capistrano3-aws-asg-deploy
Capistrano 3 plugin for AWS Auto Scaling deploys.

This is a fork of [Aftab-Akram/capistrano3-asg-deploy](https://github.com/Aftab-Akram/capistrano3-asg-deploy), updated with new features and Capistrano 3 conventions.

 I'm mainly building this gem to work with private ip address

## Requirements

* aws-sdk-ec2 ~> 1
* aws-sdk-autoscaling ~> 1
* capistrano ~> 3


## Installation

Add this line to your application's Gemfile:

    gem 'capistrano3-aws-asg-deploy'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install capistrano3-aws-asg-deploy

Add this line to your application's Capfile:

```ruby
require 'capistrano/autoscaling_deploy'
```

## Usage

Set credentials with AmazonEC2FullAccess permission in the capistrano deploy script / stage files add the following lines

```ruby
set :aws_region, 'ap-northeast-1'
set :aws_access_key_id, 'YOUR AWS KEY ID'
set :aws_secret_access_key, 'YOUR AWS SECRET KEY'
set :aws_autoscaling_group_name, 'YOUR NAME OF AUTO SCALING GROUP NAME'
set :aws_deploy_roles, [:app, :web, :db]
set :aws_deploy_user, 'USER FOR SSH CONNECTION'

invoke 'autoscaling_deploy:setup_instances'
```

you can add more auto scaling configs to deploy to multiple auto scaling groups like a cluster

## How this works

This gem will fetch only running instances that have an auto scaling group name you specified

It will then reject the roles of :db and the :primary => true for all servers found **but the first one**

(from all auto scaling groups you have specified such as using more then once the auto scaling directive in your config - i.e cluster deploy)

this is to make sure a single working task does not run in parallel

you end up as if you defined the servers yourself like so:

````ruby
server ip_address1, :app, :db, :web, :primary => true
server ip_address2, :app, :web
server ip_address3, :app, :web
````

## Contributing

1. Fork it ( https://github.com/maximbaibakov/capistrano3-aws-asg-deploy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

To test while developoing just `bundle console` on the project root directory and execute
`Capistrano::AutoScalingDeploy::VERSION` for a quick test
