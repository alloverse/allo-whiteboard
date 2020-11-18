
# allo-whiteboard
A basic whiteboard app for use within an Alloverse Place.

# Develop and run

1. `apt install libcairo2 cmake luajit llvm`
2. `git submodule update --init --recursive`
3. `./allo/assist run alloplace://nevyn.places.alloverse.com`


#Docker

Run without extra params connects to nevyns place

`docker run -it allo-whiteboard`

Run with allo url to connect to specific place

`docker run -it allo-whiteboard alloplace://nevyn.places.alloverse.com`