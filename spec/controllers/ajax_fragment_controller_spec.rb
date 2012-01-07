require File.dirname(__FILE__) + '/../spec_helper'

describe AjaxFragmentController do

  let!(:topic) { Factory.create(:topic, :default => true) }
  before { @request.host = "#{topic.subdomain}.test.host" }
  integrate_views

  context 'with empty fragment' do
    it 'should response not supported fragment' do
      get :fragment_for, {
          :__topic_id => topic.id,
          :d          => Time.now.to_i,
          :format     => 'mobile',
          :l          => 'en.js'
      }

      response.should be_success
      response.body.should == 'Not supported fragment'
    end
  end

  context 'with tailing suffix format and format params request' do
    [:top_menu, :notice,
     :authenticity_token, :best_for_box,
     :featured_box, :page_side_modules,
     :leader_board, :news_feed].each do |fragment_name|
      describe "#render_#{fragment_name}" do
        before {
          get :fragment_for, {
              :__topic_id => topic.id,
              :d          => Time.now.to_i,
              :format     => 'mobile',
              :name       => fragment_name,
              :l          => 'en.js'
          }
        }

        it 'should render successfully' do
          response.should be_success
        end

        it 'should respond in javascript format' do
          response.headers['Content-Type'].should == 'text/javascript; charset=UTF-8'
        end
      end
    end
  end
end
