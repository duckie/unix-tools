#!/usr/bin/env python2

import json
import os
import yaml
import sys
from collections import defaultdict

class MakeNamespace(object):
    def __init__(self,values):
        self.__dict__.update(values)

# Examples of inventory-config.yml
#---
#aws:
#  region: eu-west-1
#  ec2:
#    group_by_tag: HostGroup
#    login_by_tag: Login
#    filters:
#      - Name: tag:Usage
#        Values: [ 'multicluster-group1' ]
#      - Name: tag:Owner
#        Values: [ 'jenkins' ]
#
#azure:
#  vm:
#    group_by_tag: HostGroup
#    login_by_tag: Login
#    filters:
#      - Name: Customer
#        Value: 'training'

# Open the configuration of current file
def main():
    conf = None
    if 1 < len(sys.argv) and sys.argv[1] != "--list":
        try: 
            conf = yaml.safe_load(open(sys.argv[1],"r"))
        except Exception:
            conf = json.loads(open(sys.argv[1],"r"))
    elif os.path.isfile("inventory-config.yml"):
        conf = yaml.safe_load(open("inventory-config.yml","r"))
    elif os.path.isfile("inventory-config.json"): 
        conf = json.loads(open("inventory-config.json","r"))

    # Prepare shared state

    ansible_inventory = defaultdict(list)
    ansible_inventory["all"] = { "hosts": [], "vars": {} }
    ansible_inventory["_meta"] = { "hostvars": {} }

    # Get the aws ec2 machines
    aws_conf = conf.get('aws',None)
    if aws_conf is not None:
        import boto3
        region = aws_conf.get("region",None)
        profile = aws_conf.get("profile",None)
        boto_session = boto3.session.Session(profile_name=profile)
        ec2_conf = conf['aws']['ec2'] 
        ec2_client = boto_session.client('ec2', region_name=region)
        instances = ec2_client.describe_instances(
                Filters = ec2_conf.get('filters',[]),
                )
        ec2_group_by_tag = ec2_conf.get("group_by_tag",None)
        ec2_login_by_tag = ec2_conf.get("login_by_tag",None)
        login = ec2_conf.get("login",None)
        for reservation in instances.get("Reservations",[]):
            for instance_dict in reservation.get("Instances",[]):
                instance = MakeNamespace(instance_dict)
                if instance.State.get("Name",None) == "terminated" or instance.State.get("Name",None) == "stopped":
                    continue
                #host = instance.PublicDnsName
                host = instance.PublicIpAddress
                tag_map = { tag["Key"] : tag["Value"] for tag in instance.Tags }
                name = tag_map.get("Name",None)
                facts = {
                    "public_dns_name": instance.PublicDnsName,
                    "public_ip": instance.PublicIpAddress,
                    "private_dns_name": instance.PrivateDnsName,
                    "private_ip": instance.PrivateIpAddress,
                    "tags": tag_map,
                    "is_ec2": True,
                    "ansible_host": host
                }
                if name is not None:
                    host = name
                    #ansible_inventory[name].append(host)
                if ec2_group_by_tag is not None:
                    value = tag_map.get(ec2_group_by_tag, None)
                    if value is not None:
                        ansible_inventory[value].append(host)
                if ec2_login_by_tag is not None:
                    value = tag_map.get(ec2_login_by_tag,None)
                    if value is not None:
                        facts["ansible_ssh_user"] = value
                if login is not None:
                    facts["remote_user"] = login
                    facts["ansible_ssh_user"] = login
                ansible_inventory["_meta"]["hostvars"][host] = facts
                if host not in  ansible_inventory["all"]["hosts"]:
                    ansible_inventory["all"]["hosts"].append(host)

    azure_conf = conf.get('azure',None)
    if azure_conf is not None:
        import azure
        from azure.common.credentials import ServicePrincipalCredentials
        from azure.mgmt.resource import ResourceManagementClient
        from azure.mgmt.network import NetworkManagementClient
        from azure.mgmt.compute import ComputeManagementClient

        credentials, subscription_id = azure.common.credentials.get_azure_cli_credentials()
        compute_client = ComputeManagementClient(credentials,subscription_id)
        resource_client = ResourceManagementClient(credentials,subscription_id)
        network_client = NetworkManagementClient(credentials,subscription_id)

        vm_conf = azure_conf['vm']
        filter="resourceType eq 'Microsoft.Compute/virtualMachines'"
        #for f in vm_conf['filters']:
            #filter += " & {} eq {{{}}}".format(f['Name'],f['Value'])
        resources = resource_client.resources.list(filter=filter)
        machines = []
        group_by_tag = vm_conf.get("group_by_tag",None)
        login_by_tag = vm_conf.get("login_by_tag",None)
        login = vm_conf.get("login",None)
        for resource in resources:
            if resource.tags is not None:
                is_valid = True
                for f in vm_conf['filters']:
                    is_valid = is_valid and resource.tags[f['Name']] == f['Value']
                if is_valid:
                    id_data = resource.id.split('/')
                    vm_name = id_data[-1]
                    group = id_data[4]
                    machines.append(compute_client.virtual_machines.get(group,vm_name))
            
        for machine in machines:
            name = machine.name
            net_data = machine.network_profile.network_interfaces[0].id.split("/")
            net_group = net_data[4]
            net_name = net_data[-1]
            itf = network_client.network_interfaces.get(net_group,net_name)
            private_ip = itf.ip_configurations[0].private_ip_address

            # Find out public ip
            ip_data = itf.ip_configurations[0].public_ip_address.id.split('/')
            ip_group, ip_name = ip_data[4], ip_data[-1]
            public_ip_resource = network_client.public_ip_addresses.get(ip_group,ip_name)
            public_ip = public_ip_resource.ip_address
            public_dns = None
            if public_ip_resource.dns_settings is not None:
                public_dns = public_ip_resource.dns_settings.fqdn

            # Create facts
            host = public_ip
            tag_map = machine.tags 
            tag_map['Name'] = name
            facts = {
                "name": name,
                "public_dns_name": public_dns,
                "public_ip": public_ip,
                "private_dns_name": machine.os_profile.computer_name, # Unfortunately not true :(
                "private_ip": private_ip,
                "tags": tag_map,
                "is_azure": True,
                "ansible_host": host
            }
        
            if name is not None:
                #ansible_inventory[name].append(host)
                host = name
            if group_by_tag is not None:
                value = tag_map.get(group_by_tag, None)
                if value is not None:
                    ansible_inventory[value].append(host)
            if login_by_tag is not None:
                value = tag_map.get(login_by_tag,None)
                if value is not None:
                    facts["ansible_ssh_user"] = value
            if login is not None:
                facts["remote_user"] = login
                facts["ansible_ssh_user"] = login
            ansible_inventory["_meta"]["hostvars"][host] = facts
            if host not in  ansible_inventory["all"]["hosts"]:
                ansible_inventory["all"]["hosts"].append(host)

    print(json.dumps(ansible_inventory))

if __name__ == "__main__":
    main()
