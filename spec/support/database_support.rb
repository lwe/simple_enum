module DatabaseSupport
  def self.connect
    connection
  end

  def self.connection
    @connection_pool ||= ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
    ActiveRecord::Base.connection
  end

  def self.create_dummies
    connection.create_table :dummies, :force => true do |t|
      t.column :name, :string
      t.column :gender_cd, :integer
      t.column :word_cd, :string, :limit => 5
      t.column :role_cd, :string
      t.column :other, :integer
      t.column :numeric_cd, :string
      t.column :nilish_cd, :string
      t.column :style_cd, :integer
    end
  end

  def self.dummy(&block)
    Class.new(ActiveRecord::Base) do
      self.table_name = 'dummies'
      instance_eval &block
    end
  end
end
