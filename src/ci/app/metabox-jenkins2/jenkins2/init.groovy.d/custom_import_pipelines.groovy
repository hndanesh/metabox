import jenkins.*
import jenkins.model.*
import hudson.*
import hudson.model.*
import hudson.security.*
import org.jenkinsci.plugins.workflow.job.WorkflowJob

import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import hudson.plugins.git.GitSCM
import org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition

import groovy.io.FileType

def defaultPipelineFolderPath() {
    return "/app/jenkins2/pipelines"
} 

def log(msg) {
   println "\u001B[32mMETABOX: pipeline import: ${msg}\u001B[0m"
}

def getPipelineFolderPath() {

    def env = System.getenv()
    def result = env['METABOX_PIPELINES_FOLDER']

    if(result == null) {
        log "using default pipeline folder path: ${defaultPipelineFolderPath()}"
        result = defaultPipelineFolderPath()
    } else {
        log "using custom pipeline folder path from ENV var 'METABOX_PIPELINES_FOLDER': ${defaultPipelineFolderPath}"
    }
   
    return result
}

def getPipelineFiles() {

    log "fetching pipeline files..."

    def result = []
    def pipelineFolderPath = getPipelineFolderPath()

    def dir = new File(pipelineFolderPath)
    dir.eachFileRecurse (FileType.FILES) { file ->
        result << file
    }

    return result
}

def getOrCreateNewProject(name, script) {
 
    log "creating new pipeline with name: ${name}"

   def result = null
  
   Jenkins.instance.getAllItems().each {it ->
    if(it.fullName == name) {
     	result = it
      
    }
  }
  
  if(result == null) {
    result = Jenkins.instance.createProject(WorkflowJob, name)
  }
  
  def flow = new CpsFlowDefinition(script, true)
  result.definition = flow
  
  return result
}

def importPipelines(files) {
    files.each { file ->
        def fileContent = new File(file.path).text
        def fileName = file.name.take(file.name.lastIndexOf('.'))

        getOrCreateNewProject(fileName, fileContent)
    }
}

Thread.start {
    sleep 20000
    
    log "tricking the system!"
    println ACL.impersonate(User.get("METABOX").impersonate())

    log "importing pipelines..."
    def pipelineFiles = getPipelineFiles()
    importPipelines(pipelineFiles)

    log "importing pipelines completed!"
}