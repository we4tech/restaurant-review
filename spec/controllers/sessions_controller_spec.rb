require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe SessionsController do
  let!(:topic) { Factory(:topic, :default => true) }

  describe '#new' do
    before { get :new }

    it 'should assign topic' do
      assigns(:topic).should be
    end

    it 'should set :return_to to session' do
      raise session.inspect
    end

    it 'should render new view'
  end

  describe '#create'

  describe '#login_as'

  describe '#auth_destroy'

  describe '#fb_auth_destroy'

end
