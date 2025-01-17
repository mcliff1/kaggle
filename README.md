# Kaggle

## Run in Co Lab

[Brownian Motion](https://colab.research.google.com/github/mcliff1/kaggle/blob/master/sandbox/Brownian%20Walk.ipynb)


[Probability Windows](https://colab.research.google.com/github/mcliff1/kaggle/blob/master/sandbox/probability%20windows.ipynb)

## Overview

This repo was dormant for almost a year, I used it once to manage refactoring some R code. Once again, I have a use and may as well use this repo;  this time I want to set up a flow where you can have a set of working notebooks as well as a 'persisted data' and working data area tied all together with a jupyter notebook.  This is exactly the functionality that Kaggle offers, however this repo will provide the scripts and tools to do this local or in the AWS cloud (and perhaps the Google cloud)

Remove CDK components, instead plan to use this to support ipy notebooks, with codelab, as well as kaggle api's


A runtime environment is expected to be running on a local filesystem with the following layout
```
ROOT/code/project1/
         /project2/
    /data/
    /work/
```

### Local Server Docker Workflow
In this flow docker is expected to be installed. If we are not modifying the persisted data sets we only need run steps 4-6

1. Choose a root filesystem
2. create the code, data and work folders (if necessary)
3. sync the s3 data to the local folder (if necessary)
4. run the git clone (or pull) from the code folder
5. execute `docker --rm 10000:8888 -p -v ROOT:/home/joyvan/work jupyter/scipy-notebook:17aba6048f44`
6. when done executing run git push
7. sync the local data folder back to s3 (if necessary)


To make this work with Kaggle you want to create a *input* as a sym-link one directory below the script folder pointing to the appropriate s3 data subfolder to enable a command like `open('../input/datafile.csv')`;   we should also create *output*

```
ROOT/code/project1/script.ipynb
    -s   /input -> ../data/project1
         /project2/
    /data/project1
         /project2/
    /work/
```

## Ad Tracker
[Talking Data Ad Tracker Fraud Detection Challenge](https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection)

To set up the *R Studio* work station, use Lauch Template **lt-015e347f2161b738b**, which uses AMI **ami-67a9de1f**. (May 2018)

 With this project, used the **LightGBM** method and **R**.  Using the Kaggle kernels I was only able to use *45 million* records. With 2 hours to go I am attempting to split this up onto server different machines.

the `light-parts.R` script will generate this over 45 million records using a AWS r3.xlarge machine (32GB RAM)
