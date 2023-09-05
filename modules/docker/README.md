## Terraform Docker Module

 - Builds docker images.

 - Sets a trigger argument that causes the docker image to be rebuilt when the source code changes.

 - Pushes the docker images to Google Artifact Registry.

 - Provides the names of the docker images in 'outputs.tf' for consumption by the Cloud Run instances defined in the serverless module.