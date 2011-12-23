require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do

  context 'without topic' do

  end

  context 'with topic' do
    let!(:topic) { Factory(:topic, :default => true) }
    it 'should redirect to topic url with locale inserted' do
      get '/'
      expected_url = root_url(:subdomain => topic.subdomain)
      expected_url.insert(expected_url.index('?'), 'application//')
      response.should redirect_to(expected_url)
    end

    it 'should redirect to topic url' do
      get '/'
      response.should redirect_to("http://#{topic.hosts}")
    end
  end

end
