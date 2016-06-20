=begin
  app/workers/contentful_entry_migration.rb
  Created By:   Ashutosh Sharma
  Created Date: June 9, 2016
  Description:  Job to migrate assets from one space to another
=end
require 'http'
module ContentfulEntryMigration

  def self.perform(entry_id=nil)

    # if skip entry migration is configured do not perform migrations based on config file
    return if entry_id.nil? && ENV['CONTENTFUL_SKIP_ENTRY_MIGRATION'] == true

    # verify all require environment variables are present
    if verify_source_parameters==:missing || verify_destination_parameters==:missing
      return ">>>>> Entry migration aborting. Missing Source or Destination Parameters.
              If you need to migrate entries these need to be configured"
    end

    puts ">>>>>>>>>> Beginning Entry Migration"

    # initialize the array of entry ids which need to be migrated
    puts "Initializaing id array\n====================================\n\n"

    entry_id_list = []
    if entry_id.nil?
      #read list of ids that should be migrated by default from config file
      entry_id_list = ENV['CONTENTFUL_ENTRIES_TO_MIGRATE'].split "," unless ENV['CONTENTFUL_ENTRIES_TO_MIGRATE'].nil?
    else
      # Use the passed in entry id to create the list
      entry_id_list << entry_id
    end

    # retrieve each of the entries by going directly to the Management API and add it to an array
    puts "Retrieving entries from Source Space\n====================================\n\n"
    entry_list = []
    entry_id_list.each do |id|
      # use the proxy if configured and call out to contentful 
      response = proxy
                  .auth("Bearer #{ENV['CONTENTFUL_SOURCE_MGMT_TOKEN']}")
                  .headers("Content-Type": "application/vnd.contentful.management.v1+json")
                  .get("https://api.contentful.com/spaces/#{ENV['CONTENTFUL_SOURCE_SPACE_ID']}/entries/#{id}")

      return response.body.to_s if response.code != 200

      entry_list << JSON.parse(response.body, symbolize_names: true)
    end

    # set up the basic HTTP request, using proxy if configured, which will be used to push entries to the destination space
    request = proxy
                .auth("Bearer #{ENV['CONTENTFUL_MANAGEMENT_TOKEN']}")
                .headers("Content-Type" => "application/vnd.contentful.management.v1+json")

    puts "Adding entries to Destination Space\n====================================\n\n"

    entry_list.each do |entry|
      puts "#{entry[:sys][:id]}"

      res = request.get("https://api.contentful.com/spaces/#{ENV['CONTENTFUL_SPACE_ID']}/entries/#{entry[:sys][:id]}")

      if res.code == 404
        current_entry_version = 0
      else
        return res.body.inspect if res.code != 200
        current_entry = JSON.parse(res, symbolize_names: true)
        current_entry_version = current_entry[:sys][:version].to_i
      end

      body = {}
      body[:fields] = entry[:fields]

      # create/update the entry in the destination space
      res = request.headers("X-Contentful-Content-Type" => entry[:sys][:contentType][:sys][:id])
                   .headers("X-Contentful-Version" => current_entry_version)
                   .put("https://api.contentful.com/spaces/#{ENV['CONTENTFUL_SPACE_ID']}/entries/#{entry[:sys][:id]}", :json => body)

      return res.body if res.code >= 400
      puts "added to space #{ENV['CONTENTFUL_SPACE_ID']}"

      # publish the Entry
      res = request.headers("X-Contentful-Version" => current_entry_version + 1)
                   .put("https://api.contentful.com/spaces/#{ENV['CONTENTFUL_SPACE_ID']}/entries/#{entry[:sys][:id]}/published")

      return res.body.inspect if res.code >= 400
      puts "and published\n\n"
    end

    return "Completed entry migration"
  end

protected
  def self.verify_source_parameters
    if ENV['CONTENTFUL_SOURCE_SPACE_ID'].nil? || ENV['CONTENTFUL_SOURCE_MGMT_TOKEN'].nil?
      puts ">>>>> Missing CONTENTFUL_SOURCE_SPACE_ID or CONTENTFUL_SOURCE_MGMT_TOKEN environment variable"
      puts ">>>>> Exiting Entry Migration"
      return :missing
    end
  end

  def self.verify_destination_parameters
    if ENV['CONTENTFUL_SPACE_ID'].nil? || ENV['CONTENTFUL_MANAGEMENT_TOKEN'].nil?
      puts ">>>>> Missing CONTENTFUL_SPACE_ID or CONTENTFUL_MANAGEMENT_TOKEN environment variable"
      puts ">>>>> Exiting Entry Migration"
      return :missing
    end
  end

  def self.proxy
    @http_object ||=
      # if the proxy has been configured initialize the HTTP object to use the proxy
      if ENV['PROXY']
        proxy = ENV['PROXY'].split(':')
        HTTP.via(proxy[0], proxy[1].to_i)
      else
        HTTP
      end
  end
end