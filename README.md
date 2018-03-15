# Installation

You need to have a installed and running docker environment and be a member of the `docker` group.

1. Get this repo
```
git clone https://github.com/ricoderks/MSConvert-docker
cd MSConvert-docker
```

2. Create the container image
```
docker build --rm -t msconvert-gui .
```

3. Run the container :

`docker run --rm -v /tmp/.X11-unix:/tmp/.X11-unix:rw -v $HOME:/data:rw msconvertgui`

Replace $HOME by the name of the folder where your raw data is.

# Acknowledgements

I would like to thank the guys how did the hard work : Steffen Neumann (@sneumann) and Rene Meier (@meier-rene). 
