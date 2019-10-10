
## Building

The homepage is built with [Hugo](https://gohugo.io). Simply run:

    cd homepage
    hugo

## Updating dependencies

The web, endless dependencies, … in order to avoid JavaScript-dependency-hell, only Bootstrap, Popper and jQuery are
being used at the moment. And they are downloaded with `curl`, orchestrated using a `Makefile`. Change the versions
in the Makefile, and then run:

    cd homepage
    make clean
    make fetch
