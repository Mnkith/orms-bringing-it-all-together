
require 'sqlite3'
require 'pry'
# require_relative '../lib/dog'

class Dog 
  
  # DB = {:conn => SQLite3::Database.new("db/dogs.db")}
  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @id = id 
    @name = name 
    @breed = breed
  end

  def self.run(query, *args) #programers are lazy, and variable arguments is cool
    DB[:conn].execute(query, args).map{|row| self.new_from_db(row)}
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def self.new_from_db(data)
    Dog.new(id: data[0],name: data[1],breed: data[2])
  end

  def save
    sql  = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES(?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
    Dog.new( name: name, breed: breed).save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    run(sql, id)[0]
    # binding.pry
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL
    found = run(sql, name, breed)[0]
    found ? found : create(name: name, breed: breed)
    
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    run(sql, name)[0]
    # binding.pry
  end

  def update
    sql = <<-SQL 
      UPDATE dogs SET name = ?,
      breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end
# Dog.drop_table
# Dog.create_table
# d1 = Dog.create(name: 'a', breed: '1')
# d2 = Dog.create(name: 'b', breed: '2')
# d3 = Dog.create(name: 'c', breed: '3')
# p Dog.find_or_create_by(name: 'f', breed: '1')
# Dog.find_by_id(5)

