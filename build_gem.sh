
if [[ -z $APPVEYOR_BUILD_NUMBER ]] ; then 
    APPVEYOR_BUILD_NUMBER=1000
    echo 'Running locally. Set APPVEYOR_BUILD_NUMBER=$APPVEYOR_BUILD_NUMBER' 
else 
    echo "Running under CI" ; 
fi

if [ "$1" == "--install" ] ; then 
    INSTALL_GEM=1
fi

function validate_exit_code()
{
    CODE=$1
    MGS=$2
 
    [ $CODE -eq 0 ] && echo "   [+] exit code is 0, continue..."
    [ $CODE -ne 0 ] && echo "   [-] exiting with non-zero code [$CODE] - $MGS" && exit $CODE
}

function patch_gemfile() {
    
    echo "Patching file  : $GEM_VERSION_FILE"
    
    sed -i "/VERSION/c\ VERSION=\"${GEM_VERSION}\"" $GEM_VERSION_FILE
    validate_exit_code $? "Cannot update gemfile: $GEM_VERSION_FILE"
}

function cat_gemfile() {
    echo "Showing file: $GEM_VERSION_FILE"
    cat $GEM_VERSION_FILE
}

function cleanup_old_gems() {
    echo 'Cleanin up previous gems..'
    rm -rf ./src/metabox/*.gem
}

function build_gem() {
    

    echo "Building gem..."
    sh -c "cd $GEM_FOLDER && gem build *.gemspec"

    validate_exit_code $? "Cannot build gem in folder: $GEM_FOLDER"
}

function prepare_build_folder() {
    echo "Creating build dir: $BUILD_DIR"
    mkdir -p $BUILD_DIR
    validate_exit_code $? "Cannot create folder: $BUILD_DIR"

    echo "Cleaning up build dir: $BUILD_DIR"
    rm -rf $BUILD_DIR/*
    validate_exit_code $? "Cannot cleanup folder: $BUILD_DIR"
}

function copy_gem_to_build_folder() {
    echo "Copying 'latest' gem to build dir: $BUILD_DIR"
    
    cp ./src/metabox/*.gem $BUILD_DIR/
    validate_exit_code $? "Cannot copy latest gem to folder: $BUILD_DIR"

    echo "Copying 'metabox-nightly.gem' to build dir: $BUILD_DIR"
    cp ./src/metabox/metabox-0*.gem $BUILD_DIR/metabox-nightly.gem
    validate_exit_code $? "Cannot copy nighly gem to folder: $BUILD_DIR"
}

BUILD_DIR=.build
GEM_FOLDER="./src/metabox"

GEM_VERSION="0.2.3.${APPVEYOR_BUILD_NUMBER}"
GEM_VERSION_FILE=./src/metabox/lib/metabox/version.rb

echo "Bulding gem version: $GEM_VERSION"

patch_gemfile
cat_gemfile

cleanup_old_gems
build_gem

prepare_build_folder
copy_gem_to_build_folder

echo "Completed build!"


if [ $INSTALL_GEM ] ; then 
    GEM_PATH="$BUILD_DIR/metabox-nightly.gem"

    echo "Unisntalling metabox gem -v $GEM_VERSION"
    gem uninstall metabox -v $GEM_VERSION --force -x

    echo "Installing latest gem: $GEM_PATH"
    gem install --local $GEM_PATH --no-ri --no-rdoc --force
    
    validate_exit_code $? "Cannot install nighly gem: $BUILD_DIR"

    echo "Completed install!"
fi

exit 0