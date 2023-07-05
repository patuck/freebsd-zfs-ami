# Steps to create an AMI

## Upload the VHD file to an AWS S3 bucket
Convert the disk file form its existing format to VHD and upload it to the Amazon S3 bucket.

## Create container.json
Use the template below to create a file called `container.json` with the following content.
```
{
    "Description": "FreeBSD with ZFS",
    "Format": "vhd",
    "UserBucket": {
        "S3Bucket": "S3-BUCKET-NAME",
        "S3Key": "PATH-TO-VHD-FILE"
    }
}
```
This file is used to create a snapshot from the uploaded image.

## Import a snapshot
Run the following aws ec2 import snapshot command to import a snapshot of the container
```
aws ec2 import-snapshot --description "FreeBSD - ZFS" --disk-container file://container.json
```
Note down the `ImportTaskId`.
Run the following command to check on the snapshot import progress
```
aws ec2 describe-import-snapshot-tasks --import-task-id IMPORT-TASK-ID
```
Once the snapshot has been created note down the `SnapshotId` from the output.
## Create the block device mapping
Create a file called `block-device-mappings.json` with the following content
```
[
    {
        "DeviceName": "/dev/sda1",
        "Ebs": {
            "DeleteOnTermination": true,
            "SnapshotId": "SNAPSHOT-ID",
            "VolumeSize": 5
        }
    }
]
```

## Create the AMI image
Run the following command to create the AMI image
```
aws ec2 register-image --name freebsd-zfs --architecture x86_64 --root-device /dev/sda1 --block-device-mappings file://block-device-mappings.json --virtualization-type hvm --ena-support
```
Note down the AMI ID
