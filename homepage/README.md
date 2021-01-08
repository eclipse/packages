Serve Homepage:

    JEKYLL_VERSION=4
    docker run --rm --volume="$PWD:/srv/jekyll:z" --volume="$PWD/vendor/bundle:/usr/local/bundle:z" -eJEKYLL_UID=$UID -p 4000:4000 -it docker.io/jekyll/jekyll:$JEKYLL_VERSION jekyll serve

On Windows:

    set JEKYLL_VERSION=4
    docker run --rm --volume="%CD%:/srv/jekyll" --volume="%CD%/vendor/bundle:/usr/local/bundle" -p 4000:4000 -it docker.io/jekyll/jekyll:%JEKYLL_VERSION% jekyll serve
