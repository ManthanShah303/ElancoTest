=begin
  app/controllers/deploy/authorize_controller.rb
  Created By:   Ashutosh Sharma
  Created Date: June 16, 2016
  Description:  This controller assists in the authentication process with a contentful oAuth app.
=end
class Deploy::AuthorizeController < ApplicationController
# when the user hits the /deploy/authorize endpoint they are redirected to contentful to authenticate
  def authorize
    redirect_to "https://be.contentful.com/oauth/authorize?response_type=token&client_id=#{ENV['CONTENTFUL_MGMT_APP_CLIENT_ID']}&redirect_uri=#{ENV['API_URL']}/deploy/authorize/callback&scope=content_management_manage"
  end

  # The callback screen will simply parse the URL and display the oAuth token. See the related view
  # at views/deploy/authorize/callback.html.erb
  def callback
  	render :layout => false
  end
end
