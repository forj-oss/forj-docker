The files in this folder are for purposes of demo / testing only.
Actual blueprint files should live in the blueprint repository
that is delivering the blueprint.  The folder structure here
might be used to clone those blueprint projects for build and test.


Structure:

 --- Root \
          -- docker \
                   -- <blueprint name> \
                                     -- <container name>

Ideas for what should be found in the <container name> folder
* a Docker.name file that implements the creation of the container.
* a VERSION file that containers a semantic version number.
* a meta tag in the Docker.name file called DOCKER-NAME to provide
  a name for the docker container.  Replace VERSION keyword with actual
  contents of the version file in this string.
  
