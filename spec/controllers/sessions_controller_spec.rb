require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do
  let!(:topic) { Factory.create(:topic, :default => true) }
  before { @request.host = "#{topic.subdomain}.test.host" }

  describe '#new' do
    before { get :new }

    it 'should assign topic' do
      assigns(:topic).should be
    end

    it 'should set :return_to to session' do
      session[:return_to].should == "http://www.test.host/?l=en"
    end

    it 'should render new view' do
      response.should render_template('sessions/_new')
    end
  end

  describe '#create'

  describe '#login_as'

  describe '#auth_destroy'

  describe '#fb_auth_destroy'

end
