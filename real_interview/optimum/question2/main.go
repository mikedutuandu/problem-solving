package main

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
)

func main() {

	svc := ec2.New(session.New())
	input := &ec2.DescribeInstancesInput{
		Filters: []*ec2.Filter{
			{
				Name: new(string),
				Values: []*string{
					aws.String("running"),
				},
			},
		},
	}

	*input.Filters[0].Name = "instance-state-name"

	result, err := svc.DescribeInstances(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			default:
				fmt.Println(aerr.Error())
			}
		} else {
			// Print the error, cast err to awserr.Error to get the Code and
			// Message from an error.
			fmt.Println(err.Error())
		}
		return
	}

	for _, reservation := range result.Reservations {
		for _, instance := range reservation.Instances {
			fmt.Printf("%s", *instance.InstanceId)
			fmt.Printf("%s", *instance.InstanceType)
			fmt.Printf("%s", *instance.PublicIpAddress)
		}
	}

	fmt.Println(result)
}
