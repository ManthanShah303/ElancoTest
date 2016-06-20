=begin
  app/workers/contentful_deployment.rb
  Created By:   Ashutosh Sharma
  Created Date: June 9, 2016
  Description:  Job to create assets on contentful and migrate assets from one space to another
                - When invoked it will POST to an endpoint which will execute this job
=end

module ContentfulDeployment
    def self.perform
        client = Contentful::Management::Client.new(
                    ENV['CONTENTFUL_MANAGEMENT_TOKEN'],
                    default_locale: 'en-GB',
                    proxy_host: ENV['PROXY'].nil? ? nil : ENV['PROXY'].split(':')[0],
                    proxy_port: ENV['PROXY'].nil? ? nil : ENV['PROXY'].split(':')[1].to_i             
                  )
            
            @space = client.spaces.find(ENV['CONTENTFUL_SPACE_ID'])
            return "Error initializing Contentful space #{@space.error}" if @space.try(:error)
           
            create_content_types
            
            puts ">>>>>>>>>> Contentful Deployment Complete"
            
            ContentfulEntryMigration.perform
            :success
            
    end

    # Ensure the json-configuration-object content type is been created in the Conentful space that is being deployed to
    # This method is meant as a convienience when deploying to a new space
    # It will create the content types and entries which are known to be needed when setting up a new space
    def self.create_content_types
      if @space.content_types.find('json-configuration-object').try(:error)
        puts "Creating JSON Configuration Object Content Type...."
       
        jsonconfigobj = @space.content_types.create(id: 'json-configuration-object', name: 'JSON Configuration Object')
                
        jsonconfigobj.fields.create(id: 'name', name: 'Name', type: 'Symbol', localized: false)
        jsonconfigobj.fields.create(id: 'value', name: 'Value', type: 'Object', localized: true)

        return "Error creating Contentful content type #{@content_type.error}" if @content_type.try(:error)       

        jsonconfigobj.update(displayField: 'name')
        jsonconfigobj.activate

        puts "Creating Entry/Entries which is/are known for JSON Configuration Object"
        
        jsonconfigobj.entries.create(id: 'index.json', name: 'index.json')
        jsonconfigobj.entries.create(id: 'contact.json', name: 'contact.json')
      end
    end
    

    def self.create_entry(space_id, content_type_id, entry_id)
        client = Contentful::Management::Client.new(
                   ENV['CONTENTFUL_MANAGEMENT_TOKEN'],
                   default_locale: 'en-GB',
                   proxy_host: ENV['PROXY'].nil? ? nil : ENV['PROXY'].split(':')[0],
                   proxy_port: ENV['PROXY'].nil? ? nil : ENV['PROXY'].split(':')[1].to_i                  
            )
            
        @space = client.spaces.find(space_id.to_s)
        return "Error initializing Contentful space #{@space.error}" if @space.try(:error)
         
        @content_type = @space.content_types.find(content_type_id.to_s)
        return "Error initializing Contentful content type #{@content_type.error}" if @content_type.try(:error)
       
        puts "Creating Entry for #{@content_type.name}"
        
        @entry = @content_type.entries.create(id: entry_id.to_s)
        return "Error creating Contentful entry  #{@entry.error}" if @entry.try(:error)

        :success
    end

    def self.create_asset(asset_identity)
        # set up the basic HTTP request, using proxy if configured, which will be used to push entries to the destination space
        request = ContentfulEntryMigration.proxy
                    .auth("Bearer #{ENV['CONTENTFUL_MANAGEMENT_TOKEN']}")
                    .headers("Content-Type" => "application/vnd.contentful.management.v1+json")

        asset_id = asset_identity.to_s
        current_entry_version = 1
        puts "Creating asset to contentful space #{ENV['CONTENTFUL_SPACE_ID']}\n"

        res = request.headers("X-Contentful-Version" => current_entry_version)
                     .put("https://api.contentful.com/spaces/#{ENV['CONTENTFUL_SPACE_ID']}/assets/#{asset_id}")

        puts res
        return res.body.inspect if res.code >= 400

        puts "Asset created successfully!"
    end
end