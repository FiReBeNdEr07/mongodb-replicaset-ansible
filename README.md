# Creating a highly available and secure three node MongoDB replica set

## Installing required things

### AWS CLI (Using pip3)
```
pip3 install awscli --upgrade --user
```
### Ansibe (Following Ubuntu installation process)
```
sudo apt update
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
``` 
### Terraform (Following Ubuntu installation process)
```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install -y terraform
```

## Steps to do the setup

### AWS CLI login
```
aws configure # Provide the AWS keys and use region of your choice, I was using ap-south-1
aws ec2 create-key-pair --key-name assgin-mani --query "KeyMaterial" --output text > assginmani.pem  #Generate key-pair for yoursefl
chmod 400 assginmani.pem #Please change the permission of this key 
```
### Initialing EC2 instances using Terrafrom
```
cd /terraform
terraform init # This will initaite terraform in our working directory
terraform valicate # This will validate our terraform config files.
# To understand the config please refer to inline comments.
terraform apply # This will initailize EC2 instance with attached EBS storage
```
### Update host file with the output returned form the terraform init comaand ip and your host file(which is files/hosts) should look like this
```
127.0.0.1 localhost
xx.xx.xx.xx   mongo1 
xx.xx.xx.xx   mongo2
xx.xx.xx.xx   mongo3
# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
```
### Upadte to your machine hosts with with this
```
xx.xx.xx.xx   mongo1 
xx.xx.xx.xx   mongo2
xx.xx.xx.xx   mongo3
```
### Creating SSL's for Mongod(using opensll)
```
cd files/keys
bash key.sh
```
### Installing Monogo, mounting EBS, copying SSL certs, mongo replia set init
```
ansible-playbook -i inventory --private-key assginmani.pem --become --become-user=root mongo.yaml #Please refer to inline desc of task to understand
```
## *Now you have highly available and secure three node MongoDB replica set*

## For monitoring I am using MongoDB Free monitoring, we can enable using.
```
ssh -i assginmani.pem ubuntu@mongo1 #SSH to server
cd /ets/ssl
mongo --host mongo1 --ssl --sslPEMKeyFile client.pem --sslCAFile ca.pem #mongo1 is my primary node
rs0:PRIMARY> db.enableFreeMonitoring() # This will give me URL to monitoring
```
### To access the mongodb from local you should have client.pem and ca.pem
```
mongo --host mongo1 --ssl --sslPEMKeyFile client.pem --sslCAFile ca.pem
```


# Summary
Now we have running High Availbilty monogodb cluster, here it's explained why it's high available, https://docs.mongodb.com/manual/core/replica-set-high-availability/ (I can try to explain this myself, but docs will be more to the point). And this is secure as Client need SSL to access this which can be only generate from our side and shared. 

# *Note* 
* For production use Please expose your mongodb to VPC only.
* For production use Please please bind it to Public/Private IP not 0.0.0.0

# Teardown
```
ansible-playbook -i inventory --private-key assginmani.pem --become --become-user=root teardown.yaml 
terraform destroy # Removes all EC2 and EBS