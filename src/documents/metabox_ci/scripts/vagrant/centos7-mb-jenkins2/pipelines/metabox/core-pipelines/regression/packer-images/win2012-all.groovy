node("metabox") {

    // metabox system init - start
    def mbSrcPath           = env.METABOX_SRC_PATH == null ? "src" : env.METABOX_SRC_PATH;
    def mbVagrantBuildPath  = env.METABOX_VAGRANT_BUILD_DIR 
    def mbUtils             = load "$mbVagrantBuildPath/scripts/vagrant/centos7-mb-jenkins2/pipelines_shared/metabox-utils.groovy"
    // metabox system init - end
    
    mbUtils.runMetaboxPrepareStages(mbSrcPath);
    
    mbUtils.runMetaboxPackerBuild(mbSrcPath, "win2012-mb-soe");
    mbUtils.runMetaboxPackerBuild(mbSrcPath, "win2012-mb-app");
    mbUtils.runMetaboxPackerBuild(mbSrcPath, "win2012-mb-bin-sp13");
}