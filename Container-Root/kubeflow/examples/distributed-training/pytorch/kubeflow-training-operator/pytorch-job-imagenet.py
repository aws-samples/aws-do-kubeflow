from kubernetes.client import V1PodTemplateSpec
from kubernetes.client import V1ObjectMeta
from kubernetes.client import V1PodSpec
from kubernetes.client import V1Container
from kubernetes.client import V1ResourceRequirements
from kubernetes.client import V1LocalObjectReference

from kubeflow.training import constants
from kubeflow.training import utils
from kubeflow.training import V1ReplicaSpec
from kubeflow.training import V1PyTorchJob
from kubeflow.training import V1PyTorchJobSpec
from kubeflow.training import PyTorchJobClient
from kubeflow.training import V1RunPolicy

import os

def main():
    
    registry=os.getenv('REGISTRY','')
    if ( registry != '' ):
        if ( registry[-1] != '/' ):
            registry = "%s/"%registry
    
    container = V1Container(
        name="pytorch",
        image="%spytorch-imagenet:latest"%registry,
        command=[
            "python",
            "-m",
            "torch.distributed.run",
            "imagenet.py",
            "--arch=resnet18",
            "--epochs=2",
            "--batch-size=32",
            "--workers=0",
            "/workspace/data/tiny-imagenet-200"
        ],
        resources=V1ResourceRequirements(limits={"nvidia.com/gpu": "1"})
    )

    master = V1ReplicaSpec(
        replicas=1,
        restart_policy="OnFailure",
        template=V1PodTemplateSpec(
            spec=V1PodSpec(
                containers=[container],
                image_pull_secrets=[V1LocalObjectReference("ecr-token")]
            ),
            metadata=V1ObjectMeta(
                annotations={"sidecar.istio.io/inject": "false"}
            )
        )
    )

    worker = V1ReplicaSpec(
        replicas=2,
        restart_policy="OnFailure",
        template=V1PodTemplateSpec(
            spec=V1PodSpec(
                containers=[container],
                image_pull_secrets=[V1LocalObjectReference("ecr-token")]
            ),
            metadata=V1ObjectMeta(
                annotations={"sidecar.istio.io/inject": "false"}
            )
        )
    )

    pytorchjob = V1PyTorchJob(
        api_version="kubeflow.org/v1",
        kind="PyTorchJob",
        metadata=V1ObjectMeta(name="distributed-pytorch-job-imagenet"),
        spec=V1PyTorchJobSpec(
            pytorch_replica_specs={'Master': master, 'Worker': worker},
            run_policy=V1RunPolicy(clean_pod_policy="None")
        )
    )

    pytorchjob_client = PyTorchJobClient()
    pytorchjob_client.create(pytorchjob)
    #pytorchjob_client.delete(pytorchjob)
    

if __name__ == "__main__":
    
    main()
