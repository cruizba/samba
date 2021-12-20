[![logo](https://raw.githubusercontent.com/erriez/samba/master/logo.jpg)](https://www.samba.org)

# Samba

Samba docker container, derived from `dperson/samba`:

- Updated images with `alpine:3.15` to fix critical vulnerabilities.
- Update `docker-compose.yml` according updated Docker formatting.
- Add Windows Network Discovery example with WSDD
- Add Linux Network Discovery example with Avahi
- Add multiarchitecture `buildx` support.
- AMD64, ARM64, ARMv6 and ARMv7 images on [DockerHub](https://hub.docker.com/r/erriez/samba)

# What is Samba?

Since 1992, Samba has provided secure, stable and fast file and print services
for all clients using the SMB/CIFS protocol, such as all versions of DOS and
Windows, OS/2, Linux and many others.

# How to use this image

By default there are no shares configured, additional ones can be added.

## Hosting a Samba instance

    sudo docker run -it -p 139:139 -p 445:445 -d erriez/samba:latest -p

OR set local storage:

    sudo docker run -it --name samba -p 139:139 -p 445:445 \
                -v /path/to/directory:/mount \
                -d erriez/samba:latest -p

## Configuration

    sudo docker run -it --rm erriez/samba -h
    Usage: samba.sh [-opt] [command]
    Options (fields in '[]' are optional, '<>' are required):
        -h          This help
        -c "<from:to>" setup character mapping for file/directory names
                    required arg: "<from:to>" character mappings separated by ','
        -G "<section;parameter>" Provide generic section option for smb.conf
                    required arg: "<section>" - IE: "share"
                    required arg: "<parameter>" - IE: "log level = 2"
        -g "<parameter>" Provide global option for smb.conf
                    required arg: "<parameter>" - IE: "log level = 2"
        -i "<path>" Import smbpassword
                    required arg: "<path>" - full file path in container
        -n          Start the 'nmbd' daemon to advertise the shares
        -p          Set ownership and permissions on the shares
        -r          Disable recycle bin for shares
        -S          Disable SMB2 minimum version
        -s "<name;/path>[;browse;readonly;guest;users;admins;writelist;comment]"
                    Configure a share
                    required arg: "<name>;</path>"
                    <name> is how it's called for clients
                    <path> path to share
                    NOTE: for the default values, just leave blank
                    [browsable] default:'yes' or 'no'
                    [readonly] default:'yes' or 'no'
                    [guest] allowed default:'yes' or 'no'
                    NOTE: for user lists below, usernames are separated by ','
                    [users] allowed default:'all' or list of allowed users
                    [admins] allowed default:'none' or list of admin users
                    [writelist] list of users that can write to a RO share
                    [comment] description of share
        -u "<username;password>[;ID;group;GID]"       Add a user
                    required arg: "<username>;<passwd>"
                    <username> for user
                    <password> for user
                    [ID] for user
                    [group] for user
                    [GID] for group
        -w "<workgroup>"       Configure the workgroup (domain) samba should use
                    required arg: "<workgroup>"
                    <workgroup> for samba
        -W          Allow access wide symbolic links
        -I          Add an include option at the end of the smb.conf
                    required arg: "<include file path>"
                    <include file path> in the container, e.g. a bind mount

    The 'command' (if provided and valid) will be run instead of samba

ENVIRONMENT VARIABLES

 * `CHARMAP` - As above, configure character mapping
 * `GENERIC` - As above, configure a generic section option (See NOTE3 below)
 * `GLOBAL` - As above, configure a global option (See NOTE3 below)
 * `IMPORT` - As above, import a smbpassword file
 * `NMBD` - As above, enable nmbd
 * `PERMISSIONS` - As above, set file permissions on all shares
 * `RECYCLE` - As above, disable recycle bin
 * `SHARE` - As above, setup a share (See NOTE3 below)
 * `SMB` - As above, disable SMB2 minimum version
 * `TZ` - Set a timezone, IE `Europe/Amsterdam`
 * `USER` - As above, setup a user (See NOTE3 below)
 * `WIDELINKS` - As above, allow access wide symbolic links
 * `WORKGROUP` - As above, set workgroup
 * `USERID` - Set the UID for the samba server's default user (smbuser)
 * `GROUPID` - Set the GID for the samba server's default user (smbuser)
 * `INCLUDE` - As above, add a smb.conf include

**NOTE**: if you enable nmbd (via `-n` or the `NMBD` environment variable), you
will also want to expose port 137 and 138 with `-p 137:137/udp -p 138:138/udp`.

**NOTE2**: there are reports that `-n` and `NMBD` only work if you have the
container configured to use the hosts network stack.

**NOTE3**: optionally supports additional variables starting with the same name,
IE `SHARE` also will work for `SHARE2`, `SHARE3`... `SHAREx`, etc.

## Examples

Any of the commands can be run at creation with `docker run` or later with
`docker exec -it samba samba.sh` (as of version 1.3 of docker).

### Setting the Timezone

    sudo docker run -it -e TZ=Europe/Amsterdam -p 139:139 -p 445:445 -d erriez/samba:latest -p

### Start an instance creating users and shares:

    sudo docker run -it -p 139:139 -p 445:445 -d erriez/samba:latest -p \
                -u "example1;badpass" \
                -u "example2;badpass" \
                -s "public;/share" \
                -s "users;/srv;no;no;no;example1,example2" \
                -s "example1 private share;/example1;no;no;no;example1" \
                -s "example2 private share;/example2;no;no;no;example2"

# Network discovery

Windows and Linux no longer displays the Samba file-server in file managers by running the Samba
Docker container only. To get this functionality back in Windows Explorer and Ubuntu Nautilus for
example, two additional Docker containers can be started. An example is available in 
[docker-compose.yml](https://github.com/Erriez/docker-samba/blob/master/docker-compose.yml).

## Windows Explorer Network Discovery

Windows dropped NetBIOS Network discovery. As a result, the Samba file-server is no longer available
in `Windows Explorer | Network`. An additional `WSDD` (Web Service Discovery Daemon) Docker container
can be started to get this functionality back. 

**Note:** This container requires `--net=host` access.

## Linux Network Discovery

Also Ubuntu no longer displays the Samba file-server in `Nautilus | Other Locations` and 
possible other Linux OS'es and file managers. An additional `Avahi` Docker container can be started
to get this functionality back.

`sudo apt install smbclient` is required on some distributions.

**Note:** This container requires `--net=host` access.

# Build image via Dockerfile

Run the following command to build an image on a local machine via Dockerfile:

```bash
docker build -t <username>/samba:<tag> .

# For example:
docker build -t erriez/samba:latest .
```

# Run containers via docker-compose.yml

Run the following commands to run Samba or all containers:

```bash
# Run Samba, Avahi and WSDD containers
$ docker-compose up

# Run Samba container only
$ docker-compose up samba
```

Optionally, build images on a local machine via `docker-compose.yml` by uncomment lines `build: .` in 
`docker-compose.yml` followed by `docker-compose build` command.

# Multi-architecture build

The following commands can be used to build multiarchitecture Samba images with `docker buildx`:

```bash
# Docker installation Ubuntu https://docs.docker.com/engine/install/ubuntu/
$ sudo apt-get remove docker docker-engine docker.io containerd runc
$ sudo apt-get update
$ sudo apt-get install ca-certificates curl gnupg lsb-release
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
$ sudo apt-get update
$ sudo apt-get install docker-ce docker-ce-cli containerd.io

# Install buildkit_qemu_emulator
$ docker run -it --rm --privileged tonistiigi/binfmt --install all

# Create new builder instance (one time)
$ docker buildx create --use mybuild

# Build image for AMD64, ARM64, ARMv6 and ARMv7 and push to DockerHub
# Note, to test fist, replace --push with --load and remove --platform argument to build for current platform
$ docker login

$ docker buildx build --push --platform linux/amd64,linux/arm64,linux/arm/v6,linux/arm/v7 -t <username>/samba:<tag> samba/

# Optional for Linux discovery:
$ docker buildx build --push --platform linux/amd64,linux/arm64,linux/arm/v6,linux/arm/v7 -t <username>/avahi:<tag> avahi/

# Optional for Windows discovery:
$ docker buildx build --push --platform linux/amd64,linux/arm64,linux/arm/v6,linux/arm/v7 -t <username>/wsdd:<tag> wsdd/
```

# User Feedback

## Troubleshooting

* You get the error `Access is denied` (or similar) on the client and/or see
`change_to_user_internal: chdir_current_service() failed!` in the container
logs.

Add the `-p` option to the end of your options to the container, or set the
`PERMISSIONS` environment variable.

    sudo docker run -it --name samba -p 139:139 -p 445:445 \
                -v /path/to/directory:/mount \
                -d erriez/samba:latest -p

If changing the permissions of your files is not possible in your setup you
can instead set the environment variables `USERID` and `GROUPID` to the
values of the owner of your files.

* High memory usage by samba. Multiple people have reported high memory usage
that's never freed by the samba processes. Recommended work around below:

Add the `-m 512m` option to docker run command, or `mem_limit:` in
docker_compose.yml files, IE:

    sudo docker run -it --name samba -m 512m -p 139:139 -p 445:445 \
                -v /path/to/directory:/mount \
                -d erriez/samba:latest -p

* Attempting to connect with the `smbclient` commandline tool. By default samba
still tries to use SMB1, which is depriciated and has security issues. This
container defaults to SMB2, which for no decernable reason even though it's
supported is disabled by default so run the command as `smbclient -m SMB3`, then
any other options you would specify.

## Issues

If you have any problems with or questions about this image, please contact me
through a [GitHub issue](https://github.com/erriez/samba/issues).