#!/bin/bash


#Sync library directories on sv5
rsync -a --exclude '*.gz' --exclude '*.zip' /export/libs1/ sv7:/libsync
rsync -a --exclude '*.gz' --exclude '*.zip' /export/libs/tsmc/016nm sv7:/libsync
