
if [[ -z $APPVEYOR_BUILD_NUMBER ]] ; then 
    APPVEYOR_BUILD_NUMBER=1000
    echo 'Running locally. Set APPVEYOR_BUILD_NUMBER=$APPVEYOR_BUILD_NUMBER' 
else 
    echo "Running under CI" ; 
fi

GEM_VERSION="0.2.3.${APPVEYOR_BUILD_NUMBER}"
GEM_VERSION_FILE=./src/metabox/lib/metabox/version.rb

echo "Bulding version: $GEM_VERSION"
echo "Patching file  : $GEM_VERSION_FILE"

sed -i "/VERSION/c\ VERSION=\"${GEM_VERSION}\"" $GEM_VERSION_FILE

echo "Showing file: $GEM_VERSION_FILE"
cat $GEM_VERSION_FILE

echo "Building gem..."
sh -c 'cd ./src/metabox && gem build *.gemspec'

RETVAL=$?
[ $RETVAL -eq 0 ] && echo "All good!"
[ $RETVAL -ne 0 ] && echo "Can't build gem, exit code was: $RETVAL" && exit $RETVAL

exit 0