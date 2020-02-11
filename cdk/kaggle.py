from aws_cdk import (
    aws_ec2,
    core
)

class KaggleStack(core.Stack):

    def __init__(self, scope, id_, **kwargs):
        super().__init__(scope, id_, **kwargs)

        instance = aws_ec2.Instance(self, f'{id_}-instance',
            instance_type=aws_ec2.InstanceType.of(aws_ec2.InstanceClass.BURSTABLE3, aws_ec2.InstanceSize.SMALL),
            machine_image=aws_ec2.MachineImage.lookup(name='RStudio-1.2*'),
            vpc=aws_ec2.Vpc.from_lookup(self, f'{id_}-vpc', is_default=True)
        )

        instance.connections.allow_from(aws_ec2.Peer.ipv4('xxxxx/32'), aws_ec2.Port.tcp(80), 'allow http from my IP')



app = core.App()
KaggleStack(app, 'kaggle', env=core.Environment(account='xxxxxx', region='us-west-2'))

app.synth()
