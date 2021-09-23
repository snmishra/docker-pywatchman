# Python watchman Docker Image

Django's runserver works a lot more efficiently with [watchman](https://github.com/facebook/watchman) installed.

If you are using a virtualenv in your container you'll just need to run
`pip install /pywatchman/pywatchman-*.whl` from within your environment.

The images are built using Github Actions every once in a while and 
uploaded automatically to DockerHub
