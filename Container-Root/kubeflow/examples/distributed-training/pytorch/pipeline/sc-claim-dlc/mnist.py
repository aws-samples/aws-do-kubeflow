import argparse
import logging
import os

import torch
import torch.distributed as dist
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
import torch.utils.data
from torch.optim.lr_scheduler import StepLR
from torchvision import datasets, transforms

logging.getLogger().setLevel(logging.INFO)

# Number of processes participating in (distributed) job
# See: https://pytorch.org/docs/stable/distributed.html
WORLD_SIZE = int(os.environ.get("WORLD_SIZE", 1))

logging.info("WORLD_SIZE- {}".format(WORLD_SIZE))

# Custom models must subclass toch.nn.Module and override `forward`
# See: https://pytorch.org/docs/stable/nn.html#torch.nn.Module
class Net(nn.Module):
    def __init__(self):
        super(Net, self).__init__()
        self.conv1 = nn.Conv2d(1, 32, 3, 1)
        self.conv2 = nn.Conv2d(32, 64, 3, 1)
        self.dropout1 = nn.Dropout2d(0.25)
        self.dropout2 = nn.Dropout2d(0.5)
        self.fc1 = nn.Linear(9216, 128)
        self.fc2 = nn.Linear(128, 10)

    def forward(self, x):
        x = self.conv1(x)
        x = F.relu(x)
        x = self.conv2(x)
        x = F.relu(x)
        x = F.max_pool2d(x, 2)
        x = self.dropout1(x)
        x = torch.flatten(x, 1)
        x = self.fc1(x)
        x = F.relu(x)
        x = self.dropout2(x)
        x = self.fc2(x)
        output = F.log_softmax(x, dim=1)
        #logging.info("Inside the model: Device id - {}".format(torch.cuda.current_device()))

        return output


def should_distribute():
    return dist.is_available() and WORLD_SIZE > 1


def is_distributed():
    logging.info("dist.is_available(): {} ".format(dist.is_available()))
    logging.info("dist.is_initialized(): {} backend".format(dist.is_initialized()))
    return dist.is_available() and dist.is_initialized()


def percentage(value):
    return "{: 5.1f}%".format(100.0 * value)


def train(args, model, device, train_loader, optimizer, epoch):
    model.train()
    
    
    logging.info("train_loader - {}".format(len(train_loader)))
    
    data_counter=0
    
    for batch_idx, (data, target) in enumerate(train_loader):
        #logging.info("Data Shape: {}".format(data.shape))
        #logging.info("device: {}".format(device))
        #logging.info("data length - {}".format(len(data)))
        data_counter += len(data)
        data, target = data.to(device), target.to(device)
        optimizer.zero_grad()
        output = model(data)
        loss = F.nll_loss(output, target)
        loss.backward()
        optimizer.step()

        #logging.info("Outside the model: Device id - {}".format(torch.cuda.current_device()))
        

        if batch_idx % args.log_interval == 0:
            logging.info(
                f"Epoch: {epoch} ({percentage(batch_idx / len(train_loader))}) - Loss: {loss.item()}"
            )
    logging.info("data_counter - {}".format(data_counter))

def test(args, model, device, test_loader):
    model.eval()
    test_loss = 0
    correct = 0
    with torch.no_grad():
        for data, target in test_loader:
            data, target = data.to(device), target.to(device)
            output = model(data)
            test_loss += F.nll_loss(
                output, target, reduction="sum"
            ).item()  # sum batch losses
            pred = output.argmax(dim=1, keepdim=True)
            correct += pred.eq(target.view_as(pred)).sum().item()

    test_loss /= len(test_loader.dataset)

    logging.info(
        f"Test accuracy: {correct}/{len(test_loader.dataset)} ({percentage(correct / len(test_loader.dataset))})"
    )

    # Log metrics for Katib
    logging.info("loss={:.4f}".format(test_loss))
    logging.info("accuracy={:.4f}".format(float(correct) / len(test_loader.dataset)))


def main():
    parser = argparse.ArgumentParser(description="PyTorch MNIST Training Job")
    parser.add_argument(
        "--batch-size",
        type=int,
        default=64,
        metavar="N",
        help="Batch size for training (default: 64)",
    )
    parser.add_argument(
        "--test-batch-size",
        type=int,
        default=1000,
        metavar="N",
        help="Batch size for testing (default: 1000)",
    )
    parser.add_argument(
        "--epochs",
        type=int,
        default=5,
        metavar="N",
        help="Number of epochs to train",
    )
    parser.add_argument(
        "--lr",
        type=float,
        default=1.0,
        metavar="LR",
        help="Learning rate (default: 1.0)",
    )
    parser.add_argument(
        "--gamma",
        type=float,
        default=0.7,
        metavar="M",
        help="Learning rate's decay rate (default: 0.7)",
    )
    parser.add_argument(
        "--no-cuda",
        action="store_true",
        default=False,
        help="Disables CUDA (GPU) training",
    )
    parser.add_argument(
        "--seed", type=int, default=1, metavar="S", help="Random seed (default: 1)"
    )
    parser.add_argument(
        "--log-interval",
        type=int,
        default=10,
        metavar="N",
        help="Number of training batches between status log entries",
    )
    parser.add_argument(
        "--save-model",
        action="store_true",
        default=False,
        help="Whether to save the trained model",
    )

    logging.info("distribution availible: {}".format(dist.is_available()))

    if dist.is_available():
        parser.add_argument(
            "--backend",
            type=str,
            help="Distributed backend",
            choices=[dist.Backend.GLOO, dist.Backend.NCCL, dist.Backend.MPI],
            default=dist.Backend.GLOO,
        )

    args, _ = parser.parse_known_args()
    logging.info("args.no_cuda: {}".format(args.no_cuda))

    logging.info("torch.cuda.is_available: {}".format(torch.cuda.is_available()))

    use_cuda = not args.no_cuda and torch.cuda.is_available()
    logging.info("Use Cuda: {}".format(use_cuda))

    torch.manual_seed(args.seed)

    if should_distribute():
        logging.info("Using distributed PyTorch with {} backend".format(args.backend))
        dist.init_process_group(backend=args.backend)

    logging.info("Downloading data ...")

    kwargs = {"num_workers": 1, "pin_memory": True} if use_cuda else {}
    train_data = datasets.MNIST(
        "sc-claim-dlc",
        download=True,
        train=True,
        transform=transforms.Compose(
            [transforms.ToTensor(), transforms.Normalize((0.1307,), (0.3081,))]
        ),
    )

    logging.info("Creating training dataset ...")
                 
    # DistributedSampler partitions the training dataset among the worker processes
    train_sampler = (
        torch.utils.data.distributed.DistributedSampler(train_data)
        if should_distribute()
        else None
    )

    train_loader = torch.utils.data.DataLoader(
        train_data,
        batch_size=args.batch_size,
        sampler=train_sampler,
        shuffle=False,
        **kwargs,
    )
    
    logging.info("Loading data ...")
    test_loader = torch.utils.data.DataLoader(
        datasets.MNIST(
            "sc-claim-dlc",
            download=False,
            train=False,
            transform=transforms.Compose(
                [transforms.ToTensor(), transforms.Normalize((0.1307,), (0.3081,))]
            ),
        ),
        batch_size=args.test_batch_size,
        shuffle=True,
        **kwargs,
    )
    
    logging.info("Loading model to device ...")
    device = torch.device("cuda" if use_cuda else "cpu")
    model = Net().to(device)
    
    logging.info("is_distributed(): {}".format(is_distributed()))
    logging.info("use_cuda:{}".format(use_cuda))

    if is_distributed():
        if use_cuda:
            torch.cuda.set_device(torch.cuda.current_device())
        model = nn.parallel.DistributedDataParallel(model)

    # Check if GPUs are availible for CUDA-built image
    if int(os.getenv("GPUS",0)) > 0:
        if torch.cuda.get_device_name() is None:
            raise Exception(
                    f"Cannot find GPUs available using image with GPU support."
                )

    # See: https://pytorch.org/docs/stable/optim.html#torch.optim.Adadelta
    optimizer = optim.Adadelta(model.parameters(), lr=args.lr)

    logging.info("Training model ...")
    # See: https://pytorch.org/docs/stable/optim.html#torch.optim.lr_scheduler.StepLR
    scheduler = StepLR(optimizer, step_size=1, gamma=args.gamma)
    for epoch in range(1, args.epochs + 1):
        train(args, model, device, train_loader, optimizer, epoch)
        test(args, model, device, test_loader)
        scheduler.step()

    logging.info("Saving model ...")
    if args.save_model:
        torch.save(model.state_dict(), "mnist_model.pt")
        
    logging.info("Done.")


if __name__ == "__main__":
    main()

