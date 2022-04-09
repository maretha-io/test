# These environment values must be set:
# export NUXEO_USER=Administrator
# export NUXEO_PASSWORD=Administrator
# export NUXEO_HOST=http://localhost:8080
# export EXPORT_DIR=/tmp/export/directories

if [ -z "$NUXEO_USER" ]; then
	echo "NUXEO_USER environment variable must be set";
	exit 1
fi

if [ -z "$NUXEO_PASSWORD" ]; then
	echo "NUXEO_PASSWORD environment variable must be set";
	exit 1
fi

if [ -z "$NUXEO_HOST" ]; then
	echo "NUXEO_HOST environment variable must be set";
	exit 1
fi

if [ -z "$EXPORT_DIR" ]; then
	echo "EXPORT_DIR environment variable must be set";
	exit 1
fi

mkdir -p $EXPORT_DIR
rm $EXPORT_DIR/*.csv

# - Gets a list of directories from the ExportListOperation operation
# - Parses the list using grep
# - Then loops through the directory names to export a csv for each directory one at a time

curl --location --request POST -u "$NUXEO_USER:$NUXEO_PASSWORD" "$NUXEO_HOST/nuxeo/api/v1/automation/VocabularyDirectories.ExportListOperation" \
--header 'Content-Type: application/json' \
--header 'Accept-Encoding: application/json' \
--data-raw '{}' \
| grep -oe '\[.*\]' \
| egrep -o '[0-9a-zA-Z_]+' \
| while read name; do
	echo "exporting directory $name..."
	curl --location --request POST -u "$NUXEO_USER:$NUXEO_PASSWORD" "$NUXEO_HOST/nuxeo/api/v1/automation/VocabularyDirectories.ExportOperation" \
    -o /dev/null -s -w "%{http_code}\n" \
    --header 'Content-Type: application/json' \
    --header 'Accept-Encoding: application/json' \
    --data-raw "{\"params\":{\"directory\":\"$name\",\"destination\":\"$EXPORT_DIR\"},\"context\":{}}"
	echo
done

