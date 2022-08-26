# Workshop Execution Steps

## 1. Set up AWS Accounts

1.1 If you are running the workshop **on your own** and you don’t already have an AWS account with Administrator access, please create one now by clicking here (https://aws.amazon.com/getting-started/). This workshop assumes that you already have an EKS cluster. If not, we recommend that you refer to the [aws-do-eks](https://github.com/aws-samples/aws-do-eks) project and create one using the [eks-kubeflow.yaml](https://github.com/aws-samples/aws-do-eks/blob/main/Container-Root/eks/eks-kubeflow.yaml) cluster manifest.

1.2 If you are running the workshop **at an AWS Event or with AWS teams**, Login to AWS Workshop Portal by clicking the button or browsing to https://dashboard.eventengine.run/

The following screen shows up.

<center><img src="img/event_engine_login_screen.png" width="80%"/> </center> <br/><br/>

1.3 Enter the provided hash (will be provided in the chat by the event administrator) in the text box. The button on the bottom right corner activates to Accept Terms & Login. Click on that button to continue the next screen below.


<center><img src="img/one_time_password.png" width="80%"/> </center><br/><br/>


1.4 Click on "Email One-Time Password(OTP)" and enter your email and click on "Send passcode" as below. 


<center><img src="img/sendpasscode.png" width="80%"/> </center> <br/><br/>


1.5 Enter the 9 digit passcode that you recieve in your email and click "Sign in"


<center><img src="img/9digit.png" width="80%"/> </center> <br/><br/>


1.6 Click on "AWS Console" button 

<center><img src="img/aws_console_button.png" width="80%"/> </center> <br/><br/>


1.7 Take the defaults and click on "Open Console". This will open AWS Console in a new browser tab.

<center><img src="img/aws_console_login.png" width="80%"/> </center> <br/><br/>


## 2. Register Cloud9 Environment

2.1 If you are using **your own account**, you can create a Cloud9 environment and EKS cluster, following steps 0 and 1 from [this workshop](https://github.com/aws-samples/aws-distributed-training-workshop-eks).

2.2 If you are running the workshop **at an AWS Event or with AWS teams**, an EKS cluster and an EC2 instance that has access to the cluster and has Cloud9 installed is already created for you. This section will describe  how to register your existing instance as a Cloud9 environment. 

2.3 To register the Cloud9 Environment from your existing EC2 instance with the AWS console, navigate to [Cloud9](https://us-west-2.console.aws.amazon.com/cloud9/home?region=us-west-2), then click the “Create environment” button.


<center><img src="img/cloud9_create_screen.png" width="80%"/> </center><br/><br/>


2.4 Enter a name for your environment and click “Next step”


<center><img src="img/cloud9_name_env.png" width="80%"/> </center><br/><br/>


2.5 In a new window, open the [EC2 Console](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Instances:instanceState=running) and list your running instances.

2.6 Select the m5.xlarge instance that is not an EKS node and ***copy its Public IPv4 address***.


<center><img src="img/cloud9_instances.png" width="80%"/> </center> <br/><br/>


2.7 Click the “Connect” button in the upper right section of the screen and then click the “Connect” button on the Session Manager tab


<center><img src="img/cloud9_session_manager.png" width="80%"/> </center><br/><br/>


2.8 The Session Manager will open a shell window in your browser, connected to the EC2 instance. Execute:

```
sudo su ec2-user
cd ~/.ssh
vi authorized_keys
```

2.9 Switch back to the Cloud9 screen, type ec2-user in the User field and paste the public IP address of your EC2 instance in the Host field, then click the Copy key to clipboard button.


<center><img src="img/cloud9_configure_settings.png" width="80%"/> </center><br/><br/>

2.10 Open the Session Manager window and paste the copied public key into the authorized_keys file and save 

<center><img src="img/cloud9_paste_publickey.png" width="20%"/> </center> <br/><br/>

To save authorized_keys file, Press Esc to enter Command mode, and then type :wq to write and then hit enter to quit the file.


2.11 Then click “Next step” in the Cloud9 console and “Create environment” on the Review screen.


<center><img src="img/cloud9_review.png" width="80%"/> <br/>

2.12 The browser will open the newly created Cloud9 environment. We will use this environment for the remainder of the workshop. You may close the Session Manager window. 

<center><img src="img/cloud9_newly_created.png" width="80%"/> </center><br/><br/>


## 3. Deploy Kubeflow

3.1 From your Cloud9 environment, click on "+" icon and open new terminal. Clone the aws-do-kubeflow repository:

```
git clone https://github.com/aws-samples/aws-do-kubeflow
cd aws-do-kubeflow
```

3.2 Get names of available EKS clusters

```
eksctl get clusters

NAME            REGION          EKSCTL CREATED
eks-kubeflow    us-west-2       True
```

3.3 **This is an optional step and has been initialized for the AWS Workshop** and is just to see/update the configurations if you building it in your own projects: Configure the project
```
./config.sh
```

Optional: Modify the cluster name setting in the file to match the name of the available EKS cluster in your environment
`export AWS_CLUSTER_NAME=eks-kubeflow`

Optional: Ensure the Kubeflow distribution is set to "aws"
`export KF_DISTRO=aws`

Optional: and save the configuration.

3.4 Then build and run the aws-do-kubeflow Docker container:

```
./build.sh
./run.sh
```

3.5 Open a new Terminal in your Cloud9 environment and optionally position it side by side with your current terminal, execute a watch command to continuously display all of the running pods in the cluster:

watch kubectl get pods -A

3.6 In the original terminal once step 3.4 completes and you see cli prompt $, open a shell into the running aws-do-kubeflow container and execute the kubeflow deploy scripts. 
 
```
./exec.sh
```

3.7 Execute the below script once step 3.6 completes

```
./kubeflow-deploy.sh
```

3.8 As Kubeflow is deployed to the cluster, you will see new pods in your watch window. When all pods enter the Running state, your Kubeflow instance is fully deployed.


<center><img src="img/kubeflow_cli.png" width="80%"/> </center><br/>


## 4. Login to Kubeflow Dashboard

4.1 To securely connect to the Kubeflow dashboard, from within the aws-do-kubeflow container execute(the original terminal same as in step 3.6):

```
./kubeflow-expose.sh
```

4.2 Then select Preview→Preview Running Application from the Cloud9 menu


<center><img src="img/cloud9_preview.png" width="80%"/> </center><br/><br/>


4.3 This will display your the Kubeflow login screen inside a tab within the Cloud9 environment. Click the detach icon located next to the“Browser” button in the right corner of the tab to open the Kubeflow dashboard in a separate browser window.


<center><img src="img/dex_login.png" width="80%"/></center><br/><br/>


4.4 Enter the default credentials (user@example.com / 12341234) to log in to your Kubeflow instance.

4.5 Once you are logged into the Kubeflow dashboard, ensure you have the right namespace "kubeflow-user-example-com" on top of the drop down 


<center><img src="img/1_kubeflow_dashboard.png" width="80%"/> </center><br/><br/>

> **_NOTE:_** If you do not see the namespace "kubeflow-user-example-com" selected in your Kubeflow dashboard, or you experience any other errors, please execute script `./kubeflow-restart.sh`, located in the aws-do-kubeflow container.

## 5. Create EFS volume


5.1 Click on Volumes on the left navigation. Click on New Volume in Volumes UI screen and enter following:
    1. Name:  “efs-sc-claim”, 
    2. Volume size: 10 Gi, 
    3. storage class: “efs-sc”  
    4. Access mode: ReadWriteOnce


<center><img src="img/2_kubeflow_efs_create.png" width="80%"/> </center><br/><br/>


5.2 Verify volume efs-sc-claim is created 


<center><img src="img/3_kubeflow_efs.png" width="80%"/> </center><br/><br/>


## 6. Create Jupyter Notebook 

6.1 Click on “Notebooks” on left navigation of the Kubeflow dashboard. Click on “New Notebook” button. Enter name as “aws-hybrid-nb”, select “jupyter-pytorch:1.11.0-cpu-py38” as Jupyter Docket Image. Enter 1 for CPU and 5 as memory in Gi. Keep GPUs as None.


<center><img src="img/4_kubeflow_create_jupyter.png" width="80%"/> </center><br/><br/>


6.2 Do not change "Workspace Volume" section. 

6.3 Click "Attach existing volume" in Data Volumes section. Expand Existing volume secion. Select Name as "efs-sc-claim" and enter "/home/jovyan/efs-sc-claim" as Mount path. 

<center><img src="img/5_kubeflow_data_volume_jupyter.png" width="80%"/> </center><br/><br/>

6.4 Select value "Allow access to Kubeflow Pipelines" in Configurations section and click LAUNCH . 

<center><img src="img/5.1_kubeflow_config_jupyter.png" width="80%"/> </center><br/><br/>


6.5 Verify if notebook is created successfully and CONNECT button is activated. It might takes couple of minutes to create a notebook. 


<center><img src="img/6_notebook_success.png" width="80%"/> <center/><br/><br/>


6.6 Click on CONNECT button to log on to JupyterLab like below. 


<center><img src="img/7_jupyterlab.png" width="80%"/> </center><br/><br/>


6.7 Clone the repo by entering `https://github.com/aws-samples/aws-do-kubeflow` in "Clone a repo" field

<center><img src="img/8_git_clone1.png" width="80%"/> </center><br/><br/>


<center><img src="img/8_git_clone2.png" width="80%"/> </center><br/><br/>

6.8 Browse to "aws-do-kubeflow/Container-Root/kubeflow/examples/distributed-training/pytorch/workshop" folder

6.9 Run notebook "0_initialize_dependencies.ipynb". Please wait for it to finish execution before you move on to next step

6.10 Run notebook “1_submit_pytorchdist_k8s.ipynb”      

Please ensure notebook '0_initialize_dependencies.ipynb' has finished executing the install scripts before you start with this notebook.

6.11 Run notebook “2_create_pipeline_k8s_sagemaker.ipynb”    

Please ensure you have executed notebook '1_submit_pytorchdist_k8s.ipynb' before you start with this notebook

If you get sagemaker import error then please do 
     1. !pip install sagemaker
     2. restart the Kernel (Go to 'Kernel' Menu -> Click 'Restart Kernel...')

6.12 Click on “Run details” link in the following cell. 

<center><img src="img/9_run_details.png" width="80%"/> </center><br/><br/>


You will see the pipeline run executed . 

<center><img src="img/10_pipeline.png" width="80%"/> </center><br/><br/>

