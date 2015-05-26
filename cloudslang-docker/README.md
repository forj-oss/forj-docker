# Introduction
This project will use [CloudSlang][1] to orchestrate docker to run a [docker registry 2.0][2] container on your cloud machine.

## Usage
The project is completely written by CloudSlang scripts. You can fire up the CloudSlang CLI and enter the following at the prompt to run this project:
```shell
run --f <folder path>/cloudslang-docker/main/build_registry2_container.sl \
    --cp <folder path>/cloudslang-docker/util,<folder path>/cloudslang-docker/ssh-docker-host \
    --i host_login_url=<host IP address>,host_login_username=<username>,host_login_identity_path=<private key path>, \
        host_registry_port=80,registry_container_base_storage_path=<path in container>,registry_host_local_storage_path=<path in host>,registry_http_proxy=<your proxy>,registry_https_proxy=<your proxy>,nginx_configs_path=<folder path>/cloudslang-docker/nginx-proxy-config
```

## Done
* We can run a docker registry 2.0 container on a cloud machine which has installed docker already
* We can detect whether docker registry 2.0 container is running on your cloud machine

## TODO
* Implement the function to integrate th command calls to run with rake CLI

#License
cloudslang-docker is licensed under the Apache License, Version 2.0.

[1]: http://cloudslang.io
[2]: https://github.com/docker/distribution
