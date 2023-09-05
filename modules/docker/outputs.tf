output "sfelc_docker_image" {
    value = docker_image.sfelc_image.name
    description = "sfelc cloud Run Job Docker Image"
}

output "sfatc_docker_image" {
    value = docker_image.sfatc_image.name
    description = "sfatc cloud Run Job Docker Image"
}