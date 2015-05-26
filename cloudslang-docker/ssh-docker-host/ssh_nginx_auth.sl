namespace: cloudslang-docker.ssh-docker-nginx

operation:
  name: ssh_docker_run_nginx_container
  inputs:
    - host
    - port:
        default: "'22'"
    - username
    - privateKeyFile
    - local_config_path:
        default: "'~/nginx-proxy-config/nginx'"
    - local_cert_path:
        default: "'~/nginx-proxy-config/demo-certs'" 
    - http_proxy:
        default: "''"
    - https_proxy:
        default: "''"
    - registry_container:
        default: "'registry2'"
    - command:
        default: "'docker run -d -p 443:443 --link registry2:docker-registry -v ' + local_config_path + ':/etc/nginx -v ' + local_cert_path + ':/etc/ssl/docker -e http_proxy=' + http_proxy + ' -e https_proxy=' + https_proxy + ' -e HTTP_PROXY=' + http_proxy + ' -e HTTPS_PROXY=' + https_proxy + ' --name nginx_auth h3nrik/nginx-ldap:latest'"
        overridable: false
    - arguments:
        default: "''"
    - characterSet:
        default: "'UTF-8'"
    - pty:
        default: "'false'"
    - timeout:
        default: "'30000000'"
    - closeSession:
        default: "'false'"
  action:
    java_action:
      className: io.cloudslang.content.ssh.actions.SSHShellCommandAction
      methodName: runSshShellCommand
  outputs:
    - nginx_container_ID: returnResult
    - nginx_error_message: "'' if 'STDERR' not in locals() else STDERR if returnCode == '0' else ''"
  results:
    - RUNNING: returnCode == '0' and (not 'Error' in STDERR)
    - ERROR_RESULT
