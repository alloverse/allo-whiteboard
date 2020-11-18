FROM debian:stretch

WORKDIR /app

# alpine
# RUN apk add --no-cache bash cairo cmake luajit llvm

#debian
RUN apt-get update && apt-get install -y \
   # build-essential \
    libcairo2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
# debian; libcairo does not match expected name so symlink it
RUN ln -s /usr/lib/x86_64-linux-gnu/libcairo.so.2 /usr/lib/x86_64-linux-gnu/libcairo.so

ADD . /app/

ENTRYPOINT [ "./allo/assist", "run" ]
CMD [ "alloplace://nevyn.places.alloverse.com" ]