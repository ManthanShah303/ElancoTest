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
                    proxy_port: ENV['PROXY'].nil? ? nil : ENV['PROXY'].split(':')[1].to_i,
                    raise_errors: true
                  )
            
            space = client.spaces.find(ENV['CONTENTFUL_SPACE_ID'])
            return "Error initializing Contentful space #{space.error}" if space.try(:error)
           
            create_content_types(space)
            
            puts ">>>>>>>>>> Asset Deployment Complete"
            
            #ContentfulEntryMigration.perform
            :success
            
    end
    
    def self.create_content_types(space)
      if space.content_types.find('json-configuration-object').try(:error)
        puts "Creating JSON Configuration Object Content Type...."
       
        jsonconfigobj = space.content_types.create(id: 'json-configuration-object', name: 'JSON Configuration Object')
       
        
        jsonconfigobj.fields.create(id: 'name', name: 'Name', type: 'Symbol', localized: false)
        jsonconfigobj.fields.create(id: 'value', name: 'Value', type: 'Object', localized: true)
        jsonconfigobj.update(displayField: 'name')
        jsonconfigobj.activate

        puts "Creating Entry/Entries which is/are known for JSON Configuration Object"
        contents = []
        contents << jsonconfigobj.entries.create(id: 'index.json', name: 'index.json')
        contents << jsonconfigobj.entries.create(id: 'contact.json', name: 'contact.json')
        contents.map(&:publish)
      end
    end
    
    def self.create_entry(space_id, content_type_id, entry_id)
        client = Contentful::Management::Client.new(
                   ENV['CONTENTFUL_MANAGEMENT_TOKEN'],
                   default_locale: 'en-GB',
                   proxy_host: ENV['PROXY'].nil? ? nil : ENV['PROXY'].split(':')[0],
                   proxy_port: ENV['PROXY'].nil? ? nil : ENV['PROXY'].split(':')[1].to_i,
                   raise_errors: true
            )
            
        space = client.spaces.find(space_id.to_s)
        return "Error initializing Contentful space #{space.error}" if space.try(:error)
         
        content_type = space.content_types.find(content_type_id.to_s)
        return "Error initializing Contentful content type #{content_type.error}" if content_type.try(:error)
       
        puts "Creating Entry for #{content_type.name}"
        
        entry = content_type.entries.create(id: entry_id.to_s)
        entry.publish
    end
end