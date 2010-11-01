class StaticPageController < ApplicationController

  def open_search
    render :xml => %{<?xml version="1.0" encoding="UTF-8"?>
<OpenSearchDescription xmlns="http://a9.com/-/spec/opensearch/1.1/">
  <ShortName>Bangladeshi Restaurant Search</ShortName>
  <Description>Use WellTreatUs to find your nearby the best Bangladeshi restaurant</Description>
  <Tags>restaurant, bangladesh, WellTreatUs</Tags>
  <Contact>hasan@welltreat.us</Contact>
  <Url type="application/xml"
       template="#{search_url('name|description|short_array|long_array[]' => '_ST_', :format => :xml).gsub(/&/, '&amp;').gsub('_ST_', '{searchTerms}')}"/>
  <Url type="text/html"
       template="#{search_url('name|description|short_array|long_array[]' => '_ST_', :format => :html).gsub(/&/, '&amp;').gsub('_ST_', '{searchTerms}')}"/>
  <LongName>Restaurant.WellTreat.Us Bangladeshi Restaurant Search</LongName>
  <Image height="64" width="64" type="image/png">
    http://asset3.welltreat.us/images/fresh/icon.png
  </Image>
  <Image height="16" width="16" type="image/gif">
    http://asset2.welltreat.us/images/fresh/favicon.gif
  </Image>
  <Developer>Restaurant.WellTreat.Us Development Team</Developer>
  <Attribution>
    WellTreat.Us Copyright 2010., All Rights Reserved
  </Attribution>
  <SyndicationRight>open</SyndicationRight>
  <AdultContent>false</AdultContent>
  <Language>en-us</Language>
  <OutputEncoding>UTF-8</OutputEncoding>
  <InputEncoding>UTF-8</InputEncoding>
</OpenSearchDescription>

        }
  end
end
