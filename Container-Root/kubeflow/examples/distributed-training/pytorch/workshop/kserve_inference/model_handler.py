from torchvision import transforms
from ts.torch_handler.image_classifier import ImageClassifier
from torch.profiler import ProfilerActivity
import base64


class CIFARImageClassifier(ImageClassifier):
    
    image_processing = transforms.Compose([
        transforms.RandomCrop(32, padding=4),
        transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
        transforms.Normalize((0.4914, 0.4822, 0.4465), (0.2023, 0.1994, 0.2010)),
    ])

    def __init__(self):
        super(CIFARImageClassifier, self).__init__()
        self.profiler_args = {
            "activities" : [ProfilerActivity.CPU],
            "record_shapes": True,
        }
        
    def get_all_keys(d):
        if isinstance(d, dict):
            for key, value in d.items():
                if(key.startswith('instances')):
                    yield value
                if isinstance(value, dict):
                    yield from get_all_keys(value)
        if isinstance(d, list):
            yield d


    def preprocess(self, data):
        # Base64 encode the image to avoid the framework throwing
        # non json encodable errors
        print("printing right value v2:")
        
        
        def img_data(data):
            data_dict={}

            def get_all_keys(data):
                if isinstance(data, dict):
                    for key, value in data.items():
                        if(key.startswith('instances')):
                            yield value
                        if isinstance(value, dict):
                            yield from get_all_keys(value)
                if isinstance(data, list):
                    unk_object=data[0]
                    if(isinstance(unk_object, dict)):
                        if(list(unk_object.keys())[0]).startswith('data'):
                            yield data
                        else:
                            yield img_data(unk_object)  

            for data_dict in get_all_keys(data):
                data_dict=data_dict

            return data_dict
        
        data=img_data(data)
            
        print(data)
        
        b64_data = []
        
        if(isinstance(data, list)):
            for row in data:
                print("printing row data v2:")
                print(row)
                #input_data = row.get("image_bytes")("b64") or row.get("body")
                input_data = row["data"]
                # Wrap the input data into a format that is expected by the parent
                # preprocessing method
                b64_data.append({"body": base64.b64decode(input_data)})
        else:
            print("printing direct data v2:")
            print(data["data"])
            input_data = data["data"]
            b64_data.append({"body": base64.b64decode(input_data)})
    
        return ImageClassifier.preprocess(self, b64_data)
    
    
    def postprocess(self, data):
        """The post process of MNIST converts the predicted output response to a label.
        Args:
            data (list): The predicted output from the Inference with probabilities is passed
            to the post-process function
        Returns:
            list : A list of dictionaries with predictions and explanations is returned
        """
        return data.argmax(1).tolist()