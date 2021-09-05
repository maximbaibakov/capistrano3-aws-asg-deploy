require 'active_support'
require 'active_support/time'

require 'aws-sdk-ec2'
require 'aws-sdk-autoscaling'

namespace :load do
  task :defaults do
    set :aws_autoscaling, true
    set :aws_region, 'ap-northeast-1'
    set :aws_deploy_roles, [:app, :web, :db]
    set :aws_autoscale_ami_prefix, ''
  end
end

namespace :deploy do
  before :starting, :check_autoscaling_hooks do
    invoke 'autoscaling_deploy:setup_instances' if fetch(:aws_autoscaling)
  end
end

namespace :autoscaling_deploy do
  desc 'Add server from Auto Scaling Group.'
  task :setup_instances do
    ec2_instances = fetch_ec2_instances
    aws_deploy_roles = fetch(:aws_deploy_roles)
    aws_deploy_user = fetch(:aws_deploy_user)

    ec2_instances.each { |instance|
      if ec2_instances.first == instance
        server instance, user: aws_deploy_user, roles: aws_deploy_roles, primary: true
        puts("First Server: #{instance} - #{aws_deploy_roles}")
      else
        server instance, user: aws_deploy_user, roles: sanitize_roles(aws_deploy_roles)
        puts("Server: #{instance} - #{sanitize_roles(aws_deploy_roles)}")
      end
    }
  end

  def fetch_ec2_instances
    region = fetch(:aws_region)
    key = fetch(:aws_access_key_id)
    secret = fetch(:aws_secret_access_key)
    group_name = fetch(:aws_autoscaling_group_name)
    puts("Fetching servers for Auto Scaling Group: #{group_name}")

    instances = get_instances_ip(region, key, secret, group_name)

    puts("Found #{instances.count} servers (#{instances.join(' , ')}) for Auto Scaling Group: #{group_name} ")

    instances
  end

  # Get Autoscale Group Healthy Instance Public IP's
  def get_instances_ip(region, key, secret, group_name)
    credentials = {
      region: region,
      credentials: Aws::Credentials.new(key, secret)
    }
    instances_of_as = get_instances(credentials, group_name)
    autoscaling_dns = []
    ec2 = Aws::EC2::Resource.new(credentials)

    instances_of_as.each do |instance|
      if instance.health_status != 'Healthy'
        puts "Autoscaling: Skipping unhealthy instance #{instance.instance_id}"
      else
        autoscaling_dns << ec2.instance(instance.instance_id).public_ip_address
      end
    end

    autoscaling_dns
  end

  # Get Autoscale Group Instance Info
  def get_instances(credentials, group_name)
    as = Aws::AutoScaling::Client.new(credentials)
    instances_of_as = as.describe_auto_scaling_groups(
      auto_scaling_group_names: [group_name],
      max_records: 1,
    ).auto_scaling_groups[0].instances

    instances_of_as
  end

  # remove :db (for migrations), remove  :primary => :true (for assets precompile) for primary server
  def sanitize_roles(roles)
    roles.inject([]) { |acc, role|
      if !role.is_a?(Hash)
        acc << role if role != :db
      else
        acc << role.reject { |k, v| k == :primary }
      end
      acc
    }
  end
end