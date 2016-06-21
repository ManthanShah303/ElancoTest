# Atopica

This repository is for Atopica website built upon Ruby on Rails.

## Environment Setup

The development environment can be setup on windows. Please follwo the following steps: -  

A. Create a new folder on your system and pull the latest code from this repository  
B. Set the following environment variables : -  
  #####Required
  1. CONTENTFUL_SPACE_ID -> Space Id of the associated app
  2. CONTENTFUL_MANAGEMENT_TOKEN -> A token set during Contentful Authentication
  3. CONTENTFUL_MGMT_APP_CLIENT_ID -> UID generated when creating Contentful Applications
  4. API_URL -> The URL for the app
  5. PROXY -> In order to ensure that callouts on port 443 can be made successfully
  6. HTTPS_PROXY -> In order to ensure that callouts on port 443 can be made successfully

  #####Optional
  1. CONTENTFUL_SKIP_ENTRY_MIGRATION -> True - to skip if any entry does not need to be migrated otherwise false
  2. CONTENTFUL_ENTRIES_TO_MIGRATE -> Id of the entries to be migrated separated with comma
  3. CONTENTFUL_SOURCE_MGMT_TOKEN -> Management token of the source space from whichentries need to be migrated
  4. CONTENTFUL_SOURCE_SPACE_ID -> Space Id of the space which is the source of migration

  The values depend on the working environment.

###Issues

You might face some general issues during development, such as: -

1. **SSL Endpoint Error** - Please refer [here](https://gist.github.com/fnichol/867550) for better understanding
2. **Contentful issues** - Please refer to their [developer center](https://www.contentful.com/developers/docs/)