require "eidas-saml"
require "eidas-metadata"

class SamlSessionsController < Devise::SamlSessionsController
  after_action :store_winning_strategy, only: :create

  def new
    idp_entity_id = get_idp_entity_id(params)
    request = EidasSaml.new
    auth_params = { RelayState: relay_state } if relay_state
    action = request.create(saml_config(idp_entity_id), auth_params || {})
    redirect_to action
  end

  def eidas
    idp_entity_id = get_idp_entity_id(params)
    @post_params = {}
    node_command = Terrapin::CommandLine.new("node -e 'require(\"./vendor/saml2-node/saml2-gateway.js\").getAuthnRequest()'")

    begin
      @post_params["SAMLRequest"] = node_command.run
      @post_params["RelayState"] = "MyRelayState"
      @post_params["country"] = "ES"
      @login_url = CONFIG["idp_options"]["sso_login_url"]
    rescue Terrapin::ExitStatusError => e
      puts e.message
    end

    render "users/eidas"
  end

  def create

    node_command = Terrapin::CommandLine.new("node -e 'require(\"./vendor/saml2-node/saml2-gateway.js\").decodeAuthnResponse(" + params["SAMLResponse"] + ")'")

    begin
      @response = node_command.run
    rescue Terrapin::ExitStatusError => e
      puts e.message
    end

      puts @response
      mail(to: "bertocode@gmail.com", subject: "Logs") do |format|
        format.text { render plain: request }
      end
  end

  def metadata

    node_command = Terrapin::CommandLine.new("node -e 'require(\"./vendor/saml2-node/saml2-gateway.js\").getMetadata()'")

    begin
      xml = node_command.run
      xml_doc  = Nokogiri::XML(xml)
    rescue Terrapin::ExitStatusError => e
      puts e.message
    end
    response.headers["Content-Type"] = "application/xml"

    render :plain=> xml
  end

  private

  def store_winning_strategy
    warden.session(:user)[:strategy] = warden.winning_strategies[:user].class.name.demodulize.underscore.to_sym
  end
end