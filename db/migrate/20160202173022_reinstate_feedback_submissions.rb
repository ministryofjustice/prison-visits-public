class ReinstateFeedbackSubmissions < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    
    create_table :feedback_submissions, id: :uuid do |t|
      t.text :body, null: false
      t.string :email_address
      t.string :referrer
      t.string :user_agent
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
