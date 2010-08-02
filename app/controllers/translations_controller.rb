class TranslationsController < ApplicationController

  before_filter :login_required
  before_filter :authorize, :except => []
  before_filter :load_locale_files

  def index
    @locales = @locale_files.collect{|file| file.split('.').first}
  end

  def edit
    @translation_map = YAML.load_file(File.join(RAILS_ROOT, 'config', 'locales', "#{params[:id]}.yml"))
  end

  def update
    yml_file = File.join(RAILS_ROOT, 'config', 'locales', "#{params[:id]}.yml")
    File.open(yml_file, 'wb') do |f|
      f.puts params[:translations].to_yaml
    end

    flash[:success] = 'Stored translation file!'
    redirect_to edit_translation_path(params[:id])
  end

  private
    def load_locale_files
      @locale_files = Dir.glob(File.join(RAILS_ROOT, 'config', 'locales', '*.yml'))
      @locale_files.collect!{|file| file.split('/').last}
    end
end
