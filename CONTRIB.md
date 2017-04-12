
# FusionInventory Agent Contribs

## Included contribs

 * [Yum-plugin](contrib/yum-plugin) by @remicollet, see [INSTALL](contrib/yum-plugin/INSTALL)
 * [Unix](contrib/unix):
   * legacy Debian and Redhat init scripts
   * systemd sample service file
 * [Windows](contrib/windows):
   * [fusioninventory-agent-deployment.vbs](contrib/windows/fusioninventory-agent-deployment.vbs):
     FusionInventory Agent deployment helper script
   * ADML & ADMX templates to help setup FusionInventory Agent through GPO

## Other contribs

 * [fusioninventory-agent-deployment.vbs](contrib/windows/fusioninventory-agent-deployment.vbs) with server location support  
   See [Add server location to allow server move](https://github.com/EChaffraix/fusioninventory-agent/commit/16507d0a5da09e019d5baa6264b97edf3efb3164) or #220  
   [Download](https://github.com/EChaffraix/ws/fusioninventory-agent/raw/2.3.x/contrib/windows/fusioninventory-agent-deployment.vbs), thanks to @EChaffraix

 * [fusioninventory-agent-deployment.vbs](contrib/windows/fusioninventory-agent-deployment.vbs) with Telegram notification support  
   See [Implement notification in Telegram when agent was installed](https://github.com/fusioninventory/fusioninventory-agent/pull/256/commits/86c9f85516e89394523ef5641911974cfc684326) or #256  
   [Download](https://github.com/fusioninventory/fusioninventory-agent/raw/86c9f85516e89394523ef5641911974cfc684326/contrib/windows/fusioninventory-agent-deployment.vbs), thanks to @wanderleihuttel

## Submit your contribs

 * Clone [FusionInventory-Agent github repository](https://github.com/fusioninventory/fusioninventory-agent)
 * Create a dedicated branch to develop and test your contrib
 * On your 2.3.x branch, update this CONTRIB.md file to reference properly your contrib
 * Make a PR so we only include your new contrib reference
