+++

title = "x86 Build in M1 Mac"
date = "2024-01-31"
draft = false

[taxonomies]
tags = ["build", "docker", "x86"]
categories = ["Today I Learned", "Docker"]


[extra]
lang = "en"
toc = false

+++

Building docker images with the flag `--platform linux/amd64` allows you to create x86 images using docker

Which platform am I on?

```
> gcc -dumpmachine
arm64-apple-darwin23.2.0
```

#### Let's run an image to enter the x86 world

```bash
> docker run -it --platform=linux/amd64 gcc:13.2.0 /bin/bash
(inside docker container)> gcc -dumpmachine
x86_64-linux-gnu
```

#### When to use this?

This is helpful to build cross platform images. i.e. in Elixir you can create a binary file with `mix release` however it only targets the current platform target triple. As my server runs on `linux/amd64` I would have to build the code again rather than just copying over the binary file. Hence, I use this script to build the binary for the x86 platform and copy over the binary file only.

