Serve Homepage:

    JEKYLL_VERSION=4
    docker run --rm --volume="$PWD:/srv/jekyll:z" -eJEKYLL_UID=$UID -p 4000:4000 -it jekyll/jekyll:$JEKYLL_VERSION jekyll serve -b /packages
