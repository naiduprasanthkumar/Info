# Set your Falcon Client ID & Secret
export FALCON_CLIENT_ID=a6a99bbd4f244b66824f51585000b732
export FALCON_CLIENT_SECRET=NBSnMJy4ftIQ8ald13YFKs2qwrHGE7L9eu5ck6T0
# Get the Falcon Sensor image details
# This will pull the most recent falcon sensor
export FALCON_CID=$( ./falcon-container-sensor-pull.sh -t falcon-sensor --get-cid )
export FALCON_IMAGE_FULL_PATH=$( ./falcon-container-sensor-pull.sh -t falcon-sensor --get-image-path )
export FALCON_IMAGE_REPO=$( echo $FALCON_IMAGE_FULL_PATH | cut -d':' -f 1 )
export FALCON_IMAGE_TAG=$( echo $FALCON_IMAGE_FULL_PATH | cut -d':' -f 2 )
export FALCON_IMAGE_PULL_TOKEN=$( ./falcon-container-sensor-pull.sh -t falcon-sensor --get-pull-token )
# --list-tags parameter can be used to view available versions. Need Only When we get new update.
./falcon-container-sensor-pull.sh -t falcon-sensor --list-tags 
# Deploy the Daemonset
helm repo add crowdstrike https://crowdstrike.github.io/falcon-helm --force-update
helm upgrade --install falcon-sensor crowdstrike/falcon-sensor \
    -n falcon-system --create-namespace \
    --set falcon.cid="$FALCON_CID" \
    --set node.image.repository="$FALCON_IMAGE_REPO" \
    --set node.image.tag="$FALCON_IMAGE_TAG" \
    --set node.image.registryConfigJSON="$FALCON_IMAGE_PULL_TOKEN" \
    --set node.backend="bpf"