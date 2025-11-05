#creo la vpc y devuelvo su id
VPC_ID=$(aws ec2 create-vpc --cidr-block 192.168.3.0/24 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=nube1jorge}]' \
    --query Vpc.VpcId --output text)

#muestro el id de la vpc
echo $VPC_ID

#habilitar dns en la vpc
aws ec2 modify-vpc-attribute \
  --vpc-id $VPC_ID \
  --enable-dns-hostnames "{\"Value\":true}"

SUB_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 192.168.3.0/28 \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=mi-subred1-jorge}]' \
    --query Subnet.SubnetId --output text)

echo $SUB_ID


#habilito la asignacion de ipv4publica en la subred
#comprobar como NO se habilita y tenemos que hacerlo a posteriori
aws ec2 modify-subnet-attribute --subnet-id $SUB_ID --map-public-ip-on-launch

#creo el grupo de seguridad
SG_ID=$(aws ec2 create-security-group --vpc-id  $VPC_ID \
  --group-name gs-mio \
  --description "Mi grupo de seguridad para abrir el puerto 22" \
  --query GroupId --output text)

echo "Y ahora el grupo de seguridad:"
echo $SG_ID

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "0.0.0.0/0", "Description": "Allow SSH"}]}]' 

aws ec2 create-tags \
  --resources $SG_ID \
  --tags "Key=Name,Value=migruposeguridad" 


#creo un ec2
EC2_ID=$(aws ec2 run-instances \
    --image-id ami-0ecb62995f68bb549 \
    --instance-type t3.micro \
    --key-name vockey \
    --subnet-id $SUB_ID \
    --security-group-ids $SG_ID \
    --associate-public-ip-address \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=miec2}]' \
    --query Instances.InstanceId --output text)


