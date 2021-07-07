require 'pry'
require_relative "../config/environment.rb"

class Dog 
    attr_accessor :id, :name, :breed

    def initialize(name:, breed:, id: nil)
        @id = id
        @name = name
        @breed = breed
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
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id
          self.update
        else
          sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
          SQL
          DB[:conn].execute(sql, self.name, self.breed)
          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
      end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(id: id, name: name, breed: breed)
    end
    
    def self.find_by_id(id)
        sql = <<-SQL
        Select * from dogs
        where id = ?
        limit 1
        SQL

        DB[:conn].execute(sql,id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        Select * from dogs where name = ? and breed = ?
        limit 1
        SQL
        dog = DB[:conn].execute(sql,name,breed)
        if !dog.empty?
          dog_data = dog[0]
          dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
          dog = self.create(name: name, breed: breed)
        end
        dog
      end



    def self.find_by_name(name)
        sql = <<-SQL
        Select *
        from dogs
        where name = ?
        limit 1
        SQL
        DB[:conn].execute(sql,name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = <<-SQL
        Update dogs set name = ?,
        breed = ? where id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end