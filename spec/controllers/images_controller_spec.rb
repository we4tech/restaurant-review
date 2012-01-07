require File.dirname(__FILE__) + '/../spec_helper'

describe ImagesController do

  let!(:topic) { Factory.create(:topic, :default => true) }
  before { @request.host = "#{topic.subdomain}.test.host" }

  describe '#show' do
    integrate_views
    let!(:image) { Factory(:image, :uploaded_data => fixture_file_upload('test.png', 'image/png')) }

    context 'with valid format' do
      [:html, :mobile].each do |format|
        context "with format - #{format}" do
          before { get :show, :id => image.id, :format => format.to_s }

          it 'should render successfully' do
            response.should be_success
          end

          it 'should render show.html.erb' do
            if format == :html
              response.should render_template('images/show.html.erb')
            elsif format == :mobile
              response.should render_template('images/show.mobile.haml')
            end
          end
        end
      end
    end

    context 'with invalid format and &' do
      before { get :show, :id => image.id, :format => 'mobile&l=furniture_store_en' }

      it 'should render successfully' do
        response.should be_success
      end

      it 'should convert invalid format to mobile' do
        request.send(:format).should == 'mobile'
      end

      it 'should render show.mobile.haml' do
        response.should render_template('images/show.mobile.haml')
      end
    end
  end
end
