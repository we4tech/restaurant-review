require File.dirname(__FILE__) + '/../spec_helper'

describe HomeController do

  let!(:topic) { Factory.create(:topic, :default => true) }
  before { @request.host = "#{topic.subdomain}.test.host" }

  describe 'allowed format' do
    integrate_views

    it "should support html format" do
      get :frontpage, :format => 'html'
      response.should_not be_redirect
      response.should be_success
      response.should render_template 'home/frontpage.html.erb'
    end

    it "should support mobile format" do
      get :frontpage, :format => 'mobile'
      response.should_not be_redirect
      response.should be_success
      response.should render_template 'home/frontpage.mobile.erb'
    end

    it 'should convert none html, mobile format to html' do
      get :frontpage, :format => 'htm..'
      response.should_not be_redirect
      response.should be_success
      response.should render_template 'home/frontpage.html.erb'
    end
  end

  describe 'allowed locales' do
    integrate_views

    context 'when valid locale' do
      it 'should load successfully' do
        get :frontpage, :l => 'en'
        response.should be_success
      end

      LocaleHelper::SUPPORTED_LOCALES.each do |locale|
        it "should load page with locale - #{locale}" do
          get :frontpage, :l => locale
          response.should be_success
          I18n.locale.should == locale.to_sym
        end
      end
    end

    context 'when invalid locale' do
      it 'should set switch to default locale' do
        get :frontpage, :l => '...'
        response.should be_success
        I18n.locale.should == I18n.default_locale
      end
    end
  end
end
