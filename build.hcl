variable "DOCKER_ORG" {
  default = "erriez"
}
variable "DOCKER_PREFIX" {
  default = ""
}
variable "IMAGE_VERSION" {
  default = "local"
}

group "default" {
  targets = [
    "samba",
    "avahi",
    "wsdd"
  ]
}

target "defaults" {
  platforms = [ "linux/amd64", "linux/arm64" ]
  dockerfile="Dockerfile"
}

function "tag" {
  params = [image_name]
  result = "${DOCKER_ORG}/${DOCKER_PREFIX}${image_name}:${IMAGE_VERSION}"
}

target "samba" {
  inherits = ["defaults"]
  context = "samba"
  tags = [ tag("samba") ]
}

target "avahi" {
  inherits = ["defaults"]
  context = "avahi"
  tags = [ tag("avahi") ]
}

target "wsdd" {
  inherits = ["defaults"]
  context = "wsdd"
  tags = [ tag("wsdd") ]
}
