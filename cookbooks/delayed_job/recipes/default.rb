#
# Cookbook Name:: delayed_job
# Recipe:: default
#

if node[:instance_role] == "solo" || (node[:instance_role] == "util" && node[:name] !~ /^(mongodb|redis|memcache)/)
  node[:applications].each do |app_name,data|
  
    # determine the number of workers to run based on instance size

    #  2 workers on staging
    if node[:environment][:framework_env] == 'staging'
      worker_count = 2
    # production solo instance (no workers)
    elsif node[:instance_role] == 'solo'
      worker_count = 0
    # production util instance
    elsif node[:instance_role] == 'util'
      worker_count = 5
    else
      case node[:ec2][:instance_type]
      when 'm1.small' then worker_count = 2
      when 'm1.medium' then worker_count = 10
      when 'c1.xlarge' then worker_count = 8
      else 
        worker_count = 0
      end

    end
    
    worker_count.times do |count|
      template "/etc/monit.d/delayed_job#{count+1}.#{app_name}.monitrc" do
        source "dj.monitrc.erb"
        owner "root"
        group "root"
        mode 0644
        variables({
          :app_name => app_name,
          :user => node[:owner_name],
          :worker_name => "#{app_name}_delayed_job#{count+1}",
          :framework_env => node[:environment][:framework_env]
        })
      end
    end
    
    execute "monit reload" do
       action :run
       epic_fail true
    end
      
  end
end