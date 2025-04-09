# Set your Falcon Client ID & Secret
export FALCON_CLIENT_ID=a6a99bbd4f244b66824f51585000b732
export FALCON_CLIENT_SECRET=NBSnMJy4ftIQ8ald13YFKs2qwrHGE7L9eu5ck6T0
 
# Get the Falcon Sensor image details
# This will pull the most recent falcon KAC
export FALCON_CID=$( ./falcon-container-sensor-pull.sh -t falcon-kac --get-cid )
export FALCON_KAC_IMAGE_FULL_PATH=$(./falcon-container-sensor-pull.sh -t falcon-kac --get-image-path )
export FALCON_KAC_IMAGE_REPO=$( echo $FALCON_KAC_IMAGE_FULL_PATH | cut -d':' -f 1 )
export FALCON_KAC_IMAGE_TAG=$( echo $FALCON_KAC_IMAGE_FULL_PATH | cut -d':' -f 2 )
export FALCON_IMAGE_PULL_TOKEN=$( ./falcon-container-sensor-pull.sh -t falcon-kac --get-pull-token )
 
# Deploy the KAC
helm repo add crowdstrike https://crowdstrike.github.io/falcon-helm --force-update
 
helm upgrade --install falcon-kac crowdstrike/falcon-kac \
    -n falcon-kac --create-namespace \
    --set falcon.cid=$FALCON_CID \
    --set image.repository=$FALCON_KAC_IMAGE_REPO \
    --set image.tag=$FALCON_KAC_IMAGE_TAG \
    --set image.registryConfigJSON=$FALCON_IMAGE_PULL_TOKEN