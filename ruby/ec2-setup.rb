#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'rubygems'
require 'aws-sdk'
require 'net/ssh'

################################################################
## chef roles
# EC2 instance startup ruby script using the chef.
# ${access_key_id}     : Please set your own access key here.
# ${secret_access_key} : Please set your own secret key here.
################################################################
role = ARGV[0]
if !role
  # If the default roles exist..
  role = 'base'
end

#AWS resion (Tokyo)
REGION = 'ap-northeast-1'
AVAILABILITY_ZONE = 'ap-northeast-1a'

################################################################
# Setting
################################################################
xxx_server_set = {
  'role'                 => 'role[xxx_server]',
  'ami'                  => 'ami-12345678',
  'flavor'               => 'm1.medium',
  'ssh_user'             => 'root',
  'ssh_key_file'         => '/home/xxx/.ssh/ec2.pem',
  'security_group_id'    => 'sg-12345678',
  'subnet_id'            => 'subnet-12345678',
  'key-pair_name'        => 'kp-yyy',
  'iam_instance_profile' => 'iam-zzz',
  'private_ip_subnet'    => '10.0.0.',
  'availability_zone'    => 'ap-northeast-1a'
}

################################################################
# role setting
################################################################
case role
when 'base'
  server_set = base
when 'xxx'
  server_set = xxx_server_set
when 'yyy'
  server_set = yyy_server_set
end

################################################################
# EC2 Access
################################################################
config = {:access_key_id => '${access_key_id}',
          :secret_access_key => '${secret_access_key}',
          :ec2_endpoint => 'ec2.ap-northeast-1.amazonaws.com'}

AWS.config(config)
ec2 = AWS::EC2.new

# Search xxx
names = []
ec2.instances.each do |instance|
  next if instance.status == :terminated
  next if instance.status == :shutting_down
  tags = instance.tags['Name']
  names << instance.private_ip_address.split(".")[3] if tags =~ /#{role}[\d]+/
end

# Max ServerID
last = names.sort.last
if last
  max_number = names.sort.last.gsub(role, '').to_i
else
  # Since the number of different origins by the system,
  # Please set as appropriate.
  max_number = 10
end

set_private_ip = server_set['private_ip_subnet'].to_s + (max_number + 1).to_s
tnumber = (max_number + 1).to_s
tname = role + "#{tnumber}"
print tname + "\n"

##################################
# Get instance_id & IP : -N #{tname}
##################################
# role setting
chef_setup_cmd =<<"EOS"
TIME_STAMP=`date +%Y-%m-%d_%H-%M-%S`
# if use EC2 user data
sed -e "s/\\(SERVER_TYPE=\\).*/\\1#{role}/" /home/xxx/bootstrap/centos_base.sh > /tmp/${TIME_STAMP}.txt
# Execution of the start-up
knife ec2 server create -r '#{server_set['role'].to_s}' --region #{REGION} -Z #{server_set['availability_zone'].to_s} -I #{server_set['ami'].to_s} -f #{server_set['flavor'].to_s} -x #{server_set['ssh_user'].to_s} -i #{server_set['ssh_key_file'].to_s} -g #{server_set['security_group_id'].to_s} -s #{server_set['subnet_id'].to_s} -S #{server_set['key-pair_name'].to_s} -k #{server_set['ssh_key_file'].to_s} --user-data /tmp/${TIME_STAMP}.txt -T Name=#{tname} --iam-profile #{server_set['iam_instance_profile'].to_s} --private-ip-address #{set_private_ip}
EOS

#print chef_setup_cmd + "\n"

chef_setup_cmd_result = `#{chef_setup_cmd}`
print chef_setup_cmd_result

/Instance ID: (.*)\n/ =~chef_setup_cmd_result
instance_id = $1
if !instance_id
  exit(0)
end
/Private IP Address: (.*)\n/ =~chef_setup_cmd_result
private_ip = $1
if !private_ip
  exit(0)
end

print "*** " + instance_id + " ***\n"
print "*** " + private_ip + " ***\n"

# Set termination protect.
ec2_term_cmd =<<"EOS10"
ec2-modify-instance-attribute #{instance_id} --disable-api-termination true
EOS10

ec2_term_cmd_result = `#{ec2_term_cmd}`
