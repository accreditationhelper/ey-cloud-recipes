if ['solo', 'app_master', 'app'].include?(node[:instance_role])

  instances = node[:engineyard][:environment][:instances]
  redis_instance = (node[:instance_role][/solo/] && instances.length == 1) ? instances[0] : instances.find{|i| i[:name].to_s[/redis/]}

  # If you have only one utility instance uncomment the line below
  #redis_instance = node['utility_instances'].first
  # Otherwise, if you have multiple utility instances you can specify it by uncommenting the line below
  # You can change the name of the instance based on whatever name you have chosen for your instance.
  #redis_instance = node['utility_instances'].find { |instance| instance['name'] == 'redis' }

  if redis_instance
    node[:applications].each do |app, data|
      template "/data/#{app}/shared/config/redis.yml"do
        source 'redis.yml.erb'
        owner node[:owner_name]
        group node[:owner_name]
        mode 0655
        backup 0
        variables({
          :environment => node[:environment][:framework_env],
          :hostname => redis_instance[:private_hostname]
        })
      end
    end
  end
end