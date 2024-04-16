/*
Sample Terraform.tfvars file

Remove the comment characters and add your values

Note that the EVENT_TYPES environmental variable should follow the exact pattern depicted below - i.e a space after the commas

The storage bucket's storage class is set by default to 'STANDARD' and the Region and Zone is set by default to northamerica-northeast1 and northamerica-northeast1-a repectively

You can change this default values here
*/

project_id = "log-collector-420416"
cloud_storage_bucket = "sf-log-bucket"
storage_class = "STANDARD"
secrets_project_id = "log-collector-420416"
region = "northamerica-northeast1"
repo_name = "sf_repo"
zone = "northamerica-northeast1-a"
secret_id = "salesforce-log-collector-secret"
env = {    
    "GOOGLE_PROJECT_ID" = "log-collector-420416"  
    "CLIENT_ID" = "3MVG9M43irr9JAuzzDZiDMO2XlC1gz2Ok22vBnK5Nj6yZLocN0QnP5jc4joSXeusrlwO.JQ_qsSW09fiDvJNW"    
    "AUDIENCE" = "https://test.salesforce.com"     
    "SUBJECT" = "log.collector@cogeco.com.epccpq1"    
    "SECRET_ID" = "salesforce-log-collector-secret"    
    "CLOUD_STORAGE_BUCKET" = "sf-log-bucket"    
    "TOKEN_ENDPOINT" = "https://test.salesforce.com/services/oauth2/token"    
    "GOOGLE_SECRETS_PROJECT_ID" = "log-collector-420416"    
    "EVENT_TYPES" = "Login, Logout, URI, RestApi, API, Report, ReportExport, BulkApi, BulkApi2, LoginAs"
    }  


