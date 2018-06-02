import jenkins.*
import jenkins.model.*
import hudson.*
import hudson.model.*
import hudson.security.*

def userName = "metabox"
def userPassword = "metabox"

def log(msg) {
   println "\u001B[32mmetabox: user setup: ${msg}\u001B[0m"
}

Thread.start {
    sleep 10000
    
    def instance = Jenkins.getInstance();

    log "creating new realm for user: ${userName}"
    def hudsonRealm = new HudsonPrivateSecurityRealm(false);
    hudsonRealm.createAccount(userName, userPassword);

    instance.setSecurityRealm(hudsonRealm);
    instance.save();
    def strategy = new GlobalMatrixAuthorizationStrategy();

    log "adding new user..."
    strategy.add(Jenkins.ADMINISTER, userName);
    strategy.add(Jenkins.ADMINISTER, "admin");

    log "updating security..."
    instance.setAuthorizationStrategy(strategy);
    
    log "setup complete"
}