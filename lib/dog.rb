require 'pry'
require_relative "../config/environment.rb"

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    if self.id
      update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    return self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.new_from_db(row)
    dog = Dog.new(name: row[1], breed: row[2], id: row[0])
    dog
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    DB[:conn].execute(sql, name, breed)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
