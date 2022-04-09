# These environment values must be set:
# export NUXEO_USER=Administrator
# export NUXEO_PASSWORD=Administrator
# export NUXEO_HOST=http://localhost:8080
# export IMPORT_DIR=/tmp/import/directories
# export DATA_LOADING_POLICY=skip_duplicate

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

if [ -z "$IMPORT_DIR" ]; then
	echo "IMPORT_DIR environment variable must be set";
	exit 1
fi

if [ -z "$DATA_LOADING_POLICY" ]; then
	$DATA_LOADING_POLICY=skip_duplicate
	echo "DATA_LOADING_POLICY not set. Defaulting to $DATA_LOADING_POLICY";
fi

for f in $IMPORT_DIR/*.csv; do
	dirname=$(basename "$f" | awk '{split($0,a,"."); print a[1]}')
	echo "Importing $dirname from $f"
	curl -XPOST -u "$NUXEO_USER:$NUXEO_PASSWORD" -F "request={\"params\":{\"directoryName\":\"$dirname\", \"dataLoadingPolicy\":\"$DATA_LOADING_POLICY\"}, \"context\":{}}" -F "input=@\"$f\"" "$NUXEO_HOST/nuxeo/api/v1/automation/Directory.LoadFromCSV"
	echo
done
