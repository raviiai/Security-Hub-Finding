# #!/bin/bash

# # Get a list of all S3 buckets
# buckets=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text)

# # Loop through each bucket
# echo "***********************************************"
# echo "List of All S3 Bucket with versioning Disabled"
# echo "***********************************************"
# for bucket in $buckets; do
#     versioning=$(aws s3api get-bucket-versioning --bucket $bucket --query 'Status' --output text)
#     if [[ $versioning != "Enabled" ]]; then
#         echo "=>: $bucket"
#         echo "-------"
#     fi
# done


#!/bin/bash

# Get a list of all S3 buckets
buckets=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text)

# CSV file name
csv_file="s3_buckets_with_disabled_versioning.csv"

# Create CSV file with headers
echo "Bucket Name" > $csv_file

# Loop through each bucket
for bucket in $buckets; do
    versioning=$(aws s3api get-bucket-versioning --bucket $bucket --query 'Status' --output text)
    if [[ $versioning != "Enabled" ]]; then
        echo "=>: $bucket : Versioning Disabled..."
        echo "---------"
        echo "$bucket" >> $csv_file
    fi
done

echo "Exported to CSV file '$csv_file'."
