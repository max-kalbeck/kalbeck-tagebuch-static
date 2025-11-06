# Digitale Edition des Tagebuchs von Max Kalbeck (1896–1897)


* data is fetched from https://github.com/max-kalbeck/kalbeck-tagebuch-data
* build with [DSE-Static-Cookiecutter](https://github.com/acdh-oeaw/dse-static-cookiecutter)

## dockerize your application

* To build the image run: `docker build -f docker/Dockerfile -t kalbeck-tagebuch-static .`
* To run the container: `docker run -p 80:80 --rm --name kalbeck-tagebuch-static kalbeck-tagebuch-static`

## Licenses

This project is released under the [MIT License](LICENSE)

### third-party JavaScript libraries
The code for all third-party JavaScript libraries used is included in the `html/vendor` folder, their respective licenses can be found either in a `LICENSE.txt` file or directly in the header of the `.js` file

### SAXON-HE
The projects also includes Saxon-HE, which is licensed separately under the Mozilla Public License, Version 2.0 (MPL 2.0). See the dedicated [LICENSE.txt](saxon/notices/LICENSE.txt)

