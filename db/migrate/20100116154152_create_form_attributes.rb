class CreateFormAttributes < ActiveRecord::Migration
  def self.up
    create_table :form_attributes do |t|
      t.integer :topic_id
      t.text :fields

      t.timestamps
    end

    add_index :form_attributes, [:topic_id]

    Topic.all.each do |topic|
      if topic.form_attribute.nil?
        form_attribute = FormAttribute.new
        form_attribute.topic_id = topic.id
        form_attribute.fields = [
            {'field' => 'name', 'type' => 'text_field', 'required' => true, 'index' => 0},
            {'field' => 'description', 'type' => 'text_area', 'required' => true, 'index' => 1},
            {'field' => 'address', 'type' => 'text_field', 'required' => true, 'index' => 2}]
        form_attribute.save
      end
    end
  end

  def self.down
    drop_table :form_attributes
  end
end
