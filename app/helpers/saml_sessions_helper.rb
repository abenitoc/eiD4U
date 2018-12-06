
require 'json'

module SamlSessionsHelper
  requested_eidas_attrs = File.read(Rails.root + 'vendor/saml2-node/requested_attributes.json')
  parsed_eidas_attrs = {}
  begin 
    parsed_eidas_attrs = JSON.parse(requested_eidas_attrs)
  rescue
  end
  def generate_metadata

  end
  def saml_attrs_to_model_attrs
  	{
  		 "PersonIdentifier" => "person_identifier",
  		 "FamilyName" => "family_name",
  		 "FirstName" => "first_name",
  		 "DateOfBirth" => "birth_date",
       "PlaceOfBirth" => "born_place",
       "CurrentAddress"  => "permanent_adress",
       "Gender" => "sex"
  	}

  end

  def get_eidas_requested_attrs
    requested_attributes = REQUESTED_EIDAS_ATTRS

    array_natural = ["PersonIdentifier" , "FamilyName", "FirstName", "DateOfBirth", "PlaceOfBirth", "CurrentAddress", "Gender"]
    array_legal = ["LegalPersonIdentifier", "LegalName"]
    array_representative = []
    attrs = []

    array_natural.each do |attr| 
        attrVal = requested_attributes["NaturalPerson"][attr]
        attrs.push({ "Name" => attrVal["@Name"], "FriendlyName" => attrVal["@FriendlyName"], "NameFormat" => attrVal["@NameFormat"], "isRequired" => attrVal["@isRequired"]})
    end

    array_legal.each do |attr| 
        attrVal = requested_attributes["LegalPerson"][attr]
        attrs.push({ "Name" => attrVal["@Name"], "FriendlyName" => attrVal["@FriendlyName"], "NameFormat" => attrVal["@NameFormat"], "isRequired" => attrVal["@isRequired"]})
    end

    array_representative.each do |attr| 
        attrVal = requested_attributes["RepresentativeNaturalPerson"][attr]
        attrs.push({ "Name" => attrVal["@Name"], "FriendlyName" => attrVal["@FriendlyName"], "NameFormat" => attrVal["@NameFormat"], "isRequired" => attrVal["@isRequired"]})
    end

    attrs
  end
end