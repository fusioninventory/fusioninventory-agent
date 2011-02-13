Group Policy Templates for FusionInventory Agent
------------------------------------------------
These Group Policy templates give you the policy to control certain parameters
of the FusionInventory agent. Templates in ADMX format can be used by group
policy editor starting Windows Vista and Windows Server 2008.

How to install
--------------
You have to copy the ADMX file and an ADML file in your language. Just have to
copy them to specific folders depending your usage:

For local group policies:
 - ADMX File: %systemroot%\PolicyDefinitions
 - ADML File: %systemroot%\policyDefinitions\<yourLocale>

In a Windows Domain:
 - ADMX File: %systemroot%\sysvol\domain\policies\PolicyDefinitions
 - ADML File: %systemroot%\sysvol\domain\policies\PolicyDefinitions\<yourLocale>

Afterwards you have to restart the group policy editor to see a section 
"FusionInventory Agent" (might be different depending your locale) under

  Computer Configuration -> Administrative Templates -> System

If the ADML for your language is missing yet, you temporarily take the english
ADML, or any other language's ADML file and copy it in the locale folder of your 
language.
