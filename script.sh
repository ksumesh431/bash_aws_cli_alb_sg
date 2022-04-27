#!/bin/bash

alb_arn="arn:aws:elasticloadbalancing:ap-south-1:507074252730:loadbalancer/app/boto3-appLB/c432240b1d6481c3"
accID=${alb_arn:40:12}


#Function to fetch ALB, get Old Security Groups and VPC ID.
alb_fetch_function(){
    
    local response=$(aws elbv2 describe-load-balancers --load-balancer-arns $1)
    
    old_SGs=$(echo $response | grep -o '\"sg-\S*')
    vpc_id=$(echo $response | grep -o '\"vpc-\S*\"')
}

alb_fetch_function $alb_arn
printf "Old Security Groups = $old_SGs \nVPC ID = $vpc_id \n\n"

#Sed to remove " " from vpc id
vpc_id=$(sed -e 's/^"//' -e 's/"$//' <<<"$vpc_id" )









#````````````````````````````````````````````````````````````````````````````````````````````````````````````````
#````````````````````````````````````````````````````````````````````````````````````````````````````````````````









sg_create_function(){

    #New security group creation
    local response=$(aws ec2 create-security-group --group-name abcde --description "Chk alb for sg attachment" --vpc-id $1)

    new_sg_id=$(echo $response | grep -o '\"sg-\S*')
    #sed to remove " " from security group id
    new_sg_id=$(sed -e 's/^"//' -e 's/"$//' <<<"$new_sg_id" )


    # code to add any ingress rule in sg
    aws ec2 authorize-security-group-ingress \
    --group-id $new_sg_id \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

    # code to ATTACH to ELB
    echo Newly Created Security Group is:
    aws elbv2 set-security-groups --load-balancer-arn $2 --security-groups $new_sg_id
}


# ******* UNCOMMENT to run security group function
# sg_create_function $vpc_id $alb_arn







