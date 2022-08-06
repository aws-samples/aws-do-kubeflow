ALL STEPS ARE RUN INSIDE NOTEBOOK SERVER

make sure kubeconfig is correct

create a .vscode folder and put a launch.json file inside it with the contents of the launchCopy.json

get image name by building and pulling in the container-mnist-debug folder

replace both image names with your image in pytorch-job-mnist.yaml file. it will look like
110605085135.dkr.ecr.us-west-2.amazonaws.com/pytorch-mnist:latest

run the pytorch-job-mnist.yaml file

ensure all 5 worker nodes and the master node is running

run the expose-debug.sh script on a pod you want to debug. ex: ./expose-debug.sh pytorch-worker1

use the kubetail pytorchjob command. instead of running like usual, it should hang.

click on the debug button on the left side of the notebook vscode ide. It looks like a play button with a bug

click the play button at the top and debug should start
