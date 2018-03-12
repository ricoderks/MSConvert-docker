# Installation

You need to have a installed and running docker environment and be a member of the `docker` group.

1. Get this repo
```
git clone https://github.com/ricoderks/MSConvert-docker
cd MSConvert-docker
```

2. Create the container image
```
docker build --rm -t msconvert .
```

3. To convert a file:

Bruker -> mzXML example:

`docker run --rm -v $HOME:/data msconvert ./Sample_4512.d -o ./ --mzXML --64 --zlib --filter "peakPicking true 1-" --filter "msLevel 1-"`

Sciex -> mzXML example:

`docker run --rm -v $HOME:/data msconvert ./Sample_4512.wiff -o ./ --mzXML --64 --zlib --filter "peakPicking true 1-" --filter "msLevel 1-"`

Replace $HOME by the name of the folder where your raw data is.

Thermo:

Unfortunately RAW files from Thermo fail.

# Acknowledgements

I would like to thank the guys how did the hard work : Steffen Neumann (@sneumann) and Rene Meier (@meier-rene). 
