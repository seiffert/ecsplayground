AWSTemplateFormatVersion: "2010-09-09"
Resources:
  ClusterLaunchConfig:
    Type: "AWS::AutoScaling::LaunchConfiguration"
    Properties:
      IamInstanceProfile: !Ref 'EC2InstanceProfile'
      ImageId: "ami-c6f424a9"
      InstanceType: "t2.micro"
      KeyName: "macbookjimdo"
      UserData: "${base64encode(user_data)}"

  ClusterASG:
    Type: "AWS::AutoScaling::AutoScalingGroup"
    Properties:
      AvailabilityZones:
        Fn::GetAZs: ''
      LaunchConfigurationName:
        Ref: ClusterLaunchConfig
      MinSize: '1'
      MaxSize: '3'
    UpdatePolicy:
      AutoScalingRollingUpdate:
        MaxBatchSize: 1
        MinInstancesInService: 1
        PauseTime: PT2M

  EC2Role:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Statement:
        - Effect: Allow
          Principal:
            Service: [ec2.amazonaws.com]
          Action: ['sts:AssumeRole']
      Path: /
      Policies:
      - PolicyName: ecs-service
        PolicyDocument:
          Statement:
          - Effect: Allow
            Action: ['ecs:CreateCluster', 'ecs:DeregisterContainerInstance', 'ecs:DiscoverPollEndpoint',
              'ecs:Poll', 'ecs:RegisterContainerInstance', 'ecs:StartTelemetrySession',
              'ecs:Submit*']
            Resource: '*'
  EC2InstanceProfile:
    Type: AWS::IAM::InstanceProfile
    Properties:
      Path: /
      Roles: [!Ref 'EC2Role']