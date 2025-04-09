echo "This script req 1 run time par. 1.Env repo name"
PROJECT_ID="$(gcloud config get-value project)" &&
gcloud config set project $PROJECT_ID &&
echo "Project set to $PROJECT_ID"
gcloud services enable container.googleapis.com cloudbuild.googleapis.com sourcerepo.googleapis.com containeranalysis.googleapis.com &&
echo "Enabled the required APIs."
gcloud source repos create $1		#$1 will be REPO_NAME
if [ $? -eq 0 ]
then
    echo "Created a repository name $1"
else
    echo "Repository might exists. Please check."
fi
git clone https://source.developers.google.com/p/$PROJECT_ID/r/$1
if [ $? -eq 0 ]
then
    echo "Clone Repo $1"
else
    echo "Folder already exists. Please check."
fi
cd $1
git checkout -b candidate
gsutil cp -r  /home/prasanth_naidu/cloudbuild.yaml .
gsutil cp -r /home/prasanth_naidu/kubernetes.yaml .
git add .
git commit -m "Create cloudbuild.yaml and kubernetes.yaml for deployment"
git push -u origin candidate
git checkout -b production
git push -u origin production
PROJECT_NUMBER="$(gcloud projects describe ${PROJECT_ID} --format='get(projectNumber)')"
gcloud projects add-iam-policy-binding ${PROJECT_NUMBER} --member=serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/container.developer
echo "Granted project access to IAM"
cat >/tmp/hello-cloudbuild-env-policy.yaml <<EOF
bindings:
- members:
  - serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com
  role: roles/source.writer
EOF
gcloud source repos set-iam-policy $1 /tmp/hello-cloudbuild-env-policy.yaml
echo "Granted the Source Repository Writer IAM role to the Cloud Build service account"
echo "Successfull!! Can proceed with next cloud build"
gcloud beta builds triggers create cloud-source-repositories --repo=$1 --branch-pattern="candidate" --build-config=cloudbuild.yaml
echo "Env Repo Triger has been setup!!"