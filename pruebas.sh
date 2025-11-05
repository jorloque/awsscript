#creo el grupo de seguridad
SG_ID=$(aws ec2 create-security-group --vpc-id  vpc-02900ca405b5f2be6 \
  --group-name gs-mio \
  --description "Mi grupo de seguridad para abrir el puerto 22" \
  --query GroupId --output text)

echo "Y ahora el grupo de seguridad:"
echo $SG_ID

aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "0.0.0.0/0", "Description": "Allow SSH"}]}]' \
    --ip-permissions '[{"IpProtocol": "http", "FromPort": 80, "ToPort": 80, "IpRanges": [{"CidrIp": "0.0.0.0/0", "Description": "Allow http"}]}]'

