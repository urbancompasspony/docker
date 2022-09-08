Tutorial inspired by Fmstrat, the same base code to run the file 02-samba-ad-dc on this repository.
All Credits goes to him! Thanks so much.
https://github.com/Fmstrat/samba-domain

To create a Custom Image, create a folder called "build", inside create 2 files:

- Dockerfile
- init.sh

Dockerfile has instructions to select an image, for example ubuntu:latest, environment, apt install packages and in the end will catch the .init.sh file.

This init.sh file is an script that will auto-load when "docker run this_image" parsing parameters when calling.

To build, open terminal

$ cd build

$ docker build -t samba-domain .
