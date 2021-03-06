#!/bin/bash
#
# Mini-ImageNet.
#

IMAGENET_URL=http://www.image-net.org/challenges/LSVRC/2012/nnoupb/ILSVRC2012_img_train.tar

set -e

mkdir tmp
trap 'rm -r tmp' EXIT

if [ ! -d data ]; then
    mkdir data
fi

if [ ! -d data/miniimagenet ]; then
    mkdir tmp/miniimagenet
    for subset in train test val; do
        mkdir "tmp/miniimagenet/$subset"
        echo "Fetching Mini-ImageNet $subset set ..."
        for csv in $(ls metadata/miniimagenet/$subset); do
            echo "Fetching wnid: ${csv%.csv}"
            dst_dir="tmp/miniimagenet/$subset/${csv%.csv}"
            mkdir "$dst_dir"
            for entry in $(cat metadata/miniimagenet/$subset/$csv); do
                name=$(echo "$entry" | cut -f 1 -d ,)
                range=$(echo "$entry" | cut -f 2 -d ,)
                curl -s -H "range: bytes=$range" $IMAGENET_URL > "$dst_dir/$name" &
            done
            wait
        done
    done
    mv tmp/miniimagenet data/miniimagenet
    mv data/miniimagenet/val/* data/miniimagenet/test/
fi
