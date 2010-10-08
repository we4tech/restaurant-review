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
    data = prepare_newly_added_fields(params[:translations])

    File.open(yml_file, 'wb') do |f|
      f.puts data.to_yaml
    end

    flash[:success] = 'Stored translation file!'
    redirect_to edit_translation_path(params[:id])
  end

  private
    def prepare_newly_added_fields(map)
      if map
        map.each do |key, value|
          if key && key == 'new'
            new_fields = find_new_fields(value)
            if !new_fields.empty?
              new_fields.each do |new_key, new_value|
                map[new_key] = new_value
              end
            end

            map.delete(key)
          else
            prepare_newly_added_fields(value)
          end
        end
      end
    end

    def find_new_fields(map)
      new_fields = {}

      if !map.empty?
        map.each do |key, value|
          newly_added_fields = value
          if !newly_added_fields.empty? &&
             !newly_added_fields['field_value'].blank? &&
             !newly_added_fields['field_name'].blank?
            new_fields[newly_added_fields['field_name']] = newly_added_fields['field_value']
          end
        end
      end

      new_fields
    end

    def load_locale_files
      @locale_files = Dir.glob(File.join(RAILS_ROOT, 'config', 'locales', '*.yml'))
      @locale_files.collect!{|file| file.split('/').last}
    end
end
