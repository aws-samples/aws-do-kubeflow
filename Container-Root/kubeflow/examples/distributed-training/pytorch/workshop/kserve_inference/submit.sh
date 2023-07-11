!/bin/sh -e

echo $1
echo $2
if [ "$1" = "" ]; then
			echo "Argument not provided. Provide S3 bucket name ..."
			exit 1
		else
			export bucket=$1
fi

if [ "$2" = "" ]; then
                        echo "Argument not provided. Provide model artifact name ..."
                        exit 1
                else
                        export model_input=$2
fi

if [ "$3" = "" ]; then
                        echo "Argument not provided. Provide model archive output name ..."
                        exit 1
                else
                        export model_archive=$3
fi

if [ "$4" = "" ]; then
                        echo "Argument not provided. Provide model archive output name ..."
                        exit 1
                else
                        export model_uri=$4
fi

echo "Arguments are good"

aws s3 cp s3://${bucket}/${model_input} .
tar -xzvf 'model.tar.gz'

echo "copied model artifact from s3"

torch-model-archiver -f --model-name ${model_archive} --version 1.0 --model-file ./model.py --serialized-file ./model.pth --handler  ./model_handler.py

mkdir -p model_layout/config 
mkdir -p model_layout/model-store
cp config.properties model_layout/config/.
cp cifar.mar model_layout/model-store/

aws s3 cp ./model_layout ${model_uri}/ --recursive

echo "copied back model layout to s3"
